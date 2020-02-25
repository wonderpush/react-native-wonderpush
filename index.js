
import { NativeModules } from 'react-native';

const { RNWonderpush } = NativeModules;



function isInitialized() {
  return RNWonderpush != null;
}

export class WonderPush{
  static init(clientId, clientSecret) {
    console.log("test1");
    if (RNWonderpush == null){
      console.log("test2");
      return;
    } 
    if (Platform.OS === 'ios') {
      console.log("test3");
      console.log(clientId);
      console.log(clientSecret);
      RNWonderpush.init(clientId,clientSecret)
    } else {
    }
  }
  static helloWorld(){
    console.log("Hello World");
  }
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