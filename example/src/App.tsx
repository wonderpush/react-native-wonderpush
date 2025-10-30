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
  const [isReady, setIsReady] = React.useState(false);
  const [initialState, setInitialState] = React.useState();

  React.useEffect(() => {
    const restoreState = async () => {
      try {
        const rnInitialUrl = await Linking.getInitialURL();
        const wpInitialUrl = await WonderPush.getInitialURL();
        const initialUrl = rnInitialUrl || wpInitialUrl;
        console.log('XXXXXX App: Linking.getInitialURL:', rnInitialUrl);
        console.log('XXXXXX App: WonderPush.getInitialURL:', wpInitialUrl);
        console.log('XXXXXX App: -> initialURL:', initialUrl);

        if (initialUrl) {
          // If app opened from deep link, create initial state with Home in the stack
          if (initialUrl.includes('child')) {
            console.log('XXXXXX App: setInitialState(child)');
            // Create navigation state with Home -> Child
            setInitialState({
              index: 1,
              routes: [{ name: 'Home' }, { name: 'Child' }],
            } as any);
          }
        }
      } catch (e) {
        console.error(e);
      } finally {
        setIsReady(true);
      }
    };

    restoreState();
  }, []);

  const linking = {
    prefixes: ['wonderpush://', 'https://wonderpush.example'],
    config: {
      screens: {
        Home: '',
        Child: 'child',
      },
    },
  };

  if (!isReady) {
    return null;
  }

  return (
    <NavigationContainer linking={linking} initialState={initialState}>
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
