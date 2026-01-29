// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ビタバディ';

  @override
  String get homeGreetingMorning => 'おはようございます';

  @override
  String get homeGreetingAfternoon => 'こんにちは';

  @override
  String get homeGreetingEvening => 'こんばんは';

  @override
  String get homeSubtitle => '今日も健康的な一日を！';

  @override
  String get caloriesUnit => 'kcal';

  @override
  String get intakeLabel => '摂取';

  @override
  String get burnedLabel => '消費';

  @override
  String get remainingLabel => '残り';

  @override
  String get goalLabel => '目標';

  @override
  String get minutesUnit => '分';

  @override
  String get exerciseRecord => '運動記録';

  @override
  String get foodRecord => '食事記録';

  @override
  String get dailySummary => '今日のまとめ';

  @override
  String get wearableConnected => '接続済み';

  @override
  String get wearablePermissionRequired => '権限が必要';

  @override
  String get wearableNotConnected => '未接続';

  @override
  String get walkingActivity => 'ウォーキング';

  @override
  String get runningActivity => 'ランニング';

  @override
  String get cyclingActivity => 'サイクリング';

  @override
  String get swimmingActivity => '水泳';

  @override
  String get weightTrainingActivity => '筋力トレーニング';

  @override
  String get yogaActivity => 'ヨガ';

  @override
  String get dancingActivity => 'ダンス';

  @override
  String get hikingActivity => 'ハイキング';

  @override
  String get tennisActivity => 'テニス';

  @override
  String get basketballActivity => 'バスケットボール';

  @override
  String get soccerActivity => 'サッカー';

  @override
  String get aerobicsActivity => 'エアロビクス';

  @override
  String get badmintonActivity => 'バドミントン';

  @override
  String get baseballActivity => '野球';

  @override
  String get boxingActivity => 'ボクシング';

  @override
  String get golfActivity => 'ゴルフ';

  @override
  String get pilatesActivity => 'ピラティス';

  @override
  String get tableTennisActivity => '卓球';

  @override
  String get volleyballActivity => 'バレーボール';

  @override
  String get ellipticalActivity => 'エリプティカル';

  @override
  String get rowingActivity => 'ローイング';

  @override
  String get stairClimbingActivity => '階段昇降';

  @override
  String get otherActivity => 'その他';

  @override
  String get sourceManual => '手動入力';

  @override
  String get sourceHealthConnect => 'Health Connect';

  @override
  String get sourceHealthKit => 'HealthKit';

  @override
  String get workoutTypeLabel => '運動の種類';

  @override
  String get durationLabel => '運動時間（分）';

  @override
  String get intensityLabel => '強度';

  @override
  String get intensityLow => '低い';

  @override
  String get intensityMedium => '普通';

  @override
  String get intensityHigh => '高い';

  @override
  String get calcCaloriesLabel => '予想消費カロリー';

  @override
  String get calorieCalcError => 'カロリー計算エラー';

  @override
  String workoutSaved(Object type) {
    return '$typeが記録されました';
  }

  @override
  String saveError(Object error) {
    return '保存失敗: $error';
  }

  @override
  String get syncComplete => '同期完了';

  @override
  String get syncFailed => '同期失敗';

  @override
  String get noDataToSync => '同期するデータがありません';

  @override
  String get settingsTitle => '設定';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get languageTitle => '言語';

  @override
  String get calorieGoalSettings => '目標カロリー設定';

  @override
  String get sleepSettings => '睡眠設定';

  @override
  String get avatarClothingSettings => 'アバター服設定';

  @override
  String get profileEdit => 'プロフィール編集';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get healthDataPermission => 'ヘルスデータ権限';

  @override
  String get healthPermissionAlreadyGranted => 'ヘルスデータ権限はすでに許可されています';

  @override
  String get healthPermissionGranted => 'ヘルスデータ権限が許可されました';

  @override
  String get healthPermissionDenied => 'ヘルスデータ権限が拒否されました。設定で許可してください。';

  @override
  String get weight => '体重';

  @override
  String get height => '身長';

  @override
  String get age => '年齢';

  @override
  String get gender => '性別';

  @override
  String get male => '男性';

  @override
  String get female => '女性';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get autoRecord => '自動記録';

  @override
  String get manualRecord => '手動記録';

  @override
  String get caloriesBurned => '消費カロリー';

  @override
  String get workoutCount => '運動回数';

  @override
  String get steps => '歩数';

  @override
  String get syncing => '同期中...';

  @override
  String get syncHealthData => 'ヘルスデータ同期';

  @override
  String get noAutoRecords => '自動記録された運動がありません';

  @override
  String get noAutoRecordsSubtitle =>
      'ヘルスデータ同期ボタンを押して\nスマートフォンとウェアラブルの運動データを取得してください';

  @override
  String get noManualRecords => '手動記録された運動がありません';

  @override
  String get noManualRecordsSubtitle => '右下の+ボタンをタップして\n運動を直接記録してください';

  @override
  String get dataLoadFailed => 'データの読み込みに失敗しました';

  @override
  String get basicInfo => '基本';

  @override
  String get bodyInfo => '身体';

  @override
  String get personality => '性格';

  @override
  String get previous => '前へ';

  @override
  String get nameOptional => '名前 (任意)';

  @override
  String get activityLevel => '活動レベル';

  @override
  String get activitySedentary => 'ほぼ運動しない';

  @override
  String get activityLight => '軽い運動（週1〜3日）';

  @override
  String get activityModerate => '適度な運動（週3〜5日）';

  @override
  String get activityActive => '活発な運動（週6〜7日）';

  @override
  String get activityVeryActive => '非常に活発（1日2回など）';

  @override
  String get sedentary => 'ほとんど運動しない';

  @override
  String get lightExercise => '軽い運動（週1-3日）';

  @override
  String get moderateExercise => '普通の運動（週3-5日）';

  @override
  String get activeExercise => '積極的な運動（週6-7日）';

  @override
  String get veryActiveExercise => '非常に活発（1日2回以上）';

  @override
  String get saveChanges => '変更を保存';

  @override
  String get profileUpdated => 'プロフィールが更新されました';

  @override
  String get discardChanges => '変更を破棄';

  @override
  String get discardChangesMessage => '変更を保存せずに終了しますか？';

  @override
  String get continueEditing => '編集を続ける';

  @override
  String get exitWithoutSaving => '終了';

  @override
  String get complete => '完了';

  @override
  String get next => '次へ';

  @override
  String get foodInput => '食事入力';

  @override
  String get recent => '最近';

  @override
  String get favorites => 'お気に入り';

  @override
  String get search => '検索';

  @override
  String get customAdd => '直接追加';

  @override
  String get noRecentFoods => '最近食べた食事がありません';

  @override
  String get noFavoriteFoods => 'お気に入りの食事がありません';

  @override
  String get addFavoriteHint => '食事一覧で⭐を押して追加してください';

  @override
  String get noSearchResults => '検索結果がありません';

  @override
  String get searchFoodHint => '食事を検索...';

  @override
  String get foodName => '食事名';

  @override
  String get calories => 'カロリー';

  @override
  String get quantity => '数量';

  @override
  String get servingCalories => '1食あたりのカロリー';

  @override
  String get servingCount => '摂取回数';

  @override
  String get foodNameHint => '例：ハンバーガー';

  @override
  String get caloriesHint => '例：550';

  @override
  String get addIntake => '摂取追加';

  @override
  String get saveTemporary => '一時保存（後でカロリー入力）';

  @override
  String get invalidQuantity => '正しい数量を入力してください';

  @override
  String get foodAdded => '食事が追加されました';

  @override
  String get foodAddFailed => '食事の追加に失敗しました';

  @override
  String get favoriteAdded => 'お気に入りに追加されました';

  @override
  String get favoriteRemoved => 'お気に入りから削除されました';

  @override
  String get inputModeTotal => '全体';

  @override
  String get inputModeServing => '1食';

  @override
  String get inputMode100g => '100g';

  @override
  String get inputModeQuick => '高速';

  @override
  String get add => '追加';

  @override
  String get enterFoodNameAndCalories => '食事名とカロリーを入力してください';

  @override
  String get enterValidCalories => '正しいカロリーを入力してください';

  @override
  String get userFoodAddFailed => 'ユーザー食事の追加に失敗しました';

  @override
  String get enterFoodName => '食事名を入力してください';

  @override
  String get quickSaveSuccess => '一時保存されました（後でカロリー入力）';

  @override
  String get servingInfoHelp => '栄養成分表示の1食分情報をそのまま入力してください';

  @override
  String get servingUnit => '回';

  @override
  String get unitServings => '人分';

  @override
  String get unitCount => '個/人分';

  @override
  String get foodAddTitle => '食事追加';

  @override
  String foodAddConfirm(String foodName) {
    return '$foodNameを追加しますか？';
  }

  @override
  String get refreshTooltip => '更新';

  @override
  String get totalCalorieHelp => '総カロリーを直接入力してください';

  @override
  String get quickRecordHelp => '食事名のみ入力し、後でカロリーを追加できます';

  @override
  String get defaultLabel => 'デフォルト';

  @override
  String get weightRecord => '体重記録';

  @override
  String get weightLoadFailed => '体重記録の読み込みに失敗しました';

  @override
  String get enterWeight => '体重を入力してください';

  @override
  String get enterValidWeight => '正しい体重を入力してください (20-300kg)';

  @override
  String get weightRecorded => '体重が記録されました';

  @override
  String get weightRecordFailed => '体重の記録に失敗しました';

  @override
  String get weightRecordDeleted => '体重記録が削除されました';

  @override
  String get deleteFailed => '記録の削除に失敗しました';

  @override
  String get todaysWeight => '今日の体重';

  @override
  String get weightHint => '例：70.5';

  @override
  String get record => '記録';

  @override
  String get noteOptional => 'メモ（任意）';

  @override
  String get noteHint => '例：運動後';

  @override
  String get weightTrend => '体重推移';

  @override
  String get noWeightRecords => '体重記録がありません';

  @override
  String get deleteRecord => '記録削除';

  @override
  String get confirmDeleteWeight => 'この体重記録を削除しますか？';

  @override
  String get languageSettings => '言語設定';

  @override
  String get selectLanguage => '言語選択';

  @override
  String get getStarted => '始める';

  @override
  String get language => '言語';

  @override
  String get healthPermissionContent =>
      'ウェアラブルデバイスとのカロリー同期には、ヘルスデータへのアクセス権限が必要です。';

  @override
  String get healthPermissionAllowInfo => '許可した場合:';

  @override
  String get healthPermissionInfo1 => '• 歩数および消費カロリーの自動同期';

  @override
  String get healthPermissionInfo2 => '• 運動記録の自動インポート';

  @override
  String get healthPermissionInfo3 => '• より正確なカロリー管理';

  @override
  String get healthPermissionDenyInfo => '権限を拒否しても、アプリの基本機能は使用できます。';

  @override
  String get later => '後で';

  @override
  String get allowPermission => '許可';

  @override
  String get permissionSelect => '権限を選択';

  @override
  String get allowAndSync => '許可して同期';

  @override
  String get setupLater => '後で設定';

  @override
  String get history => '履歴';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get noRecords => 'まだ記録がありません。';

  @override
  String get pleaseSelectLanguage => '言語を選択してください';

  @override
  String get homeTitle => '治癒する VitaBuddy';

  @override
  String get mealRecord => '食事記録';

  @override
  String get viewRecords => '記録を見る';

  @override
  String get developerTest => '開発者テスト画面';

  @override
  String get mealGuidance => '食事ガイド';

  @override
  String get nextMeal => '次の食事';

  @override
  String get moreNeeded => '不足';

  @override
  String get reduce => '超過';

  @override
  String get until => 'まで';

  @override
  String get sleepMode => '睡眠モード';

  @override
  String get connected => '接続済み';

  @override
  String get disconnected => '未接続';

  @override
  String get notConnected => '未接続';

  @override
  String get justSynced => 'たった今同期';

  @override
  String get syncedJustNow => 'たった今同期';

  @override
  String syncedMinutesAgo(int minutes) {
    return '$minutes分前';
  }

  @override
  String syncedHoursAgo(int hours) {
    return '$hours時間前';
  }

  @override
  String get minutesAgo => '分前';

  @override
  String get hoursAgo => '時間前';

  @override
  String get minutesShort => '分';

  @override
  String get changeClothingColor => '服の色を変更';

  @override
  String get walking => 'ウォーキング';

  @override
  String get running => 'ランニング';

  @override
  String get cycling => 'サイクリング';

  @override
  String get swimming => '水泳';

  @override
  String get user => 'ユーザー';

  @override
  String homeGreetingFormat(String greeting, String user) {
    return '$greeting、$userさん！';
  }

  @override
  String get reduceIntake => '摂取量を減らす';

  @override
  String get profileSetup => 'プロフィール設定';

  @override
  String get stepBasicInfo => '基本情報';

  @override
  String get basicInfoDesc => '正確なカロリー計算のために基本情報を入力してください。';

  @override
  String get nameHint => '例: 山田太郎';

  @override
  String get yearsOld => '歳';

  @override
  String get ageUnit => '歳';

  @override
  String get stepMealPattern => '食事パターン';

  @override
  String get mealPatternSetup => '食事パターン設定';

  @override
  String get mealPatternDesc => '毎日の食事パターンを設定して、通知を受け取りましょう。';

  @override
  String get meals2 => '2食';

  @override
  String get meals3 => '3食 (推奨)';

  @override
  String get meals4 => '4食';

  @override
  String get meals4Plus => '4食+';

  @override
  String get mealTimeSettings => '食事時間設定';

  @override
  String get configuredMealTimes => '設定された食事時間';

  @override
  String get stepSomatotype => '体質選択';

  @override
  String get somatotypeSelection => '体質選択';

  @override
  String get somatotypeDesc => 'あなたの体質タイプを選択してください。代謝率の計算に反映されます。';

  @override
  String get dontKnow => 'よくわかりません';

  @override
  String get unsure => 'よくわかりません';

  @override
  String get stepBodyShape => '体型選択';

  @override
  String get bodyShapeSelection => '体型選択';

  @override
  String get bodyShapeDesc => 'どこに肉がつきやすいですか？アバターの表現に反映されます。';

  @override
  String get stepDetailInfo => '詳細情報';

  @override
  String get detailInfoDesc => '追加情報により、より正確なカロリー計算が可能になります。';

  @override
  String get muscleType => '筋肉量';

  @override
  String get muscleInfo => '筋肉量が多いほど基礎代謝量が高くなります。';

  @override
  String get stepPersonality => '簡単な性格診断';

  @override
  String get personalityDesc => '日常の活動量計算に反映されます (NEAT)。';

  @override
  String get questionExtraversion => '普段、活発で外交的ですか？';

  @override
  String get questionConscientiousness => '計画的で規則正しいですか？';

  @override
  String get questionNeuroticism => '座っている時によく動きますか？\n(貧乏ゆすりなど)';

  @override
  String get personalityInfo => '性格特性に応じて1日の推奨カロリーが調整されます。';

  @override
  String get no => 'いいえ';

  @override
  String get yes => 'はい';

  @override
  String get prev => '前へ';

  @override
  String get somatotypeEctomorph => '外胚葉型 (痩せ型)';

  @override
  String get somatotypeEctomorphDesc => '代謝が早く太りにくいですが、筋肉がつきにくいです。';

  @override
  String get somatotypeMesomorph => '中胚葉型 (筋肉質)';

  @override
  String get somatotypeMesomorphDesc => '筋肉がつきやすく、体重調整が比較的容易です。';

  @override
  String get somatotypeEndomorph => '内胚葉型 (ぽっちゃり型)';

  @override
  String get somatotypeEndomorphDesc => '脂肪がつきやすく、減量が難しい場合があります。';

  @override
  String get somatotypeMixed => '混合型';

  @override
  String get somatotypeMixedDesc => '複数の体質の特徴を持っています。';

  @override
  String get bodyShapeApple => '🍎 リンゴ型';

  @override
  String get bodyShapeAppleDesc => '主に上半身と腹部に脂肪がつきます。';

  @override
  String get bodyShapePear => '🍐 洋ナシ型';

  @override
  String get bodyShapePearDesc => '主に下半身（お尻、太もも）に脂肪がつきます。';

  @override
  String get bodyShapeHourglass => '⏳ 砂時計型';

  @override
  String get bodyShapeHourglassDesc => 'バストとお尻のバランスが良く、ウエストがくびれています。';

  @override
  String get bodyShapeRectangle => '📏 長方形型';

  @override
  String get bodyShapeRectangleDesc => '全体的に平坦で均整の取れた体型です。';

  @override
  String get bodyShapeInvertedTriangle => '🔺 逆三角形型';

  @override
  String get bodyShapeInvertedTriangleDesc => '肩幅が広く、お尻が狭い体型です。';

  @override
  String get muscleLow => '少ない';

  @override
  String get muscleMedium => '普通';

  @override
  String get muscleHigh => '多い';

  @override
  String get mealBreakfast => '朝食';

  @override
  String get mealLunch => '昼食';

  @override
  String get mealDinner => '夕食';

  @override
  String get mealSnackMorning => '午前の間食';

  @override
  String get mealSnackAfternoon => '午後の間食';

  @override
  String get mealSnackEvening => '夜の間食';

  @override
  String get mealSnack => '間食';

  @override
  String get guidanceNoPattern => '食事パターンを設定すると、より正確なアドバイスを受けられます！';

  @override
  String guidanceDailyGoal(int goal) {
    return '1日の目標: ${goal}kcal';
  }

  @override
  String guidanceOvereating(String meal, String time, int current) {
    return '⚠️ $meal($time)の前なのに既に${current}kcal摂取しています！食べ過ぎに注意してください。';
  }

  @override
  String guidanceFasting(String meal, String time) {
    return '💡 $meal($time)まで空腹を維持することをお勧めします。';
  }

  @override
  String get guidanceFinished => '✅ 今日の食事は終了しました！';

  @override
  String guidanceLow(int diff) {
    return '💡 1日の推奨量より${diff}kcal不足しています。間食を摂りましょう！';
  }

  @override
  String guidanceHigh(int diff) {
    return '⚠️ 1日の推奨量より${diff}kcal超過しています。';
  }

  @override
  String guidanceAdequate(String context) {
    return '✅ 素晴らしい！$context適量を摂取しました。';
  }

  @override
  String guidanceLowMid(String context, int recommended, int current) {
    return '⚠️ $context約${recommended}kcalの摂取が推奨されますが、現在は${current}kcalです。次の食事でもう少し食べましょう！';
  }

  @override
  String guidanceHighMid(String context, int recommended, int current) {
    return '⚠️ $context${recommended}kcalが推奨されますが、${current}kcal摂取しました。次の食事は控えめに！';
  }

  @override
  String get contextCurrent => '現在';

  @override
  String contextUntilMeal(String meal) {
    return '$mealまで';
  }

  @override
  String get healthPermissionWarning => 'ヘルスデータ権限が必要です';

  @override
  String syncSuccess(Object count) {
    return '✅ $count件の運動データを同期しました';
  }

  @override
  String syncError(Object error) {
    return '同期中にエラーが発生しました: $error';
  }

  @override
  String dataLoadError(Object error) {
    return 'データの読み込みに失敗しました: $error';
  }

  @override
  String get catTotal => 'すべて';

  @override
  String get catFruit => '果物';

  @override
  String get catStaple => '主食';

  @override
  String get catSoup => 'スープ';

  @override
  String get catMeat => '肉類';

  @override
  String get catFish => '魚介類';

  @override
  String get catSide => 'おかず';

  @override
  String get catVegetable => '野菜';

  @override
  String get catDairy => '乳製品';

  @override
  String get catBakery => 'ベーカリー';

  @override
  String get catSnack => 'スナック';

  @override
  String get catBeverage => '飲料';

  @override
  String get catEtc => 'その他';

  @override
  String get quickActionsTitle => '健康管理';

  @override
  String get todayHealthNote => '今日の健康ノート';

  @override
  String get bmiUnderweight => '低体重';

  @override
  String get bmiNormal => '正常';

  @override
  String get bmiOverweight => '過体重';

  @override
  String get bmiObese => '肥満';

  @override
  String get motivationOverLimit => '大丈夫、明日少し動けばいいよ。🌿';

  @override
  String get motivationNearLimit => '今日は一日よく頑張りました！☀️';

  @override
  String get motivationGood => 'あなたのペースで進んでいます。とても素晴らしい！👏';

  @override
  String get mealRecordButton => '食事記録';

  @override
  String get exerciseRecordButton => '運動記録';

  @override
  String get weightRecordButton => '体重記録';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get weightLabel => '体重';

  @override
  String get dailyGoalLabel => '1日の目標';

  @override
  String get currentLabel => '現在';

  @override
  String get todayLabel => '今日';

  @override
  String get totalLabel => '合計';

  @override
  String get netCaloriesLabel => '現在のカロリー';

  @override
  String get surplusLabel => '余剰';

  @override
  String get deficitLabel => '不足';

  @override
  String get allow => '許可';

  @override
  String get deny => '拒否';

  @override
  String get healthPlatformName => 'ヘルス';

  @override
  String get exercise => '運動';

  @override
  String get kcalUnit => 'kcal';

  @override
  String get kgUnit => 'kg';

  @override
  String get kmUnit => 'km';

  @override
  String intakeTooltip(int current) {
    return '摂取: $current kcal';
  }

  @override
  String exerciseBurnTooltip(int burned) {
    return '運動: -$burned kcal';
  }

  @override
  String tdeeBurnTooltip(int tdee) {
    return 'TDEE: -$tdee kcal';
  }

  @override
  String totalBurnTooltip(int total) {
    return '消費合計: -$total kcal';
  }

  @override
  String get currentCaloriesTooltip => '現在のカロリー';

  @override
  String remainingTooltip(int remaining) {
    return '残り: $remaining kcal';
  }

  @override
  String get current => '現在';

  @override
  String get normal => '普通';

  @override
  String get total => '合計';

  @override
  String get today => '今日';

  @override
  String get deficit => '不足';

  @override
  String get calorieGoalSettingsTitle => '目標カロリー設定';

  @override
  String get selectGoalMode => '目標モード選択';

  @override
  String get dailyCalorieGoal => '1日の目標カロリー';

  @override
  String get minBmr => '最小(BMR)';

  @override
  String get maintainTdee => '維持(TDEE)';

  @override
  String get max => '最大';

  @override
  String get bmrLabel => '私の基礎代謝量 (BMR)';

  @override
  String get tdeeLabel => '私の総エネルギー消費量 (TDEE)';

  @override
  String get bmrWarning =>
      '💡 基礎代謝量(BMR)以下を摂取すると健康に害を及ぼす可能性があるため、最低目標として設定されます。';

  @override
  String get lossMode => '減量';

  @override
  String get maintainMode => '維持';

  @override
  String get bulkMode => '増量';

  @override
  String get weightMaintain => '現在の体重維持';

  @override
  String weightLossPrediction(String weight) {
    return '週に約${weight}kgの減量予想';
  }

  @override
  String weightGainPrediction(String weight) {
    return '週に約${weight}kgの増量予想';
  }

  @override
  String get maintainDesc => '健康的なバランスを維持していますね！';

  @override
  String get lossDesc => '継続が最も重要です。ファイティング！';

  @override
  String get bulkDesc => '筋肉量増加のためにも運動を並行してください！';

  @override
  String get saveGoal => '保存する';

  @override
  String get goalSaved => '目標が保存されました。';

  @override
  String get mealLunchPreset => '昼食';

  @override
  String get mealDinnerPreset => '夕食';

  @override
  String get mealBreakfastPreset => '朝食';

  @override
  String get mealSnackMorningPreset => '午前の間食';

  @override
  String get mealSnackAfternoonPreset => '午後の間食';

  @override
  String get appTitleMain => '治癒する VitaBuddy';

  @override
  String get clothingSettingsTitle => '服の色を変更';

  @override
  String get preview => 'プレビュー';

  @override
  String get colorThemeSelection => 'カラーテーマ選択';

  @override
  String get apply => '適用';

  @override
  String get clothingColorChanged => '服の色が変更されました';

  @override
  String get discardChangesConfirm => '変更を破棄して終了しますか？';

  @override
  String get stay => '留まる';

  @override
  String get exit => '終了';

  @override
  String get loadFoodsFailed => '食事データの読み込みに失敗しました';

  @override
  String get amount => '量';

  @override
  String get servings => '人分';

  @override
  String consumedOn(String date) {
    return '摂取日: $date';
  }

  @override
  String get unknown => '不明';

  @override
  String get addFood => '食事追加';

  @override
  String get quantityHint => '数量';

  @override
  String get servingsHint => '人分';

  @override
  String recentEaten(Object date) {
    return '最近食べた: $date';
  }

  @override
  String get addFoodButton => '追加';

  @override
  String get mealsTab => '食事';

  @override
  String get exercisesTab => '運動';

  @override
  String get summaryTab => '要約';

  @override
  String get noMealRecords => '記録された食事がありません。';

  @override
  String get noExerciseRecords => '記録された運動がありません。';

  @override
  String get unknownFood => '不明な食事';

  @override
  String get totalIntakeCalories => '総摂取カロリー';

  @override
  String get totalBurnedCalories => '総消費カロリー';

  @override
  String get recordedWeight => '記録された体重';

  @override
  String get noRecord => '記録なし';

  @override
  String get netCalorieChange => '純粋カロリー変動';

  @override
  String get mealPatternTitle => '毎日の食事パターンを教えてください';

  @override
  String get mealPatternSubtitle => 'パーソナライズされた通知のために食事時間を設定してください';

  @override
  String get meals2Preset => '2食';

  @override
  String get meals3Preset => '3食 (推奨)';

  @override
  String get meals4Preset => '4食+';

  @override
  String get customPreset => 'カスタム';

  @override
  String get mealTimes => '食事時間';

  @override
  String get addMeal => '食事追加';

  @override
  String get mealNameHint => '食事名';

  @override
  String get snackNotifications => '🍎 間食通知';

  @override
  String get snackNotificationsDesc => '午前/午後の間食時間通知を受け取ることができます';

  @override
  String get lunch => '昼食';

  @override
  String get dinner => '夕食';

  @override
  String get breakfast => '朝食';

  @override
  String get morningSnack => '午前の間食';

  @override
  String mealNumber(Object number) {
    return '食事 $number';
  }

  @override
  String get energyAlertSensitivity => '⚡ エネルギー警告感度';

  @override
  String get mealNotifications => '📱 食事通知';

  @override
  String get exerciseNotifications => '🏃 運動通知';

  @override
  String get weightMeasurementNotifications => '⚖️ 体重測定通知';

  @override
  String get breakfastMeal => '朝食';

  @override
  String get lunchMeal => '昼食';

  @override
  String get dinnerMeal => '夕食';

  @override
  String get afternoonSnack => '午後の間食';

  @override
  String get weightMeasurement => '体重測定';

  @override
  String get exerciseTime => '運動時間';

  @override
  String get selectDays => '曜日を選択:';

  @override
  String get monday => '月';

  @override
  String get tuesday => '火';

  @override
  String get wednesday => '水';

  @override
  String get thursday => '木';

  @override
  String get friday => '金';

  @override
  String get saturday => '土';

  @override
  String get sunday => '日';

  @override
  String get energyDeficitAlertFrequency => 'エネルギー不足警告頻度';

  @override
  String get adjustAlertFrequencyDesc => '設定に応じて通知をより頻繁に受け取ったり減らしたりすることができます。';

  @override
  String get insensitive => '鈍感';

  @override
  String get sensitive => '敏感';

  @override
  String get minimizeNotifications => '通知最小化';

  @override
  String get defaultSettings => 'デフォルト設定';

  @override
  String get frequentNotifications => '頻繁な通知';

  @override
  String get notificationPermissionGranted => '通知権限が許可されました';

  @override
  String get notificationPermissionRequired => '通知権限が必要です';

  @override
  String get enablePermissionForHealthAlerts => '重要な健康通知を受け取るために権限を有効にしてください。';

  @override
  String get settings => '設定';

  @override
  String get currentCaloriesLabel => '(現在のカロリー)';

  @override
  String get notificationBreakfastTitle => 'おはようございます！ ☀️';

  @override
  String get notificationBreakfastBody => '栄養たっぷりの朝食で、活気ある一日を始めましょう！';

  @override
  String get notificationLunchTitle => '昼食の時間です！ 🍱';

  @override
  String get notificationLunchBody => 'バランスの取れた昼食で、午後の活力を補給しましょう！';

  @override
  String get notificationDinnerTitle => '夕食の時間です！ 🌙';

  @override
  String get notificationDinnerBody => '健康的な夕食で、一日を締めくくりましょう！';

  @override
  String get notificationBrunchTitle => 'ブランチの時間です！ 🥞';

  @override
  String get notificationBrunchBody => '美味しいブランチをお楽しみください！';

  @override
  String notificationCustomMealTitle(Object mealName) {
    return '$mealNameの時間です！ 🍽️';
  }

  @override
  String get notificationCustomMealBody => '美味しく健康的な食事を楽しんでください！';

  @override
  String get notificationMorningSnackTitle => '朝のおやつの時間です！ 🍎';

  @override
  String get notificationAfternoonSnackTitle => '午後のおやつの時間です！ 🥨';

  @override
  String get notificationSnackBody => '健康的なおやつでエネルギーを補給しましょう！';

  @override
  String get notificationWaterTitle => '水分補給の時間です！ 💧';

  @override
  String get notificationWaterBody => '健康のため、水を一杯いかがですか？';

  @override
  String get notificationCalorieOverTitle => 'カロリー目標超過 ⚠️';

  @override
  String notificationCalorieOverBody(Object overAmount) {
    return '今日は${overAmount}kcal超過しました。健康的な食生活を維持しましょう！';
  }

  @override
  String get notificationLateNightTitle => '今お召し上がりですか？ 🌙';

  @override
  String get notificationLateNightBody => '夜遅い食事は睡眠と消化に良くありません。軽いものでいかがですか？';

  @override
  String get notificationGoalAchievedTitle => 'おめでとうございます！ 🎉';

  @override
  String get notificationGoalAchievedBody => '今日のカロリー目標を達成しました！';

  @override
  String get notificationMotivationTitle => 'VitaBuddyからの応援 💝';

  @override
  String get notificationMotivationMessage1 => '健康的な一日を過ごしていますか？ 💪';

  @override
  String get notificationMotivationMessage2 => '水を一杯いかがですか？ 🥤';

  @override
  String get notificationMotivationMessage3 => '軽いストレッチで爽快感を味わってみてください！ 🤸‍♀️';

  @override
  String get notificationMotivationMessage4 => '今日も健康管理ファイティング！ 🌟';

  @override
  String get notificationMotivationMessage5 => 'バランスの取れた食事が健康の始まりです！ 🥗';

  @override
  String get notificationExerciseTitle => '運動の時間です！ 🏃';

  @override
  String get notificationExerciseBody => '今日のカロリーを燃焼してみませんか？';

  @override
  String get notificationWeightTitle => '体重測定の時間です！ ⚖️';

  @override
  String get notificationWeightBody => '今日の体重を記録して、健康目標を確認しましょう。';

  @override
  String notificationSupplementTitle(Object supplementName) {
    return '$supplementName摂取の時間です！ 💊';
  }

  @override
  String get notificationSupplementBody => '健康管理を忘れずに。継続が大切です！';

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
  String get avatarLoadFailed => 'アバタロード失敗';

  @override
  String get avatarBuildFailed => 'アバタビルド失敗';

  @override
  String get sleepSettingsTitle => '睡眠設定';

  @override
  String get sleepSettingsSaved => '睡眠設定が保存されました。';

  @override
  String get sleepModeSection => '睡眠モード';

  @override
  String get sleepTimeSettings => '睡眠時間設定';

  @override
  String get saveSettings => '保存する';

  @override
  String get hybridMode => 'ハイブリッド (推奨)';

  @override
  String get hybridModeDesc => 'スマートウォッチデータを優先、ない場合は手動時間を使用';

  @override
  String get manualMode => '手動設定';

  @override
  String get manualModeDesc => '設定された時間のみ睡眠モード適用';

  @override
  String get deviceOnlyMode => 'デバイス専用';

  @override
  String get deviceOnlyModeDesc => 'スマートウォッチデータのみ使用';

  @override
  String get bedtime => '就寝時間';

  @override
  String get waketime => '起床時間';

  @override
  String get clothingPresetDefault => 'デフォルト (グレー)';

  @override
  String get clothingPresetPinkBlack => 'ピンク/ブラック';

  @override
  String get clothingPresetWhiteNavy => '白/ネイビー';

  @override
  String get clothingPresetMintCharcoal => 'ミント/チャコール';

  @override
  String get clothingPresetLavenderPurple => 'ラベンダー/パープル';

  @override
  String get clothingPresetCoralGray => 'コーラル/グレー';

  @override
  String get timezoneSettings => 'タイムゾーン設定';

  @override
  String get selectTimezone => 'タイムゾーンを選択';

  @override
  String get timezoneNotificationAdjustment => '通知時間は選択したタイムゾーンに応じて調整されます。';

  @override
  String timezoneSet(String timezone) {
    return 'タイムゾーンが$timezoneに設定されました。';
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
  String get permissionDiagnosis => '権限診断';

  @override
  String get permissionDiagnosisResults => '権限診断結果';

  @override
  String get clearPermissionCache => '権限キャッシュをクリア';

  @override
  String get permissionCacheCleared => '権限キャッシュがクリアされました。アプリを再起動してください。';

  @override
  String get syncingHealthData => 'ヘルスデータを同期中...';

  @override
  String get close => '閉じる';

  @override
  String get waterIntakeManagement => '水分摂取管理';

  @override
  String get supplementNotifications => 'ビタミン/サプリメント通知';

  @override
  String get addSupplement => 'サプリメント追加';

  @override
  String get supplementName => 'サプリメント名';

  @override
  String get supplementTime => '摂取時間';

  @override
  String get waterReminder => '水分補給アラーム';

  @override
  String get waterInterval => '通知間隔 (分)';

  @override
  String get waterStartTime => '開始時間';

  @override
  String get noSupplementsRegistered => '登録されたサプリメントがありません。+ボタンをタップして追加してください。';

  @override
  String get maxSupplementsReached => 'サプリメントは最大3個まで登録できます。';

  @override
  String dailyWaterGoal(int goal) {
    return '하루 목표: ${goal}ml';
  }

  @override
  String get editSupplement => 'サプリメント編集';

  @override
  String get dailyGoal => '1日の目標';

  @override
  String get supplementHintText => '例：ビタミンC、オメガ3など';

  @override
  String get recommendedWaterIntake => '推奨水分摂取量';

  @override
  String get recommendedBasedOnProfile => '体重と活動量に基づいて計算された推奨量です';

  @override
  String get yourDailyGoal => '1日の目標';

  @override
  String get canAdjustManually => '手動で調整できます（1000〜5000ml）';

  @override
  String get useRecommendedAmount => '推奨量を適用';

  @override
  String get barcodeScan => 'バーコードスキャン';

  @override
  String get cameraPermissionRequired => 'カメラ権限が必要です。設定で権限を許可してください。';

  @override
  String get cameraInitializing => 'カメラを初期化中...';

  @override
  String cameraInitFailed(String error) {
    return 'カメラの初期化に失敗しました: $error';
  }

  @override
  String get barcodeDetected => 'バーコードを検知しました！';

  @override
  String get pointCameraAtBarcode => 'バーコードにカメラを向けてください\n（どのバーコードでも認識されます）';

  @override
  String get barcodeVerified => 'バーコードが検証されました！';

  @override
  String get invalidBarcode => '無効なバーコード';

  @override
  String get type => 'タイプ';

  @override
  String get confidence => '信頼度';

  @override
  String get scanCount => 'スキャン回数';

  @override
  String get accept => '使用';

  @override
  String get rescan => '再スキャン';

  @override
  String get supportedFormats => 'サポートされている形式: QRコード、バーコード（EAN-13、UPC-Aなど）';

  @override
  String get localSearch => 'ローカル検索';

  @override
  String get onlineSearch => 'インターネット検索';

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
  String get searchOnlineHint => 'インターネットで食材を検索...';

  @override
  String get search100gHint => '100g당 입력은 검색 탭을 이용해주세요.';

  @override
  String get quantityLabel => '数量:';

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
  String get noCameraAvailable => '利用可能なカメラがありません。';

  @override
  String get cameraReady => 'カメラ準備完了...';

  @override
  String get requestPermission => '権限をリクエスト';

  @override
  String get openSettings => '設定を開く';

  @override
  String get flashToggle => 'フラッシュ切り替え';

  @override
  String get confidenceLabel => '信頼度';

  @override
  String get scanCountLabel => 'スキャン回数';

  @override
  String get checkingCameraPermission => 'カメラ権限を確認中...';

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
  String get brandLabel => 'ブランド';

  @override
  String apiResultsFound(int count) {
    return '合計$count件の結果が見つかりました。';
  }

  @override
  String foodNotFoundInDatabase(String apiName) {
    return '$apiNameデータベースでこの食品が見つかりませんでした。';
  }

  @override
  String apiKeyRequired(String apiName) {
    return 'より正確な検索のために設定で${apiName}APIキーを入力してください。';
  }

  @override
  String apiSearchError(String apiName) {
    return '$apiNameの検索中にエラーが発生しました。';
  }

  @override
  String get noDataStatus => 'データなし';

  @override
  String get dataNotFoundTitle => 'データにない';

  @override
  String get settingsRequired => '設定が必要';

  @override
  String get errorStatus => 'エラー';
}
