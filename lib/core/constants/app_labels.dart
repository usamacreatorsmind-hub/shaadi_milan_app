import 'package:flutter/material.dart';
import '../../features/l10n/app_localizations.dart';
import '../../features/l10n/app_localizations_en.dart';

/// Central place to manage all localized UI labels.
class AppLabels {
  AppLabels._();

  /// Helper to safely get localizations or fallback to English if context is outside MaterialApp
  static AppLocalizations _loc(BuildContext context) =>
      AppLocalizations.of(context) ?? AppLocalizationsEn();

  // ─── App Info ───────────────────────────────────────────────────────────────
  static String appName(BuildContext context) => _loc(context).appName;
  static String appTagline(BuildContext context) => _loc(context).appTagline;
  static String splashTagline(BuildContext context) => _loc(context).splashTagline;
  static String copyright(BuildContext context) => _loc(context).copyright;

  // ─── App Content ────────────────────────────────────────────────────────────
  static String missionTitle(BuildContext context) => _loc(context).missionTitle;
  static String missionContent(BuildContext context) => _loc(context).missionContent;
  static String offerTitle(BuildContext context) => _loc(context).offerTitle;
  static String offerContent(BuildContext context) => _loc(context).offerContent;
  static String valuesTitle(BuildContext context) => _loc(context).valuesTitle;
  static String valuesContent(BuildContext context) => _loc(context).valuesContent;
  static String whyChooseUsTitle(BuildContext context) => _loc(context).whyChooseUsTitle;
  static String whyChooseUsContent(BuildContext context) => _loc(context).whyChooseUsContent;
  static String thankYouMessage(BuildContext context) => _loc(context).thankYouMessage;

  // ─── UI Labels ──────────────────────────────────────────────────────────────
  static String dashboard(BuildContext context) => _loc(context).dashboard;
  static String myClients(BuildContext context) => _loc(context).myClients;
  static String analytics(BuildContext context) => _loc(context).analytics;
  static String supportTickets(BuildContext context) => _loc(context).supportTickets;
  static String documents(BuildContext context) => _loc(context).documents;
  static String settings(BuildContext context) => _loc(context).settings;
  static String myProfile(BuildContext context) => _loc(context).myProfile;
  static String document(BuildContext context) => _loc(context).document;
  static String agentIdLabel(BuildContext context) => _loc(context).agentIdLabel;

  // ─── Nav Labels ─────────────────────────────────────────────────────────────
  static String navHome(BuildContext context) => _loc(context).navHome;
  static String navWishlist(BuildContext context) => _loc(context).navWishlist;
  static String navSupport(BuildContext context) => _loc(context).navSupport;
  static String navProfile(BuildContext context) => _loc(context).navProfile;
  static String navDashboard(BuildContext context) => _loc(context).navDashboard;
  static String navClients(BuildContext context) => _loc(context).navClients;
  static String navRevenue(BuildContext context) => _loc(context).navRevenue;

  // ─── Agent Dashboard Labels ─────────────────────────────────────────────────
  static String dashboardTitle(BuildContext context) => _loc(context).dashboard;
  static String welcome(BuildContext context) => _loc(context).welcome;
  static String welcomeSubtitle(BuildContext context) => _loc(context).welcomeSubtitle;
  static String emailAddress(BuildContext context) => _loc(context).emailAddress;
  static String dontHaveAccount(BuildContext context) => _loc(context).dontHaveAccount;
  static String createNewProfile(BuildContext context) => _loc(context).createNewProfile;
  static String loading(BuildContext context) => _loc(context).loading;
  static String quickActions(BuildContext context) => _loc(context).quickActions;
  static String recentClients(BuildContext context) => _loc(context).recentClients;
  static String viewAll(BuildContext context) => _loc(context).viewAll;
  static String totalRevenue(BuildContext context) => _loc(context).totalRevenue;
  static String totalCommission(BuildContext context) => _loc(context).commission;
  static String totalClients(BuildContext context) => _loc(context).totalClients;
  static String success(BuildContext context) => _loc(context).success;
  static String pending(BuildContext context) => _loc(context).pending;
  static String logout(BuildContext context) => _loc(context).logout;
  static String logoutConfirm(BuildContext context) => _loc(context).logoutConfirm;
  static String cancel(BuildContext context) => _loc(context).cancel;
  static String back(BuildContext context) => _loc(context).back;
  static String reports(BuildContext context) => _loc(context).reports;
  static String support(BuildContext context) => _loc(context).support;
  static String revenueDashboard(BuildContext context) => _loc(context).revenueDashboard;
  static String overview(BuildContext context) => _loc(context).overview;
  static String trends(BuildContext context) => _loc(context).trends;
  static String regions(BuildContext context) => _loc(context).regions;
  static String transactions(BuildContext context) => _loc(context).transactions;
  static String contactUs(BuildContext context) => _loc(context).contactUs;
  static String hereToHelp(BuildContext context) => _loc(context).hereToHelp;
  static String contactDescription(BuildContext context) => _loc(context).contactDescription;
  static String emailUs(BuildContext context) => _loc(context).emailUs;
  static String callUs(BuildContext context) => _loc(context).callUs;
  static String whatsapp(BuildContext context) => _loc(context).whatsapp;
  static String sendAMessage(BuildContext context) => _loc(context).sendAMessage;
  static String getBackShortly(BuildContext context) => _loc(context).getBackShortly;
  static String supportTeamAvailable(BuildContext context) => _loc(context).supportTeamAvailable;
  static String noClientsYet(BuildContext context) => _loc(context).noClientsYet;

