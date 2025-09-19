import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  // Initialization
  setLogging(enable: boolean): Promise<void>;
  initialize(clientId: string, clientSecret: string): Promise<void>;
  initializeAndRememberCredentials(
    clientId: string,
    clientSecret: string
  ): Promise<void>;
  getRememberedClientId(): Promise<string>;
  isInitialized(): Promise<boolean>;

  // Subscribing users
  subscribeToNotifications(fallbackToSettings: boolean): Promise<void>;
  unsubscribeFromNotifications(): Promise<void>;
  isSubscribedToNotifications(): Promise<boolean>;

  // Segmentation
  trackEvent(type: string, attributes: Object): Promise<void>;

  // Tags
  addTag(tags: Array<string>): Promise<void>;
  removeTag(tags: Array<string>): Promise<void>;
  removeAllTags(): Promise<void>;
  hasTag(tag: string): Promise<boolean>;
  getTags(): Promise<Array<string>>;

  // Properties
  getPropertyValue(property: string): Promise<any>;
  getPropertyValues(property: string): Promise<Array<any>>;
  addProperty(str: string, property: Array<any>): Promise<void>;
  removeProperty(str: string, property: Array<any>): Promise<void>;
  setProperty(str: string, property: Array<any>): Promise<void>;
  unsetProperty(property: string): Promise<void>;
  putProperties(properties: Object): Promise<void>;
  getProperties(): Promise<Object>;

  // Localization
  getCountry(): Promise<string>;
  setCountry(country: string | null): Promise<void>;
  getCurrency(): Promise<string>;
  setCurrency(currency: string | null): Promise<void>;
  getLocale(): Promise<string>;
  setLocale(locale: string | null): Promise<void>;
  getTimeZone(): Promise<string>;
  setTimeZone(timeZone: string | null): Promise<void>;

  // User IDs
  getUserId(): Promise<string>;
  setUserId(userId: string): Promise<void>;

  // Installation info
  getDeviceId(): Promise<string>;
  getInstallationId(): Promise<string>;
  getPushToken(): Promise<string>;
  getAccessToken(): Promise<string>;

  // Privacy
  setRequiresUserConsent(isConsent: boolean): Promise<void>;
  getUserConsent(): Promise<boolean>;
  setUserConsent(isConsent: boolean): Promise<void>;
  disableGeolocation(): Promise<void>;
  enableGeolocation(): Promise<void>;
  setGeolocation(lat: number, lon: number): Promise<void>;
  clearEventsHistory(): Promise<void>;
  clearPreferences(): Promise<void>;
  clearAllData(): Promise<void>;
  downloadAllData(): Promise<Object>;

  // Callbacks
  setNotificationReceivedCallback(
    callback: (notification: string) => void
  ): void;
  setNotificationOpenedCallback(
    callback: (notification: string, buttonIndex: number) => void
  ): void;

  // Deep linking
  getInitialURL(): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('WonderPush');
