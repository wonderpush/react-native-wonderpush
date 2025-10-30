import * as React from 'react';
import { View, Text, StyleSheet, Button, ScrollView } from 'react-native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import WonderPush from 'react-native-wonderpush';

type RootStackParamList = {
  Home: undefined;
  Child: undefined;
};

type Props = NativeStackScreenProps<RootStackParamList, 'Child'>;

export default function ChildScreen({ navigation }: Props) {
  const handleGoBack = () => {
    navigation.goBack();
  };

  const handleTrackEvent = async () => {
    try {
      await WonderPush.trackEvent('child_screen_visit', {
        screen: 'ChildScreen',
        timestamp: new Date().toISOString(),
      });
      console.log('Child screen visit tracked');
    } catch (error) {
      console.error('Failed to track child screen visit:', error);
    }
  };

  React.useEffect(() => {
    handleTrackEvent();
  }, []);

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.scrollContent}
    >
      <View style={styles.header}>
        <Text style={styles.title}>🎯 Child Screen</Text>
        <Text style={styles.subtitle}>Deep Link Target Screen</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🔗 Navigation Info</Text>
        <Text style={styles.infoText}>
          You successfully navigated to the child screen! This screen can be
          reached via deep linking.
        </Text>
        <Text style={styles.infoText}>Deep Link URL: wonderpush://child</Text>
        <Text style={styles.infoText}>
          Universal Link URL: https://wonderpush.example/child
        </Text>
        <Text style={styles.infoText}>
          Can go back: {navigation.canGoBack() ? 'Yes ✅' : 'No ❌'}
        </Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>📊 WonderPush Integration</Text>
        <Text style={styles.infoText}>
          This screen automatically tracks a "child_screen_visit" event when
          opened.
        </Text>
        <Button
          title="Track Custom Event"
          onPress={async () => {
            try {
              await WonderPush.trackEvent('button_pressed', {
                button: 'Track Custom Event',
                screen: 'ChildScreen',
                timestamp: new Date().toISOString(),
              });
              console.log('Custom event tracked');
            } catch (error) {
              console.error('Failed to track custom event:', error);
            }
          }}
        />
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🏠 Navigation</Text>
        <View style={styles.buttonRow}>
          <Button title="Go Back" onPress={handleGoBack} />
          <Button
            title="Go to Home"
            onPress={() => navigation.navigate('Home')}
          />
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>ℹ️ Testing Instructions</Text>
        <Text style={styles.instructionText}>
          To test deep linking:
          {'\n\n'}
          1. Send yourself a text message or email with the deep link URL
          {'\n'}
          2. Click the link from your mobile device
          {'\n'}
          3. The app should open and navigate to this screen
          {'\n\n'}
          Available URLs:
          {'\n'}• wonderpush://child (Custom scheme)
          {'\n'}• https://wonderpush.example/child (Universal link)
        </Text>
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
  header: {
    backgroundColor: 'white',
    borderRadius: 8,
    padding: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
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
  infoText: {
    fontSize: 14,
    color: '#666',
    backgroundColor: '#f0f8ff',
    padding: 12,
    borderRadius: 4,
    fontFamily: 'monospace',
    lineHeight: 20,
  },
  instructionText: {
    fontSize: 14,
    color: '#444',
    lineHeight: 20,
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 12,
    flexWrap: 'wrap',
  },
});
