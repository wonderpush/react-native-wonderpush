import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  subscribeToNotifications(fallbackToSettings: boolean): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('WonderPush');