  // ─── Home Labels ────────────────────────────────────────────────────────────
  static String home(BuildContext context) => _loc(context).home;
  static String homeSubtitle(BuildContext context) => _loc(context).homeSubtitle;
  static String allProfiles(BuildContext context) => _loc(context).allProfiles;
  static String welcomeLabel(BuildContext context) => _loc(context).welcomeLabel;
  static String showingFiltered(BuildContext context) => _loc(context).showingFiltered;
  static String showingAllMatches(BuildContext context) => _loc(context).showingAllMatches;
  static String filterProfiles(BuildContext context) => _loc(context).filterProfiles;
  static String applyFilters(BuildContext context) => _loc(context).applyFilters;
  static String reset(BuildContext context) => _loc(context).reset;
  static String filter(BuildContext context) => _loc(context).filter;
  static String filters(BuildContext context) => _loc(context).filters;
  static String active(BuildContext context) => _loc(context).active;
  static String religionAndCaste(BuildContext context) => _loc(context).religionAndCaste;
  static String scope(BuildContext context) => _loc(context).scope;
  static String myClientsOnly(BuildContext context) => _loc(context).myClientsOnly;
  static String assignedToYouOnly(BuildContext context) => _loc(context).assignedToYouOnly;
  static String allAgents(BuildContext context) => _loc(context).allAgents;
  static String payment(BuildContext context) => _loc(context).payment;
  static String notStarted(BuildContext context) => _loc(context).notStarted;
  static String closed(BuildContext context) => _loc(context).closed;
  static String matrimonyProfile(BuildContext context) => _loc(context).matrimonyProfile;
  static String notCreated(BuildContext context) => _loc(context).notCreated;
  static String apply(BuildContext context) => _loc(context).apply;
  static String filterRevenue(BuildContext context) => _loc(context).filterRevenue;
  static String filterClients(BuildContext context) => _loc(context).filterClients;
  static String dateRange(BuildContext context) => _loc(context).dateRange;
  static String startDate(BuildContext context) => _loc(context).startDate;
  static String endDate(BuildContext context) => _loc(context).endDate;
  static String selectState(BuildContext context) => _loc(context).selectState;
  static String allStates(BuildContext context) => _loc(context).allStates;
  static String selectCityDistrict(BuildContext context) => _loc(context).selectCityDistrict;
  static String allCities(BuildContext context) => _loc(context).allCities;
  static String cityDistrict(BuildContext context) => _loc(context).cityDistrict;
  static String selectReligion(BuildContext context) => _loc(context).selectReligion;
  static String allReligions(BuildContext context) => _loc(context).allReligions;
  static String selectCaste(BuildContext context) => _loc(context).selectCaste;
  static String allCastes(BuildContext context) => _loc(context).allCastes;
  static String couldNotLoadLocations(BuildContext context) => _loc(context).couldNotLoadLocations;
  static String couldNotLoadReligions(BuildContext context) => _loc(context).couldNotLoadReligions;
  static String noMessage(BuildContext context) => _loc(context).noMessage;
  static String statusUpdated(BuildContext context) => _loc(context).statusUpdated;
  static String completeProfileTitle(BuildContext context) => _loc(context).completeProfileTitle;
  static String completeProfileMessage(BuildContext context) => _loc(context).completeProfileMessage;
  static String completeProfileButton(BuildContext context) => _loc(context).completeProfileButton;
  static String noProfilesFound(BuildContext context) => _loc(context).noProfilesFound;
  static String viewProfile(BuildContext context) => _loc(context).viewProfile;
  static String resetFilters(BuildContext context) => _loc(context).resetFilters;
  static String ageYrs(BuildContext context) => _loc(context).ageYrs;
  static String userNotFound(BuildContext context) => _loc(context).userNotFound;
  static String location(BuildContext context) => _loc(context).location;
  static String state(BuildContext context) => _loc(context).state;
  static String city(BuildContext context) => _loc(context).city;
  static String cultural(BuildContext context) => _loc(context).cultural;
  static String religion(BuildContext context) => _loc(context).religion;
  static String caste(BuildContext context) => _loc(context).caste;
  static String profileStatus(BuildContext context) => _loc(context).profileStatus;
  static String gender(BuildContext context) => _loc(context).gender;
  static String male(BuildContext context) => _loc(context).male;
  static String female(BuildContext context) => _loc(context).female;
  static String both(BuildContext context) => _loc(context).both;
  static String all(BuildContext context) => _loc(context).all;
  static String paid(BuildContext context) => _loc(context).paid;
  static String created(BuildContext context) => _loc(context).created;
  static String pleaseSubscribe(BuildContext context) => _loc(context).pleaseSubscribe;

