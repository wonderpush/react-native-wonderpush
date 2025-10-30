import NativeWonderPush from './NativeWonderPush';
import type { WonderPushChannel, WonderPushChannelGroup } from './types';

// Global delegate storage
let currentDelegate: {
  urlForDeeplink?: (
    url: string,
    callback: (url: string | null) => void
  ) => void;
  onNotificationReceived?: (notification: any) => void;
  onNotificationOpened?: (notification: any, buttonIndex?: number) => void;
} | null = null;

// Set up event listeners once during static initialization
NativeWonderPush.onNotificationReceived((data: { notification: any }) => {
  if (currentDelegate?.onNotificationReceived) {
    currentDelegate.onNotificationReceived(data.notification);
  }
});

NativeWonderPush.onNotificationOpened(
  (data: { notification: any; buttonIndex: number }) => {
    if (currentDelegate?.onNotificationOpened) {
      currentDelegate.onNotificationOpened(data.notification, data.buttonIndex);
    }
  }
);

NativeWonderPush.onUrlForDeeplink(
  (data: { url: string; callbackId: string }) => {
    if (currentDelegate?.urlForDeeplink) {
      try {
        currentDelegate.urlForDeeplink(
          data.url,
          (modifiedUrl: string | null) => {
            NativeWonderPush.urlForDeeplinkCallback(
              data.callbackId,
              modifiedUrl
            );
          }
        );
      } catch (e) {
        console.error('[RNWonderPush] Error in urlForDeeplink delegate', e);
        // On error, return the original URL
        NativeWonderPush.urlForDeeplinkCallback(data.callbackId, data.url);
      }
    } else {
      // No delegate set, return the original URL
      NativeWonderPush.urlForDeeplinkCallback(data.callbackId, data.url);
    }
  }
);

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

  static async downloadAllData(): Promise<string | null> {
    return NativeWonderPush.downloadAllData();
  }

  // Deep linking
  static async getInitialURL(): Promise<string> {
    return NativeWonderPush.getInitialURL();
  }

  // Delegate (event-based handling)
  static setDelegate(
    delegate: {
      urlForDeeplink?: (
        url: string,
        callback: (url: string | null) => void
      ) => void;
      onNotificationReceived?: (notification: any) => void;
      onNotificationOpened?: (notification: any, buttonIndex?: number) => void;
    } | null
  ) {
    // Simply store the current delegate - event listeners are already set up
    currentDelegate = delegate;
    // Flush any queued notifications from native side
    NativeWonderPush.flushDelegateEvents();
  }
}

/**
 * WonderPushUserPreferences provides access to notification channel preferences.
 * On Android, this controls notification channels and channel groups.
 * On iOS, these methods are no-ops (except getters which return default values).
 */
export class WonderPushUserPreferences {
  /**
   * Get the default channel ID.
   * Returns "default" on iOS, the actual default channel ID on Android.
   */
  static async getDefaultChannelId(): Promise<string> {
    return NativeWonderPush.getDefaultChannelId();
  }

  /**
   * Set the default channel ID.
   * No-op on iOS, sets the default channel on Android.
   */
  static async setDefaultChannelId(id: string): Promise<void> {
    return NativeWonderPush.setDefaultChannelId(id);
  }

  /**
   * Get a channel group by ID.
   * Returns null on iOS, the actual channel group on Android if it exists.
   */
  static async getChannelGroup(
    groupId: string
  ): Promise<WonderPushChannelGroup | null> {
    const result = await NativeWonderPush.getChannelGroup(groupId);
    return result as WonderPushChannelGroup | null;
  }

  /**
   * Get a channel by ID.
   * Returns null on iOS, the actual channel on Android if it exists.
   */
  static async getChannel(
    channelId: string
  ): Promise<WonderPushChannel | null> {
    const result = await NativeWonderPush.getChannel(channelId);
    return result as WonderPushChannel | null;
  }

  /**
   * Set all channel groups, replacing existing ones.
   * No-op on iOS, replaces all channel groups on Android.
   */
  static async setChannelGroups(
    channelGroups: WonderPushChannelGroup[]
  ): Promise<void> {
    // Validate that all channel groups have an id
    channelGroups.forEach((group, index) => {
      if (!group.id || typeof group.id !== 'string') {
        throw new Error(
          `Channel group at index ${index} must have a valid 'id' string property`
        );
      }
    });
    return NativeWonderPush.setChannelGroups(channelGroups as any[]);
  }

  /**
   * Set all channels, replacing existing ones.
   * No-op on iOS, replaces all channels on Android.
   */
  static async setChannels(channels: WonderPushChannel[]): Promise<void> {
    // Validate that all channels have an id
    channels.forEach((channel, index) => {
      if (!channel.id || typeof channel.id !== 'string') {
        throw new Error(
          `Channel at index ${index} must have a valid 'id' string property`
        );
      }
    });
    return NativeWonderPush.setChannels(channels as any[]);
  }

  /**
   * Add or update a channel group.
   * No-op on iOS, adds or updates the channel group on Android.
   */
  static async putChannelGroup(
    channelGroup: WonderPushChannelGroup
  ): Promise<void> {
    // Validate that the channel group has an id
    if (!channelGroup.id || typeof channelGroup.id !== 'string') {
      throw new Error("Channel group must have a valid 'id' string property");
    }
    return NativeWonderPush.putChannelGroup(channelGroup as any);
  }

  /**
   * Add or update a channel.
   * No-op on iOS, adds or updates the channel on Android.
   */
  static async putChannel(channel: WonderPushChannel): Promise<void> {
    // Validate that the channel has an id
    if (!channel.id || typeof channel.id !== 'string') {
      throw new Error("Channel must have a valid 'id' string property");
    }
    return NativeWonderPush.putChannel(channel as any);
  }

  /**
   * Remove a channel group by ID.
   * No-op on iOS, removes the channel group on Android.
   */
  static async removeChannelGroup(groupId: string): Promise<void> {
    return NativeWonderPush.removeChannelGroup(groupId);
  }

  /**
   * Remove a channel by ID.
   * No-op on iOS, removes the channel on Android.
   */
  static async removeChannel(channelId: string): Promise<void> {
    return NativeWonderPush.removeChannel(channelId);
  }
}

// Named exports for both classes
export { WonderPush };
// Export types
export type { WonderPushChannel, WonderPushChannelGroup } from './types';
