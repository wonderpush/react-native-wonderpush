package com.wonderpush.sdk.reactnative;

import static android.content.Context.POWER_SERVICE;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.PowerManager;
import android.util.Log;
import android.util.Pair;

import androidx.annotation.Nullable;

import com.facebook.infer.annotation.Assertions;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceEventListener;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.common.LifecycleState;
import com.facebook.react.jstasks.HeadlessJsTaskConfig;
import com.facebook.react.jstasks.HeadlessJsTaskContext;
import com.facebook.react.jstasks.HeadlessJsTaskEventListener;
import com.wonderpush.sdk.ContextReceiver;
import com.wonderpush.sdk.DeepLinkEvent;
import com.wonderpush.sdk.WonderPushDelegate;

import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

public class Delegate implements WonderPushDelegate, ContextReceiver {
    public interface SubDelegate extends WonderPushDelegate {
        boolean subDelegateIsReady();
    }
    private Context context;

    private final BackgroundForwarder backgroundForwarder = new BackgroundForwarder();

    private String headlessTaskName;
    private static List<WeakReference<SubDelegate>> subDelegates = new ArrayList<>();
    private static final List<Pair<JSONObject, Integer>> savedOpenedNotifications = new ArrayList<>();
    private static final List<JSONObject> savedReceivedNotifications = new ArrayList<>();

    private static final String HEADLESS_TASK_NAME_METADATA = "com.wonderpush.sdk.headlessTaskName";

    private static final String TAG = "WonderPush";

    protected static Pair<JSONObject, Integer> consumeSavedOpenedNotification() {
        synchronized (Delegate.class) {
            if (savedOpenedNotifications.size() > 0) {
                Pair<JSONObject, Integer> result = savedOpenedNotifications.get(0);
                savedOpenedNotifications.remove(0);
                return result;
            }
            return null;
        }
    }

    protected static JSONObject consumeSavedReceivedNotification() {
        synchronized (Delegate.class) {
            if (savedReceivedNotifications.size() > 0) {
                JSONObject result = savedReceivedNotifications.get(0);
                savedReceivedNotifications.remove(0);
                return result;
            }
            return null;
        }
    }

    protected static void addSubDelegate(SubDelegate subDelegate) {
        synchronized (Delegate.class) {
            subDelegates.add(new WeakReference<>(subDelegate));
        }
    }