  // ─── Auth Labels ───────────────────────────────────────────────────────────
  static String staffLogin(BuildContext context) => _loc(context).staffLogin;
  static String accessStaffPortal(BuildContext context) => _loc(context).accessStaffPortal;
  static String staffPortal(BuildContext context) => _loc(context).staffPortal;
  static String manageLeadsSubtitle(BuildContext context) => _loc(context).manageLeadsSubtitle;
  static String memberPortal(BuildContext context) => _loc(context).memberPortal;
  static String findSoulmateSubtitle(BuildContext context) => _loc(context).findSoulmateSubtitle;
  static String verifiedProfiles(BuildContext context) => _loc(context).verifiedProfiles;
  static String needHelpContactUs(BuildContext context) => _loc(context).needHelpContactUs;
  static String workEmail(BuildContext context) => _loc(context).workEmail;
  static String workEmailHint(BuildContext context) => _loc(context).workEmailHint;
  static String passwordHint(BuildContext context) => _loc(context).passwordHint;
  static String loggingIn(BuildContext context) => _loc(context).loggingIn;
  static String forgotPassword(BuildContext context) => _loc(context).forgotPassword;
  static String notAStaffMember(BuildContext context) => _loc(context).notAStaffMember;
  static String userLogin(BuildContext context) => _loc(context).userLogin;
  static String createAccount(BuildContext context) => _loc(context).createAccount;
  static String joinToday(BuildContext context) => _loc(context).joinToday;
  static String fullName(BuildContext context) => _loc(context).fullName;
  static String email(BuildContext context) => _loc(context).email;
  static String phone(BuildContext context) => _loc(context).phone;
  static String staffId(BuildContext context) => _loc(context).staffId;
  static String optional(BuildContext context) => _loc(context).optional;
  static String registering(BuildContext context) => _loc(context).registering;
  static String register(BuildContext context) => _loc(context).register;
  static String alreadyAMember(BuildContext context) => _loc(context).alreadyAMember;
  static String loginNow(BuildContext context) => _loc(context).loginNow;
  static String loginSuccessful(BuildContext context) => _loc(context).loginSuccessful;
  static String fillAllFields(BuildContext context) => _loc(context).fillAllFields;

  // Reset & Change Password
  static String resetPassword(BuildContext context) => _loc(context).resetPassword;
  static String resetPasswordSubtitle(BuildContext context) => _loc(context).resetPasswordSubtitle;
  static String sendResetLink(BuildContext context) => _loc(context).sendResetLink;
  static String resetLinkSent(BuildContext context) => _loc(context).resetLinkSent;
  static String userNotFoundWithEmail(BuildContext context) => _loc(context).userNotFoundWithEmail;
  static String unableToSendResetLink(BuildContext context) => _loc(context).unableToSendResetLink;
  static String changePassword(BuildContext context) => _loc(context).changePassword;
  static String backToLogin(BuildContext context) => _loc(context).backToLogin;
  static String updateYourPassword(BuildContext context) => _loc(context).updateYourPassword;
  static String changePasswordSubtitle(BuildContext context) => _loc(context).changePasswordSubtitle;
  static String currentPassword(BuildContext context) => _loc(context).currentPassword;
  static String newPassword(BuildContext context) => _loc(context).newPassword;
  static String confirmNewPassword(BuildContext context) => _loc(context).confirmNewPassword;
  static String passwordChangedSuccessfully(BuildContext context) => _loc(context).passwordChangedSuccessfully;
  static String reauthenticateForSecurity(BuildContext context) => _loc(context).reauthenticateForSecurity;
  static String incorrectCurrentPassword(BuildContext context) => _loc(context).incorrectCurrentPassword;
  static String weakNewPassword(BuildContext context) => _loc(context).weakNewPassword;
  static String mustBeLoggedInToReset(BuildContext context) => _loc(context).mustBeLoggedInToReset;
  static String forgotPasswordResetViaEmail(BuildContext context) => _loc(context).forgotPasswordResetViaEmail;
  static String resetEmailSentTo(BuildContext context, String email) => _loc(context).resetEmailSentTo(email);

