
package com.reactlibrary;

import com.wonderpush.sdk.WonderPush;
import java.lang.Object;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;

import org.json.JSONObject;

public class RNWonderpushModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNWonderpushModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNWonderpush";
  }

  @ReactMethod
  public void getAccessToken(Callback result) {
    result.invoke(null, WonderPush.getAccessToken());
  }

  @ReactMethod
  public void getDelegate(Callback result) {
    result.invoke(null, WonderPush.getDelegate());
  }

  @ReactMethod
  public void getDeviceId(Callback result) {
    result.invoke(null, WonderPush.getDeviceId());
  }

  @ReactMethod
  public void getInstallationCustomProperties(Callback result){
    result.invoke(null, WonderPush.getInstallationCustomProperties());
  }

  @ReactMethod
  public void getInstallationId(Callback result){
    result.invoke(null, WonderPush.getInstallationId());
  }

  @ReactMethod
  public void getNotificationEnabled(Callback result){
    result.invoke(null, WonderPush.getNotificationEnabled());
  }

  @ReactMethod
  public void getPushToken(Callback result){
    result.invoke(null, WonderPush.getPushToken());
  }

  @ReactMethod
  public void getUserId(Callback result){
    result.invoke(null, WonderPush.getUserId());
  }

  @ReactMethod
  public void init() {
    WonderPush.initialize(
            reactContext,
            "7524c8a317c1794c0b23895dce3a3314d6a24105",
            "b43a2d0fbdb54d24332b4d70736954eab5d24d29012b18ef6d214ff0f51e7901"
    );
  }

  @ReactMethod
  public void isReady(Callback result) {
    result.invoke(null, WonderPush.isReady());
  }

/*  @ReactMethod
  public void onBroadcastReceived(){
    WonderPush.onBroadcastReceived();
  }*/

/*  @ReactMethod
  public void putInstallationCustomProperties(String properties){
    JSONObject newProps = new JSONObject(properties);
    WonderPush.putInstallationCustomProperties(newProps);
  }*/

/*  @ReactMethod
  public void setDelegate(){
    WonderPush.setDelegate();
  }*/

/*  @ReactMethod
  public void setLogging(){
    WonderPush.setLogging();
  }*/

/*  @ReactMethod
  public void setNotificationEnabled(){
    WonderPush.setNotificationEnabled();
  }*/

/*  @ReactMethod
  public void setUserId(){
    WonderPush.setUserId();
  }*/

 /* @ReactMethod
  public void showPotentialNotification(){
    WonderPush.showPotentialNotification();
  }*/

/*  @ReactMethod
  public void trackEvent(){
    WonderPush.trackEvent();
  }*/
}