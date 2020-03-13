package com.reactwonderpushlibrary;
import android.content.Context;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.wonderpush.sdk.WonderPush;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class WonderPushLibModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public WonderPushLibModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        WonderPush.setIntegrator("ReactNative");
    }

    @Override
    public String getName() {
        return "WonderPushLib";
    }


    // WonderPush: Initialization methods

  // WonderPush: Initialization methods
    @ReactMethod
    public void setClientId(String clientId, String clientSecret, Promise promise) {
        try {
            WonderPush.initialize(this.reactContext,clientId,clientSecret);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void setLogging(boolean enable, Promise promise){
        try {
            WonderPush.setLogging(enable);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void isReady(Promise promise) {
        try {
            boolean status =  WonderPush.isReady();
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void isInitialized(Promise promise) {
        try {
            boolean status =  WonderPush.isReady();
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    // WonderPush: Subscribing users methods
    @ReactMethod
    public void subscribeToNotifications(Promise promise) {
        try {
            WonderPush.subscribeToNotifications();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void unsubscribeFromNotifications(Promise promise) {
        try {
            WonderPush.unsubscribeFromNotifications();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void isSubscribedToNotifications(Promise promise) {
        try {
            boolean status =  WonderPush.isSubscribedToNotifications();
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject(e);
        }
    }


    @ReactMethod
    public void trackEvent(String type, JSONObject attributes, Promise promise) {
        try {
            WonderPush.trackEvent(type, attributes);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void addTag(String tag, Promise promise) {
        try {
            WonderPush.addTag(tag);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void removeTag(String tag, Promise promise) {
        try {
            WonderPush.removeTag(tag);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void removeAllTags(Promise promise) {
        try {
            WonderPush.removeAllTags();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void hasTag(String tag, Promise promise) {
        try {
            boolean status =  WonderPush.hasTag(tag);
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getTags(Promise promise) {
        try {
            Set<String> tags = WonderPush.getTags();
            promise.resolve(tags);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getUserId(Promise promise) {
        try {
            String userId = WonderPush.getUserId();
            promise.resolve(userId);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void setUserId(String userId, Promise promise) {
        try {
            WonderPush.setUserId(userId);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }
}
