
import { NativeModules } from 'react-native';

const { RNWonderpush } = NativeModules;


function isInitialized() {
  return RNWonderpush != null;
}

export default class WonderPush{
  static init(clientId, clientSecret) {
    if (!isInitialized()){
      return;
    } 
    if (Platform.OS === 'ios') {
        RNWonderpush.init(clientId,clientSecret)
    } else {
      //to do
    }
  }
  static setupDelegate()
  static subscribeToNotifications(){
    if (Platform.OS === 'ios') {
      RNWonderpush.subscribeToNotifications()
    } else {
    //to do
    }
  }
  static unsubscribeFromNotifications(){
     RNWonderpush.unsubscribeFromNotifications()
  }
}