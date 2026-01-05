import 'package:flutter/material.dart';
import '../utils/meal_pattern_calorie_guide.dart';
import '../l10n/app_localizations.dart';

/// 칼로리 상태 (7단계)
///
/// 일일 목표 칼로리 대비 현재 섭취량 기준
enum CalorieStatus {
  /// 매우 낮음 (0-20%)
  veryLow,

  /// 낮음 (21-40%)
  low,

  /// 적정 하한 (41-60%)
  belowIdeal,

  /// 이상적 (61-80%)
  ideal,

  /// 약간 높음 (81-95%)
  slightlyHigh,

  /// 높음 (96-110%)
  high,

  /// 초과 (111%+)
  exceeded,
}

extension CalorieStatusExtension on CalorieStatus {
  /// 상태별 색상
  Color get color {
    switch (this) {
      case CalorieStatus.veryLow:
        return const Color(0xFFD32F2F); // Dark Red
      case CalorieStatus.low:
        return const Color(0xFFFF6F00); // Orange
      case CalorieStatus.belowIdeal:
        return const Color(0xFFFBC02D); // Yellow
      case CalorieStatus.ideal:
        return const Color(0xFF388E3C); // Green
      case CalorieStatus.slightlyHigh:
        return const Color(0xFF1976D2); // Blue
      case CalorieStatus.high:
        return const Color(0xFF7B1FA2); // Purple
      case CalorieStatus.exceeded:
        return const Color(0xFFB71C1C); // Very Dark Red
    }
  }

  /// 상태별 메시지 (현지화 키)
  String getLocalizedMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case CalorieStatus.veryLow:
        return l10n.calorieStatusVeryLow;
      case CalorieStatus.low:
        return l10n.calorieStatusLow;
      case CalorieStatus.belowIdeal:
        return l10n.calorieStatusBelowIdeal;
      case CalorieStatus.ideal:
        return l10n.calorieStatusIdeal;
      case CalorieStatus.slightlyHigh:
        return l10n.calorieStatusSlightlyHigh;
      case CalorieStatus.high:
        return l10n.calorieStatusHigh;
      case CalorieStatus.exceeded:
        return l10n.calorieStatusExceeded;
    }
  }

  /// 상태별 메시지 (하위 호환성 유지 - 한국어)
  @Deprecated('Use getLocalizedMessage(context) instead')
  String get message {
    switch (this) {
      case CalorieStatus.veryLow:
        return '배고파요... 식사가 필요해요!';
      case CalorieStatus.low:
        return '에너지가 부족해요';
      case CalorieStatus.belowIdeal:
        return '조금 더 먹어도 괜찮아요';
      case CalorieStatus.ideal:
        return '완벽해요! 좋은 상태예요';
      case CalorieStatus.slightlyHigh:
        return '조금 많이 먹었네요';
      case CalorieStatus.high:
        return '칼로리가 높아요!';
      case CalorieStatus.exceeded:
        return '목표 초과! 운동 필요해요!';
    }
  }

  /// 상태별 아이콘
  IconData get icon {
    switch (this) {
      case CalorieStatus.veryLow:
      case CalorieStatus.low:
        return Icons.battery_alert;
      case CalorieStatus.belowIdeal:
        return Icons.battery_3_bar;
      case CalorieStatus.ideal:
        return Icons.battery_full;
      case CalorieStatus.slightlyHigh:
        return Icons.warning_amber;
      case CalorieStatus.high:
      case CalorieStatus.exceeded:
        return Icons.error;
    }
  }

  /// 백분율 범위
  String get percentageRange {
    switch (this) {
      case CalorieStatus.veryLow:
        return '0-20%';
      case CalorieStatus.low:
        return '21-40%';
      case CalorieStatus.belowIdeal:
        return '41-60%';
      case CalorieStatus.ideal:
        return '61-80%';
      case CalorieStatus.slightlyHigh:
        return '81-95%';
      case CalorieStatus.high:
        return '96-110%';
      case CalorieStatus.exceeded:
        return '111%+';
    }
  }
}

/// 칼로리 상태 계산
CalorieStatus getCalorieStatus({
  required double current,
  required double goal,
  Map<String, dynamic>? mealPattern,
  DateTime? currentTime,
}) {
  if (goal <= 0) return CalorieStatus.ideal;

  // 식사 패턴이 있으면 권장 칼로리 기준으로 판단
  if (mealPattern != null) {
    try {
      final guidance = MealPatternCalorieGuide.getGuidance(
        mealPattern: mealPattern,
        dailyGoal: goal,
        currentIntake: current,
        currentTime: currentTime,
        l10n: null, // l10n 없이 호출 (기본값 사용)
      );

      // 권장 칼로리 대비 현재 섭취량 비율 계산
      double recommendedPercentage;
      if (guidance.recommendedCalories > 0) {
        recommendedPercentage = (current / guidance.recommendedCalories) * 100;
      } else {
        // 권장량이 0일 때 (아직 첫 식사 전)
        if (current > 0) {
          // 섭취량이 있으면 무한대 초과 -> 매우 큰 값으로 설정 (Exceeded 유도)
          recommendedPercentage = 999.0;
        } else {
          // 둘 다 0이면 적절함
          recommendedPercentage = 100.0; // Ideal 범위
        }
      }

      // 권장 칼로리 기준으로 상태 판단
      if (recommendedPercentage <= 50) return CalorieStatus.veryLow;
      if (recommendedPercentage <= 75) return CalorieStatus.low;
      if (recommendedPercentage <= 90) return CalorieStatus.belowIdeal;
      if (recommendedPercentage <= 110) return CalorieStatus.ideal;
      if (recommendedPercentage <= 125) return CalorieStatus.slightlyHigh;
      if (recommendedPercentage <= 140) return CalorieStatus.high;
      return CalorieStatus.exceeded;
    } catch (e) {
      print('❌ [CalorieStatus] Error: $e');
      // MealPatternCalorieGuide 오류 시 기본 로직으로 fallback
    }
  }

  // 기존 로직 (일일 목표 기준)
  final percentage = (current / goal) * 100;

  if (percentage <= 20) return CalorieStatus.veryLow;
  if (percentage <= 40) return CalorieStatus.low;
  if (percentage <= 60) return CalorieStatus.belowIdeal;
  if (percentage <= 80) return CalorieStatus.ideal;
  if (percentage <= 95) return CalorieStatus.slightlyHigh;
  if (percentage <= 110) return CalorieStatus.high;
  return CalorieStatus.exceeded;
}
