/// 음식 입력 모드
enum FoodInputMode {
  /// 전체 칼로리 (가장 간단)
  totalCalories,
  
  /// 100g당 칼로리 (기존 방식)
  per100g,
  
  /// 1회 제공량당 (영양성분표)
  perServing,
  
  /// 빠른 기록 (나중에 칼로리 입력)
  quickRecord,
}

extension FoodInputModeExtension on FoodInputMode {
  String get displayName {
    switch (this) {
      case FoodInputMode.totalCalories:
        return '전체 칼로리';
      case FoodInputMode.per100g:
        return '100g당';
      case FoodInputMode.perServing:
        return '1회 제공량';
      case FoodInputMode.quickRecord:
        return '빠른 기록';
    }
  }
  
  String get description {
    switch (this) {
      case FoodInputMode.totalCalories:
        return '음식의 총 칼로리를 직접 입력';
      case FoodInputMode.per100g:
        return '100g당 칼로리로 계산';
      case FoodInputMode.perServing:
        return '영양성분표의 1회 제공량 기준';
      case FoodInputMode.quickRecord:
        return '일단 기록, 나중에 칼로리 입력';
    }
  }
}
