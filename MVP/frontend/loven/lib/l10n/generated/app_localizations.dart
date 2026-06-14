import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Discover Art That Speaks to You!'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Discover unique artworks, join a vibrant artistic community.\nStart your creative adventure effortlessly with us.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Where Art Meets Soul!'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Join us and let us guide you to the perfect masterpiece,\ncurated to resonate with your artistic identity.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Welcome to LOVEN!'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Ready to embark on a quest for inspiration and beauty?\nYour adventure begins now. Let\'s go!'**
  String get onboardingDesc3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account and start discovering art'**
  String get signupSubtitle;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @hintName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get hintName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get hintEmail;

  /// No description provided for @emailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalidError;

  /// No description provided for @emailTakenError.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get emailTakenError;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @hintPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get hintPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordAtLeastNumber.
  ///
  /// In en, this message translates to:
  /// **'At least 1 number'**
  String get passwordAtLeastNumber;

  /// No description provided for @passwordContainsLetters.
  ///
  /// In en, this message translates to:
  /// **'Contains letters'**
  String get passwordContainsLetters;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @artist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account? '**
  String get haveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By registering, you agree to our terms and policies.'**
  String get termsAgreement;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back '**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @signupSubtitle_2.
  ///
  /// In en, this message translates to:
  /// **'Start your creative journey today'**
  String get signupSubtitle_2;

  /// No description provided for @accountType_2.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType_2;

  /// No description provided for @register_2.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register_2;

  /// No description provided for @haveAccount_2.
  ///
  /// In en, this message translates to:
  /// **'Have an account? '**
  String get haveAccount_2;

  /// No description provided for @passwordRuleMinLength.
  ///
  /// In en, this message translates to:
  /// **'8 characters minimum'**
  String get passwordRuleMinLength;

  /// No description provided for @passwordAtleastNumber.
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get passwordAtleastNumber;

  /// No description provided for @passwordAtleastLetters.
  ///
  /// In en, this message translates to:
  /// **'At least one letter'**
  String get passwordAtleastLetters;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If an account exists, a link was sent.'**
  String get emailSentSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @verifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re verified'**
  String get verifiedTitle;

  /// No description provided for @verifiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your email is confirmed and your LOVEN account is ready. \nSign in to start exploring art from local creators.'**
  String get verifiedSubtitle;

  /// No description provided for @continueToLogin.
  ///
  /// In en, this message translates to:
  /// **'Continue to login'**
  String get continueToLogin;

  /// No description provided for @passwordChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChangedTitle;

  /// No description provided for @passwordChangedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated. Sign in with your new password.'**
  String get passwordChangedSubtitle;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verificationSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to'**
  String get verificationSentSubtitle;

  /// No description provided for @openLinkInstruction.
  ///
  /// In en, this message translates to:
  /// **'Open the link in your email, then return here and tap Continue.'**
  String get openLinkInstruction;

  /// No description provided for @didntReceiveEmail.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email? '**
  String get didntReceiveEmail;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Check your inbox.'**
  String get verificationEmailSent;

  /// No description provided for @emailVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully.'**
  String get emailVerifiedSuccessfully;

  /// No description provided for @emailNotVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Open the link in your inbox, then tap Continue.'**
  String get emailNotVerifiedYet;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String fieldRequired(Object fieldName);

  /// No description provided for @min8Characters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get min8Characters;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get homeTitle;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTooltip;

  /// No description provided for @themeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get themeTooltip;

  /// No description provided for @notificationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationTooltip;

  /// No description provided for @masterpieces.
  ///
  /// In en, this message translates to:
  /// **'Masterpieces'**
  String get masterpieces;

  /// No description provided for @artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @trendingWorks.
  ///
  /// In en, this message translates to:
  /// **'Trending works'**
  String get trendingWorks;

  /// No description provided for @searchGallery.
  ///
  /// In en, this message translates to:
  /// **'Search the gallery'**
  String get searchGallery;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Artworks, artists, styles…'**
  String get searchHint;

  /// No description provided for @browseByStyle.
  ///
  /// In en, this message translates to:
  /// **'Browse by style'**
  String get browseByStyle;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @noMatchingWorks.
  ///
  /// In en, this message translates to:
  /// **'No matching works'**
  String get noMatchingWorks;

  /// No description provided for @galleryIsQuiet.
  ///
  /// In en, this message translates to:
  /// **'Gallery is quiet'**
  String get galleryIsQuiet;

  /// No description provided for @noResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or style.'**
  String get noResultsSubtitle;

  /// No description provided for @emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'New artworks will be added soon.'**
  String get emptySubtitle;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @match.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get match;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @genre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @preparingDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Preparing discovery...'**
  String get preparingDiscovery;

  /// No description provided for @couldNotLoadArtworks.
  ///
  /// In en, this message translates to:
  /// **'Could not load artworks'**
  String get couldNotLoadArtworks;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @galleryAwaitsTitle.
  ///
  /// In en, this message translates to:
  /// **'The gallery awaits'**
  String get galleryAwaitsTitle;

  /// No description provided for @galleryAwaitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Original works from our artists will appear here soon.'**
  String get galleryAwaitsSubtitle;

  /// No description provided for @artistProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artistProfileTitle;

  /// No description provided for @myProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfileTitle;

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile…'**
  String get loadingProfile;

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get couldNotLoadProfile;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noArtistGallery.
  ///
  /// In en, this message translates to:
  /// **'No artist gallery'**
  String get noArtistGallery;

  /// No description provided for @customerNoPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Customer accounts do not have artist portfolios.'**
  String get customerNoPortfolio;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @worksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 { } =1 {1 work} other {{count} works}}'**
  String worksCount(num count);

  /// No description provided for @noArtworksYet.
  ///
  /// In en, this message translates to:
  /// **'No artworks yet'**
  String get noArtworksYet;

  /// No description provided for @publicNoArtworks.
  ///
  /// In en, this message translates to:
  /// **'This artist has not published any works.'**
  String get publicNoArtworks;

  /// No description provided for @ownerNoArtworks.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio will appear here once you add artworks.'**
  String get ownerNoArtworks;

  /// No description provided for @artworkDeleted.
  ///
  /// In en, this message translates to:
  /// **'Artwork deleted'**
  String get artworkDeleted;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
