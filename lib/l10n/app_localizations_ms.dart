// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'VitaBuddy';

  @override
  String get homeGreetingMorning => 'Selamat pagi';

  @override
  String get homeGreetingAfternoon => 'Selamat tengah hari';

  @override
  String get homeGreetingEvening => 'Selamat malam';

  @override
  String get homeSubtitle => 'Semoga hari anda sihat!';

  @override
  String get caloriesUnit => 'kkal';

  @override
  String get intakeLabel => 'Pengambilan';

  @override
  String get burnedLabel => 'Terbakar';

  @override
  String get remainingLabel => 'Baki';

  @override
  String get goalLabel => 'Sasaran';

  @override
  String get minutesUnit => 'min';

  @override
  String get exerciseRecord => 'Rekod Senaman';

  @override
  String get foodRecord => 'Rekod Makanan';

  @override
  String get dailySummary => 'Ringkasan Harian';

  @override
  String get wearableConnected => 'Disambungkan';

  @override
  String get wearablePermissionRequired => 'Kebenaran Diperlukan';

  @override
  String get wearableNotConnected => 'Tidak disambungkan';

  @override
  String get walkingActivity => 'Berjalan';

  @override
  String get runningActivity => 'Berlari';

  @override
  String get cyclingActivity => 'Berbasikal';

  @override
  String get swimmingActivity => 'Berenang';

  @override
  String get weightTrainingActivity => 'Latihan Berat';

  @override
  String get yogaActivity => 'Yoga';

  @override
  String get dancingActivity => 'Menari';

  @override
  String get hikingActivity => 'Mendaki';

  @override
  String get tennisActivity => 'Tenis';

  @override
  String get basketballActivity => 'Bola Keranjang';

  @override
  String get soccerActivity => 'Bola Sepak';

  @override
  String get aerobicsActivity => 'Aerobic';

  @override
  String get badmintonActivity => 'Badminton';

  @override
  String get baseballActivity => 'Baseball';

  @override
  String get boxingActivity => 'Boks';

  @override
  String get golfActivity => 'Golf';

  @override
  String get pilatesActivity => 'Pilates';

  @override
  String get tableTennisActivity => 'Ping Pong';

  @override
  String get volleyballActivity => 'Bola Tampar';

  @override
  String get ellipticalActivity => 'Elliptical';

  @override
  String get rowingActivity => 'Mendayung';

  @override
  String get stairClimbingActivity => 'Naik Tangga';

  @override
  String get otherActivity => 'Lain-lain';

  @override
  String get sourceManual => 'Manual';

  @override
  String get sourceHealthConnect => 'Health Connect';

  @override
  String get sourceHealthKit => 'HealthKit';

  @override
  String get workoutTypeLabel => 'Jenis Senaman';

  @override
  String get durationLabel => 'Tempoh (minit)';

  @override
  String get intensityLabel => 'Intensiti';

  @override
  String get intensityLow => 'Rendah';

  @override
  String get intensityMedium => 'Sederhana';

  @override
  String get intensityHigh => 'Tinggi';

  @override
  String get calcCaloriesLabel => 'Anggaran Kalori';

  @override
  String get calorieCalcError => 'Ralat pengiraan kalori';

  @override
  String workoutSaved(Object type) {
    return '$type direkodkan';
  }

  @override
  String saveError(Object error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String get syncComplete => 'Penyegerakan selesai';

  @override
  String get syncFailed => 'Penyegerakan gagal';

  @override
  String get noDataToSync => 'Tiada data untuk disegerakkan';

  @override
  String get settingsTitle => 'Tetapan';

  @override
  String get profileTitle => 'Profil';

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get calorieGoalSettings => 'Tetapan Sasaran Kalori';

  @override
  String get sleepSettings => 'Tetapan Tidur';

  @override
  String get avatarClothingSettings => 'Tetapan Pakaian Avatar';

  @override
  String get profileEdit => 'Edit Profil';

  @override
  String get notificationSettings => 'Tetapan Pemberitahuan';

  @override
  String get healthDataPermission => 'Kebenaran Data Kesihatan';

  @override
  String get healthPermissionAlreadyGranted =>
      'Kebenaran data kesihatan telah diberikan';

  @override
  String get healthPermissionGranted => 'Kebenaran data kesihatan diberikan';

  @override
  String get healthPermissionDenied =>
      'Kebenaran data kesihatan ditolak. Sila dayakan dalam tetapan.';

  @override
  String get weight => 'Berat';

  @override
  String get height => 'Tinggi';

  @override
  String get age => 'Umur';

  @override
  String get gender => 'Jantina';

  @override
  String get male => 'Lelaki';

  @override
  String get female => 'Perempuan';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Sahkan';

  @override
  String get delete => 'Padam';

  @override
  String get edit => 'Edit';

  @override
  String get autoRecord => 'Rekod Automatik';

  @override
  String get manualRecord => 'Rekod Manual';

  @override
  String get caloriesBurned => 'Kalori Terbakar';

  @override
  String get workoutCount => 'Bilangan Senaman';

  @override
  String get steps => 'Langkah';

  @override
  String get syncing => 'Menyegerakkan...';

  @override
  String get syncHealthData => 'Segerakkan Data Kesihatan';

  @override
  String get noAutoRecords => 'Tiada senaman yang direkod secara automatik';

  @override
  String get noAutoRecordsSubtitle =>
      'Tekan butang Segerakkan Data Kesihatan untuk\nmengimport data senaman dari telefon dan wearable anda';

  @override
  String get noManualRecords => 'Tiada senaman yang direkod secara manual';

  @override
  String get noManualRecordsSubtitle =>
      'Ketik butang + di bahagian kanan bawah\nuntuk merekod senaman anda secara manual';

  @override
  String get dataLoadFailed => 'Gagal memuatkan data';

  @override
  String get basicInfo => 'Asas';

  @override
  String get bodyInfo => 'Badan';

  @override
  String get personality => 'Personaliti';

  @override
  String get previous => 'Sebelumnya';

  @override
  String get nameOptional => 'Nama (Pilihan)';

  @override
  String get activityLevel => 'Tahap Aktiviti';

  @override
  String get activitySedentary => 'Tidak aktif';

  @override
  String get activityLight => 'Senaman ringan (1-3 hari/minggu)';

  @override
  String get activityModerate => 'Senaman sederhana (3-5 hari/minggu)';

  @override
  String get activityActive => 'Senaman aktif (6-7 hari/minggu)';

  @override
  String get activityVeryActive => 'Sangat aktif (2x sehari)';

  @override
  String get sedentary => 'Hampir tidak bersenam';

  @override
  String get lightExercise => 'Senaman ringan (1-3 hari/minggu)';

  @override
  String get moderateExercise => 'Senaman sederhana (3-5 hari/minggu)';

  @override
  String get activeExercise => 'Senaman aktif (6-7 hari/minggu)';

  @override
  String get veryActiveExercise => 'Sangat aktif (dua kali sehari)';

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String get profileUpdated => 'Profil dikemas kini';

  @override
  String get discardChanges => 'Batalkan Perubahan';

  @override
  String get discardChangesMessage => 'Keluar tanpa menyimpan perubahan?';

  @override
  String get continueEditing => 'Teruskan Mengedit';

  @override
  String get exitWithoutSaving => 'Keluar';

  @override
  String get complete => 'Selesai';

  @override
  String get next => 'Seterusnya';

  @override
  String get foodInput => 'Input Makanan';

  @override
  String get recent => 'Terbaru';

  @override
  String get favorites => 'Kegemaran';

  @override
  String get search => 'Cari';

  @override
  String get customAdd => 'Tambah Tersuai';

  @override
  String get noRecentFoods => 'Tiada makanan terbaru';

  @override
  String get noFavoriteFoods => 'Tiada makanan kegemaran';

  @override
  String get addFavoriteHint =>
      'Ketik ⭐ pada senarai makanan untuk menambah kegemaran';

  @override
  String get noSearchResults => 'Tiada hasil carian';

  @override
  String get searchFoodHint => 'Cari makanan...';

  @override
  String get foodName => 'Nama Makanan';

  @override
  String get calories => 'Kalori';

  @override
  String get quantity => 'Kuantiti';

  @override
  String get servingCalories => 'Kalori setiap Hidangan';

  @override
  String get servingCount => 'Bilangan Hidangan';

  @override
  String get foodNameHint => 'contoh: Hamburger';

  @override
  String get caloriesHint => 'contoh: 550';

  @override
  String get addIntake => 'Tambah Pengambilan';

  @override
  String get saveTemporary => 'Simpan Cepat (Tambah kalori kemudian)';

  @override
  String get invalidQuantity => 'Sila masukkan kuantiti yang sah';

  @override
  String get foodAdded => 'Makanan ditambah';

  @override
  String get foodAddFailed => 'Gagal menambah makanan';

  @override
  String get favoriteAdded => 'Ditambah ke kegemaran';

  @override
  String get favoriteRemoved => 'Dibuang dari kegemaran';

  @override
  String get inputModeTotal => 'Jumlah';

  @override
  String get inputModeServing => 'Hidangan';

  @override
  String get inputMode100g => '100g';

  @override
  String get inputModeQuick => 'Cepat';

  @override
  String get add => 'Tambah';

  @override
  String get enterFoodNameAndCalories =>
      'Sila masukkan nama makanan dan kalori';

  @override
  String get enterValidCalories => 'Sila masukkan kalori yang sah';

  @override
  String get userFoodAddFailed => 'Gagal menambah makanan pengguna';

  @override
  String get enterFoodName => 'Sila masukkan nama makanan';

  @override
  String get quickSaveSuccess => 'Disimpan sementara (Tambah kalori kemudian)';

  @override
  String get servingInfoHelp => 'Masukkan info hidangan dari label nutrisi';

  @override
  String get servingUnit => 'kali';

  @override
  String get unitServings => 'hidangan';

  @override
  String get unitCount => 'buah/hidangan';

  @override
  String get foodAddTitle => 'Tambah Makanan';

  @override
  String foodAddConfirm(String foodName) {
    return 'Tambah $foodName?';
  }

  @override
  String get refreshTooltip => 'Segarkan';

  @override
  String get totalCalorieHelp => 'Masukkan jumlah kalori secara langsung';

  @override
  String get quickRecordHelp =>
      'Masukkan nama sahaja dan tambah kalori kemudian';

  @override
  String get defaultLabel => 'Lalai';

  @override
  String get weightRecord => 'Rekod Berat Badan';

  @override
  String get weightLoadFailed => 'Gagal memuatkan rekod berat badan';

  @override
  String get enterWeight => 'Sila masukkan berat badan';

  @override
  String get enterValidWeight =>
      'Sila masukkan berat badan yang sah (20-300kg)';

  @override
  String get weightRecorded => 'Berat badan direkodkan';

  @override
  String get weightRecordFailed => 'Gagal merekod berat badan';

  @override
  String get weightRecordDeleted => 'Rekod berat badan dipadam';

  @override
  String get deleteFailed => 'Gagal memadam rekod';

  @override
  String get todaysWeight => 'Berat Hari Ini';

  @override
  String get weightHint => 'contoh: 70.5';

  @override
  String get record => 'Rekod';

  @override
  String get noteOptional => 'Nota (Pilihan)';

  @override
  String get noteHint => 'contoh: Selepas senaman';

  @override
  String get weightTrend => 'Trend Berat Badan';

  @override
  String get noWeightRecords => 'Tiada rekod berat badan';

  @override
  String get deleteRecord => 'Padam Rekod';

  @override
  String get confirmDeleteWeight => 'Padam rekod berat badan ini?';

  @override
  String get languageSettings => 'Tetapan Bahasa';

  @override
  String get selectLanguage => 'Pilih Bahasa';

  @override
  String get getStarted => 'Mula';

  @override
  String get language => 'Bahasa';

  @override
  String get healthPermissionContent =>
      'Aplikasi memerlukan akses data kesihatan untuk menyegerakkan kalori dengan peranti boleh pakai.';

  @override
  String get healthPermissionAllowInfo => 'Jika dibenarkan:';

  @override
  String get healthPermissionInfo1 =>
      '• Segerakkan langkah dan pembakaran kalori secara automatik';

  @override
  String get healthPermissionInfo2 => '• Import rekod senaman secara automatik';

  @override
  String get healthPermissionInfo3 => '• Pengurusan kalori yang lebih tepat';

  @override
  String get healthPermissionDenyInfo =>
      'Anda masih boleh menggunakan ciri asas aplikasi walaupun kebenaran ditolak.';

  @override
  String get later => 'Nanti';

  @override
  String get allowPermission => 'Benarkan';

  @override
  String get permissionSelect => 'Pilih Kebenaran';

  @override
  String get allowAndSync => 'Benarkan dan Segerakkan';

  @override
  String get setupLater => 'Tetapkan Kemudian';

  @override
  String get history => 'Sejarah';

  @override
  String get errorOccurred => 'Ralat Berlaku';

  @override
  String get noRecords => 'Tiada rekod lagi.';

  @override
  String get pleaseSelectLanguage => 'Sila pilih bahasa';

  @override
  String get homeTitle => 'Chiyuhada VitaBuddy';

  @override
  String get mealRecord => 'Rekod Makanan';

  @override
  String get viewRecords => 'Lihat Rekod';

  @override
  String get developerTest => 'Skrin Ujian Pembangun';

  @override
  String get mealGuidance => 'Panduan Makanan';

  @override
  String get nextMeal => 'Makanan Seterusnya';

  @override
  String get moreNeeded => 'diperlukan lagi';

  @override
  String get reduce => 'kurangkan';

  @override
  String get until => 'sehingga';

  @override
  String get sleepMode => 'Mod Tidur';

  @override
  String get connected => 'Disambungkan';

  @override
  String get disconnected => 'Terputus';

  @override
  String get notConnected => 'Tidak disambungkan';

  @override
  String get justSynced => 'Baru disegerakkan';

  @override
  String get syncedJustNow => 'Baru disegerakkan';

  @override
  String syncedMinutesAgo(int minutes) {
    return '$minutes min lalu';
  }

  @override
  String syncedHoursAgo(int hours) {
    return '$hours jam lalu';
  }

  @override
  String get minutesAgo => 'min lalu';

  @override
  String get hoursAgo => 'jam lalu';

  @override
  String get minutesShort => 'min';

  @override
  String get changeClothingColor => 'Tukar warna pakaian';

  @override
  String get walking => 'Berjalan';

  @override
  String get running => 'Berlari';

  @override
  String get cycling => 'Berbasikal';

  @override
  String get swimming => 'Berenang';

  @override
  String get user => 'Pengguna';

  @override
  String homeGreetingFormat(String greeting, String user) {
    return '$greeting, $user!';
  }

  @override
  String get reduceIntake => 'Kurangkan pengambilan';

  @override
  String get profileSetup => 'Tetapan Profil';

  @override
  String get stepBasicInfo => 'Maklumat Asas';

  @override
  String get basicInfoDesc =>
      'Sila masukkan maklumat asas untuk pengiraan kalori yang tepat.';

  @override
  String get nameHint => 'Contoh: Ali';

  @override
  String get yearsOld => 'tahun';

  @override
  String get ageUnit => 'tahun';

  @override
  String get stepMealPattern => 'Corak Makanan';

  @override
  String get mealPatternSetup => 'Tetapan Corak Makanan';

  @override
  String get mealPatternDesc =>
      'Tetapkan corak makanan harian anda untuk mendapatkan pemberitahuan peribadi.';

  @override
  String get meals2 => '2 Makanan';

  @override
  String get meals3 => '3 Makanan (Disyorkan)';

  @override
  String get meals4 => '4 Makanan';

  @override
  String get meals4Plus => '4 Makan+';

  @override
  String get mealTimeSettings => 'Tetapan Waktu Makan';

  @override
  String get configuredMealTimes => 'Waktu Makan Ditetapkan';

  @override
  String get stepSomatotype => 'Jenis Badan';

  @override
  String get somatotypeSelection => 'Pemilihan Jenis Badan';

  @override
  String get somatotypeDesc =>
      'Pilih jenis badan anda. Ia mempengaruhi pengiraan kadar metabolisme.';

  @override
  String get dontKnow => 'Saya tidak tahu';

  @override
  String get unsure => 'Tidak pasti';

  @override
  String get stepBodyShape => 'Bentuk Badan';

  @override
  String get bodyShapeSelection => 'Pemilihan Bentuk Badan';

  @override
  String get bodyShapeDesc =>
      'Di mana berat badan anda bertambah? Mempengaruhi penampilan avatar.';

  @override
  String get stepDetailInfo => 'Maklumat Lanjut';

  @override
  String get detailInfoDesc =>
      'Maklumat tambahan membolehkan pengiraan yang lebih tepat.';

  @override
  String get muscleType => 'Jisim Otot';

  @override
  String get muscleInfo => 'Jisim otot yang lebih tinggi meningkatkan BMR.';

  @override
  String get stepPersonality => 'Ujian Personaliti';

  @override
  String get personalityDesc =>
      'Mempengaruhi pengiraan aktiviti harian (NEAT).';

  @override
  String get questionExtraversion => 'Adakah anda bertenaga dan ekstrovert?';

  @override
  String get questionConscientiousness =>
      'Adakah anda teratur dan berdisiplin?';

  @override
  String get questionNeuroticism =>
      'Adakah anda sering bergerak semasa duduk?\n(Menggelisah, dll.)';

  @override
  String get personalityInfo =>
      'Kalori harian yang disyorkan disesuaikan berdasarkan ciri personaliti.';

  @override
  String get no => 'Tidak';

  @override
  String get yes => 'Ya';

  @override
  String get prev => 'Sebelumnya';

  @override
  String get somatotypeEctomorph => 'Ektomorf (Kurus)';

  @override
  String get somatotypeEctomorphDesc =>
      'Metabolisme cepat, sukar menambah berat badan dan otot.';

  @override
  String get somatotypeMesomorph => 'Mesomorf (Berotot)';

  @override
  String get somatotypeMesomorphDesc =>
      'Mudah membina otot, kawalan berat badan agak mudah.';

  @override
  String get somatotypeEndomorph => 'Endomorf (Berisi)';

  @override
  String get somatotypeEndomorphDesc =>
      'Mudah menimbun lemak, penurunan berat badan boleh menjadi sukar.';

  @override
  String get somatotypeMixed => 'Jenis Campuran';

  @override
  String get somatotypeMixedDesc => 'Gabungan beberapa jenis badan.';

  @override
  String get bodyShapeApple => '🍎 Epal';

  @override
  String get bodyShapeAppleDesc =>
      'Lemak terkumpul terutamanya di bahagian atas badan dan perut.';

  @override
  String get bodyShapePear => '🍐 Pir';

  @override
  String get bodyShapePearDesc =>
      'Lemak terkumpul terutamanya di bahagian bawah badan (pinggul, peha).';

  @override
  String get bodyShapeHourglass => '⏳ Jam Pasir';

  @override
  String get bodyShapeHourglassDesc =>
      'Dada dan pinggul seimbang dengan pinggang yang jelas.';

  @override
  String get bodyShapeRectangle => '📏 Segi Empat Tepat';

  @override
  String get bodyShapeRectangleDesc =>
      'Secara amnya bentuk badan rata dan seragam.';

  @override
  String get bodyShapeInvertedTriangle => '🔺 Segitiga Terbalik';

  @override
  String get bodyShapeInvertedTriangleDesc => 'Bahu lebar dan pinggul sempit.';

  @override
  String get muscleLow => 'Rendah';

  @override
  String get muscleMedium => 'Sederhana';

  @override
  String get muscleHigh => 'Tinggi';

  @override
  String get mealBreakfast => 'Sarapan';

  @override
  String get mealLunch => 'Makan Tengah Hari';

  @override
  String get mealDinner => 'Makan Malam';

  @override
  String get mealSnackMorning => 'Snek Pagi';

  @override
  String get mealSnackAfternoon => 'Snek Petang';

  @override
  String get mealSnackEvening => 'Snek Malam';

  @override
  String get mealSnack => 'Snek';

  @override
  String get guidanceNoPattern =>
      'Tetapkan pola makan anda untuk panduan yang lebih tepat!';

  @override
  String guidanceDailyGoal(int goal) {
    return 'Sasaran Harian: ${goal}kcal';
  }

  @override
  String guidanceOvereating(String meal, String time, int current) {
    return '⚠️ Anda sudah makan ${current}kcal sebelum $meal($time)! Berhati-hati dengan makan berlebihan.';
  }

  @override
  String guidanceFasting(String meal, String time) {
    return '💡 Disyorkan untuk berpuasa sehingga $meal($time).';
  }

  @override
  String get guidanceFinished => '✅ Anda telah menyelesaikan makanan hari ini!';

  @override
  String guidanceLow(int diff) {
    return '💡 Anda kurang ${diff}kcal daripada sasaran harian. Makan snek!';
  }

  @override
  String guidanceHigh(int diff) {
    return '⚠️ Anda melebihi ${diff}kcal daripada sasaran harian.';
  }

  @override
  String guidanceAdequate(String context) {
    return '✅ Hebat! Anda makan dalam jumlah yang betul $context.';
  }

  @override
  String guidanceLowMid(String context, int recommended, int current) {
    return '⚠️ Disyorkan ${recommended}kcal $context, tetapi anda di ${current}kcal. Makan sedikit lebih banyak pada makanan seterusnya!';
  }

  @override
  String guidanceHighMid(String context, int recommended, int current) {
    return '⚠️ Disyorkan ${recommended}kcal $context, tetapi anda di ${current}kcal. Makan lebih ringan lain kali!';
  }

  @override
  String get contextCurrent => 'semasa';

  @override
  String contextUntilMeal(String meal) {
    return 'sehingga $meal';
  }

  @override
  String get healthPermissionWarning => 'Kebenaran data kesihatan diperlukan';

  @override
  String syncSuccess(Object count) {
    return '✅ $count rekod aktiviti disegerakkan';
  }

  @override
  String syncError(Object error) {
    return 'Ralat semasa penyegerakan: $error';
  }

  @override
  String dataLoadError(Object error) {
    return 'Gagal memuatkan data: $error';
  }

  @override
  String get catTotal => 'Semua';

  @override
  String get catFruit => 'Buah';

  @override
  String get catStaple => 'Makanan Ruji';

  @override
  String get catSoup => 'Sup';

  @override
  String get catMeat => 'Daging';

  @override
  String get catFish => 'Ikan';

  @override
  String get catSide => 'Lauk';

  @override
  String get catVegetable => 'Sayur';

  @override
  String get catDairy => 'Tenusu';

  @override
  String get catBakery => 'Roti';

  @override
  String get catSnack => 'Snek';

  @override
  String get catBeverage => 'Minuman';

  @override
  String get catEtc => 'Lain-lain';

  @override
  String get quickActionsTitle => 'Jaga Kesihatan';

  @override
  String get todayHealthNote => 'Nota Kesihatan Hari Ini';

  @override
  String get bmiUnderweight => 'Kurus';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Berlebihan Berat';

  @override
  String get bmiObese => 'Obes';

  @override
  String get motivationOverLimit =>
      'Jangan risau, gerak sedikit lebih banyak esok. 🌿';

  @override
  String get motivationNearLimit => 'Anda telah bekerja keras hari ini! ☀️';

  @override
  String get motivationGood =>
      'Anda bergerak mengikut rentak anda. Bagus sekali! 👏';

  @override
  String get mealRecordButton => 'Rekod Makan';

  @override
  String get exerciseRecordButton => 'Rekod Senaman';

  @override
  String get weightRecordButton => 'Rekod Berat';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get weightLabel => 'Berat Badan';

  @override
  String get dailyGoalLabel => 'Sasaran Harian';

  @override
  String get currentLabel => 'Semasa';

  @override
  String get todayLabel => 'Hari Ini';

  @override
  String get totalLabel => 'Jumlah';

  @override
  String get netCaloriesLabel => 'Kalori Semasa';

  @override
  String get surplusLabel => 'Kelebihan';

  @override
  String get deficitLabel => 'Kekurangan';

  @override
  String get allow => 'Benarkan';

  @override
  String get deny => 'Tolak';

  @override
  String get healthPlatformName => 'Kesihatan';

  @override
  String get exercise => 'Senaman';

  @override
  String get kcalUnit => 'kcal';

  @override
  String get kgUnit => 'kg';

  @override
  String get kmUnit => 'km';

  @override
  String intakeTooltip(int current) {
    return 'Pengambilan: $current kcal';
  }

  @override
  String exerciseBurnTooltip(int burned) {
    return 'Senaman: -$burned kcal';
  }

  @override
  String tdeeBurnTooltip(int tdee) {
    return 'TDEE: -$tdee kcal';
  }

  @override
  String totalBurnTooltip(int total) {
    return 'Jumlah Terbakar: -$total kcal';
  }

  @override
  String get currentCaloriesTooltip => 'Kalori Semasa';

  @override
  String remainingTooltip(int remaining) {
    return 'Baki: $remaining kcal';
  }

  @override
  String get current => 'Semasa';

  @override
  String get normal => 'Normal';

  @override
  String get total => 'Jumlah';

  @override
  String get today => 'Hari Ini';

  @override
  String get deficit => 'Kekurangan';

  @override
  String get calorieGoalSettingsTitle => 'Tetapan Matlamat Kalori';

  @override
  String get selectGoalMode => 'Pilih Mod Matlamat';

  @override
  String get dailyCalorieGoal => 'Matlamat Kalori Harian';

  @override
  String get minBmr => 'Min (BMR)';

  @override
  String get maintainTdee => 'Kekalkan (TDEE)';

  @override
  String get max => 'Maks';

  @override
  String get bmrLabel => 'Kadar Metabolik Basal Saya (BMR)';

  @override
  String get tdeeLabel => 'Perbelanjaan Tenaga Harian Jumlah Saya (TDEE)';

  @override
  String get bmrWarning =>
      '💡 Mengonsumsi di bawah Kadar Metabolik Basal (BMR) boleh berbahaya kepada kesihatan dan ditetapkan sebagai matlamat minimum.';

  @override
  String get lossMode => 'Penurunan';

  @override
  String get maintainMode => 'Kekalkan';

  @override
  String get bulkMode => 'Penambahan';

  @override
  String get weightMaintain => 'Pemeliharaan Berat Badan Semasa';

  @override
  String weightLossPrediction(String weight) {
    return 'Anggaran penurunan ~${weight}kg seminggu';
  }

  @override
  String weightGainPrediction(String weight) {
    return 'Anggaran peningkatan ~${weight}kg seminggu';
  }

  @override
  String get maintainDesc => 'Anda mengekalkan keseimbangan yang sihat!';

  @override
  String get lossDesc => 'Konsistensi adalah yang paling penting. Semangat!';

  @override
  String get bulkDesc => 'Sila juga bersenam untuk meningkatkan jisim otot!';

  @override
  String get saveGoal => 'Simpan';

  @override
  String get goalSaved => 'Matlamat disimpan.';

  @override
  String get mealLunchPreset => 'Makan Tengah Hari';

  @override
  String get mealDinnerPreset => 'Makan Malam';

  @override
  String get mealBreakfastPreset => 'Sarapan';

  @override
  String get mealSnackMorningPreset => 'Snek Pagi';

  @override
  String get mealSnackAfternoonPreset => 'Snek Petang';

  @override
  String get appTitleMain => 'ChiYuHada VitaBuddy';

  @override
  String get clothingSettingsTitle => 'Tukar Warna Pakaian';

  @override
  String get preview => 'Pratonton';

  @override
  String get colorThemeSelection => 'Pemilihan Tema Warna';

  @override
  String get apply => 'Terapkan';

  @override
  String get clothingColorChanged => 'Warna pakaian telah ditukar';

  @override
  String get discardChangesConfirm =>
      'Adakah anda ingin membatalkan perubahan dan keluar?';

  @override
  String get stay => 'Kekal';

  @override
  String get exit => 'Keluar';

  @override
  String get loadFoodsFailed => 'Gagal memuatkan data makanan';

  @override
  String get amount => 'Jumlah';

  @override
  String get servings => 'hidangan';

  @override
  String consumedOn(String date) {
    return 'Tarikh pengambilan: $date';
  }

  @override
  String get unknown => 'Tidak diketahui';

  @override
  String get addFood => 'Tambah Makanan';

  @override
  String get quantityHint => 'Kuantiti';

  @override
  String get servingsHint => 'hidangan';

  @override
  String recentEaten(Object date) {
    return 'Baru dimakan: $date';
  }

  @override
  String get addFoodButton => 'Tambah';

  @override
  String get mealsTab => 'Makanan';

  @override
  String get exercisesTab => 'Senaman';

  @override
  String get summaryTab => 'Ringkasan';

  @override
  String get noMealRecords => 'Tiada catatan makanan.';

  @override
  String get noExerciseRecords => 'Tiada catatan senaman.';

  @override
  String get unknownFood => 'Makanan Tidak Diketahui';

  @override
  String get totalIntakeCalories => 'Jumlah Kalori Pengambilan';

  @override
  String get totalBurnedCalories => 'Jumlah Kalori Terbakar';

  @override
  String get recordedWeight => 'Berat Badan Direkodkan';

  @override
  String get noRecord => 'Tiada Catatan';

  @override
  String get netCalorieChange => 'Perubahan Kalori Bersih';

  @override
  String get mealPatternTitle =>
      'Beritahu kami tentang corak makanan harian anda';

  @override
  String get mealPatternSubtitle =>
      'Tetapkan waktu makan untuk pemberitahuan yang diperibadikan';

  @override
  String get meals2Preset => '2 Makanan';

  @override
  String get meals3Preset => '3 Makanan (Disyorkan)';

  @override
  String get meals4Preset => '4 Makanan+';

  @override
  String get customPreset => 'Tersuai';

  @override
  String get mealTimes => 'Waktu Makan';

  @override
  String get addMeal => 'Tambah Makanan';

  @override
  String get mealNameHint => 'Nama makanan';

  @override
  String get snackNotifications => '🍎 Pemberitahuan Snek';

  @override
  String get snackNotificationsDesc =>
      'Anda boleh menerima pemberitahuan waktu snek pagi/petang';

  @override
  String get lunch => 'Makan Tengah Hari';

  @override
  String get dinner => 'Makan Malam';

  @override
  String get breakfast => 'Sarapan';

  @override
  String get morningSnack => 'Snek Pagi';

  @override
  String mealNumber(Object number) {
    return 'Makanan $number';
  }

  @override
  String get energyAlertSensitivity => '⚡ Sensitiviti Peringatan Tenaga';

  @override
  String get mealNotifications => '📱 Pemberitahuan Makanan';

  @override
  String get exerciseNotifications => '🏃 Pemberitahuan Senaman';

  @override
  String get weightMeasurementNotifications =>
      '⚖️ Pemberitahuan Pengukuran Berat Badan';

  @override
  String get breakfastMeal => 'Sarapan';

  @override
  String get lunchMeal => 'Makan Tengah Hari';

  @override
  String get dinnerMeal => 'Makan Malam';

  @override
  String get afternoonSnack => 'Snek Petang';

  @override
  String get weightMeasurement => 'Pengukuran Berat Badan';

  @override
  String get exerciseTime => 'Waktu Senaman';

  @override
  String get selectDays => 'Pilih Hari:';

  @override
  String get monday => 'Isn';

  @override
  String get tuesday => 'Sel';

  @override
  String get wednesday => 'Rab';

  @override
  String get thursday => 'Kha';

  @override
  String get friday => 'Jum';

  @override
  String get saturday => 'Sab';

  @override
  String get sunday => 'Aha';

  @override
  String get energyDeficitAlertFrequency =>
      'Frekuensi Peringatan Defisit Tenaga';

  @override
  String get adjustAlertFrequencyDesc =>
      'Anda boleh menerima pemberitahuan lebih kerap atau kurang bergantung pada tetapan.';

  @override
  String get insensitive => 'Tidak Sensitif';

  @override
  String get sensitive => 'Sensitif';

  @override
  String get minimizeNotifications => 'Minimumkan pemberitahuan';

  @override
  String get defaultSettings => 'Tetapan lalai';

  @override
  String get frequentNotifications => 'Pemberitahuan kerap';

  @override
  String get notificationPermissionGranted =>
      'Kebenaran pemberitahuan diberikan';

  @override
  String get notificationPermissionRequired =>
      'Kebenaran pemberitahuan diperlukan';

  @override
  String get enablePermissionForHealthAlerts =>
      'Dayakan kebenaran untuk menerima peringatan kesihatan penting.';

  @override
  String get settings => 'Tetapan';

  @override
  String get currentCaloriesLabel => '(Kalori Semasa)';

  @override
  String get notificationBreakfastTitle => 'Selamat pagi! ☀️';

  @override
  String get notificationBreakfastBody =>
      'Mulakan hari anda dengan sarapan yang penuh nutrisi!';

  @override
  String get notificationLunchTitle => 'Masa makan tengah hari! 🍱';

  @override
  String get notificationLunchBody =>
      'Isi tenaga petang anda dengan makan tengah hari yang seimbang!';

  @override
  String get notificationDinnerTitle => 'Masa makan malam! 🌙';

  @override
  String get notificationDinnerBody =>
      'Akhiri hari anda dengan makan malam yang sihat!';

  @override
  String get notificationBrunchTitle => 'Masa brunch! 🥞';

  @override
  String get notificationBrunchBody => 'Nikmati brunch yang sedap!';

  @override
  String notificationCustomMealTitle(Object mealName) {
    return 'Masa $mealName! 🍽️';
  }

  @override
  String get notificationCustomMealBody =>
      'Nikmati makanan yang sedap dan sihat!';

  @override
  String get notificationMorningSnackTitle => 'Masa snek pagi! 🍎';

  @override
  String get notificationAfternoonSnackTitle => 'Masa snek petang! 🥨';

  @override
  String get notificationSnackBody => 'Isi tenaga dengan snek sihat!';

  @override
  String get notificationWaterTitle => 'Masa minum air! 💧';

  @override
  String get notificationWaterBody =>
      'Bagaimana dengan segelas air untuk kesihatan anda?';

  @override
  String get notificationCalorieOverTitle => 'Sasaran kalori terlampau ⚠️';

  @override
  String notificationCalorieOverBody(Object overAmount) {
    return 'Anda terlampau ${overAmount}kcal hari ini. Cuba jaga pola makan sihat!';
  }

  @override
  String get notificationLateNightTitle => 'Sedang makan sekarang? 🌙';

  @override
  String get notificationLateNightBody =>
      'Makan malam hari tidak baik untuk tidur dan pencernaan. Bagaimana dengan yang ringan?';

  @override
  String get notificationGoalAchievedTitle => 'Tahniah! 🎉';

  @override
  String get notificationGoalAchievedBody =>
      'Anda berjaya mencapai sasaran kalori hari ini!';

  @override
  String get notificationMotivationTitle => 'Semangat dari VitaBuddy 💝';

  @override
  String get notificationMotivationMessage1 =>
      'Adakah anda menghabiskan hari yang sihat? 💪';

  @override
  String get notificationMotivationMessage2 =>
      'Bagaimana dengan segelas air? 🥤';

  @override
  String get notificationMotivationMessage3 =>
      'Cuba rasai kesegaran dengan regangan ringan! 🤸‍♀️';

  @override
  String get notificationMotivationMessage4 =>
      'Semangat mengurus kesihatan hari ini! 🌟';

  @override
  String get notificationMotivationMessage5 =>
      'Diet seimbang adalah permulaan kesihatan! 🥗';

  @override
  String get notificationExerciseTitle => 'Masa bersenam! 🏃';

  @override
  String get notificationExerciseBody =>
      'Bagaimana dengan membakar kalori hari ini?';

  @override
  String get notificationWeightTitle => 'Masa menimbang berat badan! ⚖️';

  @override
  String get notificationWeightBody =>
      'Catat berat badan hari ini dan semak sasaran kesihatan anda.';

  @override
  String notificationSupplementTitle(Object supplementName) {
    return 'Masa minum $supplementName! 💊';
  }

  @override
  String get notificationSupplementBody =>
      'Jangan lupa mengurus kesihatan. Konsistensi itu penting!';

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
  String get clothingPresetDefault => 'Lalai (Kelabu)';

  @override
  String get clothingPresetPinkBlack => 'Merah Jambu/Hitam';

  @override
  String get clothingPresetWhiteNavy => 'Putih/Navy';

  @override
  String get clothingPresetMintCharcoal => 'Mint/Charcoal';

  @override
  String get clothingPresetLavenderPurple => 'Lavender/Ungu';

  @override
  String get clothingPresetCoralGray => 'Koral/Kelabu';

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
  String get permissionDiagnosis => 'Diagnosis Kebenaran';

  @override
  String get permissionDiagnosisResults => 'Hasil Diagnosis Kebenaran';

  @override
  String get clearPermissionCache => 'Kosongkan Cache Kebenaran';

  @override
  String get permissionCacheCleared =>
      'Cache kebenaran telah dikosongkan. Sila mulakan semula aplikasi.';

  @override
  String get syncingHealthData => 'Menyegerakkan data kesihatan...';

  @override
  String get close => 'Tutup';

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
  String get barcodeScan => 'Imbas Kod Bar';

  @override
  String get cameraPermissionRequired =>
      'Kebenaran kamera diperlukan. Sila benarkan dalam tetapan.';

  @override
  String get cameraInitializing => 'Memulakan kamera...';

  @override
  String cameraInitFailed(String error) {
    return 'Permulaan kamera gagal: $error';
  }

  @override
  String get barcodeDetected => 'Barcode dikesan!';

  @override
  String get pointCameraAtBarcode =>
      'Arahkan kamera ke barcode\n(Sebarang barcode akan dikenali)';

  @override
  String get barcodeVerified => 'Barcode disahkan!';

  @override
  String get invalidBarcode => 'Barcode tidak sah';

  @override
  String get type => 'Jenis';

  @override
  String get confidence => 'Keyakinan';

  @override
  String get scanCount => 'Bilangan imbasan';

  @override
  String get accept => 'Terima';

  @override
  String get rescan => 'Imbas semula';

  @override
  String get supportedFormats =>
      'Format yang disokong: Kod QR, barcode (EAN-13, UPC-A, dll.)';

  @override
  String get localSearch => 'Carian Tempatan';

  @override
  String get onlineSearch => 'Carian Dalam Talian';

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
  String get searchOnlineHint => 'Cari makanan dalam talian...';

  @override
  String get search100gHint => '100g당 입력은 검색 탭을 이용해주세요.';

  @override
  String get quantityLabel => 'Kuantiti:';

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
  String get noCameraAvailable => 'Tiada kamera tersedia.';

  @override
  String get cameraReady => 'Kamera sedia...';

  @override
  String get requestPermission => 'Minta Kebenaran';

  @override
  String get openSettings => 'Buka Tetapan';

  @override
  String get flashToggle => 'Togol Flash';

  @override
  String get confidenceLabel => 'Keyakinan';

  @override
  String get scanCountLabel => 'Bilangan Pemindaian';

  @override
  String get checkingCameraPermission => 'Memeriksa izin kamera...';

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
  String get brandLabel => 'Jenama';

  @override
  String apiResultsFound(int count) {
    return 'Jumlah $count hasil dijumpai.';
  }

  @override
  String foodNotFoundInDatabase(String apiName) {
    return 'Makanan ini tidak dapat dijumpai di pangkalan data $apiName.';
  }

  @override
  String apiKeyRequired(String apiName) {
    return 'Masukkan kunci API $apiName dalam tetapan untuk carian yang lebih tepat.';
  }

  @override
  String apiSearchError(String apiName) {
    return 'Ralat berlaku semasa mencari $apiName.';
  }

  @override
  String get noDataStatus => 'Tiada data';

  @override
  String get dataNotFoundTitle => 'Tiada dalam data';

  @override
  String get settingsRequired => 'Tetapan diperlukan';

  @override
  String get errorStatus => 'Ralat';
}
