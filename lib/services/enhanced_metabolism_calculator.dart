import '../models/user_profile.dart';
import '../models/body_types.dart';

/// 개인화된 대사율 계산 서비스
/// 체질, 근육량, 성격 데이터를 반영한 정확한 칼로리 계산
class EnhancedMetabolismCalculator {
  /// 개인화된 BMR (기초대사량) 계산
  /// 
  /// Harris-Benedict 공식에 체질과 근육량 보정을 적용합니다.
  /// 
  /// 보정 계수:
  /// - 체질 (Somatotype): 외배엽형 +7%, 중배엽형 0%, 내배엽형 -7%
  /// - 근육량 (MuscleType): 높음 +5%, 보통 0%, 낮음 -3%
  static double calculateEnhancedBMR(UserProfile profile) {
    // 1. 기본 Harris-Benedict 공식
    double baseBMR = profile.getBMR();
    
    // 2. 체질 보정 계수
    double somatypeModifier = _getSomatypeModifier(profile);
    
    // 3. 근육량 보정 계수
    double muscleModifier = _getMuscleModifier(profile);
    
    // 4. 최종 BMR = 기본 BMR × 체질 계수 × 근육량 계수
    double enhancedBMR = baseBMR * somatypeModifier * muscleModifier;
    
    return enhancedBMR;
  }
  
  /// 개인화된 TDEE (일일 총 에너지 소비량) 계산
  /// 
  /// BMR에 활동 수준과 NEAT(비운동성 활동 대사)를 반영합니다.
  /// 
  /// TDEE = (BMR × 활동 계수) + NEAT 보너스
  static double calculateEnhancedTDEE(UserProfile profile) {
    // 1. 개인화된 BMR 계산
    double bmr = calculateEnhancedBMR(profile);
    
    // 2. 활동 수준 계수 (기존 로직)
    double activityMultiplier = _getActivityMultiplier(profile.activityLevel);
    
    // 3. 성격 기반 NEAT 보너스
    double neatBonus = _getNEATBonus(profile);
    
    // 4. 최종 TDEE
    double tdee = (bmr * activityMultiplier) + neatBonus;
    
    return tdee;
  }
  
  /// 체질별 BMR 보정 계수
  static double _getSomatypeModifier(UserProfile profile) {
    if (profile.somatotype == null) {
      return 1.00; // 설정되지 않은 경우 표준
    }
    
    final somatype = Somatotype.fromString(profile.somatotype!);
    return somatype.bmrModifier;
  }
  
  /// 근육량별 BMR 보정 계수
  /// 
  /// 근육 조직은 지방 조직보다 많은 칼로리를 소모합니다.
  /// 근육 1kg당 약 13 kcal/일 추가 연소
  static double _getMuscleModifier(UserProfile profile) {
    final bodyComposition = profile.getBodyComposition();
    
    if (bodyComposition == null) {
      return 1.00; // 설정되지 않은 경우 표준
    }
    
    final muscleType = MuscleType.fromString(bodyComposition.muscleType);
    return muscleType.bmrModifier;
  }
  
  /// 활동 수준 계수 (Harris-Benedict 표준)
  static double _getActivityMultiplier(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return 1.2;   // 거의 운동 안 함
      case 'light':
        return 1.375; // 가벼운 운동 (주 1-3일)
      case 'moderate':
        return 1.55;  // 보통 운동 (주 3-5일)
      case 'active':
        return 1.725; // 적극적 운동 (주 6-7일)
      case 'very_active':
        return 1.9;   // 매우 적극적 (하루 2회 이상)
      default:
        return 1.2;
    }
  }
  
  /// 성격 기반 NEAT (Non-Exercise Activity Thermogenesis) 보너스
  /// 
  /// 운동이 아닌 일상 활동으로 소모되는 추가 칼로리
  /// 
  /// 성격 특성별 영향:
  /// - Extraversion (외향성): 높을수록 활동적 → +0~200 kcal
  /// - Neuroticism (신경성): 중간~높을수록 fidgeting 증가 → +0~150 kcal
  static double _getNEATBonus(UserProfile profile) {
    final traits = profile.personalityTraits;
    
    if (traits == null) {
      return 0.0; // 성격 데이터 없으면 보너스 없음
    }
    
    double bonus = 0.0;
    
    // 1. 외향성 (Extraversion): 0~100 → 0~200 kcal
    final extraversion = (traits['extraversion'] ?? 50) / 100.0;
    bonus += extraversion * 200;
    
    // 2. 신경성 (Neuroticism): 40~100 → 0~150 kcal
    // (낮은 신경성에서는 NEAT 영향 없음)
    final neuroticism = (traits['neuroticism'] ?? 50) / 100.0;
    if (neuroticism > 0.4) {
      bonus += (neuroticism - 0.4) * 250; // 40% 이상만 보너스
    }
    
    return bonus;
  }
  
  /// 체질별 권장 매크로 비율 계산
  /// 
  /// 반환값: {'carbs': 40, 'protein': 30, 'fat': 30} (%)
  static Map<String, int> getRecommendedMacros(UserProfile profile) {
    final somatype = profile.getSomatotype();
    
    switch (somatype) {
      case Somatotype.ectomorph:
        // 외배엽형: 고탄수화물
        return {
          'carbs': 55,
          'protein': 25,
          'fat': 20,
        };
        
      case Somatotype.mesomorph:
        // 중배엽형: 균형
        return {
          'carbs': 45,
          'protein': 30,
          'fat': 25,
        };
        
      case Somatotype.endomorph:
        // 내배엽형: 저탄수화물
        return {
          'carbs': 30,
          'protein': 30,
          'fat': 40,
        };
        
      default:
        // 기본값: 균형
        return {
          'carbs': 40,
          'protein': 30,
          'fat': 30,
        };
    }
  }
  
  /// TDEE 변화량 계산 (기존 vs 개인화)
  /// 
  /// 사용자에게 개인화의 효과를 보여주기 위한 메서드
  static Map<String, double> calculateTDEEComparison(UserProfile profile) {
    // 기존 방식 (단순 Harris-Benedict + 활동 계수)
    double standardBMR = profile.getBMR();
    double activityMultiplier = _getActivityMultiplier(profile.activityLevel);
    double standardTDEE = standardBMR * activityMultiplier;
    
    // 개인화된 방식
    double enhancedTDEE = calculateEnhancedTDEE(profile);
    
    // 차이
    double difference = enhancedTDEE - standardTDEE;
    double percentChange = (difference / standardTDEE) * 100;
    
    return {
      'standard': standardTDEE,
      'enhanced': enhancedTDEE,
      'difference': difference,
      'percentChange': percentChange,
    };
  }
}
