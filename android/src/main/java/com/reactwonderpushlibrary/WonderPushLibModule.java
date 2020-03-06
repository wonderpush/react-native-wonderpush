package com.reactwonderpushlibrary;
import android.content.Context;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.wonderpush.sdk.WonderPush;
import com.wonderpush.sdk.WonderPushInitializer;
import com.wonderpush.sdk.WonderPushService;

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

    // Sample methods
    @ReactMethod
    public void sampleMethod(String stringArgument, int numberArgument, Callback callback) {
        // TODO: Implement some actually useful functionality
        callback.invoke("Received numberArgument: " + numberArgument + " stringArgument: " + stringArgument);
    }

    // WonderPush: Initialization methods
    @ReactMethod
    public void setClientId(String clientId, String clientSecret, Callback callback) {
        WonderPush.initialize(this.reactContext,clientId,clientSecret);
        callback.invoke("WonderPush <Android> initialized successfully.");
    }

    @ReactMethod
    public void setLogging(boolean enable, Callback callback){
        WonderPush.setLogging(enable);
        if(enable){
            callback.invoke("WonderPush <Android> logging status enabled successfully.");
        }else{
            callback.invoke("WonderPush <Android> logging status disabled successfully.");
        }
    }

    @ReactMethod
    public void isReady(Callback callback) {
        boolean status = WonderPush.isReady();
        callback.invoke(status);
    }

     @ReactMethod
    public void isInitialized(Callback callback) {
         boolean status = WonderPush.isReady();
         callback.invoke(status);
    }

    // WonderPush: Subscribing users methods
    @ReactMethod
    public void subscribeToNotifications(Callback callback) {
        WonderPush.subscribeToNotifications();
        callback.invoke("WonderPush: <Android> subscribed to notification successfully.");
    }

     @ReactMethod
    public void unsubscribeFromNotifications(Callback callback) {
        WonderPush.unsubscribeFromNotifications();
        callback.invoke("WonderPush: <Android> unsubscribed to notification successfully.");
    }

    @ReactMethod
    public void isSubscribedToNotifications(Callback callback) {
        boolean status = WonderPush.isSubscribedToNotifications();
        callback.invoke(status);
    }
}
