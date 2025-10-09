import type { ConfigPlugin } from '@expo/config-plugins';
import { AndroidConfig, withAndroidManifest } from '@expo/config-plugins';
import type { WonderPushPluginProps } from '.';

const withWonderPushAndroid: ConfigPlugin<WonderPushPluginProps | void> = (
  expoConfig,
  props
) => {
  const clientId = props?.clientId || 'USE_REMEMBERED';
  const clientSecret = props?.clientSecret || 'USE_REMEMBERED';
  const senderId = props?.senderId;
  const logging = props?.logging;
  const autoInit = props?.autoInit;
  const requiresUserConsent = props?.requiresUserConsent;
  const geolocation = props?.geolocation;

  return withAndroidManifest(expoConfig, (config) => {
    const mainApplication = AndroidConfig.Manifest.getMainApplicationOrThrow(
      config.modResults
    );

    // Add clientId metadata
    AndroidConfig.Manifest.addMetaDataItemToMainApplication(
      mainApplication,
      'com.wonderpush.sdk.clientId',
      clientId
    );

    // Add clientSecret metadata
    AndroidConfig.Manifest.addMetaDataItemToMainApplication(
      mainApplication,
      'com.wonderpush.sdk.clientSecret',
      clientSecret
    );

    // Add senderId metadata only if provided and non-empty
    if (senderId && senderId.trim() !== '') {
      AndroidConfig.Manifest.addMetaDataItemToMainApplication(
        mainApplication,
        'com.wonderpush.sdk.senderId',
        senderId
      );
    }

    // Add logging metadata if explicitly set to true or false
    if (typeof logging === 'boolean') {
      AndroidConfig.Manifest.addMetaDataItemToMainApplication(
        mainApplication,
        'com.wonderpush.sdk.logging',
        logging.toString()
      );
    }

    // Add autoInit metadata if explicitly set to true or false
    if (typeof autoInit === 'boolean') {
      AndroidConfig.Manifest.addMetaDataItemToMainApplication(
        mainApplication,
        'com.wonderpush.sdk.autoInit',
        autoInit.toString()
      );
    }

    // Add requiresUserConsent metadata if explicitly set to true or false
    if (typeof requiresUserConsent === 'boolean') {
      AndroidConfig.Manifest.addMetaDataItemToMainApplication(
        mainApplication,
        'com.wonderpush.sdk.requiresUserConsent',
        requiresUserConsent.toString()
      );
    }

    // Add geolocation metadata if explicitly set to true or false
    if (typeof geolocation === 'boolean') {
      AndroidConfig.Manifest.addMetaDataItemToMainApplication(
        mainApplication,
        'com.wonderpush.sdk.geolocation',
        geolocation.toString()
      );
    }

    return config;
  });
};

export default withWonderPushAndroid;
