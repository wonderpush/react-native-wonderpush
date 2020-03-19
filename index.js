import { NativeModules } from 'react-native';

const { WonderPushLib } = NativeModules;

//export default WonderPushLib;

class WonderPushPlugIn {

    async checkNativeModuleInitialized() {
        if(WonderPushLib === null) {
            throw new Error("WonderPush: Native module not initialized.");
        }
    }
    

    // WonderPush: Initialization methods

    async setLogging(enable) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.setLogging(enable);
    }

    async isReady() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.isReady();
    }

    async isInitialized() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.isInitialized();
    }

    // WonderPush: Subscribing users methods

    async subscribeToNotifications() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.subscribeToNotifications();
    }

    async unsubscribeFromNotifications() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.unsubscribeFromNotifications();
    }
    
    async isSubscribedToNotifications() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.isSubscribedToNotifications();
    }

    async trackEvent(type, attributes) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.trackEvent(type, attributes);
    }

    async addTag(...tags) {
        this.checkNativeModuleInitialized();
        if(tags.length > 0){
            if(typeof(tags[0]) == 'object'){
                return WonderPushLib.addTag(tags);
            }else if(typeof(tags[0]) == 'string'){
                return WonderPushLib.addTag(Array.from(tags));
            }else{
                return Promise.reject("Wonderpush: addTag() require Strings or String Array as parameter.");
            }
        }else{
            return Promise.reject("Wonderpush: addTag() needs atleast one parameter.");
        }
    }

    async removeTag(...tags) {
        this.checkNativeModuleInitialized();
        if(tags.length > 0){
            if(typeof(tags[0]) == 'object'){
                return WonderPushLib.removeTag(tags);
            }else if(typeof(tags[0]) == 'string'){
                return WonderPushLib.removeTag(Array.from(tags));
            }else{
                return Promise.reject("WonderPush: removeTag() require Strings or String Array as parameter.");
            }
        }else{
            return Promise.reject("WonderPush: removeTag() needs atleast one parameter.");
        }
    }

    async removeAllTags() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.removeAllTags();
    }

    async hasTag(tag) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.hasTag(tag);
    }

    async getTags() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getTags();
    }

    async getCountry() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getCountry();
    }

    async setCountry(country) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.setCountry(country);
    }

    async getCurrency() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getCurrency();
    }

    async setCurrency(currency) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.setCurrency(currency);
    }

    async getLocale() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getLocale();
    }

    async setLocale(locale) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.setLocale(locale);
    }

    async getTimeZone() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getTimeZone();
    }

    async setTimeZone(timeZone) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.setTimeZone(timeZone);
    }

    async getUserId() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getUserId();
    }

    async setUserId(userId) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.setUserId(userId);
    }

}
const WonderPush = new WonderPushPlugIn();
export default WonderPush;
