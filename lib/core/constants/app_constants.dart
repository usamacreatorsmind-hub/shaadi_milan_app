/// Central place to manage all app-wide technical constants.
/// UI labels are managed in AppLabels.
class  AppConstants {
  AppConstants._();

  static const String appName = 'Shaadi Milan';
  static const String appNameRaw = 'Shaadi Milan';

  // ─── Assets ─────────────────────────────────────────────────────────────────
  static const String appLogoPath = 'assets/img.png';

  // ─── Contact Details ────────────────────────────────────────────────────────
  static const String supportEmail = 'shaadimilanapp@gmail.com';
  static const String grievanceEmail = 'shaadimilanapp@gmail.com';
  static const String phoneRaw = '+911234567890'; // for tel: / wa.me links
  static const String grievanceOfficerName = 'Ajay Kumar';
  static const String grievanceOfficerAddress = 'Patna, Bihar, India';
  static const String address = 'Patna, Bihar, India';

  // ─── Support Hours ──────────────────────────────────────────────────────────
  static const String supportHours = '9 AM – 6 PM (IST), Monday to Sunday';

  // ─── URLs ───────────────────────────────────────────────────────────────────
  static const String privacyPolicyUrl =
      'https://privacy.creatorsmind.co.in/shaadi-milan-app-privacy-policy/';
  static const String termsAndConditionsUrl =
      'https://privacy.creatorsmind.co.in/terms-and-conditions-for-shaadi-milan-app/';

  // ─── Deep / Action Links ────────────────────────────────────────────────────
  static const String emailLink = 'mailto:$supportEmail';
  static const String phoneLink = 'tel:$phoneRaw';
  static const String whatsappLink = 'https://wa.me/$phoneRaw';

  // ─── Misc ───────────────────────────────────────────────────────────────────
  static const int minAgeRequirement = 18;
  static const String governingLaw = 'India';

  // ─── Notification Channels ──────────────────────────────────────────────────
  static const String fcmChannelKey = 'fcm_channel';
  static const String fcmChannelName = 'FCM Notifications';
  static const String fcmChannelDescription = 'Firebase Cloud Messaging';

  static const String basicChannelKey = 'basic_channel';
  static const String basicChannelName = 'Basic Notifications';
  static const String basicChannelDescription = 'General notifications';

  static const String scheduledChannelKey = 'scheduled_channel';
  static const String scheduledChannelName = 'Scheduled Notifications';
  static const String scheduledChannelDescription = 'Scheduled reminders';

  static const String notificationIcon = 'resource://drawable/ic_notification';

  // ─── Design ─────────────────────────────────────────────────────────────────
  static const String fontFamily = 'Roboto';
  static const int primaryRedHex = 0xFFB11226;
  static const int accentRedHex = 0xFFE53935;

  // ─── Firestore Collections ──────────────────────────────────────────────────
  static const String collUsers = 'users';
  static const String collAgents = 'agents';
  static const String collProfiles = 'metrimony_profiles';

  // ─── Firestore Fields ───────────────────────────────────────────────────────
  static const String fieldGender = 'gender';
  static const String fieldProfileStatus = 'profileStatus';
  static const String statusActive = 'active';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldFcmToken = 'fcmToken';
  static const String fieldFcmTokenUpdatedAt = 'fcmTokenUpdatedAt';
  static const String fieldPlatform = 'platform';

  // ─── Agent Designations ──────────────────────────────────────────────────
  static const String agentStaff = 'staff';
  static const String agentFieldManager = 'field_manager';
  static const String agentAreaManager = 'area_manager';
}
