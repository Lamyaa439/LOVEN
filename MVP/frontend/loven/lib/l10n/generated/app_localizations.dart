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

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

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

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading LOVEN…'**
  String get splashLoading;

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

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @updateStorefront.
  ///
  /// In en, this message translates to:
  /// **'Update how collectors see your storefront.'**
  String get updateStorefront;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select city'**
  String get selectCity;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @writeBioHint.
  ///
  /// In en, this message translates to:
  /// **'Write a short artist bio'**
  String get writeBioHint;

  /// No description provided for @shippingPolicy.
  ///
  /// In en, this message translates to:
  /// **'Shipping policy'**
  String get shippingPolicy;

  /// No description provided for @shippingPolicyHint.
  ///
  /// In en, this message translates to:
  /// **'Describe shipping availability and timing'**
  String get shippingPolicyHint;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @fixHighlighted.
  ///
  /// In en, this message translates to:
  /// **'Please fix the highlighted fields'**
  String get fixHighlighted;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @couldNotUpdate.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile: {error}'**
  String couldNotUpdate(Object error);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @noBioYet.
  ///
  /// In en, this message translates to:
  /// **'This artist has not added a bio yet.'**
  String get noBioYet;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @ships.
  ///
  /// In en, this message translates to:
  /// **'Ships'**
  String get ships;

  /// No description provided for @editArtistProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit artist profile'**
  String get editArtistProfile;

  /// No description provided for @uploadArtwork.
  ///
  /// In en, this message translates to:
  /// **'Upload artwork'**
  String get uploadArtwork;

  /// No description provided for @pleaseSelectArtworkImage.
  ///
  /// In en, this message translates to:
  /// **'Please select an artwork image'**
  String get pleaseSelectArtworkImage;

  /// No description provided for @pleaseLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'Please login again before uploading artwork'**
  String get pleaseLoginAgain;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed: {error}'**
  String imageUploadFailed(Object error);

  /// No description provided for @artworkUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Artwork uploaded successfully'**
  String get artworkUploadedSuccessfully;

  /// No description provided for @artworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Artwork title'**
  String get artworkTitle;

  /// No description provided for @enterArtworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter artwork title'**
  String get enterArtworkTitle;

  /// No description provided for @titleIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleIsRequired;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @describeYourArtwork.
  ///
  /// In en, this message translates to:
  /// **'Describe your artwork'**
  String get describeYourArtwork;

  /// No description provided for @descriptionIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionIsRequired;

  /// No description provided for @priceSAR.
  ///
  /// In en, this message translates to:
  /// **'Price (SAR)'**
  String get priceSAR;

  /// No description provided for @shippingSAR.
  ///
  /// In en, this message translates to:
  /// **'Shipping (SAR)'**
  String get shippingSAR;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantityAvailable.
  ///
  /// In en, this message translates to:
  /// **'Quantity available'**
  String get quantityAvailable;

  /// No description provided for @quantityIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get quantityIsRequired;

  /// No description provided for @availableForSale.
  ///
  /// In en, this message translates to:
  /// **'Available for sale'**
  String get availableForSale;

  /// No description provided for @portfolioShowcaseOnly.
  ///
  /// In en, this message translates to:
  /// **'Portfolio showcase only'**
  String get portfolioShowcaseOnly;

  /// No description provided for @willBeListedForPurchase.
  ///
  /// In en, this message translates to:
  /// **'This artwork will be listed for purchase.'**
  String get willBeListedForPurchase;

  /// No description provided for @visibleInPortfolioUntilVerified.
  ///
  /// In en, this message translates to:
  /// **'Visible in your portfolio until verification is approved.'**
  String get visibleInPortfolioUntilVerified;

  /// No description provided for @portfolioMode.
  ///
  /// In en, this message translates to:
  /// **'Portfolio mode'**
  String get portfolioMode;

  /// No description provided for @unverifiedArtistNote.
  ///
  /// In en, this message translates to:
  /// **'Unverified artists can showcase work in their portfolio. Purchases unlock after verification.'**
  String get unverifiedArtistNote;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get uploading;

  /// No description provided for @publishArtwork.
  ///
  /// In en, this message translates to:
  /// **'Publish artwork'**
  String get publishArtwork;

  /// No description provided for @saveToPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Save to portfolio'**
  String get saveToPortfolio;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get changeImage;

  /// No description provided for @addArtworkImage.
  ///
  /// In en, this message translates to:
  /// **'Add artwork image'**
  String get addArtworkImage;

  /// No description provided for @pngOrJpg.
  ///
  /// In en, this message translates to:
  /// **'PNG or JPG from your gallery'**
  String get pngOrJpg;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get accountDetails;

  /// No description provided for @accountDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, email, and account image'**
  String get accountDetailsSubtitle;

  /// No description provided for @switchToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Switch to customer'**
  String get switchToCustomer;

  /// No description provided for @becomeArtist.
  ///
  /// In en, this message translates to:
  /// **'Become an artist'**
  String get becomeArtist;

  /// No description provided for @useLovenAsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Use LOVEN as a customer'**
  String get useLovenAsCustomer;

  /// No description provided for @createAndShowcase.
  ///
  /// In en, this message translates to:
  /// **'Create and showcase your artworks'**
  String get createAndShowcase;

  /// No description provided for @savedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get savedAddresses;

  /// No description provided for @manageDelivery.
  ///
  /// In en, this message translates to:
  /// **'Manage delivery locations'**
  String get manageDelivery;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updatePassword;

  /// No description provided for @myArtistProfile.
  ///
  /// In en, this message translates to:
  /// **'My artist profile'**
  String get myArtistProfile;

  /// No description provided for @manageStorefront.
  ///
  /// In en, this message translates to:
  /// **'Manage your storefront and portfolio'**
  String get manageStorefront;

  /// No description provided for @incomingOrders.
  ///
  /// In en, this message translates to:
  /// **'Incoming orders'**
  String get incomingOrders;

  /// No description provided for @reviewOrders.
  ///
  /// In en, this message translates to:
  /// **'Review and fulfill buyer orders'**
  String get reviewOrders;

  /// No description provided for @requestVerification.
  ///
  /// In en, this message translates to:
  /// **'Request verification'**
  String get requestVerification;

  /// No description provided for @applyVerifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Apply for a verified artist badge'**
  String get applyVerifiedBadge;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @yourFavorites.
  ///
  /// In en, this message translates to:
  /// **'Your favorites'**
  String get yourFavorites;

  /// No description provided for @savedArtworks.
  ///
  /// In en, this message translates to:
  /// **'Artworks you have saved'**
  String get savedArtworks;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get orderHistory;

  /// No description provided for @viewPreviousOrders.
  ///
  /// In en, this message translates to:
  /// **'View your previous orders'**
  String get viewPreviousOrders;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @shareThoughts.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts, suggestions, or issues with us.'**
  String get shareThoughts;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get signOut;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get currentLanguage;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryPainting.
  ///
  /// In en, this message translates to:
  /// **'Painting'**
  String get categoryPainting;

  /// No description provided for @categorySculpture.
  ///
  /// In en, this message translates to:
  /// **'Sculpture'**
  String get categorySculpture;

  /// No description provided for @categoryPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get categoryPhotography;

  /// No description provided for @categoryDigitalArt.
  ///
  /// In en, this message translates to:
  /// **'Digital Art'**
  String get categoryDigitalArt;

  /// No description provided for @categoryCalligraphy.
  ///
  /// In en, this message translates to:
  /// **'Calligraphy'**
  String get categoryCalligraphy;

  /// No description provided for @loadingCollection.
  ///
  /// In en, this message translates to:
  /// **'Loading your collection…'**
  String get loadingCollection;

  /// No description provided for @couldNotLoadFavorites.
  ///
  /// In en, this message translates to:
  /// **'Could not load favorites'**
  String get couldNotLoadFavorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @noFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save artworks you love to easily find them later.'**
  String get noFavoritesSubtitle;

  /// No description provided for @yourCollection.
  ///
  /// In en, this message translates to:
  /// **'Your collection'**
  String get yourCollection;

  /// No description provided for @savedWorksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 saved work} other {{count} saved works}}'**
  String savedWorksCount(num count);

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @loadingCart.
  ///
  /// In en, this message translates to:
  /// **'Loading cart…'**
  String get loadingCart;

  /// No description provided for @couldNotLoadCart.
  ///
  /// In en, this message translates to:
  /// **'Could not load cart'**
  String get couldNotLoadCart;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get yourCartIsEmpty;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add artworks you love and they will appear here.'**
  String get cartEmptySubtitle;

  /// No description provided for @exploreArtworks.
  ///
  /// In en, this message translates to:
  /// **'Explore artworks'**
  String get exploreArtworks;

  /// No description provided for @onlyOneItemAvailable.
  ///
  /// In en, this message translates to:
  /// **'Only 1 item is available in stock.'**
  String get onlyOneItemAvailable;

  /// No description provided for @itemsAvailableInStock.
  ///
  /// In en, this message translates to:
  /// **'Only {count} items are available in stock.'**
  String itemsAvailableInStock(Object count);

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get clearCart;

  /// No description provided for @each.
  ///
  /// In en, this message translates to:
  /// **'each'**
  String get each;

  /// No description provided for @paymentExpired.
  ///
  /// In en, this message translates to:
  /// **'Your previous payment session expired. Creating a new order...'**
  String get paymentExpired;

  /// No description provided for @couldNotReadOrderId.
  ///
  /// In en, this message translates to:
  /// **'Could not read order ID'**
  String get couldNotReadOrderId;

  /// No description provided for @moyasarKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'Moyasar publishable key is missing'**
  String get moyasarKeyMissing;

  /// No description provided for @confirmingPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirming your payment...'**
  String get confirmingPayment;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @paymentNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment could not be confirmed. Please try again from checkout.'**
  String get paymentNotConfirmed;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @helpUsImprove.
  ///
  /// In en, this message translates to:
  /// **'Help us improve LOVEN'**
  String get helpUsImprove;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @optionalSubject.
  ///
  /// In en, this message translates to:
  /// **'Optional subject'**
  String get optionalSubject;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @writeFeedback.
  ///
  /// In en, this message translates to:
  /// **'Write your feedback here'**
  String get writeFeedback;

  /// No description provided for @feedbackRequired.
  ///
  /// In en, this message translates to:
  /// **'Feedback message is required'**
  String get feedbackRequired;

  /// No description provided for @feedbackTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please write a little more detail'**
  String get feedbackTooShort;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit feedback'**
  String get submitFeedback;
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
