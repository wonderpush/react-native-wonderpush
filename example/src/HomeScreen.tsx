import {
  Button,
  Text,
  View,
  StyleSheet,
  Switch,
  ScrollView,
  TextInput,
  Alert,
  PermissionsAndroid,
  Platform,
  Linking,
} from 'react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import WonderPush from 'react-native-wonderpush';
import { useState, useCallback, useEffect } from 'react';

console.log('WonderPush from react-native-wonderpush:', WonderPush);

type RootStackParamList = {
  Home: undefined;
  Child: undefined;
};

type Props = NativeStackScreenProps<RootStackParamList, 'Home'>;

const wonderpushDelegate = {
  urlForDeeplink: (url: string, callback: (url: string | null) => void) => {
    console.log('🔗 [urlForDeeplink] Intercepted URL:', url);

    // For demonstration, let's modify certain URLs
    let modifiedUrl: string | null = url;
    let action = 'using original URL';

    // Example 1: Redirect wonderpush.com URLs to google.com
    if (url.includes('wonderpush.com')) {
      modifiedUrl = 'https://www.google.com/search?q=wonderpush';
      action = 'redirecting to Google';
    }
    // Example 2: Block certain URLs (return null)
    else if (url.includes('blocked-domain.com')) {
      modifiedUrl = null; // Block the URL
      action = 'BLOCKED (returning null)';
    }
    // Example 3: Modify query parameters
    else if (url.includes('example.com')) {
      modifiedUrl = url + (url.includes('?') ? '&' : '?') + 'intercepted=true';
      action = 'added ?intercepted=true parameter';
    }

    console.log(`🔗 [urlForDeeplink] Action: ${action}`);
    console.log(
      `🔗 [urlForDeeplink] Result: ${modifiedUrl || 'null (blocked)'}`
    );

    // IMPORTANT: No UI operations here! This may be called in background on Android
    // Call the callback with the modified URL
    callback(modifiedUrl);
  },
  onNotificationReceived: (notif: any) => {
    console.log('onNotificationReceived:', notif);
    Alert.alert('Notification received', JSON.stringify(notif, null, 2));
  },
  onNotificationOpened: (notif: any, button: number | undefined) => {
    console.log('onNotificationOpened with button', button, ':', notif);
    Alert.alert(
      'Notification clicked',
      'Button: ' + button + '\n' + JSON.stringify(notif, null, 2)
    );
  },
};
WonderPush.setDelegate(wonderpushDelegate);

