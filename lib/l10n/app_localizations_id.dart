// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'VitaBuddy';

  @override
  String get homeGreetingMorning => 'Selamat pagi';

  @override
  String get homeGreetingAfternoon => 'Selamat siang';

  @override
  String get homeGreetingEvening => 'Selamat malam';

  @override
  String get homeSubtitle => 'Semoga harimu sehat!';

  @override
  String get caloriesUnit => 'kkal';

  @override
  String get intakeLabel => 'Asupan';

  @override
  String get burnedLabel => 'Terbakar';

  @override
  String get remainingLabel => 'Tersisa';

  @override
  String get goalLabel => 'Target';

  @override
  String get minutesUnit => 'mnt';

  @override
  String get exerciseRecord => 'Catatan Olahraga';

  @override
  String get foodRecord => 'Catatan Makanan';

  @override
  String get dailySummary => 'Ringkasan Harian';

  @override
  String get wearableConnected => 'Terhubung';

  @override
  String get wearablePermissionRequired => 'Izin Diperlukan';

  @override
  String get wearableNotConnected => 'Tidak terhubung';

  @override
  String get walkingActivity => 'Jalan Kaki';

  @override
  String get runningActivity => 'Lari';

  @override
  String get cyclingActivity => 'Bersepeda';

  @override
  String get swimmingActivity => 'Berenang';

  @override
  String get weightTrainingActivity => 'Latihan Beban';

  @override
  String get yogaActivity => 'Yoga';

  @override
  String get dancingActivity => 'Menari';

  @override
  String get hikingActivity => 'Mendaki';

  @override
  String get tennisActivity => 'Tenis';

  @override
  String get basketballActivity => 'Bola Basket';

  @override
  String get soccerActivity => 'Sepak Bola';

  @override
  String get aerobicsActivity => 'Aerobik';

  @override
  String get badmintonActivity => 'Bulutangkis';

  @override
  String get baseballActivity => 'Baseball';

  @override
  String get boxingActivity => 'Tinju';

  @override
  String get golfActivity => 'Golf';

  @override
  String get pilatesActivity => 'Pilates';

  @override
  String get tableTennisActivity => 'Tenis Meja';

  @override
  String get volleyballActivity => 'Bola Voli';

  @override
  String get ellipticalActivity => 'Elliptical';

  @override
  String get rowingActivity => 'Dayung';

  @override
  String get stairClimbingActivity => 'Naik Tangga';

  @override
  String get otherActivity => 'Lainnya';

  @override
  String get sourceManual => 'Manual';

  @override
  String get sourceHealthConnect => 'Health Connect';

  @override
  String get sourceHealthKit => 'HealthKit';

  @override
  String get workoutTypeLabel => 'Jenis Latihan';

  @override
  String get durationLabel => 'Durasi (menit)';

  @override
  String get intensityLabel => 'Intensitas';

  @override
  String get intensityLow => 'Rendah';

  @override
  String get intensityMedium => 'Sedang';

  @override
  String get intensityHigh => 'Tinggi';

  @override
  String get calcCaloriesLabel => 'Perkiraan Kalori';

  @override
  String get calorieCalcError => 'Kesalahan perhitungan kalori';

  @override
  String workoutSaved(Object type) {
    return '$type tersimpan';
  }

  @override
  String saveError(Object error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String get syncComplete => 'Sinkronisasi selesai';

  @override
  String get syncFailed => 'Sinkronisasi gagal';

  @override
  String get noDataToSync => 'Tidak ada data untuk disinkronkan';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get profileTitle => 'Profil';

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get calorieGoalSettings => 'Pengaturan Tujuan Kalori';

  @override
  String get sleepSettings => 'Pengaturan Tidur';

  @override
  String get avatarClothingSettings => 'Pengaturan Pakaian Avatar';

  @override
  String get profileEdit => 'Edit Profil';

  @override
  String get notificationSettings => 'Pengaturan Notifikasi';

  @override
  String get healthDataPermission => 'Izin Data Kesehatan';

  @override
  String get healthPermissionAlreadyGranted =>
      'Izin data kesehatan sudah diberikan';

  @override
  String get healthPermissionGranted => 'Izin data kesehatan diberikan';

  @override
  String get healthPermissionDenied =>
      'Izin data kesehatan ditolak. Silakan aktifkan di pengaturan.';

  @override
  String get weight => 'Berat';

  @override
  String get height => 'Tinggi';

  @override
  String get age => 'Usia';

  @override
  String get gender => 'Jenis Kelamin';

  @override
  String get male => 'Pria';

  @override
  String get female => 'Wanita';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Edit';

  @override
  String get autoRecord => 'Rekam Otomatis';

  @override
  String get manualRecord => 'Rekam Manual';

  @override
  String get caloriesBurned => 'Kalori Terbakar';

  @override
  String get workoutCount => 'Jumlah Olahraga';

  @override
  String get steps => 'Langkah';

  @override
  String get syncing => 'Menyinkronkan...';

  @override
  String get syncHealthData => 'Sinkronkan Data Kesehatan';

  @override
  String get noAutoRecords => 'Tidak ada olahraga yang direkam secara otomatis';

  @override
  String get noAutoRecordsSubtitle =>
      'Tekan tombol Sinkronkan Data Kesehatan untuk\nmengimpor data olahraga dari ponsel dan wearable Anda';

  @override
  String get noManualRecords => 'Tidak ada olahraga yang direkam secara manual';

  @override
  String get noManualRecordsSubtitle =>
      'Ketuk tombol + di kanan bawah\nuntuk merekam olahraga Anda secara manual';

  @override
  String get dataLoadFailed => 'Gagal memuat data';

  @override
  String get basicInfo => 'Dasar';

  @override
  String get bodyInfo => 'Tubuh';

  @override
  String get personality => 'Kepribadian';

  @override
  String get previous => 'Sebelumnya';

  @override
  String get nameOptional => 'Nama (Opsional)';

  @override
  String get activityLevel => 'Tingkat Aktivitas';

  @override
  String get activitySedentary => 'Tidak banyak bergerak';

  @override
  String get activityLight => 'Olahraga ringan (1-3 hari/minggu)';

  @override
  String get activityModerate => 'Olahraga sedang (3-5 hari/minggu)';

  @override
  String get activityActive => 'Olahraga aktif (6-7 hari/minggu)';

  @override
  String get activityVeryActive => 'Sangat aktif (2x sehari)';

  @override
  String get sedentary => 'Hampir tidak berolahraga';

  @override
  String get lightExercise => 'Olahraga ringan (1-3 hari/minggu)';

  @override
  String get moderateExercise => 'Olahraga sedang (3-5 hari/minggu)';

  @override
  String get activeExercise => 'Olahraga aktif (6-7 hari/minggu)';

  @override
  String get veryActiveExercise => 'Sangat aktif (dua kali sehari)';

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String get profileUpdated => 'Profil diperbarui';

  @override
  String get discardChanges => 'Batalkan Perubahan';

  @override
  String get discardChangesMessage => 'Keluar tanpa menyimpan perubahan?';

  @override
  String get continueEditing => 'Lanjutkan Mengedit';

  @override
  String get exitWithoutSaving => 'Keluar';

  @override
  String get complete => 'Selesai';

  @override
  String get next => 'Selanjutnya';

  @override
  String get foodInput => 'Input Makanan';

  @override
  String get recent => 'Terbaru';

  @override
  String get favorites => 'Favorit';

  @override
  String get search => 'Cari';

  @override
  String get customAdd => 'Tambah Kustom';

  @override
  String get noRecentFoods => 'Tidak ada makanan terbaru';

  @override
  String get noFavoriteFoods => 'Tidak ada makanan favorit';

  @override
  String get addFavoriteHint =>
      'Ketuk ⭐ pada daftar makanan untuk menambahkan favorit';

  @override
  String get noSearchResults => 'Tidak ada hasil pencarian';

  @override
  String get searchFoodHint => 'Cari makanan...';

  @override
  String get foodName => 'Nama Makanan';

  @override
  String get calories => 'Kalori';

  @override
  String get quantity => 'Jumlah';

  @override
  String get servingCalories => 'Kalori per Porsi';

  @override
  String get servingCount => 'Jumlah Porsi';

  @override
  String get foodNameHint => 'contoh: Hamburger';

  @override
  String get caloriesHint => 'contoh: 550';

  @override
  String get addIntake => 'Tambah Asupan';

  @override
  String get saveTemporary => 'Simpan Cepat (Tambah kalori nanti)';

  @override
  String get invalidQuantity => 'Masukkan jumlah yang valid';

  @override
  String get foodAdded => 'Makanan ditambahkan';

  @override
  String get foodAddFailed => 'Gagal menambahkan makanan';

  @override
  String get favoriteAdded => 'Ditambahkan ke favorit';

  @override
  String get favoriteRemoved => 'Dihapus dari favorit';

  @override
  String get inputModeTotal => 'Total';

  @override
  String get inputModeServing => 'Porsi';

  @override
  String get inputMode100g => '100g';

  @override
  String get inputModeQuick => 'Cepat';

  @override
  String get add => 'Tambah';

  @override
  String get enterFoodNameAndCalories => 'Masukkan nama makanan dan kalori';

  @override
  String get enterValidCalories => 'Masukkan kalori yang valid';

  @override
  String get userFoodAddFailed => 'Gagal menambahkan makanan pengguna';

  @override
  String get enterFoodName => 'Masukkan nama makanan';

  @override
  String get quickSaveSuccess => 'Disimpan sementara (Tambah kalori nanti)';

  @override
  String get servingInfoHelp => 'Masukkan info porsi dari label nutrisi';

  @override
  String get servingUnit => 'kali';

  @override
  String get unitServings => 'porsi';

  @override
  String get unitCount => 'buah/porsi';

  @override
  String get foodAddTitle => 'Tambah Makanan';

  @override
  String foodAddConfirm(String foodName) {
    return 'Tambahkan $foodName?';
  }

  @override
  String get refreshTooltip => 'Segarkan';

  @override
  String get totalCalorieHelp => 'Masukkan total kalori secara langsung';

  @override
  String get quickRecordHelp => 'Masukkan nama saja dan tambah kalori nanti';

  @override
  String get defaultLabel => 'Default';

  @override
  String get weightRecord => 'Rekam Berat Badan';

  @override
  String get weightLoadFailed => 'Gagal memuat catatan berat badan';

  @override
  String get enterWeight => 'Masukkan berat badan';

  @override
  String get enterValidWeight => 'Masukkan berat badan yang valid (20-300kg)';

  @override
  String get weightRecorded => 'Berat badan direkam';

  @override
  String get weightRecordFailed => 'Gagal merekam berat badan';

  @override
  String get weightRecordDeleted => 'Catatan berat badan dihapus';

  @override
  String get deleteFailed => 'Gagal menghapus catatan';

  @override
  String get todaysWeight => 'Berat Hari Ini';

  @override
  String get weightHint => 'contoh: 70.5';

  @override
  String get record => 'Rekam';

  @override
  String get noteOptional => 'Catatan (Opsional)';

  @override
  String get noteHint => 'contoh: Setelah olahraga';

  @override
  String get weightTrend => 'Tren Berat Badan';

  @override
  String get noWeightRecords => 'Tidak ada catatan berat badan';

  @override
  String get deleteRecord => 'Hapus Catatan';

  @override
  String get confirmDeleteWeight => 'Hapus catatan berat badan ini?';

  @override
  String get languageSettings => 'Pengaturan Bahasa';

  @override
  String get selectLanguage => 'Pilih Bahasa';

  @override
  String get getStarted => 'Mulai';

  @override
  String get language => 'Bahasa';

  @override
  String get healthPermissionContent =>
      'Aplikasi memerlukan akses data kesehatan untuk menyinkronkan kalori dengan perangkat yang dapat dikenakan.';

  @override
  String get healthPermissionAllowInfo => 'Jika diizinkan:';

  @override
  String get healthPermissionInfo1 =>
      '• Sinkronisasi otomatis langkah dan kalori yang terbakar';

  @override
  String get healthPermissionInfo2 => '• Impor otomatis catatan olahraga';

  @override
  String get healthPermissionInfo3 => '• Manajemen kalori yang lebih akurat';

  @override
  String get healthPermissionDenyInfo =>
      'Anda tetap dapat menggunakan fitur dasar aplikasi meskipun izin ditolak.';

  @override
  String get later => 'Nanti';

  @override
  String get allowPermission => 'Izinkan';

  @override
  String get permissionSelect => 'Pilih Izin';

  @override
  String get allowAndSync => 'Izinkan dan Sinkronkan';

  @override
  String get setupLater => 'Atur Nanti';

  @override
  String get history => 'Riwayat';

  @override
  String get errorOccurred => 'Kesalahan Terjadi';

  @override
  String get noRecords => 'Belum ada catatan.';

  @override
  String get pleaseSelectLanguage => 'Silakan pilih bahasa';

  @override
  String get homeTitle => 'Chiyuhada VitaBuddy';

  @override
  String get mealRecord => 'Catatan Makan';

  @override
  String get viewRecords => 'Lihat Catatan';

  @override
  String get developerTest => 'Layar Tes Pengembang';

  @override
  String get mealGuidance => 'Panduan Makan';

  @override
  String get nextMeal => 'Makan Berikutnya';

  @override
  String get moreNeeded => 'lagi';

  @override
  String get reduce => 'kurangi';

  @override
  String get until => 'sampai';

  @override
  String get sleepMode => 'Mode Tidur';

  @override
  String get connected => 'Terhubung';

  @override
  String get disconnected => 'Terputus';

  @override
  String get notConnected => 'Tidak terhubung';

  @override
  String get justSynced => 'Baru saja';

  @override
  String get syncedJustNow => 'Baru saja disinkronkan';

  @override
  String syncedMinutesAgo(int minutes) {
    return '$minutes menit lalu';
  }

  @override
  String syncedHoursAgo(int hours) {
    return '$hours jam lalu';
  }

  @override
  String get minutesAgo => 'menit lalu';

  @override
  String get hoursAgo => 'jam lalu';

  @override
  String get minutesShort => 'mnt';

  @override
  String get changeClothingColor => 'Ubah warna pakaian';

  @override
  String get walking => 'Jalan kaki';

  @override
  String get running => 'Lari';

  @override
  String get cycling => 'Bersepeda';

  @override
  String get swimming => 'Berenang';

  @override
  String get user => 'Pengguna';

  @override
  String homeGreetingFormat(String greeting, String user) {
    return '$greeting, $user!';
  }

  @override
  String get reduceIntake => 'Kurangi asupan';

  @override
  String get profileSetup => 'Pengaturan Profil';

  @override
  String get stepBasicInfo => 'Info Dasar';

  @override
  String get basicInfoDesc =>
      'Harap masukkan info dasar untuk perhitungan kalori yang akurat.';

  @override
  String get nameHint => 'Contoh: Budi';

  @override
  String get yearsOld => 'tahun';

  @override
  String get ageUnit => 'tahun';

  @override
  String get stepMealPattern => 'Pola Makan';

  @override
  String get mealPatternSetup => 'Pengaturan Pola Makan';

  @override
  String get mealPatternDesc =>
      'Atur pola makan harian Anda untuk mendapatkan notifikasi yang dipersonalisasi.';

  @override
  String get meals2 => '2 Makan';

  @override
  String get meals3 => '3 Makan (Disarankan)';

  @override
  String get meals4 => '4 Makanan';

  @override
  String get meals4Plus => '4 Makan+';

  @override
  String get mealTimeSettings => 'Pengaturan Waktu Makan';

  @override
  String get configuredMealTimes => 'Waktu Makan Terkonfigurasi';

  @override
  String get stepSomatotype => 'Tipe Tubuh';

  @override
  String get somatotypeSelection => 'Pemilihan Tipe Tubuh';

  @override
  String get somatotypeDesc =>
      'Pilih tipe tubuh Anda. Ini mempengaruhi perhitungan tingkat metabolisme.';

  @override
  String get dontKnow => 'Saya tidak tahu';

  @override
  String get unsure => 'Tidak yakin';

  @override
  String get stepBodyShape => 'Bentuk Tubuh';

  @override
  String get bodyShapeSelection => 'Pemilihan Bentuk Tubuh';

  @override
  String get bodyShapeDesc =>
      'Di mana berat badan Anda bertambah? Mempengaruhi penampilan avatar.';

  @override
  String get stepDetailInfo => 'Info Detail';

  @override
  String get detailInfoDesc =>
      'Info tambahan memungkinkan perhitungan yang lebih akurat.';

  @override
  String get muscleType => 'Massa Otot';

  @override
  String get muscleInfo => 'Massa otot yang lebih tinggi meningkatkan BMR.';

  @override
  String get stepPersonality => 'Tes Kepribadian';

  @override
  String get personalityDesc =>
      'Mempengaruhi perhitungan aktivitas harian (NEAT).';

  @override
  String get questionExtraversion => 'Apakah Anda energik dan ekstrovert?';

  @override
  String get questionConscientiousness =>
      'Apakah Anda terorganisir dan disiplin?';

  @override
  String get questionNeuroticism =>
      'Apakah Anda sering bergerak saat duduk?\n(Menggelisah, dll.)';

  @override
  String get personalityInfo =>
      'Kalori harian yang disarankan disesuaikan berdasarkan sifat kepribadian.';

  @override
  String get no => 'Tidak';

  @override
  String get yes => 'Ya';

  @override
  String get prev => 'Sebelumnya';

  @override
  String get somatotypeEctomorph => 'Ectomorph (Kurus)';

  @override
  String get somatotypeEctomorphDesc =>
      'Metabolisme cepat, sulit menambah berat badan dan otot.';

  @override
  String get somatotypeMesomorph => 'Mesomorph (Berotot)';

  @override
  String get somatotypeMesomorphDesc =>
      'Mudah membangun otot, kontrol berat badan relatif mudah.';

  @override
  String get somatotypeEndomorph => 'Endomorph (Berisi)';

  @override
  String get somatotypeEndomorphDesc =>
      'Mudah menimbun lemak, penurunan berat badan bisa sulit.';

  @override
  String get somatotypeMixed => 'Tipe Campuran';

  @override
  String get somatotypeMixedDesc => 'Kombinasi dari beberapa tipe tubuh.';

  @override
  String get bodyShapeApple => '🍎 Apel';

  @override
  String get bodyShapeAppleDesc =>
      'Lemak menumpuk terutama di tubuh bagian atas dan perut.';

  @override
  String get bodyShapePear => '🍐 Pir';

  @override
  String get bodyShapePearDesc =>
      'Lemak menumpuk terutama di tubuh bagian bawah (pinggul, paha).';

  @override
  String get bodyShapeHourglass => '⏳ Jam Pasir';

  @override
  String get bodyShapeHourglassDesc =>
      'Dada dan pinggul seimbang dengan pinggang yang jelas.';

  @override
  String get bodyShapeRectangle => '📏 Persegi Panjang';

  @override
  String get bodyShapeRectangleDesc =>
      'Secara umum bentuk tubuh datar dan seragam.';

  @override
  String get bodyShapeInvertedTriangle => '🔺 Segitiga Terbalik';

  @override
  String get bodyShapeInvertedTriangleDesc => 'Bahu lebar dan pinggul sempit.';

  @override
  String get muscleLow => 'Rendah';

  @override
  String get muscleMedium => 'Sedang';

  @override
  String get muscleHigh => 'Tinggi';

  @override
  String get mealBreakfast => 'Sarapan';

  @override
  String get mealLunch => 'Makan Siang';

  @override
  String get mealDinner => 'Makan Malam';

  @override
  String get mealSnackMorning => 'Camilan Pagi';

  @override
  String get mealSnackAfternoon => 'Camilan Sore';

  @override
  String get mealSnackEvening => 'Camilan Malam';

  @override
  String get mealSnack => 'Camilan';

  @override
  String get guidanceNoPattern =>
      'Atur pola makan Anda untuk panduan yang lebih akurat!';

  @override
  String guidanceDailyGoal(int goal) {
    return 'Target Harian: ${goal}kcal';
  }

  @override
  String guidanceOvereating(String meal, String time, int current) {
    return '⚠️ Anda sudah makan ${current}kcal sebelum $meal($time)! Hati-hati makan berlebihan.';
  }

  @override
  String guidanceFasting(String meal, String time) {
    return '💡 Disarankan untuk berpuasa sampai $meal($time).';
  }

  @override
  String get guidanceFinished => '✅ Anda telah menyelesaikan makan hari ini!';

  @override
  String guidanceLow(int diff) {
    return '💡 Anda kurang ${diff}kcal dari target harian. Makan camilan!';
  }

  @override
  String guidanceHigh(int diff) {
    return '⚠️ Anda melebihi ${diff}kcal dari target harian.';
  }

  @override
  String guidanceAdequate(String context) {
    return '✅ Bagus! Anda makan dalam jumlah yang tepat $context.';
  }

  @override
  String guidanceLowMid(String context, int recommended, int current) {
    return '⚠️ Disarankan ${recommended}kcal $context, tapi Anda di ${current}kcal. Makan sedikit lebih banyak di makan berikutnya!';
  }

  @override
  String guidanceHighMid(String context, int recommended, int current) {
    return '⚠️ Disarankan ${recommended}kcal $context, tapi Anda di ${current}kcal. Makan lebih ringan lain kali!';
  }

  @override
  String get contextCurrent => 'saat ini';

  @override
  String contextUntilMeal(String meal) {
    return 'sampai $meal';
  }

  @override
  String get healthPermissionWarning => 'Izin data kesehatan diperlukan';

  @override
  String syncSuccess(Object count) {
    return '✅ $count data aktivitas disinkronkan';
  }

  @override
  String syncError(Object error) {
    return 'Kesalahan saat sinkronisasi: $error';
  }

  @override
  String dataLoadError(Object error) {
    return 'Gagal memuat data: $error';
  }

  @override
  String get catTotal => 'Semua';

  @override
  String get catFruit => 'Buah';

  @override
  String get catStaple => 'Makanan Pokok';

  @override
  String get catSoup => 'Sup';

  @override
  String get catMeat => 'Daging';

  @override
  String get catFish => 'Ikan';

  @override
  String get catSide => 'Lauk Pauk';

  @override
  String get catVegetable => 'Sayur';

  @override
  String get catDairy => 'Produk Susu';

  @override
  String get catBakery => 'Roti';

  @override
  String get catSnack => 'Makanan Ringan';

  @override
  String get catBeverage => 'Minuman';

  @override
  String get catEtc => 'Lainnya';

  @override
  String get quickActionsTitle => 'Jaga Kesehatan';

  @override
  String get todayHealthNote => 'Catatan Kesehatan Hari Ini';

  @override
  String get bmiUnderweight => 'Kurus';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Kelebihan Berat';

  @override
  String get bmiObese => 'Obesitas';

  @override
  String get motivationOverLimit =>
      'Santai saja, besok sedikit lebih banyak gerak. 🌿';

  @override
  String get motivationNearLimit => 'Hari ini Anda sudah bekerja keras! ☀️';

  @override
  String get motivationGood =>
      'Anda bergerak sesuai ritme Anda. Sangat bagus! 👏';

  @override
  String get mealRecordButton => 'Catatan Makan';

  @override
  String get exerciseRecordButton => 'Catatan Olahraga';

  @override
  String get weightRecordButton => 'Catatan Berat Badan';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get weightLabel => 'Berat Badan';

  @override
  String get dailyGoalLabel => 'Target Harian';

  @override
  String get currentLabel => 'Saat Ini';

  @override
  String get todayLabel => 'Hari Ini';

  @override
  String get totalLabel => 'Total';

  @override
  String get netCaloriesLabel => 'Kalori Saat Ini';

  @override
  String get surplusLabel => 'Kelebihan';

  @override
  String get deficitLabel => 'Kekurangan';

  @override
  String get allow => 'Izinkan';

  @override
  String get deny => 'Tolak';

  @override
  String get healthPlatformName => 'Kesehatan';

  @override
  String get exercise => 'Olahraga';

  @override
  String get kcalUnit => 'kkal';

  @override
  String get kgUnit => 'kg';

  @override
  String get kmUnit => 'km';

  @override
  String intakeTooltip(int current) {
    return 'Asupan: $current kkal';
  }

  @override
  String exerciseBurnTooltip(int burned) {
    return 'Olahraga: -$burned kkal';
  }

  @override
  String tdeeBurnTooltip(int tdee) {
    return 'TDEE: -$tdee kkal';
  }

  @override
  String totalBurnTooltip(int total) {
    return 'Total Terbakar: -$total kkal';
  }

  @override
  String get currentCaloriesTooltip => 'Kalori Saat Ini';

  @override
  String remainingTooltip(int remaining) {
    return 'Tersisa: $remaining kkal';
  }

  @override
  String get current => 'Saat Ini';

  @override
  String get normal => 'Normal';

  @override
  String get total => 'Total';

  @override
  String get today => 'Hari Ini';

  @override
  String get deficit => 'Defisit';

  @override
  String get calorieGoalSettingsTitle => 'Pengaturan Tujuan Kalori';

  @override
  String get selectGoalMode => 'Pilih Mode Tujuan';

  @override
  String get dailyCalorieGoal => 'Tujuan Kalori Harian';

  @override
  String get minBmr => 'Min (BMR)';

  @override
  String get maintainTdee => 'Pertahankan (TDEE)';

  @override
  String get max => 'Maks';

  @override
  String get bmrLabel => 'Basal Metabolic Rate Saya (BMR)';

  @override
  String get tdeeLabel => 'Total Daily Energy Expenditure Saya (TDEE)';

  @override
  String get bmrWarning =>
      '💡 Mengonsumsi di bawah Basal Metabolic Rate (BMR) dapat berbahaya bagi kesehatan dan diatur sebagai tujuan minimum.';

  @override
  String get lossMode => 'Penurunan';

  @override
  String get maintainMode => 'Pertahankan';

  @override
  String get bulkMode => 'Penambahan';

  @override
  String get weightMaintain => 'Pemeliharaan Berat Badan Saat Ini';

  @override
  String weightLossPrediction(String weight) {
    return 'Perkiraan penurunan ~${weight}kg per minggu';
  }

  @override
  String weightGainPrediction(String weight) {
    return 'Perkiraan peningkatan ~${weight}kg per minggu';
  }

  @override
  String get maintainDesc => 'Anda menjaga keseimbangan yang sehat!';

  @override
  String get lossDesc => 'Konsistensi adalah yang paling penting. Semangat!';

  @override
  String get bulkDesc =>
      'Silakan juga berolahraga untuk meningkatkan massa otot!';

  @override
  String get saveGoal => 'Simpan';

  @override
  String get goalSaved => 'Tujuan disimpan.';

  @override
  String get mealLunchPreset => 'Makan Siang';

  @override
  String get mealDinnerPreset => 'Makan Malam';

  @override
  String get mealBreakfastPreset => 'Sarapan';

  @override
  String get mealSnackMorningPreset => 'Camilan Pagi';

  @override
  String get mealSnackAfternoonPreset => 'Camilan Sore';

  @override
  String get appTitleMain => 'ChiYuHada VitaBuddy';

  @override
  String get clothingSettingsTitle => 'Ubah Warna Pakaian';

  @override
  String get preview => 'Pratinjau';

  @override
  String get colorThemeSelection => 'Pemilihan Tema Warna';

  @override
  String get apply => 'Terapkan';

  @override
  String get clothingColorChanged => 'Warna pakaian telah diubah';

  @override
  String get discardChangesConfirm =>
      'Apakah Anda ingin membatalkan perubahan dan keluar?';

  @override
  String get stay => 'Tetap';

  @override
  String get exit => 'Keluar';

  @override
  String get loadFoodsFailed => 'Gagal memuat data makanan';

  @override
  String get amount => 'Jumlah';

  @override
  String get servings => 'porsi';

  @override
  String consumedOn(String date) {
    return '섭취일: $date';
  }

  @override
  String get unknown => 'Tidak diketahui';

  @override
  String get addFood => 'Tambah Makanan';

  @override
  String get quantityHint => 'Jumlah';

  @override
  String get servingsHint => 'porsi';

  @override
  String recentEaten(Object date) {
    return 'Baru saja dimakan: $date';
  }

  @override
  String get addFoodButton => 'Tambah';

  @override
  String get mealsTab => 'Makanan';

  @override
  String get exercisesTab => 'Olahraga';

  @override
  String get summaryTab => 'Ringkasan';

  @override
  String get noMealRecords => 'Tidak ada catatan makanan.';

  @override
  String get noExerciseRecords => 'Tidak ada catatan olahraga.';

  @override
  String get unknownFood => 'Makanan Tidak Diketahui';

  @override
  String get totalIntakeCalories => 'Total Kalori Asupan';

  @override
  String get totalBurnedCalories => 'Total Kalori Terbakar';

  @override
  String get recordedWeight => 'Berat Badan Tercatat';

  @override
  String get noRecord => 'Tidak Ada Catatan';

  @override
  String get netCalorieChange => 'Perubahan Kalori Bersih';

  @override
  String get mealPatternTitle => 'Beritahu kami tentang pola makan harian Anda';

  @override
  String get mealPatternSubtitle =>
      'Atur waktu makan untuk notifikasi yang dipersonalisasi';

  @override
  String get meals2Preset => '2 Makanan';

  @override
  String get meals3Preset => '3 Makanan (Disarankan)';

  @override
  String get meals4Preset => '4 Makanan+';

  @override
  String get customPreset => 'Kustom';

  @override
  String get mealTimes => 'Waktu Makan';

  @override
  String get addMeal => 'Tambah Makanan';

  @override
  String get mealNameHint => 'Nama makanan';

  @override
  String get snackNotifications => '🍎 Notifikasi Camilan';

  @override
  String get snackNotificationsDesc =>
      'Anda dapat menerima notifikasi waktu camilan pagi/sore';

  @override
  String get lunch => 'Makan Siang';

  @override
  String get dinner => 'Makan Malam';

  @override
  String get breakfast => 'Sarapan';

  @override
  String get morningSnack => 'Camilan Pagi';

  @override
  String mealNumber(Object number) {
    return 'Makanan $number';
  }

  @override
  String get energyAlertSensitivity => '⚡ Sensitivitas Peringatan Energi';

  @override
  String get mealNotifications => '📱 Notifikasi Makanan';

  @override
  String get exerciseNotifications => '🏃 Notifikasi Olahraga';

  @override
  String get weightMeasurementNotifications =>
      '⚖️ Notifikasi Pengukuran Berat Badan';

  @override
  String get breakfastMeal => 'Sarapan';

  @override
  String get lunchMeal => 'Makan Siang';

  @override
  String get dinnerMeal => 'Makan Malam';

  @override
  String get afternoonSnack => 'Camilan Sore';

  @override
  String get weightMeasurement => 'Pengukuran Berat Badan';

  @override
  String get exerciseTime => 'Waktu Olahraga';

  @override
  String get selectDays => 'Pilih Hari:';

  @override
  String get monday => 'Sen';

  @override
  String get tuesday => 'Sel';

  @override
  String get wednesday => 'Rab';

  @override
  String get thursday => 'Kam';

  @override
  String get friday => 'Jum';

  @override
  String get saturday => 'Sab';

  @override
  String get sunday => 'Min';

  @override
  String get energyDeficitAlertFrequency =>
      'Frekuensi Peringatan Defisit Energi';

  @override
  String get adjustAlertFrequencyDesc =>
      'Anda dapat menerima notifikasi lebih sering atau lebih jarang tergantung pengaturan.';

  @override
  String get insensitive => 'Tidak Sensitif';

  @override
  String get sensitive => 'Sensitif';

  @override
  String get minimizeNotifications => 'Minimalkan notifikasi';

  @override
  String get defaultSettings => 'Pengaturan default';

  @override
  String get frequentNotifications => 'Notifikasi sering';

  @override
  String get notificationPermissionGranted => 'Izin notifikasi diberikan';

  @override
  String get notificationPermissionRequired => 'Izin notifikasi diperlukan';

  @override
  String get enablePermissionForHealthAlerts =>
      'Aktifkan izin untuk menerima peringatan kesehatan penting.';

  @override
  String get settings => 'Pengaturan';

  @override
  String get currentCaloriesLabel => '(Kalori Saat Ini)';

  @override
  String get notificationBreakfastTitle => 'Selamat pagi yang baik! ☀️';

  @override
  String get notificationBreakfastBody =>
      'Mulai hari Anda dengan sarapan yang penuh nutrisi!';

  @override
  String get notificationLunchTitle => 'Waktunya makan siang! 🍱';

  @override
  String get notificationLunchBody =>
      'Isi energi sore Anda dengan makan siang yang seimbang!';

  @override
  String get notificationDinnerTitle => 'Waktunya makan malam! 🌙';

  @override
  String get notificationDinnerBody =>
      'Akhiri hari Anda dengan makan malam yang sehat!';

  @override
  String get notificationBrunchTitle => 'Waktunya brunch! 🥞';

  @override
  String get notificationBrunchBody => 'Nikmati brunch yang lezat!';

  @override
  String notificationCustomMealTitle(Object mealName) {
    return 'Waktunya $mealName! 🍽️';
  }

  @override
  String get notificationCustomMealBody =>
      'Nikmati makanan yang lezat dan sehat!';

  @override
  String get notificationMorningSnackTitle => 'Waktunya camilan pagi! 🍎';

  @override
  String get notificationAfternoonSnackTitle => 'Waktunya camilan sore! 🥨';

  @override
  String get notificationSnackBody => 'Isi energi dengan camilan sehat!';

  @override
  String get notificationWaterTitle => 'Waktunya minum air! 💧';

  @override
  String get notificationWaterBody =>
      'Bagaimana dengan segelas air untuk kesehatan Anda?';

  @override
  String get notificationCalorieOverTitle => 'Target kalori terlampaui ⚠️';

  @override
  String notificationCalorieOverBody(Object overAmount) {
    return 'Anda melebihi ${overAmount}kcal hari ini. Coba jaga pola makan sehat!';
  }

  @override
  String get notificationLateNightTitle => 'Sedang makan sekarang? 🌙';

  @override
  String get notificationLateNightBody =>
      'Makan malam hari tidak baik untuk tidur dan pencernaan. Bagaimana dengan yang ringan?';

  @override
  String get notificationGoalAchievedTitle => 'Selamat! 🎉';

  @override
  String get notificationGoalAchievedBody =>
      'Anda berhasil mencapai target kalori hari ini!';

  @override
  String get notificationMotivationTitle => 'Semangat dari VitaBuddy 💝';

  @override
  String get notificationMotivationMessage1 =>
      'Apakah Anda menghabiskan hari yang sehat? 💪';

  @override
  String get notificationMotivationMessage2 =>
      'Bagaimana dengan segelas air? 🥤';

  @override
  String get notificationMotivationMessage3 =>
      'Coba rasakan kesegaran dengan peregangan ringan! 🤸‍♀️';

  @override
  String get notificationMotivationMessage4 =>
      'Semangat mengelola kesehatan hari ini! 🌟';

  @override
  String get notificationMotivationMessage5 =>
      'Diet seimbang adalah awal kesehatan! 🥗';

  @override
  String get notificationExerciseTitle => 'Waktunya olahraga! 🏃';

  @override
  String get notificationExerciseBody =>
      'Bagaimana dengan membakar kalori hari ini?';

  @override
  String get notificationWeightTitle => 'Waktunya menimbang berat badan! ⚖️';

  @override
  String get notificationWeightBody =>
      'Catat berat badan hari ini dan periksa tujuan kesehatan Anda.';

  @override
  String notificationSupplementTitle(Object supplementName) {
    return 'Waktunya minum $supplementName! 💊';
  }

  @override
  String get notificationSupplementBody =>
      'Jangan lupa mengelola kesehatan. Konsistensi itu penting!';

  @override
  String get calorieStatusVeryLow => 'Saya lapar... Saya butuh makan!';

  @override
  String get calorieStatusLow => 'Energi rendah';

  @override
  String get calorieStatusBelowIdeal => 'Boleh makan sedikit lagi';

  @override
  String get calorieStatusIdeal => 'Sempurna! Kondisi bagus';

  @override
  String get calorieStatusSlightlyHigh => 'Sudah makan sedikit terlalu banyak';

  @override
  String get calorieStatusHigh => 'Kalori tinggi!';

  @override
  String get calorieStatusExceeded => 'Melebihi target! Perlu olahraga!';

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
  String get clothingPresetDefault => 'Default (Abu-abu)';

  @override
  String get clothingPresetPinkBlack => 'Pink/Hitam';

  @override
  String get clothingPresetWhiteNavy => 'Putih/Navy';

  @override
  String get clothingPresetMintCharcoal => 'Mint/Charcoal';

  @override
  String get clothingPresetLavenderPurple => 'Lavender/Ungu';

  @override
  String get clothingPresetCoralGray => 'Coral/Abu-abu';

  @override
  String get timezoneSettings => 'Pengaturan Zona Waktu';

  @override
  String get selectTimezone => 'Pilih Zona Waktu';

  @override
  String get timezoneNotificationAdjustment =>
      'Waktu notifikasi akan disesuaikan sesuai zona waktu yang dipilih.';

  @override
  String timezoneSet(String timezone) {
    return 'Zona waktu telah diatur ke $timezone.';
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
  String get permissionDiagnosis => 'Diagnosis Izin';

  @override
  String get permissionDiagnosisResults => 'Hasil Diagnosis Izin';

  @override
  String get clearPermissionCache => 'Hapus Cache Izin';

  @override
  String get permissionCacheCleared =>
      'Cache izin telah dihapus. Silakan mulai ulang aplikasi.';

  @override
  String get syncingHealthData => 'Menyinkronkan data kesehatan...';

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
