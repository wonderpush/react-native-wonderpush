/**
 * Represents a notification channel group.
 * Mimics Android's NotificationChannelGroup with support for pre-Android O devices.
 */
export interface WonderPushChannelGroup {
  /** Unique identifier per package for the channel group */
  id: string;
  /** User-visible display name for the group */
  name?: string | null;
}

/**
 * Represents a notification channel.
 * Mimics Android's NotificationChannel with backward compatibility and additional features.
 */
export interface WonderPushChannel {
  /** Unique channel identifier (immutable) */
  id: string;
  /** Visual grouping in UI (optional) */
  groupId?: string | null;
  /** User-visible channel name */
  name?: string | null;
  /** User-visible channel description */
  description?: string | null;
  /** Do Not Disturb override permission */
  bypassDnd?: boolean | null;
  /** Launcher badge display */
  showBadge?: boolean | null;
  /**
   * Interruption level (importance)
   * Values correspond to NotificationManager constants:
   * - IMPORTANCE_NONE (0)
   * - IMPORTANCE_MIN (1)
   * - IMPORTANCE_LOW (2)
   * - IMPORTANCE_DEFAULT (3)
   * - IMPORTANCE_HIGH (4)
   * - IMPORTANCE_MAX (5)
   */
  importance?: number | null;
  /** Notification LED trigger */
  lights?: boolean | null;
  /** LED color value (as integer) */
  lightColor?: number | null;
  /** Vibration enabled */
  vibrate?: boolean | null;
  /** Custom vibration sequence (array of longs) */
  vibrationPattern?: number[] | null;
  /** Audio playback enabled */
  sound?: boolean | null;
  /** Custom notification sound path (URI string) */
  soundUri?: string | null;
  /**
   * Lock screen display mode
   * Values correspond to Notification visibility constants:
   * - VISIBILITY_SECRET (-1)
   * - VISIBILITY_PRIVATE (0)
   * - VISIBILITY_PUBLIC (1)
   */
  lockscreenVisibility?: number | null;
  /** Silent mode vibration (WonderPush addition) */
  vibrateInSilentMode?: boolean | null;
  /** Notification color (as integer) */
  color?: number | null;
  /** Device-local restriction */
  localOnly?: boolean | null;
}
