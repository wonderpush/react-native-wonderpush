import { Button, View, StyleSheet } from 'react-native';
import { WonderPush } from 'react-native-wonderpush';

export default function App() {
  return (
    <View style={styles.container}>
      <Button
        title="Subscribe"
        onPress={() => WonderPush.subscribeToNotifications(true)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
