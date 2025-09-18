import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  multiply(a: number, b: number): number;
  subscribeToNotifications(fallbackToSettings: boolean): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('WonderPush');
