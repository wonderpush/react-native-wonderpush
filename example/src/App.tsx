import * as React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { Linking } from 'react-native';
import HomeScreen from './HomeScreen';
import ChildScreen from './ChildScreen';
import { WonderPush, WonderPushUserPreferences } from 'react-native-wonderpush';

type RootStackParamList = {
  Home: undefined;
  Child: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

Promise.resolve(undefined)
  .then(async () => {
    console.log(
      'WonderPushUserPreferences.getDefaultChannelId: ',
      await WonderPushUserPreferences.getDefaultChannelId()
    );
    await WonderPushUserPreferences.putChannel({
      id: 'test',
      name: 'Test',
    });
    console.log(
      "WonderPushUserPreferences.getDChannel('test'): ",
      await WonderPushUserPreferences.getChannel('test')
    );
    await WonderPushUserPreferences.putChannelGroup({
      id: 'test_group',
      name: 'Test group',
    });
    //await WonderPushUserPreferences.removeChannel('test_group');
    await WonderPushUserPreferences.putChannel({
      id: 'test_group',
      groupId: 'test_group',
      name: 'Test group channel',
    });
  })
  .catch((err) => console.error(err));

export default function App() {
  const navigationRef = React.useRef<any>(null);

  React.useEffect(() => {
    // Listen for deep links when app is already open
    const subscription = Linking.addEventListener('url', ({ url }) => {
      console.log('📱 [App] Linking event received:', url);
    });

    return () => {
      subscription.remove();
    };
  }, []);

  const linking = React.useMemo(
    () => ({
      prefixes: ['wonderpush://', 'https://wonderpush.example'],
      config: {
        screens: {
          Home: '',
          Child: 'child',
        },
      },
      // Custom getInitialURL to handle both React Native Linking and WonderPush
      async getInitialURL() {
        console.log('📱 [App] getInitialURL called');

        // Check if app was opened by a deep link
        const rnUrl = await Linking.getInitialURL();
        console.log('📱 [App] Linking.getInitialURL():', rnUrl);

        if (rnUrl != null) {
          return rnUrl;
        }

        // Check if app was opened by a WonderPush notification
        const wpUrl = await WonderPush.getInitialURL();
        console.log('📱 [App] WonderPush.getInitialURL():', wpUrl);

        return wpUrl;
      },
      // Custom subscribe to handle URL events
      subscribe(listener: (url: string) => void) {
        console.log(
          '📱 [App] subscribe called - NavigationContainer is now listening'
        );

        // Listen to incoming links from React Native Linking
        const onReceiveURL = ({ url }: { url: string }) => {
          console.log('📱 [App] onReceiveURL called with URL:', url);
          console.log('📱 [App] Passing URL to NavigationContainer listener');
          listener(url);
        };

        // Subscribe to Linking URL events
        const subscription = Linking.addEventListener('url', onReceiveURL);
        console.log('📱 [App] Linking.addEventListener registered');

        return () => {
          console.log('📱 [App] unsubscribe called');
          subscription.remove();
        };
      },
    }),
    []
  );

  return (
    <NavigationContainer
      ref={navigationRef}
      linking={linking}
      onReady={() => console.log('📱 [App] NavigationContainer ready')}
      onStateChange={(state) =>
        console.log(
          '📱 [App] Navigation state changed:',
          state?.routes?.[state?.index]?.name
        )
      }
    >
      <Stack.Navigator
        initialRouteName="Home"
        screenOptions={{
          headerStyle: {
            backgroundColor: '#007AFF',
          },
          headerTintColor: '#fff',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
        }}
      >
        <Stack.Screen
          name="Home"
          component={HomeScreen}
          options={{ title: 'WonderPush Demo' }}
        />
        <Stack.Screen
          name="Child"
          component={ChildScreen}
          options={{ title: 'Child Screen' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
