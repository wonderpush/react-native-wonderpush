package com.wonderpush.sdk.reactnative;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.wonderpush.sdk.WonderPush;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Iterator;
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


    private JSONObject toJsonObject(ReadableMap readableMap) throws JSONException {
        JSONObject object = new JSONObject();
        ReadableMapKeySetIterator iter = readableMap.keySetIterator();
        while(iter.hasNextKey()) {
            String key = iter.nextKey();
            ReadableType type = readableMap.getType(key);
            switch(type) {
                case Boolean:
                    object.put(key, readableMap.getBoolean(key));
                    break;
                case Number:
                    object.put(key, readableMap.getDouble(key));
                    break;
                case String:
                    object.put(key, readableMap.getString(key));
                    break;
                case Map:
                    object.put(key, toJsonObject(readableMap.getMap(key)));
                    break;
                case Array:
                    object.put(key, toJsonArray(readableMap.getArray(key)));
                    break;
                case Null:
                    object.put(key, JSONObject.NULL);
                    break;
                default:
                    break;
            }
        }
        return object;
    }


    private JSONArray toJsonArray(ReadableArray readableArray) throws JSONException {
        JSONArray array = new JSONArray();
        for (int idx = 0; idx < readableArray.size(); idx++) {
            ReadableType type = readableArray.getType(idx);
            switch(type) {
                case Boolean:
                    array.put(readableArray.getBoolean(idx));
                    break;
                case Number:
                    array.put(readableArray.getDouble(idx));
                    break;
                case String:
                    array.put(readableArray.getString(idx));
                    break;
                case Map:
                    array.put(toJsonObject(readableArray.getMap(idx)));
                    break;
                case Array:
                    array.put(toJsonArray(readableArray.getArray(idx)));
                    break;  
                case Null:
                    array.put(JSONObject.NULL);
                    break;
                default:
                    break;
            }
        }
        return array;
    }


    //Initialization
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

    // Subscribing users
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

    // Segmentation
    @ReactMethod
    public void trackEvent(String type, ReadableMap attributes, Promise promise) {
        try{
            JSONObject jObject = toJsonObject(attributes);
            WonderPush.trackEvent(type, jObject);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void addTag(ReadableArray tags, Promise promise) {
        try {
            WonderPush.addTag(String.valueOf(tags));
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void removeTag(ReadableArray tags, Promise promise) {
        try {
            WonderPush.removeTag(String.valueOf(tags));
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
    public void getCountry(Promise promise) {
        try {
            String country = WonderPush.getCountry();
            promise.resolve(country);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void setCountry(String country, Promise promise) {
        try {
            WonderPush.setCountry(country);
            promise.resolve("WonderPush <Android> country set successfully.");
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getCurrency(Promise promise) {
        try {
            String currency = WonderPush.getCurrency();
            promise.resolve(currency);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void setCurrency(String currency, Promise promise) {
        try {
            WonderPush.setCurrency(currency);
            promise.resolve("WonderPush <Android> currency set successfully.");
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getLocale(Promise promise) {
        try {
            String locale = WonderPush.getLocale();
            promise.resolve(locale);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void setLocale(String locale, Promise promise) {
        try {
            WonderPush.setLocale(locale);
            promise.resolve("WonderPush <Android> locale set successfully.");
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getTimeZone(Promise promise) {
        try {
            String timeZone = WonderPush.getTimeZone();
            promise.resolve(timeZone);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void setTimeZone(String timeZone, Promise promise) {
        try {
            WonderPush.setLocale(timeZone);
            promise.resolve("WonderPush <Android> timeZone set successfully.");
        } catch (Exception e) {
            promise.reject(e);
        }
    }
    
    // User IDs
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

    // Installation info
    @ReactMethod
    public void getInstallationId(Promise promise) {
        try {
            String installationId = WonderPush.getInstallationId();
            promise.resolve(installationId);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getPushToken(Promise promise) {
        try {
            String pushToken = WonderPush.getPushToken();
            promise.resolve(pushToken);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

     @ReactMethod
    public void getPushToken(Promise promise) {
        try {
            String pushToken = WonderPush.getPushToken();
            promise.resolve(pushToken);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    // Privacy
    @ReactMethod
    public void disableGeolocation(Promise promise) {
        try {
            WonderPush.disableGeolocation();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void enableGeolocation(Promise promise) {
        try {
            WonderPush.enableGeolocation();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void clearEventsHistory(Promise promise) {
        try {
            WonderPush.clearEventsHistory();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void clearPreferences(Promise promise) {
        try {
            WonderPush.clearPreferences();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void clearAllData(Promise promise) {
        try {
            WonderPush.clearAllData();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }
}
