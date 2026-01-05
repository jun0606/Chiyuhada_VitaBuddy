import 'dart:math';
import '../models/meal_guidance.dart';
import '../l10n/app_localizations.dart';

/// 식사 패턴 기반 칼로리 안내 유틸리티
class MealPatternCalorieGuide {
  /// 식사 패턴 기반 칼로리 안내 생성
  static MealGuidance getGuidance({
    required Map<String, dynamic>? mealPattern,
    required double dailyGoal,
    required double currentIntake,
    AppLocalizations? l10n,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();

    // 식사 패턴이 없으면 기본 메시지만 반환
    if (mealPattern == null || dailyGoal <= 0) {
      return MealGuidance(
        recommendedCalories: dailyGoal,
        currentCalories: currentIntake,
        status: 'adequate',
        message: l10n?.guidanceNoPattern ?? '식사 패턴을 설정하면 더 정확한 안내를 받을 수 있어요!',
      );
    }

    // meals 리스트 가져오기 (타입 명시적 변환)
    final mealsRaw = mealPattern['meals'] as List?;
    if (mealsRaw == null || mealsRaw.isEmpty) {
      return MealGuidance(
        recommendedCalories: dailyGoal,
        currentCalories: currentIntake,
        status: 'adequate',
        message:
            l10n?.guidanceDailyGoal(dailyGoal.toInt()) ??
            '하루 목표: ${dailyGoal.toInt()}kcal',
      );
    }

    // 활성화된 식사만 필터링
    final meals = mealsRaw.where((m) => m['enabled'] == true).map((m) {
      final meal = Map<String, dynamic>.from(m as Map);

      // time 필드 유효성 검사
      bool hasValidTime = false;
      if (meal['time'] != null && meal['time'] is String) {
        final parts = (meal['time'] as String).split(':');
        if (parts.length == 2) hasValidTime = true;
      }

      if (!hasValidTime) {
        int? hour;
        int? minute;

        if (meal['hour'] is int)
          hour = meal['hour'];
        else if (meal['hour'] is double)
          hour = (meal['hour'] as double).toInt();
        else if (meal['hour'] is String)
          hour = int.tryParse(meal['hour']);

        if (meal['minute'] is int)
          minute = meal['minute'];
        else if (meal['minute'] is double)
          minute = (meal['minute'] as double).toInt();
        else if (meal['minute'] is String)
          minute = int.tryParse(meal['minute']);

        if (hour != null && minute != null) {
          meal['time'] =
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        }
      }
      return meal;
    }).toList();

    if (meals.isEmpty) {
      return MealGuidance(
        recommendedCalories: dailyGoal,
        currentCalories: currentIntake,
        status: 'adequate',
        message:
            l10n?.guidanceDailyGoal(dailyGoal.toInt()) ??
            '하루 목표: ${dailyGoal.toInt()}kcal',
      );
    }

    // 현재까지 지나간 식사들의 누적 비율 계산
    final cumulativeRatio = _getCumulativeRatio(meals, now);
    final recommendedCalories = dailyGoal * cumulativeRatio;

    // 다음 식사 정보
    final nextMeal = _getNextMeal(meals, now);

    // 상태 판단
    final difference = currentIntake - recommendedCalories;
    String status;
    if (difference < -200) {
      status = 'low';
    } else if (difference > 200) {
      status = 'high';
    } else {
      status = 'adequate';
    }

    // 메시지 생성
    final message = _generateMessage(
      status: status,
      recommended: recommendedCalories,
      current: currentIntake,
      difference: difference,
      cumulativeRatio: cumulativeRatio,
      meals: meals,
      now: now,
      l10n: l10n,
    );

    // 다음 식사까지 필요한 칼로리 계산
    double? caloriesUntilNextMeal;
    if (nextMeal != null) {
      final nextMealRatio = _getMealRatio(
        meals.indexOf(nextMeal),
        meals.length,
      );
      final nextMealCalories = dailyGoal * nextMealRatio;
      caloriesUntilNextMeal =
          (recommendedCalories + nextMealCalories) - currentIntake;
    }

    // 다음 식사 이름 번역
    String? nextMealName = nextMeal?['name'];
    if (nextMealName != null) {
      nextMealName = _getLocalizedMealName(nextMealName, l10n);
    }

    return MealGuidance(
      recommendedCalories: recommendedCalories,
      currentCalories: currentIntake,
      status: status,
      message: message,
      nextMealName: nextMealName,
      nextMealTime: nextMeal?['time'],
      caloriesUntilNextMeal: caloriesUntilNextMeal,
    );
  }

  static double _getMealRatio(int mealIndex, int totalMeals) {
    double baseRatio = 1.0 / totalMeals;
    if (totalMeals >= 3 && mealIndex == 1) {
      return baseRatio * 1.2;
    }
    return baseRatio;
  }

  static double _getCumulativeRatio(List meals, DateTime now) {
    if (meals.isEmpty) return 0.0;

    final currentMinutes = now.hour * 60 + now.minute;
    int passedMeals = 0;

    for (final meal in meals) {
      int? mealMinutes;
      final time = meal['time'];
      if (time != null && time is String) {
        final parts = time.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null && minute != null) {
            mealMinutes = hour * 60 + minute;
          }
        }
      }

      if (mealMinutes == null) {
        final hour = meal['hour'];
        final minute = meal['minute'];
        if (hour != null && minute != null) {
          mealMinutes = (hour as int) * 60 + (minute as int);
        }
      }

      if (mealMinutes == null) continue;

      final mealName = meal['name'];
      // 다국어 지원을 위해 키값 점검
      if ((mealName == '점심' ||
              mealName == 'lunch' ||
              mealName == 'Makan Siang') &&
          mealMinutes < 10 * 60) {
        mealMinutes += 12 * 60;
      } else if ((mealName == '저녁' ||
              mealName == 'dinner' ||
              mealName == 'Makan Malam') &&
          mealMinutes < 15 * 60) {
        mealMinutes += 12 * 60;
      }

      if (currentMinutes >= mealMinutes) {
        passedMeals++;
      }
    }

