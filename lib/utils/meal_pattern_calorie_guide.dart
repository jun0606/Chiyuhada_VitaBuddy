import 'dart:math';
import '../models/meal_guidance.dart';

/// 식사 패턴 기반 칼로리 안내 유틸리티
/// 
/// 현재 시간과 사용자의 식사 패턴을 기반으로
/// "지금까지 먹었어야 할 칼로리"를 계산하고 안내 메시지를 생성합니다.
class MealPatternCalorieGuide {
  /// 식사 패턴 기반 칼로리 안내 생성
  /// 
  /// @param mealPattern 사용자의 식사 패턴 (UserProfile.getMealPattern())
  /// @param dailyGoal 일일 목표 칼로리
  /// @param currentIntake 현재까지 섭취한 칼로리
  /// @param currentTime 현재 시간 (기본값: DateTime.now())
  /// @return MealGuidance 안내 정보
  static MealGuidance getGuidance({
    required Map<String, dynamic>? mealPattern,
    required double dailyGoal,
    required double currentIntake,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    
    // 식사 패턴이 없으면 기본 메시지만 반환
    if (mealPattern == null || dailyGoal <= 0) {
      return MealGuidance(
        recommendedCalories: dailyGoal,
        currentCalories: currentIntake,
        status: 'adequate',
        message: '식사 패턴을 설정하면 더 정확한 안내를 받을 수 있어요!',
      );
    }
    
    // meals 리스트 가져오기 (타입 명시적 변환)
    final mealsRaw = mealPattern['meals'] as List?;
    if (mealsRaw == null || mealsRaw.isEmpty) {
      return MealGuidance(
        recommendedCalories: dailyGoal,
        currentCalories: currentIntake,
        status: 'adequate',
        message: '하루 목표: ${dailyGoal.toInt()}kcal',
      );
    }
    
    // 활성화된 식사만 필터링하고 Map<String, dynamic>으로 변환
    // time 필드가 없으면 hour/minute로부터 생성
    final meals = mealsRaw
        .where((m) => m['enabled'] == true)
        .map((m) {
          final meal = Map<String, dynamic>.from(m as Map);
          
          // time 필드 유효성 검사
          bool hasValidTime = false;
          if (meal['time'] != null && meal['time'] is String) {
            final parts = (meal['time'] as String).split(':');
            if (parts.length == 2) hasValidTime = true;
          }
          
          // time 필드가 없거나 유효하지 않으면 hour/minute로 생성
          if (!hasValidTime) {
            // hour/minute가 있는지 확인 (타입 안전하게 처리)
            int? hour;
            int? minute;
            
            if (meal['hour'] is int) hour = meal['hour'];
            else if (meal['hour'] is double) hour = (meal['hour'] as double).toInt();
            else if (meal['hour'] is String) hour = int.tryParse(meal['hour']);
            
            if (meal['minute'] is int) minute = meal['minute'];
            else if (meal['minute'] is double) minute = (meal['minute'] as double).toInt();
            else if (meal['minute'] is String) minute = int.tryParse(meal['minute']);
            
            if (hour != null && minute != null) {
              meal['time'] = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
            }
          }
          return meal;
        })
        .toList();
    
    if (meals.isEmpty) {
      return MealGuidance(
        recommendedCalories: dailyGoal,
        currentCalories: currentIntake,
        status: 'adequate',
        message: '하루 목표: ${dailyGoal.toInt()}kcal',
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
    );
    
    // 다음 식사까지 필요한 칼로리 계산
    double? caloriesUntilNextMeal;
    if (nextMeal != null) {
      final nextMealRatio = _getMealRatio(meals.indexOf(nextMeal), meals.length);
      final nextMealCalories = dailyGoal * nextMealRatio;
      caloriesUntilNextMeal = (recommendedCalories + nextMealCalories) - currentIntake;
    }
    
    return MealGuidance(
      recommendedCalories: recommendedCalories,
      currentCalories: currentIntake,
      status: status,
      message: message,
      nextMealName: nextMeal?['name'],
      nextMealTime: nextMeal?['time'],
      caloriesUntilNextMeal: caloriesUntilNextMeal,
    );
  }
  
  /// 식사별 칼로리 비율 계산
  /// 
  /// 균등 분배 원칙 + 점심 가중치 적용
  static double _getMealRatio(int mealIndex, int totalMeals) {
    // 기본 균등 분배
    double baseRatio = 1.0 / totalMeals;
    
    // 점심은 약간 더 (index 1 또는 중간 식사로 가정)
    if (totalMeals >= 3 && mealIndex == 1) {
      return baseRatio * 1.2;
    }
    
    return baseRatio;
  }
  
  /// 현재까지 지나간 식사들의 누적 비율 계산
  /// 
  /// 예: 현재 14:00, 식사 [08:00 아침, 12:00 점심, 19:00 저녁]
  ///     → 아침(30%) + 점심(40%) = 70%
  static double _getCumulativeRatio(List meals, DateTime now) {
    if (meals.isEmpty) return 0.0;
    
    final currentMinutes = now.hour * 60 + now.minute;
    int passedMeals = 0;
    
    for (final meal in meals) {
      int? mealMinutes;
      
      // time 필드 체크 (문자열 형식: "HH:mm")
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
      
      // hour/minute 필드 체크 (정수 형식)
      if (mealMinutes == null) {
        final hour = meal['hour'];
        final minute = meal['minute'];
        if (hour != null && minute != null) {
          mealMinutes = (hour as int) * 60 + (minute as int);
        }
      }
      
      if (mealMinutes == null) continue;
      
      // 24시간제 보정 (데이터 오류 방지)
      // 점심이 10시 이전, 저녁이 15시 이전이면 12시간제 오기로 간주하고 보정
      final mealName = meal['name'];
      if (mealName == '점심' && mealMinutes < 10 * 60) {
        mealMinutes += 12 * 60; // 12시간제 오류 보정
      } else if (mealName == '저녁' && mealMinutes < 15 * 60) {
        mealMinutes += 12 * 60; // 12시간제 오류 보정
      }
      
      // 현재 시간이 식사 시간을 지났으면 카운트
      if (currentMinutes >= mealMinutes) {
        passedMeals++;
      }
    }
    
    // 지나간 식사가 없으면 0%, 모두 지났으면 100%
    if (passedMeals == 0) return 0.0;
    if (passedMeals >= meals.length) return 1.0;
    
    // 지나간 식사들의 비율 누적
    double totalRatio = 0.0;
    for (int i = 0; i < passedMeals; i++) {
      totalRatio += _getMealRatio(i, meals.length);
    }
    
    // 정규화 (비율 합이 1.0이 되도록)
    double sumOfRatios = 0.0;
    for (int i = 0; i < meals.length; i++) {
      sumOfRatios += _getMealRatio(i, meals.length);
    }
    
    return min(1.0, totalRatio / sumOfRatios);
  }
  
  /// 다음 식사 정보 가져오기
  static Map<String, dynamic>? _getNextMeal(List meals, DateTime now) {
    final currentMinutes = now.hour * 60 + now.minute;
    
    for (final meal in meals) {
      int? mealMinutes;
      
      // time 필드 체크 (문자열 형식: "HH:mm")
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
      
      // hour/minute 필드 체크 (정수 형식)
      if (mealMinutes == null) {
        final hour = meal['hour'];
        final minute = meal['minute'];
        if (hour != null && minute != null) {
          mealMinutes = (hour as int) * 60 + (minute as int);
        }
      }
      
      if (mealMinutes == null) continue;
      
      // 아직 지나지 않은 첫 번째 식사
      if (currentMinutes < mealMinutes) {
        // time 필드가 없으면 새로운 Map 생성하여 추가
        if (meal['time'] == null) {
          final hour = meal['hour'] as int;
          final minute = meal['minute'] as int;
          final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          
          return Map<String, dynamic>.from(meal)..['time'] = timeString;
        }
        return Map<String, dynamic>.from(meal);
      }
    }
    
    return null; // 모든 식사가 끝남
  }
  
  /// 사용자 친화적 메시지 생성
  static String _generateMessage({
    required String status,
    required double recommended,
    required double current,
    required double difference,
    required double cumulativeRatio,
    required List meals,
    required DateTime now,
  }) {
    // 50kcal 단위로 반올림
    int recommendedInt = (recommended / 50).round() * 50;
    int currentInt = (current / 50).round() * 50;
    int differenceInt = (difference.abs() / 50).round() * 50;
    
    // 지나간 마지막 식사 이름
    String? lastMealName;
    final currentMinutes = now.hour * 60 + now.minute;
    
    for (final meal in meals.reversed) {
      int? mealMinutes;
      
      // time 필드 체크
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
      
      // hour/minute 필드 체크
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
        break;
      }
    }
    
    // 아직 첫 식사 전
    if (cumulativeRatio == 0.0) {
      final firstName = meals.first['name'];
      final firstTime = meals.first['time'];
      
      // 첫 식사 전인데 이미 많이 먹은 경우 (예: 200kcal 이상)
      if (current > 200) {
         return '⚠️ $firstName($firstTime) 전인데 벌써 ${currentInt}kcal를 드셨네요! 과식에 주의하세요.';
      }
      
      return '💡 $firstName($firstTime)까지 공복 유지를 권장해요';
    }
    
    // 모든 식사 완료
    if (cumulativeRatio >= 1.0) {
      if (status == 'adequate') {
        return '✅ 오늘 하루 식사를 잘 마쳤습니다!';
      } else if (status == 'low') {
        return '💡 하루 권장량보다 ${differenceInt}kcal 부족합니다. 간식을 드세요!';
      } else {
        return '⚠️ 하루 권장량보다 ${differenceInt}kcal 초과했습니다.';
      }
    }
    
    // 식사 중간 (일반적인 케이스)
    final mealContext = lastMealName != null ? '$lastMealName까지' : '현재';
    
    if (status == 'adequate') {
      return '✅ 훌륭해요! $mealContext 적정량을 섭취했습니다.';
    } else if (status == 'low') {
      return '⚠️ $mealContext 약 ${recommendedInt}kcal 섭취가 권장되지만,\n현재 ${currentInt}kcal입니다. 다음 식사에서 조금 더 드세요!';
    } else {
      return '⚠️ $mealContext ${recommendedInt}kcal가 권장되는데\n${currentInt}kcal를 섭취했습니다. 다음 식사는 가볍게!';
    }
  }
}
