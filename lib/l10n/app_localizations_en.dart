// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VitaBuddy';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeSubtitle => 'Have a healthy day!';

  @override
  String get caloriesUnit => 'kcal';

  @override
  String get intakeLabel => 'Intake';

  @override
  String get burnedLabel => 'Burned';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get goalLabel => 'Goal';

  @override
  String get minutesUnit => 'min';

  @override
  String get exerciseRecord => 'Exercise Record';

  @override
  String get foodRecord => 'Food Record';

  @override
  String get dailySummary => 'Daily Summary';

  @override
  String get wearableConnected => 'Connected';

  @override
  String get wearablePermissionRequired => 'Permission Required';

  @override
  String get wearableNotConnected => 'Not connected';

  @override
  String get walkingActivity => 'Walking';

  @override
  String get runningActivity => 'Running';

  @override
  String get cyclingActivity => 'Cycling';

  @override
  String get swimmingActivity => 'Swimming';

  @override
  String get weightTrainingActivity => 'Weight Training';

  @override
  String get yogaActivity => 'Yoga';

  @override
  String get dancingActivity => 'Dancing';

  @override
  String get hikingActivity => 'Hiking';

  @override
  String get tennisActivity => 'Tennis';

  @override
  String get basketballActivity => 'Basketball';

  @override
  String get soccerActivity => 'Soccer';

  @override
  String get aerobicsActivity => 'Aerobics';

  @override
  String get badmintonActivity => 'Badminton';

  @override
  String get baseballActivity => 'Baseball';

  @override
  String get boxingActivity => 'Boxing';

  @override
  String get golfActivity => 'Golf';

  @override
  String get pilatesActivity => 'Pilates';

  @override
  String get tableTennisActivity => 'Table Tennis';

  @override
  String get volleyballActivity => 'Volleyball';

  @override
  String get ellipticalActivity => 'Elliptical';

  @override
  String get rowingActivity => 'Rowing';

  @override
  String get stairClimbingActivity => 'Stair Climbing';

  @override
  String get otherActivity => 'Other';

  @override
  String get sourceManual => 'Manual';

  @override
  String get sourceHealthConnect => 'Health Connect';

  @override
  String get sourceHealthKit => 'HealthKit';

  @override
  String get workoutTypeLabel => 'Workout Type';

  @override
  String get durationLabel => 'Duration (min)';

  @override
  String get intensityLabel => 'Intensity';

  @override
  String get intensityLow => 'Low';

  @override
  String get intensityMedium => 'Medium';

  @override
  String get intensityHigh => 'High';

  @override
  String get calcCaloriesLabel => 'Estimated Calories';

  @override
  String get calorieCalcError => 'Calorie calculation error';

  @override
  String workoutSaved(Object type) {
    return '$type recorded';
  }

  @override
  String saveError(Object error) {
    return 'Save failed: $error';
  }

  @override
  String get syncComplete => 'Sync complete';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get noDataToSync => 'No data to sync';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileTitle => 'Profile';

  @override
  String get languageTitle => 'Language';

  @override
  String get calorieGoalSettings => 'Calorie Goal Settings';

  @override
  String get sleepSettings => 'Sleep Settings';

  @override
  String get avatarClothingSettings => 'Avatar Clothing Settings';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get healthDataPermission => 'Health Data Permission';

  @override
  String get healthPermissionAlreadyGranted =>
      'Health data permission is already granted';

  @override
  String get healthPermissionGranted => 'Health data permission granted';

  @override
  String get healthPermissionDenied =>
      'Health data permission denied. Please enable it in settings.';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get autoRecord => 'Auto Record';

  @override
  String get manualRecord => 'Manual Record';

  @override
  String get caloriesBurned => 'Calories Burned';

  @override
  String get workoutCount => 'Workout Count';

  @override
  String get steps => 'Steps';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncHealthData => 'Sync Health Data';

  @override
  String get noAutoRecords => 'No auto-recorded workouts';

  @override
  String get noAutoRecordsSubtitle =>
      'Press the Health Data Sync button to\nimport workout data from your phone and wearable';

  @override
  String get noManualRecords => 'No manually recorded workouts';

  @override
  String get noManualRecordsSubtitle =>
      'Tap the + button at the bottom right\nto record your workout manually';

  @override
  String get dataLoadFailed => 'Failed to load data';

  @override
  String get basicInfo => 'Basic';

  @override
  String get bodyInfo => 'Body';

  @override
  String get personality => 'Personality';

  @override
  String get previous => 'Previous';

  @override
  String get nameOptional => 'Name (Optional)';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get activitySedentary => 'Sedentary (little or no exercise)';

  @override
  String get activityLight => 'Light exercise (1-3 days/week)';

  @override
  String get activityModerate => 'Moderate exercise (3-5 days/week)';

  @override
  String get activityActive => 'Active exercise (6-7 days/week)';

  @override
  String get activityVeryActive => 'Very active (twice per day)';

  @override
  String get sedentary => 'Sedentary (little or no exercise)';

  @override
  String get lightExercise => 'Light exercise (1-3 days/week)';

  @override
  String get moderateExercise => 'Moderate exercise (3-5 days/week)';

  @override
  String get activeExercise => 'Active exercise (6-7 days/week)';

  @override
  String get veryActiveExercise => 'Very active (twice per day)';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get discardChanges => 'Discard Changes';

  @override
  String get discardChangesMessage => 'Leave without saving changes?';

  @override
  String get continueEditing => 'Continue Editing';

  @override
  String get exitWithoutSaving => 'Exit';

  @override
  String get complete => 'Complete';

  @override
  String get next => 'Next';

  @override
  String get foodInput => 'Food Input';

  @override
  String get recent => 'Recent';

  @override
  String get favorites => 'Favorites';

  @override
  String get search => 'Search';

  @override
  String get customAdd => 'Custom';

  @override
  String get noRecentFoods => 'No recent foods';

  @override
  String get noFavoriteFoods => 'No favorite foods';

  @override
  String get addFavoriteHint => 'Tap ⭐ on food list to add favorites';

  @override
  String get noSearchResults => 'No search results';

  @override
  String get searchFoodHint => 'Search food...';

  @override
  String get foodName => 'Food Name';

  @override
  String get calories => 'Calories';

  @override
  String get quantity => 'Quantity';

  @override
  String get servingCalories => 'Serving Calories';

  @override
  String get servingCount => 'Serving Count';

  @override
  String get foodNameHint => 'e.g. Hamburger';

  @override
  String get caloriesHint => 'e.g. 550';

  @override
  String get addIntake => 'Add Intake';

  @override
  String get saveTemporary => 'Quick Save (Add calories later)';

  @override
  String get invalidQuantity => 'Please enter a valid quantity';

  @override
  String get foodAdded => 'Food added';

  @override
  String get foodAddFailed => 'Failed to add food';

  @override
  String get favoriteAdded => 'Added to favorites';

  @override
  String get favoriteRemoved => 'Removed from favorites';

  @override
  String get inputModeTotal => 'Total';

  @override
  String get inputModeServing => 'Serving';

  @override
  String get inputMode100g => '100g';

  @override
  String get inputModeQuick => 'Quick';

  @override
  String get add => 'Add';

  @override
  String get enterFoodNameAndCalories => 'Please enter food name and calories';

  @override
  String get enterValidCalories => 'Please enter valid calories';

  @override
  String get userFoodAddFailed => 'Failed to add user food';

  @override
  String get enterFoodName => 'Please enter food name';

  @override
  String get quickSaveSuccess => 'Saved temporarily (Add calories later)';

  @override
  String get servingInfoHelp =>
      'Enter the serving size info from nutrition label';

  @override
  String get servingUnit => 'times';

  @override
  String get unitServings => 'servings';

  @override
  String get unitCount => 'count/servings';

  @override
  String get foodAddTitle => 'Add Food';

  @override
  String foodAddConfirm(String foodName) {
    return 'Add $foodName?';
  }

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get totalCalorieHelp => 'Enter total calories directly';

  @override
  String get quickRecordHelp => 'Enter name only and add calories later';

  @override
  String get defaultLabel => 'Default';

  @override
  String get weightRecord => 'Weight Record';

  @override
  String get weightLoadFailed => 'Failed to load weight records';

  @override
  String get enterWeight => 'Please enter weight';

  @override
  String get enterValidWeight => 'Please enter valid weight (20-300kg)';

  @override
  String get weightRecorded => 'Weight recorded';

  @override
  String get weightRecordFailed => 'Failed to record weight';

  @override
  String get weightRecordDeleted => 'Weight record deleted';

  @override
  String get deleteFailed => 'Failed to delete record';

  @override
  String get todaysWeight => 'Today\'s Weight';

  @override
  String get weightHint => 'e.g. 70.5';

  @override
  String get record => 'Record';

  @override
  String get noteOptional => 'Note (Optional)';

  @override
  String get noteHint => 'e.g. After workout';

  @override
  String get weightTrend => 'Weight Trend';

  @override
  String get noWeightRecords => 'No weight records';

  @override
  String get deleteRecord => 'Delete Record';

  @override
  String get confirmDeleteWeight => 'Delete this weight record?';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get getStarted => 'Get Started';

  @override
  String get language => 'Language';

  @override
  String get healthPermissionContent =>
      'The app needs access to health data to sync calories with wearable devices.';

  @override
  String get healthPermissionAllowInfo => 'If allowed:';

  @override
  String get healthPermissionInfo1 =>
      '• Automatically sync steps and calorie burn';

  @override
  String get healthPermissionInfo2 => '• Automatically import exercise records';

  @override
  String get healthPermissionInfo3 => '• More accurate calorie management';

  @override
  String get healthPermissionDenyInfo =>
      'You can still use basic app features even if denied.';

  @override
  String get later => 'Later';

  @override
  String get allowPermission => 'Allow';

  @override
  String get permissionSelect => 'Select Permission';

  @override
  String get allowAndSync => 'Allow and Sync';

  @override
  String get setupLater => 'Setup Later';

  @override
  String get history => 'History';

  @override
  String get errorOccurred => 'Error Occurred';

  @override
  String get noRecords => 'No records yet.';

  @override
  String get pleaseSelectLanguage => 'Please select a language';

  @override
  String get homeTitle => 'Chiyuhada VitaBuddy';

  @override
  String get mealRecord => 'Meal Record';

  @override
  String get viewRecords => 'View Records';

  @override
  String get developerTest => 'Developer Test Screen';

  @override
  String get mealGuidance => 'Meal Guidance';

  @override
  String get nextMeal => 'Next Meal';

  @override
  String get moreNeeded => 'more needed';

  @override
  String get reduce => 'reduce';

  @override
  String get until => 'until';

  @override
  String get sleepMode => 'Sleep Mode';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get notConnected => 'Not connected';

  @override
  String get justSynced => 'Just synced';

  @override
  String get syncedJustNow => 'Just synced';

  @override
  String syncedMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String syncedHoursAgo(int hours) {
    return '$hours hrs ago';
  }

  @override
  String get minutesAgo => 'min ago';

  @override
  String get hoursAgo => 'hrs ago';

  @override
  String get minutesShort => 'min';

  @override
  String get changeClothingColor => 'Change clothing color';

  @override
  String get walking => 'Walking';

  @override
  String get running => 'Running';

  @override
  String get cycling => 'Cycling';

  @override
  String get swimming => 'Swimming';

  @override
  String get user => 'User';

  @override
  String homeGreetingFormat(String greeting, String user) {
    return '$greeting, $user!';
  }

  @override
  String get reduceIntake => 'Reduce intake';

  @override
  String get profileSetup => 'Profile Setup';

  @override
  String get stepBasicInfo => 'Basic Info';

  @override
  String get basicInfoDesc =>
      'Please enter basic info for accurate calorie calculation.';

  @override
  String get nameHint => 'e.g. John Doe';

  @override
  String get yearsOld => 'years old';

  @override
  String get ageUnit => 'years';

  @override
  String get stepMealPattern => 'Meal Pattern';

  @override
  String get mealPatternSetup => 'Meal Pattern Setup';

  @override
  String get mealPatternDesc =>
      'Set your daily meal pattern to get personalized notifications.';

  @override
  String get meals2 => '2 Meals';

  @override
  String get meals3 => '3 Meals (Recommended)';

  @override
  String get meals4 => '4 Meals';

  @override
  String get meals4Plus => '4 Meals+';

  @override
  String get mealTimeSettings => 'Meal Time Settings';

  @override
  String get configuredMealTimes => 'Configured Meal Times';

  @override
  String get stepSomatotype => 'Somatotype';

  @override
  String get somatotypeSelection => 'Body Type Selection';

  @override
  String get somatotypeDesc =>
      'Select your somatotype. It affects metabolic rate calculation.';

  @override
  String get dontKnow => 'I don\'t know';

  @override
  String get unsure => 'Not sure';

  @override
  String get stepBodyShape => 'Body Shape';

  @override
  String get bodyShapeSelection => 'Body Shape Selection';

  @override
  String get bodyShapeDesc =>
      'Where do you gain weight? Affects avatar appearance.';

  @override
  String get stepDetailInfo => 'Detailed Info';

  @override
  String get detailInfoDesc =>
      'Additional info enables more accurate calculation.';

  @override
  String get muscleType => 'Muscle Mass';

  @override
  String get muscleInfo => 'Higher muscle mass increases BMR.';

  @override
  String get stepPersonality => 'Personality Test';

  @override
  String get personalityDesc => 'Affects daily activity calculation (NEAT).';

  @override
  String get questionExtraversion =>
      'Are you generally energetic and extraverted?';

  @override
  String get questionConscientiousness => 'Are you organized and disciplined?';

  @override
  String get questionNeuroticism =>
      'Do you move often while sitting?\n(Fidgeting, etc.)';

  @override
  String get personalityInfo =>
      'Daily recommended calories are adjusted based on personality traits.';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get prev => 'Previous';

  @override
  String get somatotypeEctomorph => 'Ectomorph (Lean)';

  @override
  String get somatotypeEctomorphDesc =>
      'Fast metabolism, hard to gain weight and muscle.';

  @override
  String get somatotypeMesomorph => 'Mesomorph (Muscular)';

  @override
  String get somatotypeMesomorphDesc =>
      'Easy to build muscle, relatively easy weight control.';

  @override
  String get somatotypeEndomorph => 'Endomorph (Curvy)';

  @override
  String get somatotypeEndomorphDesc =>
      'Gains fat easily, weight loss can be difficult.';

  @override
  String get somatotypeMixed => 'Mixed Type';

  @override
  String get somatotypeMixedDesc => 'Combination of multiple body types.';

  @override
  String get bodyShapeApple => '🍎 Apple';

  @override
  String get bodyShapeAppleDesc =>
      'Fat accumulates mainly in upper body and abdomen.';

  @override
  String get bodyShapePear => '🍐 Pear';

  @override
  String get bodyShapePearDesc =>
      'Fat accumulates mainly in lower body (hips, thighs).';

  @override
  String get bodyShapeHourglass => '⏳ Hourglass';

  @override
  String get bodyShapeHourglassDesc =>
      'Balanced bust and hips with a defined waist.';

  @override
  String get bodyShapeRectangle => '📏 Rectangle';

  @override
  String get bodyShapeRectangleDesc => 'Generally flat and uniform body shape.';

  @override
  String get bodyShapeInvertedTriangle => '🔺 Inverted Triangle';

  @override
  String get bodyShapeInvertedTriangleDesc =>
      'Broad shoulders and narrow hips.';

  @override
  String get muscleLow => 'Low';

  @override
  String get muscleMedium => 'Medium';

  @override
  String get muscleHigh => 'High';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnackMorning => 'Morning Snack';

  @override
  String get mealSnackAfternoon => 'Afternoon Snack';

  @override
  String get mealSnackEvening => 'Evening Snack';

  @override
  String get mealSnack => 'Snack';

  @override
  String get guidanceNoPattern =>
      'Set up your meal pattern for more accurate guidance!';

  @override
  String guidanceDailyGoal(int goal) {
    return 'Daily Goal: ${goal}kcal';
  }

  @override
  String guidanceOvereating(String meal, String time, int current) {
    return '⚠️ You\'ve already eaten ${current}kcal before $meal($time)! Watch out for overeating.';
  }

  @override
  String guidanceFasting(String meal, String time) {
    return '💡 Recommended to fast until $meal($time).';
  }

  @override
  String get guidanceFinished => '✅ You\'ve finished your meals for today!';

  @override
  String guidanceLow(int diff) {
    return '💡 You are ${diff}kcal below the daily target. Have a snack!';
  }

  @override
  String guidanceHigh(int diff) {
    return '⚠️ You are ${diff}kcal over the daily target.';
  }

  @override
  String guidanceAdequate(String context) {
    return '✅ Great! You\'ve eaten the right amount $context.';
  }

  @override
  String guidanceLowMid(String context, int recommended, int current) {
    return '⚠️ Recommended ${recommended}kcal $context, but you\'re at ${current}kcal. Eat a bit more at the next meal!';
  }

  @override
  String guidanceHighMid(String context, int recommended, int current) {
    return '⚠️ Recommended ${recommended}kcal $context, but you\'re at ${current}kcal. Eat lighter next time!';
  }

  @override
  String get contextCurrent => 'currently';

  @override
  String contextUntilMeal(String meal) {
    return 'until $meal';
  }

  @override
  String get healthPermissionWarning => 'Health data permission is required';

  @override
  String syncSuccess(Object count) {
    return '✅ $count exercise records synced';
  }

  @override
  String syncError(Object error) {
    return 'Error during sync: $error';
  }

  @override
  String dataLoadError(Object error) {
    return 'Failed to load data: $error';
  }

  @override
  String get catTotal => 'All';

  @override
  String get catFruit => 'Fruit';

  @override
  String get catStaple => 'Staple';

  @override
  String get catSoup => 'Soup';

  @override
  String get catMeat => 'Meat';

  @override
  String get catFish => 'Fish';

  @override
  String get catSide => 'Side Dish';

  @override
  String get catVegetable => 'Vegetable';

  @override
  String get catDairy => 'Dairy';

  @override
  String get catBakery => 'Bakery';

  @override
  String get catSnack => 'Snack';

  @override
  String get catBeverage => 'Beverage';

  @override
  String get catEtc => 'Etc';

  @override
  String get quickActionsTitle => 'Take Care of Your Health';

  @override
  String get todayHealthNote => 'Today\'s Health Note';

  @override
  String get bmiUnderweight => 'Underweight';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Overweight';

  @override
  String get bmiObese => 'Obese';

  @override
  String get motivationOverLimit =>
      'Don\'t worry, you can move a little more tomorrow. 🌿';

  @override
  String get motivationNearLimit => 'You\'ve worked hard today! ☀️';

  @override
  String get motivationGood =>
      'You\'re going at your own pace. You\'re doing very well.';

  @override
  String get mealRecordButton => 'Meal Record';

  @override
  String get exerciseRecordButton => 'Exercise Record';

  @override
  String get weightRecordButton => 'Weight Record';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get weightLabel => 'Weight';

  @override
  String get dailyGoalLabel => 'Daily Goal';

  @override
  String get currentLabel => 'Current';

  @override
  String get todayLabel => 'Today';

  @override
  String get totalLabel => 'Total';

  @override
  String get netCaloriesLabel => 'Net Calories';

  @override
  String get surplusLabel => 'Surplus';

  @override
  String get deficitLabel => 'Deficit';

  @override
  String get allow => 'Allow';

  @override
  String get deny => 'Deny';

  @override
  String get healthPlatformName => 'Health';

  @override
  String get exercise => 'Exercise';

  @override
  String get kcalUnit => 'kcal';

  @override
  String get kgUnit => 'kg';

  @override
  String get kmUnit => 'km';

  @override
  String intakeTooltip(int current) {
    return 'Intake: $current kcal';
  }

  @override
  String exerciseBurnTooltip(int burned) {
    return 'Exercise: -$burned kcal';
  }

  @override
  String tdeeBurnTooltip(int tdee) {
    return 'TDEE: -$tdee kcal';
  }

  @override
  String totalBurnTooltip(int total) {
    return 'Total Burned: -$total kcal';
  }

  @override
  String get currentCaloriesTooltip => 'Current Calories';

  @override
  String remainingTooltip(int remaining) {
    return 'Remaining: $remaining kcal';
  }

  @override
  String get current => 'Current';

  @override
  String get normal => 'Normal';

  @override
  String get total => 'Total';

  @override
  String get today => 'Today';

  @override
  String get deficit => 'Deficit';

  @override
  String get calorieGoalSettingsTitle => 'Calorie Goal Settings';

  @override
  String get selectGoalMode => 'Select Goal Mode';

  @override
  String get dailyCalorieGoal => 'Daily Calorie Goal';

  @override
  String get minBmr => 'Min (BMR)';

  @override
  String get maintainTdee => 'Maintain (TDEE)';

  @override
  String get max => 'Max';

  @override
  String get bmrLabel => 'My Basal Metabolic Rate (BMR)';

  @override
  String get tdeeLabel => 'My Total Daily Energy Expenditure (TDEE)';

  @override
  String get bmrWarning =>
      '💡 Consuming below Basal Metabolic Rate (BMR) may be harmful to health and is set as minimum goal.';

  @override
  String get lossMode => 'Loss';

  @override
  String get maintainMode => 'Maintain';

  @override
  String get bulkMode => 'Bulk';

  @override
  String get weightMaintain => 'Current Weight Maintenance';

  @override
  String weightLossPrediction(String weight) {
    return 'Expected ~${weight}kg loss per week';
  }

  @override
  String weightGainPrediction(String weight) {
    return 'Expected ~${weight}kg gain per week';
  }

  @override
  String get maintainDesc => 'You\'re maintaining a healthy balance!';

  @override
  String get lossDesc => 'Consistency is most important. Fighting!';

  @override
  String get bulkDesc => 'Please also exercise to increase muscle mass!';

  @override
  String get saveGoal => 'Save';

  @override
  String get goalSaved => 'Goal saved.';

  @override
  String get mealLunchPreset => 'Lunch';

  @override
  String get mealDinnerPreset => 'Dinner';

  @override
  String get mealBreakfastPreset => 'Breakfast';

  @override
  String get mealSnackMorningPreset => 'Morning Snack';

  @override
  String get mealSnackAfternoonPreset => 'Afternoon Snack';

  @override
  String get appTitleMain => 'ChiYuHada VitaBuddy';

  @override
  String get clothingSettingsTitle => 'Change Clothing Color';

  @override
  String get preview => 'Preview';

  @override
  String get colorThemeSelection => 'Color Theme Selection';

  @override
  String get apply => 'Apply';

  @override
  String get clothingColorChanged => 'Clothing color has been changed';

  @override
  String get discardChangesConfirm =>
      'Do you want to discard changes and exit?';

  @override
  String get stay => 'Stay';

  @override
  String get exit => 'Exit';

  @override
  String get loadFoodsFailed => 'Failed to load food data';

  @override
  String get amount => 'Amount';

  @override
  String get servings => 'servings';

  @override
  String consumedOn(String date) {
    return '섭취일: $date';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get addFood => 'Add Food';

  @override
  String get quantityHint => 'Quantity';

  @override
  String get servingsHint => 'servings';

  @override
  String recentEaten(Object date) {
    return 'Recently eaten: $date';
  }

  @override
  String get addFoodButton => 'Add';

  @override
  String get mealsTab => 'Meals';

  @override
  String get exercisesTab => 'Exercises';

  @override
  String get summaryTab => 'Summary';

  @override
  String get noMealRecords => 'No meal records found.';

  @override
  String get noExerciseRecords => 'No exercise records found.';

  @override
  String get unknownFood => 'Unknown Food';

  @override
  String get totalIntakeCalories => 'Total Intake Calories';

  @override
  String get totalBurnedCalories => 'Total Burned Calories';

  @override
  String get recordedWeight => 'Recorded Weight';

  @override
  String get noRecord => 'No Record';

  @override
  String get netCalorieChange => 'Net Calorie Change';

  @override
  String get mealPatternTitle => 'Tell us about your daily meal pattern';

  @override
  String get mealPatternSubtitle =>
      'Set meal times for personalized notifications';

  @override
  String get meals2Preset => '2 Meals';

  @override
  String get meals3Preset => '3 Meals (Recommended)';

  @override
  String get meals4Preset => '4 Meals+';

  @override
  String get customPreset => 'Custom';

  @override
  String get mealTimes => 'Meal Times';

  @override
  String get addMeal => 'Add Meal';

  @override
  String get mealNameHint => 'Meal name';

  @override
  String get snackNotifications => '🍎 Snack Notifications';

  @override
  String get snackNotificationsDesc =>
      'You can receive notifications for morning/afternoon snack times';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get morningSnack => 'Morning Snack';

  @override
  String mealNumber(Object number) {
    return 'Meal $number';
  }

  @override
  String get energyAlertSensitivity => '⚡ Energy Alert Sensitivity';

  @override
  String get mealNotifications => '📱 Meal Notifications';

  @override
  String get exerciseNotifications => '🏃 Exercise Notifications';

  @override
  String get weightMeasurementNotifications =>
      '⚖️ Weight Measurement Notifications';

  @override
  String get breakfastMeal => 'Breakfast';

  @override
  String get lunchMeal => 'Lunch';

  @override
  String get dinnerMeal => 'Dinner';

  @override
  String get afternoonSnack => 'Afternoon Snack';

  @override
  String get weightMeasurement => 'Weight Measurement';

  @override
  String get exerciseTime => 'Exercise Time';

  @override
  String get selectDays => 'Select Days:';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get energyDeficitAlertFrequency => 'Energy Deficit Alert Frequency';

  @override
  String get adjustAlertFrequencyDesc =>
      'You can receive notifications more or less frequently depending on settings.';

  @override
  String get insensitive => 'Insensitive';

  @override
  String get sensitive => 'Sensitive';

  @override
  String get minimizeNotifications => 'Minimize notifications';

  @override
  String get defaultSettings => 'Default settings';

  @override
  String get frequentNotifications => 'Frequent notifications';

  @override
  String get notificationPermissionGranted => 'Notification permission granted';

  @override
  String get notificationPermissionRequired =>
      'Notification permission required';

  @override
  String get enablePermissionForHealthAlerts =>
      'Please enable permission to receive important health notifications.';

  @override
  String get settings => 'Settings';

  @override
  String get currentCaloriesLabel => '(Current Calories)';

  @override
  String get notificationBreakfastTitle => 'Good morning! ☀️';

  @override
  String get notificationBreakfastBody =>
      'Start your day with a nutritious breakfast full of energy!';

  @override
  String get notificationLunchTitle => 'Lunch time! 🍱';

  @override
  String get notificationLunchBody =>
      'Recharge your afternoon with a balanced lunch!';

  @override
  String get notificationDinnerTitle => 'Dinner time! 🌙';

  @override
  String get notificationDinnerBody => 'End your day with a healthy dinner!';

  @override
  String get notificationBrunchTitle => 'Brunch time! 🥞';

  @override
  String get notificationBrunchBody => 'Enjoy a delightful brunch!';

  @override
  String notificationCustomMealTitle(Object mealName) {
    return '$mealName time! 🍽️';
  }

  @override
  String get notificationCustomMealBody =>
      'Enjoy a delicious and healthy meal!';

  @override
  String get notificationMorningSnackTitle => 'Morning snack time! 🍎';

  @override
  String get notificationAfternoonSnackTitle => 'Afternoon snack time! 🥨';

  @override
  String get notificationSnackBody => 'Recharge with a healthy snack!';

  @override
  String get notificationWaterTitle => 'Time to drink water! 💧';

  @override
  String get notificationWaterBody =>
      'How about a glass of water for your health?';

  @override
  String get notificationCalorieOverTitle => 'Calorie goal exceeded ⚠️';

  @override
  String notificationCalorieOverBody(Object overAmount) {
    return 'You exceeded ${overAmount}kcal today. Try maintaining a healthy diet!';
  }

  @override
  String get notificationLateNightTitle => 'Eating now? 🌙';

  @override
  String get notificationLateNightBody =>
      'Late-night eating isn\'t good for sleep and digestion. How about something light?';

  @override
  String get notificationGoalAchievedTitle => 'Congratulations! 🎉';

  @override
  String get notificationGoalAchievedBody =>
      'You successfully achieved today\'s calorie goal!';

  @override
  String get notificationMotivationTitle => 'VitaBuddy\'s encouragement 💝';

  @override
  String get notificationMotivationMessage1 =>
      'Are you having a healthy day? 💪';

  @override
  String get notificationMotivationMessage2 => 'How about a glass of water? 🥤';

  @override
  String get notificationMotivationMessage3 =>
      'Try feeling refreshed with light stretching! 🤸‍♀️';

  @override
  String get notificationMotivationMessage4 =>
      'Keep up the health management today! 🌟';

  @override
  String get notificationMotivationMessage5 =>
      'A balanced diet is the start of health! 🥗';

  @override
  String get notificationExerciseTitle => 'Exercise time! 🏃';

  @override
  String get notificationExerciseBody => 'How about burning today\'s calories?';

  @override
  String get notificationWeightTitle => 'Time to measure weight! ⚖️';

  @override
  String get notificationWeightBody =>
      'Record today\'s weight and check your health goals.';

  @override
  String notificationSupplementTitle(Object supplementName) {
    return '$supplementName time! 💊';
  }

  @override
  String get notificationSupplementBody =>
      'Don\'t forget health management. Consistency is important!';

  @override
  String get calorieStatusVeryLow => 'I\'m hungry... I need a meal!';

  @override
  String get calorieStatusLow => 'Energy is low';

  @override
  String get calorieStatusBelowIdeal => 'It\'s okay to eat a bit more';

  @override
  String get calorieStatusIdeal => 'Perfect! You\'re in good shape';

  @override
  String get calorieStatusSlightlyHigh => 'You\'ve eaten a bit too much';

  @override
  String get calorieStatusHigh => 'Calories are high!';

  @override
  String get calorieStatusExceeded => 'Goal exceeded! Exercise needed!';

  @override
  String get avatarLoadFailed => 'Avatar load failed';

  @override
  String get avatarBuildFailed => 'Avatar build failed';

  @override
  String get sleepSettingsTitle => 'Sleep Settings';

  @override
  String get sleepSettingsSaved => 'Sleep settings have been saved.';

  @override
  String get sleepModeSection => 'Sleep Mode';

  @override
  String get sleepTimeSettings => 'Sleep Time Settings';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get hybridMode => 'Hybrid (Recommended)';

  @override
  String get hybridModeDesc =>
      'Prioritize smartwatch data, use manual time if not available';

  @override
  String get manualMode => 'Manual Settings';

  @override
  String get manualModeDesc => 'Apply sleep mode only at set times';

  @override
  String get deviceOnlyMode => 'Device Only';

  @override
  String get deviceOnlyModeDesc => 'Use only smartwatch data';

  @override
  String get bedtime => 'Bedtime';

  @override
  String get waketime => 'Wake Time';

  @override
  String get clothingPresetDefault => 'Default (Gray)';

  @override
  String get clothingPresetPinkBlack => 'Pink/Black';

  @override
  String get clothingPresetWhiteNavy => 'White/Navy';

  @override
  String get clothingPresetMintCharcoal => 'Mint/Charcoal';

  @override
  String get clothingPresetLavenderPurple => 'Lavender/Purple';

  @override
  String get clothingPresetCoralGray => 'Coral/Gray';

  @override
  String get timezoneSettings => 'Timezone Settings';

  @override
  String get selectTimezone => 'Select Timezone';

  @override
  String get timezoneNotificationAdjustment =>
      'Notification times will be adjusted according to the selected timezone.';

  @override
  String timezoneSet(String timezone) {
    return 'Timezone has been set to $timezone.';
  }

  @override
  String get healthConnectUpdateRequired =>
      'Health Connect app update or data migration required.\nPlease check system settings and Play Store.';

  @override
  String get healthConnectNotInstalled =>
      'Health Connect app is not installed.\nPlease install it from Google Play and try again.';

  @override
  String get healthConnectInitializing => 'Initializing Health Connect...';

  @override
  String get healthConnectCheckingStatus => 'Checking Health Connect status...';

  @override
  String healthConnectInitFailed(Object error) {
    return 'Health Connect initialization failed: $error';
  }

  @override
  String healthConnectCheckFailed(Object error) {
    return 'Health Connect check failed: $error';
  }

  @override
  String healthConnectRequestFailed(Object error) {
    return 'Permission request failed: $error';
  }

  @override
  String get permissionDiagnosis => 'Permission Diagnosis';

  @override
  String get permissionDiagnosisResults => 'Permission Diagnosis Results';

  @override
  String get clearPermissionCache => 'Clear Permission Cache';

  @override
  String get permissionCacheCleared =>
      'Permission cache has been cleared. Please restart the app.';

  @override
  String get syncingHealthData => 'Synchronizing health data...';

  @override
  String get close => 'Close';

  @override
  String get waterIntakeManagement => 'Water Intake Management';

  @override
  String get supplementNotifications => 'Vitamin/Supplement Notifications';

  @override
  String get addSupplement => 'Add Supplement';

  @override
  String get supplementName => 'Supplement Name';

  @override
  String get supplementTime => 'Intake Time';

  @override
  String get waterReminder => 'Water Reminder';

  @override
  String get waterInterval => 'Reminder Interval (min)';

  @override
  String get waterStartTime => 'Start Time';

  @override
  String get noSupplementsRegistered =>
      'No supplements registered. Tap the + button to add.';

  @override
  String get maxSupplementsReached => 'You can register up to 3 supplements.';

  @override
  String dailyWaterGoal(int goal) {
    return '하루 목표: ${goal}ml';
  }

  @override
  String get editSupplement => 'Edit Supplement';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get supplementHintText => 'e.g. Vitamin C, Omega-3';

  @override
  String get recommendedWaterIntake => 'Recommended Water Intake';

  @override
  String get recommendedBasedOnProfile =>
      'Calculated based on your weight and activity level';

  @override
  String get yourDailyGoal => 'Your Daily Goal';

  @override
  String get canAdjustManually => 'You can adjust manually (1000~5000ml)';

  @override
  String get useRecommendedAmount => 'Use Recommended Amount';

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
}
