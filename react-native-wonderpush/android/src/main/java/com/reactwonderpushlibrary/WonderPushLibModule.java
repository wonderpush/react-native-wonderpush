package com.reactwonderpushlibrary;
import android.content.Context;
import android.widget.Toast;
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

   @ReactMethod
    public void show(String text) {
        Context context = getReactApplicationContext();
        Toast.makeText(context,text, Toast.LENGTH_LONG).show();
    }

    // WonderPush: Initialization methods
    @ReactMethod
    public void setClientId(String clientId, String clientSecret, Callback callback) {
        WonderPush.initialize(this.reactContext,clientId,clientSecret);
        callback.invoke("WonderPush <Android> initialized successfully.");
    }

    // WonderPush: Subscribing users methods
    @ReactMethod
    public void subscribeToNotifications(Callback callback) {
        if(!WonderPush.isSubscribedToNotifications()){
            WonderPush.subscribeToNotifications();
            callback.invoke("WonderPush: <Android> subscribed to notification successfully.");
        }else{
            callback.invoke("WonderPush: <Android> already subscribed to notifications.");
        }
    }

     @ReactMethod
    public void unsubscribeFromNotifications(Callback callback) {
         if(WonderPush.isSubscribedToNotifications()){
             WonderPush.unsubscribeFromNotifications();
             callback.invoke("WonderPush: <Android> unsubscribed to notification successfully.");
         }else{
             callback.invoke("WonderPush: <Android> already unsubscribed to notifications.");
         }
    }

}
