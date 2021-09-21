package com.wonderpush.sdk.reactnative;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.location.Location;
import android.os.Bundle;
import android.util.Log;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.facebook.react.bridge.*;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.wonderpush.sdk.WonderPush;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Array;
import java.util.*;

public class WonderPushLibModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public WonderPushLibModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        WonderPush.setIntegrator("react-native-wonderpush-2.0.8");

        LocalBroadcastManager.getInstance(reactContext).registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (!WonderPush.INTENT_NOTIFICATION_WILL_OPEN_EXTRA_NOTIFICATION_TYPE_DATA.equals(
                        intent.getStringExtra(WonderPush.INTENT_NOTIFICATION_WILL_OPEN_EXTRA_NOTIFICATION_TYPE))) {

                    Intent pushNotif = intent.getParcelableExtra(WonderPush.INTENT_NOTIFICATION_WILL_OPEN_EXTRA_RECEIVED_PUSH_NOTIFICATION);
                    Bundle bundle = pushNotif != null ? pushNotif.getExtras() : null;
                    if (null != bundle) {
                        WritableMap notificationData = new WritableNativeMap();
                        Set<String> keys = bundle.keySet();
                        for (String key : keys) {
                            if (key.equals("_wp")) {
                                String jsonString = bundle.getString("_wp");
                                try {
                                    JSONObject jsonObject = new JSONObject(jsonString);
                                    notificationData.putMap("_wp", jsonToReact(jsonObject));
                                } catch (JSONException e) {
                                }
                                continue;
                            }
                            notificationData.putString(key, bundle.getString(key));
                        }
                        Log.d("WonderPush", notificationData.toString());
                        reactContext
                                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                                .emit(WonderPush.INTENT_NOTIFICATION_WILL_OPEN, notificationData);
                    }
                }
            }
        }, new IntentFilter(WonderPush.INTENT_NOTIFICATION_WILL_OPEN));
    }

    @Override
    public String getName() {
        return "RNWonderPush";
    }

    private JSONObject toJsonObject(ReadableMap readableMap) throws JSONException {
        JSONObject object = new JSONObject();
        ReadableMapKeySetIterator iter = readableMap.keySetIterator();
        while (iter.hasNextKey()) {
            String key = iter.nextKey();
            ReadableType type = readableMap.getType(key);
            switch (type) {
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
            switch (type) {
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
        while (iterator.hasNext()) {
            String key = (String) iterator.next();
            Object value = jsonObject.get(key);
            if (value instanceof Boolean) {
                writableMap.putBoolean(key, ((Boolean) value).booleanValue());
            } else if (value instanceof Number) {
                writableMap.putDouble(key, ((Number) value).doubleValue());
            } else if (value instanceof String) {
                writableMap.putString(key, (String) value);
            } else if (value instanceof JSONObject) {
                writableMap.putMap(key, jsonToReact((JSONObject) value));
            } else if (value instanceof JSONArray) {
                writableMap.putArray(key, jsonToReact((JSONArray) value));
            } else if (value == JSONObject.NULL) {
                writableMap.putNull(key);
            }
        }

        return writableMap;
    }

    public static WritableArray jsonToReact(JSONArray jsonArray) throws JSONException {
        WritableArray writableArray = Arguments.createArray();
        for (int i = 0; i < jsonArray.length(); i++) {
            Object value = jsonArray.get(i);
            if (value instanceof Boolean) {
                writableArray.pushBoolean(((Boolean) value).booleanValue());
            } else if (value instanceof Number) {
                writableArray.pushDouble(((Number) value).doubleValue());
            } else if (value instanceof String) {
                writableArray.pushString((String) value);
            } else if (value instanceof JSONObject) {
                writableArray.pushMap(jsonToReact((JSONObject) value));
            } else if (value instanceof JSONArray) {
                writableArray.pushArray(jsonToReact((JSONArray) value));
            } else if (value == JSONObject.NULL) {
                writableArray.pushNull();
            }
        }
        return writableArray;
    }

    //Initialization
    @ReactMethod
    public void setClientId(String clientId, String clientSecret, Promise promise) {
        try {
            WonderPush.initialize(this.reactContext, clientId, clientSecret);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void setLogging(boolean enable, Promise promise) {
        try {
            WonderPush.setLogging(enable);
            promise.resolve(null);
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
            boolean status = WonderPush.isSubscribedToNotifications();
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    // Segmentation
    @ReactMethod
    public void trackEvent(String type, ReadableMap attributes, Promise promise) {
        try {
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
                    case String:
                        array[i] = tags.getString(i);
                        break;
                    default:
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
                    case String:
                        array[i] = tags.getString(i);
                        break;
                    default:
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
            boolean status = WonderPush.hasTag(tag);
            promise.resolve(status);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getTags(Promise promise) {
        try {
            Set<String> tags = WonderPush.getTags();
            WritableArray writableArray = Arguments.createArray();
            for (String tag : tags) {
                writableArray.pushString(tag);
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
            } else if (value instanceof Number) {
                promise.resolve(((Number) value).doubleValue());
            } else if (value instanceof String) {
                promise.resolve((String) value);
            } else if (value instanceof Map) {
                promise.resolve((ReadableMap) value);
            } else if (value instanceof Array) {
                promise.resolve((ReadableArray) value);
            } else if (value instanceof JSONObject) {
                promise.resolve(jsonToReact((JSONObject) value));
            } else if (value instanceof JSONArray) {
                promise.resolve(jsonToReact((JSONArray) value));
            } else if (value == null || value == JSONObject.NULL) {
                promise.resolve(null);
            } else {
                Log.d("WonderPush", "Unexpected type " + value.getClass().getCanonicalName());
                promise.resolve(null);
            }
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getPropertyValues(String property, Promise promise) {
        try {
            List<Object> values = WonderPush.getPropertyValues(property);
            WritableArray writableArray = Arguments.createArray();
            for (Object obj : values) {
                if (obj instanceof Boolean) {
                    writableArray.pushBoolean((Boolean) obj);
                } else if (obj instanceof Number) {
                    writableArray.pushDouble(((Number) obj).doubleValue());
                } else if (obj instanceof String) {
                    writableArray.pushString((String) obj);
                } else if (obj instanceof Map) {
                    writableArray.pushMap((WritableMap) obj);
                } else if (obj instanceof Array) {
                    writableArray.pushArray((WritableArray) obj);
                } else if (obj instanceof JSONObject) {
                    writableArray.pushMap(jsonToReact((JSONObject) obj));
                } else if (obj instanceof JSONArray) {
                    writableArray.pushArray(jsonToReact((JSONArray) obj));
                } else if (obj == null || obj == JSONObject.NULL) {
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
        try {
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
            WonderPush.setTimeZone(timeZone);
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
