import '../models/user_profile.dart';

/// 수분 섭취 권장량 계산 유틸리티
class WaterRecommendation {
  /// 사용자 프로필 기반 권장 수분량 계산 (ml)
  /// 
  /// 계산 공식:
  /// - 기본: 체중(kg) × 33ml
  /// - 활동량 추가 (250ml ~ 1000ml)
  /// - 연령 조정 (±200ml)
  /// - 성별 조정 (여성 0.92배)
  static int calculateRecommendedWater(UserProfile profile) {
    // 1. 기본 체중 기반 계산 (체중 × 33ml)
    double baseWater = profile.initialWeight * 33.0;
    
    // 2. 활동량 추가
    double activityBonus = _getActivityBonus(profile.activityLevel);
    
    // 3. 연령 조정
    double ageAdjustment = _getAgeAdjustment(profile.age);
    
    // 4. 성별 조정
    double genderMultiplier = _getGenderMultiplier(profile.gender);
    
    double totalWater = (baseWater + activityBonus + ageAdjustment) * genderMultiplier;
    
    // 100ml 단위로 반올림, 최소 1500ml, 최대 4000ml
    int recommended = ((totalWater / 100).round() * 100).clamp(1500, 4000);
    
    return recommended;
  }
  
  /// 활동량에 따른 추가 수분량
  static double _getActivityBonus(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return 0;
      case 'light':
        return 250;
      case 'moderate':
        return 500;
      case 'active':
        return 750;
      case 'very_active':
        return 1000;
      default:
        return 0;
    }
  }
  
  /// 연령에 따른 조정
  static double _getAgeAdjustment(int age) {
    if (age >= 65) return -200; // 노년층: 신장 기능 감소
    if (age < 18) return 200;   // 청소년: 성장기
    return 0;
  }
  
  /// 성별에 따른 배수
  static double _getGenderMultiplier(String gender) {
    return gender.toLowerCase() == 'female' ? 0.92 : 1.0;
  }
  
  /// 계산 설명 텍스트 반환 (디버깅/설명용)
  static String getCalculationExplanation(UserProfile profile, int recommendedWater) {
    final baseWater = (profile.initialWeight * 33.0).toInt();
    final activityBonus = _getActivityBonus(profile.activityLevel).toInt();
    final ageAdjustment = _getAgeAdjustment(profile.age).toInt();
    final genderMultiplier = _getGenderMultiplier(profile.gender);
    
    return '''
체중 기반: ${profile.initialWeight}kg × 33ml = ${baseWater}ml
활동량 추가: +${activityBonus}ml
연령 조정: ${ageAdjustment >= 0 ? '+' : ''}${ageAdjustment}ml
성별 조정: ×${genderMultiplier}
권장량: ${recommendedWater}ml
''';
  }
}
