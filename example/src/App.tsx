import { Text, Button, View, StyleSheet } from 'react-native';
import { WonderPush } from 'react-native-wonderpush';

const result = WonderPush.multiply(3, 5);

export default function App() {
  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
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