  // Identity Form
  static String createIdentity(BuildContext context) => _loc(context).createIdentity;
  static String editIdentity(BuildContext context) => _loc(context).editIdentity;
  static String aboutMe(BuildContext context) => _loc(context).aboutMe;
  static String tellUsAboutYourself(BuildContext context) => _loc(context).tellUsAboutYourself;
  static String aadharNumber(BuildContext context) => _loc(context).aadharNumber;
  static String enterAadharNumber(BuildContext context) => _loc(context).enterAadharNumber;
  static String selectDateOfBirth(BuildContext context) => _loc(context).selectDateOfBirth;
  static String selectDobHelp(BuildContext context) => _loc(context).selectDobHelp;
  static String selectDobConfirm(BuildContext context) => _loc(context).selectDobConfirm;
  static String pleaseSelectDob(BuildContext context) => _loc(context).pleaseSelectDob;
  static String mustBe18(BuildContext context) => _loc(context).mustBe18;
  static String notEligibleUnder18(BuildContext context) => _loc(context).notEligibleUnder18;
  static String identitySavedSuccessfully(BuildContext context) => _loc(context).identitySavedSuccessfully;
  static String saveIdentity(BuildContext context) => _loc(context).saveIdentity;
  static String updateIdentity(BuildContext context) => _loc(context).updateIdentity;
  static String genderNotFound(BuildContext context) => _loc(context).genderNotFound;
  static String errorFetchingUserData(BuildContext context, String error) => _loc(context).errorFetchingUserData(error);
  static String ageYears(BuildContext context, int age) => _loc(context).ageYears(age);
  static String dobValue(BuildContext context, String date) => _loc(context).dobValue(date);

  // Address Form
  static String addressDetails(BuildContext context) => _loc(context).addressDetails;
  static String place(BuildContext context) => _loc(context).place;
  static String placeHint(BuildContext context) => _loc(context).placeHint;
  static String post(BuildContext context) => _loc(context).post;
  static String postHint(BuildContext context) => _loc(context).postHint;
  static String policeStation(BuildContext context) => _loc(context).policeStation;
  static String policeStationHint(BuildContext context) => _loc(context).policeStationHint;
  static String pinCodeLabel(BuildContext context) => _loc(context).pinCode;
  static String pinCodeHint(BuildContext context) => _loc(context).pinCodeHint;
  static String addressSavedSuccessfully(BuildContext context) => _loc(context).addressSavedSuccessfully;
  static String saveAddress(BuildContext context) => _loc(context).saveAddress;
  static String districtLabel(BuildContext context) => _loc(context).district;
  static String selectDistrict(BuildContext context) => _loc(context).selectDistrict;
  static String selectStateHelp(BuildContext context) => _loc(context).selectStateHelp;

  // Cultural Form
  static String addCulturalDetails(BuildContext context) => _loc(context).addCulturalDetails;
  static String editCulturalDetails(BuildContext context) => _loc(context).editCulturalDetails;
  static String specifyCaste(BuildContext context) => _loc(context).specifyCaste;
  static String specifyCasteHint(BuildContext context) => _loc(context).specifyCasteHint;
  static String subCasteLabel(BuildContext context) => _loc(context).subCaste;
  static String subCasteHint(BuildContext context) => _loc(context).subCasteHint;
  static String additionalQualifications(BuildContext context) => _loc(context).additionalQualifications;
  static String addKnownLanguages(BuildContext context) => _loc(context).addKnownLanguages;
  static String languagesHint(BuildContext context) => _loc(context).languagesHint;
  static String culturalDetailsSavedSuccessfully(BuildContext context) => _loc(context).culturalDetailsSavedSuccessfully;
  static String pleaseSelectReligion(BuildContext context) => _loc(context).pleaseSelectReligion;
  static String pleaseSelectCaste(BuildContext context) => _loc(context).pleaseSelectCaste;

  // Education Form
  static String educationDetails(BuildContext context) => _loc(context).educationDetails;
  static String editEducation(BuildContext context) => _loc(context).editEducation;
  static String literate(BuildContext context) => _loc(context).literate;
  static String illiterate(BuildContext context) => _loc(context).illiterate;
  static String highestQualification(BuildContext context) => _loc(context).highestQualification;
  static String collegeUniversity(BuildContext context) => _loc(context).collegeUniversity;
  static String collegeHint(BuildContext context) => _loc(context).collegeHint;
  static String degreeCourse(BuildContext context) => _loc(context).degreeCourse;
  static String degreeHint(BuildContext context) => _loc(context).degreeHint;
  static String percentageCGPA(BuildContext context) => _loc(context).percentageCGPA;
  static String percentageHint(BuildContext context) => _loc(context).percentageHint;
  static String passingYear(BuildContext context) => _loc(context).passingYear;
  static String yearHint(BuildContext context) => _loc(context).yearHint;
  static String addExtraQualification(BuildContext context) => _loc(context).addExtraQualification;
  static String extraQualificationHint(BuildContext context) => _loc(context).extraQualificationHint;
  static String educationSavedSuccessfully(BuildContext context) => _loc(context).educationSavedSuccessfully;
  static String saveEducation(BuildContext context) => _loc(context).saveEducation;
  static String updateEducation(BuildContext context) => _loc(context).updateEducation;

