import 'package:flutter/material.dart';

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
  
  /// 상태별 메시지
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
CalorieStatus getCalorieStatus(double current, double goal) {
  if (goal <= 0) return CalorieStatus.ideal;
  
  final percentage = (current / goal) * 100;
  
  if (percentage <= 20) return CalorieStatus.veryLow;
  if (percentage <= 40) return CalorieStatus.low;
  if (percentage <= 60) return CalorieStatus.belowIdeal;
  if (percentage <= 80) return CalorieStatus.ideal;
  if (percentage <= 95) return CalorieStatus.slightlyHigh;
  if (percentage <= 110) return CalorieStatus.high;
  return CalorieStatus.exceeded;
}