    @Override
    public void setContext(Context context) {
        this.context = context;
        try {
            Bundle metaData = this.context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA).metaData;
            this.headlessTaskName = metaData != null ? metaData.getString(HEADLESS_TASK_NAME_METADATA) : null;
        } catch (PackageManager.NameNotFoundException e) {
        }

    }


    @Override
    public String urlForDeepLink(DeepLinkEvent event) {
        String defaultUrl = event.getUrl();
        synchronized (Delegate.class) {
            for (WeakReference<SubDelegate> subDelegate : subDelegates) {
                WonderPushDelegate delegate = subDelegate.get();
                if (delegate == null) continue;
                String alternateUrl = delegate.urlForDeepLink(event);
                if (alternateUrl == null && defaultUrl == null) continue;
                if (alternateUrl != null && alternateUrl.equals(defaultUrl)) continue;
                return alternateUrl;
            }
        }
        return defaultUrl;
    }

    @Override
    public void onNotificationOpened(JSONObject notif, int buttonIndex) {
        synchronized (Delegate.class) {
            if (!hasReadySubDelegates()) {
                // Save for later
                savedOpenedNotifications.add(new Pair<>(notif, buttonIndex));
                return;
            }
            for (WeakReference<SubDelegate> subDelegate : subDelegates) {
                WonderPushDelegate delegate = subDelegate.get();
                if (delegate == null) continue;
                delegate.onNotificationOpened(notif, buttonIndex);
            }
        }
    }

    @Override
    public void onNotificationReceived(JSONObject notif) {
        synchronized (Delegate.class) {

            // Forward to background task for listening to received notifications.
            final ReactInstanceManager reactInstanceManager =
                    getReactNativeHost().getReactInstanceManager();
            ReactContext reactContext = reactInstanceManager != null ? reactInstanceManager.getCurrentReactContext() : null;
            // Only if we're in the background
            if (reactContext == null || reactContext.getLifecycleState() != LifecycleState.RESUMED) {
                UiThreadUtil.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        backgroundForwarder.startTask(notif);
                    }
                });
                return;
            }

            if (!hasReadySubDelegates()) {
                // Save for later
                savedReceivedNotifications.add(notif);
                return;
            }
            for (WeakReference<SubDelegate> subDelegate : subDelegates) {
                WonderPushDelegate delegate = subDelegate.get();
                if (delegate == null) continue;
                delegate.onNotificationReceived(notif);
            }
        }
    }

    private static boolean hasReadySubDelegates() {
        for (WeakReference<SubDelegate> sd : subDelegates) {
            SubDelegate subDelegate = sd.get();
            if (subDelegate != null && subDelegate.subDelegateIsReady()) {
                return true;
            }
        }
        return false;
    }

    private static @Nullable PowerManager.WakeLock sWakeLock;

    @SuppressLint("WakelockTimeout")
    public static void acquireWakeLockNow(Context context) {
        if (sWakeLock == null || !sWakeLock.isHeld()) {
            PowerManager powerManager =
                    Assertions.assertNotNull((PowerManager) context.getSystemService(POWER_SERVICE));
            sWakeLock =
                    powerManager.newWakeLock(
                            PowerManager.PARTIAL_WAKE_LOCK, Delegate.class.getCanonicalName());
            sWakeLock.setReferenceCounted(false);
            sWakeLock.acquire();
        }
    }

    protected ReactNativeHost getReactNativeHost() {
        return ((ReactApplication) context.getApplicationContext()).getReactNativeHost();
    }

    private class BackgroundForwarder implements HeadlessJsTaskEventListener {

        private final Set<Integer> mActiveTasks = new CopyOnWriteArraySet<>();

        protected void startTask(final JSONObject notif) {

            Bundle bundle = new Bundle();
            bundle.putString("notification", notif.toString());
            HeadlessJsTaskConfig taskConfig = new HeadlessJsTaskConfig(
                    headlessTaskName != null ? headlessTaskName : "WonderPushNotificationReceived",
                    Arguments.fromBundle(bundle),
                    5000, // timeout in milliseconds for the task
                    false // optional: defines whether or not the task is allowed in foreground. Default is false
            );

            UiThreadUtil.assertOnUiThread();
            acquireWakeLockNow(context);
            final ReactInstanceManager reactInstanceManager =
                    getReactNativeHost().getReactInstanceManager();
            ReactContext reactContext = reactInstanceManager.getCurrentReactContext();
            if (reactContext == null) {
                reactInstanceManager.addReactInstanceEventListener(
                        new ReactInstanceEventListener() {
                            @Override
                            public void onReactContextInitialized(ReactContext reactContext) {
                                invokeStartTask(reactContext, taskConfig);
                                reactInstanceManager.removeReactInstanceEventListener(this);
                            }
                        });
                reactInstanceManager.createReactContextInBackground();
            } else {
                invokeStartTask(reactContext, taskConfig);
            }
        }


        private void invokeStartTask(ReactContext reactContext, final HeadlessJsTaskConfig taskConfig) {
            final HeadlessJsTaskContext headlessJsTaskContext =
                    HeadlessJsTaskContext.getInstance(reactContext);
            headlessJsTaskContext.addTaskEventListener(this);

            UiThreadUtil.runOnUiThread(
                    new Runnable() {
                        @Override
                        public void run() {
                            int taskId = headlessJsTaskContext.startTask(taskConfig);
                            mActiveTasks.add(taskId);
                        }
                    });
        }


        @Override
        public void onHeadlessJsTaskStart(int taskId) {}

        @Override
        public void onHeadlessJsTaskFinish(int taskId) {
            mActiveTasks.remove(taskId);
            if (mActiveTasks.size() == 0) {
                cleanup();
            }
        }
        private void cleanup() {

            if (getReactNativeHost().hasInstance()) {
                ReactInstanceManager reactInstanceManager = getReactNativeHost().getReactInstanceManager();
                ReactContext reactContext = reactInstanceManager.getCurrentReactContext();
                if (reactContext != null) {
                    HeadlessJsTaskContext headlessJsTaskContext =
                            HeadlessJsTaskContext.getInstance(reactContext);
                    headlessJsTaskContext.removeTaskEventListener(this);
                }
            }
            if (sWakeLock != null) {
                sWakeLock.release();
            }
        }
    }
}