  // Family Form
  static String familyDetails(BuildContext context) => _loc(context).familyDetails;
  static String fatherName(BuildContext context) => _loc(context).fatherName;
  static String fatherNameHint(BuildContext context) => _loc(context).fatherNameHint;
  static String motherName(BuildContext context) => _loc(context).motherName;
  static String motherNameHint(BuildContext context) => _loc(context).motherNameHint;
  static String numberOfBrothers(BuildContext context) => _loc(context).numberOfBrothers;
  static String brothersHint(BuildContext context) => _loc(context).brothersHint;
  static String numberOfSisters(BuildContext context) => _loc(context).numberOfSisters;
  static String sistersHint(BuildContext context) => _loc(context).sistersHint;
  static String familyType(BuildContext context) => _loc(context).familyType;
  static String selectFamilyType(BuildContext context) => _loc(context).selectFamilyType;
  static String lifeStyleStatus(BuildContext context) => _loc(context).lifeStyleStatus;
  static String selectLifeStyleStatus(BuildContext context) => _loc(context).selectLifeStyleStatus;
  static String familyProfileSavedSuccessfully(BuildContext context) => _loc(context).familyProfileSavedSuccessfully;
  static String saveFamily(BuildContext context) => _loc(context).saveFamily;
  static String jointFamily(BuildContext context) => _loc(context).jointFamily;
  static String nuclearFamily(BuildContext context) => _loc(context).nuclearFamily;
  static String preferNotToSay(BuildContext context) => _loc(context).preferNotToSay;
  static String simpleLifestyle(BuildContext context) => _loc(context).simpleLifestyle;
  static String moderateLifestyle(BuildContext context) => _loc(context).moderateLifestyle;
  static String comfortableLifestyle(BuildContext context) => _loc(context).comfortableLifestyle;
  static String wellEstablishedLifestyle(BuildContext context) => _loc(context).wellEstablishedLifestyle;

  // Image Form
  static String uploadProfileImages(BuildContext context) => _loc(context).uploadProfileImages;
  static String pleaseSelectPrimaryImage(BuildContext context) => _loc(context).pleaseSelectPrimaryImage;
  static String pleaseSelectAadharPdf(BuildContext context) => _loc(context).pleaseSelectAadharPdf;
  static String continueButton(BuildContext context) => _loc(context).continueButton;

  // Employment Form
  static String employmentDetails(BuildContext context) => _loc(context).employmentDetails;
  static String jobType(BuildContext context) => _loc(context).jobType;
  static String selectJobType(BuildContext context) => _loc(context).selectJobType;
  static String private(BuildContext context) => _loc(context).private;
  static String government(BuildContext context) => _loc(context).government;
  static String business(BuildContext context) => _loc(context).business;
  static String defence(BuildContext context) => _loc(context).defence;
  static String selfEmployed(BuildContext context) => _loc(context).selfEmployed;
  static String notWorking(BuildContext context) => _loc(context).notWorking;
  static String organization(BuildContext context) => _loc(context).organization;
  static String organizationHint(BuildContext context) => _loc(context).organizationHint;
  static String workLocation(BuildContext context) => _loc(context).workLocation;
  static String workLocationHint(BuildContext context) => _loc(context).workLocationHint;
  static String annualIncome(BuildContext context) => _loc(context).annualIncome;
  static String annualIncomeHint(BuildContext context) => _loc(context).annualIncomeHint;
  static String employmentSavedSuccessfully(BuildContext context) => _loc(context).employmentSavedSuccessfully;
  static String saveEmployment(BuildContext context) => _loc(context).saveEmployment;

  // Physical Form
  static String physicalDetails(BuildContext context) => _loc(context).physicalDetails;
  static String heightCm(BuildContext context) => _loc(context).heightCm;
  static String heightHint(BuildContext context) => _loc(context).heightHint;
  static String weightKg(BuildContext context) => _loc(context).weightKg;
  static String weightHint(BuildContext context) => _loc(context).weightHint;
  static String selectBodyType(BuildContext context) => _loc(context).selectBodyType;
  static String slim(BuildContext context) => _loc(context).slim;
  static String athletic(BuildContext context) => _loc(context).athletic;
  static String average(BuildContext context) => _loc(context).average;
  static String heavy(BuildContext context) => _loc(context).heavy;
  static String muscular(BuildContext context) => _loc(context).muscular;
  static String obese(BuildContext context) => _loc(context).obese;
  static String selectComplexion(BuildContext context) => _loc(context).selectComplexion;
  static String veryFair(BuildContext context) => _loc(context).veryFair;
  static String fair(BuildContext context) => _loc(context).fair;
  static String wheatish(BuildContext context) => _loc(context).wheatish;
  static String dark(BuildContext context) => _loc(context).dark;
  static String brown(BuildContext context) => _loc(context).brown;
  static String dusky(BuildContext context) => _loc(context).dusky;
  static String darkBrown(BuildContext context) => _loc(context).darkBrown;
  static String blackComplexion(BuildContext context) => _loc(context).blackComplexion;
  static String physicallyChallenged(BuildContext context) => _loc(context).physicallyChallenged;
  static String disabilityDetails(BuildContext context) => _loc(context).disabilityDetails;
  static String disabilityDetailsHint(BuildContext context) => _loc(context).disabilityDetailsHint;
  static String physicalProfileSavedSuccessfully(BuildContext context) => _loc(context).physicalProfileSavedSuccessfully;
  static String physicalProfile(BuildContext context) => _loc(context).physicalProfile;

