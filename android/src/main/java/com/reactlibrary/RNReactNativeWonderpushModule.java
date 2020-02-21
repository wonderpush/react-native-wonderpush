
package com.reactlibrary;

import com.wonderpush.sdk.WonderPush;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;

public class RNReactNativeWonderpushModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNReactNativeWonderpushModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNWonderpush";
  }

 @ReactMethod
  public void init(String clientId, String clinetSecret){
    WonderPush.initialize(this.reactContext,clientId,clinetSecret);
  }

  @ReactMethod
  public void subscribeToNotifications(){
    WonderPush.subscribeToNotifications();
  }

  @ReactMethod
  public void unsubscribeFromNotifications(){
    WonderPush.unsubscribeFromNotifications();
  }

//  public void getAccessToken(Callback result) {
//    result.invoke(null, WonderPush.getAccessToken());
//  }
//
//  @ReactMethod
//  public void getDelegate(Callback result) {
//    result.invoke(null, WonderPush.getDelegate());
//  }
//
//  @ReactMethod
//  public void getDeviceId(Callback result) {
//    result.invoke(null, WonderPush.getDeviceId());
//  }
//
//  @ReactMethod
//  public void getInstallationCustomProperties(Callback result){
//  }
//
//  @ReactMethod
//  public void getInstallationId(Callback result){
//  }
//
//  @ReactMethod
//  public void getNotificationEnabled(Callback result){
//  }
//
//  @ReactMethod
//  public void getPushToken(Callback result){
//    result.invoke(null, WonderPush.getPushToken());
//  }
//
//  @ReactMethod
//  public void getUserId(Callback result){
//    result.invoke(null, WonderPush.getUserId());
//  }
//
//  @ReactMethod
//  public void init(String clientId, String clientSecret) {
//    WonderPush.initialize(
//            reactContext,
//            clientId,
//            clientSecret
//    );
//  }
//
//  @ReactMethod
//  public void isReady(Callback result) {
//    result.invoke(null, WonderPush.isReady());
//  }
//
///*  @ReactMethod
//  public void onBroadcastReceived(){
//    WonderPush.onBroadcastReceived();
//  }*/
//
///*  @ReactMethod
//  public void putInstallationCustomProperties(String properties){
//    JSONObject newProps = new JSONObject(properties);
//    WonderPush.putInstallationCustomProperties(newProps);
//  }*/
//
///*  @ReactMethod
//  public void setDelegate(){
//    WonderPush.setDelegate();
//  }*/
//
//  @ReactMethod
//  public void setLogging(Boolean shouldLog){
//    WonderPush.setLogging(shouldLog);
//  }
//
//  @ReactMethod
//  public void setNotificationEnabled(Boolean isEnabled){
//  }
//
//  @ReactMethod
//  public void setUserId(String userId){
//    WonderPush.setUserId(userId);
//  }
//
///*  @ReactMethod
//  public void showPotentialNotification(){
//    WonderPush.showPotentialNotification();
//  }*/
//
//  @ReactMethod
//  public void trackEvent(String type){
//    WonderPush.trackEvent(type);
//  }
}