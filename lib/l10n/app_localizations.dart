import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';

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
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'비타버디'**
  String get appTitle;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In ko, this message translates to:
  /// **'좋은 아침입니다'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In ko, this message translates to:
  /// **'좋은 오후입니다'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In ko, this message translates to:
  /// **'좋은 저녁입니다'**
  String get homeGreetingEvening;

  /// No description provided for @homeSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘도 건강한 하루 보내세요!'**
  String get homeSubtitle;

  /// No description provided for @caloriesUnit.
  ///
  /// In ko, this message translates to:
  /// **'kcal'**
  String get caloriesUnit;

  /// No description provided for @intakeLabel.
  ///
  /// In ko, this message translates to:
  /// **'섭취'**
  String get intakeLabel;

  /// No description provided for @burnedLabel.
  ///
  /// In ko, this message translates to:
  /// **'소모'**
  String get burnedLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In ko, this message translates to:
  /// **'잔여'**
  String get remainingLabel;

  /// No description provided for @goalLabel.
  ///
  /// In ko, this message translates to:
  /// **'목표'**
  String get goalLabel;

  /// No description provided for @minutesUnit.
  ///
  /// In ko, this message translates to:
  /// **'분'**
  String get minutesUnit;

  /// No description provided for @exerciseRecord.
  ///
  /// In ko, this message translates to:
  /// **'운동 기록'**
  String get exerciseRecord;

  /// No description provided for @foodRecord.
  ///
  /// In ko, this message translates to:
  /// **'음식 기록'**
  String get foodRecord;

  /// No description provided for @dailySummary.
  ///
  /// In ko, this message translates to:
  /// **'오늘 하루 요약'**
  String get dailySummary;

  /// No description provided for @wearableConnected.
  ///
  /// In ko, this message translates to:
  /// **'연결됨'**
  String get wearableConnected;

  /// No description provided for @wearablePermissionRequired.
  ///
  /// In ko, this message translates to:
  /// **'권한 필요'**
  String get wearablePermissionRequired;

  /// No description provided for @wearableNotConnected.
  ///
  /// In ko, this message translates to:
  /// **'연결 안됨'**
  String get wearableNotConnected;

  /// No description provided for @walkingActivity.
  ///
  /// In ko, this message translates to:
  /// **'걷기'**
  String get walkingActivity;

  /// No description provided for @runningActivity.
  ///
  /// In ko, this message translates to:
  /// **'달리기'**
  String get runningActivity;

  /// No description provided for @cyclingActivity.
  ///
  /// In ko, this message translates to:
  /// **'자전거'**
  String get cyclingActivity;

  /// No description provided for @swimmingActivity.
  ///
  /// In ko, this message translates to:
  /// **'수영'**
  String get swimmingActivity;

  /// No description provided for @weightTrainingActivity.
  ///
  /// In ko, this message translates to:
  /// **'근력 운동'**
  String get weightTrainingActivity;

  /// No description provided for @yogaActivity.
  ///
  /// In ko, this message translates to:
  /// **'요가'**
  String get yogaActivity;

  /// No description provided for @dancingActivity.
  ///
  /// In ko, this message translates to:
  /// **'댄스'**
  String get dancingActivity;

  /// No description provided for @hikingActivity.
  ///
  /// In ko, this message translates to:
  /// **'등산'**
  String get hikingActivity;

  /// No description provided for @tennisActivity.
  ///
  /// In ko, this message translates to:
  /// **'테니스'**
  String get tennisActivity;

  /// No description provided for @basketballActivity.
  ///
  /// In ko, this message translates to:
  /// **'농구'**
  String get basketballActivity;

  /// No description provided for @soccerActivity.
  ///
  /// In ko, this message translates to:
  /// **'축구'**
  String get soccerActivity;

  /// No description provided for @aerobicsActivity.
  ///
  /// In ko, this message translates to:
  /// **'에어로빅'**
  String get aerobicsActivity;

  /// No description provided for @badmintonActivity.
  ///
  /// In ko, this message translates to:
  /// **'배드민턴'**
  String get badmintonActivity;

  /// No description provided for @baseballActivity.
  ///
  /// In ko, this message translates to:
  /// **'야구'**
  String get baseballActivity;

  /// No description provided for @boxingActivity.
  ///
  /// In ko, this message translates to:
  /// **'복싱'**
  String get boxingActivity;

  /// No description provided for @golfActivity.
  ///
  /// In ko, this message translates to:
  /// **'골프'**
  String get golfActivity;

  /// No description provided for @pilatesActivity.
  ///
  /// In ko, this message translates to:
  /// **'필라테스'**
  String get pilatesActivity;

  /// No description provided for @tableTennisActivity.
  ///
  /// In ko, this message translates to:
  /// **'탁구'**
  String get tableTennisActivity;

  /// No description provided for @volleyballActivity.
  ///
  /// In ko, this message translates to:
  /// **'배구'**
  String get volleyballActivity;

  /// No description provided for @ellipticalActivity.
  ///
  /// In ko, this message translates to:
  /// **'일립티컬'**
  String get ellipticalActivity;

  /// No description provided for @rowingActivity.
  ///
  /// In ko, this message translates to:
  /// **'로잉 머신'**
  String get rowingActivity;

  /// No description provided for @stairClimbingActivity.
  ///
  /// In ko, this message translates to:
  /// **'계단 오르기'**
  String get stairClimbingActivity;

  /// No description provided for @otherActivity.
  ///
  /// In ko, this message translates to:
  /// **'기타 운동'**
  String get otherActivity;

  /// No description provided for @sourceManual.
  ///
  /// In ko, this message translates to:
  /// **'수동 입력'**
  String get sourceManual;

  /// No description provided for @sourceHealthConnect.
  ///
  /// In ko, this message translates to:
  /// **'Health Connect'**
  String get sourceHealthConnect;

  /// No description provided for @sourceHealthKit.
  ///
  /// In ko, this message translates to:
  /// **'HealthKit'**
  String get sourceHealthKit;

  /// No description provided for @workoutTypeLabel.
  ///
  /// In ko, this message translates to:
  /// **'운동 종류'**
  String get workoutTypeLabel;

  /// No description provided for @durationLabel.
  ///
  /// In ko, this message translates to:
  /// **'운동 시간 (분)'**
  String get durationLabel;

  /// No description provided for @intensityLabel.
  ///
  /// In ko, this message translates to:
  /// **'운동 강도'**
  String get intensityLabel;

  /// No description provided for @intensityLow.
  ///
  /// In ko, this message translates to:
  /// **'낮음'**
  String get intensityLow;

  /// No description provided for @intensityMedium.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get intensityMedium;

  /// No description provided for @intensityHigh.
  ///
  /// In ko, this message translates to:
  /// **'높음'**
  String get intensityHigh;

  /// No description provided for @calcCaloriesLabel.
  ///
  /// In ko, this message translates to:
  /// **'예상 칼로리 소모량'**
  String get calcCaloriesLabel;

  /// No description provided for @calorieCalcError.
  ///
  /// In ko, this message translates to:
  /// **'칼로리 계산 오류가 발생했습니다'**
  String get calorieCalcError;

  /// No description provided for @workoutSaved.
  ///
  /// In ko, this message translates to:
  /// **'{type} 운동이 기록되었습니다'**
  String workoutSaved(Object type);

  /// No description provided for @saveError.
  ///
  /// In ko, this message translates to:
  /// **'저장 실패: {error}'**
  String saveError(Object error);

  /// No description provided for @syncComplete.
  ///
  /// In ko, this message translates to:
  /// **'동기화 완료'**
  String get syncComplete;

  /// No description provided for @syncFailed.
  ///
  /// In ko, this message translates to:
  /// **'동기화 실패'**
  String get syncFailed;

  /// No description provided for @noDataToSync.
  ///
  /// In ko, this message translates to:
  /// **'동기화할 데이터 없음'**
  String get noDataToSync;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get profileTitle;

  /// No description provided for @languageTitle.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get languageTitle;

  /// No description provided for @calorieGoalSettings.
  ///
  /// In ko, this message translates to:
  /// **'목표 칼로리 설정'**
  String get calorieGoalSettings;

  /// No description provided for @sleepSettings.
  ///
  /// In ko, this message translates to:
  /// **'수면 설정'**
  String get sleepSettings;

  /// No description provided for @avatarClothingSettings.
  ///
  /// In ko, this message translates to:
  /// **'아바타 옷 설정'**
  String get avatarClothingSettings;

  /// No description provided for @profileEdit.
  ///
  /// In ko, this message translates to:
  /// **'프로필 수정'**
  String get profileEdit;

  /// No description provided for @notificationSettings.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get notificationSettings;

  /// No description provided for @healthDataPermission.
  ///
  /// In ko, this message translates to:
  /// **'헬스 데이터 권한'**
  String get healthDataPermission;

  /// No description provided for @healthPermissionAlreadyGranted.
  ///
  /// In ko, this message translates to:
  /// **'헬스 데이터 권한이 이미 허용되어 있습니다'**
  String get healthPermissionAlreadyGranted;

  /// No description provided for @healthPermissionGranted.
  ///
  /// In ko, this message translates to:
  /// **'헬스 데이터 권한이 허용되었습니다'**
  String get healthPermissionGranted;

  /// No description provided for @healthPermissionDenied.
  ///
  /// In ko, this message translates to:
  /// **'헬스 데이터 권한이 거부되었습니다. 설정에서 허용해주세요'**
  String get healthPermissionDenied;

  /// No description provided for @weight.
  ///
  /// In ko, this message translates to:
  /// **'체중'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In ko, this message translates to:
  /// **'키'**
  String get height;

  /// No description provided for @age.
  ///
  /// In ko, this message translates to:
  /// **'나이'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In ko, this message translates to:
  /// **'성별'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In ko, this message translates to:
  /// **'남성'**
  String get male;

  /// No description provided for @female.
  ///
  /// In ko, this message translates to:
  /// **'여성'**
  String get female;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get edit;

  /// No description provided for @autoRecord.
  ///
  /// In ko, this message translates to:
  /// **'자동 기록'**
  String get autoRecord;

  /// No description provided for @manualRecord.
  ///
  /// In ko, this message translates to:
  /// **'수동 기록'**
  String get manualRecord;

  /// No description provided for @caloriesBurned.
  ///
  /// In ko, this message translates to:
  /// **'소모 칼로리'**
  String get caloriesBurned;

  /// No description provided for @workoutCount.
  ///
  /// In ko, this message translates to:
  /// **'운동 횟수'**
  String get workoutCount;

  /// No description provided for @steps.
  ///
  /// In ko, this message translates to:
  /// **'걸음 수'**
  String get steps;

  /// No description provided for @syncing.
  ///
  /// In ko, this message translates to:
  /// **'동기화 중...'**
  String get syncing;

  /// No description provided for @syncHealthData.
  ///
  /// In ko, this message translates to:
  /// **'Health 데이터 동기화'**
  String get syncHealthData;

  /// No description provided for @noAutoRecords.
  ///
  /// In ko, this message translates to:
  /// **'자동 기록된 운동이 없습니다'**
  String get noAutoRecords;

  /// No description provided for @noAutoRecordsSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'Health 데이터 동기화 버튼을 눌러\n스마트폰과 웨어러블의 운동 데이터를 불러오세요'**
  String get noAutoRecordsSubtitle;

  /// No description provided for @noManualRecords.
  ///
  /// In ko, this message translates to:
  /// **'수동 기록된 운동이 없습니다'**
  String get noManualRecords;

  /// No description provided for @noManualRecordsSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'오른쪽 하단의 + 버튼을 눌러\n운동을 직접 기록해보세요'**
  String get noManualRecordsSubtitle;

  /// No description provided for @dataLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'데이터 로드 실패'**
  String get dataLoadFailed;

  /// No description provided for @basicInfo.
  ///
  /// In ko, this message translates to:
  /// **'기본 정보'**
  String get basicInfo;

  /// No description provided for @bodyInfo.
  ///
  /// In ko, this message translates to:
  /// **'신체'**
  String get bodyInfo;

  /// No description provided for @personality.
  ///
  /// In ko, this message translates to:
  /// **'성격'**
  String get personality;

  /// No description provided for @previous.
  ///
  /// In ko, this message translates to:
  /// **'이전'**
  String get previous;

  /// No description provided for @nameOptional.
  ///
  /// In ko, this message translates to:
  /// **'이름 (선택사항)'**
  String get nameOptional;

  /// No description provided for @activityLevel.
  ///
  /// In ko, this message translates to:
  /// **'활동 수준'**
  String get activityLevel;

  /// No description provided for @activitySedentary.
  ///
  /// In ko, this message translates to:
  /// **'거의 운동 안 함'**
  String get activitySedentary;

  /// No description provided for @activityLight.
  ///
  /// In ko, this message translates to:
  /// **'가벼운 운동 (주 1-3일)'**
  String get activityLight;

  /// No description provided for @activityModerate.
  ///
  /// In ko, this message translates to:
  /// **'보통 운동 (주 3-5일)'**
  String get activityModerate;

  /// No description provided for @activityActive.
  ///
  /// In ko, this message translates to:
  /// **'적극적 운동 (주 6-7일)'**
  String get activityActive;

  /// No description provided for @activityVeryActive.
  ///
  /// In ko, this message translates to:
  /// **'매우 적극적 (하루 2회 이상)'**
  String get activityVeryActive;

  /// No description provided for @sedentary.
  ///
  /// In ko, this message translates to:
  /// **'거의 운동 안 함'**
  String get sedentary;

  /// No description provided for @lightExercise.
  ///
  /// In ko, this message translates to:
  /// **'가벼운 운동 (주 1-3일)'**
  String get lightExercise;

  /// No description provided for @moderateExercise.
  ///
  /// In ko, this message translates to:
  /// **'보통 운동 (주 3-5일)'**
  String get moderateExercise;

  /// No description provided for @activeExercise.
  ///
  /// In ko, this message translates to:
  /// **'적극적 운동 (주 6-7일)'**
  String get activeExercise;

  /// No description provided for @veryActiveExercise.
  ///
  /// In ko, this message translates to:
  /// **'매우 적극적 (하루 2회 이상)'**
  String get veryActiveExercise;

  /// No description provided for @saveChanges.
  ///
  /// In ko, this message translates to:
  /// **'변경사항 저장'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In ko, this message translates to:
  /// **'프로필이 업데이트되었습니다'**
  String get profileUpdated;

  /// No description provided for @discardChanges.
  ///
  /// In ko, this message translates to:
  /// **'변경사항 취소'**
  String get discardChanges;

  /// No description provided for @discardChangesMessage.
  ///
  /// In ko, this message translates to:
  /// **'변경한 내용을 저장하지 않고 나가시겠습니까?'**
  String get discardChangesMessage;

  /// No description provided for @continueEditing.
  ///
  /// In ko, this message translates to:
  /// **'계속 수정'**
  String get continueEditing;

  /// No description provided for @exitWithoutSaving.
  ///
  /// In ko, this message translates to:
  /// **'나가기'**
  String get exitWithoutSaving;

  /// No description provided for @complete.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get complete;

  /// No description provided for @next.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get next;

  /// No description provided for @foodInput.
  ///
  /// In ko, this message translates to:
  /// **'음식 입력'**
  String get foodInput;

  /// No description provided for @recent.
  ///
  /// In ko, this message translates to:
  /// **'최근'**
  String get recent;

  /// No description provided for @favorites.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get favorites;

  /// No description provided for @search.
  ///
  /// In ko, this message translates to:
  /// **'검색'**
  String get search;

  /// No description provided for @customAdd.
  ///
  /// In ko, this message translates to:
  /// **'직접추가'**
  String get customAdd;

  /// No description provided for @noRecentFoods.
  ///
  /// In ko, this message translates to:
  /// **'최근에 먹은 음식이 없습니다'**
  String get noRecentFoods;

  /// No description provided for @noFavoriteFoods.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기한 음식이 없습니다'**
  String get noFavoriteFoods;

  /// No description provided for @addFavoriteHint.
  ///
  /// In ko, this message translates to:
  /// **'음식 목록에서 ⭐를 눌러 추가해보세요'**
  String get addFavoriteHint;

  /// No description provided for @noSearchResults.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없습니다'**
  String get noSearchResults;

  /// No description provided for @searchFoodHint.
  ///
  /// In ko, this message translates to:
  /// **'음식 검색...'**
  String get searchFoodHint;

  /// No description provided for @foodName.
  ///
  /// In ko, this message translates to:
  /// **'음식 이름'**
  String get foodName;

  /// No description provided for @calories.
  ///
  /// In ko, this message translates to:
  /// **'칼로리'**
  String get calories;

  /// No description provided for @quantity.
  ///
  /// In ko, this message translates to:
  /// **'수량'**
  String get quantity;

  /// No description provided for @servingCalories.
  ///
  /// In ko, this message translates to:
  /// **'1회 제공량 칼로리'**
  String get servingCalories;

  /// No description provided for @servingCount.
  ///
  /// In ko, this message translates to:
  /// **'섭취한 횟수'**
  String get servingCount;

  /// No description provided for @foodNameHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 햄버거, 불고기 정식'**
  String get foodNameHint;

  /// No description provided for @caloriesHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 550'**
  String get caloriesHint;

  /// No description provided for @addIntake.
  ///
  /// In ko, this message translates to:
  /// **'섭취 추가'**
  String get addIntake;

  /// No description provided for @saveTemporary.
  ///
  /// In ko, this message translates to:
  /// **'임시 저장 (나중에 칼로리 입력)'**
  String get saveTemporary;

  /// No description provided for @invalidQuantity.
  ///
  /// In ko, this message translates to:
  /// **'올바른 수량을 입력해주세요'**
  String get invalidQuantity;

  /// No description provided for @foodAdded.
  ///
  /// In ko, this message translates to:
  /// **'음식 추가 완료'**
  String get foodAdded;

  /// No description provided for @foodAddFailed.
  ///
  /// In ko, this message translates to:
  /// **'음식 추가에 실패했습니다'**
  String get foodAddFailed;

  /// No description provided for @favoriteAdded.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기 추가됨'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기 해제됨'**
  String get favoriteRemoved;

  /// No description provided for @inputModeTotal.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get inputModeTotal;

  /// No description provided for @inputModeServing.
  ///
  /// In ko, this message translates to:
  /// **'1회'**
  String get inputModeServing;

  /// No description provided for @inputMode100g.
  ///
  /// In ko, this message translates to:
  /// **'100g'**
  String get inputMode100g;

  /// No description provided for @inputModeQuick.
  ///
  /// In ko, this message translates to:
  /// **'빠른'**
  String get inputModeQuick;

  /// No description provided for @add.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get add;

  /// No description provided for @enterFoodNameAndCalories.
  ///
  /// In ko, this message translates to:
  /// **'음식 이름과 칼로리를 입력해주세요'**
  String get enterFoodNameAndCalories;

  /// No description provided for @enterValidCalories.
  ///
  /// In ko, this message translates to:
  /// **'올바른 칼로리를 입력해주세요'**
  String get enterValidCalories;

  /// No description provided for @userFoodAddFailed.
  ///
  /// In ko, this message translates to:
  /// **'사용자 음식 추가에 실패했습니다'**
  String get userFoodAddFailed;

  /// No description provided for @enterFoodName.
  ///
  /// In ko, this message translates to:
  /// **'음식 이름을 입력해주세요'**
  String get enterFoodName;

  /// No description provided for @quickSaveSuccess.
  ///
  /// In ko, this message translates to:
  /// **'임시 저장됨 (나중에 칼로리 입력 필요)'**
  String get quickSaveSuccess;

  /// No description provided for @servingInfoHelp.
  ///
  /// In ko, this message translates to:
  /// **'영양성분표의 1회 제공량 정보를 그대로 입력하세요'**
  String get servingInfoHelp;

  /// No description provided for @servingUnit.
  ///
  /// In ko, this message translates to:
  /// **'회'**
  String get servingUnit;

  /// No description provided for @unitServings.
  ///
  /// In ko, this message translates to:
  /// **'인분'**
  String get unitServings;

  /// No description provided for @unitCount.
  ///
  /// In ko, this message translates to:
  /// **'개/인분'**
  String get unitCount;

  /// No description provided for @foodAddTitle.
  ///
  /// In ko, this message translates to:
  /// **'음식 추가'**
  String get foodAddTitle;

  /// No description provided for @foodAddConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{foodName}을(를) 추가하시겠습니까?'**
  String foodAddConfirm(String foodName);

  /// No description provided for @refreshTooltip.
  ///
  /// In ko, this message translates to:
  /// **'새로고침'**
  String get refreshTooltip;

  /// No description provided for @totalCalorieHelp.
  ///
  /// In ko, this message translates to:
  /// **'음식의 총 칼로리를 직접 입력하세요'**
  String get totalCalorieHelp;

  /// No description provided for @quickRecordHelp.
  ///
  /// In ko, this message translates to:
  /// **'음식 이름만 입력하고 나중에 칼로리를 추가할 수 있어요'**
  String get quickRecordHelp;

  /// No description provided for @defaultLabel.
  ///
  /// In ko, this message translates to:
  /// **'기본'**
  String get defaultLabel;

  /// No description provided for @weightRecord.
  ///
  /// In ko, this message translates to:
  /// **'체중 기록'**
  String get weightRecord;

  /// No description provided for @weightLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'체중 기록을 불러오는데 실패했습니다'**
  String get weightLoadFailed;

  /// No description provided for @enterWeight.
  ///
  /// In ko, this message translates to:
  /// **'체중을 입력해주세요'**
  String get enterWeight;

  /// No description provided for @enterValidWeight.
  ///
  /// In ko, this message translates to:
  /// **'올바른 체중을 입력해주세요 (20-300kg)'**
  String get enterValidWeight;

  /// No description provided for @weightRecorded.
  ///
  /// In ko, this message translates to:
  /// **'체중이 기록되었습니다'**
  String get weightRecorded;

  /// No description provided for @weightRecordFailed.
  ///
  /// In ko, this message translates to:
  /// **'체중 기록에 실패했습니다'**
  String get weightRecordFailed;

  /// No description provided for @weightRecordDeleted.
  ///
  /// In ko, this message translates to:
  /// **'체중 기록이 삭제되었습니다'**
  String get weightRecordDeleted;

  /// No description provided for @deleteFailed.
  ///
  /// In ko, this message translates to:
  /// **'기록 삭제에 실패했습니다'**
  String get deleteFailed;

  /// No description provided for @todaysWeight.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 체중'**
  String get todaysWeight;

  /// No description provided for @weightHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 70.5'**
  String get weightHint;

  /// No description provided for @record.
  ///
  /// In ko, this message translates to:
  /// **'기록'**
  String get record;

  /// No description provided for @noteOptional.
  ///
  /// In ko, this message translates to:
  /// **'메모 (선택사항)'**
  String get noteOptional;

  /// No description provided for @noteHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 운동 후 측정'**
  String get noteHint;

  /// No description provided for @weightTrend.
  ///
  /// In ko, this message translates to:
  /// **'체중 변화 추이'**
  String get weightTrend;

  /// No description provided for @noWeightRecords.
  ///
  /// In ko, this message translates to:
  /// **'체중 기록이 없습니다'**
  String get noWeightRecords;

  /// No description provided for @deleteRecord.
  ///
  /// In ko, this message translates to:
  /// **'기록 삭제'**
  String get deleteRecord;

  /// No description provided for @confirmDeleteWeight.
  ///
  /// In ko, this message translates to:
  /// **'이 체중 기록을 삭제하시겠습니까?'**
  String get confirmDeleteWeight;

  /// No description provided for @languageSettings.
  ///
  /// In ko, this message translates to:
  /// **'언어 설정'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어 선택'**
  String get selectLanguage;

  /// No description provided for @getStarted.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get getStarted;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @healthPermissionContent.
  ///
  /// In ko, this message translates to:
  /// **'앱에서 웨어러블 기기와의 칼로리 동기화를 위해 건강 데이터 접근 권한이 필요합니다.'**
  String get healthPermissionContent;

  /// No description provided for @healthPermissionAllowInfo.
  ///
  /// In ko, this message translates to:
  /// **'권한 허용 시:'**
  String get healthPermissionAllowInfo;

  /// No description provided for @healthPermissionInfo1.
  ///
  /// In ko, this message translates to:
  /// **'• 걸음 수 및 칼로리 소모량 자동 동기화'**
  String get healthPermissionInfo1;

  /// No description provided for @healthPermissionInfo2.
  ///
  /// In ko, this message translates to:
  /// **'• 운동 기록 자동 가져오기'**
  String get healthPermissionInfo2;

  /// No description provided for @healthPermissionInfo3.
  ///
  /// In ko, this message translates to:
  /// **'• 더 정확한 칼로리 관리'**
  String get healthPermissionInfo3;

  /// No description provided for @healthPermissionDenyInfo.
  ///
  /// In ko, this message translates to:
  /// **'권한을 거부해도 앱의 기본 기능은 사용할 수 있습니다.'**
  String get healthPermissionDenyInfo;

  /// No description provided for @later.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get later;

  /// No description provided for @allowPermission.
  ///
  /// In ko, this message translates to:
  /// **'권한 허용'**
  String get allowPermission;

  /// No description provided for @permissionSelect.
  ///
  /// In ko, this message translates to:
  /// **'권한 선택'**
  String get permissionSelect;

  /// No description provided for @allowAndSync.
  ///
  /// In ko, this message translates to:
  /// **'권한 허용하고 동기화'**
  String get allowAndSync;

  /// No description provided for @setupLater.
  ///
  /// In ko, this message translates to:
  /// **'나중에 설정하기'**
  String get setupLater;

  /// No description provided for @history.
  ///
  /// In ko, this message translates to:
  /// **'기록'**
  String get history;

  /// No description provided for @errorOccurred.
  ///
  /// In ko, this message translates to:
  /// **'오류 발생'**
  String get errorOccurred;

  /// No description provided for @noRecords.
  ///
  /// In ko, this message translates to:
  /// **'아직 기록이 없습니다.'**
  String get noRecords;

  /// No description provided for @pleaseSelectLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어를 선택해주세요'**
  String get pleaseSelectLanguage;

  /// No description provided for @homeTitle.
  ///
  /// In ko, this message translates to:
  /// **'치유하다 VitaBuddy'**
  String get homeTitle;

  /// No description provided for @mealRecord.
  ///
  /// In ko, this message translates to:
  /// **'식사 기록'**
  String get mealRecord;

  /// No description provided for @viewRecords.
  ///
  /// In ko, this message translates to:
  /// **'기록 보기'**
  String get viewRecords;

  /// No description provided for @developerTest.
  ///
  /// In ko, this message translates to:
  /// **'개발자 테스트 화면'**
  String get developerTest;

  /// No description provided for @mealGuidance.
  ///
  /// In ko, this message translates to:
  /// **'식사 안내'**
  String get mealGuidance;

  /// No description provided for @nextMeal.
  ///
  /// In ko, this message translates to:
  /// **'다음 식사'**
  String get nextMeal;

  /// No description provided for @moreNeeded.
  ///
  /// In ko, this message translates to:
  /// **'더 필요'**
  String get moreNeeded;

  /// No description provided for @reduce.
  ///
  /// In ko, this message translates to:
  /// **'줄이세요'**
  String get reduce;

  /// No description provided for @until.
  ///
  /// In ko, this message translates to:
  /// **'까지'**
  String get until;

  /// No description provided for @sleepMode.
  ///
  /// In ko, this message translates to:
  /// **'수면 모드'**
  String get sleepMode;

  /// No description provided for @connected.
  ///
  /// In ko, this message translates to:
  /// **'연결됨'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In ko, this message translates to:
  /// **'연결 안됨'**
  String get disconnected;

  /// No description provided for @notConnected.
  ///
  /// In ko, this message translates to:
  /// **'연결 안됨'**
  String get notConnected;

  /// No description provided for @justSynced.
  ///
  /// In ko, this message translates to:
  /// **'방금 동기화'**
  String get justSynced;

  /// No description provided for @syncedJustNow.
  ///
  /// In ko, this message translates to:
  /// **'방금 동기화'**
  String get syncedJustNow;

  /// No description provided for @syncedMinutesAgo.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분 전'**
  String syncedMinutesAgo(int minutes);

  /// No description provided for @syncedHoursAgo.
  ///
  /// In ko, this message translates to:
  /// **'{hours}시간 전'**
  String syncedHoursAgo(int hours);

  /// No description provided for @minutesAgo.
  ///
  /// In ko, this message translates to:
  /// **'분 전'**
  String get minutesAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In ko, this message translates to:
  /// **'시간 전'**
  String get hoursAgo;

  /// No description provided for @minutesShort.
  ///
  /// In ko, this message translates to:
  /// **'분'**
  String get minutesShort;

  /// No description provided for @changeClothingColor.
  ///
  /// In ko, this message translates to:
  /// **'옷 색상 변경'**
  String get changeClothingColor;

  /// No description provided for @walking.
  ///
  /// In ko, this message translates to:
  /// **'걷기'**
  String get walking;

  /// No description provided for @running.
  ///
  /// In ko, this message translates to:
  /// **'달리기'**
  String get running;

  /// No description provided for @cycling.
  ///
  /// In ko, this message translates to:
  /// **'자전거'**
  String get cycling;

  /// No description provided for @swimming.
  ///
  /// In ko, this message translates to:
  /// **'수영'**
  String get swimming;

  /// No description provided for @user.
  ///
  /// In ko, this message translates to:
  /// **'사용자'**
  String get user;

  /// No description provided for @homeGreetingFormat.
  ///
  /// In ko, this message translates to:
  /// **'{greeting}, {user}님!'**
  String homeGreetingFormat(String greeting, String user);

  /// No description provided for @reduceIntake.
  ///
  /// In ko, this message translates to:
  /// **'줄이세요'**
  String get reduceIntake;

  /// No description provided for @profileSetup.
  ///
  /// In ko, this message translates to:
  /// **'프로필 설정'**
  String get profileSetup;

  /// No description provided for @stepBasicInfo.
  ///
  /// In ko, this message translates to:
  /// **'기본 정보'**
  String get stepBasicInfo;

  /// No description provided for @basicInfoDesc.
  ///
  /// In ko, this message translates to:
  /// **'정확한 칼로리 계산을 위해 기본 정보를 입력해주세요.'**
  String get basicInfoDesc;

  /// No description provided for @nameHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 홍길동'**
  String get nameHint;

  /// No description provided for @yearsOld.
  ///
  /// In ko, this message translates to:
  /// **'세'**
  String get yearsOld;

  /// No description provided for @ageUnit.
  ///
  /// In ko, this message translates to:
  /// **'세'**
  String get ageUnit;

  /// No description provided for @stepMealPattern.
  ///
  /// In ko, this message translates to:
  /// **'식사 패턴 설정'**
  String get stepMealPattern;

  /// No description provided for @mealPatternSetup.
  ///
  /// In ko, this message translates to:
  /// **'식사 패턴 설정'**
  String get mealPatternSetup;

  /// No description provided for @mealPatternDesc.
  ///
  /// In ko, this message translates to:
  /// **'하루 식사 패턴을 설정하면 맞춤 알림을 받을 수 있어요.'**
  String get mealPatternDesc;

  /// No description provided for @meals2.
  ///
  /// In ko, this message translates to:
  /// **'2식'**
  String get meals2;

  /// No description provided for @meals3.
  ///
  /// In ko, this message translates to:
  /// **'3식 (권장)'**
  String get meals3;

  /// No description provided for @meals4.
  ///
  /// In ko, this message translates to:
  /// **'4식+'**
  String get meals4;

  /// No description provided for @meals4Plus.
  ///
  /// In ko, this message translates to:
  /// **'4식+'**
  String get meals4Plus;

  /// No description provided for @mealTimeSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정된 식사 시간'**
  String get mealTimeSettings;

  /// No description provided for @configuredMealTimes.
  ///
  /// In ko, this message translates to:
  /// **'설정된 식사 시간'**
  String get configuredMealTimes;

  /// No description provided for @stepSomatotype.
  ///
  /// In ko, this message translates to:
  /// **'체질 선택'**
  String get stepSomatotype;

  /// No description provided for @somatotypeSelection.
  ///
  /// In ko, this message translates to:
  /// **'체질 선택'**
  String get somatotypeSelection;

  /// No description provided for @somatotypeDesc.
  ///
  /// In ko, this message translates to:
  /// **'당신의 체질 타입을 선택하세요. 대사율 계산에 반영됩니다.'**
  String get somatotypeDesc;

  /// No description provided for @dontKnow.
  ///
  /// In ko, this message translates to:
  /// **'잘 모르겠어요'**
  String get dontKnow;

  /// No description provided for @unsure.
  ///
  /// In ko, this message translates to:
  /// **'잘 모르겠어요'**
  String get unsure;

  /// No description provided for @stepBodyShape.
  ///
  /// In ko, this message translates to:
  /// **'체형 선택'**
  String get stepBodyShape;

  /// No description provided for @bodyShapeSelection.
  ///
  /// In ko, this message translates to:
  /// **'체형 선택'**
  String get bodyShapeSelection;

  /// No description provided for @bodyShapeDesc.
  ///
  /// In ko, this message translates to:
  /// **'살이 주로 어디에 찌나요? 아바타 표현에 반영됩니다.'**
  String get bodyShapeDesc;

  /// No description provided for @stepDetailInfo.
  ///
  /// In ko, this message translates to:
  /// **'상세 정보'**
  String get stepDetailInfo;

  /// No description provided for @detailInfoDesc.
  ///
  /// In ko, this message translates to:
  /// **'추가 정보로 더 정확한 칼로리 계산이 가능합니다.'**
  String get detailInfoDesc;

  /// No description provided for @muscleType.
  ///
  /// In ko, this message translates to:
  /// **'근육량'**
  String get muscleType;

  /// No description provided for @muscleInfo.
  ///
  /// In ko, this message translates to:
  /// **'근육량이 많을수록 기초대사량이 높아집니다.'**
  String get muscleInfo;

  /// No description provided for @stepPersonality.
  ///
  /// In ko, this message translates to:
  /// **'간단한 성격 테스트'**
  String get stepPersonality;

  /// No description provided for @personalityDesc.
  ///
  /// In ko, this message translates to:
  /// **'일상 활동량 계산에 반영됩니다. (NEAT)'**
  String get personalityDesc;

  /// No description provided for @questionExtraversion.
  ///
  /// In ko, this message translates to:
  /// **'평소 활기차고 외향적인가요?'**
  String get questionExtraversion;

  /// No description provided for @questionConscientiousness.
  ///
  /// In ko, this message translates to:
  /// **'계획적이고 규칙적인가요?'**
  String get questionConscientiousness;

  /// No description provided for @questionNeuroticism.
  ///
  /// In ko, this message translates to:
  /// **'앉아 있을 때 자주 움직이나요?\n(손동작, 다리 떨기 등)'**
  String get questionNeuroticism;

  /// No description provided for @personalityInfo.
  ///
  /// In ko, this message translates to:
  /// **'성격 특성에 따라 일일 권장 칼로리가 조정됩니다.'**
  String get personalityInfo;

  /// No description provided for @no.
  ///
  /// In ko, this message translates to:
  /// **'아니다'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In ko, this message translates to:
  /// **'그렇다'**
  String get yes;

  /// No description provided for @prev.
  ///
  /// In ko, this message translates to:
  /// **'이전'**
  String get prev;

  /// No description provided for @somatotypeEctomorph.
  ///
  /// In ko, this message translates to:
  /// **'외배엽형 (마른 체질)'**
  String get somatotypeEctomorph;

  /// No description provided for @somatotypeEctomorphDesc.
  ///
  /// In ko, this message translates to:
  /// **'빠른 신진대사로 살이 잘 안 찌지만, 근육을 만들기 어렵습니다.'**
  String get somatotypeEctomorphDesc;

  /// No description provided for @somatotypeMesomorph.
  ///
  /// In ko, this message translates to:
  /// **'중배엽형 (근육 체질)'**
  String get somatotypeMesomorph;

  /// No description provided for @somatotypeMesomorphDesc.
  ///
  /// In ko, this message translates to:
  /// **'근육을 쉽게 만들고, 체중 조절이 비교적 용이합니다.'**
  String get somatotypeMesomorphDesc;

  /// No description provided for @somatotypeEndomorph.
  ///
  /// In ko, this message translates to:
  /// **'내배엽형 (살찌기 쉬운 체질)'**
  String get somatotypeEndomorph;

  /// No description provided for @somatotypeEndomorphDesc.
  ///
  /// In ko, this message translates to:
  /// **'지방이 쉽게 축적되고, 체중 감량이 어려울 수 있습니다.'**
  String get somatotypeEndomorphDesc;

  /// No description provided for @somatotypeMixed.
  ///
  /// In ko, this message translates to:
  /// **'혼합형'**
  String get somatotypeMixed;

  /// No description provided for @somatotypeMixedDesc.
  ///
  /// In ko, this message translates to:
  /// **'여러 체질의 특성을 가지고 있습니다.'**
  String get somatotypeMixedDesc;

  /// No description provided for @bodyShapeApple.
  ///
  /// In ko, this message translates to:
  /// **'🍎 사과형'**
  String get bodyShapeApple;

  /// No description provided for @bodyShapeAppleDesc.
  ///
  /// In ko, this message translates to:
  /// **'상체와 복부에 지방이 주로 축적됩니다.'**
  String get bodyShapeAppleDesc;

  /// No description provided for @bodyShapePear.
  ///
  /// In ko, this message translates to:
  /// **'🍐 배형'**
  String get bodyShapePear;

  /// No description provided for @bodyShapePearDesc.
  ///
  /// In ko, this message translates to:
  /// **'하체(엉덩이, 허벅지)에 지방이 주로 축적됩니다.'**
  String get bodyShapePearDesc;

  /// No description provided for @bodyShapeHourglass.
  ///
  /// In ko, this message translates to:
  /// **'⏳ 모래시계형'**
  String get bodyShapeHourglass;

  /// No description provided for @bodyShapeHourglassDesc.
  ///
  /// In ko, this message translates to:
  /// **'가슴과 엉덩이가 비슷하고 허리가 잘록합니다.'**
  String get bodyShapeHourglassDesc;

  /// No description provided for @bodyShapeRectangle.
  ///
  /// In ko, this message translates to:
  /// **'📏 직사각형'**
  String get bodyShapeRectangle;

  /// No description provided for @bodyShapeRectangleDesc.
  ///
  /// In ko, this message translates to:
  /// **'전체적으로 평면적이고 균등한 체형입니다.'**
  String get bodyShapeRectangleDesc;

  /// No description provided for @bodyShapeInvertedTriangle.
  ///
  /// In ko, this message translates to:
  /// **'🔺 역삼각형'**
  String get bodyShapeInvertedTriangle;

  /// No description provided for @bodyShapeInvertedTriangleDesc.
  ///
  /// In ko, this message translates to:
  /// **'어깨가 넓고 엉덩이가 좁은 체형입니다.'**
  String get bodyShapeInvertedTriangleDesc;

  /// No description provided for @muscleLow.
  ///
  /// In ko, this message translates to:
  /// **'적음'**
  String get muscleLow;

  /// No description provided for @muscleMedium.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get muscleMedium;

  /// No description provided for @muscleHigh.
  ///
  /// In ko, this message translates to:
  /// **'많음'**
  String get muscleHigh;

  /// No description provided for @mealBreakfast.
  ///
  /// In ko, this message translates to:
  /// **'아침'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In ko, this message translates to:
  /// **'점심'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In ko, this message translates to:
  /// **'저녁'**
  String get mealDinner;

  /// No description provided for @mealSnackMorning.
  ///
  /// In ko, this message translates to:
  /// **'오전간식'**
  String get mealSnackMorning;

  /// No description provided for @mealSnackAfternoon.
  ///
  /// In ko, this message translates to:
  /// **'오후간식'**
  String get mealSnackAfternoon;

  /// No description provided for @mealSnackEvening.
  ///
  /// In ko, this message translates to:
  /// **'저녁간식'**
  String get mealSnackEvening;

  /// No description provided for @mealSnack.
  ///
  /// In ko, this message translates to:
  /// **'간식'**
  String get mealSnack;

  /// No description provided for @guidanceNoPattern.
  ///
  /// In ko, this message translates to:
  /// **'식사 패턴을 설정하면 더 정확한 안내를 받을 수 있어요!'**
  String get guidanceNoPattern;

  /// No description provided for @guidanceDailyGoal.
  ///
  /// In ko, this message translates to:
  /// **'하루 목표: {goal}kcal'**
  String guidanceDailyGoal(int goal);

  /// No description provided for @guidanceOvereating.
  ///
  /// In ko, this message translates to:
  /// **'⚠️ {meal}({time}) 전인데 벌써 {current}kcal를 드셨네요! 과식에 주의하세요.'**
  String guidanceOvereating(String meal, String time, int current);

  /// No description provided for @guidanceFasting.
  ///
  /// In ko, this message translates to:
  /// **'💡 {meal}({time})까지 공복 유지를 권장해요'**
  String guidanceFasting(String meal, String time);

  /// No description provided for @guidanceFinished.
  ///
  /// In ko, this message translates to:
  /// **'✅ 오늘 하루 식사를 잘 마쳤습니다!'**
  String get guidanceFinished;

  /// No description provided for @guidanceLow.
  ///
  /// In ko, this message translates to:
  /// **'💡 하루 권장량보다 {diff}kcal 부족합니다. 간식을 드세요!'**
  String guidanceLow(int diff);

  /// No description provided for @guidanceHigh.
  ///
  /// In ko, this message translates to:
  /// **'⚠️ 하루 권장량보다 {diff}kcal 초과했습니다.'**
  String guidanceHigh(int diff);

  /// No description provided for @guidanceAdequate.
  ///
  /// In ko, this message translates to:
  /// **'✅ 훌륭해요! {context} 적정량을 섭취했습니다.'**
  String guidanceAdequate(String context);

  /// No description provided for @guidanceLowMid.
  ///
  /// In ko, this message translates to:
  /// **'⚠️ {context} 약 {recommended}kcal 섭취가 권장되지만,\n현재 {current}kcal입니다. 다음 식사에서 조금 더 드세요!'**
  String guidanceLowMid(String context, int recommended, int current);

  /// No description provided for @guidanceHighMid.
  ///
  /// In ko, this message translates to:
  /// **'⚠️ {context} {recommended}kcal가 권장되는데\n{current}kcal를 섭취했습니다. 다음 식사는 가볍게!'**
  String guidanceHighMid(String context, int recommended, int current);

  /// No description provided for @contextCurrent.
  ///
  /// In ko, this message translates to:
  /// **'현재'**
  String get contextCurrent;

  /// No description provided for @contextUntilMeal.
  ///
  /// In ko, this message translates to:
  /// **'{meal}까지'**
  String contextUntilMeal(String meal);

  /// No description provided for @healthPermissionWarning.
  ///
  /// In ko, this message translates to:
  /// **'헬스 데이터 권한이 필요합니다'**
  String get healthPermissionWarning;

  /// No description provided for @syncSuccess.
  ///
  /// In ko, this message translates to:
  /// **'✅ {count}개의 운동 데이터 동기화 완료'**
  String syncSuccess(Object count);

  /// No description provided for @syncError.
  ///
  /// In ko, this message translates to:
  /// **'동기화 중 오류가 발생했습니다: {error}'**
  String syncError(Object error);

  /// No description provided for @dataLoadError.
  ///
  /// In ko, this message translates to:
  /// **'데이터 로드 실패: {error}'**
  String dataLoadError(Object error);

  /// No description provided for @catTotal.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get catTotal;

  /// No description provided for @catFruit.
  ///
  /// In ko, this message translates to:
  /// **'과일'**
  String get catFruit;

  /// No description provided for @catStaple.
  ///
  /// In ko, this message translates to:
  /// **'주식'**
  String get catStaple;

  /// No description provided for @catSoup.
  ///
  /// In ko, this message translates to:
  /// **'국'**
  String get catSoup;

  /// No description provided for @catMeat.
  ///
  /// In ko, this message translates to:
  /// **'육류'**
  String get catMeat;

  /// No description provided for @catFish.
  ///
  /// In ko, this message translates to:
  /// **'어류'**
  String get catFish;

  /// No description provided for @catSide.
  ///
  /// In ko, this message translates to:
  /// **'반찬'**
  String get catSide;

  /// No description provided for @catVegetable.
  ///
  /// In ko, this message translates to:
  /// **'야채'**
  String get catVegetable;

  /// No description provided for @catDairy.
  ///
  /// In ko, this message translates to:
  /// **'유제품'**
  String get catDairy;

  /// No description provided for @catBakery.
  ///
  /// In ko, this message translates to:
  /// **'제과'**
  String get catBakery;

  /// No description provided for @catSnack.
  ///
  /// In ko, this message translates to:
  /// **'과자'**
  String get catSnack;

  /// No description provided for @catBeverage.
  ///
  /// In ko, this message translates to:
  /// **'음료'**
  String get catBeverage;

  /// No description provided for @catEtc.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get catEtc;

  /// No description provided for @quickActionsTitle.
  ///
  /// In ko, this message translates to:
  /// **'건강 챙기기'**
  String get quickActionsTitle;

  /// No description provided for @todayHealthNote.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 건강 노트'**
  String get todayHealthNote;

  /// No description provided for @bmiUnderweight.
  ///
  /// In ko, this message translates to:
  /// **'저체중'**
  String get bmiUnderweight;

  /// No description provided for @bmiNormal.
  ///
  /// In ko, this message translates to:
  /// **'정상'**
  String get bmiNormal;

  /// No description provided for @bmiOverweight.
  ///
  /// In ko, this message translates to:
  /// **'과체중'**
  String get bmiOverweight;

  /// No description provided for @bmiObese.
  ///
  /// In ko, this message translates to:
  /// **'비만'**
  String get bmiObese;

  /// No description provided for @motivationOverLimit.
  ///
  /// In ko, this message translates to:
  /// **'괜찮아요, 내일 조금 더 움직이면 돼요. 🌿'**
  String get motivationOverLimit;

  /// No description provided for @motivationNearLimit.
  ///
  /// In ko, this message translates to:
  /// **'오늘 하루, 정말 열심히 보냈군요! ☀️'**
  String get motivationNearLimit;

  /// No description provided for @motivationGood.
  ///
  /// In ko, this message translates to:
  /// **'당신의 속도대로 가고 있어요. 아주 잘하고 있습니다.'**
  String get motivationGood;

  /// No description provided for @mealRecordButton.
  ///
  /// In ko, this message translates to:
  /// **'식사 기록'**
  String get mealRecordButton;

  /// No description provided for @exerciseRecordButton.
  ///
  /// In ko, this message translates to:
  /// **'운동 기록'**
  String get exerciseRecordButton;

  /// No description provided for @weightRecordButton.
  ///
  /// In ko, this message translates to:
  /// **'체중 기록'**
  String get weightRecordButton;

  /// No description provided for @bmiLabel.
  ///
  /// In ko, this message translates to:
  /// **'BMI'**
  String get bmiLabel;

  /// No description provided for @weightLabel.
  ///
  /// In ko, this message translates to:
  /// **'체중'**
  String get weightLabel;

  /// No description provided for @dailyGoalLabel.
  ///
  /// In ko, this message translates to:
  /// **'하루 권장 칼로리'**
  String get dailyGoalLabel;

  /// No description provided for @currentLabel.
  ///
  /// In ko, this message translates to:
  /// **'현재'**
  String get currentLabel;

  /// No description provided for @todayLabel.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get todayLabel;

  /// No description provided for @totalLabel.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get totalLabel;

  /// No description provided for @netCaloriesLabel.
  ///
  /// In ko, this message translates to:
  /// **'현재 칼로리'**
  String get netCaloriesLabel;

  /// No description provided for @surplusLabel.
  ///
  /// In ko, this message translates to:
  /// **'잉여'**
  String get surplusLabel;

  /// No description provided for @deficitLabel.
  ///
  /// In ko, this message translates to:
  /// **'부족'**
  String get deficitLabel;

  /// No description provided for @allow.
  ///
  /// In ko, this message translates to:
  /// **'허용'**
  String get allow;

  /// No description provided for @deny.
  ///
  /// In ko, this message translates to:
  /// **'거부'**
  String get deny;

  /// No description provided for @healthPlatformName.
  ///
  /// In ko, this message translates to:
  /// **'헬스'**
  String get healthPlatformName;

  /// No description provided for @exercise.
  ///
  /// In ko, this message translates to:
  /// **'운동'**
  String get exercise;

  /// No description provided for @kcalUnit.
  ///
  /// In ko, this message translates to:
  /// **'kcal'**
  String get kcalUnit;

  /// No description provided for @kgUnit.
  ///
  /// In ko, this message translates to:
  /// **'kg'**
  String get kgUnit;

  /// No description provided for @kmUnit.
  ///
  /// In ko, this message translates to:
  /// **'km'**
  String get kmUnit;

  /// No description provided for @intakeTooltip.
  ///
  /// In ko, this message translates to:
  /// **'섭취: {current} kcal'**
  String intakeTooltip(int current);

  /// No description provided for @exerciseBurnTooltip.
  ///
  /// In ko, this message translates to:
  /// **'운동: -{burned} kcal'**
  String exerciseBurnTooltip(int burned);

  /// No description provided for @tdeeBurnTooltip.
  ///
  /// In ko, this message translates to:
  /// **'TDEE: -{tdee} kcal'**
  String tdeeBurnTooltip(int tdee);

  /// No description provided for @totalBurnTooltip.
  ///
  /// In ko, this message translates to:
  /// **'소모 합계: -{total} kcal'**
  String totalBurnTooltip(int total);

  /// No description provided for @currentCaloriesTooltip.
  ///
  /// In ko, this message translates to:
  /// **'현재 칼로리'**
  String get currentCaloriesTooltip;

  /// No description provided for @remainingTooltip.
  ///
  /// In ko, this message translates to:
  /// **'남은 여유: {remaining} kcal'**
  String remainingTooltip(int remaining);

  /// No description provided for @current.
  ///
  /// In ko, this message translates to:
  /// **'현재'**
  String get current;

  /// No description provided for @normal.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get normal;

  /// No description provided for @total.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get total;

  /// No description provided for @today.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get today;

  /// No description provided for @deficit.
  ///
  /// In ko, this message translates to:
  /// **'부족'**
  String get deficit;

  /// No description provided for @calorieGoalSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'목표 칼로리 설정'**
  String get calorieGoalSettingsTitle;

  /// No description provided for @selectGoalMode.
  ///
  /// In ko, this message translates to:
  /// **'목표 모드 선택'**
  String get selectGoalMode;

  /// No description provided for @dailyCalorieGoal.
  ///
  /// In ko, this message translates to:
  /// **'일일 목표 칼로리'**
  String get dailyCalorieGoal;

  /// No description provided for @minBmr.
  ///
  /// In ko, this message translates to:
  /// **'최소(BMR)'**
  String get minBmr;

  /// No description provided for @maintainTdee.
  ///
  /// In ko, this message translates to:
  /// **'유지(TDEE)'**
  String get maintainTdee;

  /// No description provided for @max.
  ///
  /// In ko, this message translates to:
  /// **'최대'**
  String get max;

  /// No description provided for @bmrLabel.
  ///
  /// In ko, this message translates to:
  /// **'내 기초대사량 (BMR)'**
  String get bmrLabel;

  /// No description provided for @tdeeLabel.
  ///
  /// In ko, this message translates to:
  /// **'내 활동대사량 (TDEE)'**
  String get tdeeLabel;

  /// No description provided for @bmrWarning.
  ///
  /// In ko, this message translates to:
  /// **'💡 기초대사량(BMR) 이하로 섭취하면 건강에 해로울 수 있어 최소 목표로 설정됩니다.'**
  String get bmrWarning;

  /// No description provided for @lossMode.
  ///
  /// In ko, this message translates to:
  /// **'감량'**
  String get lossMode;

  /// No description provided for @maintainMode.
  ///
  /// In ko, this message translates to:
  /// **'유지'**
  String get maintainMode;

  /// No description provided for @bulkMode.
  ///
  /// In ko, this message translates to:
  /// **'증량'**
  String get bulkMode;

  /// No description provided for @weightMaintain.
  ///
  /// In ko, this message translates to:
  /// **'현재 체중 유지'**
  String get weightMaintain;

  /// No description provided for @weightLossPrediction.
  ///
  /// In ko, this message translates to:
  /// **'주당 약 {weight}kg 감량 예상'**
  String weightLossPrediction(String weight);

  /// No description provided for @weightGainPrediction.
  ///
  /// In ko, this message translates to:
  /// **'주당 약 {weight}kg 증량 예상'**
  String weightGainPrediction(String weight);

  /// No description provided for @maintainDesc.
  ///
  /// In ko, this message translates to:
  /// **'건강한 밸런스를 유지하고 있어요!'**
  String get maintainDesc;

  /// No description provided for @lossDesc.
  ///
  /// In ko, this message translates to:
  /// **'꾸준함이 가장 중요해요. 화이팅!'**
  String get lossDesc;

  /// No description provided for @bulkDesc.
  ///
  /// In ko, this message translates to:
  /// **'근육량 증가를 위해 운동도 병행해주세요!'**
  String get bulkDesc;

  /// No description provided for @saveGoal.
  ///
  /// In ko, this message translates to:
  /// **'저장하기'**
  String get saveGoal;

  /// No description provided for @goalSaved.
  ///
  /// In ko, this message translates to:
  /// **'목표가 저장되었습니다.'**
  String get goalSaved;

  /// No description provided for @mealLunchPreset.
  ///
  /// In ko, this message translates to:
  /// **'점심'**
  String get mealLunchPreset;

  /// No description provided for @mealDinnerPreset.
  ///
  /// In ko, this message translates to:
  /// **'저녁'**
  String get mealDinnerPreset;

  /// No description provided for @mealBreakfastPreset.
  ///
  /// In ko, this message translates to:
  /// **'아침'**
  String get mealBreakfastPreset;

  /// No description provided for @mealSnackMorningPreset.
  ///
  /// In ko, this message translates to:
  /// **'오전간식'**
  String get mealSnackMorningPreset;

  /// No description provided for @mealSnackAfternoonPreset.
  ///
  /// In ko, this message translates to:
  /// **'오후간식'**
  String get mealSnackAfternoonPreset;

  /// No description provided for @appTitleMain.
  ///
  /// In ko, this message translates to:
  /// **'치유하다 VitaBuddy'**
  String get appTitleMain;

  /// No description provided for @clothingSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'옷 색상 변경'**
  String get clothingSettingsTitle;

  /// No description provided for @preview.
  ///
  /// In ko, this message translates to:
  /// **'미리보기'**
  String get preview;

  /// No description provided for @colorThemeSelection.
  ///
  /// In ko, this message translates to:
  /// **'색상 테마 선택'**
  String get colorThemeSelection;

  /// No description provided for @apply.
  ///
  /// In ko, this message translates to:
  /// **'적용'**
  String get apply;

  /// No description provided for @clothingColorChanged.
  ///
  /// In ko, this message translates to:
  /// **'옷 색상이 변경되었습니다'**
  String get clothingColorChanged;

  /// No description provided for @discardChangesConfirm.
  ///
  /// In ko, this message translates to:
  /// **'변경한 내용을 취소하고 나가시겠습니까?'**
  String get discardChangesConfirm;

  /// No description provided for @stay.
  ///
  /// In ko, this message translates to:
  /// **'머무르기'**
  String get stay;

  /// No description provided for @exit.
  ///
  /// In ko, this message translates to:
  /// **'나가기'**
  String get exit;

  /// No description provided for @loadFoodsFailed.
  ///
  /// In ko, this message translates to:
  /// **'음식 데이터를 불러오는데 실패했습니다'**
  String get loadFoodsFailed;

  /// No description provided for @amount.
  ///
  /// In ko, this message translates to:
  /// **'양'**
  String get amount;

  /// No description provided for @servings.
  ///
  /// In ko, this message translates to:
  /// **'인분'**
  String get servings;

  /// No description provided for @consumedOn.
  ///
  /// In ko, this message translates to:
  /// **'섭취일: {date}'**
  String consumedOn(String date);

  /// No description provided for @unknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없음'**
  String get unknown;

  /// No description provided for @addFood.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get addFood;

  /// No description provided for @quantityHint.
  ///
  /// In ko, this message translates to:
  /// **'수량'**
  String get quantityHint;

  /// No description provided for @servingsHint.
  ///
  /// In ko, this message translates to:
  /// **'인분'**
  String get servingsHint;

  /// No description provided for @recentEaten.
  ///
  /// In ko, this message translates to:
  /// **'최근 섭취: {date}'**
  String recentEaten(Object date);

  /// No description provided for @addFoodButton.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get addFoodButton;

  /// No description provided for @mealsTab.
  ///
  /// In ko, this message translates to:
  /// **'식사'**
  String get mealsTab;

  /// No description provided for @exercisesTab.
  ///
  /// In ko, this message translates to:
  /// **'운동'**
  String get exercisesTab;

  /// No description provided for @summaryTab.
  ///
  /// In ko, this message translates to:
  /// **'요약'**
  String get summaryTab;

  /// No description provided for @noMealRecords.
  ///
  /// In ko, this message translates to:
  /// **'기록된 식사가 없습니다.'**
  String get noMealRecords;

  /// No description provided for @noExerciseRecords.
  ///
  /// In ko, this message translates to:
  /// **'기록된 운동이 없습니다.'**
  String get noExerciseRecords;

  /// No description provided for @unknownFood.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 음식'**
  String get unknownFood;

  /// No description provided for @totalIntakeCalories.
  ///
  /// In ko, this message translates to:
  /// **'총 섭취 칼로리'**
  String get totalIntakeCalories;

  /// No description provided for @totalBurnedCalories.
  ///
  /// In ko, this message translates to:
  /// **'총 소비 칼로리'**
  String get totalBurnedCalories;

  /// No description provided for @recordedWeight.
  ///
  /// In ko, this message translates to:
  /// **'기록된 체중'**
  String get recordedWeight;

  /// No description provided for @noRecord.
  ///
  /// In ko, this message translates to:
  /// **'기록 없음'**
  String get noRecord;

  /// No description provided for @netCalorieChange.
  ///
  /// In ko, this message translates to:
  /// **'순수 칼로리 변동'**
  String get netCalorieChange;

  /// No description provided for @mealPatternTitle.
  ///
  /// In ko, this message translates to:
  /// **'하루 식사 패턴을 알려주세요'**
  String get mealPatternTitle;

  /// No description provided for @mealPatternSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'맞춤형 알림을 위해 식사 시간을 설정해주세요'**
  String get mealPatternSubtitle;

  /// No description provided for @meals2Preset.
  ///
  /// In ko, this message translates to:
  /// **'2식'**
  String get meals2Preset;

  /// No description provided for @meals3Preset.
  ///
  /// In ko, this message translates to:
  /// **'3식 (권장)'**
  String get meals3Preset;

  /// No description provided for @meals4Preset.
  ///
  /// In ko, this message translates to:
  /// **'4식+'**
  String get meals4Preset;

  /// No description provided for @customPreset.
  ///
  /// In ko, this message translates to:
  /// **'커스텀'**
  String get customPreset;

  /// No description provided for @mealTimes.
  ///
  /// In ko, this message translates to:
  /// **'식사 시간'**
  String get mealTimes;

  /// No description provided for @addMeal.
  ///
  /// In ko, this message translates to:
  /// **'식사 추가'**
  String get addMeal;

  /// No description provided for @mealNameHint.
  ///
  /// In ko, this message translates to:
  /// **'식사 이름'**
  String get mealNameHint;

  /// No description provided for @snackNotifications.
  ///
  /// In ko, this message translates to:
  /// **'🍎 간식 알림'**
  String get snackNotifications;

  /// No description provided for @snackNotificationsDesc.
  ///
  /// In ko, this message translates to:
  /// **'오전/오후 간식 시간 알림을 받을 수 있어요'**
  String get snackNotificationsDesc;

  /// No description provided for @lunch.
  ///
  /// In ko, this message translates to:
  /// **'점심'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In ko, this message translates to:
  /// **'저녁'**
  String get dinner;

  /// No description provided for @breakfast.
  ///
  /// In ko, this message translates to:
  /// **'아침'**
  String get breakfast;

  /// No description provided for @morningSnack.
  ///
  /// In ko, this message translates to:
  /// **'오전 간식'**
  String get morningSnack;

  /// No description provided for @mealNumber.
  ///
  /// In ko, this message translates to:
  /// **'식사 {number}'**
  String mealNumber(Object number);

  /// No description provided for @energyAlertSensitivity.
  ///
  /// In ko, this message translates to:
  /// **'⚡ 에너지 알림 민감도'**
  String get energyAlertSensitivity;

  /// No description provided for @mealNotifications.
  ///
  /// In ko, this message translates to:
  /// **'📱 식사 알림'**
  String get mealNotifications;

  /// No description provided for @exerciseNotifications.
  ///
  /// In ko, this message translates to:
  /// **'🏃 운동 알림'**
  String get exerciseNotifications;

  /// No description provided for @weightMeasurementNotifications.
  ///
  /// In ko, this message translates to:
  /// **'⚖️ 체중 측정 알림'**
  String get weightMeasurementNotifications;

  /// No description provided for @breakfastMeal.
  ///
  /// In ko, this message translates to:
  /// **'아침 식사'**
  String get breakfastMeal;

  /// No description provided for @lunchMeal.
  ///
  /// In ko, this message translates to:
  /// **'점심 식사'**
  String get lunchMeal;

  /// No description provided for @dinnerMeal.
  ///
  /// In ko, this message translates to:
  /// **'저녁 식사'**
  String get dinnerMeal;

  /// No description provided for @afternoonSnack.
  ///
  /// In ko, this message translates to:
  /// **'오후 간식'**
  String get afternoonSnack;

  /// No description provided for @weightMeasurement.
  ///
  /// In ko, this message translates to:
  /// **'체중 측정'**
  String get weightMeasurement;

  /// No description provided for @exerciseTime.
  ///
  /// In ko, this message translates to:
  /// **'운동 시간'**
  String get exerciseTime;

  /// No description provided for @selectDays.
  ///
  /// In ko, this message translates to:
  /// **'요일 선택:'**
  String get selectDays;

  /// No description provided for @monday.
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In ko, this message translates to:
  /// **'화'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In ko, this message translates to:
  /// **'수'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In ko, this message translates to:
  /// **'목'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In ko, this message translates to:
  /// **'금'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In ko, this message translates to:
  /// **'토'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get sunday;

  /// No description provided for @energyDeficitAlertFrequency.
  ///
  /// In ko, this message translates to:
  /// **'에너지 부족 알림 빈도'**
  String get energyDeficitAlertFrequency;

  /// No description provided for @adjustAlertFrequencyDesc.
  ///
  /// In ko, this message translates to:
  /// **'설정에 따라 알림을 더 자주 받거나 줄일 수 있습니다.'**
  String get adjustAlertFrequencyDesc;

  /// No description provided for @insensitive.
  ///
  /// In ko, this message translates to:
  /// **'둔감'**
  String get insensitive;

  /// No description provided for @sensitive.
  ///
  /// In ko, this message translates to:
  /// **'민감'**
  String get sensitive;

  /// No description provided for @minimizeNotifications.
  ///
  /// In ko, this message translates to:
  /// **'알림 최소화'**
  String get minimizeNotifications;

  /// No description provided for @defaultSettings.
  ///
  /// In ko, this message translates to:
  /// **'기본 설정'**
  String get defaultSettings;

  /// No description provided for @frequentNotifications.
  ///
  /// In ko, this message translates to:
  /// **'자주 알림'**
  String get frequentNotifications;

  /// No description provided for @notificationPermissionGranted.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한이 허용됨'**
  String get notificationPermissionGranted;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한이 필요합니다'**
  String get notificationPermissionRequired;

  /// No description provided for @enablePermissionForHealthAlerts.
  ///
  /// In ko, this message translates to:
  /// **'중요한 건강 알림을 받으려면 권한을 켜주세요.'**
  String get enablePermissionForHealthAlerts;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @currentCaloriesLabel.
  ///
  /// In ko, this message translates to:
  /// **'(현재 칼로리)'**
  String get currentCaloriesLabel;

  /// No description provided for @notificationBreakfastTitle.
  ///
  /// In ko, this message translates to:
  /// **'좋은 아침이에요! ☀️'**
  String get notificationBreakfastTitle;

  /// No description provided for @notificationBreakfastBody.
  ///
  /// In ko, this message translates to:
  /// **'영양 가득한 아침 식사로 활기찬 하루를 시작하세요!'**
  String get notificationBreakfastBody;

  /// No description provided for @notificationLunchTitle.
  ///
  /// In ko, this message translates to:
  /// **'점심 시간이에요! 🍱'**
  String get notificationLunchTitle;

  /// No description provided for @notificationLunchBody.
  ///
  /// In ko, this message translates to:
  /// **'균형 잡힌 점심으로 오후 활력을 채워보세요!'**
  String get notificationLunchBody;

  /// No description provided for @notificationDinnerTitle.
  ///
  /// In ko, this message translates to:
  /// **'저녁 식사 시간이에요! 🌙'**
  String get notificationDinnerTitle;

  /// No description provided for @notificationDinnerBody.
  ///
  /// In ko, this message translates to:
  /// **'건강한 저녁 식사로 하루를 마무리하세요!'**
  String get notificationDinnerBody;

  /// No description provided for @notificationBrunchTitle.
  ///
  /// In ko, this message translates to:
  /// **'브런치 시간이에요! 🥞'**
  String get notificationBrunchTitle;

  /// No description provided for @notificationBrunchBody.
  ///
  /// In ko, this message translates to:
  /// **'맛있는 브런치를 즐겨보세요!'**
  String get notificationBrunchBody;

  /// No description provided for @notificationCustomMealTitle.
  ///
  /// In ko, this message translates to:
  /// **'{mealName} 시간이에요! 🍽️'**
  String notificationCustomMealTitle(Object mealName);

  /// No description provided for @notificationCustomMealBody.
  ///
  /// In ko, this message translates to:
  /// **'맛있고 건강한 식사를 즐기세요!'**
  String get notificationCustomMealBody;

  /// No description provided for @notificationMorningSnackTitle.
  ///
  /// In ko, this message translates to:
  /// **'오전 간식 시간이에요! 🍎'**
  String get notificationMorningSnackTitle;

  /// No description provided for @notificationAfternoonSnackTitle.
  ///
  /// In ko, this message translates to:
  /// **'오후 간식 시간이에요! 🥨'**
  String get notificationAfternoonSnackTitle;

  /// No description provided for @notificationSnackBody.
  ///
  /// In ko, this message translates to:
  /// **'건강한 간식으로 에너지를 충전하세요!'**
  String get notificationSnackBody;

  /// No description provided for @notificationWaterTitle.
  ///
  /// In ko, this message translates to:
  /// **'물 마실 시간이에요! 💧'**
  String get notificationWaterTitle;

  /// No description provided for @notificationWaterBody.
  ///
  /// In ko, this message translates to:
  /// **'건강을 위해 물 한 잔 어떠세요?'**
  String get notificationWaterBody;

  /// No description provided for @notificationCalorieOverTitle.
  ///
  /// In ko, this message translates to:
  /// **'칼로리 목표 초과 ⚠️'**
  String get notificationCalorieOverTitle;

  /// No description provided for @notificationCalorieOverBody.
  ///
  /// In ko, this message translates to:
  /// **'오늘 {overAmount}kcal 초과했습니다. 건강한 식단을 유지해보세요!'**
  String notificationCalorieOverBody(Object overAmount);

  /// No description provided for @notificationLateNightTitle.
  ///
  /// In ko, this message translates to:
  /// **'지금 드시나요? 🌙'**
  String get notificationLateNightTitle;

  /// No description provided for @notificationLateNightBody.
  ///
  /// In ko, this message translates to:
  /// **'늦은 밤 식사는 수면과 소화에 좋지 않아요. 가볍게 드시는 건 어떨까요?'**
  String get notificationLateNightBody;

  /// No description provided for @notificationGoalAchievedTitle.
  ///
  /// In ko, this message translates to:
  /// **'축하합니다! 🎉'**
  String get notificationGoalAchievedTitle;

  /// No description provided for @notificationGoalAchievedBody.
  ///
  /// In ko, this message translates to:
  /// **'오늘 칼로리 목표를 성공적으로 달성했습니다!'**
  String get notificationGoalAchievedBody;

  /// No description provided for @notificationMotivationTitle.
  ///
  /// In ko, this message translates to:
  /// **'VitaBuddy의 응원 💝'**
  String get notificationMotivationTitle;

  /// No description provided for @notificationMotivationMessage1.
  ///
  /// In ko, this message translates to:
  /// **'건강한 하루를 보내고 있나요? 💪'**
  String get notificationMotivationMessage1;

  /// No description provided for @notificationMotivationMessage2.
  ///
  /// In ko, this message translates to:
  /// **'물 한 컵 어떠세요? 🥤'**
  String get notificationMotivationMessage2;

  /// No description provided for @notificationMotivationMessage3.
  ///
  /// In ko, this message translates to:
  /// **'가벼운 스트레칭으로 상쾌함을 느껴보세요! 🤸‍♀️'**
  String get notificationMotivationMessage3;

  /// No description provided for @notificationMotivationMessage4.
  ///
  /// In ko, this message translates to:
  /// **'오늘도 건강 관리 화이팅! 🌟'**
  String get notificationMotivationMessage4;

  /// No description provided for @notificationMotivationMessage5.
  ///
  /// In ko, this message translates to:
  /// **'균형 잡힌 식단이 건강의 시작입니다! 🥗'**
  String get notificationMotivationMessage5;

  /// No description provided for @notificationExerciseTitle.
  ///
  /// In ko, this message translates to:
  /// **'운동 시간입니다! 🏃'**
  String get notificationExerciseTitle;

  /// No description provided for @notificationExerciseBody.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 칼로리를 태워볼까요?'**
  String get notificationExerciseBody;

  /// No description provided for @notificationWeightTitle.
  ///
  /// In ko, this message translates to:
  /// **'체중 측정 시간입니다! ⚖️'**
  String get notificationWeightTitle;

  /// No description provided for @notificationWeightBody.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 몸무게를 기록하고 건강 목표를 확인해 보세요.'**
  String get notificationWeightBody;

  /// No description provided for @notificationSupplementTitle.
  ///
  /// In ko, this message translates to:
  /// **'{supplementName} 복용 시간입니다! 💊'**
  String notificationSupplementTitle(Object supplementName);

  /// No description provided for @notificationSupplementBody.
  ///
  /// In ko, this message translates to:
  /// **'건강 관리 잊지 마세요. 꾸준함이 중요해요!'**
  String get notificationSupplementBody;

  /// No description provided for @calorieStatusVeryLow.
  ///
  /// In ko, this message translates to:
  /// **'배고파요... 식사가 필요해요!'**
  String get calorieStatusVeryLow;

  /// No description provided for @calorieStatusLow.
  ///
  /// In ko, this message translates to:
  /// **'에너지가 부족해요'**
  String get calorieStatusLow;

  /// No description provided for @calorieStatusBelowIdeal.
  ///
  /// In ko, this message translates to:
  /// **'조금 더 먹어도 괜찮아요'**
  String get calorieStatusBelowIdeal;

  /// No description provided for @calorieStatusIdeal.
  ///
  /// In ko, this message translates to:
  /// **'완벽해요! 좋은 상태예요'**
  String get calorieStatusIdeal;

  /// No description provided for @calorieStatusSlightlyHigh.
  ///
  /// In ko, this message translates to:
  /// **'조금 많이 먹었네요'**
  String get calorieStatusSlightlyHigh;

  /// No description provided for @calorieStatusHigh.
  ///
  /// In ko, this message translates to:
  /// **'칼로리가 높아요!'**
  String get calorieStatusHigh;

  /// No description provided for @calorieStatusExceeded.
  ///
  /// In ko, this message translates to:
  /// **'목표 초과! 운동 필요해요!'**
  String get calorieStatusExceeded;

  /// No description provided for @avatarLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'아바타 로드 실패'**
  String get avatarLoadFailed;

  /// No description provided for @avatarBuildFailed.
  ///
  /// In ko, this message translates to:
  /// **'아바타 빌드 실패'**
  String get avatarBuildFailed;

  /// No description provided for @sleepSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'수면 설정'**
  String get sleepSettingsTitle;

  /// No description provided for @sleepSettingsSaved.
  ///
  /// In ko, this message translates to:
  /// **'수면 설정이 저장되었습니다.'**
  String get sleepSettingsSaved;

  /// No description provided for @sleepModeSection.
  ///
  /// In ko, this message translates to:
  /// **'수면 모드'**
  String get sleepModeSection;

  /// No description provided for @sleepTimeSettings.
  ///
  /// In ko, this message translates to:
  /// **'수면 시간 설정'**
  String get sleepTimeSettings;

  /// No description provided for @saveSettings.
  ///
  /// In ko, this message translates to:
  /// **'저장하기'**
  String get saveSettings;

  /// No description provided for @hybridMode.
  ///
  /// In ko, this message translates to:
  /// **'하이브리드 (권장)'**
  String get hybridMode;

  /// No description provided for @hybridModeDesc.
  ///
  /// In ko, this message translates to:
  /// **'스마트워치 데이터 우선, 없을 시 수동 시간 사용'**
  String get hybridModeDesc;

  /// No description provided for @manualMode.
  ///
  /// In ko, this message translates to:
  /// **'수동 설정'**
  String get manualMode;

  /// No description provided for @manualModeDesc.
  ///
  /// In ko, this message translates to:
  /// **'설정된 시간에만 수면 모드 적용'**
  String get manualModeDesc;

  /// No description provided for @deviceOnlyMode.
  ///
  /// In ko, this message translates to:
  /// **'기기 전용'**
  String get deviceOnlyMode;

  /// No description provided for @deviceOnlyModeDesc.
  ///
  /// In ko, this message translates to:
  /// **'스마트워치 데이터만 사용'**
  String get deviceOnlyModeDesc;

  /// No description provided for @bedtime.
  ///
  /// In ko, this message translates to:
  /// **'취침 시간'**
  String get bedtime;

  /// No description provided for @waketime.
  ///
  /// In ko, this message translates to:
  /// **'기상 시간'**
  String get waketime;

  /// No description provided for @clothingPresetDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본 (회색)'**
  String get clothingPresetDefault;

  /// No description provided for @clothingPresetPinkBlack.
  ///
  /// In ko, this message translates to:
  /// **'핑크/블랙'**
  String get clothingPresetPinkBlack;

  /// No description provided for @clothingPresetWhiteNavy.
  ///
  /// In ko, this message translates to:
  /// **'흰색/네이비'**
  String get clothingPresetWhiteNavy;

  /// No description provided for @clothingPresetMintCharcoal.
  ///
  /// In ko, this message translates to:
  /// **'민트/차콜'**
  String get clothingPresetMintCharcoal;

  /// No description provided for @clothingPresetLavenderPurple.
  ///
  /// In ko, this message translates to:
  /// **'라벤더/퍼플'**
  String get clothingPresetLavenderPurple;

  /// No description provided for @clothingPresetCoralGray.
  ///
  /// In ko, this message translates to:
  /// **'코랄/그레이'**
  String get clothingPresetCoralGray;

  /// No description provided for @timezoneSettings.
  ///
  /// In ko, this message translates to:
  /// **'시간대 설정'**
  String get timezoneSettings;

  /// No description provided for @selectTimezone.
  ///
  /// In ko, this message translates to:
  /// **'시간대 선택'**
  String get selectTimezone;

  /// No description provided for @timezoneNotificationAdjustment.
  ///
  /// In ko, this message translates to:
  /// **'알림 시간은 선택한 시간대에 따라 조정됩니다.'**
  String get timezoneNotificationAdjustment;

  /// No description provided for @timezoneSet.
  ///
  /// In ko, this message translates to:
  /// **'시간대가 {timezone}로 설정되었습니다.'**
  String timezoneSet(String timezone);

  /// No description provided for @healthConnectUpdateRequired.
  ///
  /// In ko, this message translates to:
  /// **'헬스 커넥트 앱의 업데이트 또는 데이터 마이그레이션이 필요합니다.\n시스템 설정 및 플레이 스토어를 확인해주세요.'**
  String get healthConnectUpdateRequired;

  /// No description provided for @healthConnectNotInstalled.
  ///
  /// In ko, this message translates to:
  /// **'Health Connect 앱이 설치되어 있지 않습니다.\nGoogle Play에서 설치 후 다시 시도해주세요.'**
  String get healthConnectNotInstalled;

  /// No description provided for @healthConnectInitializing.
  ///
  /// In ko, this message translates to:
  /// **'Health Connect 초기화 중...'**
  String get healthConnectInitializing;

  /// No description provided for @healthConnectCheckingStatus.
  ///
  /// In ko, this message translates to:
  /// **'Health Connect 상태 확인 중...'**
  String get healthConnectCheckingStatus;

  /// No description provided for @healthConnectInitFailed.
  ///
  /// In ko, this message translates to:
  /// **'헬스 커넥트 초기화 실패: {error}'**
  String healthConnectInitFailed(Object error);

  /// No description provided for @healthConnectCheckFailed.
  ///
  /// In ko, this message translates to:
  /// **'헬스 커넥트 확인 실패: {error}'**
  String healthConnectCheckFailed(Object error);

  /// No description provided for @healthConnectRequestFailed.
  ///
  /// In ko, this message translates to:
  /// **'권한 요청 실패: {error}'**
  String healthConnectRequestFailed(Object error);

  /// No description provided for @permissionDiagnosis.
  ///
  /// In ko, this message translates to:
  /// **'권한 진단'**
  String get permissionDiagnosis;

  /// No description provided for @permissionDiagnosisResults.
  ///
  /// In ko, this message translates to:
  /// **'권한 진단 결과'**
  String get permissionDiagnosisResults;

  /// No description provided for @clearPermissionCache.
  ///
  /// In ko, this message translates to:
  /// **'권한 캐시 초기화'**
  String get clearPermissionCache;

  /// No description provided for @permissionCacheCleared.
  ///
  /// In ko, this message translates to:
  /// **'권한 캐시가 초기화되었습니다. 앱을 재시작해주세요.'**
  String get permissionCacheCleared;

  /// No description provided for @syncingHealthData.
  ///
  /// In ko, this message translates to:
  /// **'헬스 데이터 동기화 중...'**
  String get syncingHealthData;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @waterIntakeManagement.
  ///
  /// In ko, this message translates to:
  /// **'수분 섭취 관리'**
  String get waterIntakeManagement;

  /// No description provided for @supplementNotifications.
  ///
  /// In ko, this message translates to:
  /// **'비타민/보충제 알림'**
  String get supplementNotifications;

  /// No description provided for @addSupplement.
  ///
  /// In ko, this message translates to:
  /// **'보충제 추가'**
  String get addSupplement;

  /// No description provided for @supplementName.
  ///
  /// In ko, this message translates to:
  /// **'보충제 이름'**
  String get supplementName;

  /// No description provided for @supplementTime.
  ///
  /// In ko, this message translates to:
  /// **'섭취 시간'**
  String get supplementTime;

  /// No description provided for @waterReminder.
  ///
  /// In ko, this message translates to:
  /// **'물 마시기 알림'**
  String get waterReminder;

  /// No description provided for @waterInterval.
  ///
  /// In ko, this message translates to:
  /// **'알림 간격 (분)'**
  String get waterInterval;

  /// No description provided for @waterStartTime.
  ///
  /// In ko, this message translates to:
  /// **'시작 시간'**
  String get waterStartTime;

  /// No description provided for @noSupplementsRegistered.
  ///
  /// In ko, this message translates to:
  /// **'등록된 보충제가 없습니다. + 버튼을 눌러 추가하세요.'**
  String get noSupplementsRegistered;

  /// No description provided for @maxSupplementsReached.
  ///
  /// In ko, this message translates to:
  /// **'보충제는 최대 3개까지 등록할 수 있습니다.'**
  String get maxSupplementsReached;

  /// No description provided for @dailyWaterGoal.
  ///
  /// In ko, this message translates to:
  /// **'하루 목표: {goal}ml'**
  String dailyWaterGoal(int goal);

  /// No description provided for @editSupplement.
  ///
  /// In ko, this message translates to:
  /// **'보충제 수정'**
  String get editSupplement;

  /// No description provided for @dailyGoal.
  ///
  /// In ko, this message translates to:
  /// **'하루 목표'**
  String get dailyGoal;

  /// No description provided for @supplementHintText.
  ///
  /// In ko, this message translates to:
  /// **'비타민 C, 오메가3 등'**
  String get supplementHintText;

  /// No description provided for @recommendedWaterIntake.
  ///
  /// In ko, this message translates to:
  /// **'권장 수분 섭취량'**
  String get recommendedWaterIntake;

  /// No description provided for @recommendedBasedOnProfile.
  ///
  /// In ko, this message translates to:
  /// **'체중과 활동량을 기반으로 계산된 권장량입니다'**
  String get recommendedBasedOnProfile;

  /// No description provided for @yourDailyGoal.
  ///
  /// In ko, this message translates to:
  /// **'나의 하루 목표'**
  String get yourDailyGoal;

  /// No description provided for @canAdjustManually.
  ///
  /// In ko, this message translates to:
  /// **'직접 조정할 수 있습니다 (1000~5000ml)'**
  String get canAdjustManually;

  /// No description provided for @useRecommendedAmount.
  ///
  /// In ko, this message translates to:
  /// **'권장량 적용'**
  String get useRecommendedAmount;

  /// No description provided for @barcodeScan.
  ///
  /// In ko, this message translates to:
  /// **'바코드 스캔'**
  String get barcodeScan;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In ko, this message translates to:
  /// **'카메라 권한이 필요합니다. 설정에서 권한을 허용해주세요.'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraInitializing.
  ///
  /// In ko, this message translates to:
  /// **'카메라 초기화 중...'**
  String get cameraInitializing;

  /// No description provided for @cameraInitFailed.
  ///
  /// In ko, this message translates to:
  /// **'카메라 초기화에 실패했습니다: {error}'**
  String cameraInitFailed(String error);

  /// No description provided for @barcodeDetected.
  ///
  /// In ko, this message translates to:
  /// **'바코드 감지됨!'**
  String get barcodeDetected;

  /// No description provided for @pointCameraAtBarcode.
  ///
  /// In ko, this message translates to:
  /// **'바코드를 카메라에 비춰주세요\n(어디에나 바코드가 있으면 인식됩니다)'**
  String get pointCameraAtBarcode;

  /// No description provided for @barcodeVerified.
  ///
  /// In ko, this message translates to:
  /// **'바코드 검증 완료!'**
  String get barcodeVerified;

  /// No description provided for @invalidBarcode.
  ///
  /// In ko, this message translates to:
  /// **'유효하지 않은 바코드'**
  String get invalidBarcode;

  /// No description provided for @type.
  ///
  /// In ko, this message translates to:
  /// **'타입'**
  String get type;

  /// No description provided for @confidence.
  ///
  /// In ko, this message translates to:
  /// **'신뢰도'**
  String get confidence;

  /// No description provided for @scanCount.
  ///
  /// In ko, this message translates to:
  /// **'스캔 횟수'**
  String get scanCount;

  /// No description provided for @accept.
  ///
  /// In ko, this message translates to:
  /// **'사용'**
  String get accept;

  /// No description provided for @rescan.
  ///
  /// In ko, this message translates to:
  /// **'재스캔'**
  String get rescan;

  /// No description provided for @supportedFormats.
  ///
  /// In ko, this message translates to:
  /// **'지원 형식: QR코드, 바코드 (EAN-13, UPC-A 등)'**
  String get supportedFormats;

  /// No description provided for @localSearch.
  ///
  /// In ko, this message translates to:
  /// **'로컬 검색'**
  String get localSearch;

  /// No description provided for @onlineSearch.
  ///
  /// In ko, this message translates to:
  /// **'인터넷 검색'**
  String get onlineSearch;

  /// No description provided for @barcodeSearching.
  ///
  /// In ko, this message translates to:
  /// **'바코드 검색 중...'**
  String get barcodeSearching;

  /// No description provided for @barcodeSearchResults.
  ///
  /// In ko, this message translates to:
  /// **'바코드 검색 결과'**
  String get barcodeSearchResults;

  /// No description provided for @barcodeSearchFailed.
  ///
  /// In ko, this message translates to:
  /// **'바코드 검색 실패'**
  String get barcodeSearchFailed;

  /// No description provided for @barcodeFormatEan13.
  ///
  /// In ko, this message translates to:
  /// **'EAN-13 (상품 바코드)'**
  String get barcodeFormatEan13;

  /// No description provided for @barcodeFormatEan8.
  ///
  /// In ko, this message translates to:
  /// **'EAN-8 (짧은 상품 바코드)'**
  String get barcodeFormatEan8;

  /// No description provided for @barcodeFormatUpca.
  ///
  /// In ko, this message translates to:
  /// **'UPC-A (미국 상품 바코드)'**
  String get barcodeFormatUpca;

  /// No description provided for @barcodeFormatUpce.
  ///
  /// In ko, this message translates to:
  /// **'UPC-E (짧은 미국 상품 바코드)'**
  String get barcodeFormatUpce;

  /// No description provided for @barcodeFormatQrCode.
  ///
  /// In ko, this message translates to:
  /// **'QR 코드'**
  String get barcodeFormatQrCode;

  /// No description provided for @barcodeFormatCode128.
  ///
  /// In ko, this message translates to:
  /// **'Code 128 (상업용)'**
  String get barcodeFormatCode128;

  /// No description provided for @barcodeFormatCode39.
  ///
  /// In ko, this message translates to:
  /// **'Code 39 (산업용)'**
  String get barcodeFormatCode39;

  /// No description provided for @barcodeFormatCode93.
  ///
  /// In ko, this message translates to:
  /// **'Code 93'**
  String get barcodeFormatCode93;

  /// No description provided for @barcodeFormatCodabar.
  ///
  /// In ko, this message translates to:
  /// **'Codabar'**
  String get barcodeFormatCodabar;

  /// No description provided for @barcodeFormatItf.
  ///
  /// In ko, this message translates to:
  /// **'ITF (Interleaved 2 of 5)'**
  String get barcodeFormatItf;

  /// No description provided for @barcodeFormatAztec.
  ///
  /// In ko, this message translates to:
  /// **'Aztec 코드'**
  String get barcodeFormatAztec;

  /// No description provided for @barcodeFormatDataMatrix.
  ///
  /// In ko, this message translates to:
  /// **'Data Matrix'**
  String get barcodeFormatDataMatrix;

  /// No description provided for @barcodeFormatPdf417.
  ///
  /// In ko, this message translates to:
  /// **'PDF417'**
  String get barcodeFormatPdf417;

  /// No description provided for @barcodeFormatUnknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 형식'**
  String get barcodeFormatUnknown;

  /// No description provided for @searchOnlineHint.
  ///
  /// In ko, this message translates to:
  /// **'인터넷에서 음식 검색...'**
  String get searchOnlineHint;

  /// No description provided for @search100gHint.
  ///
  /// In ko, this message translates to:
  /// **'100g당 입력은 검색 탭을 이용해주세요.'**
  String get search100gHint;

  /// No description provided for @quantityLabel.
  ///
  /// In ko, this message translates to:
  /// **'수량:'**
  String get quantityLabel;

  /// No description provided for @equalsCalories.
  ///
  /// In ko, this message translates to:
  /// **'= {calories}kcal'**
  String equalsCalories(int calories);

  /// No description provided for @calorieInfoSaved.
  ///
  /// In ko, this message translates to:
  /// **'칼로리 정보가 저장되었습니다'**
  String get calorieInfoSaved;

  /// No description provided for @enterValidCaloriesDialog.
  ///
  /// In ko, this message translates to:
  /// **'올바른 칼로리 값을 입력해주세요'**
  String get enterValidCaloriesDialog;

  /// No description provided for @calorieInfoNotFound.
  ///
  /// In ko, this message translates to:
  /// **'이 음식의 칼로리 정보를 찾을 수 없습니다.\n구글에서 검색하거나 직접 입력해주세요.'**
  String get calorieInfoNotFound;

  /// No description provided for @searchGoogle.
  ///
  /// In ko, this message translates to:
  /// **'구글에서 검색'**
  String get searchGoogle;
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
      <String>['en', 'id', 'ja', 'ko', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
