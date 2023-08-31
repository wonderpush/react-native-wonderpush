package com.wonderpush.sdk.reactnative;

import static android.content.Context.POWER_SERVICE;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.PowerManager;
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
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.LifecycleState;
import com.facebook.react.jstasks.HeadlessJsTaskConfig;
import com.facebook.react.jstasks.HeadlessJsTaskContext;
import com.facebook.react.jstasks.HeadlessJsTaskEventListener;
import com.wonderpush.sdk.DeepLinkEvent;
import com.wonderpush.sdk.WonderPushDelegate;

import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

public class Delegate implements WonderPushDelegate {
    public interface SubDelegate extends WonderPushDelegate {
        boolean subDelegateIsReady();
    }
    private Context context;

    private final BackgroundForwarder backgroundForwarder = new BackgroundForwarder();

    private String notificationReceivedHeadlessTaskName;
    private String notificationOpenedHeadlessTaskName;
    private static WeakReference<SubDelegate> subDelegate;
    private static final List<Pair<JSONObject, Integer>> savedOpenedNotifications = new ArrayList<>();
    private static final List<JSONObject> savedReceivedNotifications = new ArrayList<>();

    private static final String NOTIFICATION_RECEIVED_HEADLESS_TASK_NAME_METADATA = "com.wonderpush.sdk.notificationReceivedHeadlessTaskName";
    private static final String NOTIFICATION_OPENED_HEADLESS_TASK_NAME_METADATA = "com.wonderpush.sdk.notificationOpenedHeadlessTaskName";

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

    protected static void setSubDelegate(SubDelegate subDelegate) {
        synchronized (Delegate.class) {
            Delegate.subDelegate = new WeakReference<>(subDelegate);
        }
    }

    @Override
    public void setContext(Context context) {
        this.context = context;
        try {
            Bundle metaData = this.context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA).metaData;
            this.notificationReceivedHeadlessTaskName = metaData != null ? metaData.getString(NOTIFICATION_RECEIVED_HEADLESS_TASK_NAME_METADATA) : null;
            this.notificationOpenedHeadlessTaskName = metaData != null ? metaData.getString(NOTIFICATION_OPENED_HEADLESS_TASK_NAME_METADATA) : null;
        } catch (PackageManager.NameNotFoundException e) {
        }

    }


    @Override
    public String urlForDeepLink(DeepLinkEvent event) {
        String defaultUrl = event.getUrl();
        synchronized (Delegate.class) {
            SubDelegate subDelegate = Delegate.subDelegate != null ? Delegate.subDelegate.get() : null;
            if (subDelegate != null) {
                return subDelegate.urlForDeepLink(event);
            }
        }
        return defaultUrl;
    }

    @Override
    public void onNotificationOpened(JSONObject notif, int buttonIndex) {
        synchronized (Delegate.class) {

            // Forward to background task for listening to received notifications.
            final ReactInstanceManager reactInstanceManager =
                    getReactNativeHost().getReactInstanceManager();
            ReactContext reactContext = reactInstanceManager != null ? reactInstanceManager.getCurrentReactContext() : null;

            // Only if we're in the background
            LifecycleState state = reactContext != null ? reactContext.getLifecycleState() : null;
            if (reactContext == null || state == LifecycleState.BEFORE_CREATE) {
                UiThreadUtil.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        backgroundForwarder.forwardNotificationOpened(notif, buttonIndex);
                    }
                });
                return;
            }

            if (!subDelegateIsReady()) {
                // Save for later
                savedOpenedNotifications.add(new Pair<>(notif, buttonIndex));
                return;
            }
            WonderPushDelegate delegate = Delegate.subDelegate != null ? Delegate.subDelegate.get() : null;
            if (delegate != null) {
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
            LifecycleState state = reactContext != null ? reactContext.getLifecycleState() : null;
            if (reactContext == null || state == LifecycleState.BEFORE_CREATE) {
                UiThreadUtil.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        backgroundForwarder.forwardNotificationReceived(notif);
                    }
                });
                return;
            }

            if (!subDelegateIsReady()) {
                // Save for later
                savedReceivedNotifications.add(notif);
                return;
            }
            WonderPushDelegate delegate = Delegate.subDelegate != null ? Delegate.subDelegate.get() : null;
            if (delegate != null) {
                delegate.onNotificationReceived(notif);
            }
        }
    }

    private static boolean subDelegateIsReady() {
        SubDelegate subDelegate = Delegate.subDelegate != null ? Delegate.subDelegate.get() : null;
        return subDelegate != null && subDelegate.subDelegateIsReady();
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

        protected void forwardNotificationReceived(final JSONObject notif) {
            Bundle bundle = new Bundle();
            bundle.putString("notification", notif.toString());
            startTask(Arguments.fromBundle(bundle), notificationReceivedHeadlessTaskName != null ? notificationReceivedHeadlessTaskName : "WonderPushNotificationReceived");
        }

        protected void forwardNotificationOpened(final JSONObject notif, int buttonIndex) {
            Bundle bundle = new Bundle();
            bundle.putString("notification", notif.toString());
            bundle.putInt("buttonIndex", buttonIndex);
            startTask(Arguments.fromBundle(bundle), notificationOpenedHeadlessTaskName != null ? notificationOpenedHeadlessTaskName : "WonderPushNotificationOpened");
        }

        protected void startTask(WritableMap args, String headlessTaskName) {

            HeadlessJsTaskConfig taskConfig = new HeadlessJsTaskConfig(
                    headlessTaskName,
                    args,
                    5000, // timeout in milliseconds for the task
                    true // task allowed in the foreground. There is a race condition when opening a notification and the app is not started
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
