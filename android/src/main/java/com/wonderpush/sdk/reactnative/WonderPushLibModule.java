package com.wonderpush.sdk.reactnative;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import android.util.Log;
import android.location.Location;


import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.wonderpush.sdk.WonderPush;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Array;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.Map;


public class WonderPushLibModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

   public WonderPushLibModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        WonderPush.setIntegrator("ReactNative");

        LocalBroadcastManager.getInstance(reactContext).registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (!WonderPush.INTENT_NOTIFICATION_WILL_OPEN_EXTRA_NOTIFICATION_TYPE_DATA.equals(
                        intent.getStringExtra(WonderPush.INTENT_NOTIFICATION_WILL_OPEN_EXTRA_NOTIFICATION_TYPE))) {

                    Intent pushNotif = intent.getParcelableExtra(WonderPush.INTENT_NOTIFICATION_WILL_OPEN_EXTRA_RECEIVED_PUSH_NOTIFICATION);
                    Log.d("WonderPush", pushNotif.toString());
                    reactContext
                            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit(WonderPush.INTENT_NOTIFICATION_WILL_OPEN, pushNotif);
                }
            }
        }, new IntentFilter(WonderPush.INTENT_NOTIFICATION_WILL_OPEN));
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

    public static WritableMap jsonToReact(JSONObject jsonObject) throws JSONException {
        WritableMap writableMap = Arguments.createMap();
        Iterator iterator = jsonObject.keys();
        while(iterator.hasNext()) {
            String key = (String) iterator.next();
            Object value = jsonObject.get(key);
            if (value instanceof Float || value instanceof Double) {
                writableMap.putDouble(key, jsonObject.getDouble(key));
            } else if (value instanceof Number) {
                writableMap.putInt(key, jsonObject.getInt(key));
            } else if (value instanceof String) {
                writableMap.putString(key, jsonObject.getString(key));
            } else if (value instanceof JSONObject) {
                writableMap.putMap(key, jsonToReact(jsonObject.getJSONObject(key)));
            } else if (value instanceof JSONArray){
                writableMap.putArray(key, jsonToReact(jsonObject.getJSONArray(key)));
            } else if (value == JSONObject.NULL){
                writableMap.putNull(key);
            }
        }

        return writableMap;
    }

    public static WritableArray jsonToReact(JSONArray jsonArray) throws JSONException {
        WritableArray writableArray = Arguments.createArray();
        for(int i=0; i < jsonArray.length(); i++) {
            Object value = jsonArray.get(i);
            if (value instanceof Float || value instanceof Double) {
                writableArray.pushDouble(jsonArray.getDouble(i));
            } else if (value instanceof Number) {
                writableArray.pushInt(jsonArray.getInt(i));
            } else if (value instanceof String) {
                writableArray.pushString(jsonArray.getString(i));
            } else if (value instanceof JSONObject) {
                writableArray.pushMap(jsonToReact(jsonArray.getJSONObject(i)));
            } else if (value instanceof JSONArray){
                writableArray.pushArray(jsonToReact(jsonArray.getJSONArray(i)));
            } else if (value == JSONObject.NULL){
                writableArray.pushNull();
            }
        }
        return writableArray;
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
            String[] array = new String[tags.size()];
            for (int i = 0; i < tags.size(); i++) {
                switch (tags.getType(i)) {
                    case Null:
                        break;
                    case Boolean:
                        array[i] = String.valueOf(tags.getBoolean(i));
                        break;
                    case Number:
                        array[i] = String.valueOf(tags.getDouble(i));
                        break;
                    case String:
                        array[i] = tags.getString(i);
                        break;
                    case Map:
                        array[i] = String.valueOf(tags.getMap(i));
                        break;
                    case Array:
                        array[i] = String.valueOf(tags.getArray(i));
                        break;
                }
            }
            WonderPush.addTag(array);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void removeTag(ReadableArray tags, Promise promise) {
        try {
            String[] array = new String[tags.size()];
            for (int i = 0; i < tags.size(); i++) {
                switch (tags.getType(i)) {
                    case Null:
                        break;
                    case Boolean:
                        array[i] = String.valueOf(tags.getBoolean(i));
                        break;
                    case Number:
                        array[i] = String.valueOf(tags.getDouble(i));
                        break;
                    case String:
                        array[i] = tags.getString(i);
                        break;
                    case Map:
                        array[i] = String.valueOf(tags.getMap(i));
                        break;
                    case Array:
                        array[i] = String.valueOf(tags.getArray(i));
                        break;
                }
            }
            WonderPush.removeTag(array);
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
            Object[] tArray = tags.toArray();

            WritableArray writableArray = Arguments.createArray();
            for(int i=0; i < tArray.length; i++) {
                Object value = tArray[i];
                if (value instanceof Float || value instanceof Double) {
                    writableArray.pushDouble((Double) value);
                } else if (value instanceof Number) {
                    writableArray.pushInt((Integer) value);
                } else if (value instanceof String) {
                    writableArray.pushString((String) value);
                } else if (value instanceof JSONObject) {
                    writableArray.pushMap((ReadableMap) value);
                } else if (value instanceof JSONArray){
                    writableArray.pushArray((ReadableArray) value);
                } else if (value == JSONObject.NULL){
                    writableArray.pushNull();
                }
            }
            promise.resolve(writableArray);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getPropertyValue(String property, Promise promise) {
        try {
            Object value = WonderPush.getPropertyValue(property);
            if (value instanceof Boolean) {
                promise.resolve((Boolean) value);
            } else if (value instanceof Integer) {
                promise.resolve((Integer) value);
            } else if (value instanceof String) {
                promise.resolve((String) value);
            } else if (value instanceof Map) {
                promise.resolve((ReadableMap) value);
            } else if (value instanceof Array) {
                promise.resolve((ReadableArray) value);
            } else {
                promise.resolve(null);
            }
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getPropertyValues(String property, Promise promise) {
        try{
            List<Object> values = WonderPush.getPropertyValues(property);
            WritableArray writableArray = Arguments.createArray();
            for(Object obj : values){
                if(obj instanceof Boolean) {
                    writableArray.pushBoolean((Boolean) obj);
                }else if(obj instanceof Integer){
                    writableArray.pushInt((Integer) obj);
                }else if(obj instanceof String){
                    writableArray.pushString((String) obj);
                }else if(obj instanceof Map) {
                    writableArray.pushMap((WritableMap) obj);
                }else if(obj instanceof Array) {
                    writableArray.pushArray((WritableArray) obj);
                }else if(obj == null) {
                    writableArray.pushNull();
                }
            }
            promise.resolve(writableArray);
        } catch (Exception e) {
            promise.reject(e);
        }
    }


    @ReactMethod
    public void addProperty(String str, ReadableArray property, Promise promise) {
        try {
            WonderPush.addProperty(str, toJsonArray(property));
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void removeProperty(String str, ReadableArray property, Promise promise) {
        try {
            WonderPush.removeProperty(str, toJsonArray(property));
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }


    @ReactMethod
    public void setProperty(String str, ReadableArray property, Promise promise) {
        try {
            WonderPush.setProperty(str, toJsonArray(property));
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void unsetProperty(String property, Promise promise) {
        try {
            WonderPush.unsetProperty(property);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void putProperties(ReadableMap properties, Promise promise) {
        try{
            JSONObject jObject = toJsonObject(properties);
            WonderPush.putProperties(jObject);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getProperties(Promise promise) {
        try {
            JSONObject properties = WonderPush.getProperties();
            WritableMap map = jsonToReact(properties);
            promise.resolve(map);
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
            promise.resolve(null);
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
            promise.resolve(null);
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
            promise.resolve(null);
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
            promise.resolve(null);
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

    // Privacy
    @ReactMethod
    public void setRequiresUserConsent(Boolean isConsent, Promise promise) {
        try {
            WonderPush.setRequiresUserConsent(isConsent);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void setUserConsent(Boolean isConsent, Promise promise) {
        try {
            WonderPush.setUserConsent(isConsent);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }


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
    public void setGeolocation(double lat, double lon, Promise promise) {
        try {
            Location location = new Location("WonderPush");
            location.setLatitude(lat);
            location.setLongitude(lon);
            WonderPush.setGeolocation(location);
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

    @ReactMethod
    public void downloadAllData(Promise promise) {
        try {
            WonderPush.downloadAllData();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }
}