    if (passedMeals == 0) return 0.0;
    if (passedMeals >= meals.length) return 1.0;

    double totalRatio = 0.0;
    for (int i = 0; i < passedMeals; i++) {
      totalRatio += _getMealRatio(i, meals.length);
    }

    double sumOfRatios = 0.0;
    for (int i = 0; i < meals.length; i++) {
      sumOfRatios += _getMealRatio(i, meals.length);
    }

    return min(1.0, totalRatio / sumOfRatios);
  }

  static Map<String, dynamic>? _getNextMeal(List meals, DateTime now) {
    final currentMinutes = now.hour * 60 + now.minute;

    for (final meal in meals) {
      int? mealMinutes;
      final time = meal['time'];
      if (time != null && time is String) {
        final parts = time.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null && minute != null) {
            mealMinutes = hour * 60 + minute;
          }
        }
      }

      if (mealMinutes == null) {
        final hour = meal['hour'];
        final minute = meal['minute'];
        if (hour != null && minute != null) {
          mealMinutes = (hour as int) * 60 + (minute as int);
        }
      }

      if (mealMinutes == null) continue;

      if (currentMinutes < mealMinutes) {
        if (meal['time'] == null) {
          final hour = meal['hour'] as int;
          final minute = meal['minute'] as int;
          final timeString =
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          return Map<String, dynamic>.from(meal)..['time'] = timeString;
        }
        return Map<String, dynamic>.from(meal);
      }
    }

    return null;
  }

  static String _generateMessage({
    required String status,
    required double recommended,
    required double current,
    required double difference,
    required double cumulativeRatio,
    required List meals,
    required DateTime now,
    AppLocalizations? l10n,
  }) {
    // l10n이 null이면 기본 메시지 반환
    if (l10n == null) {
      return '칼로리 안내: 권장량 ${recommended.toInt()}kcal, 현재 ${current.toInt()}kcal';
    }

    // 50kcal 단위로 반올림
    int recommendedInt = (recommended / 50).round() * 50;
    int currentInt = (current / 50).round() * 50;
    int differenceInt = (difference.abs() / 50).round() * 50;

    // 지나간 마지막 식사 이름
    String? lastMealName;
    String? lastMealTime;
    final currentMinutes = now.hour * 60 + now.minute;

    for (final meal in meals.reversed) {
      int? mealMinutes;
      final time = meal['time'];
      if (time != null && time is String) {
        final parts = time.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null && minute != null) {
            mealMinutes = hour * 60 + minute;
          }
        }
      }

      if (mealMinutes == null) {
        final hour = meal['hour'];
        final minute = meal['minute'];
        if (hour != null && minute != null) {
          mealMinutes = (hour as int) * 60 + (minute as int);
        }
      }

      if (mealMinutes == null) continue;

      if (currentMinutes >= mealMinutes) {
        lastMealName = meal['name'];
        lastMealTime = meal['time'];
        break;
      }
    }

    // 아직 첫 식사 전
    if (cumulativeRatio == 0.0) {
      final firstName = _getLocalizedMealName(meals.first['name'], l10n);
      final firstTime = meals.first['time'];

      // 첫 식사 전인데 이미 많이 먹은 경우 (예: 200kcal 이상)
      if (current > 200) {
        return l10n.guidanceOvereating(firstName, firstTime ?? '', currentInt);
      }

      return l10n.guidanceFasting(firstName, firstTime ?? '');
    }

    // 모든 식사 완료
    if (cumulativeRatio >= 1.0) {
      if (status == 'adequate') {
        return l10n.guidanceFinished;
      } else if (status == 'low') {
        return l10n.guidanceLow(differenceInt);
      } else {
        return l10n.guidanceHigh(differenceInt);
      }
    }

    // 식사 중간 (일반적인 케이스)
    final localizedLastMealName = lastMealName != null
        ? _getLocalizedMealName(lastMealName, l10n)
        : null;
    final mealContext = localizedLastMealName != null
        ? l10n.contextUntilMeal(
            localizedLastMealName,
          ) // Note: l10n key semantics might need adjustment. Original was "until X", here it seems to mean "up to X".
        : l10n.contextCurrent;

    if (status == 'adequate') {
      return l10n.guidanceAdequate(mealContext);
    } else if (status == 'low') {
      return l10n.guidanceLowMid(mealContext, recommendedInt, currentInt);
    } else {
      return l10n.guidanceHighMid(mealContext, recommendedInt, currentInt);
    }
  }

  static String _getLocalizedMealName(String name, AppLocalizations? l10n) {
    // l10n이 null이면 원래 이름 반환
    if (l10n == null) return name;

    // 키워드로 매핑 (대소문자 무시)
    final lower = name.toLowerCase();

    if (lower.contains('breakfast') ||
        lower.contains('아침') ||
        lower.contains('pagi'))
      return l10n.mealBreakfast;
    if (lower.contains('lunch') ||
        lower.contains('점심') ||
        lower.contains('siang'))
      return l10n.mealLunch;
    if (lower.contains('dinner') ||
        lower.contains('저녁') ||
        lower.contains('malam'))
      return l10n.mealDinner;
    if (lower.contains('morning') || lower.contains('오전'))
      return l10n.mealSnackMorning;
    if (lower.contains('afternoon') || lower.contains('오후'))
      return l10n.mealSnackAfternoon;
    if (lower.contains('snack') || lower.contains('간식')) return l10n.mealSnack;

    return name;
  }
}
