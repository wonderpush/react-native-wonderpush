import * as React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { Linking } from 'react-native';
import HomeScreen from './HomeScreen';
import ChildScreen from './ChildScreen';

type RootStackParamList = {
  Home: undefined;
  Child: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App() {
  const [isReady, setIsReady] = React.useState(false);
  const [initialState, setInitialState] = React.useState();

  React.useEffect(() => {
    const restoreState = async () => {
      try {
        const initialUrl = await Linking.getInitialURL();

        if (initialUrl) {
          // If app opened from deep link, create initial state with Home in the stack
          if (initialUrl.includes('child')) {
            // Create navigation state with Home -> Child
            setInitialState({
              index: 1,
              routes: [{ name: 'Home' }, { name: 'Child' }],
            } as any);
          }
        }
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
