import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

/// 알람 메시지 현지화 헬퍼 클래스
/// NotificationService는 context가 없으므로 플랫폼 로케일을 직접 감지하여 현지화
class NotificationLocalizations {
  static String _currentLang = 'ko';

  static void setLanguageCode(String code) {
    _currentLang = code;
  }

  static String getCurrentLanguageCode() {
    return _currentLang;
  }

  static String getCalorieOverTitle() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '칼로리 목표 초과 ⚠️';
      case 'ja':
        return 'カロリー目標超過 ⚠️';
      case 'id':
        return 'Kalori Melebihi Target ⚠️';
      case 'ms':
        return 'Kalori Melebihi Sasaran ⚠️';
      default:
        return 'Calorie Goal Exceeded ⚠️';
    }
  }

  static String getCalorieOverBody(int overAmount) {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '오늘 ${overAmount}kcal 초과했습니다. 건강한 식단을 유지해보세요!';
      case 'ja':
        return '今日は${overAmount}kcal超過しました。健康的な食事を維持しましょう！';
      case 'id':
        return 'Hari ini melebihi ${overAmount}kcal. Cobalah untuk menjaga pola makan yang sehat!';
      case 'ms':
        return 'Hari ini melebihi ${overAmount}kcal. Cuba jaga diet yang sihat!';
      default:
        return 'You\'ve exceeded your calorie goal by ${overAmount}kcal today. Try to maintain a healthy diet!';
    }
  }

  static String getLateNightTitle() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '지금 드시나요? 🌙';
      case 'ja':
        return '今食べますか？ 🌙';
      case 'id':
        return 'Sedang Makan? 🌙';
      case 'ms':
        return 'Sedang Makan? 🌙';
      default:
        return 'Eating Now? 🌙';
    }
  }

  static String getLateNightBody() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '늦은 밤 식사는 수면과 소화에 좋지 않아요. 가볍게 드시는 건 어떨까요?';
      case 'ja':
        return '深夜の食事は睡眠と消化に良くありません。軽く食べるのはいかがですか？';
      case 'id':
        return 'Makan larut malam tidak baik untuk tidur dan pencernaan. Bagaimana jika makan ringan?';
      case 'ms':
        return 'Makan larut malam tidak baik untuk tidur dan penghadaman. Bagaimana jika makan ringan?';
      default:
        return 'Late-night eating isn\'t good for sleep and digestion. How about having something light?';
    }
  }

  static String getGoalAchievedTitle() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '축하합니다! 🎉';
      case 'ja':
        return 'おめでとうございます！ 🎉';
      case 'id':
        return 'Selamat! 🎉';
      case 'ms':
        return 'Tahniah! 🎉';
      default:
        return 'Congratulations! 🎉';
    }
  }

  static String getGoalAchievedBody() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '오늘 칼로리 목표를 성공적으로 달성했습니다!';
      case 'ja':
        return '今日のカロリー目標を成功裏に達成しました！';
      case 'id':
        return 'Anda berhasil mencapai target kalori hari ini!';
      case 'ms':
        return 'Anda berjaya mencapai sasaran kalori hari ini!';
      default:
        return 'You\'ve successfully achieved your calorie goal today!';
    }
  }

  static String getMotivationTitle() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return 'VitaBuddy의 응원 💝';
      case 'ja':
        return 'VitaBuddyの応援 💝';
      case 'id':
        return 'Dukungan VitaBuddy 💝';
      case 'ms':
        return 'Sokongan VitaBuddy 💝';
      default:
        return 'VitaBuddy\'s Encouragement 💝';
    }
  }

  static List<String> getMotivationMessages() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return [
          "건강한 하루를 보내고 있나요? 💪",
          "물 한 컵 어떠세요? 🥤",
          "가벼운 스트레칭으로 상쾌함을 느껴보세요! 🤸‍♀️",
          "오늘도 건강 관리 화이팅! 🌟",
          "균형 잡힌 식단이 건강의 시작입니다! 🥗",
        ];
      case 'ja':
        return [
          "健康的な一日を過ごしていますか？ 💪",
          "水を一杯いかがですか？ 🥤",
          "軽いストレッチで爽快感を味わってみてください！ 🤸‍♀️",
          "今日も健康管理ファイッティング！ 🌟",
          "バランスの取れた食事は健康の始まりです！ 🥗",
        ];
      case 'id':
        return [
          "Apakah Anda menjalani hari yang sehat? 💪",
          "Bagaimana dengan segelas air? 🥤",
          "Coba rasakan kesegaran dengan peregangan ringan! 🤸‍♀️",
          "Semangat mengelola kesehatan hari ini juga! 🌟",
          "Diet seimbang adalah awal dari kesehatan! 🥗",
        ];
      case 'ms':
        return [
          "Adakah anda menjalani hari yang sihat? 💪",
          "Bagaimana dengan secawan air? 🥤",
          "Cuba rasai kesegaran dengan regangan ringan! 🤸‍♀️",
          "Semangat mengurus kesihatan hari ini juga! 🌟",
          "Diet seimbang adalah permulaan kesihatan! 🥗",
        ];
      default:
        return [
          "Are you having a healthy day? 💪",
          "How about a glass of water? 🥤",
          "Try feeling refreshed with some light stretching! 🤸‍♀️",
          "Keep up the good work with health management today too! 🌟",
          "A balanced diet is the beginning of health! 🥗",
        ];
    }
  }

  static String getLowCalorieTitle(bool isVeryLow) {
    final lang = getCurrentLanguageCode();
    if (isVeryLow) {
      switch (lang) {
        case 'ko':
          return '⚠️ 에너지가 매우 부족해요!';
        case 'ja':
          return '⚠️ エネルギーが非常に不足しています！';
        case 'id':
          return '⚠️ Energi sangat kurang!';
        case 'ms':
          return '⚠️ Tenaga sangat kurang!';
        default:
          return '⚠️ Energy is very low!';
      }
    } else {
      switch (lang) {
        case 'ko':
          return '💡 에너지가 부족해요';
        case 'ja':
          return '💡 エネルギーが不足しています';
        case 'id':
          return '💡 Energi kurang';
        case 'ms':
          return '💡 Tenaga kurang';
        default:
          return '💡 Energy is low';
      }
    }
  }

  static String getLowCalorieBody(int current, int percentage, bool isVeryLow) {
    final lang = getCurrentLanguageCode();
    if (isVeryLow) {
      switch (lang) {
        case 'ko':
          return '현재 ${current} kcal (${percentage}%). 식사가 필요해요!';
        case 'ja':
          return '現在${current} kcal (${percentage}%)。食事が必要です！';
        case 'id':
          return 'Saat ini ${current} kcal (${percentage}%). Perlu makan!';
        case 'ms':
          return 'Kini ${current} kcal (${percentage}%). Perlu makan!';
        default:
          return 'Currently ${current} kcal (${percentage}%). You need to eat!';
      }
    } else {
      switch (lang) {
        case 'ko':
          return '현재 ${current} kcal (${percentage}%). 간식을 드시는 건 어떨까요?';
        case 'ja':
          return '現在${current} kcal (${percentage}%)。おやつはいかがですか？';
        case 'id':
          return 'Saat ini ${current} kcal (${percentage}%). Bagaimana dengan camilan?';
        case 'ms':
          return 'Kini ${current} kcal (${percentage}%). Bagaimana dengan makanan ringan?';
        default:
          return 'Currently ${current} kcal (${percentage}%). How about a snack?';
      }
    }
  }

  static String getSupplementTitle(String supplementName) {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '$supplementName 복용 시간입니다! 💊';
      case 'ja':
        return '$supplementNameの服用時間です！ 💊';
      case 'id':
        return 'Waktunya minum $supplementName! 💊';
      case 'ms':
        return 'Masa untuk ambil $supplementName! 💊';
      default:
        return 'Time to take $supplementName! 💊';
    }
  }

  static String getSupplementBody() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '건강 관리 잊지 마세요. 꾸준함이 중요해요!';
      case 'ja':
        return '健康管理を忘れずに。継続が大切です！';
      case 'id':
        return 'Jangan lupa kelola kesehatan. Konsistensi itu penting!';
      case 'ms':
        return 'Jangan lupa urus kesihatan. Konsistensi itu penting!';
      default:
        return 'Don\'t forget health management. Consistency is important!';
    }
  }

  static String getWaterTitle() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '물 마실 시간이에요! 💧';
      case 'ja':
        return '水を飲む時間です！ 💧';
      case 'id':
        return 'Waktunya minum air! 💧';
      case 'ms':
        return 'Masa untuk minum air! 💧';
      default:
        return 'Time to drink water! 💧';
    }
  }

  static String getWaterBody() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '건강을 위해 물 한 잔 어떠세요?';
      case 'ja':
        return '健康のために水を一杯いかがですか？';
      case 'id':
        return 'Bagaimana dengan segelas air untuk kesehatan?';
      case 'ms':
        return 'Bagaimana dengan segelas air untuk kesihatan?';
      default:
        return 'How about a glass of water for your health?';
    }
  }

  static String getMealTitle(String mealType) {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        switch (mealType) {
          case 'breakfast':
            return '좋은 아침이에요! ☀️';
          case 'lunch':
            return '점심 시간이에요! 🍱';
          case 'dinner':
            return '저녁 식사 시간이에요! 🌙';
          case 'brunch':
            return '브런치 시간이에요! 🥞';
          default:
            return '$mealType 시간이에요! 🍽️';
        }
      case 'ja':
        switch (mealType) {
          case 'breakfast':
            return 'おはようございます！ ☀️';
          case 'lunch':
            return '昼食の時間です！ 🍱';
          case 'dinner':
            return '夕食の時間です！ 🌙';
          case 'brunch':
            return 'ブランチの時間です！ 🥞';
          default:
            return '$mealTypeの時間です！ 🍽️';
        }
      case 'id':
        switch (mealType) {
          case 'breakfast':
            return 'Selamat pagi! ☀️';
          case 'lunch':
            return 'Waktunya makan siang! 🍱';
          case 'dinner':
            return 'Waktunya makan malam! 🌙';
          case 'brunch':
            return 'Waktunya brunch! 🥞';
          default:
            return 'Waktunya $mealType! 🍽️';
        }
      case 'ms':
        switch (mealType) {
          case 'breakfast':
            return 'Selamat pagi! ☀️';
          case 'lunch':
            return 'Masa makan tengah hari! 🍱';
          case 'dinner':
            return 'Masa makan malam! 🌙';
          case 'brunch':
            return 'Masa brunch! 🥞';
          default:
            return 'Masa $mealType! 🍽️';
        }
      default:
        switch (mealType) {
          case 'breakfast':
            return 'Good morning! ☀️';
          case 'lunch':
            return 'Lunch time! 🍱';
          case 'dinner':
            return 'Dinner time! 🌙';
          case 'brunch':
            return 'Brunch time! 🥞';
          default:
            return '$mealType time! 🍽️';
        }
    }
  }

  static String getMealBody(String mealType) {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        switch (mealType) {
          case 'breakfast':
            return '영양 가득한 아침 식사로 활기찬 하루를 시작하세요!';
          case 'lunch':
            return '균형 잡힌 점심으로 오후 활력을 채워보세요!';
          case 'dinner':
            return '건강한 저녁 식사로 하루를 마무리하세요!';
          default:
            return '맛있고 건강한 식사를 즐기세요!';
        }
      case 'ja':
        switch (mealType) {
          case 'breakfast':
            return '栄養たっぷりの朝食で活気ある一日を始めましょう！';
          case 'lunch':
            return 'バランスの取れた昼食で午後の活力をチャージしましょう！';
          case 'dinner':
            return '健康的な夕食で一日を締めくくりましょう！';
          default:
            return 'おいしく健康的な食事を楽しんでください！';
        }
      case 'id':
        switch (mealType) {
          case 'breakfast':
            return 'Mulai hari yang energik dengan sarapan bergizi!';
          case 'lunch':
            return 'Isi energi sore dengan makan siang seimbang!';
          case 'dinner':
            return 'Akhiri hari dengan makan malam sehat!';
          default:
            return 'Nikmati makanan yang lezat dan sehat!';
        }
      case 'ms':
        switch (mealType) {
          case 'breakfast':
            return 'Mulakan hari yang bertenaga dengan sarapan berkhasiat!';
          case 'lunch':
            return 'Isi tenaga petang dengan makan tengah hari seimbang!';
          case 'dinner':
            return 'akhiri hari dengan makan malam sihat!';
          default:
            return 'Nikmati makanan yang sedap dan sihat!';
        }
      default:
        switch (mealType) {
          case 'breakfast':
            return 'Start your day with a nutritious breakfast!';
          case 'lunch':
            return 'Fuel your afternoon with a balanced lunch!';
          case 'dinner':
            return 'End your day with a healthy dinner!';
          default:
            return 'Enjoy delicious and healthy food!';
        }
    }
  }

  static String getSnackTitle(String snackType) {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return snackType == 'morning' ? '오전 간식 시간이에요! 🍎' : '오후 간식 시간이에요! 🥨';
      case 'ja':
        return snackType == 'morning' ? '朝のおやつ時間です！ 🍎' : '午後のおやつ時間です！ 🥨';
      case 'id':
        return snackType == 'morning'
            ? 'Waktunya camilan pagi! 🍎'
            : 'Waktunya camilan sore! 🥨';
      case 'ms':
        return snackType == 'morning'
            ? 'Masa makanan ringan pagi! 🍎'
            : 'Masa makanan ringan petang! 🥨';
      default:
        return snackType == 'morning'
            ? 'Morning snack time! 🍎'
            : 'Afternoon snack time! 🥨';
    }
  }

  static String getSnackBody() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '건강한 간식으로 에너지를 충전하세요!';
      case 'ja':
        return '健康的なおやつでエネルギーをチャージしましょう！';
      case 'id':
        return 'Isi energi dengan camilan sehat!';
      case 'ms':
        return 'Isi tenaga dengan makanan ringan sihat!';
      default:
        return 'Recharge with healthy snacks!';
    }
  }

  static String getWeightTitle() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '체중 측정 시간입니다! ⚖️';
      case 'ja':
        return '体重測定の時間です！ ⚖️';
      case 'id':
        return 'Waktunya ukur berat badan! ⚖️';
      case 'ms':
        return 'Masa untuk ukur berat badan! ⚖️';
      default:
        return 'Time to weigh yourself! ⚖️';
    }
  }

  static String getWeightBody() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '오늘의 몸무게를 기록하고 건강 목표를 확인해 보세요.';
      case 'ja':
        return '今日の体重を記録し、健康目標を確認しましょう。';
      case 'id':
        return 'Catat berat badan hari ini dan periksa target kesehatan Anda.';
      case 'ms':
        return 'Rekod berat badan hari ini dan semak sasaran kesihatan anda.';
      default:
        return 'Record today\'s weight and check your health goals.';
    }
  }

  static String getExerciseTitle() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '운동 시간입니다! 🏃';
      case 'ja':
        return '運動時間です！ 🏃';
      case 'id':
        return 'Waktunya olahraga! 🏃';
      case 'ms':
        return 'Masa untuk bersenam! 🏃';
      default:
        return 'Time to exercise! 🏃';
    }
  }

  static String getExerciseBody() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '오늘의 칼로리를 태워볼까요?';
      case 'ja':
        return '今日のカロリーを燃やしてみましょうか？';
      case 'id':
        return 'Bagaimana jika membakar kalori hari ini?';
      case 'ms':
        return 'Bagaimana jika membakar kalori hari ini?';
      default:
        return 'How about burning some calories today?';
    }
  }

  static String getMainChannelDescription() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '식사, 운동, 체중 측정 등 건강 관리 알림';
      case 'ja':
        return '食事、運動、体重測定などの健康管理通知';
      case 'id':
        return 'Notifikasi manajemen kesehatan seperti makan, olahraga, pengukuran berat badan';
      case 'ms':
        return 'Pemberitahuan pengurusan kesihatan seperti makan, senaman, pengukuran berat badan';
      default:
        return 'Health management notifications such as meals, exercise, weight measurement';
    }
  }

  static String getExerciseChannelDescription() {
    final lang = getCurrentLanguageCode();
    switch (lang) {
      case 'ko':
        return '운동 시간 알림';
      case 'ja':
        return '運動時間通知';
      case 'id':
        return 'Notifikasi waktu olahraga';
      case 'ms':
        return 'Pemberitahuan masa senaman';
      default:
        return 'Exercise time notifications';
    }
  }
}

