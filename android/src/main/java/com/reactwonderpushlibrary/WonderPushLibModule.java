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
            promise.resolve("WonderPush: initialized successfully.");
        } catch (Exception e) {
            promise.reject("0","WonderPush: Error occured in calling setClientId:secretId.",  e);
        }
    }

    @ReactMethod
    public void setLogging(boolean enable, Promise promise){
        try {
            WonderPush.setLogging(enable);
            if(enable){
                promise.resolve("WonderPush: logging enabled successfully.");
            }else{
                promise.resolve("WonderPush: logging disabled successfully.");
            }
        } catch (Exception e) {
            promise.reject("0","WonderPush: Error occured in calling setLogging.", e);
        }
    }

    @ReactMethod
    public void isReady(Promise promise) {
        try {
            boolean status = WonderPush.isReady();
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject("0","WonderPush: Error occured in calling isReady.", e);
        }
    }

    @ReactMethod
    public void isInitialized(Promise promise) {
        try {
            boolean status = WonderPush.isReady();
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject("0","WonderPush: Error occured in calling isInitialized." , e);
        }
    }

    // WonderPush: Subscribing users methods
    @ReactMethod
    public void subscribeToNotifications(Promise promise) {
        try {
            WonderPush.subscribeToNotifications();
            promise.resolve("WonderPush: subscribed to notification successfully.");
        } catch (Exception e) {
            promise.reject("0","WonderPush: Error occured in calling subscribeToNotifications.", e);
        }
    }

    @ReactMethod
    public void unsubscribeFromNotifications(Promise promise) {
        try {
            WonderPush.unsubscribeFromNotifications();
            promise.resolve("WonderPush: unsubscribed to notification successfully.");
        } catch (Exception e) {
            promise.reject("0","WonderPush: Error occured in calling unsubscribeFromNotifications.",e);
        }
    }

    @ReactMethod
    public void isSubscribedToNotifications(Promise promise) {
        try {
            boolean status = WonderPush.isSubscribedToNotifications();
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject("0","WonderPush: Error occured in calling isSubscribedToNotifications.", e);
        }
    }
}
