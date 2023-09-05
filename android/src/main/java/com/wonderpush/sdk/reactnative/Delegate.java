package com.wonderpush.sdk.reactnative;

import android.content.Context;
import android.util.Pair;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.common.LifecycleState;
import com.wonderpush.sdk.DeepLinkEvent;
import com.wonderpush.sdk.WonderPushDelegate;

import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

public class Delegate implements WonderPushDelegate {
    public interface SubDelegate extends WonderPushDelegate {
        boolean subDelegateIsReady();
    }
    private Context context;
    private static WeakReference<SubDelegate> subDelegate;
    private static final List<Pair<JSONObject, Integer>> savedOpenedNotifications = new ArrayList<>();
    private static final List<JSONObject> savedReceivedNotifications = new ArrayList<>();

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

        if (!subDelegateIsReady()) {
            synchronized (Delegate.class) {
                // Save for later
                savedOpenedNotifications.add(new Pair<>(notif, buttonIndex));
            }
            // Forward to background task for listening to received notifications.
            final ReactInstanceManager reactInstanceManager =
                    getReactNativeHost().getReactInstanceManager();
            ReactContext reactContext = reactInstanceManager != null ? reactInstanceManager.getCurrentReactContext() : null;

            // Only if we're in the background
            LifecycleState state = reactContext != null ? reactContext.getLifecycleState() : null;
            if (reactContext == null || state == LifecycleState.BEFORE_CREATE) {
                UiThreadUtil.runOnUiThread(reactInstanceManager::createReactContextInBackground);
            }
            return;
        }

        WonderPushDelegate delegate = Delegate.subDelegate != null ? Delegate.subDelegate.get() : null;
        if (delegate != null) {
            delegate.onNotificationOpened(notif, buttonIndex);
        }
    }

    @Override
    public void onNotificationReceived(JSONObject notif) {

        if (!subDelegateIsReady()) {
            // Save for later
            synchronized (Delegate.class) {
                savedReceivedNotifications.add(notif);
            }

            // Forward to background task for listening to received notifications.
            final ReactInstanceManager reactInstanceManager =
                    getReactNativeHost().getReactInstanceManager();
            ReactContext reactContext = reactInstanceManager != null ? reactInstanceManager.getCurrentReactContext() : null;

            // Only if we're in the background
            LifecycleState state = reactContext != null ? reactContext.getLifecycleState() : null;
            if (reactContext == null || state == LifecycleState.BEFORE_CREATE) {
                UiThreadUtil.runOnUiThread(reactInstanceManager::createReactContextInBackground);
            }
            return;
        }

        WonderPushDelegate delegate = Delegate.subDelegate != null ? Delegate.subDelegate.get() : null;
        if (delegate != null) {
            delegate.onNotificationReceived(notif);
        }
    }

    private static boolean subDelegateIsReady() {
        SubDelegate subDelegate = Delegate.subDelegate != null ? Delegate.subDelegate.get() : null;
        return subDelegate != null && subDelegate.subDelegateIsReady();
    }

    protected ReactNativeHost getReactNativeHost() {
        return ((ReactApplication) context.getApplicationContext()).getReactNativeHost();
    }

}
