package com.wonderpush.sdk.reactnative;

import android.content.Context;
import android.util.Log;
import com.wonderpush.sdk.WonderPush;
import com.wonderpush.sdk.WonderPushDelegate;
import com.wonderpush.sdk.WonderPushSettings;
import com.wonderpush.sdk.DeepLinkEvent;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactHost;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.interfaces.TaskInterface;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

public class Delegate implements WonderPushDelegate {

    private static final String TAG = WonderPushModule.NAME + ".Delegate";
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
        // Get a local copy of the variables to work on (in case sPendingDeepLinkFuture is nullified in between)
        final DeepLinkEvent pendingDeepLinkEvent = sPendingDeepLinkEvent;
        final CompletableFuture<String> pendingDeepLinkFuture = sPendingDeepLinkFuture;
        if (pendingDeepLinkEvent != null && pendingDeepLinkFuture != null) {
            final WonderPushDelegate subDelegate = sSubDelegate.get();
            if (subDelegate != null) {
                // Spawn a background thread to avoid blocking the bridge thread
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            String result = subDelegate.urlForDeepLink(pendingDeepLinkEvent);
                            pendingDeepLinkFuture.complete(result);
                        } catch (Exception e) {
                            Log.e(TAG, "Error processing pending DeepLinkEvent in background thread", e);
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

    /**
     * Get the ReactHost from the application context.
     * @return ReactHost if available, null otherwise
     */
    private ReactHost getReactHost() {
        if (!(this.context instanceof ReactApplication)) {
            return null;
        }
        ReactApplication reactApp = (ReactApplication) this.context;
        return reactApp.getReactHost();
    }

    /**
     * Get the current React context.
     * @return ReactContext if available, null otherwise
     */
    private ReactContext getCurrentReactContext() {
        ReactHost reactHost = getReactHost();
        return reactHost != null ? reactHost.getCurrentReactContext() : null;
    }

    @Override
    public String urlForDeepLink(DeepLinkEvent event) {
        WonderPushDelegate subDelegate = sSubDelegate.get();
        if (subDelegate != null) {
            return subDelegate.urlForDeepLink(event);
        }

        // Check if background start is allowed
        if (!shouldAllowBackgroundStart()) {
            // Return original URL immediately without initializing
            return event.getUrl();
        }

        if (WonderPush.getLogging()) Log.d(TAG, "Initializing React Native context in the background for urlForDeeplink");

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
            Log.w(TAG, "Could not initialize React Native context properly for urlForDeeplink");
        } else if (remainingTime > 0) {
            // Wait for setSubDelegate to be called (with remaining timeout)
            Log.d(TAG, "Waiting for setSubDelegate with " + remainingTime + "ms timeout");
            try {
                String result = sPendingDeepLinkFuture.get(remainingTime, TimeUnit.MILLISECONDS);
                if (WonderPush.getLogging()) Log.d(TAG, "Got result from future for urlForDeeplink: " + result);
                return result;
            } catch (Exception e) {
                Log.w(TAG, "Timeout or error waiting for delegate to process urlForDeeplink", e);
            }
        } else {
            Log.w(TAG, "Took too long to initialize React Native context for urlForDeeplink");
        }
        // Clear pending state
        sPendingDeepLinkFuture = null;
        sPendingDeepLinkEvent = null;

        // Either React Native didn't start in time, or delegate wasn't set
        Log.w(TAG, "Could not get urlForDeeplink handled by delegate in time, resolving manually");
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
                if (WonderPush.getLogging()) Log.d(TAG, "Background start disabled, dropping onNotificationReceived");
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
                if (WonderPush.getLogging()) Log.d(TAG, "Background start disabled, dropping onNotificationOpened");
            }
        }
    }

    private void tryInitializeReactNativeContext() {
        try {
            ReactHost reactHost = getReactHost();
            if (reactHost != null) {
                // ReactHost automatically starts when needed, just trigger it by getting context
                reactHost.getCurrentReactContext();
            }
        } catch (Exception e) {
            // Silently handle any errors during context initialization
            Log.w(TAG, "Failed to initialize React Native context in background", e);
        }
    }

    /**
     * Try to initialize React Native context and wait for it to be ready.
     * @param timeoutMs Maximum time to wait in milliseconds
     * @return true if context is ready, false if timeout or error
     */
    private boolean tryInitializeAndWaitForReactNativeContext(long timeoutMs) {
        try {
            // If context already exists, return immediately
            ReactContext reactContext = getCurrentReactContext();
            if (reactContext != null) {
                return true;
            }

            ReactHost reactHost = getReactHost();
            if (reactHost == null) {
                Log.w(TAG, "tryInitializeAndWaitForReactNativeContext(): ReactHost is null");
                return false;
            }

            // Start the ReactHost and get the initialization task
            TaskInterface<Void> startTask = reactHost.start();

            // Wait for the task to complete with timeout
            boolean completed = startTask.waitForCompletion(timeoutMs, TimeUnit.MILLISECONDS);

            if (!completed) {
                Log.w(TAG, "tryInitializeAndWaitForReactNativeContext(): Timeout waiting for ReactHost initialization");
                return false;
            }

            // Check if the task was cancelled
            if (startTask.isCancelled()) {
                Log.w(TAG, "tryInitializeAndWaitForReactNativeContext(): ReactHost initialization was cancelled");
                return false;
            }

            // Check if the task failed
            if (startTask.isFaulted()) {
                Exception error = startTask.getError();
                Log.e(TAG, "tryInitializeAndWaitForReactNativeContext(): ReactHost initialization failed", error);
                return false;
            }

            // Verify that the context is actually available after successful initialization
            ReactContext finalContext = reactHost.getCurrentReactContext();
            if (finalContext == null) {
                Log.w(TAG, "tryInitializeAndWaitForReactNativeContext(): ReactHost initialized but context is still null");
                return false;
            }

            return true;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            Log.w(TAG, "tryInitializeAndWaitForReactNativeContext(): Interrupted while waiting for ReactHost", e);
            return false;
        } catch (Exception e) {
            Log.w(TAG, "tryInitializeAndWaitForReactNativeContext(): Failed to initialize and wait for React Native context", e);
            return false;
        }
    }
}