  // Verify Profile
  static String verifyYourProfile(BuildContext context) => _loc(context).verifyYourProfile;
  static String confirmDetailsCorrect(BuildContext context) => _loc(context).confirmDetailsCorrect;
  static String finalSubmit(BuildContext context) => _loc(context).finalSubmit;
  static String verifyCarefullyWarning(BuildContext context) => _loc(context).verifyCarefullyWarning;
  static String uploadingImages(BuildContext context) => _loc(context).uploadingImages;
  static String role(BuildContext context) => _loc(context).role;
  static String languagesKnown(BuildContext context) => _loc(context).languagesKnown;
  static String enterEmailPassword(BuildContext context) => _loc(context).enterEmailPassword;
  static String loginSuccessfulAgent(BuildContext context) => _loc(context).loginSuccessfulAgent;
  static String agentNotFound(BuildContext context) => _loc(context).agentNotFound;
  static String incorrectPassword(BuildContext context) => _loc(context).incorrectPassword;
  static String invalidEmail(BuildContext context) => _loc(context).invalidEmail;
  static String accountDisabled(BuildContext context) => _loc(context).accountDisabled;
  static String termsAndConditions(BuildContext context) => _loc(context).termsAndConditions;
  static String termsAndConditionsFor(BuildContext context) => _loc(context).termsAndConditionsFor;
  static String acceptanceTermsTitle(BuildContext context) => _loc(context).acceptanceTermsTitle;
  static String eligibilityTitle(BuildContext context) => _loc(context).eligibilityTitle;
  static String accountRegistrationTitle(BuildContext context) => _loc(context).accountRegistrationTitle;
  static String userConductTitle(BuildContext context) => _loc(context).userConductTitle;
  static String contentOwnershipTitle(BuildContext context) => _loc(context).contentOwnershipTitle;
  static String premiumServicesTitle(BuildContext context) => _loc(context).premiumServicesTitle;
  static String disclaimerWarrantiesTitle(BuildContext context) => _loc(context).disclaimerWarrantiesTitle;
  static String limitationLiabilityTitle(BuildContext context) => _loc(context).limitationLiabilityTitle;
  static String indemnificationTitle(BuildContext context) => _loc(context).indemnificationTitle;
  static String changesTermsTitle(BuildContext context) => _loc(context).changesTermsTitle;
  static String contactUsTitle(BuildContext context) => _loc(context).contactUsTitle;
  static String acceptanceTermsContent(BuildContext context) => _loc(context).acceptanceTermsContent;
  static String eligibilityContent(BuildContext context) => _loc(context).eligibilityContent;
  static String accountRegistrationContent(BuildContext context) => _loc(context).accountRegistrationContent;
  static String userConductContent(BuildContext context) => _loc(context).userConductContent;
  static String contentOwnershipContent(BuildContext context) => _loc(context).contentOwnershipContent;
  static String premiumServicesContent(BuildContext context) => _loc(context).premiumServicesContent;
  static String disclaimerWarrantiesContent(BuildContext context) => _loc(context).disclaimerWarrantiesContent;
  static String limitationLiabilityContent(BuildContext context) => _loc(context).limitationLiabilityContent;
  static String indemnificationContent(BuildContext context) => _loc(context).indemnificationContent;
  static String changesTermsContent(BuildContext context) => _loc(context).changesTermsContent;
  static String contactUsContent(BuildContext context) => _loc(context).contactUsContent;
  static String privacyPolicy(BuildContext context) => _loc(context).privacyPolicy;
  static String privacyPolicyFor(BuildContext context) => _loc(context).privacyPolicyFor;
  static String introTitle(BuildContext context) => _loc(context).introTitle;
  static String infoCollectTitle(BuildContext context) => _loc(context).infoCollectTitle;
  static String howUseInfoTitle(BuildContext context) => _loc(context).howUseInfoTitle;
  static String disclosureInfoTitle(BuildContext context) => _loc(context).disclosureInfoTitle;
  static String securityDataTitle(BuildContext context) => _loc(context).securityDataTitle;
  static String dataRightsTitle(BuildContext context) => _loc(context).dataRightsTitle;
  static String linksOtherSitesTitle(BuildContext context) => _loc(context).linksOtherSitesTitle;
  static String childrenPrivacyTitle(BuildContext context) => _loc(context).childrenPrivacyTitle;
  static String changesPrivacyTitle(BuildContext context) => _loc(context).changesPrivacyTitle;
  static String governingLawTitle(BuildContext context) => _loc(context).governingLawTitle;
  static String yourConsentTitle(BuildContext context) => _loc(context).yourConsentTitle;
  static String grievanceOfficerTitle(BuildContext context) => _loc(context).grievanceOfficerTitle;
  static String introContent(BuildContext context) => _loc(context).introContent;
  static String infoCollectContent(BuildContext context) => _loc(context).infoCollectContent;
  static String howUseInfoContent(BuildContext context) => _loc(context).howUseInfoContent;
  static String disclosureInfoContent(BuildContext context) => _loc(context).disclosureInfoContent;
  static String securityDataContent(BuildContext context) => _loc(context).securityDataContent;
  static String dataRightsContent(BuildContext context) => _loc(context).dataRightsContent;
  static String linksOtherSitesContent(BuildContext context) => _loc(context).linksOtherSitesContent;
  static String childrenPrivacyContent(BuildContext context) => _loc(context).childrenPrivacyContent;
  static String changesPrivacyContent(BuildContext context) => _loc(context).changesPrivacyContent;
  static String governingLawContent(BuildContext context) => _loc(context).governingLawContent;
  static String yourConsentContent(BuildContext context) => _loc(context).yourConsentContent;
  static String grievanceOfficerNameLabel(BuildContext context) => _loc(context).grievanceOfficerNameLabel;
  static String grievanceOfficerEmailLabel(BuildContext context) => _loc(context).grievanceOfficerEmailLabel;
  static String grievanceOfficerAddressLabel(BuildContext context) => _loc(context).grievanceOfficerAddressLabel;
  static String privacyImportantMessage(BuildContext context) => _loc(context).privacyImportantMessage;
  static String byContinuingAgree(BuildContext context) => _loc(context).byContinuingAgree;
  static String andLabel(BuildContext context) => _loc(context).andLabel;

