package com.reactwonderpushlibrary;
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

    public void setClientId(ReactApplicationContext reactContext, String clientId, String clientSecret){
        WonderPush.initialize(reactContext,clientId,clientSecret);
    }
}
