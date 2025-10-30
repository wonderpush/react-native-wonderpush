import {
  TurboModuleRegistry,
  type TurboModule,
  type CodegenTypes,
} from 'react-native';

export interface Spec extends TurboModule {
  // Event emitters
  readonly onNotificationReceived: CodegenTypes.EventEmitter<{
    notification: Object;
  }>;
  readonly onNotificationOpened: CodegenTypes.EventEmitter<{
    notification: Object;
    buttonIndex: number;
  }>;
  readonly onUrlForDeeplink: CodegenTypes.EventEmitter<{
    url: string;
    callbackId: string;
  }>;

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
  downloadAllData(): Promise<string | null>;

  // Event emission methods (no callbacks needed)
  flushDelegateEvents(): Promise<void>;

  // Deep linking
  getInitialURL(): Promise<string>;

  // Delegate callback for URL deep link handling
  urlForDeeplinkCallback(callbackId: string, url: string | null): void;

  // User Preferences - Notification Channels
  getDefaultChannelId(): Promise<string>;
  setDefaultChannelId(id: string): Promise<void>;
  getChannelGroup(groupId: string): Promise<Object | null>;
  getChannel(channelId: string): Promise<Object | null>;
  setChannelGroups(channelGroups: Array<Object>): Promise<void>;
  setChannels(channels: Array<Object>): Promise<void>;
  putChannelGroup(channelGroup: Object): Promise<void>;
  putChannel(channel: Object): Promise<void>;
  removeChannelGroup(groupId: string): Promise<void>;
  removeChannel(channelId: string): Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNWonderPush');
