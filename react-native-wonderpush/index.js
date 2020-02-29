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
    setClientId(clientId, secret) {
        if (!this.isNativeModuleInitialized()) {
            console.log("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.setClientId(clientId, secret, (response) => {
            console.log(response);
        });
    }

    setLogging(enable){
        if (!this.isNativeModuleInitialized()) {
            console.log("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.setLogging(enable,(response) => {
            console.log(response);
        });
    }

    isInitialized(){
        if (!this.isNativeModuleInitialized()) {
            console.log("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.isInitialized((response) => {
            console.log(response);
        });
    }

    isReady(){
        if (!this.isNativeModuleInitialized()) {
            console.log("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.isReady((response) => {
            console.log(response);
        });
    }

    setupDelegateForApplication(){
        if (!this.isNativeModuleInitialized()) {
            console.log("WonderPushLib {Native module} not initialized.");
            return;
        }
        if(Platform.OS === 'ios'){
            WonderPushLib.setupDelegateForApplication((response) => {
                console.log(response);
            });
        }
    }

    setupDelegateForUserNotificationCenter(){
        if (!this.isNativeModuleInitialized()) {
            console.log("WonderPushLib {Native module} not initialized.");
            return;
        }
        if(Platform.OS === 'ios'){
            WonderPushLib.setupDelegateForUserNotificationCenter((response) => {
                console.log(response);
            });
        }
       
    }

    // WonderPush: Subscribing users methods
    subscribeToNotifications(){
        if (!this.isNativeModuleInitialized()) {
            console.log("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.subscribeToNotifications((response) => {
            console.log(response);
        });
    }

    unsubscribeFromNotifications(){
        if (!this.isNativeModuleInitialized()) {
            console.log("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.unsubscribeFromNotifications((response) => {
            console.log(response);
        });
    }

    isSubscribedToNotifications(){
        if (!this.isNativeModuleInitialized()) {
            console.log("WonderPushLib {Native module} not initialized.");
            return;
        }
        WonderPushLib.isSubscribedToNotifications((response) => {
            console.log(response);
        });
    }
}
const WonderPush = new WonderPushPlugIn();
export default WonderPush;