import 'package:flutter/material.dart';

/// 보충제 알람 정보
class SupplementAlarm {
  String name;
  TimeOfDay time;
  bool enabled;

  SupplementAlarm({
    required this.name,
    required this.time,
    this.enabled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hour': time.hour,
      'minute': time.minute,
      'enabled': enabled,
    };
  }

  factory SupplementAlarm.fromMap(Map<String, dynamic> map) {
    return SupplementAlarm(
      name: map['name'] as String,
      time: TimeOfDay(
        hour: map['hour'] as int,
        minute: map['minute'] as int,
      ),
      enabled: map['enabled'] as bool? ?? false,
    );
  }
}

/// 알림 설정 데이터 모델
class NotificationSettings {
  // 식사 알람
  bool breakfastEnabled;
  TimeOfDay breakfastTime;

  bool lunchEnabled;
  TimeOfDay lunchTime;

  bool dinnerEnabled;
  TimeOfDay dinnerTime;

  // 간식 알람
  bool morningSnackEnabled;
  TimeOfDay morningSnackTime;

  bool afternoonSnackEnabled;
  TimeOfDay afternoonSnackTime;

  // 운동 알람
  bool exerciseEnabled;
  TimeOfDay exerciseTime;
  List<int> exerciseDays; // 1=월, 2=화, ..., 7=일

  // 체중 측정 알람
  bool weightEnabled;
  TimeOfDay weightTime;

  // 비타민/보충제 알람 (최대 3개)
  List<SupplementAlarm> supplements;

  // 수분 섭취 관리
  bool waterReminderEnabled;
  int waterInterval; // 분 단위
  TimeOfDay waterStartTime;
  TimeOfDay waterEndTime;
  int dailyWaterGoal; // ml

  NotificationSettings({
    this.breakfastEnabled = false,
    this.breakfastTime = const TimeOfDay(hour: 7, minute: 0),
    this.lunchEnabled = false,
    this.lunchTime = const TimeOfDay(hour: 12, minute: 0),
    this.dinnerEnabled = false,
    this.dinnerTime = const TimeOfDay(hour: 18, minute: 0),
    this.morningSnackEnabled = false,
    this.morningSnackTime = const TimeOfDay(hour: 10, minute: 30),
    this.afternoonSnackEnabled = false,
    this.afternoonSnackTime = const TimeOfDay(hour: 15, minute: 30),
    this.exerciseEnabled = false,
    this.exerciseTime = const TimeOfDay(hour: 19, minute: 0),
    List<int>? exerciseDays,
    this.weightEnabled = false,
    this.weightTime = const TimeOfDay(hour: 6, minute: 30),
    List<SupplementAlarm>? supplements,
    this.waterReminderEnabled = false,
    this.waterInterval = 120,
    this.waterStartTime = const TimeOfDay(hour: 8, minute: 0),
    this.waterEndTime = const TimeOfDay(hour: 22, minute: 0),
    this.dailyWaterGoal = 2000,
  })  : exerciseDays = exerciseDays ?? [1, 3, 5], // 기본: 월수금
        supplements = supplements ?? [];

  Map<String, dynamic> toMap() {
    return {
      'breakfastEnabled': breakfastEnabled,
      'breakfastHour': breakfastTime.hour,
      'breakfastMinute': breakfastTime.minute,
      'lunchEnabled': lunchEnabled,
      'lunchHour': lunchTime.hour,
      'lunchMinute': lunchTime.minute,
      'dinnerEnabled': dinnerEnabled,
      'dinnerHour': dinnerTime.hour,
      'dinnerMinute': dinnerTime.minute,
      'morningSnackEnabled': morningSnackEnabled,
      'morningSnackHour': morningSnackTime.hour,
      'morningSnackMinute': morningSnackTime.minute,
      'afternoonSnackEnabled': afternoonSnackEnabled,
      'afternoonSnackHour': afternoonSnackTime.hour,
      'afternoonSnackMinute': afternoonSnackTime.minute,
      'exerciseEnabled': exerciseEnabled,
      'exerciseHour': exerciseTime.hour,
      'exerciseMinute': exerciseTime.minute,
      'exerciseDays': exerciseDays.join(','),
      'weightEnabled': weightEnabled,
      'weightHour': weightTime.hour,
      'weightMinute': weightTime.minute,
      'supplements': supplements.map((s) => s.toMap()).toList(),
      'waterReminderEnabled': waterReminderEnabled,
      'waterInterval': waterInterval,
      'waterStartHour': waterStartTime.hour,
      'waterStartMinute': waterStartTime.minute,
      'waterEndHour': waterEndTime.hour,
      'waterEndMinute': waterEndTime.minute,
      'dailyWaterGoal': dailyWaterGoal,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      breakfastEnabled: map['breakfastEnabled'] as bool? ?? false,
      breakfastTime: TimeOfDay(
        hour: map['breakfastHour'] as int? ?? 7,
        minute: map['breakfastMinute'] as int? ?? 0,
      ),
      lunchEnabled: map['lunchEnabled'] as bool? ?? false,
      lunchTime: TimeOfDay(
        hour: map['lunchHour'] as int? ?? 12,
        minute: map['lunchMinute'] as int? ?? 0,
      ),
      dinnerEnabled: map['dinnerEnabled'] as bool? ?? false,
      dinnerTime: TimeOfDay(
        hour: map['dinnerHour'] as int? ?? 18,
        minute: map['dinnerMinute'] as int? ?? 0,
      ),
      morningSnackEnabled: map['morningSnackEnabled'] as bool? ?? false,
      morningSnackTime: TimeOfDay(
        hour: map['morningSnackHour'] as int? ?? 10,
        minute: map['morningSnackMinute'] as int? ?? 30,
      ),
      afternoonSnackEnabled: map['afternoonSnackEnabled'] as bool? ?? false,
      afternoonSnackTime: TimeOfDay(
        hour: map['afternoonSnackHour'] as int? ?? 15,
        minute: map['afternoonSnackMinute'] as int? ?? 30,
      ),
      exerciseEnabled: map['exerciseEnabled'] as bool? ?? false,
      exerciseTime: TimeOfDay(
        hour: map['exerciseHour'] as int? ?? 19,
        minute: map['exerciseMinute'] as int? ?? 0,
      ),
      exerciseDays: () {
        final daysStr = map['exerciseDays'] as String?;
        if (daysStr == null || daysStr.isEmpty) {
          return [1, 3, 5]; // 기본값
        }
        return daysStr.split(',').map((e) => int.parse(e)).toList();
      }(),
      weightEnabled: map['weightEnabled'] as bool? ?? false,
      weightTime: TimeOfDay(
        hour: map['weightHour'] as int? ?? 6,
        minute: map['weightMinute'] as int? ?? 30,
      ),
      supplements: (map['supplements'] as List?)
              ?.map((s) => SupplementAlarm.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      waterReminderEnabled: map['waterReminderEnabled'] as bool? ?? false,
      waterInterval: map['waterInterval'] as int? ?? 120,
      waterStartTime: TimeOfDay(
        hour: map['waterStartHour'] as int? ?? 8,
        minute: map['waterStartMinute'] as int? ?? 0,
      ),
      waterEndTime: TimeOfDay(
        hour: map['waterEndHour'] as int? ?? 22,
        minute: map['waterEndMinute'] as int? ?? 0,
      ),
      dailyWaterGoal: map['dailyWaterGoal'] as int? ?? 2000,
    );
  }
}
