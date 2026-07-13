/// Central place to manage all app-wide constants.
/// Update values here — they will reflect everywhere automatically.
class AppConstants {
  AppConstants._();

  // ─── App Info ───────────────────────────────────────────────────────────────
  static const String appName = 'Shaadi Milan';
  static const String appTagline =
      'Your trusted partner in finding your perfect match.';
  static const String splashTagline =
      'Your Journey to a Beautiful Union Begins Here';
  static const String copyrightYear = '2026';
  static const String copyright =
      '© $copyrightYear $appName. All rights reserved.';

  // ─── App Content ────────────────────────────────────────────────────────────
  static const String missionTitle = "Our Mission";
  static const String missionContent =
      "At $appName, our mission is to connect individuals seeking lifelong companionship with compatible partners. We strive to create a platform that is safe, reliable, and efficient, ensuring a joyful journey towards matrimony.";

  static const String offerTitle = "What We Offer";
  static const String offerContent =
      "We provide a comprehensive matchmaking service with a focus on personalized experiences. Our features include detailed profile creation, advanced search filters, secure communication tools, and dedicated support to guide you every step of the way.";

  static const String valuesTitle = "Our Values";
  static const String valuesContent =
      "Trust, respect, and integrity are at the core of everything we do. We are committed to maintaining a high standard of privacy and ensuring a respectful environment for all our members.";

  static const String whyChooseUsTitle = "Why Choose Us?";
  static const String whyChooseUsContent =
      "With years of experience in matchmaking, a vast database of genuine profiles, and a team dedicated to your success, $appName stands out as a premier choice for your matrimonial needs. We understand the cultural nuances and personal preferences that are vital in finding a life partner.";

  static const String thankYouMessage =
      "Thank you for choosing $appName. We look forward to being a part of your beautiful journey!";

  // ─── Assets ─────────────────────────────────────────────────────────────────
  static const String appLogoPath = 'assets/img.png';

  // ─── Contact Details ────────────────────────────────────────────────────────
  static const String supportEmail = 'shaadimilanapp@gmail.com';
  static const String grievanceEmail = 'shaadimilanapp@gmail.com';
  static const String phone = '+911234567890';
  static const String phoneRaw = '+911234567890'; // for tel: / wa.me links
  static const String grievanceOfficerName = 'Ajay Kumar';
  static const String grievanceOfficerAddress =
      'Patna, Bihar, India';
  static const String address =
      'Patna, Bihar, India';

  // ─── Support Hours ──────────────────────────────────────────────────────────
  static const String supportHours = '9 AM – 6 PM (IST), Monday to Sunday';

  // ─── URLs ───────────────────────────────────────────────────────────────────
  // No website yet — uncomment and update when available
  //   static const String websiteUrl = 'https://www.shaadimilan.com';
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

  // ─── UI Labels ──────────────────────────────────────────────────────────────
  static const String dashboard = 'Dashboard';
  static const String myClients = 'My Clients';
  static const String analytics = 'Analytics';
  static const String supportTickets = 'Support Tickets';
  static const String documents = 'Documents';
  static const String settings = 'Settings';
  static const String myProfile = 'My Profile';
  static const String agentIdLabel = 'Agent ID: ';

  // ─── Nav Labels ─────────────────────────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navWishlist = 'WishList';
  static const String navSupport = 'Support';
  static const String navProfile = 'Profile';
  static const String navDashboard = 'Dashboard';
  static const String navClients = 'Clients';
  static const String navRevenue = 'Revenue';

  // ─── Agent Dashboard Labels ─────────────────────────────────────────────────
  static const String dashboardTitle = 'Dashboard';
  static const String welcome = 'Welcome';
  static const String loading = 'Loading...';
  static const String quickActions = 'Quick Actions';
  static const String recentClients = 'Recent Clients';
  static const String viewAll = 'View All';
  static const String totalRevenue = 'Total Revenue';
  static const String totalClients = 'Total Clients';
  static const String success = 'Success';
  static const String pending = 'Pending';
  static const String logout = 'Logout';
  static const String logoutConfirm = 'Are you sure you want to logout?';
  static const String cancel = 'Cancel';
  static const String reports = 'Reports';
  static const String support = 'Support';
  static const String noClientsYet = 'No clients yet';

  // ─── Home Labels ────────────────────────────────────────────────────────────
  static const String home = 'Home';
  static const String homeSubtitle = 'Find your best match';
  static const String allProfiles = 'All Profiles';
  static const String welcomeLabel = 'Welcome, ';
  static const String showingFiltered = 'Showing filtered results';
  static const String showingAllMatches = 'Showing all available matches';
  static const String filterProfiles = 'Filter Profiles';
  static const String applyFilters = 'Apply Filters';
  static const String reset = 'Reset';
  static const String completeProfileTitle = 'Complete your own profile first';
  static const String completeProfileMessage =
      'Finish your profile details so we can show the best matches for you.';
  static const String completeProfileButton = 'Complete profile now';
  static const String noProfilesFound =
      'No recommended profiles match your filters.';
  static const String viewProfile = 'View Profile';
  static const String gender = 'Gender';
  static const String male = 'Male';
  static const String female = 'Female';
  static const String both = 'Both';

  // ─── Dialogs & Messages ─────────────────────────────────────────────────────
  static const String updateRequiredTitle = 'Update Required';
  static const String updateRequiredMessage =
      'A new version of the app is available. Please update to continue.';
  static const String updateNowButton = 'Update Now';

  static const String maintenanceModeTitle = 'Maintenance Mode';
  static const String maintenanceModeSubtitle = 'Server Temporarily Unavailable';
  static const String maintenanceModeMessage =
      "We're currently performing scheduled maintenance to improve your experience.\n\nPlease check back in a few minutes.";
  static const String maintenanceRestoringMessage =
      'Our team is working hard to restore services as quickly as possible.';
  static const String pleaseWait = 'Please wait...';

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
}
