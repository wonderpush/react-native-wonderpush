import { NativeModules } from 'react-native';

const { WonderPushLib } = NativeModules;

//export default WonderPushLib;

class WonderPushPlugIn {

    isNativeModuleInitialized(){
        return WonderPushLib != null;
    }

    // WonderPush: Initialization methods

    setLogging(enable) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.setLogging(enable);
    }

    isReady() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.isReady();
    }

    isInitialized() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.isInitialized();
    }

    // WonderPush: Subscribing users methods

    subscribeToNotifications() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.subscribeToNotifications();
    }

    unsubscribeFromNotifications() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.unsubscribeFromNotifications();
    }
    
    isSubscribedToNotifications() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.isSubscribedToNotifications();
    }

    trackEvent(type, attributes) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.trackEvent(type, attributes);
    }

    addTag(tag) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.addTag(tag);
    }

    addTags(tags) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        if(Platform.OS !== 'ios'){
            return Promise.reject("WonderPush: method not supported.");
        }
        return WonderPushLib.addTags(tags);
    }

    removeTag(tag) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.removeTag(tag);
    }

    removeTags(tags) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        if(Platform.OS !== 'ios'){
            return Promise.reject("WonderPush: method not supported.");
        }
        return WonderPushLib.removeTags(tags);
    }

    removeAllTags() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.removeAllTags();
    }

    hasTag(tag) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.hasTag(tag);
    }

    getTags() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.getTags();
    }

    getCountry() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.getCountry();
    }

    setCountry(country) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.setCountry(country);
    }

    getCurrency() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.getCurrency();
    }

    setCurrency(currency) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.setCurrency(currency);
    }

    getLocale() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.getLocale();
    }

    setLocale(locale) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.setLocale(locale);
    }

    getTimeZone() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.getTimeZone();
    }

    setTimeZone(timeZone) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.setTimeZone(timeZone);
    }

    getUserId() {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.getUserId();
    }

    setUserId(userId) {
        if (!this.isNativeModuleInitialized()) {
            return Promise.reject("WonderPush {Native module} not initialized.");
        }
        return WonderPushLib.setUserId(userId);
    }

}
const WonderPush = new WonderPushPlugIn();
export default WonderPush;
