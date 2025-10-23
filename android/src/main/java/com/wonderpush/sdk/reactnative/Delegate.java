package com.wonderpush.sdk.reactnative;

import android.content.Context;
import android.util.Log;
import com.wonderpush.sdk.WonderPush;
import com.wonderpush.sdk.WonderPushDelegate;
import com.wonderpush.sdk.WonderPushSettings;
import com.wonderpush.sdk.DeepLinkEvent;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.ReactContext;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

public class Delegate implements WonderPushDelegate {

    private Context context = null;
    private static WeakReference<WonderPushDelegate> sSubDelegate = new WeakReference<>(null);
    private static final List<JSONObject> sSavedReceivedNotifications = new ArrayList<>();
    private static final List<NotificationOpenedInfo> sSavedOpenedNotifications = new ArrayList<>();

    // For handling pending DeepLinkEvent
    private static DeepLinkEvent sPendingDeepLinkEvent = null;
    private static CompletableFuture<String> sPendingDeepLinkFuture = null;

    public static class NotificationOpenedInfo {
        public final JSONObject notification;
        public final int buttonIndex;

        NotificationOpenedInfo(JSONObject notification, int buttonIndex) {
            this.notification = notification;
            this.buttonIndex = buttonIndex;
        }
    }

    public static synchronized void setSubDelegate(WonderPushDelegate subDelegate) {
        Log.d("WonderPushRN.Delegate", "setSubDelegate(" + subDelegate + ")");
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

    /**
     * Process any pending DeepLinkEvent with the current sub delegate.
     * This should be called when the JavaScript delegate is ready (from flushDelegateEvents).
     * This method spawns a background thread to avoid blocking the bridge thread.
     */
    public static synchronized void processPendingDeepLinkEvent() {
        Log.d("WonderPushRN.Delegate", "processPendingDeepLinkEvent()");
        // Get a local copy of the variables to work on (in case sPendingDeepLinkFuture is nullified in between)
        final DeepLinkEvent pendingDeepLinkEvent = sPendingDeepLinkEvent;
        final CompletableFuture<String> pendingDeepLinkFuture = sPendingDeepLinkFuture;
        if (pendingDeepLinkEvent != null && pendingDeepLinkFuture != null) {
            final WonderPushDelegate subDelegate = sSubDelegate.get();
            if (subDelegate != null) {
                Log.d("WonderPushRN.Delegate", "Processing pending DeepLinkEvent on background thread");
                // Spawn a background thread to avoid blocking the bridge thread
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            Log.d("WonderPushRN.Delegate", "Background thread: calling subDelegate.urlForDeepLink()");
                            String result = subDelegate.urlForDeepLink(pendingDeepLinkEvent);
                            Log.d("WonderPushRN.Delegate", "Background thread: got result for pending DeepLinkEvent: " + result);
                            pendingDeepLinkFuture.complete(result);
                        } catch (Exception e) {
                            Log.e("WonderPushRN.Delegate", "Background thread: error processing pending DeepLinkEvent", e);
                            // Complete with original URL on error
                            pendingDeepLinkFuture.complete(pendingDeepLinkEvent.getUrl());
                        }
                    }
                }).start();
                // Return immediately to free the bridge thread
                // Note: Don't clear sPendingDeepLinkEvent and sPendingDeepLinkFuture here
                // They will be cleared by the urlForDeepLink method
            } else {
                // Complete with original URL if there is no sub-delegate (should not happen)
                Log.d("WonderPushRN.Delegate", "No sub-delegate available, completing with original URL");
                pendingDeepLinkFuture.complete(pendingDeepLinkEvent.getUrl());
            }
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

    /**
     * Check if background React Native context initialization is allowed.
     * This is an opt-in feature controlled by WonderPushSettings.
     * @return true if explicitly enabled, false otherwise (default)
     */
    private boolean shouldAllowBackgroundStart() {
        Boolean setting = WonderPushSettings.getBoolean(
            "WONDERPUSH_REACTNATIVE_ALLOW_BACKGROUND_START",
            "wonderpush_reactNative_allowBackgroundStart",
            "com.wonderpush.sdk.reactnative.allowBackgroundStart"
        );
        // Only return true if explicitly set to true (null or false = disabled)
        return Boolean.TRUE.equals(setting);
    }

    @Override
    public String urlForDeepLink(DeepLinkEvent event) {
        Log.d("WonderPushRN.Delegate", "urlForDeepLink for " + event.getUrl());
        WonderPushDelegate subDelegate = sSubDelegate.get();
        Log.d("WonderPushRN.Delegate", "subDelegate:" + subDelegate);
        if (subDelegate != null) {
            Log.d("WonderPushRN.Delegate", "Calling subDelegate");
            return subDelegate.urlForDeepLink(event);
        }

        // Check if background start is allowed
        if (!shouldAllowBackgroundStart()) {
            // Return original URL immediately without initializing
            Log.d("WonderPushRN.Delegate", "urlForDeepLink: returning original URL (background start disabled)");
            return event.getUrl();
        }

        Log.d("WonderPushRN.Delegate", "Trying to initialize");

        // Store the pending event and create a future for the result
        sPendingDeepLinkEvent = event;
        sPendingDeepLinkFuture = new CompletableFuture<>();

        // Track total time for 3 second timeout
        long startTime = System.currentTimeMillis();
        long maxWaitTime = 3000; // 3 seconds total timeout

        // Try to initialize React Native context and wait for it (with timeout)
        boolean couldInitializeReactNative = tryInitializeAndWaitForReactNativeContext(maxWaitTime);

        // Calculate remaining time for waiting for setSubDelegate
        long elapsedTime = System.currentTimeMillis() - startTime;
        long remainingTime = maxWaitTime - elapsedTime;

        if (!couldInitializeReactNative) {
            Log.d("WonderPushRN.Delegate", "Could not initialize React Native properly");
        } else if (remainingTime > 0) {
            // Wait for setSubDelegate to be called (with remaining timeout)
            Log.d("WonderPushRN.Delegate", "Waiting for setSubDelegate with " + remainingTime + "ms timeout");
            try {
                String result = sPendingDeepLinkFuture.get(remainingTime, TimeUnit.MILLISECONDS);
                Log.d("WonderPushRN.Delegate", "Got result from future: " + result);
                return result;
            } catch (Exception e) {
                Log.d("WonderPushRN.Delegate", "Timeout or error waiting for delegate: " + e.getMessage());
            }
        } else {
            Log.d("WonderPushRN.Delegate", "No time remaining to wait for setSubDelegate");
        }
        // Clear pending state
        sPendingDeepLinkFuture = null;
        sPendingDeepLinkEvent = null;

        // Either React Native didn't start in time, or delegate wasn't set
        Log.d("WonderPushRN.Delegate", "no luck, resolving manually");
        return event.getUrl();
    }

    @Override
    public synchronized void onNotificationReceived(JSONObject notification) {
        WonderPushDelegate subDelegate = sSubDelegate.get();
        if (subDelegate != null) {
            // Forward to the active sub delegate
            subDelegate.onNotificationReceived(notification);
        } else {
            // Check if background start is allowed
            if (!shouldAllowBackgroundStart()) {
                // Drop the notification - don't queue or initialize
                Log.d("WonderPushRN.Delegate", "onNotificationReceived: dropping notification (background start disabled)");
                return;
            }

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

            // Check if background start is allowed
            if (shouldAllowBackgroundStart()) {
                // Try to initialize React Native context in background
                tryInitializeReactNativeContext();
            } else {
                // Don't initialize - notification might open browser/other app
                // If app is started by user, existing code will flush pending events
                Log.d("WonderPushRN.Delegate", "onNotificationOpened: skipping RN initialization (background start disabled)");
            }
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
        Log.d("WonderPushRN.Delegate", "tryInitializeAndWaitForReactNativeContext()");
        try {
            if (!(this.context instanceof ReactApplication)) {
        Log.d("WonderPushRN.Delegate", "tryInitializeAndWaitForReactNativeContext() -> false (bad context)");
                return false;
            }

            ReactApplication reactApp = (ReactApplication) this.context;
            ReactInstanceManager reactInstanceManager = reactApp.getReactNativeHost().getReactInstanceManager();

            // If context already exists, return immediately
            ReactContext reactContext = reactInstanceManager.getCurrentReactContext();
            if (reactContext != null) {
        Log.d("WonderPushRN.Delegate", "tryInitializeAndWaitForReactNativeContext() -> true (react context already exists)");
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
        Log.d("WonderPushRN.Delegate", "tryInitializeAndWaitForReactNativeContext() -> true (react context created during the listener setup)");
                return true;
            }

            // Wait for the context to be ready with timeout
            boolean completed = latch.await(timeoutMs, java.util.concurrent.TimeUnit.MILLISECONDS);
        Log.d("WonderPushRN.Delegate", "tryInitializeAndWaitForReactNativeContext() -> "+completed+" (waiting done)");
            return completed && contextReady.get();

        } catch (Exception e) {
            android.util.Log.w("WonderPush", "Failed to initialize and wait for React context", e);
        Log.d("WonderPushRN.Delegate", "tryInitializeAndWaitForReactNativeContext() -> false (above exception)");
            return false;
        }
    }
}
