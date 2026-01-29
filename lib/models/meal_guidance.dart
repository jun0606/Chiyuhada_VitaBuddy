/// 식사 안내 정보 모델
class MealGuidance {
  /// 현재 시간까지 권장되는 누적 칼로리
  final double recommendedCalories;
  
  /// 실제 섭취한 칼로리
  final double currentCalories;
  
  /// 칼로리 차이 (현재 - 권장)
  double get difference => currentCalories - recommendedCalories;
  
  /// 상태: 'adequate'(적정), 'low'(부족), 'high'(초과)
  final String status;
  
  /// 사용자에게 보여줄 메시지
  final String message;
  
  /// 다음 식사 이름 (예: "저녁")
  final String? nextMealName;
  
  /// 다음 식사 시간 (예: "19:00")
  final String? nextMealTime;
  
  /// 다음 식사까지 필요한 칼로리 (양수면 더 먹어야 함, 음수면 줄여야 함)
  final double? caloriesUntilNextMeal;

  MealGuidance({
    required this.recommendedCalories,
    required this.currentCalories,
    required this.status,
    required this.message,
    this.nextMealName,
    this.nextMealTime,
    this.caloriesUntilNextMeal,
  });
  
  /// 부족한 칼로리인지 (200kcal 이상 부족)
  bool get isLow => status == 'low' && difference < -200;
  
  /// 적정한 칼로리인지
  bool get isAdequate => status == 'adequate';
  
  /// 초과한 칼로리인지 (200kcal 이상 초과)
  bool get isHigh => status == 'high' && difference > 200;
}
