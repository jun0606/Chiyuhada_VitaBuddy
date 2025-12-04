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

  // ===== 수면 대사 및 실시간 BMR (Phase 16) =====

  /// 수면 BMR 계수 계산
  /// 
  /// 신체 데이터를 기반으로 수면 중 대사율 감소 계수를 산출합니다.
  /// 기본값: 0.9 (90%)
  /// 
  /// 보정 요인:
  /// - 근육량: 높을수록 수면 대사율이 덜 감소함 (+0.01 ~ +0.05)
  /// - 체지방률: 높을수록 대사율이 더 감소할 수 있음 (-0.01 ~ -0.03)
  /// - 나이: 나이가 들수록 수면 효율 변화 (미세 보정)
  static double calculateSleepBMRMultiplier(UserProfile profile) {
    double baseMultiplier = 0.9;
    
    // 1. 근육량 보정
    final bodyComp = profile.getBodyComposition();
    if (bodyComp != null) {
      final muscleType = MuscleType.fromString(bodyComp.muscleType);
      // 근육량이 많으면(high) +0.03, 적으면(low) -0.01
      if (muscleType == MuscleType.high) {
        baseMultiplier += 0.03;
      } else if (muscleType == MuscleType.low) {
        baseMultiplier -= 0.01;
      }
    }
    
    // 2. 체지방률 보정 (데이터가 있다면)
    // (단순화를 위해 여기서는 생략하거나 추후 고도화)
    
    // 3. 나이 보정 (50세 이상은 대사율 감소폭이 클 수 있음)
    if (profile.age >= 50) {
      baseMultiplier -= 0.02;
    }
    
    // 범위 제한 (0.8 ~ 1.0)
    return baseMultiplier.clamp(0.8, 1.0);
  }

  /// 분당 BMR 소모량 계산
  /// 
  /// @param profile 사용자 프로필
  /// @param isAsleep 수면 상태 여부
  /// @return kcal/min
  static double getMinuteBMR(UserProfile profile, {required bool isAsleep}) {
    // 1. 일일 BMR (활동 계수 제외, 순수 기초대사량)
    // 주의: 여기서는 '활동'이 없는 순수 BMR을 기준으로 해야 함.
    // 하지만 TDEE 개념에서 '기초대사량' 부분만 분리해서 생각.
    // EnhancedBMR은 이미 체질/근육량이 반영된 BMR임.
    double dailyBMR = calculateEnhancedBMR(profile);
    
    // 2. 수면 시 계수 적용
    if (isAsleep) {
      double sleepMultiplier = calculateSleepBMRMultiplier(profile);
      dailyBMR *= sleepMultiplier;
    }
    
    // 3. 분당 소모량으로 변환
    return dailyBMR / 1440.0; // 24 * 60
  }

  /// 특정 시간까지의 누적 BMR 소모량 계산 (00:00 ~ currentTime)
  /// 
  /// 수면 시간을 고려하여 분 단위로 누적 계산합니다.
  /// 
  /// @param profile 사용자 프로필 (수면 설정 포함)
  /// @param currentTime 현재 시간
  /// @return 00:00부터 현재까지 소모된 총 BMR (kcal)
  static double calculateAccumulatedBMR(UserProfile profile, DateTime currentTime) {
    final sleepConfig = profile.sleepConfig;
    
    // 수면/기상 시간 파싱 (HH:mm)
    final sleepTimeParts = sleepConfig.manualSleepTime.split(':');
    final wakeTimeParts = sleepConfig.manualWakeTime.split(':');
    
    final sleepHour = int.parse(sleepTimeParts[0]);
    final sleepMinute = int.parse(sleepTimeParts[1]);
    final wakeHour = int.parse(wakeTimeParts[0]);
    final wakeMinute = int.parse(wakeTimeParts[1]);
    
    // 분 단위로 환산
    final sleepTimeMinutes = sleepHour * 60 + sleepMinute;
    final wakeTimeMinutes = wakeHour * 60 + wakeMinute;
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    
    // 분당 소모율
    final bmrPerMinuteAwake = getMinuteBMR(profile, isAsleep: false);
    final bmrPerMinuteSleep = getMinuteBMR(profile, isAsleep: true);
    
    double accumulatedBMR = 0.0;
    
    // 00:00부터 현재까지 루프 (최적화를 위해 구간 계산 가능하지만, 
    // 하루 최대 1440번 루프는 성능에 지장 없음)
    for (int i = 0; i < currentMinutes; i++) {
      bool isAsleep = false;
      
      // 수면 시간 판별 로직 (단순화: 자정 넘김 고려)
      // Case 1: 23:00 ~ 07:00 (자정 넘김)
      // Case 2: 01:00 ~ 09:00 (자정 안 넘김 - 드문 케이스지만 가능)
      
      if (sleepTimeMinutes > wakeTimeMinutes) {
        // 자정을 넘기는 스케줄 (예: 23:00 ~ 07:00)
        // 00:00 ~ 기상시간 OR 취침시간 ~ 24:00
        if (i < wakeTimeMinutes || i >= sleepTimeMinutes) {
          isAsleep = true;
        }
      } else {
        // 자정을 안 넘기는 스케줄 (예: 01:00 ~ 08:00)
        if (i >= sleepTimeMinutes && i < wakeTimeMinutes) {
          isAsleep = true;
        }
      }
      
      accumulatedBMR += isAsleep ? bmrPerMinuteSleep : bmrPerMinuteAwake;
    }
    
    return accumulatedBMR;
  }
  
  /// 특정 시간까지의 누적 에너지 소비량(TDEE) 계산 (00:00 ~ currentTime)
  /// 
  /// BMR(수면/비수면) + 활동 대사량(비수면 시간 동안 분배)
  /// 
  /// @param profile 사용자 프로필
  /// @param currentTime 현재 시간
  /// @return 누적 소모 칼로리 (kcal)
  static double calculateAccumulatedTDEE(UserProfile profile, DateTime currentTime) {
    final sleepConfig = profile.sleepConfig;
    
    // 1. 기본 BMR 및 TDEE 계산
    final double dailyBMR = calculateEnhancedBMR(profile);
    final double dailyTDEE = calculateEnhancedTDEE(profile);
    final double dailyActivityCalories = dailyTDEE - dailyBMR; // 순수 활동으로 인한 추가 칼로리
    
    // 2. 수면/기상 시간 파싱
    final sleepTimeParts = sleepConfig.manualSleepTime.split(':');
    final wakeTimeParts = sleepConfig.manualWakeTime.split(':');
    
    final sleepHour = int.parse(sleepTimeParts[0]);
    final sleepMinute = int.parse(sleepTimeParts[1]);
    final wakeHour = int.parse(wakeTimeParts[0]);
    final wakeMinute = int.parse(wakeTimeParts[1]);
    
    final sleepTimeMinutes = sleepHour * 60 + sleepMinute;
    final wakeTimeMinutes = wakeHour * 60 + wakeMinute;
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    
    // 3. 하루 총 수면/비수면 시간 계산
    int totalSleepMinutes = 0;
    if (sleepTimeMinutes > wakeTimeMinutes) {
      // 자정 넘김 (예: 23:00 ~ 07:00) -> 24:00-23:00 + 07:00-00:00 = 1 + 7 = 8시간
      totalSleepMinutes = (1440 - sleepTimeMinutes) + wakeTimeMinutes;
    } else {
      // 자정 안 넘김 (예: 01:00 ~ 09:00) -> 8시간
      totalSleepMinutes = wakeTimeMinutes - sleepTimeMinutes;
    }
    final int totalAwakeMinutes = 1440 - totalSleepMinutes;
    
    // 4. 분당 소모율 계산
    // 활동 칼로리는 깨어있는 시간에만 분배
    final double activityPerMinute = totalAwakeMinutes > 0 
        ? dailyActivityCalories / totalAwakeMinutes 
        : 0;
        
    final double bmrPerMinuteAwake = getMinuteBMR(profile, isAsleep: false);
    final double bmrPerMinuteSleep = getMinuteBMR(profile, isAsleep: true);
    
    double accumulatedBurn = 0.0;
    
    // 5. 누적 계산
    for (int i = 0; i < currentMinutes; i++) {
      bool isAsleep = false;
      
      if (sleepTimeMinutes > wakeTimeMinutes) {
        if (i < wakeTimeMinutes || i >= sleepTimeMinutes) {
          isAsleep = true;
        }
      } else {
        if (i >= sleepTimeMinutes && i < wakeTimeMinutes) {
          isAsleep = true;
        }
      }
      
      if (isAsleep) {
        accumulatedBurn += bmrPerMinuteSleep;
      } else {
        accumulatedBurn += (bmrPerMinuteAwake + activityPerMinute);
      }
    }
    
    return accumulatedBurn;
  }
}
