import type { ConfigPlugin } from '@expo/config-plugins';
import type { WonderPushPluginProps } from '.';

const withWonderPushIOS: ConfigPlugin<WonderPushPluginProps | void> = (
  expoConfig,
  props
) => {
  void props;
  // iOS-specific configuration will go here
  return expoConfig;
};

export default withWonderPushIOS;
