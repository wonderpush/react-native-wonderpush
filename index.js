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
            console.log("WonderPush {Native module} not initialized.");
            return;
        }
        WonderPushLib.show("test toast");
    }

    isNativeModuleInitialized(){
        return WonderPushLib != null;
    }

    // WonderPush: Initialization methods

    setClientId(clientId, secret) {
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPush {Native module} not initialized.");
            }
            try{
                const response = await WonderPushLib.setClientId(clientId, secret);
                resolve(response);
            } catch (error) {
                reject(error);
            }
        }); 
    }

    setLogging(enable){
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPush {Native module} not initialized.");
            }
            try {
                const response = await WonderPushLib.setLogging(enable);
                resolve(response);   
            } catch (error) {
                reject(error);
            }
        }); 
    }

    isReady(){
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPush {Native module} not initialized.");
            }

            try{
                const response = await WonderPushLib.isReady();
                resolve(response);
            } catch (error) {
                reject(error);
            }
        }); 
    }

    isInitialized(){
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPush {Native module} not initialized.");
            }
            try{
                const response = await WonderPushLib.isInitialized();
                resolve(response);
            } catch (error) {
                reject(error);
            }
        }); 
    }

    setupDelegateForApplication(){
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPush {Native module} not initialized.");
            }
            if(Platform.OS === 'ios'){
                try{
                    const response = await WonderPushLib.setupDelegateForApplication();
                    resolve(response);
                } catch (error) {
                    reject(error);
                }
            }
        }); 
    }

    setupDelegateForUserNotificationCenter(){
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPush {Native module} not initialized.");
            }
            if(Platform.OS === 'ios'){
                try{
                    const response = await WonderPushLib.setupDelegateForUserNotificationCenter();
                    resolve(response);
                } catch (error) {
                    reject(error);
                }
            }
        }); 
    }

    // WonderPush: Subscribing users methods
    subscribeToNotifications(){
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPush {Native module} not initialized.");
            }
            try{
                const response = await WonderPushLib.subscribeToNotifications();
                resolve(response);
            } catch (error) {
                reject(error);
            }
        });
    }

    unsubscribeFromNotifications(){
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPush {Native module} not initialized.");
            }
            try{
                const response = await WonderPushLib.unsubscribeFromNotifications();
                resolve(response);
            } catch (error) {
                reject(error);
            }
        });
    }
    
    isSubscribedToNotifications(){
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPush {Native module} not initialized.");
            }
            try{
                const response = await WonderPushLib.isSubscribedToNotifications();
                resolve(response);
            } catch (error) {
                reject(error);
            }
        });
    }

    trackEvent(type, attributes) {
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPushLib {Native module} not initialized.");
            }

            try{
                const response = await WonderPushLib.trackEvent(type, attributes);
                resolve(response);
            } catch (error) {
                reject(error);
            }
        });
    }

    addTag(tag) {
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPushLib {Native module} not initialized.");
            }

            try{
                const response = await WonderPushLib.addTag(tag);
                resolve(response);
            } catch (error) {
                reject(error);
            }
        });
    }

    removeTag(tag) {
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPushLib {Native module} not initialized.");
            }

            try{
                const response = await WonderPushLib.removeTag(tag);
                resolve(response);
            } catch (error) {
                reject(error);
            }
        });
    }

    removeAllTags() {
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPushLib {Native module} not initialized.");
            }

            try{
                const response = await WonderPushLib.removeAllTags();
                resolve(response);
            } catch (error) {
                reject(error);
            }
        });
    }

    hasTag(tag) {
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPushLib {Native module} not initialized.");
            }

            try{
                const response = await WonderPushLib.hasTag(tag);
                resolve(response);
            } catch (error) {
                reject(error);
            }
        });
    }

    getTags() {
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPushLib {Native module} not initialized.");
            }
            try{
                const response = await WonderPushLib.getTags();
                resolve(response);
            } catch (error) {
                reject(error);
            }
        });
    }

    getUserId() {
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPushLib {Native module} not initialized.");
            }
            try{
                const response = await WonderPushLib.getUserId();
                resolve(response);
            } catch (error) {
                reject(error);
            }
        });
    }

    setUserId(userId) {
        self = this;
        return new Promise(async function(resolve, reject) {
            if (!self.isNativeModuleInitialized()) {
                reject("WonderPushLib {Native module} not initialized.");
            }
            try{
                const response = await WonderPushLib.setUserId(userId);
                resolve(response);
            } catch (error) {
                reject(error);
            }
        });
    }

}
const WonderPush = new WonderPushPlugIn();
export default WonderPush;