import 'dart:math';

/// 칼로리 계산기 (BMR/TDEE 기반)
///
/// Harris-Benedict 공식을 사용하여 기초대사량(BMR)과
/// 총 소모 칼로리(TDEE)를 계산합니다.
class CalorieCalculator {
  /// 기초대사량(BMR) 계산
  ///
  /// Harris-Benedict 개정 공식 사용:
  /// - 남성: 88.362 + (13.397 × 체중kg) + (4.799 × 신장cm) - (5.677 × 나이)
  /// - 여성: 447.593 + (9.247 × 체중kg) + (3.098 × 신장cm) - (4.330 × 나이)
  ///
  /// @param weight 체중 (kg)
  /// @param height 신장 (cm)
  /// @param age 나이 (세)
  /// @param gender 성별 ('male' 또는 'female')
  /// @return BMR (Kcal/day), 데이터 누락 시 기본값 1500
  static double calculateBMR({
    required double? weight,
    required double? height,
    required int? age,
    required String? gender,
  }) {
    // 데이터 검증 및 기본값 처리
    if (weight == null || weight <= 0 ||
        height == null || height <= 0 ||
        age == null || age <= 0 ||
        gender == null || gender.isEmpty) {
      return 1500.0; // 기본 BMR
    }

    try {
      if (gender.toLowerCase() == 'male') {
        return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
      } else {
        return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
      }
    } catch (e) {
      return 1500.0; // 계산 실패 시 기본값
    }
  }

  /// 총 소모 칼로리(TDEE) 계산
  ///
  /// BMR에 활동량 계수를 곱하여 계산:
  /// - sedentary: 1.2 (거의 운동 안함)
  /// - light: 1.375 (가벼운 운동, 주 1-3일)
  /// - moderate: 1.55 (중간 운동, 주 3-5일)
  /// - active: 1.725 (활발한 운동, 주 6-7일)
  /// - very_active: 1.9 (매우 활발, 하루 2회)
  ///
  /// @param bmr 기초대사량
  /// @param activityLevel 활동량 수준
  /// @return TDEE (Kcal/day)
  static double calculateTDEE(double bmr, String? activityLevel) {
    const multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    final multiplier = multipliers[activityLevel?.toLowerCase()] ?? 1.2;
    return bmr * multiplier;
  }

  /// 분당 소모 칼로리 계산
  ///
  /// TDEE를 24시간(1440분)으로 나누어 계산
  ///
  /// @param tdee 총 소모 칼로리 (Kcal/day)
  /// @return 분당 소모 칼로리 (Kcal/min)
  static double caloriesPerMinute(double tdee) {
    return tdee / (24 * 60);
  }

  /// 경과 시간에 대한 칼로리 감소량 계산
  ///
  /// @param tdee 총 소모 칼로리
  /// @param minutes 경과 시간 (분)
  /// @param dailyGoal 일일 목표 칼로리
  /// @return 감소할 칼로리 (최대 dailyGoal의 30%로 제한)
  static double calculateCalorieDecrease({
    required double tdee,
    required int minutes,
    required double dailyGoal,
  }) {
    if (minutes <= 0) return 0.0;

    final perMinute = caloriesPerMinute(tdee);
    final rawDecrease = perMinute * minutes;

    // 최대 감소량 제한 (일일 목표의 30%)
    final maxDecrease = dailyGoal * 0.3;
    return min(rawDecrease, maxDecrease);
  }

  /// 현재 칼로리에 감소량 적용
  ///
  /// @param current 현재 칼로리
  /// @param decrease 감소량
  /// @return 새로운 칼로리 (음수 방지)
  static double applyDecrease(double current, double decrease) {
    return max(0, current - decrease);
  }
}