  // ─── Dialogs & Messages ─────────────────────────────────────────────────────
  static String updateRequiredTitle(BuildContext context) => _loc(context).updateRequiredTitle;
  static String updateRequiredMessage(BuildContext context) => _loc(context).updateRequiredMessage;
  static String updateNowButton(BuildContext context) => _loc(context).updateNowButton;

  static String maintenanceModeTitle(BuildContext context) => _loc(context).maintenanceModeTitle;
  static String maintenanceModeSubtitle(BuildContext context) => _loc(context).maintenanceModeSubtitle;
  static String maintenanceModeMessage(BuildContext context) => _loc(context).maintenanceModeMessage;
  static String maintenanceRestoringMessage(BuildContext context) => _loc(context).maintenanceRestoringMessage;
  static String pleaseWait(BuildContext context) => _loc(context).pleaseWait;
  static String searchHint(BuildContext context) => _loc(context).searchHint;
  static String searchHintFull(BuildContext context) => _loc(context).searchHintFull;
  static String searchLabel(BuildContext context) => _loc(context).searchLabel;
  static String noImagesToDisplay(BuildContext context) => _loc(context).noImagesToDisplay;

  // ─── Form Labels ─────────────────────────────────────────────────────────────
  static String words(BuildContext context) => _loc(context).words;
  static String characters(BuildContext context) => _loc(context).characters;
  static String pleaseEnter(BuildContext context) => _loc(context).pleaseEnter;
  static String select(BuildContext context) => _loc(context).select;
  static String pleaseSelect(BuildContext context) => _loc(context).pleaseSelect;

