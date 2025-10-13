import type { ConfigPlugin } from '@expo/config-plugins';
import { withInfoPlist } from '@expo/config-plugins';
import type { WonderPushPluginProps } from '.';

const withWonderPushIOS: ConfigPlugin<WonderPushPluginProps | void> = (
  expoConfig,
  props
) => {
  void props;

  // Add remote-notification to UIBackgroundModes
  expoConfig = withInfoPlist(expoConfig, (config) => {
    const existingModes = config.modResults.UIBackgroundModes || [];

    // Add remote-notification if not already present
    if (!existingModes.includes('remote-notification')) {
      config.modResults.UIBackgroundModes = [
        ...existingModes,
        'remote-notification',
      ];
    }

    return config;
  });

  return expoConfig;
};

export default withWonderPushIOS;
