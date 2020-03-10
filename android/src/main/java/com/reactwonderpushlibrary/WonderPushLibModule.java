package com.reactwonderpushlibrary;
import android.content.Context;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.wonderpush.sdk.WonderPush;


public class WonderPushLibModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public WonderPushLibModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
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
            RCTWonderPush.getInstance().setClientId(this.reactContext,clientId,clientSecret);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void setLogging(boolean enable, Promise promise){
        try {
            RCTWonderPush.getInstance().setLogging(enable);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void isReady(Promise promise) {
        try {
            boolean status =  RCTWonderPush.getInstance().isReady();
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void isInitialized(Promise promise) {
        try {
            boolean status =  RCTWonderPush.getInstance().isReady();
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    // WonderPush: Subscribing users methods
    @ReactMethod
    public void subscribeToNotifications(Promise promise) {
        try {
            RCTWonderPush.getInstance().subscribeToNotifications();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void unsubscribeFromNotifications(Promise promise) {
        try {
            RCTWonderPush.getInstance().unsubscribeFromNotifications();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void isSubscribedToNotifications(Promise promise) {
        try {
            boolean status =  RCTWonderPush.getInstance().isSubscribedToNotifications();
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject(e);
        }
    }
}