  // ─── Validation Labels ───────────────────────────────────────────────────────
  static String emailRequired(BuildContext context) => _loc(context).emailRequired;
  static String passwordRequired(BuildContext context) => _loc(context).passwordRequired;
  static String passwordTooShort(BuildContext context) => _loc(context).passwordTooShort;
  static String passwordUppercase(BuildContext context) => _loc(context).passwordUppercase;
  static String passwordLowercase(BuildContext context) => _loc(context).passwordLowercase;
  static String passwordNumber(BuildContext context) => _loc(context).passwordNumber;
  static String passwordSpecial(BuildContext context) => _loc(context).passwordSpecial;
  static String confirmPasswordRequired(BuildContext context) => _loc(context).confirmPasswordRequired;
  static String confirmPassword(BuildContext context) => _loc(context).confirmPassword;
  static String passwordsDoNotMatch(BuildContext context) => _loc(context).passwordsDoNotMatch;
  static String nameRequired(BuildContext context) => _loc(context).nameRequired;
  static String nameTooShort(BuildContext context) => _loc(context).nameTooShort;
  static String phoneRequired(BuildContext context) => _loc(context).phoneRequired;
  static String invalidPhone(BuildContext context) => _loc(context).invalidPhone;
  static String ageRequired(BuildContext context) => _loc(context).ageRequired;
  static String invalidAge(BuildContext context) => _loc(context).invalidAge;
  static String pinCodeRequired(BuildContext context) => _loc(context).pinCodeRequired;
  static String invalidPinCode(BuildContext context) => _loc(context).invalidPinCode;
  static String heightRequired(BuildContext context) => _loc(context).heightRequired;
  static String invalidHeight(BuildContext context) => _loc(context).invalidHeight;
  static String weightRequired(BuildContext context) => _loc(context).weightRequired;
  static String invalidWeight(BuildContext context) => _loc(context).invalidWeight;
  static String aadharRequired(BuildContext context) => _loc(context).aadharRequired;
  static String invalidAadhar(BuildContext context) => _loc(context).invalidAadhar;
  static String isRequired(BuildContext context) => _loc(context).isRequired;
  static String mustBeNumber(BuildContext context) => _loc(context).mustBeNumber;

  // ─── Profile Labels ──────────────────────────────────────────────────────────
  static String height(BuildContext context) => _loc(context).height;
  static String education(BuildContext context) => _loc(context).education;
  static String occupation(BuildContext context) => _loc(context).occupation;
  static String about(BuildContext context) => _loc(context).about;
  static String details(BuildContext context) => _loc(context).details;
  static String tapToViewDetails(BuildContext context) => _loc(context).tapToViewDetails;
  static String profile(BuildContext context) => _loc(context).profile;
  static String result(BuildContext context) => _loc(context).result;
  static String matches(BuildContext context) => _loc(context).matches;

  // ─── About Us ───────────────────────────────────────────────────────────────
  static String aboutUs(BuildContext context) => _loc(context).aboutUs;
  static String whoWeAre(BuildContext context) => _loc(context).whoWeAre;
  static String whoWeAreDescription(BuildContext context) => _loc(context).whoWeAreDescription;
  static String madeWithLove(BuildContext context) => _loc(context).madeWithLove;

  // ─── Auth Extra ────────────────────────────────────────────────────────────
  static String login(BuildContext context) => _loc(context).login;
  static String password(BuildContext context) => _loc(context).password;

  // ─── Image Picker ──────────────────────────────────────────────────────────
  static String profileImage(BuildContext context) => _loc(context).profileImage;
  static String matrimonyImage(BuildContext context) => _loc(context).matrimonyImage;
  static String imageWithAgent(BuildContext context) => _loc(context).imageWithAgent;
  static String galleryImages(BuildContext context) => _loc(context).galleryImages;
  static String aadharDocument(BuildContext context) => _loc(context).aadharDocument;
  static String cropImage(BuildContext context) => _loc(context).cropImage;
  static String camera(BuildContext context) => _loc(context).camera;
  static String gallery(BuildContext context) => _loc(context).gallery;
  static String profileImageRequired(BuildContext context) => _loc(context).profileImageRequired;
  static String primaryImageRequired(BuildContext context) => _loc(context).primaryImageRequired;
  static String imageWithAgentRequired(BuildContext context) => _loc(context).imageWithAgentRequired;
  static String atLeastOneGalleryImageRequired(BuildContext context) => _loc(context).atLeastOneGalleryImageRequired;
  static String aadharDocumentRequired(BuildContext context) => _loc(context).aadharDocumentRequired;

  static String notifications(BuildContext context) => _loc(context).notifications;
  static String legalAndInfo(BuildContext context) => _loc(context).legalAndInfo;
  static String helpAndSupport(BuildContext context) => _loc(context).helpAndSupport;
  static String shareApp(BuildContext context) => _loc(context).shareApp;
  static String mainSection(BuildContext context) => _loc(context).mainSection;
  static String rateUs(BuildContext context) => _loc(context).rateUs;
  static String noUserData(BuildContext context) => _loc(context).noUserData;

  // ─── Revenue & Payment ─────────────────────────────────────────────────────
  static String paymentStatus(BuildContext context) => _loc(context).paymentStatus;
  static String noInternet(BuildContext context) =>_loc(context).noInternet;
  static String somethingWentWrong(BuildContext context) => _loc(context).somethingWentWrong;
  static String errorOccurred(BuildContext context) => _loc(context).errorOccurred;

  static String designation(BuildContext context) => _loc(context).designation;

  static String designationHint(BuildContext context) => _loc(context).designation;
static String next ( BuildContext context)=>_loc(context).next;

}
