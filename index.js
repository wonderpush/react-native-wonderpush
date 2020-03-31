import { NativeModules, NativeEventEmitter } from 'react-native';

const { WonderPushLib } = NativeModules;

class WonderPushPlugIn {
    eventEmitterWonderPush = new NativeEventEmitter(WonderPushLib);

    async checkNativeModuleInitialized() {
        if(WonderPushLib === null) {
            throw new Error("WonderPush native module not initialized");
        }
    }
    
    //Initialization
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

    // Subscribing users
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

    // Segmentation
    async trackEvent(type, attributes) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.trackEvent(type, attributes);
    }

    async addTag(...tags) {
        this.checkNativeModuleInitialized();
        if(tags.length > 0 && Array.isArray(tags[0])){
            return WonderPushLib.addTag(tags[0]);
        }else{
            return WonderPushLib.addTag(tags);
        }
    }

    async removeTag(...tags) {
        this.checkNativeModuleInitialized();
        if(tags.length > 0 && Array.isArray(tags[0])){
            return WonderPushLib.removeTag(tags[0]);
        }else{
            return WonderPushLib.removeTag(tags);
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

    async getPropertyValue(property) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getPropertyValue(property);
    }

    async getPropertyValues(property) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getPropertyValues(property);
    }

    async addProperty(str, property) {
        this.checkNativeModuleInitialized();
        if(!Array.isArray(property)) {
            property = [property];
        }
        return WonderPushLib.addProperty(str, property);
    }

    async removeProperty(str, property) {
        this.checkNativeModuleInitialized();
        if(!Array.isArray(property)) {
            property = [property];
        }
        return WonderPushLib.removeProperty(str, property);
    }

    async setProperty(str, property) {
        this.checkNativeModuleInitialized();
        if(Platform.OS == 'android'){
            if(typeof(property) == 'object'){
                return WonderPushLib.setProperty(str, property);
            }else{
                return WonderPushLib.setProperty(str, Array.from(property));
            }
        }else{
            return WonderPushLib.setProperty(str, property);
        }
    }
    
    async unsetProperty(property) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.unsetProperty(property);
    }

    async putProperties(property) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.putProperties(property);
    }
    
    async getProperties() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getProperties();
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

    // User IDs
    async getUserId() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getUserId();
    }

    async setUserId(userId) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.setUserId(userId);
    }

    // Installation info
    async getInstallationId() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getInstallationId();
    }

    async getPushToken() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.getPushToken();
    }

    // Privacy

    async setRequiresUserConsent(isConsent){
        this.checkNativeModuleInitialized();
        return WonderPushLib.setRequiresUserConsent(isConsent);
    }

    async setUserConsent(isConsent){
        this.checkNativeModuleInitialized();
        return WonderPushLib.setUserConsent(isConsent);
    }

    async disableGeolocation() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.disableGeolocation();
    }

    async enableGeolocation() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.enableGeolocation();
    }

    async setGeolocation(lat, lon) {
        this.checkNativeModuleInitialized();
        return WonderPushLib.setGeolocation(lat, lon);
    }


    async clearEventsHistory() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.clearEventsHistory();
    }

    async clearPreferences() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.clearPreferences();
    }

    async clearAllData() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.clearAllData();
    }

    async downloadAllData() {
        this.checkNativeModuleInitialized();
        return WonderPushLib.downloadAllData();
    }

}
const WonderPush = new WonderPushPlugIn();
export default WonderPush;
