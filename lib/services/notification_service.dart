import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

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
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

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

    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(time.hour, time.minute);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'vita_buddy_channel',
      'VitaBuddy 알림',
      channelDescription: '식사, 운동, 체중 측정 등 건강 관리 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
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

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'exercise_channel',
        '운동 알림',
        channelDescription: '운동 시간 알림',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
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
      title: '$supplementName 복용 시간입니다! 💊',
      body: '건강 관리 잊지 마세요. 꾸준함이 중요해요!',
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
      await flutterLocalNotificationsPlugin.cancel(NotificationIds.waterBase + i);
    }

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    int alarmIndex = 0;
    for (int minutes = startMinutes;
        minutes <= endMinutes && alarmIndex < 20;
        minutes += intervalMinutes) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;

      await scheduleDailyNotification(
        id: NotificationIds.waterBase + alarmIndex,
        title: '물 마실 시간이에요! 💧',
        body: '건강을 위해 물 한 잔 어떠세요?',
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
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'general_notification_channel',
      '일반 알림',
      channelDescription: '일반 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
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
  Future<void> setupMealPatternNotifications(Map<String, dynamic> mealPattern) async {
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
            body: '건강한 간식으로 에너지를 충전하세요!',
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
      return '좋은 아침이에요! ☀️';
    } else if (normalized.contains('점심') || normalized.contains('lunch')) {
      return '점심 시간이에요! 🍱';
    } else if (normalized.contains('저녁') || normalized.contains('dinner')) {
      return '저녁 식사 시간이에요! 🌙';
    } else if (normalized.contains('브런치') || normalized.contains('brunch')) {
      return '브런치 시간이에요! 🥞';
    } else {
      return '$mealName 시간이에요! 🍽️';
    }
  }
  
  /// 식사 타입에 따른 알림 내용 생성
  String _getMealBody(String mealName) {
    final normalized = mealName.toLowerCase();
    
    if (normalized.contains('아침') || normalized.contains('breakfast')) {
      return '영양 가득한 아침 식사로 활기찬 하루를 시작하세요!';
    } else if (normalized.contains('점심') || normalized.contains('lunch')) {
      return '균형 잡힌 점심으로 오후 활력을 채워보세요!';
    } else if (normalized.contains('저녁') || normalized.contains('dinner')) {
      return '건강한 저녁 식사로 하루를 마무리하세요!';
    } else {
      return '맛있고 건강한 식사를 즐기세요!';
    }
  }
  
  /// 간식 타입에 따른 알림 제목 생성
  String _getSnackTitle(String snackType) {
    if (snackType == 'morning') {
      return '오전 간식 시간이에요! 🍎';
    } else {
      return '오후 간식 시간이에요! 🥨';
    }
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
      title: title ?? '체중 측정 시간입니다! ⚖️',
      body: body ?? '오늘의 몸무게를 기록하고 건강 목표를 확인해  보세요.',
      time: TimeOfDay(hour: hour, minute: minute),
    );
  }

  // 칼로리 목표 초과 알림
  Future<void> showCalorieOverLimitNotification({
    required double currentCalories,
    required double dailyGoal,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
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

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    final overAmount = (currentCalories - dailyGoal).round();

    await flutterLocalNotificationsPlugin.show(
      998,
      '칼로리 목표 초과 ⚠️',
      '오늘 ${overAmount}kcal 초과했습니다. 건강한 식단을 유지해보세요!',
      platformChannelSpecifics,
    );
  }

  // 심야 야식 경고 알림
  Future<void> showLateNightWarning() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
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

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      996, // 고유 ID
      '지금 드시나요? 🌙',
      '늦은 밤 식사는 수면과 소화에 좋지 않아요. 가볍게 드시는 건 어떨까요?',
      platformChannelSpecifics,
    );
  }

  // 칼로리 목표 달성 축하 알림
  Future<void> showCalorieGoalAchievedNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
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

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      999,
      '축하합니다! 🎉',
      '오늘 칼로리 목표를 성공적으로 달성했습니다!',
      platformChannelSpecifics,
    );
  }

  // 동기부여 알림 (랜덤 시간)
  Future<void> scheduleMotivationalReminder() async {
    await flutterLocalNotificationsPlugin.cancel(997);

    final now = tz.TZDateTime.now(tz.local);
    final randomHours =
        2 + (DateTime.now().millisecondsSinceEpoch % 3);
    final scheduledDate = now.add(Duration(hours: randomHours));

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
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

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    final messages = [
      '건강한 하루를 보내고 있나요? 💪',
      '물 한 컵 어떠세요? 🥤',
      '가벼운 스트레칭으로 상쾌함을 느껴보세요! 🤸‍♀️',
      '오늘도 건강 관리 화이팅! 🌟',
      '균형 잡힌 식단이 건강의 시작입니다! 🥗',
    ];

    final randomMessage =
        messages[DateTime.now().millisecondsSinceEpoch % messages.length];

    await flutterLocalNotificationsPlugin.zonedSchedule(
      997,
      'VitaBuddy의 응원 💝',
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

  /// 활성화된 알림 목록 조회
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
