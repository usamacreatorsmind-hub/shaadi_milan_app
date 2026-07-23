import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Shaadi Milan'**
  String get appName;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Shaadi Milan'**
  String get welcomeMessage;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error Occurred'**
  String get serverError;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your trusted partner in finding your perfect match.'**
  String get appTagline;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Journey to a Beautiful Union Begins Here'**
  String get splashTagline;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Shaadi Milan. All rights reserved.'**
  String get copyright;

  /// No description provided for @missionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get missionTitle;

  /// No description provided for @missionContent.
  ///
  /// In en, this message translates to:
  /// **'At Shaadi Milan, our mission is to connect individuals seeking lifelong companionship with compatible partners. We strive to create a platform that is safe, reliable, and efficient, ensuring a joyful journey towards matrimony.'**
  String get missionContent;

  /// No description provided for @offerTitle.
  ///
  /// In en, this message translates to:
  /// **'What We Offer'**
  String get offerTitle;

  /// No description provided for @offerContent.
  ///
  /// In en, this message translates to:
  /// **'We provide a comprehensive matchmaking service with a focus on personalized experiences. Our features include detailed profile creation, advanced search filters, secure communication tools, and dedicated support to guide you every step of the way.'**
  String get offerContent;

  /// No description provided for @valuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Values'**
  String get valuesTitle;

  /// No description provided for @valuesContent.
  ///
  /// In en, this message translates to:
  /// **'Trust, respect, and integrity are at the core of everything we do. We are committed to maintaining a high standard of privacy and ensuring a respectful environment for all our members.'**
  String get valuesContent;

  /// No description provided for @whyChooseUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Why Choose Us?'**
  String get whyChooseUsTitle;

  /// No description provided for @whyChooseUsContent.
  ///
  /// In en, this message translates to:
  /// **'With years of experience in matchmaking, a vast database of genuine profiles, and a team dedicated to your success, Shaadi Milan stands out as a premier choice for your matrimonial needs. We understand the cultural nuances and personal preferences that are vital in finding a life partner.'**
  String get whyChooseUsContent;

  /// No description provided for @thankYouMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for choosing Shaadi Milan. We look forward to being a part of your beautiful journey!'**
  String get thankYouMessage;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @myClients.
  ///
  /// In en, this message translates to:
  /// **'My Clients'**
  String get myClients;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @supportTickets.
  ///
  /// In en, this message translates to:
  /// **'Support Tickets'**
  String get supportTickets;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @agentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Staff ID: '**
  String get agentIdLabel;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWishlist.
  ///
  /// In en, this message translates to:
  /// **'WishList'**
  String get navWishlist;

  /// No description provided for @navSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get navSupport;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get navClients;

  /// No description provided for @navRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get navRevenue;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey'**
  String get welcomeSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createNewProfile.
  ///
  /// In en, this message translates to:
  /// **'Create a New Profile'**
  String get createNewProfile;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentClients.
  ///
  /// In en, this message translates to:
  /// **'Recent Clients'**
  String get recentClients;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @totalClients.
  ///
  /// In en, this message translates to:
  /// **'Total Clients'**
  String get totalClients;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @noClientsYet.
  ///
  /// In en, this message translates to:
  /// **'No clients yet'**
  String get noClientsYet;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your best match'**
  String get homeSubtitle;

  /// No description provided for @allProfiles.
  ///
  /// In en, this message translates to:
  /// **'All Profiles'**
  String get allProfiles;

  /// No description provided for @welcomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Welcome, '**
  String get welcomeLabel;

  /// No description provided for @showingFiltered.
  ///
  /// In en, this message translates to:
  /// **'Showing filtered results'**
  String get showingFiltered;

  /// No description provided for @showingAllMatches.
  ///
  /// In en, this message translates to:
  /// **'Showing all available matches'**
  String get showingAllMatches;

  /// No description provided for @filterProfiles.
  ///
  /// In en, this message translates to:
  /// **'Filter Profiles'**
  String get filterProfiles;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'filter'**
  String get filter;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'filters'**
  String get filters;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get active;

  /// No description provided for @religionAndCaste.
  ///
  /// In en, this message translates to:
  /// **'Religion & Caste'**
  String get religionAndCaste;

  /// No description provided for @scope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get scope;

  /// No description provided for @myClientsOnly.
  ///
  /// In en, this message translates to:
  /// **'My Clients Only'**
  String get myClientsOnly;

  /// No description provided for @assignedToYouOnly.
  ///
  /// In en, this message translates to:
  /// **'Assigned to you only'**
  String get assignedToYouOnly;

  /// No description provided for @allAgents.
  ///
  /// In en, this message translates to:
  /// **'All agents'**
  String get allAgents;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get notStarted;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @staffMember.
  ///
  /// In en, this message translates to:
  /// **'Staff Member'**
  String get staffMember;

  /// No description provided for @suggestedMatches.
  ///
  /// In en, this message translates to:
  /// **'Suggested Matches'**
  String get suggestedMatches;

  /// No description provided for @searchMatchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, caste, religion, city…'**
  String get searchMatchHint;

  /// No description provided for @noMatchingReligionProfiles.
  ///
  /// In en, this message translates to:
  /// **'No matching profiles found for the same religion.'**
  String get noMatchingReligionProfiles;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @matchesFor.
  ///
  /// In en, this message translates to:
  /// **'Matches for {name}'**
  String matchesFor(String name);

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @removeRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Remove Recommendation'**
  String get removeRecommendation;

  /// No description provided for @recommendProfile.
  ///
  /// In en, this message translates to:
  /// **'Recommend Profile'**
  String get recommendProfile;

  /// No description provided for @viewFullProfile.
  ///
  /// In en, this message translates to:
  /// **'View Full Profile'**
  String get viewFullProfile;

  /// No description provided for @profileAlreadyRecommended.
  ///
  /// In en, this message translates to:
  /// **'Profile already recommended!'**
  String get profileAlreadyRecommended;

  /// No description provided for @profileRecommendedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile Recommended Successfully'**
  String get profileRecommendedSuccessfully;

  /// No description provided for @failedToRecommendProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to Recommend Profile'**
  String get failedToRecommendProfile;

  /// No description provided for @recommendationRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Recommendation Removed Successfully'**
  String get recommendationRemovedSuccessfully;

  /// No description provided for @failedToRemoveRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Failed to Remove Recommendation'**
  String get failedToRemoveRecommendation;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @matrimonyProfile.
  ///
  /// In en, this message translates to:
  /// **'Matrimony Profile'**
  String get matrimonyProfile;

  /// No description provided for @notCreated.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get notCreated;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @filterRevenue.
  ///
  /// In en, this message translates to:
  /// **'Filter Revenue'**
  String get filterRevenue;

  /// No description provided for @filterClients.
  ///
  /// In en, this message translates to:
  /// **'Filter Clients'**
  String get filterClients;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectState;

  /// No description provided for @allStates.
  ///
  /// In en, this message translates to:
  /// **'All States'**
  String get allStates;

  /// No description provided for @selectCityDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select City / District'**
  String get selectCityDistrict;

  /// No description provided for @allCities.
  ///
  /// In en, this message translates to:
  /// **'All Cities'**
  String get allCities;

  /// No description provided for @cityDistrict.
  ///
  /// In en, this message translates to:
  /// **'City / District'**
  String get cityDistrict;

  /// No description provided for @selectReligion.
  ///
  /// In en, this message translates to:
  /// **'Select Religion'**
  String get selectReligion;

  /// No description provided for @allReligions.
  ///
  /// In en, this message translates to:
  /// **'All Religions'**
  String get allReligions;

  /// No description provided for @selectCaste.
  ///
  /// In en, this message translates to:
  /// **'Select Caste'**
  String get selectCaste;

  /// No description provided for @allCastes.
  ///
  /// In en, this message translates to:
  /// **'All Castes'**
  String get allCastes;

  /// No description provided for @couldNotLoadLocations.
  ///
  /// In en, this message translates to:
  /// **'Could not load locations'**
  String get couldNotLoadLocations;

  /// No description provided for @couldNotLoadReligions.
  ///
  /// In en, this message translates to:
  /// **'Could not load religions'**
  String get couldNotLoadReligions;

  /// No description provided for @noMessage.
  ///
  /// In en, this message translates to:
  /// **'No message'**
  String get noMessage;

  /// No description provided for @statusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get statusUpdated;

  /// No description provided for @completeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your own profile first'**
  String get completeProfileTitle;

  /// No description provided for @completeProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Finish your profile details so we can show the best matches for you.'**
  String get completeProfileMessage;

  /// No description provided for @completeProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Complete profile now'**
  String get completeProfileButton;

  /// No description provided for @noProfilesFound.
  ///
  /// In en, this message translates to:
  /// **'No recommended profiles match your filters.'**
  String get noProfilesFound;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFilters;

  /// No description provided for @ageYrs.
  ///
  /// In en, this message translates to:
  /// **'yrs'**
  String get ageYrs;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @cultural.
  ///
  /// In en, this message translates to:
  /// **'Cultural'**
  String get cultural;

  /// No description provided for @religion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get religion;

  /// No description provided for @caste.
  ///
  /// In en, this message translates to:
  /// **'Caste'**
  String get caste;

  /// No description provided for @profileStatus.
  ///
  /// In en, this message translates to:
  /// **'Profile Status'**
  String get profileStatus;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @pleaseSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Please subscribe to access this feature'**
  String get pleaseSubscribe;

  /// No description provided for @staffLogin.
  ///
  /// In en, this message translates to:
  /// **'Staff Login'**
  String get staffLogin;

  /// No description provided for @accessStaffPortal.
  ///
  /// In en, this message translates to:
  /// **'Access Your Staff Portal'**
  String get accessStaffPortal;

  /// No description provided for @staffPortal.
  ///
  /// In en, this message translates to:
  /// **'Staff Portal'**
  String get staffPortal;

  /// No description provided for @manageLeadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage leads and match profiles'**
  String get manageLeadsSubtitle;

  /// No description provided for @memberPortal.
  ///
  /// In en, this message translates to:
  /// **'Member Portal'**
  String get memberPortal;

  /// No description provided for @findSoulmateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your perfect soulmate'**
  String get findSoulmateSubtitle;

  /// No description provided for @verifiedProfiles.
  ///
  /// In en, this message translates to:
  /// **'100% Verified & Secure Profiles'**
  String get verifiedProfiles;

  /// No description provided for @needHelpContactUs.
  ///
  /// In en, this message translates to:
  /// **'Need Help ? Contact Us'**
  String get needHelpContactUs;

  /// No description provided for @workEmail.
  ///
  /// In en, this message translates to:
  /// **'Work Email'**
  String get workEmail;

  /// No description provided for @workEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Your Work Email.'**
  String get workEmailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @notAStaffMember.
  ///
  /// In en, this message translates to:
  /// **'Not A Staff Member?'**
  String get notAStaffMember;

  /// No description provided for @userLogin.
  ///
  /// In en, this message translates to:
  /// **'User Login'**
  String get userLogin;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinToday.
  ///
  /// In en, this message translates to:
  /// **'Join Shaadi Milan today'**
  String get joinToday;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @staffId.
  ///
  /// In en, this message translates to:
  /// **'Staff Id'**
  String get staffId;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @registering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registering;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @alreadyAMember.
  ///
  /// In en, this message translates to:
  /// **'Already a member?'**
  String get alreadyAMember;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginNow;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful. Welcome back!'**
  String get loginSuccessful;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Please update to continue.'**
  String get updateRequiredMessage;

  /// No description provided for @updateNowButton.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNowButton;

  /// No description provided for @maintenanceModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Mode'**
  String get maintenanceModeTitle;

  /// No description provided for @maintenanceModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Server Temporarily Unavailable'**
  String get maintenanceModeSubtitle;

  /// No description provided for @maintenanceModeMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'re currently performing scheduled maintenance to improve your experience.\\n\\nPlease check back in a few minutes.'**
  String get maintenanceModeMessage;

  /// No description provided for @maintenanceRestoringMessage.
  ///
  /// In en, this message translates to:
  /// **'Our team is working hard to restore services as quickly as possible.'**
  String get maintenanceRestoringMessage;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @searchHintFull.
  ///
  /// In en, this message translates to:
  /// **'Search by name, age, location...'**
  String get searchHintFull;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @noImagesToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No images to display'**
  String get noImagesToDisplay;

  /// No description provided for @words.
  ///
  /// In en, this message translates to:
  /// **'words'**
  String get words;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'characters'**
  String get characters;

  /// No description provided for @pleaseEnter.
  ///
  /// In en, this message translates to:
  /// **'Please enter'**
  String get pleaseEnter;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get passwordTooShort;

  /// No description provided for @passwordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordUppercase;

  /// No description provided for @passwordLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get passwordLowercase;

  /// No description provided for @passwordNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordNumber;

  /// No description provided for @passwordSpecial.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get passwordSpecial;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmPasswordRequired;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters long'**
  String get nameTooShort;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit phone number'**
  String get invalidPhone;

  /// No description provided for @ageRequired.
  ///
  /// In en, this message translates to:
  /// **'Age is required'**
  String get ageRequired;

  /// No description provided for @invalidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age between 1 and 100'**
  String get invalidAge;

  /// No description provided for @pinCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'PIN Code is required'**
  String get pinCodeRequired;

  /// No description provided for @invalidPinCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit PIN Code'**
  String get invalidPinCode;

  /// No description provided for @heightRequired.
  ///
  /// In en, this message translates to:
  /// **'Height is required'**
  String get heightRequired;

  /// No description provided for @invalidHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid height in cm (e.g., 170)'**
  String get invalidHeight;

  /// No description provided for @weightRequired.
  ///
  /// In en, this message translates to:
  /// **'Weight is required'**
  String get weightRequired;

  /// No description provided for @invalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight in kg (e.g., 70)'**
  String get invalidWeight;

  /// No description provided for @aadharRequired.
  ///
  /// In en, this message translates to:
  /// **'Aadhar number is required'**
  String get aadharRequired;

  /// No description provided for @invalidAadhar.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 12-digit Aadhar number'**
  String get invalidAadhar;

  /// No description provided for @isRequired.
  ///
  /// In en, this message translates to:
  /// **'is required'**
  String get isRequired;

  /// No description provided for @mustBeNumber.
  ///
  /// In en, this message translates to:
  /// **'must be a number'**
  String get mustBeNumber;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @tapToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap to view details'**
  String get tapToViewDetails;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @match.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get match;

  /// No description provided for @revenueDashboard.
  ///
  /// In en, this message translates to:
  /// **'Revenue Dashboard'**
  String get revenueDashboard;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @todayRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today Revenue'**
  String get todayRevenue;

  /// No description provided for @yourCommission.
  ///
  /// In en, this message translates to:
  /// **'Your Commission'**
  String get yourCommission;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @revenueByGender.
  ///
  /// In en, this message translates to:
  /// **'Revenue by Gender'**
  String get revenueByGender;

  /// No description provided for @revenueByPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Revenue by Payment Status'**
  String get revenueByPaymentStatus;

  /// No description provided for @revenueByReligion.
  ///
  /// In en, this message translates to:
  /// **'Revenue by Religion'**
  String get revenueByReligion;

  /// No description provided for @revenueByCaste.
  ///
  /// In en, this message translates to:
  /// **'Revenue by Caste'**
  String get revenueByCaste;

  /// No description provided for @dailyRevenueTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily Revenue Trend'**
  String get dailyRevenueTrend;

  /// No description provided for @regionRevenueDistribution.
  ///
  /// In en, this message translates to:
  /// **'Region Revenue Distribution'**
  String get regionRevenueDistribution;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @noRegionData.
  ///
  /// In en, this message translates to:
  /// **'No region data available'**
  String get noRegionData;

  /// No description provided for @noRegionDataForChart.
  ///
  /// In en, this message translates to:
  /// **'No region data available for chart'**
  String get noRegionDataForChart;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get better matches & faster connections'**
  String get premiumSubtitle;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get mostPopular;

  /// No description provided for @payOnceUnlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Pay Once & Unlock Premium'**
  String get payOnceUnlockPremium;

  /// No description provided for @securePaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Secure payment • Cancel anytime • No hidden charges'**
  String get securePaymentNote;

  /// No description provided for @happyMarriage.
  ///
  /// In en, this message translates to:
  /// **'Happy Marriage'**
  String get happyMarriage;

  /// No description provided for @marriageCongratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on your marriage!'**
  String get marriageCongratulations;

  /// No description provided for @successFee.
  ///
  /// In en, this message translates to:
  /// **'SUCCESS FEE'**
  String get successFee;

  /// No description provided for @paySuccessFee.
  ///
  /// In en, this message translates to:
  /// **'Pay Success Fee'**
  String get paySuccessFee;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @whoWeAre.
  ///
  /// In en, this message translates to:
  /// **'Who We Are'**
  String get whoWeAre;

  /// No description provided for @whoWeAreDescription.
  ///
  /// In en, this message translates to:
  /// **'Shaadi Milan is a trusted matrimonial service dedicated to helping individuals and families find compatible life partners. We believe marriage is not just a bond between two individuals, but a union of families, values, and traditions.'**
  String get whoWeAreDescription;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ for meaningful connections'**
  String get madeWithLove;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @profileImage.
  ///
  /// In en, this message translates to:
  /// **'Profile Image'**
  String get profileImage;

  /// No description provided for @matrimonyImage.
  ///
  /// In en, this message translates to:
  /// **'Matrimony Image'**
  String get matrimonyImage;

  /// No description provided for @imageWithAgent.
  ///
  /// In en, this message translates to:
  /// **'Image with Agent'**
  String get imageWithAgent;

  /// No description provided for @galleryImages.
  ///
  /// In en, this message translates to:
  /// **'Gallery Images'**
  String get galleryImages;

  /// No description provided for @aadharDocument.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Document'**
  String get aadharDocument;

  /// No description provided for @cropImage.
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get cropImage;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @profileImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Profile image is required'**
  String get profileImageRequired;

  /// No description provided for @primaryImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Primary image is required'**
  String get primaryImageRequired;

  /// No description provided for @imageWithAgentRequired.
  ///
  /// In en, this message translates to:
  /// **'Image with agent is required'**
  String get imageWithAgentRequired;

  /// No description provided for @atLeastOneGalleryImageRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one gallery image is required'**
  String get atLeastOneGalleryImageRequired;

  /// No description provided for @aadharDocumentRequired.
  ///
  /// In en, this message translates to:
  /// **'Aadhar document is required'**
  String get aadharDocumentRequired;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @legalAndInfo.
  ///
  /// In en, this message translates to:
  /// **'Legal & Info'**
  String get legalAndInfo;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @mainSection.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get mainSection;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @noUserData.
  ///
  /// In en, this message translates to:
  /// **'No user data'**
  String get noUserData;

  /// No description provided for @pleaseSelect.
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get pleaseSelect;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @transliterateHint.
  ///
  /// In en, this message translates to:
  /// **'Type in English to transliterate'**
  String get transliterateHint;

  /// No description provided for @englishSuffix.
  ///
  /// In en, this message translates to:
  /// **'(English)'**
  String get englishSuffix;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link.'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email. Please check your inbox.'**
  String get resetLinkSent;

  /// No description provided for @userNotFoundWithEmail.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email. Please register first.'**
  String get userNotFoundWithEmail;

  /// No description provided for @unableToSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Unable to send reset link right now. Please try again later.'**
  String get unableToSendResetLink;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @updateYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Update Your Password'**
  String get updateYourPassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and a new password to update.'**
  String get changePasswordSubtitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChangedSuccessfully;

  /// No description provided for @reauthenticateForSecurity.
  ///
  /// In en, this message translates to:
  /// **'Please log in again to change your password. For security reasons, this operation requires a recent authentication.'**
  String get reauthenticateForSecurity;

  /// No description provided for @incorrectCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'The current password you entered is incorrect.'**
  String get incorrectCurrentPassword;

  /// No description provided for @weakNewPassword.
  ///
  /// In en, this message translates to:
  /// **'The new password is too weak. Please use a stronger password.'**
  String get weakNewPassword;

  /// No description provided for @mustBeLoggedInToReset.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to reset your password.'**
  String get mustBeLoggedInToReset;

  /// No description provided for @forgotPasswordResetViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password? Reset via Email'**
  String get forgotPasswordResetViaEmail;

  /// No description provided for @resetEmailSentTo.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}. Please check your inbox.'**
  String resetEmailSentTo(String email);

  /// No description provided for @createIdentity.
  ///
  /// In en, this message translates to:
  /// **'Create Identity'**
  String get createIdentity;

  /// No description provided for @editIdentity.
  ///
  /// In en, this message translates to:
  /// **'Edit Identity'**
  String get editIdentity;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// No description provided for @tellUsAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellUsAboutYourself;

  /// No description provided for @aadharNumber.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Number'**
  String get aadharNumber;

  /// No description provided for @enterAadharNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your Aadhar number'**
  String get enterAadharNumber;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select Date of Birth'**
  String get selectDateOfBirth;

  /// No description provided for @selectDobHelp.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get selectDobHelp;

  /// No description provided for @selectDobConfirm.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectDobConfirm;

  /// No description provided for @pleaseSelectDob.
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get pleaseSelectDob;

  /// No description provided for @mustBe18.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old'**
  String get mustBe18;

  /// No description provided for @notEligibleUnder18.
  ///
  /// In en, this message translates to:
  /// **'You are not eligible to create a profile as you are under 18 years old.'**
  String get notEligibleUnder18;

  /// No description provided for @identitySavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Identity saved successfully'**
  String get identitySavedSuccessfully;

  /// No description provided for @saveIdentity.
  ///
  /// In en, this message translates to:
  /// **'Save Identity'**
  String get saveIdentity;

  /// No description provided for @updateIdentity.
  ///
  /// In en, this message translates to:
  /// **'Update Identity'**
  String get updateIdentity;

  /// No description provided for @genderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Gender not found. Please update your profile.'**
  String get genderNotFound;

  /// No description provided for @errorFetchingUserData.
  ///
  /// In en, this message translates to:
  /// **'Error fetching user data: {error}'**
  String errorFetchingUserData(String error);

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'Age: {age} years'**
  String ageYears(int age);

  /// No description provided for @dobValue.
  ///
  /// In en, this message translates to:
  /// **'DOB: {date}'**
  String dobValue(String date);

  /// No description provided for @addressDetails.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get addressDetails;

  /// No description provided for @place.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get place;

  /// No description provided for @placeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your village, street, or locality'**
  String get placeHint;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @postHint.
  ///
  /// In en, this message translates to:
  /// **'Enter post office'**
  String get postHint;

  /// No description provided for @policeStation.
  ///
  /// In en, this message translates to:
  /// **'Police Station'**
  String get policeStation;

  /// No description provided for @policeStationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Police station'**
  String get policeStationHint;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'PIN Code'**
  String get pinCode;

  /// No description provided for @pinCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit PIN'**
  String get pinCodeHint;

  /// No description provided for @addressSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Address saved successfully'**
  String get addressSavedSuccessfully;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get saveAddress;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @selectStateHelp.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectStateHelp;

  /// No description provided for @addCulturalDetails.
  ///
  /// In en, this message translates to:
  /// **'Add Cultural Details'**
  String get addCulturalDetails;

  /// No description provided for @editCulturalDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Cultural Details'**
  String get editCulturalDetails;

  /// No description provided for @specifyCaste.
  ///
  /// In en, this message translates to:
  /// **'Specify Caste'**
  String get specifyCaste;

  /// No description provided for @specifyCasteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your caste'**
  String get specifyCasteHint;

  /// No description provided for @subCaste.
  ///
  /// In en, this message translates to:
  /// **'Sub-Caste'**
  String get subCaste;

  /// No description provided for @subCasteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter sub-caste'**
  String get subCasteHint;

  /// No description provided for @additionalQualifications.
  ///
  /// In en, this message translates to:
  /// **'Additional Qualifications'**
  String get additionalQualifications;

  /// No description provided for @addKnownLanguages.
  ///
  /// In en, this message translates to:
  /// **'Add Known Languages'**
  String get addKnownLanguages;

  /// No description provided for @languagesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Hindi, English, Mathili etc'**
  String get languagesHint;

  /// No description provided for @culturalDetailsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cultural details saved successfully'**
  String get culturalDetailsSavedSuccessfully;

  /// No description provided for @pleaseSelectReligion.
  ///
  /// In en, this message translates to:
  /// **'Please select a religion'**
  String get pleaseSelectReligion;

  /// No description provided for @pleaseSelectCaste.
  ///
  /// In en, this message translates to:
  /// **'Please select a caste'**
  String get pleaseSelectCaste;

  /// No description provided for @educationDetails.
  ///
  /// In en, this message translates to:
  /// **'Education Details'**
  String get educationDetails;

  /// No description provided for @editEducation.
  ///
  /// In en, this message translates to:
  /// **'Edit Education'**
  String get editEducation;

  /// No description provided for @literate.
  ///
  /// In en, this message translates to:
  /// **'Literate'**
  String get literate;

  /// No description provided for @illiterate.
  ///
  /// In en, this message translates to:
  /// **'Illiterate'**
  String get illiterate;

  /// No description provided for @highestQualification.
  ///
  /// In en, this message translates to:
  /// **'Highest Qualification'**
  String get highestQualification;

  /// No description provided for @collegeUniversity.
  ///
  /// In en, this message translates to:
  /// **'College / University'**
  String get collegeUniversity;

  /// No description provided for @collegeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter college or university name'**
  String get collegeHint;

  /// No description provided for @degreeCourse.
  ///
  /// In en, this message translates to:
  /// **'Degree / Course'**
  String get degreeCourse;

  /// No description provided for @degreeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter degree or course name'**
  String get degreeHint;

  /// No description provided for @percentageCGPA.
  ///
  /// In en, this message translates to:
  /// **'Percentage / CGPA'**
  String get percentageCGPA;

  /// No description provided for @percentageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 75.5'**
  String get percentageHint;

  /// No description provided for @passingYear.
  ///
  /// In en, this message translates to:
  /// **'Passing Year'**
  String get passingYear;

  /// No description provided for @yearHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 2023'**
  String get yearHint;

  /// No description provided for @addExtraQualification.
  ///
  /// In en, this message translates to:
  /// **'Add Extra Qualification'**
  String get addExtraQualification;

  /// No description provided for @extraQualificationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Computer Course, Diploma'**
  String get extraQualificationHint;

  /// No description provided for @educationSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Education saved successfully'**
  String get educationSavedSuccessfully;

  /// No description provided for @saveEducation.
  ///
  /// In en, this message translates to:
  /// **'Save Education'**
  String get saveEducation;

  /// No description provided for @updateEducation.
  ///
  /// In en, this message translates to:
  /// **'Update Education'**
  String get updateEducation;

  /// No description provided for @familyDetails.
  ///
  /// In en, this message translates to:
  /// **'Family Details'**
  String get familyDetails;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Name'**
  String get fatherName;

  /// No description provided for @fatherNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your father\'s name'**
  String get fatherNameHint;

  /// No description provided for @motherName.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Name'**
  String get motherName;

  /// No description provided for @motherNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your mother\'s name'**
  String get motherNameHint;

  /// No description provided for @numberOfBrothers.
  ///
  /// In en, this message translates to:
  /// **'Number of Brothers'**
  String get numberOfBrothers;

  /// No description provided for @brothersHint.
  ///
  /// In en, this message translates to:
  /// **'Enter number of brothers'**
  String get brothersHint;

  /// No description provided for @numberOfSisters.
  ///
  /// In en, this message translates to:
  /// **'Number of Sisters'**
  String get numberOfSisters;

  /// No description provided for @sistersHint.
  ///
  /// In en, this message translates to:
  /// **'Enter number of sisters'**
  String get sistersHint;

  /// No description provided for @familyType.
  ///
  /// In en, this message translates to:
  /// **'Family Type'**
  String get familyType;

  /// No description provided for @selectFamilyType.
  ///
  /// In en, this message translates to:
  /// **'Please select a family type'**
  String get selectFamilyType;

  /// No description provided for @lifeStyleStatus.
  ///
  /// In en, this message translates to:
  /// **'LifeStyle Status'**
  String get lifeStyleStatus;

  /// No description provided for @selectLifeStyleStatus.
  ///
  /// In en, this message translates to:
  /// **'Please select a family status'**
  String get selectLifeStyleStatus;

  /// No description provided for @familyProfileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Family profile saved successfully!'**
  String get familyProfileSavedSuccessfully;

  /// No description provided for @saveFamily.
  ///
  /// In en, this message translates to:
  /// **'Save Family'**
  String get saveFamily;

  /// No description provided for @jointFamily.
  ///
  /// In en, this message translates to:
  /// **'Joint Family'**
  String get jointFamily;

  /// No description provided for @nuclearFamily.
  ///
  /// In en, this message translates to:
  /// **'Nuclear Family'**
  String get nuclearFamily;

  /// No description provided for @preferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotToSay;

  /// No description provided for @simpleLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Simple Lifestyle'**
  String get simpleLifestyle;

  /// No description provided for @moderateLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Moderate Lifestyle'**
  String get moderateLifestyle;

  /// No description provided for @comfortableLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Comfortable Lifestyle'**
  String get comfortableLifestyle;

  /// No description provided for @wellEstablishedLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Well-established Lifestyle'**
  String get wellEstablishedLifestyle;

  /// No description provided for @uploadProfileImages.
  ///
  /// In en, this message translates to:
  /// **'Upload Profile Images'**
  String get uploadProfileImages;

  /// No description provided for @pleaseSelectPrimaryImage.
  ///
  /// In en, this message translates to:
  /// **'Please select a primary profile image'**
  String get pleaseSelectPrimaryImage;

  /// No description provided for @pleaseSelectAadharPdf.
  ///
  /// In en, this message translates to:
  /// **'Please select Aadhar PDF'**
  String get pleaseSelectAadharPdf;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @employmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Employment Details'**
  String get employmentDetails;

  /// No description provided for @jobType.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get jobType;

  /// No description provided for @selectJobType.
  ///
  /// In en, this message translates to:
  /// **'Please select a job type'**
  String get selectJobType;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @government.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get government;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @defence.
  ///
  /// In en, this message translates to:
  /// **'Defence'**
  String get defence;

  /// No description provided for @selfEmployed.
  ///
  /// In en, this message translates to:
  /// **'Self Employed'**
  String get selfEmployed;

  /// No description provided for @notWorking.
  ///
  /// In en, this message translates to:
  /// **'Not Working'**
  String get notWorking;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @organizationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your organization name'**
  String get organizationHint;

  /// No description provided for @workLocation.
  ///
  /// In en, this message translates to:
  /// **'Work Location'**
  String get workLocation;

  /// No description provided for @workLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your work location'**
  String get workLocationHint;

  /// No description provided for @annualIncome.
  ///
  /// In en, this message translates to:
  /// **'Annual Income'**
  String get annualIncome;

  /// No description provided for @annualIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your annual income'**
  String get annualIncomeHint;

  /// No description provided for @employmentSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Employment profile saved successfully!'**
  String get employmentSavedSuccessfully;

  /// No description provided for @saveEmployment.
  ///
  /// In en, this message translates to:
  /// **'Save Employment'**
  String get saveEmployment;

  /// No description provided for @physicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Physical Details'**
  String get physicalDetails;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (in cm)'**
  String get heightCm;

  /// No description provided for @heightHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your height in centimeters'**
  String get heightHint;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (in kg)'**
  String get weightKg;

  /// No description provided for @weightHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your weight in kilograms'**
  String get weightHint;

  /// No description provided for @selectBodyType.
  ///
  /// In en, this message translates to:
  /// **'Please select a body type'**
  String get selectBodyType;

  /// No description provided for @slim.
  ///
  /// In en, this message translates to:
  /// **'Slim'**
  String get slim;

  /// No description provided for @athletic.
  ///
  /// In en, this message translates to:
  /// **'Athletic'**
  String get athletic;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @heavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get heavy;

  /// No description provided for @muscular.
  ///
  /// In en, this message translates to:
  /// **'Muscular'**
  String get muscular;

  /// No description provided for @obese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get obese;

  /// No description provided for @selectComplexion.
  ///
  /// In en, this message translates to:
  /// **'Please select a complexion'**
  String get selectComplexion;

  /// No description provided for @veryFair.
  ///
  /// In en, this message translates to:
  /// **'Very Fair'**
  String get veryFair;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @wheatish.
  ///
  /// In en, this message translates to:
  /// **'Wheatish'**
  String get wheatish;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @brown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get brown;

  /// No description provided for @dusky.
  ///
  /// In en, this message translates to:
  /// **'Dusky'**
  String get dusky;

  /// No description provided for @darkBrown.
  ///
  /// In en, this message translates to:
  /// **'Dark Brown'**
  String get darkBrown;

  /// No description provided for @blackComplexion.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get blackComplexion;

  /// No description provided for @physicallyChallenged.
  ///
  /// In en, this message translates to:
  /// **'Physically Challenged'**
  String get physicallyChallenged;

  /// No description provided for @disabilityDetails.
  ///
  /// In en, this message translates to:
  /// **'Disability Details'**
  String get disabilityDetails;

  /// No description provided for @disabilityDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Please specify details'**
  String get disabilityDetailsHint;

  /// No description provided for @physicalProfileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Physical profile saved successfully!'**
  String get physicalProfileSavedSuccessfully;

  /// No description provided for @physicalProfile.
  ///
  /// In en, this message translates to:
  /// **'Physical Profile'**
  String get physicalProfile;

  /// No description provided for @verifyYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Profile'**
  String get verifyYourProfile;

  /// No description provided for @confirmDetailsCorrect.
  ///
  /// In en, this message translates to:
  /// **'I confirm all details are correct'**
  String get confirmDetailsCorrect;

  /// No description provided for @finalSubmit.
  ///
  /// In en, this message translates to:
  /// **'FINAL SUBMIT'**
  String get finalSubmit;

  /// No description provided for @verifyCarefullyWarning.
  ///
  /// In en, this message translates to:
  /// **'Please verify carefully. Once submitted, profile cannot be edited.'**
  String get verifyCarefullyWarning;

  /// No description provided for @uploadingImages.
  ///
  /// In en, this message translates to:
  /// **'Uploading Images...'**
  String get uploadingImages;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @languagesKnown.
  ///
  /// In en, this message translates to:
  /// **'Languages Known'**
  String get languagesKnown;

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get enterEmailPassword;

  /// No description provided for @loginSuccessfulAgent.
  ///
  /// In en, this message translates to:
  /// **'Welcome Agent! Login successful.'**
  String get loginSuccessfulAgent;

  /// No description provided for @agentNotFound.
  ///
  /// In en, this message translates to:
  /// **'No agent account found with this email.'**
  String get agentNotFound;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get incorrectPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get invalidEmail;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get accountDisabled;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @termsAndConditionsFor.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions for'**
  String get termsAndConditionsFor;

  /// No description provided for @acceptanceTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get acceptanceTermsTitle;

  /// No description provided for @eligibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Eligibility'**
  String get eligibilityTitle;

  /// No description provided for @accountRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Account Registration'**
  String get accountRegistrationTitle;

  /// No description provided for @userConductTitle.
  ///
  /// In en, this message translates to:
  /// **'4. User Conduct'**
  String get userConductTitle;

  /// No description provided for @contentOwnershipTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Content Ownership and License'**
  String get contentOwnershipTitle;

  /// No description provided for @premiumServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Premium Services and Payments'**
  String get premiumServicesTitle;

  /// No description provided for @disclaimerWarrantiesTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Disclaimer of Warranties'**
  String get disclaimerWarrantiesTitle;

  /// No description provided for @limitationLiabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'8. Limitation of Liability'**
  String get limitationLiabilityTitle;

  /// No description provided for @indemnificationTitle.
  ///
  /// In en, this message translates to:
  /// **'9. Indemnification'**
  String get indemnificationTitle;

  /// No description provided for @changesTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'10. Changes to Terms'**
  String get changesTermsTitle;

  /// No description provided for @contactUsTitle.
  ///
  /// In en, this message translates to:
  /// **'12. Contact Us'**
  String get contactUsTitle;

  /// No description provided for @acceptanceTermsContent.
  ///
  /// In en, this message translates to:
  /// **'By accessing or using the platform, you agree to be bound by these Terms and Conditions and our Privacy Policy.'**
  String get acceptanceTermsContent;

  /// No description provided for @eligibilityContent.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old and of legal marriageable age as per the laws to register and use our services.'**
  String get eligibilityContent;

  /// No description provided for @accountRegistrationContent.
  ///
  /// In en, this message translates to:
  /// **'To use certain features, you must register for an account. You agree to provide accurate and complete information.'**
  String get accountRegistrationContent;

  /// No description provided for @userConductContent.
  ///
  /// In en, this message translates to:
  /// **'You agree to use the service only for lawful purposes and in a way that does not infringe the rights of others.'**
  String get userConductContent;

  /// No description provided for @contentOwnershipContent.
  ///
  /// In en, this message translates to:
  /// **'You retain all ownership rights to the content you submit. By submitting, you grant us a license to use it.'**
  String get contentOwnershipContent;

  /// No description provided for @premiumServicesContent.
  ///
  /// In en, this message translates to:
  /// **'We may offer premium services that require payment. All fees are non-refundable unless otherwise stated.'**
  String get premiumServicesContent;

  /// No description provided for @disclaimerWarrantiesContent.
  ///
  /// In en, this message translates to:
  /// **'The service is provided on an \"as is\" basis. We make no warranties, expressed or implied.'**
  String get disclaimerWarrantiesContent;

  /// No description provided for @limitationLiabilityContent.
  ///
  /// In en, this message translates to:
  /// **'In no event shall we be liable for any damages arising out of the use or inability to use the materials.'**
  String get limitationLiabilityContent;

  /// No description provided for @indemnificationContent.
  ///
  /// In en, this message translates to:
  /// **'You agree to indemnify and hold us harmless from any losses or costs relating to your use of the service.'**
  String get indemnificationContent;

  /// No description provided for @changesTermsContent.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to change these Terms at any time. Your continued use signifies acceptance.'**
  String get changesTermsContent;

  /// No description provided for @contactUsContent.
  ///
  /// In en, this message translates to:
  /// **'We welcome your questions or comments regarding these Terms.'**
  String get contactUsContent;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyFor.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy for'**
  String get privacyPolicyFor;

  /// No description provided for @introTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Introduction'**
  String get introTitle;

  /// No description provided for @infoCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Information We Collect'**
  String get infoCollectTitle;

  /// No description provided for @howUseInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'3. How We Use Your Information'**
  String get howUseInfoTitle;

  /// No description provided for @disclosureInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Disclosure of Your Information'**
  String get disclosureInfoTitle;

  /// No description provided for @securityDataTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Security of Your Data'**
  String get securityDataTitle;

  /// No description provided for @dataRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Your Data Protection Rights'**
  String get dataRightsTitle;

  /// No description provided for @linksOtherSitesTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Links to Other Sites'**
  String get linksOtherSitesTitle;

  /// No description provided for @childrenPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'8. Children\'s Privacy'**
  String get childrenPrivacyTitle;

  /// No description provided for @changesPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'9. Changes to This Privacy Policy'**
  String get changesPrivacyTitle;

  /// No description provided for @governingLawTitle.
  ///
  /// In en, this message translates to:
  /// **'10. Governing Law'**
  String get governingLawTitle;

  /// No description provided for @yourConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'11. Your Consent'**
  String get yourConsentTitle;

  /// No description provided for @grievanceOfficerTitle.
  ///
  /// In en, this message translates to:
  /// **'13. Grievance Officer'**
  String get grievanceOfficerTitle;

  /// No description provided for @introContent.
  ///
  /// In en, this message translates to:
  /// **'Welcome to our platform. We are committed to protecting your privacy and handling your data in an open and transparent manner.'**
  String get introContent;

  /// No description provided for @infoCollectContent.
  ///
  /// In en, this message translates to:
  /// **'We collect various types of information to provide and improve our services to you, including personal data, usage data, and communication records.'**
  String get infoCollectContent;

  /// No description provided for @howUseInfoContent.
  ///
  /// In en, this message translates to:
  /// **'We use the collected data to provide and maintain our service, create profiles, match you with others, and improve our platform.'**
  String get howUseInfoContent;

  /// No description provided for @disclosureInfoContent.
  ///
  /// In en, this message translates to:
  /// **'We may share your information with other users for matchmaking, with service providers, or for legal reasons when necessary.'**
  String get disclosureInfoContent;

  /// No description provided for @securityDataContent.
  ///
  /// In en, this message translates to:
  /// **'The security of your data is important to us, but remember that no method of transmission over the Internet is 100% secure.'**
  String get securityDataContent;

  /// No description provided for @dataRightsContent.
  ///
  /// In en, this message translates to:
  /// **'Depending on your location, you may have rights to access, update, or delete the information we have on you.'**
  String get dataRightsContent;

  /// No description provided for @linksOtherSitesContent.
  ///
  /// In en, this message translates to:
  /// **'Our service may contain links to other sites. We strongly advise you to review the Privacy Policy of every site you visit.'**
  String get linksOtherSitesContent;

  /// No description provided for @childrenPrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'Our service does not address anyone under the age of 18. We do not knowingly collect information from children.'**
  String get childrenPrivacyContent;

  /// No description provided for @changesPrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.'**
  String get changesPrivacyContent;

  /// No description provided for @governingLawContent.
  ///
  /// In en, this message translates to:
  /// **'These Terms shall be governed and construed in accordance with the laws of the country.'**
  String get governingLawContent;

  /// No description provided for @yourConsentContent.
  ///
  /// In en, this message translates to:
  /// **'By using our service, you hereby consent to our Privacy Policy and agree to its terms.'**
  String get yourConsentContent;

  /// No description provided for @grievanceOfficerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get grievanceOfficerNameLabel;

  /// No description provided for @grievanceOfficerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get grievanceOfficerEmailLabel;

  /// No description provided for @grievanceOfficerAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get grievanceOfficerAddressLabel;

  /// No description provided for @privacyImportantMessage.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your personal information.'**
  String get privacyImportantMessage;

  /// No description provided for @byContinuingAgree.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get byContinuingAgree;

  /// No description provided for @andLabel.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andLabel;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @regions.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get regions;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out Shaadi Milan! Find your perfect match here:'**
  String get shareMessage;

  /// No description provided for @shareSubject.
  ///
  /// In en, this message translates to:
  /// **'Download Shaadi Milan App'**
  String get shareSubject;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @hereToHelp.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help 💙'**
  String get hereToHelp;

  /// No description provided for @contactDescription.
  ///
  /// In en, this message translates to:
  /// **'Have questions, feedback, or need assistance?\\nReach out to us through any of the channels below.'**
  String get contactDescription;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @sendAMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a Message'**
  String get sendAMessage;

  /// No description provided for @getBackShortly.
  ///
  /// In en, this message translates to:
  /// **'We\'ll get back to you shortly'**
  String get getBackShortly;

  /// No description provided for @supportTeamAvailable.
  ///
  /// In en, this message translates to:
  /// **'Our support team is available'**
  String get supportTeamAvailable;

  /// No description provided for @agentOverview.
  ///
  /// In en, this message translates to:
  /// **'Agent Overview'**
  String get agentOverview;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// No description provided for @viewDocument.
  ///
  /// In en, this message translates to:
  /// **'View Document'**
  String get viewDocument;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @notApproved.
  ///
  /// In en, this message translates to:
  /// **'Not Approved'**
  String get notApproved;

  /// No description provided for @agentIs.
  ///
  /// In en, this message translates to:
  /// **'Agent is'**
  String get agentIs;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @designation.
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get designation;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @primaryImage.
  ///
  /// In en, this message translates to:
  /// **'Primary Image'**
  String get primaryImage;

  /// No description provided for @yesLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesLabel;

  /// No description provided for @noLabel.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noLabel;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @userDetails.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get userDetails;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @userType.
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userType;

  /// No description provided for @matrimonyInformation.
  ///
  /// In en, this message translates to:
  /// **'Matrimony Information'**
  String get matrimonyInformation;

  /// No description provided for @matrimonyId.
  ///
  /// In en, this message translates to:
  /// **'Matrimony Id'**
  String get matrimonyId;

  /// No description provided for @profileId.
  ///
  /// In en, this message translates to:
  /// **'Profile Id'**
  String get profileId;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last Seen'**
  String get lastSeen;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get notAssigned;

  /// No description provided for @userRole.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userRole;

  /// No description provided for @contactingUser.
  ///
  /// In en, this message translates to:
  /// **'Contacting {name}...'**
  String contactingUser(String name);

  /// No description provided for @mailingUser.
  ///
  /// In en, this message translates to:
  /// **'Mailing {name}...'**
  String mailingUser(String name);

  /// No description provided for @mail.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get mail;

  /// No description provided for @errorLoadingUser.
  ///
  /// In en, this message translates to:
  /// **'Error Loading User'**
  String get errorLoadingUser;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loadingUser.
  ///
  /// In en, this message translates to:
  /// **'Loading User...'**
  String get loadingUser;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get noPhone;

  /// No description provided for @sameAgent.
  ///
  /// In en, this message translates to:
  /// **'Same Agent'**
  String get sameAgent;

  /// No description provided for @contactAgent.
  ///
  /// In en, this message translates to:
  /// **'Contact Agent'**
  String get contactAgent;

  /// No description provided for @staffIdNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Staff Id not available for this user.'**
  String get staffIdNotAvailable;

  /// No description provided for @sameAgentMessage.
  ///
  /// In en, this message translates to:
  /// **'This user is registered under the same agent. No need to contact another agent for the matrimony process.'**
  String get sameAgentMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @agentDetails.
  ///
  /// In en, this message translates to:
  /// **'Agent Details'**
  String get agentDetails;

  /// No description provided for @failedToLoadAgentInfo.
  ///
  /// In en, this message translates to:
  /// **'Failed to load agent info'**
  String get failedToLoadAgentInfo;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @whatsappContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi, I am contacting you regarding a matrimony profile.'**
  String get whatsappContactMessage;

  /// No description provided for @statusContacted.
  ///
  /// In en, this message translates to:
  /// **'Contacted'**
  String get statusContacted;

  /// No description provided for @statusInterested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get statusInterested;

  /// No description provided for @statusNotInterested.
  ///
  /// In en, this message translates to:
  /// **'Not Interested'**
  String get statusNotInterested;

  /// No description provided for @searchClientsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone…'**
  String get searchClientsHint;

  /// No description provided for @noClientsFound.
  ///
  /// In en, this message translates to:
  /// **'No Clients Found'**
  String get noClientsFound;

  /// No description provided for @noMatchingClients.
  ///
  /// In en, this message translates to:
  /// **'No Matching Clients'**
  String get noMatchingClients;

  /// No description provided for @adjustFiltersToFind.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters to find what you\'re looking for.'**
  String get adjustFiltersToFind;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear All Filters'**
  String get clearAllFilters;

  /// No description provided for @errorLoadingClients.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Clients'**
  String get errorLoadingClients;

  /// No description provided for @matrimony.
  ///
  /// In en, this message translates to:
  /// **'Matrimony'**
  String get matrimony;

  /// No description provided for @profileCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Created'**
  String get profileCreatedLabel;

  /// No description provided for @profilePendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Pending'**
  String get profilePendingLabel;

  /// No description provided for @paymentPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get paymentPendingLabel;

  /// No description provided for @wishlistManagement.
  ///
  /// In en, this message translates to:
  /// **'Wishlist Management'**
  String get wishlistManagement;

  /// No description provided for @myUsersWishlists.
  ///
  /// In en, this message translates to:
  /// **'My Users\' Wishlists'**
  String get myUsersWishlists;

  /// No description provided for @leadsForMyUsers.
  ///
  /// In en, this message translates to:
  /// **'Leads for My Users'**
  String get leadsForMyUsers;

  /// No description provided for @noWishlistsFromClient.
  ///
  /// In en, this message translates to:
  /// **'No wishlists from your client'**
  String get noWishlistsFromClient;

  /// No description provided for @noLeadsForClient.
  ///
  /// In en, this message translates to:
  /// **'No leads for your client'**
  String get noLeadsForClient;

  /// No description provided for @outgoingInterest.
  ///
  /// In en, this message translates to:
  /// **'Outgoing Interest'**
  String get outgoingInterest;

  /// No description provided for @incomingLead.
  ///
  /// In en, this message translates to:
  /// **'Incoming Lead'**
  String get incomingLead;

  /// No description provided for @yourUser.
  ///
  /// In en, this message translates to:
  /// **'Your User'**
  String get yourUser;

  /// No description provided for @interestedIn.
  ///
  /// In en, this message translates to:
  /// **'Interested In'**
  String get interestedIn;

  /// No description provided for @interestedBy.
  ///
  /// In en, this message translates to:
  /// **'Interested By'**
  String get interestedBy;

  /// No description provided for @updatedAtWithParam.
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String updatedAtWithParam(String date);

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @errorLoadingUserWithId.
  ///
  /// In en, this message translates to:
  /// **'Error loading user: {userId}'**
  String errorLoadingUserWithId(String userId);

  /// No description provided for @userNotFoundWithId.
  ///
  /// In en, this message translates to:
  /// **'User not found: {userId}'**
  String userNotFoundWithId(String userId);

  /// No description provided for @statusUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Status updated to {status}'**
  String statusUpdatedTo(String status);

  /// No description provided for @failedToUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status: {error}'**
  String failedToUpdateStatus(String error);

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @cannotCloseProfileNoRegistrationPayment.
  ///
  /// In en, this message translates to:
  /// **'Cannot close profile: User has not completed registration payment.'**
  String get cannotCloseProfileNoRegistrationPayment;

  /// No description provided for @cannotCloseProfileNoAfterMarriagePayment.
  ///
  /// In en, this message translates to:
  /// **'Cannot close profile: No successful after-marriage payment found.'**
  String get cannotCloseProfileNoAfterMarriagePayment;

  /// No description provided for @profileClosedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile closed successfully'**
  String get profileClosedSuccessfully;

  /// No description provided for @failedToCloseProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to close profile: {error}'**
  String failedToCloseProfile(String error);

  /// No description provided for @closeMatrimonyProfile.
  ///
  /// In en, this message translates to:
  /// **'Close Matrimony Profile'**
  String get closeMatrimonyProfile;

  /// No description provided for @closeProfileConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close this matrimony profile?\n\nThis user will not appear in search or receive interests.'**
  String get closeProfileConfirmMessage;

  /// No description provided for @closeProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Close Profile'**
  String get closeProfileButton;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @matrimonyProfileTab.
  ///
  /// In en, this message translates to:
  /// **'Matrimony Profile'**
  String get matrimonyProfileTab;

  /// No description provided for @bioData.
  ///
  /// In en, this message translates to:
  /// **'Bio Data'**
  String get bioData;

  /// No description provided for @matrimonyProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Matrimony Profile Not Found'**
  String get matrimonyProfileNotFound;

  /// No description provided for @matrimonyProfileNotFoundContent.
  ///
  /// In en, this message translates to:
  /// **'This user has not created a matrimony profile yet.\n\nPlease ask the user to complete their profile setup through the app.'**
  String get matrimonyProfileNotFoundContent;

  /// No description provided for @matrimonyProfileNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Matrimony profile not available'**
  String get matrimonyProfileNotAvailable;

  /// No description provided for @matrimonyProfileNotCreatedYet.
  ///
  /// In en, this message translates to:
  /// **'Matrimony profile not created yet'**
  String get matrimonyProfileNotCreatedYet;

  /// No description provided for @identityInformation.
  ///
  /// In en, this message translates to:
  /// **'Identity Information'**
  String get identityInformation;

  /// No description provided for @physicalInformation.
  ///
  /// In en, this message translates to:
  /// **'Physical Information'**
  String get physicalInformation;

  /// No description provided for @bodyType.
  ///
  /// In en, this message translates to:
  /// **'Body Type'**
  String get bodyType;

  /// No description provided for @complexion.
  ///
  /// In en, this message translates to:
  /// **'Complexion'**
  String get complexion;

  /// No description provided for @culturalInformation.
  ///
  /// In en, this message translates to:
  /// **'Cultural Information'**
  String get culturalInformation;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @isIlliterate.
  ///
  /// In en, this message translates to:
  /// **'Is Illiterate'**
  String get isIlliterate;

  /// No description provided for @course.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get course;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @extraQualifications.
  ///
  /// In en, this message translates to:
  /// **'Extra Qualifications'**
  String get extraQualifications;

  /// No description provided for @familyInformation.
  ///
  /// In en, this message translates to:
  /// **'Family Information'**
  String get familyInformation;

  /// No description provided for @brothers.
  ///
  /// In en, this message translates to:
  /// **'Brothers'**
  String get brothers;

  /// No description provided for @sisters.
  ///
  /// In en, this message translates to:
  /// **'Sisters'**
  String get sisters;

  /// No description provided for @familyStatus.
  ///
  /// In en, this message translates to:
  /// **'Family Status'**
  String get familyStatus;

  /// No description provided for @agentInformation.
  ///
  /// In en, this message translates to:
  /// **'Agent Information'**
  String get agentInformation;

  /// No description provided for @agentName.
  ///
  /// In en, this message translates to:
  /// **'Agent Name'**
  String get agentName;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @matchProfiles.
  ///
  /// In en, this message translates to:
  /// **'Match Profiles'**
  String get matchProfiles;

  /// No description provided for @photosAndDocuments.
  ///
  /// In en, this message translates to:
  /// **'Photos & Documents'**
  String get photosAndDocuments;

  /// No description provided for @primaryPhoto.
  ///
  /// In en, this message translates to:
  /// **'Primary Photo'**
  String get primaryPhoto;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @photoWithAgent.
  ///
  /// In en, this message translates to:
  /// **'Photo with Agent'**
  String get photoWithAgent;

  /// No description provided for @aadharCard.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Card'**
  String get aadharCard;

  /// No description provided for @tapToViewFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Tap to view fullscreen'**
  String get tapToViewFullscreen;

  /// No description provided for @openPdf.
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get openPdf;

  /// No description provided for @matchingOptions.
  ///
  /// In en, this message translates to:
  /// **'Matching Options'**
  String get matchingOptions;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @noPaymentFound.
  ///
  /// In en, this message translates to:
  /// **'No Payment Found'**
  String get noPaymentFound;

  /// No description provided for @noPaymentsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'This user has not made any payments yet'**
  String get noPaymentsYetMessage;

  /// No description provided for @paymentInformation.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get paymentInformation;

  /// No description provided for @paymentId.
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get paymentId;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @razorpayOrderId.
  ///
  /// In en, this message translates to:
  /// **'Razorpay Order ID'**
  String get razorpayOrderId;

  /// No description provided for @paymentGateway.
  ///
  /// In en, this message translates to:
  /// **'Payment Gateway'**
  String get paymentGateway;

  /// No description provided for @clientInformation.
  ///
  /// In en, this message translates to:
  /// **'Client Information'**
  String get clientInformation;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @errorLoadingPayment.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Payment'**
  String get errorLoadingPayment;

  /// No description provided for @afterMarriagePayment.
  ///
  /// In en, this message translates to:
  /// **'After Marriage Payment'**
  String get afterMarriagePayment;

  /// No description provided for @noAfterMarriagePaymentFound.
  ///
  /// In en, this message translates to:
  /// **'No After Marriage Payment Found'**
  String get noAfterMarriagePaymentFound;

  /// No description provided for @errorLoadingAfterMarriagePayment.
  ///
  /// In en, this message translates to:
  /// **'Error loading after marriage payments'**
  String get errorLoadingAfterMarriagePayment;

  /// No description provided for @paymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get paymentType;

  /// No description provided for @afterMarriage.
  ///
  /// In en, this message translates to:
  /// **'After Marriage'**
  String get afterMarriage;

  /// No description provided for @notAvailableShort.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailableShort;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @loginFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Try again later.'**
  String get loginFailedTryAgain;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get emailAlreadyRegistered;

  /// No description provided for @phoneAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered.'**
  String get phoneAlreadyRegistered;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccessfully;

  /// No description provided for @accountAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get accountAlreadyExists;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get passwordTooWeak;

  /// No description provided for @errorCheckingStaffId.
  ///
  /// In en, this message translates to:
  /// **'Error checking Staff Id: {error}'**
  String errorCheckingStaffId(String error);

  /// No description provided for @staffIdNotExists.
  ///
  /// In en, this message translates to:
  /// **'Staff Id does not exist. Please check the ID or leave it blank.'**
  String get staffIdNotExists;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password: {error}'**
  String failedToChangePassword(String error);

  /// No description provided for @failedToSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email: {error}'**
  String failedToSendResetEmail(String error);

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get fullNameHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'1234 567 890'**
  String get phoneHint;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String yearsOld(int age);

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @idCards.
  ///
  /// In en, this message translates to:
  /// **'ID Cards'**
  String get idCards;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @noPhotosAvailable.
  ///
  /// In en, this message translates to:
  /// **'No additional photos available.'**
  String get noPhotosAvailable;

  /// No description provided for @aadharCardNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Aadhar card not uploaded.'**
  String get aadharCardNotUploaded;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescriptionAvailable;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get myReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviewsYet;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No description provided for @religiousAndAstrological.
  ///
  /// In en, this message translates to:
  /// **'Religious & Astrological'**
  String get religiousAndAstrological;

  /// No description provided for @qualificationsBilingual.
  ///
  /// In en, this message translates to:
  /// **'Qualifications (Hindi | English)'**
  String get qualificationsBilingual;

  /// No description provided for @languagesBilingual.
  ///
  /// In en, this message translates to:
  /// **'Languages (Hindi | English)'**
  String get languagesBilingual;

  /// No description provided for @addQualification.
  ///
  /// In en, this message translates to:
  /// **'Add Qualification'**
  String get addQualification;

  /// No description provided for @addLanguage.
  ///
  /// In en, this message translates to:
  /// **'Add Language'**
  String get addLanguage;

  /// No description provided for @basicInfoTab.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfoTab;

  /// No description provided for @personalDetailsTab.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetailsTab;

  /// No description provided for @educationCareerTab.
  ///
  /// In en, this message translates to:
  /// **'Education & Career'**
  String get educationCareerTab;

  /// No description provided for @familyCultureTab.
  ///
  /// In en, this message translates to:
  /// **'Family & Culture'**
  String get familyCultureTab;

  /// No description provided for @physical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physical;

  /// No description provided for @employment.
  ///
  /// In en, this message translates to:
  /// **'Employment'**
  String get employment;

  /// No description provided for @educationStatus.
  ///
  /// In en, this message translates to:
  /// **'Education Status'**
  String get educationStatus;

  /// No description provided for @additionalCourses.
  ///
  /// In en, this message translates to:
  /// **'Additional Courses'**
  String get additionalCourses;

  /// No description provided for @addToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Add to Wishlist'**
  String get addToWishlist;

  /// No description provided for @disability.
  ///
  /// In en, this message translates to:
  /// **'Disability'**
  String get disability;

  /// No description provided for @college.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get college;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @alreadyAddedToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Already added to wishlist!'**
  String get alreadyAddedToWishlist;

  /// No description provided for @addedToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist!'**
  String get addedToWishlist;

  /// No description provided for @wishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlistTitle;

  /// No description provided for @manageInterests.
  ///
  /// In en, this message translates to:
  /// **'Manage your interests'**
  String get manageInterests;

  /// No description provided for @myWishlist.
  ///
  /// In en, this message translates to:
  /// **'My Wishlist'**
  String get myWishlist;

  /// No description provided for @wishlistedMe.
  ///
  /// In en, this message translates to:
  /// **'Wishlisted Me'**
  String get wishlistedMe;

  /// No description provided for @emptyWishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty!'**
  String get emptyWishlistTitle;

  /// No description provided for @emptyWishlistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding profiles to your wishlist to see them here.'**
  String get emptyWishlistSubtitle;

  /// No description provided for @noOneWishlistedMeTitle.
  ///
  /// In en, this message translates to:
  /// **'No one has wishlisted you yet!'**
  String get noOneWishlistedMeTitle;

  /// No description provided for @noOneWishlistedMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone adds you to their wishlist, you\'ll see them here.'**
  String get noOneWishlistedMeSubtitle;

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get couldNotLoadProfile;

  /// No description provided for @noAgentAssociated.
  ///
  /// In en, this message translates to:
  /// **'No agent associated with this user.'**
  String get noAgentAssociated;

  /// No description provided for @userStatus.
  ///
  /// In en, this message translates to:
  /// **'User Status'**
  String get userStatus;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @manageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage your account'**
  String get manageAccount;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get premiumActive;

  /// No description provided for @premiumMemberMessage.
  ///
  /// In en, this message translates to:
  /// **'You are a Premium Member!'**
  String get premiumMemberMessage;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @noAgentAssigned.
  ///
  /// In en, this message translates to:
  /// **'No agent assigned yet.'**
  String get noAgentAssigned;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @postMarriagePayment.
  ///
  /// In en, this message translates to:
  /// **'Post Marriage Payment'**
  String get postMarriagePayment;

  /// No description provided for @trustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust Score'**
  String get trustScore;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumUpgradeBenefits.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited access to all features and connect with more matches.'**
  String get premiumUpgradeBenefits;

  /// No description provided for @agentSetup.
  ///
  /// In en, this message translates to:
  /// **'Agent Setup'**
  String get agentSetup;

  /// No description provided for @enterStaffId.
  ///
  /// In en, this message translates to:
  /// **'Enter Staff Id'**
  String get enterStaffId;

  /// No description provided for @pleaseEnterStaffId.
  ///
  /// In en, this message translates to:
  /// **'Please enter Staff Id'**
  String get pleaseEnterStaffId;

  /// No description provided for @agentAssignedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Agent {id} assigned successfully!'**
  String agentAssignedSuccessfully(String id);

  /// No description provided for @agentSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Assign an agent to your profile to get personalized assistance and faster service.'**
  String get agentSetupDescription;

  /// No description provided for @staffIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Staff Id (e.g., AGT-12345)'**
  String get staffIdHint;

  /// No description provided for @agentDetailsHeader.
  ///
  /// In en, this message translates to:
  /// **'Agent Details:'**
  String get agentDetailsHeader;

  /// No description provided for @assignAgent.
  ///
  /// In en, this message translates to:
  /// **'Assign Agent'**
  String get assignAgent;

  /// No description provided for @noStaffIdSupport.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t have an Staff Id, you can contact our support team for assistance.'**
  String get noStaffIdSupport;

  /// No description provided for @enterMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your message'**
  String get enterMessageHint;

  /// No description provided for @supportRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your request has been submitted. Our team will contact you shortly.'**
  String get supportRequestSubmitted;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @viewManageTickets.
  ///
  /// In en, this message translates to:
  /// **'View and manage your tickets'**
  String get viewManageTickets;

  /// No description provided for @newTicket.
  ///
  /// In en, this message translates to:
  /// **'New Ticket'**
  String get newTicket;

  /// No description provided for @noSupportTickets.
  ///
  /// In en, this message translates to:
  /// **'No Support Tickets'**
  String get noSupportTickets;

  /// No description provided for @createTicketHelp.
  ///
  /// In en, this message translates to:
  /// **'Create a ticket to get help from our support team'**
  String get createTicketHelp;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @createSupportTicket.
  ///
  /// In en, this message translates to:
  /// **'Create Support Ticket'**
  String get createSupportTicket;

  /// No description provided for @wereHereToHelp.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help!'**
  String get wereHereToHelp;

  /// No description provided for @supportFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your issue and we\'ll get back to you soon.'**
  String get supportFormSubtitle;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @pleaseEnterSubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get pleaseEnterSubject;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @ticketCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ticket created successfully!'**
  String get ticketCreatedSuccess;

  /// No description provided for @catAccountIssues.
  ///
  /// In en, this message translates to:
  /// **'Account Issues'**
  String get catAccountIssues;

  /// No description provided for @catPaymentProblems.
  ///
  /// In en, this message translates to:
  /// **'Payment Problems'**
  String get catPaymentProblems;

  /// No description provided for @catProfileIssues.
  ///
  /// In en, this message translates to:
  /// **'Profile Issues'**
  String get catProfileIssues;

  /// No description provided for @catTechSupport.
  ///
  /// In en, this message translates to:
  /// **'Technical Support'**
  String get catTechSupport;

  /// No description provided for @catFeatureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get catFeatureRequest;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @ticketDetails.
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get ticketDetails;

  /// No description provided for @ticketInformation.
  ///
  /// In en, this message translates to:
  /// **'Ticket Information'**
  String get ticketInformation;

  /// No description provided for @adminResponse.
  ///
  /// In en, this message translates to:
  /// **'Admin Response'**
  String get adminResponse;

  /// No description provided for @ticketHash.
  ///
  /// In en, this message translates to:
  /// **'Ticket #'**
  String get ticketHash;

  /// No description provided for @writeAReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeAReview;

  /// No description provided for @pleaseSelectRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get pleaseSelectRating;

  /// No description provided for @reviewSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully!'**
  String get reviewSubmittedSuccess;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Title'**
  String get reviewTitle;

  /// No description provided for @reviewTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a title for your review'**
  String get reviewTitleHint;

  /// No description provided for @reviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Review Description'**
  String get reviewDescription;

  /// No description provided for @reviewDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Write your detailed review here'**
  String get reviewDescriptionHint;

  /// No description provided for @titleCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty'**
  String get titleCannotBeEmpty;

  /// No description provided for @descriptionCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Description cannot be empty'**
  String get descriptionCannotBeEmpty;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @noAgentReviewError.
  ///
  /// In en, this message translates to:
  /// **'You can\'t write a review without an agent'**
  String get noAgentReviewError;

  /// No description provided for @whatUsersSay.
  ///
  /// In en, this message translates to:
  /// **'What our users say about us'**
  String get whatUsersSay;

  /// No description provided for @happyCustomersMessage.
  ///
  /// In en, this message translates to:
  /// **'Read genuine reviews from our happy customers.'**
  String get happyCustomersMessage;

  /// No description provided for @beTheFirstReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to leave a review!'**
  String get beTheFirstReview;

  /// No description provided for @reviewDetails.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get reviewDetails;

  /// No description provided for @reviewedOn.
  ///
  /// In en, this message translates to:
  /// **'Reviewed on {date}'**
  String reviewedOn(String date);

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @accountVerification.
  ///
  /// In en, this message translates to:
  /// **'Account Verification'**
  String get accountVerification;

  /// No description provided for @accountUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Your account is currently under review. Please wait for verification.'**
  String get accountUnderReview;

  /// No description provided for @profileUpdate.
  ///
  /// In en, this message translates to:
  /// **'Profile Update'**
  String get profileUpdate;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your profile has been successfully updated.'**
  String get profileUpdateSuccess;

  /// No description provided for @newMatchFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'New Match Found!'**
  String get newMatchFoundTitle;

  /// No description provided for @newMatchFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We found a new match for you. Check it out!'**
  String get newMatchFoundSubtitle;

  /// No description provided for @newMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessageTitle;

  /// No description provided for @newMessageFrom.
  ///
  /// In en, this message translates to:
  /// **'You have a new message from {name}.'**
  String newMessageFrom(String name);

  /// No description provided for @paymentReminder.
  ///
  /// In en, this message translates to:
  /// **'Payment Reminder'**
  String get paymentReminder;

  /// No description provided for @subscriptionRenewalDue.
  ///
  /// In en, this message translates to:
  /// **'Your subscription renewal is due soon.'**
  String get subscriptionRenewalDue;

  /// No description provided for @contactAdminDetails.
  ///
  /// In en, this message translates to:
  /// **'Please contact the administrator for more details.'**
  String get contactAdminDetails;

  /// No description provided for @uploadBioData.
  ///
  /// In en, this message translates to:
  /// **'Upload Biodata (Photo, PDF, or Document)'**
  String get uploadBioData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
