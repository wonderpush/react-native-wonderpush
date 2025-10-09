import type { ConfigPlugin } from '@expo/config-plugins';
import withWonderPushAndroid from './withWonderPushAndroid';
import withWonderPushIOS from './withWonderPushIOS';

export type WonderPushPluginProps = {
  clientId?: string;
  clientSecret?: string;
  senderId?: string;
  logging?: boolean;
  autoInit?: boolean;
  requiresUserConsent?: boolean;
  geolocation?: boolean;
};

const withWonderPush: ConfigPlugin<WonderPushPluginProps | void> = (
  config,
  props
) => {
  config = withWonderPushAndroid(config, props);
  config = withWonderPushIOS(config, props);
  return config;
};

export default withWonderPush;
