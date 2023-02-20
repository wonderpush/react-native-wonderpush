import { NativeEventEmitter, NativeModules } from 'react-native';

const {RNWonderPush} = NativeModules;

if (RNWonderPush === null) {
    throw new Error("WonderPush native module not initialized");
}

export default class WonderPush {

    //Initialization
    static async setLogging(enable) {
        return RNWonderPush.setLogging(enable);
    }

    // Subscribing users
    static async subscribeToNotifications(fallbackToSettings) {
        return RNWonderPush.subscribeToNotifications(!!fallbackToSettings);
    }

    static async unsubscribeFromNotifications() {
        return RNWonderPush.unsubscribeFromNotifications();
    }

    static async isSubscribedToNotifications() {
        return RNWonderPush.isSubscribedToNotifications();
    }

    // Segmentation
    static async trackEvent(type, attributes = {}) {
        return RNWonderPush.trackEvent(type, attributes);
    }

    static async addTag(...tags) {
        if (tags.length > 0 && Array.isArray(tags[0])) {
            return RNWonderPush.addTag(tags[0]);
        } else {
            return RNWonderPush.addTag(tags);
        }
    }

    static async removeTag(...tags) {
        if (tags.length > 0 && Array.isArray(tags[0])) {
            return RNWonderPush.removeTag(tags[0]);
        } else {
            return RNWonderPush.removeTag(tags);
        }
    }

    static async removeAllTags() {
        return RNWonderPush.removeAllTags();
    }

    static async hasTag(tag) {
        return RNWonderPush.hasTag(tag);
    }

    static async getPropertyValue(property) {
        return RNWonderPush.getPropertyValue(property);
    }

    static async getPropertyValues(property) {
        return RNWonderPush.getPropertyValues(property);
    }

    static async addProperty(str, property) {
        if (!Array.isArray(property)) {
            property = [property];
        }
        return RNWonderPush.addProperty(str, property);
    }

    static async removeProperty(str, property) {
        if (!Array.isArray(property)) {
            property = [property];
        }
        return RNWonderPush.removeProperty(str, property);
    }

    static async setProperty(str, property) {
        if (!Array.isArray(property)) {
            property = [property];
        }
        return RNWonderPush.setProperty(str, property);
    }

    static async unsetProperty(property) {
        return RNWonderPush.unsetProperty(property);
    }

    static async putProperties(property) {
        return RNWonderPush.putProperties(property);
    }

    static async getProperties() {
        return RNWonderPush.getProperties();
    }

    static async getTags() {
        return RNWonderPush.getTags();
    }

    static async getCountry() {
        return RNWonderPush.getCountry();
    }

    static async setCountry(country) {
        return RNWonderPush.setCountry(country);
    }

    static async getCurrency() {
        return RNWonderPush.getCurrency();
    }

    static async setCurrency(currency) {
        return RNWonderPush.setCurrency(currency);
    }

    static async getLocale() {
        return RNWonderPush.getLocale();
    }

    static async setLocale(locale) {
        return RNWonderPush.setLocale(locale);
    }

    static async getTimeZone() {
        return RNWonderPush.getTimeZone();
    }

    static async setTimeZone(timeZone) {
        return RNWonderPush.setTimeZone(timeZone);
    }

    // User IDs
    static async getUserId() {
        return RNWonderPush.getUserId();
    }

    static async setUserId(userId) {
        return RNWonderPush.setUserId(userId);
    }

    // Installation info
    static async getDeviceId() {
        return RNWonderPush.getDeviceId();
    }

    static async getInstallationId() {
        return RNWonderPush.getInstallationId();
    }

    static async getPushToken() {
        return RNWonderPush.getPushToken();
    }

    static async getAccessToken() {
        return RNWonderPush.getAccessToken();
    }

    // Privacy

    static async setRequiresUserConsent(isConsent) {
        return RNWonderPush.setRequiresUserConsent(isConsent);
    }

    static async getUserConsent() {
        return RNWonderPush.getUserConsent();
    }

    static async setUserConsent(isConsent) {
        return RNWonderPush.setUserConsent(isConsent);
    }

    static async disableGeolocation() {
        return RNWonderPush.disableGeolocation();
    }

    static async enableGeolocation() {
        return RNWonderPush.enableGeolocation();
    }

    static async setGeolocation(lat, lon) {
        return RNWonderPush.setGeolocation(lat, lon);
    }

    static async clearEventsHistory() {
        return RNWonderPush.clearEventsHistory();
    }

    static async clearPreferences() {
        return RNWonderPush.clearPreferences();
    }

    static async clearAllData() {
        return RNWonderPush.clearAllData();
    }

    static async downloadAllData() {
        return RNWonderPush.downloadAllData();
    }

    /**
     * If the application was launched by clicking a notification
     * whose targetUrl is a deeplink, this method will return that targetUrl, null otherwise
     * @returns {Promise<string>}
     */
    static async getInitialURL() {
        return RNWonderPush.getInitialURL();
    }

}
