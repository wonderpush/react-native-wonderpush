package com.wonderpush.sdk.reactnative;

import android.content.Context;
import com.wonderpush.sdk.WonderPush;
import com.wonderpush.sdk.WonderPushDelegate;
import com.wonderpush.sdk.DeepLinkEvent;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.ReactContext;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

public class Delegate implements WonderPushDelegate {

    private Context context = null;
    private static WeakReference<WonderPushDelegate> sSubDelegate = new WeakReference<>(null);
    private static final List<JSONObject> sSavedReceivedNotifications = new ArrayList<>();
    private static final List<NotificationOpenedInfo> sSavedOpenedNotifications = new ArrayList<>();

    public static class NotificationOpenedInfo {
        public final JSONObject notification;
        public final int buttonIndex;

        NotificationOpenedInfo(JSONObject notification, int buttonIndex) {
            this.notification = notification;
            this.buttonIndex = buttonIndex;
        }
    }

    public static synchronized void setSubDelegate(WonderPushDelegate subDelegate) {
        sSubDelegate = new WeakReference<>(subDelegate);

        // Flush any saved notifications to the new sub delegate
        WonderPushDelegate delegate = sSubDelegate.get();
        if (delegate != null) {
            // Process saved received notifications
            for (JSONObject notification : sSavedReceivedNotifications) {
                delegate.onNotificationReceived(notification);
            }
            sSavedReceivedNotifications.clear();

            // Process saved opened notifications
            for (NotificationOpenedInfo info : sSavedOpenedNotifications) {
                delegate.onNotificationOpened(info.notification, info.buttonIndex);
            }
            sSavedOpenedNotifications.clear();
        }
    }

    public static synchronized JSONObject consumeSavedReceivedNotification() {
        if (!sSavedReceivedNotifications.isEmpty()) {
            return sSavedReceivedNotifications.remove(0);
        }
        return null;
    }

    public static synchronized NotificationOpenedInfo consumeSavedOpenedNotification() {
        if (!sSavedOpenedNotifications.isEmpty()) {
            return sSavedOpenedNotifications.remove(0);
        }
        return null;
    }

    public static synchronized boolean hasSavedOpenedNotifications() {
        return !sSavedOpenedNotifications.isEmpty();
    }

    public static synchronized boolean hasSavedReceivedNotifications() {
        return !sSavedReceivedNotifications.isEmpty();
    }

    @Override
    public void setContext(Context context) {
        this.context = context.getApplicationContext();
    }

    @Override
    public String urlForDeepLink(DeepLinkEvent event) {
        WonderPushDelegate subDelegate = sSubDelegate.get();
        if (subDelegate != null) {
            return subDelegate.urlForDeepLink(event);
        }

        // Try to initialize React Native context and wait for it (with timeout)
        if (tryInitializeAndWaitForReactNativeContext(2750)) {
            // Context is ready, check if subDelegate is now available
            subDelegate = sSubDelegate.get();
            if (subDelegate != null) {
                return subDelegate.urlForDeepLink(event);
            }
        }

        // Either React Native didn't start in time, or delegate wasn't set
        return event.getUrl();
    }

    @Override
    public synchronized void onNotificationReceived(JSONObject notification) {
        WonderPushDelegate subDelegate = sSubDelegate.get();
        if (subDelegate != null) {
            // Forward to the active sub delegate
            subDelegate.onNotificationReceived(notification);
        } else {
            // Save the notification for later processing
            sSavedReceivedNotifications.add(notification);

            // Try to initialize React Native context in background
            tryInitializeReactNativeContext();
        }
    }

    @Override
    public synchronized void onNotificationOpened(JSONObject notification, int buttonIndex) {
        WonderPushDelegate subDelegate = sSubDelegate.get();
        if (subDelegate != null) {
            // Forward to the active sub delegate
            subDelegate.onNotificationOpened(notification, buttonIndex);
        } else {
            // Save the notification for later processing
            sSavedOpenedNotifications.add(new NotificationOpenedInfo(notification, buttonIndex));

            // Try to initialize React Native context in background
            tryInitializeReactNativeContext();
        }
    }

    private void tryInitializeReactNativeContext() {
        try {
            if (this.context instanceof ReactApplication) {
                ReactApplication reactApp = (ReactApplication) this.context;
                ReactInstanceManager reactInstanceManager = reactApp.getReactNativeHost().getReactInstanceManager();

                if (!reactInstanceManager.hasStartedCreatingInitialContext()) {
                    // Create the React context in background if not already started
                    reactInstanceManager.createReactContextInBackground();
                }
            }
        } catch (Exception e) {
            // Silently handle any errors during context initialization
            android.util.Log.w("WonderPush", "Failed to initialize React context in background", e);
        }
    }

    /**
     * Try to initialize React Native context and wait for it to be ready.
     * @param timeoutMs Maximum time to wait in milliseconds
     * @return true if context is ready, false if timeout or error
     */
    private boolean tryInitializeAndWaitForReactNativeContext(long timeoutMs) {
        try {
            if (!(this.context instanceof ReactApplication)) {
                return false;
            }

            ReactApplication reactApp = (ReactApplication) this.context;
            ReactInstanceManager reactInstanceManager = reactApp.getReactNativeHost().getReactInstanceManager();

            // If context already exists, return immediately
            ReactContext reactContext = reactInstanceManager.getCurrentReactContext();
            if (reactContext != null) {
                return true;
            }

            // Use a CountDownLatch to wait for context creation
            final java.util.concurrent.CountDownLatch latch = new java.util.concurrent.CountDownLatch(1);
            final java.util.concurrent.atomic.AtomicBoolean contextReady = new java.util.concurrent.atomic.AtomicBoolean(false);

            // Add a listener for when the context is created
            reactInstanceManager.addReactInstanceEventListener(new com.facebook.react.ReactInstanceManager.ReactInstanceEventListener() {
                @Override
                public void onReactContextInitialized(ReactContext context) {
                    contextReady.set(true);
                    latch.countDown();
                    // Remove this listener after it fires
                    reactInstanceManager.removeReactInstanceEventListener(this);
                }
            });

            // Start creating the context if not already started
            if (!reactInstanceManager.hasStartedCreatingInitialContext()) {
                reactInstanceManager.createReactContextInBackground();
            }

            // Check again if context was created while we were setting up the listener
            if (reactInstanceManager.getCurrentReactContext() != null) {
                return true;
            }

            // Wait for the context to be ready with timeout
            boolean completed = latch.await(timeoutMs, java.util.concurrent.TimeUnit.MILLISECONDS);
            return completed && contextReady.get();

        } catch (Exception e) {
            android.util.Log.w("WonderPush", "Failed to initialize and wait for React context", e);
            return false;
        }
    }
}