export default function HomeScreen({ navigation }: Props) {
  // State management
  const [isSubscribedToNotifications, setIsSubscribedToNotifications] =
    useState<boolean | undefined>(undefined);
  const [isLoggingEnabled, setIsLoggingEnabled] = useState<boolean>(false);
  const [isInitialized, setIsInitialized] = useState<boolean | undefined>(
    undefined
  );
  const [hasTagFoo, setHasTagFoo] = useState<boolean | undefined>(undefined);
  const [hasTagBar, setHasTagBar] = useState<boolean | undefined>(undefined);
  const [userId, setUserId] = useState<string>('');
  const [deviceId, setDeviceId] = useState<string>('');
  const [installationId, setInstallationId] = useState<string>('');
  const [pushToken, setPushToken] = useState<string>('');
  const [accessToken, setAccessToken] = useState<string>('');
  const [country, setCountry] = useState<string>('');
  const [currency, setCurrency] = useState<string>('');
  const [locale, setLocale] = useState<string>('');
  const [timeZone, setTimeZone] = useState<string>('');
  const [userConsent, setUserConsent] = useState<boolean | undefined>(
    undefined
  );
  const [tags, setTags] = useState<string[]>([]);
  const [properties, setProperties] = useState<any>({});
  const [inputUserId, setInputUserId] = useState<string>('');
  const [inputCountry, setInputCountry] = useState<string>('');
  const [inputCurrency, setInputCurrency] = useState<string>('');
  const [inputLocale, setInputLocale] = useState<string>('');
  const [inputTimeZone, setInputTimeZone] = useState<string>('');
  const [inputLat, setInputLat] = useState<string>('');
  const [inputLon, setInputLon] = useState<string>('');

  // Refresh functions
  const refreshIsInitialized = useCallback(async () => {
    try {
      setIsInitialized(await WonderPush.isInitialized());
    } catch (error) {
      console.error('Error checking initialization:', error);
    }
  }, []);

  const refreshHasTagFoo = useCallback(async () => {
    try {
      setHasTagFoo(await WonderPush.hasTag('foo'));
    } catch (error) {
      console.error('Error checking tag foo:', error);
    }
  }, []);

  const refreshHasTagBar = useCallback(async () => {
    try {
      setHasTagBar(await WonderPush.hasTag('bar'));
    } catch (error) {
      console.error('Error checking tag bar:', error);
    }
  }, []);

  const refreshUserInfo = useCallback(async () => {
    try {
      const [
        userIdResult,
        deviceIdResult,
        installationIdResult,
        pushTokenResult,
        accessTokenResult,
      ] = await Promise.all([
        WonderPush.getUserId(),
        WonderPush.getDeviceId(),
        WonderPush.getInstallationId(),
        WonderPush.getPushToken(),
        WonderPush.getAccessToken(),
      ]);
      setUserId(userIdResult || '');
      setDeviceId(deviceIdResult || '');
      setInstallationId(installationIdResult || '');
      setPushToken(pushTokenResult || '');
      setAccessToken(accessTokenResult || '');
    } catch (error) {
      console.error('Error getting user info:', error);
    }
  }, []);

  const refreshLocalization = useCallback(async () => {
    try {
      const [countryResult, currencyResult, localeResult, timeZoneResult] =
        await Promise.all([
          WonderPush.getCountry(),
          WonderPush.getCurrency(),
          WonderPush.getLocale(),
          WonderPush.getTimeZone(),
        ]);
      setCountry(countryResult || '');
      setCurrency(currencyResult || '');
      setLocale(localeResult || '');
      setTimeZone(timeZoneResult || '');
    } catch (error) {
      console.error('Error getting localization:', error);
    }
  }, []);

  const refreshUserConsent = useCallback(async () => {
    try {
      setUserConsent(await WonderPush.getUserConsent());
    } catch (error) {
      console.error('Error getting user consent:', error);
    }
  }, []);

  const refreshTags = useCallback(async () => {
    try {
      setTags(await WonderPush.getTags());
    } catch (error) {
      console.error('Error getting tags:', error);
    }
  }, []);

  const refreshProperties = useCallback(async () => {
    try {
      setProperties(await WonderPush.getProperties());
    } catch (error) {
      console.error('Error getting properties:', error);
    }
  }, []);

  // Request geolocation permission
  const requestGeolocationPermission = useCallback(async () => {
    if (Platform.OS === 'android') {
      try {
        const granted = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
          {
            title: 'Location Permission',
            message:
              'This app needs location permission to provide location-based features.',
            buttonNeutral: 'Ask Me Later',
            buttonNegative: 'Cancel',
            buttonPositive: 'OK',
          }
        );
        if (granted === PermissionsAndroid.RESULTS.GRANTED) {
          console.log('Location permission granted');
        } else {
          console.log('Location permission denied');
        }
      } catch (error) {
        console.error('Error requesting location permission:', error);
      }
    }
  }, []);

  // Initialize all data
  useEffect(() => {
    refreshIsInitialized();
    refreshHasTagFoo();
    refreshHasTagBar();
    refreshUserInfo();
    refreshLocalization();
    refreshUserConsent();
    refreshTags();
    refreshProperties();

    // Request geolocation permission at startup
    requestGeolocationPermission();
  }, [
    refreshIsInitialized,
    refreshHasTagFoo,
    refreshHasTagBar,
    refreshUserInfo,
    refreshLocalization,
    refreshUserConsent,
    refreshTags,
    refreshProperties,
    requestGeolocationPermission,
  ]);

  const refreshIsSubscribedToNotifications = useCallback(async () => {
    try {
      const subscribed = await WonderPush.isSubscribedToNotifications();
      setIsSubscribedToNotifications(subscribed);
    } catch (error) {
      console.error('Error checking subscription status:', error);
    }
  }, []);

  const handleSubscribe = useCallback(async () => {
    try {
      await WonderPush.subscribeToNotifications(true);
      await refreshIsSubscribedToNotifications();
    } catch (error) {
      console.error('Error subscribing:', error);
    }
  }, [refreshIsSubscribedToNotifications]);

  const handleUnsubscribe = useCallback(async () => {
    try {
      await WonderPush.unsubscribeFromNotifications();
      await refreshIsSubscribedToNotifications();
    } catch (error) {
      console.error('Error unsubscribing:', error);
    }
  }, [refreshIsSubscribedToNotifications]);

  const handleLoggingToggle = useCallback(async (value: boolean) => {
    try {
      await WonderPush.setLogging(value);
      setIsLoggingEnabled(value);
    } catch (error) {
      console.error('Error setting logging:', error);
    }
  }, []);

  // Load initial subscription status
  useEffect(() => {
    refreshIsSubscribedToNotifications();
  }, [refreshIsSubscribedToNotifications]);

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.scrollContent}
    >
      {/* Navigation Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🧭 Navigation</Text>
        <Text style={styles.infoText}>
          Test deep linking by navigating to the child screen and copying the
          URLs provided there.
        </Text>
        <Button
          title="Go to Child Screen"
          onPress={() => navigation.navigate('Child')}
        />
      </View>

      {/* Initialization Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🚀 Initialization</Text>
        <Text style={styles.statusText}>
          Initialized:{' '}
          {isInitialized === undefined
            ? 'Loading...'
            : isInitialized.toString()}
        </Text>
        <Button
          title="Initialize Demo Credentials"
          onPress={async () => {
            try {
              await WonderPush.initialize(
                '7524c8a317c1794c0b23895dce3a3314d6a24105',
                'b43a2d0fbdb54d24332b4d70736954eab5d24d29012b18ef6d214ff0f51e7901'
              );
              await refreshIsInitialized();
              Alert.alert('Success', 'WonderPush initialized');
            } catch (error) {
              Alert.alert('Error', `Failed to initialize: ${error}`);
            }
          }}
        />
        <Button
          title="Initialize & Remember Demo Credentials"
          onPress={async () => {
            try {
              await WonderPush.initializeAndRememberCredentials(
                '7524c8a317c1794c0b23895dce3a3314d6a24105',
                'b43a2d0fbdb54d24332b4d70736954eab5d24d29012b18ef6d214ff0f51e7901'
              );
              await refreshIsInitialized();
              Alert.alert('Success', 'WonderPush initialized and remembered');
            } catch (error) {
              Alert.alert('Error', `Failed to initialize: ${error}`);
            }
          }}
        />
        <Button
          title="Initialize Example Credentials"
          onPress={async () => {
            try {
              await WonderPush.initialize(
                '47d9054ece4faca1882ba05abcf60163941597f4',
                'f7864cc6cffc9eea85f1dac4788978434f5325e06cdfe32c1b3139b3d5c18f30'
              );
              await refreshIsInitialized();
              Alert.alert('Success', 'WonderPush initialized');
            } catch (error) {
              Alert.alert('Error', `Failed to initialize: ${error}`);
            }
          }}
        />
        <Button
          title="Initialize & Remember Example Credentials"
          onPress={async () => {
            try {
              await WonderPush.initializeAndRememberCredentials(
                '47d9054ece4faca1882ba05abcf60163941597f4',
                'f7864cc6cffc9eea85f1dac4788978434f5325e06cdfe32c1b3139b3d5c18f30'
              );
              await refreshIsInitialized();
              Alert.alert('Success', 'WonderPush initialized and remembered');
            } catch (error) {
              Alert.alert('Error', `Failed to initialize: ${error}`);
            }
          }}
        />
        <Button
          title="Get Remembered Client ID"
          onPress={async () => {
            try {
              const clientId = await WonderPush.getRememberedClientId();
              Alert.alert('Client ID', clientId || 'None');
            } catch (error) {
              Alert.alert('Error', `Failed to get client ID: ${error}`);
            }
          }}
        />
      </View>

      {/* Logging Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>📝 Logging</Text>
        <View style={styles.switchContainer}>
          <Text style={styles.switchLabel}>Enable Logging</Text>
          <Switch
            value={isLoggingEnabled}
            onValueChange={handleLoggingToggle}
          />
        </View>
      </View>

      {/* Notifications Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🔔 Notifications</Text>
        <Text style={styles.statusText}>
          Subscribed:{' '}
          {isSubscribedToNotifications === undefined
            ? 'Loading...'
            : isSubscribedToNotifications.toString()}
        </Text>
        <View style={styles.buttonRow}>
          <Button title="Subscribe" onPress={handleSubscribe} />
          <Button title="Unsubscribe" onPress={handleUnsubscribe} />
        </View>
      </View>

      {/* Event Tracking Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>📊 Event Tracking</Text>
        <View style={styles.buttonRow}>
          <Button
            title="Track 'firstVisit'"
            onPress={async () => {
              try {
                await WonderPush.trackEvent('firstVisit');
              } catch (error) {
                Alert.alert('Error', `Failed to track event: ${error}`);
              }
            }}
          />
          <Button
            title="Track 'purchase'"
            onPress={async () => {
              try {
                await WonderPush.trackEvent('purchase', {
                  amount: 9.99,
                  currency: 'USD',
                });
              } catch (error) {
                Alert.alert('Error', `Failed to track event: ${error}`);
              }
            }}
          />
        </View>
      </View>

      {/* Tags Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🏷️ Tags</Text>
        <Text style={styles.infoText}>All tags: {JSON.stringify(tags)}</Text>
        <View style={styles.tagRow}>
          <Button
            title="+foo"
            onPress={async () => {
              await WonderPush.addTag('foo').catch(console.error);
              await Promise.all([refreshHasTagFoo(), refreshTags()]);
            }}
          />
          <Button
            title="-foo"
            onPress={async () => {
              await WonderPush.removeTag('foo').catch(console.error);
              await Promise.all([refreshHasTagFoo(), refreshTags()]);
            }}
          />
          <Text>
            foo: {hasTagFoo === undefined ? '...' : JSON.stringify(hasTagFoo)}
          </Text>
        </View>
        <View style={styles.tagRow}>
          <Button
            title="+bar"
            onPress={async () => {
              await WonderPush.addTag('bar').catch(console.error);
              await Promise.all([refreshHasTagBar(), refreshTags()]);
            }}
          />
          <Button
            title="-bar"
            onPress={async () => {
              await WonderPush.removeTag('bar').catch(console.error);
              await Promise.all([refreshHasTagBar(), refreshTags()]);
            }}
          />
          <Text>
            bar: {hasTagBar === undefined ? '...' : JSON.stringify(hasTagBar)}
          </Text>
        </View>
        <Button
          title="Remove All Tags"
          onPress={async () => {
            try {
              await WonderPush.removeAllTags();
              await Promise.all([
                refreshHasTagFoo(),
                refreshHasTagBar(),
                refreshTags(),
              ]);
            } catch (error) {
              Alert.alert('Error', `Failed to remove tags: ${error}`);
            }
          }}
        />
      </View>

      {/* Properties Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>⚙️ Properties</Text>
        <Text style={styles.infoText}>
          {JSON.stringify(properties, null, 2)}
        </Text>
        <View style={styles.buttonRow}>
          <Button
            title="Set 'string_gender' = 'male'"
            onPress={async () => {
              try {
                await WonderPush.setProperty('string_gender', 'male');
                await refreshProperties();
              } catch (error) {
                Alert.alert('Error', `Failed to set property: ${error}`);
              }
            }}
          />
          <Button
            title="Set 'string_gender' = 'female'"
            onPress={async () => {
              try {
                await WonderPush.setProperty('string_gender', 'female');
                await refreshProperties();
              } catch (error) {
                Alert.alert('Error', `Failed to set property: ${error}`);
              }
            }}
          />
          <Button
            title="Add 'string_categories'"
            onPress={async () => {
              try {
                await WonderPush.addProperty('string_categories', [
                  'sports',
                  'tech',
                ]);
                await refreshProperties();
              } catch (error) {
                Alert.alert('Error', `Failed to add property: ${error}`);
              }
            }}
          />
          <Button
            title="Get 'string_categories' values"
            onPress={async () => {
              try {
                const values =
                  await WonderPush.getPropertyValues('string_categories');
                Alert.alert('Property Values', JSON.stringify(values));
              } catch (error) {
                Alert.alert('Error', `Failed to get property: ${error}`);
              }
            }}
          />
        </View>
        <View style={styles.buttonRow}>
          <Button
            title="Get 'string_gender' value"
            onPress={async () => {
              try {
                const value =
                  await WonderPush.getPropertyValue('string_gender');
                Alert.alert('Property Value', JSON.stringify(value));
              } catch (error) {
                Alert.alert('Error', `Failed to get property: ${error}`);
              }
            }}
          />
          <Button
            title="Unset 'string_gender'"
            onPress={async () => {
              try {
                await WonderPush.unsetProperty('string_gender');
                await refreshProperties();
              } catch (error) {
                Alert.alert('Error', `Failed to unset property: ${error}`);
              }
            }}
          />
        </View>
      </View>

      {/* User Management Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>👤 User Management</Text>
        <Text style={styles.infoText}>Current User ID: {userId || 'None'}</Text>
        <View style={styles.inputRow}>
          <TextInput
            style={styles.textInput}
            placeholder="Enter User ID"
            value={inputUserId}
            onChangeText={setInputUserId}
          />
          <Button
            title="Set"
            onPress={async () => {
              try {
                await WonderPush.setUserId(inputUserId);
                await refreshUserInfo();
              } catch (error) {
                Alert.alert('Error', `Failed to set user ID: ${error}`);
              }
            }}
          />
        </View>
      </View>

      {/* Localization Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🌍 Localization</Text>
        <View style={styles.localizationInfo}>
          <Text>Country: {country || 'None'}</Text>
          <Text>Currency: {currency || 'None'}</Text>
          <Text>Locale: {locale || 'None'}</Text>
          <Text>TimeZone: {timeZone || 'None'}</Text>
        </View>

        <View style={styles.inputRow}>
          <TextInput
            style={styles.textInput}
            placeholder="Country (e.g., US)"
            value={inputCountry}
            onChangeText={setInputCountry}
          />
          <Button
            title="Set"
            onPress={async () => {
              await WonderPush.setCountry(inputCountry || null).catch(
                console.error
              );
              await refreshLocalization();
            }}
          />
        </View>

        <View style={styles.inputRow}>
          <TextInput
            style={styles.textInput}
            placeholder="Currency (e.g., USD)"
            value={inputCurrency}
            onChangeText={setInputCurrency}
          />
          <Button
            title="Set"
            onPress={async () => {
              await WonderPush.setCurrency(inputCurrency || null).catch(
                console.error
              );
              await refreshLocalization();
            }}
          />
        </View>

        <View style={styles.inputRow}>
          <TextInput
            style={styles.textInput}
            placeholder="Locale (e.g., en-US)"
            value={inputLocale}
            onChangeText={setInputLocale}
          />
          <Button
            title="Set"
            onPress={async () => {
              await WonderPush.setLocale(inputLocale || null).catch(
                console.error
              );
              await refreshLocalization();
            }}
          />
        </View>

        <View style={styles.inputRow}>
          <TextInput
            style={styles.textInput}
            placeholder="TimeZone"
            value={inputTimeZone}
            onChangeText={setInputTimeZone}
          />
          <Button
            title="Set"
            onPress={async () => {
              await WonderPush.setTimeZone(inputTimeZone || null).catch(
                console.error
              );
              await refreshLocalization();
            }}
          />
        </View>
      </View>

      {/* Privacy Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🔒 Privacy</Text>
        <Text style={styles.statusText}>
          User Consent:{' '}
          {userConsent === undefined ? 'Loading...' : userConsent.toString()}
        </Text>

        <View style={styles.buttonRow}>
          <Button
            title="Require User Consent"
            onPress={async () => {
              try {
                await WonderPush.setRequiresUserConsent(true);
                Alert.alert('Success', 'User consent required');
              } catch (error) {
                Alert.alert('Error', `Failed: ${error}`);
              }
            }}
          />
          <Button
            title="Grant Consent"
            onPress={async () => {
              try {
                await WonderPush.setUserConsent(true);
                await refreshUserConsent();
                Alert.alert('Success', 'Consent granted');
              } catch (error) {
                Alert.alert('Error', `Failed: ${error}`);
              }
            }}
          />
        </View>

        <View style={styles.buttonRow}>
          <Button
            title="Enable Geolocation"
            onPress={async () => {
              try {
                await WonderPush.enableGeolocation();
                Alert.alert('Success', 'Geolocation enabled');
              } catch (error) {
                Alert.alert('Error', `Failed: ${error}`);
              }
            }}
          />
          <Button
            title="Disable Geolocation"
            onPress={async () => {
              try {
                await WonderPush.disableGeolocation();
                Alert.alert('Success', 'Geolocation disabled');
              } catch (error) {
                Alert.alert('Error', `Failed: ${error}`);
              }
            }}
          />
        </View>

        <View style={styles.geoInputRow}>
          <TextInput
            style={styles.textInput}
            placeholder="Latitude"
            value={inputLat}
            onChangeText={setInputLat}
            keyboardType="numeric"
          />
          <TextInput
            style={styles.textInput}
            placeholder="Longitude"
            value={inputLon}
            onChangeText={setInputLon}
            keyboardType="numeric"
          />
          <Button
            title="Set Location"
            onPress={async () => {
              try {
                const lat = parseFloat(inputLat);
                const lon = parseFloat(inputLon);
                if (isNaN(lat) || isNaN(lon)) {
                  Alert.alert('Error', 'Please enter valid coordinates');
                  return;
                }
                await WonderPush.setGeolocation(lat, lon);
                Alert.alert('Success', `Location set to ${lat}, ${lon}`);
              } catch (error) {
                Alert.alert('Error', `Failed: ${error}`);
              }
            }}
          />
        </View>
      </View>

      {/* Installation Info Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>📱 Installation Info</Text>
        <Text style={styles.infoText}>Device ID: {deviceId}</Text>
        <Text style={styles.infoText}>Installation ID: {installationId}</Text>
        <Text style={styles.infoText}>
          Push Token: {pushToken ? `${pushToken.substring(0, 20)}...` : 'None'}
        </Text>
        <Text style={styles.infoText}>
          Access Token:{' '}
          {accessToken ? `${accessToken.substring(0, 20)}...` : 'None'}
        </Text>
        <Button title="Refresh Info" onPress={refreshUserInfo} />
      </View>

      {/* Data Management Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>💾 Data Management</Text>
        <View style={styles.buttonRow}>
          <Button
            title="Clear Events History"
            onPress={async () => {
              try {
                await WonderPush.clearEventsHistory();
                Alert.alert('Success', 'Events history cleared');
              } catch (error) {
                Alert.alert('Error', `Failed: ${error}`);
              }
            }}
          />
          <Button
            title="Clear Preferences"
            onPress={async () => {
              try {
                await WonderPush.clearPreferences();
                Alert.alert('Success', 'Preferences cleared');
              } catch (error) {
                Alert.alert('Error', `Failed: ${error}`);
              }
            }}
          />
        </View>
        <View style={styles.buttonRow}>
          <Button
            title="Clear All Data"
            onPress={async () => {
              try {
                await WonderPush.clearAllData();
                Alert.alert('Success', 'All data cleared');
              } catch (error) {
                Alert.alert('Error', `Failed: ${error}`);
              }
            }}
          />
          <Button
            title="Download All Data"
            onPress={async () => {
              try {
                const data = await WonderPush.downloadAllData();
                Alert.alert('Data Downloaded', JSON.stringify(data, null, 2));
              } catch (error) {
                Alert.alert('Error', `Failed: ${error}`);
              }
            }}
          />
        </View>
      </View>

      {/* Deep Linking Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🔗 Deep Linking</Text>
        <Button
          title="Get Initial URLs (Detailed)"
          onPress={async () => {
            try {
              const [linkingURL, wonderPushURL] = await Promise.all([
                Linking.getInitialURL(),
                WonderPush.getInitialURL(),
              ]);

              const details = [
                'URL Sources:',
                '',
                '📱 Linking.getInitialURL():',
                linkingURL ? `"${linkingURL}"` : 'null',
                '',
                '🔔 WonderPush.getInitialURL():',
                wonderPushURL ? `"${wonderPushURL}"` : 'null',
                '',
                'Note:',
                '- Linking: Standard React Native deep linking',
                '- WonderPush: URLs from push notifications only',
              ].join('\n');

              Alert.alert('Initial URLs Comparison', details);

              // Also log to console for debugging
              console.log('=== Deep Link URL Comparison ===');
              console.log('Linking.getInitialURL():', linkingURL);
              console.log('WonderPush.getInitialURL():', wonderPushURL);
              console.log('================================');
            } catch (error) {
              Alert.alert('Error', `Failed: ${error}`);
            }
          }}
        />
        <View style={styles.buttonRow}>
          <Button
            title="Test Deep Links"
            onPress={() => {
              Alert.alert(
                'Test Deep Links',
                'Available URLs:\n\n• wonderpush://child\n• https://wonderpush.example/child\n\nSend these URLs to yourself via text/email and tap them to test.'
              );
            }}
          />
        </View>
      </View>

      {/* Notification Delegate Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>📬 Notification Delegate</Text>
        <Button
          title="Set Notification Delegate"
          onPress={() => {
            WonderPush.setDelegate(wonderpushDelegate);
            Alert.alert('Success', 'Notification delegate set');
          }}
        />
        <Button
          title="Remove Notification Delegate"
          onPress={() => {
            WonderPush.setDelegate(null);
            Alert.alert('Success', 'Notification delegate removed');
          }}
        />
      </View>

      {/* URL Deep Link Delegate Testing Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🔗 URL Deep Link Delegate</Text>
        <Text style={styles.infoText}>
          The urlForDeeplink delegate is set to intercept deep link URLs:
          {'\n\n'}• wonderpush.com URLs → Redirected to Google
          {'\n'}• blocked-domain.com → Blocked (returns null)
          {'\n'}• example.com → Adds ?intercepted=true
          {'\n'}• Others → Pass through unchanged
          {'\n\n'}
          ⚠️ NOTE: This delegate may be called in the background (Android) or
          when the app is not running, so it only logs to console - no UI!
        </Text>
        <Text style={styles.statusText}>
          📝 Check console logs (adb logcat on Android, Xcode console on iOS) to
          see URL interception in action!
        </Text>
        <View style={styles.buttonRow}>
          <Button
            title="How to Test"
            onPress={() => {
              Alert.alert(
                'Testing URL Interception',
                'To test the urlForDeeplink delegate:\n\n' +
                  '1. Send yourself a push notification with a target URL from the WonderPush dashboard\n\n' +
                  '2. Use URLs like:\n' +
                  '   • https://wonderpush.com/test\n' +
                  '   • https://example.com/page\n' +
                  '   • https://blocked-domain.com/test\n\n' +
                  '3. Watch the console logs to see URL interception\n\n' +
                  '4. Observe which URL actually opens in the browser',
                [{ text: 'Got it!' }]
              );
            }}
          />
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollContent: {
    padding: 16,
    gap: 16,
  },
  section: {
    backgroundColor: 'white',
    borderRadius: 8,
    padding: 16,
    gap: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  statusText: {
    fontSize: 16,
    padding: 8,
    backgroundColor: '#f0f8ff',
    borderRadius: 4,
    color: '#007AFF',
  },
  infoText: {
    fontSize: 14,
    color: '#666',
    backgroundColor: '#f9f9f9',
    padding: 8,
    borderRadius: 4,
    fontFamily: 'monospace',
  },
  switchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  switchLabel: {
    fontSize: 16,
    color: '#333',
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 12,
    flexWrap: 'wrap',
  },
  tagRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    flexWrap: 'wrap',
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  geoInputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    flexWrap: 'wrap',
  },
  textInput: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 4,
    padding: 8,
    fontSize: 16,
    backgroundColor: 'white',
    minWidth: 120,
  },
  localizationInfo: {
    gap: 4,
  },
});