/// 알람 ID 상수 정의
class NotificationIds {
  static const int breakfast = 1;
  static const int lunch = 2;
  static const int dinner = 3;
  static const int morningSnack = 4;
  static const int afternoonSnack = 5;
  static const int exercise = 6;
  static const int weight = 7;
  static const int supplementBase = 10; // 10~12 (최대 3개)
  static const int waterBase = 100; // 100~119 (최대 20개)
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  factory NotificationService() => _instance;

  NotificationService._internal();

  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin {
    _flutterLocalNotificationsPlugin ??= FlutterLocalNotificationsPlugin();
    return _flutterLocalNotificationsPlugin!;
  }

  Future<void> initialize() async {
    // 타임존 데이터 초기화
    tz.initializeTimeZones();

    // 언어 설정 초기화
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('app_locale') ?? 'ko';
    NotificationLocalizations.setLanguageCode(langCode);

    // 알림 권한 요청
    await _requestPermissions();

    // 알림 초기화 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  /// 타임존 설정 (동적)
  Future<void> setTimezone(String timezoneName) async {
    try {
      final location = tz.getLocation(timezoneName);
      tz.setLocalLocation(location);
      developer.log('✅ 타임존 설정: $timezoneName');
    } catch (e) {
      developer.log('❌ 타임존 설정 실패: $e');
      // 실패 시 기본 타임존으로 폴백
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  /// 현재 설정된 타임존 이름 반환
  String getCurrentTimezoneName() {
    return tz.local.name;
  }

  /// 사용 가능한 타임존 목록 반환
  List<String> getAvailableTimezones() {
    // 주요 타임존들만 필터링하여 반환
    final majorTimezones = [
      'UTC',
      'America/New_York', // EST/EDT
      'America/Los_Angeles', // PST/PDT
      'America/Chicago', // CST/CDT
      'America/Denver', // MST/MDT
      'Europe/London', // GMT/BST
      'Europe/Paris', // CET/CEST
      'Europe/Berlin', // CET/CEST
      'Asia/Tokyo', // JST
      'Asia/Jakarta', // WIB (인도네시아)
      'Asia/Kuala_Lumpur', // MST (말레이시아)
      'Asia/Seoul', // KST
      'Asia/Taipei', // CST
      'Australia/Sydney', // AEST/AEDT
      'Pacific/Auckland', // NZST/NZDT
    ];

    // 실제 존재하는 타임존만 필터링
    return majorTimezones.where((tzName) {
      try {
        tz.getLocation(tzName);
        return true;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print('알림 클릭됨: ${response.payload}');
  }

  /// 매일 반복 알람 예약 (식사, 간식, 체중 등)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    await flutterLocalNotificationsPlugin.cancel(id);

    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(
      time.hour,
      time.minute,
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'vita_buddy_channel',
          'VitaBuddy 알림',
          channelDescription:
              NotificationLocalizations.getMainChannelDescription(),
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// 요일 선택 반복 알람 (운동 알람용)
  Future<void> scheduleWeeklyNotification({
    required int baseId,
    required String title,
    required String body,
    required TimeOfDay time,
    required List<int> weekdays, // 1=월, 2=화, ..., 7=일
    String? payload,
  }) async {
    // 기존 알람 취소 (최대 7개)
    for (int i = 0; i < 7; i++) {
      await flutterLocalNotificationsPlugin.cancel(baseId + i);
    }

    for (int i = 0; i < weekdays.length; i++) {
      final weekday = weekdays[i];
      final notificationId = baseId + i;

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // 해당 요일까지 날짜 조정
      while (scheduledDate.weekday != weekday) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'exercise_channel',
            '운동 알림',
            channelDescription:
                NotificationLocalizations.getExerciseChannelDescription(),
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
    }
  }

  /// 비타민/보충제 알람
  Future<void> scheduleSupplementNotification({
    required int id,
    required String supplementName,
    required TimeOfDay time,
  }) async {
    await scheduleDailyNotification(
      id: id,
      title: NotificationLocalizations.getSupplementTitle(supplementName),
      body: NotificationLocalizations.getSupplementBody(),
      time: time,
      payload: 'supplement_$id',
    );
  }

  /// 수분 섭취 알람 (여러 개)
  Future<void> scheduleWaterReminders({
    required TimeOfDay start,
    required TimeOfDay end,
    required int intervalMinutes,
  }) async {
    // 기존 물 알람 모두 취소
    for (int i = 0; i < 20; i++) {
      await flutterLocalNotificationsPlugin.cancel(
        NotificationIds.waterBase + i,
      );
    }

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    int alarmIndex = 0;
    for (
      int minutes = startMinutes;
      minutes <= endMinutes && alarmIndex < 20;
      minutes += intervalMinutes
    ) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;

      await scheduleDailyNotification(
        id: NotificationIds.waterBase + alarmIndex,
        title: NotificationLocalizations.getWaterTitle(),
        body: NotificationLocalizations.getWaterBody(),
        time: TimeOfDay(hour: hour, minute: minute),
        payload: 'water_reminder',
      );

      alarmIndex++;
    }
  }

  /// 알람 취소
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// 즉시 알림 표시 (일반용)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'general_notification_channel',
          '일반 알림',
          channelDescription: '일반 알림',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// 식사 패턴 기반 알림 일괄 설정
  Future<void> setupMealPatternNotifications(
    Map<String, dynamic> mealPattern,
  ) async {
    // 1. 기존 식사 알림 모두 취소
    await cancelNotification(NotificationIds.breakfast);
    await cancelNotification(NotificationIds.lunch);
    await cancelNotification(NotificationIds.dinner);
    await cancelNotification(NotificationIds.morningSnack);
    await cancelNotification(NotificationIds.afternoonSnack);

    // 2. mealPattern에서 enabled된 식사만 알림 등록
    final meals = mealPattern['meals'] as List?;
    if (meals != null) {
      for (var meal in meals) {
        if (meal['enabled'] == true) {
          final mealName = meal['name'] as String;
          final hour = meal['hour'] as int;
          final minute = meal['minute'] as int;

          // 동적 ID 생성 (해시 기반)
          final notificationId = mealName.hashCode % 900 + 20; // 20~919 범위

          await scheduleDailyNotification(
            id: notificationId,
            title: _getMealTitle(mealName),
            body: _getMealBody(mealName),
            time: TimeOfDay(hour: hour, minute: minute),
            payload: 'meal_$mealName',
          );
        }
      }
    }

    // 3. 간식 알림 설정 (있다면)
    final snacks = mealPattern['snacks'] as List?;
    if (snacks != null) {
      for (var snack in snacks) {
        if (snack['enabled'] == true) {
          final snackType = snack['type'] as String;
          final hour = snack['hour'] as int;
          final minute = snack['minute'] as int;

          final notificationId = snackType == 'morning'
              ? NotificationIds.morningSnack
              : NotificationIds.afternoonSnack;

          await scheduleDailyNotification(
            id: notificationId,
            title: _getSnackTitle(snackType),
            body: NotificationLocalizations.getSnackBody(),
            time: TimeOfDay(hour: hour, minute: minute),
            payload: 'snack_$snackType',
          );
        }
      }
    }
  }

  /// 식사 타입에 따른 알림 제목 생성
  String _getMealTitle(String mealName) {
    final normalized = mealName.toLowerCase();

    if (normalized.contains('아침') || normalized.contains('breakfast')) {
      return NotificationLocalizations.getMealTitle('breakfast');
    } else if (normalized.contains('점심') || normalized.contains('lunch')) {
      return NotificationLocalizations.getMealTitle('lunch');
    } else if (normalized.contains('저녁') || normalized.contains('dinner')) {
      return NotificationLocalizations.getMealTitle('dinner');
    } else if (normalized.contains('브런치') || normalized.contains('brunch')) {
      return NotificationLocalizations.getMealTitle('brunch');
    } else {
      return NotificationLocalizations.getMealTitle('meal');
    }
  }

  /// 식사 타입에 따른 알림 내용 생성
  String _getMealBody(String mealName) {
    final normalized = mealName.toLowerCase();

    if (normalized.contains('아침') || normalized.contains('breakfast')) {
      return NotificationLocalizations.getMealBody('breakfast');
    } else if (normalized.contains('점심') || normalized.contains('lunch')) {
      return NotificationLocalizations.getMealBody('lunch');
    } else if (normalized.contains('저녁') || normalized.contains('dinner')) {
      return NotificationLocalizations.getMealBody('dinner');
    } else {
      return NotificationLocalizations.getMealBody('meal');
    }
  }

  /// 간식 타입에 따른 알림 제목 생성
  String _getSnackTitle(String snackType) {
    return NotificationLocalizations.getSnackTitle(snackType);
  }

  // 체중 체크 알림 예약
  Future<void> scheduleWeightCheckReminder({
    required int hour,
    required int minute,
    String? title,
    String? body,
  }) async {
    await scheduleDailyNotification(
      id: NotificationIds.weight,
      title: title ?? NotificationLocalizations.getWeightTitle(),
      body: body ?? NotificationLocalizations.getWeightBody(),
      time: TimeOfDay(hour: hour, minute: minute),
    );
  }

  // 칼로리 목표 초과 알림
  Future<void> showCalorieOverLimitNotification({
    required double currentCalories,
    required double dailyGoal,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'calorie_alert_channel',
          '칼로리 알림',
          channelDescription: '칼로리 목표 관련 알림',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    final overAmount = (currentCalories - dailyGoal).round();

    await flutterLocalNotificationsPlugin.show(
      998,
      NotificationLocalizations.getCalorieOverTitle(),
      NotificationLocalizations.getCalorieOverBody(overAmount),
      platformChannelSpecifics,
    );
  }

  // 심야 야식 경고 알림
  Future<void> showLateNightWarning() async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'late_night_channel',
          '심야 식사 알림',
          channelDescription: '늦은 시간 식사 시 건강 경고',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      996, // 고유 ID
      NotificationLocalizations.getLateNightTitle(),
      NotificationLocalizations.getLateNightBody(),
      platformChannelSpecifics,
    );
  }

  // 칼로리 목표 달성 축하 알림
  Future<void> showCalorieGoalAchievedNotification() async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'achievement_channel',
          '업적 알림',
          channelDescription: '건강 목표 달성 축하 알림',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      999,
      NotificationLocalizations.getGoalAchievedTitle(),
      NotificationLocalizations.getGoalAchievedBody(),
      platformChannelSpecifics,
    );
  }

  // 동기부여 알림 (랜덤 시간)
  Future<void> scheduleMotivationalReminder() async {
    await flutterLocalNotificationsPlugin.cancel(997);

    final now = tz.TZDateTime.now(tz.local);
    final randomHours = 2 + (DateTime.now().millisecondsSinceEpoch % 3);
    final scheduledDate = now.add(Duration(hours: randomHours));

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'motivation_channel',
          '동기부여 알림',
          channelDescription: '건강한 생활을 응원하는 알림',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    final randomMessage = _getRandomMotivationMessage();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      997,
      NotificationLocalizations.getMotivationTitle(),
      randomMessage,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 다음 알림 시간을 계산하는 헬퍼 메서드
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// 동기부여 메시지 랜덤 선택
  String _getRandomMotivationMessage() {
    final messages = NotificationLocalizations.getMotivationMessages();
    return messages[DateTime.now().millisecondsSinceEpoch % messages.length];
  }

  /// 활성화된 알림 목록 조회
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// 테스트용 알람 현지화 확인 메소드
  void testLocalization() {
    developer.log('🧪 현지화 테스트 시작');
    developer.log(
      '현재 로케일: ${NotificationLocalizations.getCurrentLanguageCode()}',
    );
    developer.log(
      '칼로리 부족 제목 (very low): ${NotificationLocalizations.getLowCalorieTitle(true)}',
    );
    developer.log(
      '칼로리 부족 제목 (low): ${NotificationLocalizations.getLowCalorieTitle(false)}',
    );
    developer.log(
      '칼로리 부족 내용: ${NotificationLocalizations.getLowCalorieBody(1500, 60, true)}',
    );
    developer.log('🧪 현지화 테스트 완료');
  }
}
