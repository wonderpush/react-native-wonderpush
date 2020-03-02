import { NativeModules } from 'react-native';

const { WonderPushLib } = NativeModules;

//export default WonderPushLib;

class WonderPushPlugIn {

   // Sample Methods
    displayMsg(message) {
        WonderPushLib.show(message);
    }

    show() {
        if (!this.isNativeModuleInitialized()) {
            console.log("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.show("test toast");
    }

    isNativeModuleInitialized(){
        return WonderPushLib != null;
    }

    // WonderPush: Initialization methods
    setClientId(clientId, secret, callback) {
        if (!this.isNativeModuleInitialized()) {
            callback("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.setClientId(clientId, secret, (response) => {
            callback(response);
        });
    }

    setLogging(enable, callback){
        if (!this.isNativeModuleInitialized()) {
            callback("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.setLogging(enable,(response) => {
            callback(response);
        });
    }

    isInitialized(callback){
        if (!this.isNativeModuleInitialized()) {
            callback("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.isInitialized((response) => {
            callback(response);
        });
    }

    isReady(callback){
        if (!this.isNativeModuleInitialized()) {
            callback("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.isReady((response) => {
            callback(response);
        });
    }

    setupDelegateForApplication(callback){
        if (!this.isNativeModuleInitialized()) {
            callback("WonderPushLib {Native module} not initialized.");
            return;
        }
        if(Platform.OS === 'ios'){
            WonderPushLib.setupDelegateForApplication((response) => {
                callback(response);
            });
        }
    }

    setupDelegateForUserNotificationCenter(callback){
        if (!this.isNativeModuleInitialized()) {
            callback("WonderPushLib {Native module} not initialized.");
            return;
        }
        if(Platform.OS === 'ios'){
            WonderPushLib.setupDelegateForUserNotificationCenter((response) => {
                callback(response);
            });
        }
       
    }

    // WonderPush: Subscribing users methods
    subscribeToNotifications(callback){
        if (!this.isNativeModuleInitialized()) {
            callback("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.subscribeToNotifications((response) => {
            callback(response);
        });
    }

    unsubscribeFromNotifications(callback){
        if (!this.isNativeModuleInitialized()) {
            callback("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.unsubscribeFromNotifications((response) => {
            callback(response);
        });
    }

    isSubscribedToNotifications(callback){
        if (!this.isNativeModuleInitialized()) {
            callback("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.isSubscribedToNotifications((response) => {
            callback(response);
        });
    }
}
const WonderPush = new WonderPushPlugIn();
export default WonderPush;