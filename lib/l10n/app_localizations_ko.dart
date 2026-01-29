// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '비타버디';

  @override
  String get homeGreetingMorning => '좋은 아침입니다';

  @override
  String get homeGreetingAfternoon => '좋은 오후입니다';

  @override
  String get homeGreetingEvening => '좋은 저녁입니다';

  @override
  String get homeSubtitle => '오늘도 건강한 하루 보내세요!';

  @override
  String get caloriesUnit => 'kcal';

  @override
  String get intakeLabel => '섭취';

  @override
  String get burnedLabel => '소모';

  @override
  String get remainingLabel => '잔여';

  @override
  String get goalLabel => '목표';

  @override
  String get minutesUnit => '분';

  @override
  String get exerciseRecord => '운동 기록';

  @override
  String get foodRecord => '음식 기록';

  @override
  String get dailySummary => '오늘 하루 요약';

  @override
  String get wearableConnected => '연결됨';

  @override
  String get wearablePermissionRequired => '권한 필요';

  @override
  String get wearableNotConnected => '연결 안됨';

  @override
  String get walkingActivity => '걷기';

  @override
  String get runningActivity => '달리기';

  @override
  String get cyclingActivity => '자전거';

  @override
  String get swimmingActivity => '수영';

  @override
  String get weightTrainingActivity => '근력 운동';

  @override
  String get yogaActivity => '요가';

  @override
  String get dancingActivity => '댄스';

  @override
  String get hikingActivity => '등산';

  @override
  String get tennisActivity => '테니스';

  @override
  String get basketballActivity => '농구';

  @override
  String get soccerActivity => '축구';

  @override
  String get aerobicsActivity => '에어로빅';

  @override
  String get badmintonActivity => '배드민턴';

  @override
  String get baseballActivity => '야구';

  @override
  String get boxingActivity => '복싱';

  @override
  String get golfActivity => '골프';

  @override
  String get pilatesActivity => '필라테스';

  @override
  String get tableTennisActivity => '탁구';

  @override
  String get volleyballActivity => '배구';

  @override
  String get ellipticalActivity => '일립티컬';

  @override
  String get rowingActivity => '로잉 머신';

  @override
  String get stairClimbingActivity => '계단 오르기';

  @override
  String get otherActivity => '기타 운동';

  @override
  String get sourceManual => '수동 입력';

  @override
  String get sourceHealthConnect => 'Health Connect';

  @override
  String get sourceHealthKit => 'HealthKit';

  @override
  String get workoutTypeLabel => '운동 종류';

  @override
  String get durationLabel => '운동 시간 (분)';

  @override
  String get intensityLabel => '운동 강도';

  @override
  String get intensityLow => '낮음';

  @override
  String get intensityMedium => '보통';

  @override
  String get intensityHigh => '높음';

  @override
  String get calcCaloriesLabel => '예상 칼로리 소모량';

  @override
  String get calorieCalcError => '칼로리 계산 오류가 발생했습니다';

  @override
  String workoutSaved(Object type) {
    return '$type 운동이 기록되었습니다';
  }

  @override
  String saveError(Object error) {
    return '저장 실패: $error';
  }

  @override
  String get syncComplete => '동기화 완료';

  @override
  String get syncFailed => '동기화 실패';

  @override
  String get noDataToSync => '동기화할 데이터 없음';

  @override
  String get settingsTitle => '설정';

  @override
  String get profileTitle => '프로필';

  @override
  String get languageTitle => '언어';

  @override
  String get calorieGoalSettings => '목표 칼로리 설정';

  @override
  String get sleepSettings => '수면 설정';

  @override
  String get avatarClothingSettings => '아바타 옷 설정';

  @override
  String get profileEdit => '프로필 수정';

  @override
  String get notificationSettings => '알림 설정';

  @override
  String get healthDataPermission => '헬스 데이터 권한';

  @override
  String get healthPermissionAlreadyGranted => '헬스 데이터 권한이 이미 허용되어 있습니다';

  @override
  String get healthPermissionGranted => '헬스 데이터 권한이 허용되었습니다';

  @override
  String get healthPermissionDenied => '헬스 데이터 권한이 거부되었습니다. 설정에서 허용해주세요';

  @override
  String get weight => '체중';

  @override
  String get height => '키';

  @override
  String get age => '나이';

  @override
  String get gender => '성별';

  @override
  String get male => '남성';

  @override
  String get female => '여성';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get delete => '삭제';

  @override
  String get edit => '수정';

  @override
  String get autoRecord => '자동 기록';

  @override
  String get manualRecord => '수동 기록';

  @override
  String get caloriesBurned => '소모 칼로리';

  @override
  String get workoutCount => '운동 횟수';

  @override
  String get steps => '걸음 수';

  @override
  String get syncing => '동기화 중...';

  @override
  String get syncHealthData => 'Health 데이터 동기화';

  @override
  String get noAutoRecords => '자동 기록된 운동이 없습니다';

  @override
  String get noAutoRecordsSubtitle =>
      'Health 데이터 동기화 버튼을 눌러\n스마트폰과 웨어러블의 운동 데이터를 불러오세요';

  @override
  String get noManualRecords => '수동 기록된 운동이 없습니다';

  @override
  String get noManualRecordsSubtitle => '오른쪽 하단의 + 버튼을 눌러\n운동을 직접 기록해보세요';

  @override
  String get dataLoadFailed => '데이터 로드 실패';

  @override
  String get basicInfo => '기본 정보';

  @override
  String get bodyInfo => '신체';

  @override
  String get personality => '성격';

  @override
  String get previous => '이전';

  @override
  String get nameOptional => '이름 (선택사항)';

  @override
  String get activityLevel => '활동 수준';

  @override
  String get activitySedentary => '거의 운동 안 함';

  @override
  String get activityLight => '가벼운 운동 (주 1-3일)';

  @override
  String get activityModerate => '보통 운동 (주 3-5일)';

  @override
  String get activityActive => '적극적 운동 (주 6-7일)';

  @override
  String get activityVeryActive => '매우 적극적 (하루 2회 이상)';

  @override
  String get sedentary => '거의 운동 안 함';

  @override
  String get lightExercise => '가벼운 운동 (주 1-3일)';

  @override
  String get moderateExercise => '보통 운동 (주 3-5일)';

  @override
  String get activeExercise => '적극적 운동 (주 6-7일)';

  @override
  String get veryActiveExercise => '매우 적극적 (하루 2회 이상)';

  @override
  String get saveChanges => '변경사항 저장';

  @override
  String get profileUpdated => '프로필이 업데이트되었습니다';

  @override
  String get discardChanges => '변경사항 취소';

  @override
  String get discardChangesMessage => '변경한 내용을 저장하지 않고 나가시겠습니까?';

  @override
  String get continueEditing => '계속 수정';

  @override
  String get exitWithoutSaving => '나가기';

  @override
  String get complete => '완료';

  @override
  String get next => '다음';

  @override
  String get foodInput => '음식 입력';

  @override
  String get recent => '최근';

  @override
  String get favorites => '즐겨찾기';

  @override
  String get search => '검색';

  @override
  String get customAdd => '직접추가';

  @override
  String get noRecentFoods => '최근에 먹은 음식이 없습니다';

  @override
  String get noFavoriteFoods => '즐겨찾기한 음식이 없습니다';

  @override
  String get addFavoriteHint => '음식 목록에서 ⭐를 눌러 추가해보세요';

  @override
  String get noSearchResults => '검색 결과가 없습니다';

  @override
  String get searchFoodHint => '음식 검색...';

  @override
  String get foodName => '음식 이름';

  @override
  String get calories => '칼로리';

  @override
  String get quantity => '수량';

  @override
  String get servingCalories => '1회 제공량 칼로리';

  @override
  String get servingCount => '섭취한 횟수';

  @override
  String get foodNameHint => '예: 햄버거, 불고기 정식';

  @override
  String get caloriesHint => '예: 550';

  @override
  String get addIntake => '섭취 추가';

  @override
  String get saveTemporary => '임시 저장 (나중에 칼로리 입력)';

  @override
  String get invalidQuantity => '올바른 수량을 입력해주세요';

  @override
  String get foodAdded => '음식 추가 완료';

  @override
  String get foodAddFailed => '음식 추가에 실패했습니다';

  @override
  String get favoriteAdded => '즐겨찾기 추가됨';

  @override
  String get favoriteRemoved => '즐겨찾기 해제됨';

  @override
  String get inputModeTotal => '전체';

  @override
  String get inputModeServing => '1회';

  @override
  String get inputMode100g => '100g';

  @override
  String get inputModeQuick => '빠른';

  @override
  String get add => '추가';

  @override
  String get enterFoodNameAndCalories => '음식 이름과 칼로리를 입력해주세요';

  @override
  String get enterValidCalories => '올바른 칼로리를 입력해주세요';

  @override
  String get userFoodAddFailed => '사용자 음식 추가에 실패했습니다';

  @override
  String get enterFoodName => '음식 이름을 입력해주세요';

  @override
  String get quickSaveSuccess => '임시 저장됨 (나중에 칼로리 입력 필요)';

  @override
  String get servingInfoHelp => '영양성분표의 1회 제공량 정보를 그대로 입력하세요';

  @override
  String get servingUnit => '회';

  @override
  String get unitServings => '인분';

  @override
  String get unitCount => '개/인분';

  @override
  String get foodAddTitle => '음식 추가';

  @override
  String foodAddConfirm(String foodName) {
    return '$foodName을(를) 추가하시겠습니까?';
  }

  @override
  String get refreshTooltip => '새로고침';

  @override
  String get totalCalorieHelp => '음식의 총 칼로리를 직접 입력하세요';

  @override
  String get quickRecordHelp => '음식 이름만 입력하고 나중에 칼로리를 추가할 수 있어요';

  @override
  String get defaultLabel => '기본';

  @override
  String get weightRecord => '체중 기록';

  @override
  String get weightLoadFailed => '체중 기록을 불러오는데 실패했습니다';

  @override
  String get enterWeight => '체중을 입력해주세요';

  @override
  String get enterValidWeight => '올바른 체중을 입력해주세요 (20-300kg)';

  @override
  String get weightRecorded => '체중이 기록되었습니다';

  @override
  String get weightRecordFailed => '체중 기록에 실패했습니다';

  @override
  String get weightRecordDeleted => '체중 기록이 삭제되었습니다';

  @override
  String get deleteFailed => '기록 삭제에 실패했습니다';

  @override
  String get todaysWeight => '오늘의 체중';

  @override
  String get weightHint => '예: 70.5';

  @override
  String get record => '기록';

  @override
  String get noteOptional => '메모 (선택사항)';

  @override
  String get noteHint => '예: 운동 후 측정';

  @override
  String get weightTrend => '체중 변화 추이';

  @override
  String get noWeightRecords => '체중 기록이 없습니다';

  @override
  String get deleteRecord => '기록 삭제';

  @override
  String get confirmDeleteWeight => '이 체중 기록을 삭제하시겠습니까?';

  @override
  String get languageSettings => '언어 설정';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get getStarted => '시작하기';

  @override
  String get language => '언어';

  @override
  String get healthPermissionContent =>
      '앱에서 웨어러블 기기와의 칼로리 동기화를 위해 건강 데이터 접근 권한이 필요합니다.';

  @override
  String get healthPermissionAllowInfo => '권한 허용 시:';

  @override
  String get healthPermissionInfo1 => '• 걸음 수 및 칼로리 소모량 자동 동기화';

  @override
  String get healthPermissionInfo2 => '• 운동 기록 자동 가져오기';

  @override
  String get healthPermissionInfo3 => '• 더 정확한 칼로리 관리';

  @override
  String get healthPermissionDenyInfo => '권한을 거부해도 앱의 기본 기능은 사용할 수 있습니다.';

  @override
  String get later => '나중에';

  @override
  String get allowPermission => '권한 허용';

  @override
  String get permissionSelect => '권한 선택';

  @override
  String get allowAndSync => '권한 허용하고 동기화';

  @override
  String get setupLater => '나중에 설정하기';

  @override
  String get history => '기록';

  @override
  String get errorOccurred => '오류 발생';

  @override
  String get noRecords => '아직 기록이 없습니다.';

  @override
  String get pleaseSelectLanguage => '언어를 선택해주세요';

  @override
  String get homeTitle => '치유하다 VitaBuddy';

  @override
  String get mealRecord => '식사 기록';

  @override
  String get viewRecords => '기록 보기';

  @override
  String get developerTest => '개발자 테스트 화면';

  @override
  String get mealGuidance => '식사 안내';

  @override
  String get nextMeal => '다음 식사';

  @override
  String get moreNeeded => '더 필요';

  @override
  String get reduce => '줄이세요';

  @override
  String get until => '까지';

  @override
  String get sleepMode => '수면 모드';

  @override
  String get connected => '연결됨';

  @override
  String get disconnected => '연결 안됨';

  @override
  String get notConnected => '연결 안됨';

  @override
  String get justSynced => '방금 동기화';

  @override
  String get syncedJustNow => '방금 동기화';

  @override
  String syncedMinutesAgo(int minutes) {
    return '$minutes분 전';
  }

  @override
  String syncedHoursAgo(int hours) {
    return '$hours시간 전';
  }

  @override
  String get minutesAgo => '분 전';

  @override
  String get hoursAgo => '시간 전';

  @override
  String get minutesShort => '분';

  @override
  String get changeClothingColor => '옷 색상 변경';

  @override
  String get walking => '걷기';

  @override
  String get running => '달리기';

  @override
  String get cycling => '자전거';

  @override
  String get swimming => '수영';

  @override
  String get user => '사용자';

  @override
  String homeGreetingFormat(String greeting, String user) {
    return '$greeting, $user님!';
  }

  @override
  String get reduceIntake => '줄이세요';

  @override
  String get profileSetup => '프로필 설정';

  @override
  String get stepBasicInfo => '기본 정보';

  @override
  String get basicInfoDesc => '정확한 칼로리 계산을 위해 기본 정보를 입력해주세요.';

  @override
  String get nameHint => '예: 홍길동';

  @override
  String get yearsOld => '세';

  @override
  String get ageUnit => '세';

  @override
  String get stepMealPattern => '식사 패턴 설정';

  @override
  String get mealPatternSetup => '식사 패턴 설정';

  @override
  String get mealPatternDesc => '하루 식사 패턴을 설정하면 맞춤 알림을 받을 수 있어요.';

  @override
  String get meals2 => '2식';

  @override
  String get meals3 => '3식 (권장)';

  @override
  String get meals4 => '4식+';

  @override
  String get meals4Plus => '4식+';

  @override
  String get mealTimeSettings => '설정된 식사 시간';

  @override
  String get configuredMealTimes => '설정된 식사 시간';

  @override
  String get stepSomatotype => '체질 선택';

  @override
  String get somatotypeSelection => '체질 선택';

  @override
  String get somatotypeDesc => '당신의 체질 타입을 선택하세요. 대사율 계산에 반영됩니다.';

  @override
  String get dontKnow => '잘 모르겠어요';

  @override
  String get unsure => '잘 모르겠어요';

  @override
  String get stepBodyShape => '체형 선택';

  @override
  String get bodyShapeSelection => '체형 선택';

  @override
  String get bodyShapeDesc => '살이 주로 어디에 찌나요? 아바타 표현에 반영됩니다.';

  @override
  String get stepDetailInfo => '상세 정보';

  @override
  String get detailInfoDesc => '추가 정보로 더 정확한 칼로리 계산이 가능합니다.';

  @override
  String get muscleType => '근육량';

  @override
  String get muscleInfo => '근육량이 많을수록 기초대사량이 높아집니다.';

  @override
  String get stepPersonality => '간단한 성격 테스트';

  @override
  String get personalityDesc => '일상 활동량 계산에 반영됩니다. (NEAT)';

  @override
  String get questionExtraversion => '평소 활기차고 외향적인가요?';

  @override
  String get questionConscientiousness => '계획적이고 규칙적인가요?';

  @override
  String get questionNeuroticism => '앉아 있을 때 자주 움직이나요?\n(손동작, 다리 떨기 등)';

  @override
  String get personalityInfo => '성격 특성에 따라 일일 권장 칼로리가 조정됩니다.';

  @override
  String get no => '아니다';

  @override
  String get yes => '그렇다';

  @override
  String get prev => '이전';

  @override
  String get somatotypeEctomorph => '외배엽형 (마른 체질)';

  @override
  String get somatotypeEctomorphDesc => '빠른 신진대사로 살이 잘 안 찌지만, 근육을 만들기 어렵습니다.';

  @override
  String get somatotypeMesomorph => '중배엽형 (근육 체질)';

  @override
  String get somatotypeMesomorphDesc => '근육을 쉽게 만들고, 체중 조절이 비교적 용이합니다.';

  @override
  String get somatotypeEndomorph => '내배엽형 (살찌기 쉬운 체질)';

  @override
  String get somatotypeEndomorphDesc => '지방이 쉽게 축적되고, 체중 감량이 어려울 수 있습니다.';

  @override
  String get somatotypeMixed => '혼합형';

  @override
  String get somatotypeMixedDesc => '여러 체질의 특성을 가지고 있습니다.';

  @override
  String get bodyShapeApple => '🍎 사과형';

  @override
  String get bodyShapeAppleDesc => '상체와 복부에 지방이 주로 축적됩니다.';

  @override
  String get bodyShapePear => '🍐 배형';

  @override
  String get bodyShapePearDesc => '하체(엉덩이, 허벅지)에 지방이 주로 축적됩니다.';

  @override
  String get bodyShapeHourglass => '⏳ 모래시계형';

  @override
  String get bodyShapeHourglassDesc => '가슴과 엉덩이가 비슷하고 허리가 잘록합니다.';

  @override
  String get bodyShapeRectangle => '📏 직사각형';

  @override
  String get bodyShapeRectangleDesc => '전체적으로 평면적이고 균등한 체형입니다.';

  @override
  String get bodyShapeInvertedTriangle => '🔺 역삼각형';

  @override
  String get bodyShapeInvertedTriangleDesc => '어깨가 넓고 엉덩이가 좁은 체형입니다.';

  @override
  String get muscleLow => '적음';

  @override
  String get muscleMedium => '보통';

  @override
  String get muscleHigh => '많음';

  @override
  String get mealBreakfast => '아침';

  @override
  String get mealLunch => '점심';

  @override
  String get mealDinner => '저녁';

  @override
  String get mealSnackMorning => '오전간식';

  @override
  String get mealSnackAfternoon => '오후간식';

  @override
  String get mealSnackEvening => '저녁간식';

  @override
  String get mealSnack => '간식';

  @override
  String get guidanceNoPattern => '식사 패턴을 설정하면 더 정확한 안내를 받을 수 있어요!';

  @override
  String guidanceDailyGoal(int goal) {
    return '하루 목표: ${goal}kcal';
  }

  @override
  String guidanceOvereating(String meal, String time, int current) {
    return '⚠️ $meal($time) 전인데 벌써 ${current}kcal를 드셨네요! 과식에 주의하세요.';
  }

  @override
  String guidanceFasting(String meal, String time) {
    return '💡 $meal($time)까지 공복 유지를 권장해요';
  }

  @override
  String get guidanceFinished => '✅ 오늘 하루 식사를 잘 마쳤습니다!';

  @override
  String guidanceLow(int diff) {
    return '💡 하루 권장량보다 ${diff}kcal 부족합니다. 간식을 드세요!';
  }

  @override
  String guidanceHigh(int diff) {
    return '⚠️ 하루 권장량보다 ${diff}kcal 초과했습니다.';
  }

  @override
  String guidanceAdequate(String context) {
    return '✅ 훌륭해요! $context 적정량을 섭취했습니다.';
  }

  @override
  String guidanceLowMid(String context, int recommended, int current) {
    return '⚠️ $context 약 ${recommended}kcal 섭취가 권장되지만,\n현재 ${current}kcal입니다. 다음 식사에서 조금 더 드세요!';
  }

  @override
  String guidanceHighMid(String context, int recommended, int current) {
    return '⚠️ $context ${recommended}kcal가 권장되는데\n${current}kcal를 섭취했습니다. 다음 식사는 가볍게!';
  }

  @override
  String get contextCurrent => '현재';

  @override
  String contextUntilMeal(String meal) {
    return '$meal까지';
  }

  @override
  String get healthPermissionWarning => '헬스 데이터 권한이 필요합니다';

  @override
  String syncSuccess(Object count) {
    return '✅ $count개의 운동 데이터 동기화 완료';
  }

  @override
  String syncError(Object error) {
    return '동기화 중 오류가 발생했습니다: $error';
  }

  @override
  String dataLoadError(Object error) {
    return '데이터 로드 실패: $error';
  }

  @override
  String get catTotal => '전체';

  @override
  String get catFruit => '과일';

  @override
  String get catStaple => '주식';

  @override
  String get catSoup => '국';

  @override
  String get catMeat => '육류';

  @override
  String get catFish => '어류';

  @override
  String get catSide => '반찬';

  @override
  String get catVegetable => '야채';

  @override
  String get catDairy => '유제품';

  @override
  String get catBakery => '제과';

  @override
  String get catSnack => '과자';

  @override
  String get catBeverage => '음료';

  @override
  String get catEtc => '기타';

  @override
  String get quickActionsTitle => '건강 챙기기';

  @override
  String get todayHealthNote => '오늘의 건강 노트';

  @override
  String get bmiUnderweight => '저체중';

  @override
  String get bmiNormal => '정상';

  @override
  String get bmiOverweight => '과체중';

  @override
  String get bmiObese => '비만';

  @override
  String get motivationOverLimit => '괜찮아요, 내일 조금 더 움직이면 돼요. 🌿';

  @override
  String get motivationNearLimit => '오늘 하루, 정말 열심히 보냈군요! ☀️';

  @override
  String get motivationGood => '당신의 속도대로 가고 있어요. 아주 잘하고 있습니다.';

  @override
  String get mealRecordButton => '식사 기록';

  @override
  String get exerciseRecordButton => '운동 기록';

  @override
  String get weightRecordButton => '체중 기록';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get weightLabel => '체중';

  @override
  String get dailyGoalLabel => '하루 권장 칼로리';

  @override
  String get currentLabel => '현재';

  @override
  String get todayLabel => '오늘';

  @override
  String get totalLabel => '전체';

  @override
  String get netCaloriesLabel => '현재 칼로리';

  @override
  String get surplusLabel => '잉여';

  @override
  String get deficitLabel => '부족';

  @override
  String get allow => '허용';

  @override
  String get deny => '거부';

  @override
  String get healthPlatformName => '헬스';

  @override
  String get exercise => '운동';

  @override
  String get kcalUnit => 'kcal';

  @override
  String get kgUnit => 'kg';

  @override
  String get kmUnit => 'km';

  @override
  String intakeTooltip(int current) {
    return '섭취: $current kcal';
  }

  @override
  String exerciseBurnTooltip(int burned) {
    return '운동: -$burned kcal';
  }

  @override
  String tdeeBurnTooltip(int tdee) {
    return 'TDEE: -$tdee kcal';
  }

  @override
  String totalBurnTooltip(int total) {
    return '소모 합계: -$total kcal';
  }

  @override
  String get currentCaloriesTooltip => '현재 칼로리';

  @override
  String remainingTooltip(int remaining) {
    return '남은 여유: $remaining kcal';
  }

  @override
  String get current => '현재';

  @override
  String get normal => '보통';

  @override
  String get total => '전체';

  @override
  String get today => '오늘';

  @override
  String get deficit => '부족';

  @override
  String get calorieGoalSettingsTitle => '목표 칼로리 설정';

  @override
  String get selectGoalMode => '목표 모드 선택';

  @override
  String get dailyCalorieGoal => '일일 목표 칼로리';

  @override
  String get minBmr => '최소(BMR)';

  @override
  String get maintainTdee => '유지(TDEE)';

  @override
  String get max => '최대';

  @override
  String get bmrLabel => '내 기초대사량 (BMR)';

  @override
  String get tdeeLabel => '내 활동대사량 (TDEE)';

  @override
  String get bmrWarning => '💡 기초대사량(BMR) 이하로 섭취하면 건강에 해로울 수 있어 최소 목표로 설정됩니다.';

  @override
  String get lossMode => '감량';

  @override
  String get maintainMode => '유지';

  @override
  String get bulkMode => '증량';

  @override
  String get weightMaintain => '현재 체중 유지';

  @override
  String weightLossPrediction(String weight) {
    return '주당 약 ${weight}kg 감량 예상';
  }

  @override
  String weightGainPrediction(String weight) {
    return '주당 약 ${weight}kg 증량 예상';
  }

  @override
  String get maintainDesc => '건강한 밸런스를 유지하고 있어요!';

  @override
  String get lossDesc => '꾸준함이 가장 중요해요. 화이팅!';

  @override
  String get bulkDesc => '근육량 증가를 위해 운동도 병행해주세요!';

  @override
  String get saveGoal => '저장하기';

  @override
  String get goalSaved => '목표가 저장되었습니다.';

  @override
  String get mealLunchPreset => '점심';

  @override
  String get mealDinnerPreset => '저녁';

  @override
  String get mealBreakfastPreset => '아침';

  @override
  String get mealSnackMorningPreset => '오전간식';

  @override
  String get mealSnackAfternoonPreset => '오후간식';

  @override
  String get appTitleMain => '치유하다 VitaBuddy';

  @override
  String get clothingSettingsTitle => '옷 색상 변경';

  @override
  String get preview => '미리보기';

  @override
  String get colorThemeSelection => '색상 테마 선택';

  @override
  String get apply => '적용';

  @override
  String get clothingColorChanged => '옷 색상이 변경되었습니다';

  @override
  String get discardChangesConfirm => '변경한 내용을 취소하고 나가시겠습니까?';

  @override
  String get stay => '머무르기';

  @override
  String get exit => '나가기';

  @override
  String get loadFoodsFailed => '음식 데이터를 불러오는데 실패했습니다';

  @override
  String get amount => '양';

  @override
  String get servings => '인분';

  @override
  String consumedOn(String date) {
    return '섭취일: $date';
  }

  @override
  String get unknown => '알 수 없음';

  @override
  String get addFood => '추가';

  @override
  String get quantityHint => '수량';

  @override
  String get servingsHint => '인분';

  @override
  String recentEaten(Object date) {
    return '최근 섭취: $date';
  }

  @override
  String get addFoodButton => '추가';

  @override
  String get mealsTab => '식사';

  @override
  String get exercisesTab => '운동';

  @override
  String get summaryTab => '요약';

  @override
  String get noMealRecords => '기록된 식사가 없습니다.';

  @override
  String get noExerciseRecords => '기록된 운동이 없습니다.';

  @override
  String get unknownFood => '알 수 없는 음식';

  @override
  String get totalIntakeCalories => '총 섭취 칼로리';

  @override
  String get totalBurnedCalories => '총 소비 칼로리';

  @override
  String get recordedWeight => '기록된 체중';

  @override
  String get noRecord => '기록 없음';

  @override
  String get netCalorieChange => '순수 칼로리 변동';

  @override
  String get mealPatternTitle => '하루 식사 패턴을 알려주세요';

  @override
  String get mealPatternSubtitle => '맞춤형 알림을 위해 식사 시간을 설정해주세요';

  @override
  String get meals2Preset => '2식';

  @override
  String get meals3Preset => '3식 (권장)';

  @override
  String get meals4Preset => '4식+';

  @override
  String get customPreset => '커스텀';

  @override
  String get mealTimes => '식사 시간';

  @override
  String get addMeal => '식사 추가';

  @override
  String get mealNameHint => '식사 이름';

  @override
  String get snackNotifications => '🍎 간식 알림';

  @override
  String get snackNotificationsDesc => '오전/오후 간식 시간 알림을 받을 수 있어요';

  @override
  String get lunch => '점심';

  @override
  String get dinner => '저녁';

  @override
  String get breakfast => '아침';

  @override
  String get morningSnack => '오전 간식';

  @override
  String mealNumber(Object number) {
    return '식사 $number';
  }

  @override
  String get energyAlertSensitivity => '⚡ 에너지 알림 민감도';

  @override
  String get mealNotifications => '📱 식사 알림';

  @override
  String get exerciseNotifications => '🏃 운동 알림';

  @override
  String get weightMeasurementNotifications => '⚖️ 체중 측정 알림';

  @override
  String get breakfastMeal => '아침 식사';

  @override
  String get lunchMeal => '점심 식사';

  @override
  String get dinnerMeal => '저녁 식사';

  @override
  String get afternoonSnack => '오후 간식';

  @override
  String get weightMeasurement => '체중 측정';

  @override
  String get exerciseTime => '운동 시간';

  @override
  String get selectDays => '요일 선택:';

  @override
  String get monday => '월';

  @override
  String get tuesday => '화';

  @override
  String get wednesday => '수';

  @override
  String get thursday => '목';

  @override
  String get friday => '금';

  @override
  String get saturday => '토';

  @override
  String get sunday => '일';

  @override
  String get energyDeficitAlertFrequency => '에너지 부족 알림 빈도';

  @override
  String get adjustAlertFrequencyDesc => '설정에 따라 알림을 더 자주 받거나 줄일 수 있습니다.';

  @override
  String get insensitive => '둔감';

  @override
  String get sensitive => '민감';

  @override
  String get minimizeNotifications => '알림 최소화';

  @override
  String get defaultSettings => '기본 설정';

  @override
  String get frequentNotifications => '자주 알림';

  @override
  String get notificationPermissionGranted => '알림 권한이 허용됨';

  @override
  String get notificationPermissionRequired => '알림 권한이 필요합니다';

  @override
  String get enablePermissionForHealthAlerts => '중요한 건강 알림을 받으려면 권한을 켜주세요.';

  @override
  String get settings => '설정';

  @override
  String get currentCaloriesLabel => '(현재 칼로리)';

  @override
  String get notificationBreakfastTitle => '좋은 아침이에요! ☀️';

  @override
  String get notificationBreakfastBody => '영양 가득한 아침 식사로 활기찬 하루를 시작하세요!';

  @override
  String get notificationLunchTitle => '점심 시간이에요! 🍱';

  @override
  String get notificationLunchBody => '균형 잡힌 점심으로 오후 활력을 채워보세요!';

  @override
  String get notificationDinnerTitle => '저녁 식사 시간이에요! 🌙';

  @override
  String get notificationDinnerBody => '건강한 저녁 식사로 하루를 마무리하세요!';

  @override
  String get notificationBrunchTitle => '브런치 시간이에요! 🥞';

  @override
  String get notificationBrunchBody => '맛있는 브런치를 즐겨보세요!';

  @override
  String notificationCustomMealTitle(Object mealName) {
    return '$mealName 시간이에요! 🍽️';
  }

  @override
  String get notificationCustomMealBody => '맛있고 건강한 식사를 즐기세요!';

  @override
  String get notificationMorningSnackTitle => '오전 간식 시간이에요! 🍎';

  @override
  String get notificationAfternoonSnackTitle => '오후 간식 시간이에요! 🥨';

  @override
  String get notificationSnackBody => '건강한 간식으로 에너지를 충전하세요!';

  @override
  String get notificationWaterTitle => '물 마실 시간이에요! 💧';

  @override
  String get notificationWaterBody => '건강을 위해 물 한 잔 어떠세요?';

  @override
  String get notificationCalorieOverTitle => '칼로리 목표 초과 ⚠️';

  @override
  String notificationCalorieOverBody(Object overAmount) {
    return '오늘 ${overAmount}kcal 초과했습니다. 건강한 식단을 유지해보세요!';
  }

  @override
  String get notificationLateNightTitle => '지금 드시나요? 🌙';

  @override
  String get notificationLateNightBody =>
      '늦은 밤 식사는 수면과 소화에 좋지 않아요. 가볍게 드시는 건 어떨까요?';

  @override
  String get notificationGoalAchievedTitle => '축하합니다! 🎉';

  @override
  String get notificationGoalAchievedBody => '오늘 칼로리 목표를 성공적으로 달성했습니다!';

  @override
  String get notificationMotivationTitle => 'VitaBuddy의 응원 💝';

  @override
  String get notificationMotivationMessage1 => '건강한 하루를 보내고 있나요? 💪';

  @override
  String get notificationMotivationMessage2 => '물 한 컵 어떠세요? 🥤';

  @override
  String get notificationMotivationMessage3 => '가벼운 스트레칭으로 상쾌함을 느껴보세요! 🤸‍♀️';

  @override
  String get notificationMotivationMessage4 => '오늘도 건강 관리 화이팅! 🌟';

  @override
  String get notificationMotivationMessage5 => '균형 잡힌 식단이 건강의 시작입니다! 🥗';

  @override
  String get notificationExerciseTitle => '운동 시간입니다! 🏃';

  @override
  String get notificationExerciseBody => '오늘의 칼로리를 태워볼까요?';

  @override
  String get notificationWeightTitle => '체중 측정 시간입니다! ⚖️';

  @override
  String get notificationWeightBody => '오늘의 몸무게를 기록하고 건강 목표를 확인해 보세요.';

  @override
  String notificationSupplementTitle(Object supplementName) {
    return '$supplementName 복용 시간입니다! 💊';
  }

  @override
  String get notificationSupplementBody => '건강 관리 잊지 마세요. 꾸준함이 중요해요!';

  @override
  String get calorieStatusVeryLow => '배고파요... 식사가 필요해요!';

  @override
  String get calorieStatusLow => '에너지가 부족해요';

  @override
  String get calorieStatusBelowIdeal => '조금 더 먹어도 괜찮아요';

  @override
  String get calorieStatusIdeal => '완벽해요! 좋은 상태예요';

  @override
  String get calorieStatusSlightlyHigh => '조금 많이 먹었네요';

  @override
  String get calorieStatusHigh => '칼로리가 높아요!';

  @override
  String get calorieStatusExceeded => '목표 초과! 운동 필요해요!';

  @override
  String get avatarLoadFailed => '아바타 로드 실패';

  @override
  String get avatarBuildFailed => '아바타 빌드 실패';

  @override
  String get sleepSettingsTitle => '수면 설정';

  @override
  String get sleepSettingsSaved => '수면 설정이 저장되었습니다.';

  @override
  String get sleepModeSection => '수면 모드';

  @override
  String get sleepTimeSettings => '수면 시간 설정';

  @override
  String get saveSettings => '저장하기';

  @override
  String get hybridMode => '하이브리드 (권장)';

  @override
  String get hybridModeDesc => '스마트워치 데이터 우선, 없을 시 수동 시간 사용';

  @override
  String get manualMode => '수동 설정';

  @override
  String get manualModeDesc => '설정된 시간에만 수면 모드 적용';

  @override
  String get deviceOnlyMode => '기기 전용';

  @override
  String get deviceOnlyModeDesc => '스마트워치 데이터만 사용';

  @override
  String get bedtime => '취침 시간';

  @override
  String get waketime => '기상 시간';

  @override
  String get clothingPresetDefault => '기본 (회색)';

  @override
  String get clothingPresetPinkBlack => '핑크/블랙';

  @override
  String get clothingPresetWhiteNavy => '흰색/네이비';

  @override
  String get clothingPresetMintCharcoal => '민트/차콜';

  @override
  String get clothingPresetLavenderPurple => '라벤더/퍼플';

  @override
  String get clothingPresetCoralGray => '코랄/그레이';

  @override
  String get timezoneSettings => '시간대 설정';

  @override
  String get selectTimezone => '시간대 선택';

  @override
  String get timezoneNotificationAdjustment => '알림 시간은 선택한 시간대에 따라 조정됩니다.';

  @override
  String timezoneSet(String timezone) {
    return '시간대가 $timezone로 설정되었습니다.';
  }

  @override
  String get healthConnectUpdateRequired =>
      '헬스 커넥트 앱의 업데이트 또는 데이터 마이그레이션이 필요합니다.\n시스템 설정 및 플레이 스토어를 확인해주세요.';

  @override
  String get healthConnectNotInstalled =>
      'Health Connect 앱이 설치되어 있지 않습니다.\nGoogle Play에서 설치 후 다시 시도해주세요.';

  @override
  String get healthConnectInitializing => 'Health Connect 초기화 중...';

  @override
  String get healthConnectCheckingStatus => 'Health Connect 상태 확인 중...';

  @override
  String healthConnectInitFailed(Object error) {
    return '헬스 커넥트 초기화 실패: $error';
  }

  @override
  String healthConnectCheckFailed(Object error) {
    return '헬스 커넥트 확인 실패: $error';
  }

  @override
  String healthConnectRequestFailed(Object error) {
    return '권한 요청 실패: $error';
  }

  @override
  String get permissionDiagnosis => '권한 진단';

  @override
  String get permissionDiagnosisResults => '권한 진단 결과';

  @override
  String get clearPermissionCache => '권한 캐시 초기화';

  @override
  String get permissionCacheCleared => '권한 캐시가 초기화되었습니다. 앱을 재시작해주세요.';

  @override
  String get syncingHealthData => '헬스 데이터 동기화 중...';

  @override
  String get close => '닫기';

  @override
  String get waterIntakeManagement => '수분 섭취 관리';

  @override
  String get supplementNotifications => '비타민/보충제 알림';

  @override
  String get addSupplement => '보충제 추가';

  @override
  String get supplementName => '보충제 이름';

  @override
  String get supplementTime => '섭취 시간';

  @override
  String get waterReminder => '물 마시기 알림';

  @override
  String get waterInterval => '알림 간격 (분)';

  @override
  String get waterStartTime => '시작 시간';

  @override
  String get noSupplementsRegistered => '등록된 보충제가 없습니다. + 버튼을 눌러 추가하세요.';

  @override
  String get maxSupplementsReached => '보충제는 최대 3개까지 등록할 수 있습니다.';

  @override
  String dailyWaterGoal(int goal) {
    return '하루 목표: ${goal}ml';
  }

  @override
  String get editSupplement => '보충제 수정';

  @override
  String get dailyGoal => '하루 목표';

  @override
  String get supplementHintText => '비타민 C, 오메가3 등';

  @override
  String get recommendedWaterIntake => '권장 수분 섭취량';

  @override
  String get recommendedBasedOnProfile => '체중과 활동량을 기반으로 계산된 권장량입니다';

  @override
  String get yourDailyGoal => '나의 하루 목표';

  @override
  String get canAdjustManually => '직접 조정할 수 있습니다 (1000~5000ml)';

  @override
  String get useRecommendedAmount => '권장량 적용';

  @override
  String get barcodeScan => '바코드 스캔';

  @override
  String get cameraPermissionRequired => '카메라 권한이 필요합니다. 설정에서 권한을 허용해주세요.';

  @override
  String get cameraInitializing => '카메라 초기화 중...';

  @override
  String cameraInitFailed(String error) {
    return '카메라 초기화에 실패했습니다: $error';
  }

  @override
  String get barcodeDetected => '바코드 감지됨!';

  @override
  String get pointCameraAtBarcode => '바코드를 카메라에 비춰주세요\n(어디에나 바코드가 있으면 인식됩니다)';

  @override
  String get barcodeVerified => '바코드 검증 완료!';

  @override
  String get invalidBarcode => '유효하지 않은 바코드';

  @override
  String get type => '타입';

  @override
  String get confidence => '신뢰도';

  @override
  String get scanCount => '스캔 횟수';

  @override
  String get accept => '사용';

  @override
  String get rescan => '재스캔';

  @override
  String get supportedFormats => '지원 형식: QR코드, 바코드 (EAN-13, UPC-A 등)';

  @override
  String get localSearch => '로컬 검색';

  @override
  String get onlineSearch => '인터넷 검색';

  @override
  String get barcodeSearching => '바코드 검색 중...';

  @override
  String get barcodeSearchResults => '바코드 검색 결과';

  @override
  String get barcodeSearchFailed => '바코드 검색 실패';

  @override
  String get barcodeFormatEan13 => 'EAN-13 (상품 바코드)';

  @override
  String get barcodeFormatEan8 => 'EAN-8 (짧은 상품 바코드)';

  @override
  String get barcodeFormatUpca => 'UPC-A (미국 상품 바코드)';

  @override
  String get barcodeFormatUpce => 'UPC-E (짧은 미국 상품 바코드)';

  @override
  String get barcodeFormatQrCode => 'QR 코드';

  @override
  String get barcodeFormatCode128 => 'Code 128 (상업용)';

  @override
  String get barcodeFormatCode39 => 'Code 39 (산업용)';

  @override
  String get barcodeFormatCode93 => 'Code 93';

  @override
  String get barcodeFormatCodabar => 'Codabar';

  @override
  String get barcodeFormatItf => 'ITF (Interleaved 2 of 5)';

  @override
  String get barcodeFormatAztec => 'Aztec 코드';

  @override
  String get barcodeFormatDataMatrix => 'Data Matrix';

  @override
  String get barcodeFormatPdf417 => 'PDF417';

  @override
  String get barcodeFormatUnknown => '알 수 없는 형식';

  @override
  String get searchOnlineHint => '인터넷에서 음식 검색...';

  @override
  String get search100gHint => '100g당 입력은 검색 탭을 이용해주세요.';

  @override
  String get quantityLabel => '수량:';

  @override
  String equalsCalories(int calories) {
    return '= ${calories}kcal';
  }

  @override
  String get calorieInfoSaved => '칼로리 정보가 저장되었습니다';

  @override
  String get enterValidCaloriesDialog => '올바른 칼로리 값을 입력해주세요';

  @override
  String get calorieInfoNotFound =>
      '이 음식의 칼로리 정보를 찾을 수 없습니다.\n구글에서 검색하거나 직접 입력해주세요.';

  @override
  String get searchGoogle => '구글에서 검색';

  @override
  String get noCameraAvailable => '사용 가능한 카메라가 없습니다.';

  @override
  String get cameraReady => '카메라 준비 중...';

  @override
  String get requestPermission => '권한 요청';

  @override
  String get openSettings => '설정으로 이동';

  @override
  String get flashToggle => '플래시 토글';

  @override
  String get confidenceLabel => '신뢰도';

  @override
  String get scanCountLabel => '스캔 횟수';

  @override
  String get checkingCameraPermission => '카메라 권한을 확인하는 중...';

  @override
  String get cameraPermissionRequestFailed => '카메라 권한 요청에 실패했습니다.';

  @override
  String get cameraPermissionPermanentlyDenied =>
      '카메라 권한이 영구적으로 거부되었습니다. 설정 앱에서 권한을 허용해주세요.';

  @override
  String get cameraPermissionDenied => '카메라 권한이 거부되었습니다.';

  @override
  String get cameraPermissionUnknown => '카메라 권한 상태를 확인할 수 없습니다.';

  @override
  String get brandLabel => '브랜드';

  @override
  String apiResultsFound(int count) {
    return '총 $count개의 결과를 찾았습니다.';
  }

  @override
  String foodNotFoundInDatabase(String apiName) {
    return '$apiName 데이터베이스에서 이 음식을 찾을 수 없습니다.';
  }

  @override
  String apiKeyRequired(String apiName) {
    return '설정에서 $apiName API 키를 입력하면 더 정확한 검색이 가능합니다.';
  }

  @override
  String apiSearchError(String apiName) {
    return '$apiName 검색 중 오류가 발생했습니다.';
  }

  @override
  String get noDataStatus => '데이터 없음';

  @override
  String get dataNotFoundTitle => '데이터에 없음';

  @override
  String get settingsRequired => '설정 필요';

  @override
  String get errorStatus => '오류';
}
