import NativeWonderPush from './NativeWonderPush';

export default class WonderPush {
  // Initialization
  static async setLogging(enable: boolean): Promise<void> {
    return NativeWonderPush.setLogging(enable);
  }

  static async initialize(
    clientId: string,
    clientSecret: string
  ): Promise<void> {
    return NativeWonderPush.initialize(clientId, clientSecret);
  }

  static async initializeAndRememberCredentials(
    clientId: string,
    clientSecret: string
  ): Promise<void> {
    return NativeWonderPush.initializeAndRememberCredentials(
      clientId,
      clientSecret
    );
  }

  static async getRememberedClientId(): Promise<string> {
    return NativeWonderPush.getRememberedClientId();
  }

  static async isInitialized(): Promise<boolean> {
    return NativeWonderPush.isInitialized();
  }

  // Subscribing users
  static async subscribeToNotifications(
    fallbackToSettings: boolean = false
  ): Promise<void> {
    return NativeWonderPush.subscribeToNotifications(fallbackToSettings);
  }

  static async unsubscribeFromNotifications(): Promise<void> {
    return NativeWonderPush.unsubscribeFromNotifications();
  }

  static async isSubscribedToNotifications(): Promise<boolean> {
    return NativeWonderPush.isSubscribedToNotifications();
  }

  // Segmentation
  static async trackEvent(
    type: string,
    attributes: Record<string, any> = {}
  ): Promise<void> {
    return NativeWonderPush.trackEvent(type, attributes);
  }

  // Tags
  static async addTag(...tags: string[] | [string[]]): Promise<void> {
    let tagArray: string[];
    if (tags.length > 0 && Array.isArray(tags[0])) {
      tagArray = tags[0];
    } else {
      tagArray = tags as string[];
    }
    return NativeWonderPush.addTag(tagArray);
  }

  static async removeTag(...tags: string[] | [string[]]): Promise<void> {
    let tagArray: string[];
    if (tags.length > 0 && Array.isArray(tags[0])) {
      tagArray = tags[0];
    } else {
      tagArray = tags as string[];
    }
    return NativeWonderPush.removeTag(tagArray);
  }

  static async removeAllTags(): Promise<void> {
    return NativeWonderPush.removeAllTags();
  }

  static async hasTag(tag: string): Promise<boolean> {
    return NativeWonderPush.hasTag(tag);
  }

  static async getTags(): Promise<string[]> {
    return NativeWonderPush.getTags();
  }

  // Properties
  static async getPropertyValue(property: string): Promise<any> {
    return NativeWonderPush.getPropertyValue(property);
  }

  static async getPropertyValues(property: string): Promise<any[]> {
    return NativeWonderPush.getPropertyValues(property);
  }

  static async addProperty(
    property: string,
    values: any | any[]
  ): Promise<void> {
    const valuesArray = Array.isArray(values) ? values : [values];
    return NativeWonderPush.addProperty(property, valuesArray);
  }

  static async removeProperty(
    property: string,
    values: any | any[]
  ): Promise<void> {
    const valuesArray = Array.isArray(values) ? values : [values];
    return NativeWonderPush.removeProperty(property, valuesArray);
  }

  static async setProperty(
    property: string,
    values: any | any[]
  ): Promise<void> {
    const valuesArray = Array.isArray(values) ? values : [values];
    return NativeWonderPush.setProperty(property, valuesArray);
  }

  static async unsetProperty(property: string): Promise<void> {
    return NativeWonderPush.unsetProperty(property);
  }

  static async putProperties(properties: Record<string, any>): Promise<void> {
    return NativeWonderPush.putProperties(properties);
  }

  static async getProperties(): Promise<Record<string, any>> {
    return NativeWonderPush.getProperties();
  }

  // Localization
  static async getCountry(): Promise<string> {
    return NativeWonderPush.getCountry();
  }

  static async setCountry(country: string | null): Promise<void> {
    return NativeWonderPush.setCountry(country);
  }

  static async getCurrency(): Promise<string> {
    return NativeWonderPush.getCurrency();
  }

  static async setCurrency(currency: string | null): Promise<void> {
    return NativeWonderPush.setCurrency(currency);
  }

  static async getLocale(): Promise<string> {
    return NativeWonderPush.getLocale();
  }

  static async setLocale(locale: string | null): Promise<void> {
    return NativeWonderPush.setLocale(locale);
  }

  static async getTimeZone(): Promise<string> {
    return NativeWonderPush.getTimeZone();
  }

  static async setTimeZone(timeZone: string | null): Promise<void> {
    return NativeWonderPush.setTimeZone(timeZone);
  }

  // User IDs
  static async getUserId(): Promise<string> {
    return NativeWonderPush.getUserId();
  }

  static async setUserId(userId: string): Promise<void> {
    return NativeWonderPush.setUserId(userId);
  }

  // Installation info
  static async getDeviceId(): Promise<string> {
    return NativeWonderPush.getDeviceId();
  }

  static async getInstallationId(): Promise<string> {
    return NativeWonderPush.getInstallationId();
  }

  static async getPushToken(): Promise<string> {
    return NativeWonderPush.getPushToken();
  }

  static async getAccessToken(): Promise<string> {
    return NativeWonderPush.getAccessToken();
  }

  // Privacy
  static async setRequiresUserConsent(value: boolean): Promise<void> {
    return NativeWonderPush.setRequiresUserConsent(value);
  }

  static async getUserConsent(): Promise<boolean> {
    return NativeWonderPush.getUserConsent();
  }

  static async setUserConsent(value: boolean): Promise<void> {
    return NativeWonderPush.setUserConsent(value);
  }

  static async disableGeolocation(): Promise<void> {
    return NativeWonderPush.disableGeolocation();
  }

  static async enableGeolocation(): Promise<void> {
    return NativeWonderPush.enableGeolocation();
  }

  static async setGeolocation(lat: number, lon: number): Promise<void> {
    return NativeWonderPush.setGeolocation(lat, lon);
  }

  static async clearEventsHistory(): Promise<void> {
    return NativeWonderPush.clearEventsHistory();
  }

  static async clearPreferences(): Promise<void> {
    return NativeWonderPush.clearPreferences();
  }

  static async clearAllData(): Promise<void> {
    return NativeWonderPush.clearAllData();
  }

  static async downloadAllData(): Promise<Record<string, any>> {
    return NativeWonderPush.downloadAllData();
  }

  // Deep linking
  static async getInitialURL(): Promise<string> {
    return NativeWonderPush.getInitialURL();
  }

  // Delegate (callback handling)
  static setDelegate(delegate?: {
    onNotificationReceived?: (notification: any) => void;
    onNotificationOpened?: (notification: any, buttonIndex?: number) => void;
  }) {
    if (!delegate) {
      NativeWonderPush.setNotificationReceivedCallback(() => {});
      NativeWonderPush.setNotificationOpenedCallback(() => {});
      return;
    }

    if (delegate.onNotificationReceived) {
      NativeWonderPush.setNotificationReceivedCallback(
        (notificationJson: string) => {
          try {
            const notification = JSON.parse(notificationJson);
            delegate.onNotificationReceived!(notification);
          } catch (e) {
            console.error('Could not parse notification JSON', e);
          }
        }
      );
    }

    if (delegate.onNotificationOpened) {
      NativeWonderPush.setNotificationOpenedCallback(
        (notificationJson: string, buttonIndex: number) => {
          try {
            const notification = JSON.parse(notificationJson);
            delegate.onNotificationOpened!(notification, buttonIndex);
          } catch (e) {
            console.error('Could not parse notification JSON', e);
          }
        }
      );
    }
  }
}
