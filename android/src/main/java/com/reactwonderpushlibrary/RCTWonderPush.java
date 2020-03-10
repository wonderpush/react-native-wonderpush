package com.reactwonderpushlibrary;
import android.content.Context;

import com.wonderpush.sdk.WonderPush;
import com.facebook.react.bridge.ReactApplicationContext;

public class RCTWonderPush {

    private static RCTWonderPush sharedInstance = null;

    private RCTWonderPush() {
    }

    public static RCTWonderPush getInstance() {
        if (sharedInstance == null)
            sharedInstance = new RCTWonderPush();
        return sharedInstance;
    }

    public void setClientId(Context context, String clientId, String clientSecret){
        WonderPush.initialize(context,clientId,clientSecret);
    }

    public void setLogging(boolean enable){
        WonderPush.setLogging(enable);
    }

    public boolean isReady(){
        return WonderPush.isReady();
    }

    public boolean isInitialized(){
        return WonderPush.isReady();
    }

    public void subscribeToNotifications(){
        WonderPush.subscribeToNotifications();
    }

    public void unsubscribeFromNotifications(){
        WonderPush.unsubscribeFromNotifications();
    }

    public boolean isSubscribedToNotifications(){
       return WonderPush.isSubscribedToNotifications();
    }

}
