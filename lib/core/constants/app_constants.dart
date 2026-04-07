/// Central place to manage all app-wide constants.
/// Update values here — they will reflect everywhere automatically.
class AppConstants {
  AppConstants._();

  // ─── App Info ───────────────────────────────────────────────────────────────
  static const String appName = 'Arvika Marriage Bureau';
  static const String appTagline =
      'Your trusted partner in finding your perfect match.';
  static const String copyrightYear = '2025';
  static const String copyright =
      '© $copyrightYear $appName. All rights reserved.';

  // ─── Contact Details ────────────────────────────────────────────────────────
  static const String supportEmail = 'arvikamarrage@gmail.com';
  static const String grievanceEmail = 'arvikamarrage@gmail.com';
  static const String phone = '+918340364533';
  static const String phoneRaw = '+918340364533'; // for tel: / wa.me links
  static const String grievanceOfficerName = 'Arvind Kumar';
  static const String grievanceOfficerAddress =
      'Kachahri Road, Near V-Mart, Begusarai, Bihar, India - 851101';
  static const String address =
      'Kachahri Road, Near V-Mart, Begusarai, Bihar, India - 851101';

  // ─── Support Hours ──────────────────────────────────────────────────────────
  static const String supportHours = '9 AM – 6 PM (IST), Monday to Sunday';

  // ─── URLs ───────────────────────────────────────────────────────────────────
  // No website yet — uncomment and update when available
  //   static const String websiteUrl = 'https://www.arvikamarriage.com';
  static const String privacyPolicyUrl =
      'https://privacy.creatorsmind.co.in/arvika-marriage-bureau-app-privacy-policy/';
  static const String termsAndConditionsUrl =
      'https://privacy.creatorsmind.co.in/terms-and-conditions-for-arvika-marriage-bureau-app/';

  // ─── Deep / Action Links ────────────────────────────────────────────────────
  static const String emailLink = 'mailto:$supportEmail';
  static const String phoneLink = 'tel:$phoneRaw';
  static const String whatsappLink = 'https://wa.me/$phoneRaw';

  // ─── Misc ───────────────────────────────────────────────────────────────────
  static const int minAgeRequirement = 18;
  static const String governingLaw = 'India';
}
