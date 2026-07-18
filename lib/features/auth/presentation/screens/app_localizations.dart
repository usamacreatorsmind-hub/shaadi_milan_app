// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:intl/intl.dart' as intl;
//
// import 'app_localizations_en.dart';
// import 'app_localizations_hi.dart';
//
// abstract class AppLocalizations {
//   AppLocalizations(String locale)
//     : localeName = intl.Intl.canonicalizedLocale(locale.toString());
//
//   final String localeName;
//
//   static AppLocalizations? of(BuildContext context) {
//     return Localizations.of<AppLocalizations>(context, AppLocalizations);
//   }
//
//   static const LocalizationsDelegate<AppLocalizations> delegate =
//       _AppLocalizationsDelegate();
//
//   static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
//       <LocalizationsDelegate<dynamic>>[
//         delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//       ];
//
//   static const List<Locale> supportedLocales = <Locale>[
//     Locale('en'),
//     Locale('hi'),
//   ];
//
//   String  get next;
//
//
//   String get appName;
//   String get welcomeMessage;
//   String get somethingWentWrong;
//   String get errorOccurred;
//   String get noInternet;
//   String get serverError;
//
//   // App Info
//   String get appTagline;
//   String get splashTagline;
//   String get copyright;
//
//   // App Content
//   String get missionTitle;
//   String get missionContent;
//   String get offerTitle;
//   String get offerContent;
//   String get valuesTitle;
//   String get valuesContent;
//   String get whyChooseUsTitle;
//   String get whyChooseUsContent;
//   String get thankYouMessage;
//
//   // About Us
//   String get aboutUs;
//   String get whoWeAre;
//   String get whoWeAreDescription;
//   String get madeWithLove;
//
//   // UI Labels
//   String get dashboard;
//   String get myClients;
//   String get analytics;
//   String get supportTickets;
//   String get documents;
//   String get settings;
//   String get myProfile;
//   String get document;
//   String get agentIdLabel;
//
//   // Nav Labels
//   String get navHome;
//   String get navWishlist;
//   String get navSupport;
//   String get navProfile;
//   String get navDashboard;
//   String get navClients;
//   String get navRevenue;
//
//   // Common Labels
//   String get welcome;
//   String get welcomeSubtitle;
//   String get emailAddress;
//   String get dontHaveAccount;
//   String get createNewProfile;
//   String get loading;
//   String get quickActions;
//   String get recentClients;
//   String get viewAll;
//   String get totalClients;
//   String get noUserData;
//   String get mainSection;
//   String get notifications;
//   String get legalAndInfo;
//   String get helpAndSupport;
//   String get shareApp;
//   String get shareMessage;
//   String get shareSubject;
//   String get rateUs;
//   String get logout;
//   String get logoutConfirm;
//   String get cancel;
//   String get back;
//   String get reports;
//   String get support;
//   String get contactUs;
//   String get hereToHelp;
//   String get contactDescription;
//   String get emailUs;
//   String get callUs;
//   String get whatsapp;
//   String get sendAMessage;
//   String get getBackShortly;
//   String get supportTeamAvailable;
//   String get noClientsYet;
//
//   // Home Labels
//   String get home;
//   String get homeSubtitle;
//   String get allProfiles;
//   String get welcomeLabel;
//   String get showingFiltered;
//   String get showingAllMatches;
//   String get filterProfiles;
//   String get applyFilters;
//   String get reset;
//   String get filter;
//   String get filters;
//   String get active;
//   String get religionAndCaste;
//   String get scope;
//   String get myClientsOnly;
//   String get assignedToYouOnly;
//   String get allAgents;
//   String get payment;
//   String get notStarted;
//   String get closed;
//   String get matrimonyProfile;
//   String get notCreated;
//   String get apply;
//   String get filterRevenue;
//   String get filterClients;
//   String get dateRange;
//   String get startDate;
//   String get endDate;
//   String get selectState;
//   String get allStates;
//   String get selectCityDistrict;
//   String get allCities;
//   String get cityDistrict;
//   String get selectReligion;
//   String get allReligions;
//   String get selectCaste;
//   String get allCastes;
//   String get couldNotLoadLocations;
//   String get couldNotLoadReligions;
//   String get noMessage;
//   String get statusUpdated;
//   String get completeProfileTitle;
//   String get completeProfileMessage;
//   String get completeProfileButton;
//   String get noProfilesFound;
//   String get viewProfile;
//   String get resetFilters;
//   String get ageYrs;
//   String get userNotFound;
//   String get location;
//   String get state;
//   String get city;
//   String get cultural;
//   String get religion;
//   String get caste;
//   String get profileStatus;
//   String get gender;
//   String get male;
//   String get female;
//   String get both;
//   String get all;
//   String get paid;
//   String get created;
//
//   // Dialogs & Messages
//   String get updateRequiredTitle;
//   String get updateRequiredMessage;
//   String get updateNowButton;
//   String get maintenanceModeTitle;
//   String get maintenanceModeSubtitle;
//   String get maintenanceModeMessage;
//   String get maintenanceRestoringMessage;
//   String get pleaseWait;
//   String get searchHint;
//   String get searchHintFull;
//   String get searchLabel;
//   String get noImagesToDisplay;
//
//   // Form Labels
//   String get words;
//   String get characters;
//   String get pleaseEnter;
//   String get select;
//
//   // Validation Labels
//   String get emailRequired;
//   String get passwordRequired;
//   String get passwordTooShort;
//   String get passwordUppercase;
//   String get passwordLowercase;
//   String get passwordNumber;
//   String get passwordSpecial;
//   String get confirmPasswordRequired;
//   String get confirmPassword;
//   String get passwordsDoNotMatch;
//   String get nameRequired;
//   String get nameTooShort;
//   String get phoneRequired;
//   String get invalidPhone;
//   String get ageRequired;
//   String get invalidAge;
//   String get pinCodeRequired;
//   String get invalidPinCode;
//   String get heightRequired;
//   String get invalidHeight;
//   String get weightRequired;
//   String get invalidWeight;
//   String get aadharRequired;
//   String get invalidAadhar;
//   String get isRequired;
//   String get mustBeNumber;
//
//   // Profile Labels
//   String get height;
//   String get education;
//   String get occupation;
//   String get about;
//   String get details;
//   String get tapToViewDetails;
//   String get profile;
//   String get result;
//   String get matches;
//
//   // Revenue Dashboard
//   String get revenueDashboard;
//   String get overview;
//   String get trends;
//   String get regions;
//   String get transactions;
//   String get totalRevenue;
//   String get todayRevenue;
//   String get yourCommission;
//   String get paymentStatus;
//   String get success;
//   String get pending;
//   String get failed;
//   String get revenueByGender;
//   String get revenueByReligion;
//   String get revenueByCaste;
//   String get dailyRevenueTrend;
//   String get regionRevenueDistribution;
//   String get noTransactionsFound;
//   String get commission;
//
//   // Premium / Payment
//   String get goPremium;
//   String get premiumSubtitle;
//   String get mostPopular;
//   String get payOnceUnlockPremium;
//   String get securePaymentNote;
//   String get pleaseSubscribe;
//
//   // Auth Labels
//   String get staffLogin;
//   String get accessStaffPortal;
//   String get staffPortal;
//   String get manageLeadsSubtitle;
//   String get memberPortal;
//   String get findSoulmateSubtitle;
//   String get verifiedProfiles;
//   String get needHelpContactUs;
//   String get workEmail;
//   String get workEmailHint;
//   String get passwordHint;
//   String get loggingIn;
//   String get forgotPassword;
//   String get notAStaffMember;
//   String get userLogin;
//   String get createAccount;
//   String get joinToday;
//   String get fullName;
//   String get email;
//   String get phone;
//   String get staffId;
//   String get optional;
//   String get registering;
//   String get register;
//   String get alreadyAMember;
//   String get loginNow;
//   String get loginSuccessful;
//   String get fillAllFields;
//
//   // Reset & Change Password
//   String get resetPassword;
//   String get resetPasswordSubtitle;
//   String get sendResetLink;
//   String get resetLinkSent;
//   String get userNotFoundWithEmail;
//   String get unableToSendResetLink;
//   String get changePassword;
//   String get backToLogin;
//   String get updateYourPassword;
//   String get changePasswordSubtitle;
//   String get currentPassword;
//   String get newPassword;
//   String get confirmNewPassword;
//   String get passwordChangedSuccessfully;
//   String get reauthenticateForSecurity;
//   String get incorrectCurrentPassword;
//   String get weakNewPassword;
//   String get mustBeLoggedInToReset;
//   String get forgotPasswordResetViaEmail;
//   String resetEmailSentTo(String email);
//
//   // Identity Form
//   String get createIdentity;
//   String get editIdentity;
//   String get aboutMe;
//   String get tellUsAboutYourself;
//   String get aadharNumber;
//   String get enterAadharNumber;
//   String get selectDateOfBirth;
//   String get selectDobHelp;
//   String get selectDobConfirm;
//   String get pleaseSelectDob;
//   String get mustBe18;
//   String get notEligibleUnder18;
//   String get identitySavedSuccessfully;
//   String get saveIdentity;
//   String get updateIdentity;
//   String get genderNotFound;
//   String errorFetchingUserData(String error);
//   String ageYears(int age);
//   String dobValue(String date);
//
//   // Address Form
//   String get addressDetails;
//   String get place;
//   String get placeHint;
//   String get post;
//   String get postHint;
//   String get policeStation;
//   String get policeStationHint;
//   String get pinCode;
//   String get pinCodeHint;
//   String get addressSavedSuccessfully;
//   String get saveAddress;
//   String get district;
//   String get selectDistrict;
//   String get selectStateHelp;
//
//   // Cultural Form
//   String get addCulturalDetails;
//   String get editCulturalDetails;
//   String get specifyCaste;
//   String get specifyCasteHint;
//   String get subCaste;
//   String get subCasteHint;
//   String get additionalQualifications;
//   String get addKnownLanguages;
//   String get languagesHint;
//   String get culturalDetailsSavedSuccessfully;
//   String get pleaseSelectReligion;
//   String get pleaseSelectCaste;
//
//   // Education Form
//   String get educationDetails;
//   String get editEducation;
//   String get literate;
//   String get illiterate;
//   String get highestQualification;
//   String get collegeUniversity;
//   String get collegeHint;
//   String get degreeCourse;
//   String get degreeHint;
//   String get percentageCGPA;
//   String get percentageHint;
//   String get passingYear;
//   String get yearHint;
//   String get addExtraQualification;
//   String get extraQualificationHint;
//   String get educationSavedSuccessfully;
//   String get saveEducation;
//   String get updateEducation;
//
//   // Family Form
//   String get familyDetails;
//   String get fatherName;
//   String get fatherNameHint;
//   String get motherName;
//   String get motherNameHint;
//   String get numberOfBrothers;
//   String get brothersHint;
//   String get numberOfSisters;
//   String get sistersHint;
//   String get familyType;
//   String get selectFamilyType;
//   String get lifeStyleStatus;
//   String get selectLifeStyleStatus;
//   String get familyProfileSavedSuccessfully;
//   String get saveFamily;
//   String get jointFamily;
//   String get nuclearFamily;
//   String get preferNotToSay;
//   String get simpleLifestyle;
//   String get moderateLifestyle;
//   String get comfortableLifestyle;
//   String get wellEstablishedLifestyle;
//
//   // Image Form
//   String get uploadProfileImages;
//   String get pleaseSelectPrimaryImage;
//   String get pleaseSelectAadharPdf;
//   String get continueButton;
//
//   // Employment Form
//   String get employmentDetails;
//   String get jobType;
//   String get selectJobType;
//   String get private;
//   String get government;
//   String get business;
//   String get defence;
//   String get selfEmployed;
//   String get notWorking;
//   String get organization;
//   String get organizationHint;
//   String get workLocation;
//   String get workLocationHint;
//   String get annualIncome;
//   String get annualIncomeHint;
//   String get employmentSavedSuccessfully;
//   String get saveEmployment;
//
//   // Physical Form
//   String get physicalDetails;
//   String get heightCm;
//   String get heightHint;
//   String get weightKg;
//   String get weightHint;
//   String get selectBodyType;
//   String get slim;
//   String get athletic;
//   String get average;
//   String get heavy;
//   String get muscular;
//   String get obese;
//   String get selectComplexion;
//   String get veryFair;
//   String get fair;
//   String get wheatish;
//   String get dark;
//   String get brown;
//   String get dusky;
//   String get darkBrown;
//   String get blackComplexion;
//   String get physicallyChallenged;
//   String get disabilityDetails;
//   String get disabilityDetailsHint;
//   String get physicalProfileSavedSuccessfully;
//   String get physicalProfile;
//
//   // Verify Profile
//   String get verifyYourProfile;
//   String get confirmDetailsCorrect;
//   String get finalSubmit;
//   String get verifyCarefullyWarning;
//   String get uploadingImages;
//   String get role;
//   String get languagesKnown;
//   String get enterEmailPassword;
//   String get loginSuccessfulAgent;
//   String get agentNotFound;
//   String get incorrectPassword;
//   String get invalidEmail;
//   String get accountDisabled;
//   String get termsAndConditions;
//   String get termsAndConditionsFor;
//   String get acceptanceTermsTitle;
//   String get eligibilityTitle;
//   String get accountRegistrationTitle;
//   String get userConductTitle;
//   String get contentOwnershipTitle;
//   String get premiumServicesTitle;
//   String get disclaimerWarrantiesTitle;
//   String get limitationLiabilityTitle;
//   String get indemnificationTitle;
//   String get changesTermsTitle;
//   String get contactUsTitle;
//   String get acceptanceTermsContent;
//   String get eligibilityContent;
//   String get accountRegistrationContent;
//   String get userConductContent;
//   String get contentOwnershipContent;
//   String get premiumServicesContent;
//   String get disclaimerWarrantiesContent;
//   String get limitationLiabilityContent;
//   String get indemnificationContent;
//   String get changesTermsContent;
//   String get contactUsContent;
//   String get privacyPolicy;
//   String get privacyPolicyFor;
//   String get introTitle;
//   String get infoCollectTitle;
//   String get howUseInfoTitle;
//   String get disclosureInfoTitle;
//   String get securityDataTitle;
//   String get dataRightsTitle;
//   String get linksOtherSitesTitle;
//   String get childrenPrivacyTitle;
//   String get changesPrivacyTitle;
//   String get governingLawTitle;
//   String get yourConsentTitle;
//   String get grievanceOfficerTitle;
//   String get introContent;
//   String get infoCollectContent;
//   String get howUseInfoContent;
//   String get disclosureInfoContent;
//   String get securityDataContent;
//   String get dataRightsContent;
//   String get linksOtherSitesContent;
//   String get childrenPrivacyContent;
//   String get changesPrivacyContent;
//   String get governingLawContent;
//   String get yourConsentContent;
//   String get grievanceOfficerNameLabel;
//   String get grievanceOfficerEmailLabel;
//   String get grievanceOfficerAddressLabel;
//   String get privacyImportantMessage;
//   String get byContinuingAgree;
//   String get andLabel;
//
//   // After Marriage
//   String get happyMarriage;
//   String get marriageCongratulations;
//   String get successFee;
//   String get paySuccessFee;
//   String get login;
//   String get password;
//
//   // Image Picker
//   String get profileImage;
//   String get matrimonyImage;
//   String get imageWithAgent;
//   String get galleryImages;
//   String get aadharDocument;
//   String get cropImage;
//   String get camera;
//   String get gallery;
//   String get profileImageRequired;
//   String get primaryImageRequired;
//   String get imageWithAgentRequired;
//   String get atLeastOneGalleryImageRequired;
//   String get aadharDocumentRequired;
//
//   String get agentOverview;
//   String get mobile;
//   String get pincode;
//   String get viewDocument;
//   String get contactInformation;
//   String get approved;
//   String get notApproved;
//   String get agentIs;
//   String get media;
//   String get contact;
//   String get status;
//   String get call;
//   String get designation;
//
//   String get pleaseSelect;
// }
//
// class _AppLocalizationsDelegate
//     extends LocalizationsDelegate<AppLocalizations> {
//   const _AppLocalizationsDelegate();
//
//   @override
//   Future<AppLocalizations> load(Locale locale) {
//     return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
//   }
//
//   @override
//   bool isSupported(Locale locale) =>
//       <String>['en', 'hi'].contains(locale.languageCode);
//
//   @override
//   bool shouldReload(_AppLocalizationsDelegate old) => false;
// }
//
// AppLocalizations lookupAppLocalizations(Locale locale) {
//   switch (locale.languageCode) {
//     case 'en':
//       return AppLocalizationsEn();
//     case 'hi':
//       return AppLocalizationsHi();
//   }
//
//   throw FlutterError(
//     'AppLocalizations.delegate failed to load unsupported locale "$locale".',
//   );
// }
