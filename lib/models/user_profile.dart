import 'package:hive/hive.dart';
import '../avatar/clothing_colors.dart';
import '../services/enhanced_metabolism_calculator.dart';
import 'body_composition.dart';
import 'body_types.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  double height; // cm

  @HiveField(2)
  double initialWeight; // kg

  @HiveField(3)
  String gender; // 'male', 'female', 'other'

  @HiveField(4)
  int age; // years

  @HiveField(5)
  String activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'

  @HiveField(6)
  DateTime? createdAt;

  @HiveField(7)
  DateTime? updatedAt;

  @HiveField(8)
  Map<String, int>? clothingColors;

  // ===== 고급 프로필 필드 =====

  /// 체질 타입
  @HiveField(9)
  String? somatotype; // 'ectomorph', 'mesomorph', 'endomorph', 'mixed'

  /// 체형 타입
  @HiveField(10)
  String? bodyShape; // 'apple', 'pear', 'hourglass', 'rectangle', 'inverted_triangle'

  /// 성격 특성 (Big Five, 0-100 점수)
  /// {'conscientiousness': 75, 'extraversion': 60, 'neuroticism': 40, 'openness': 70, 'agreeableness': 65}
  @HiveField(11)
  Map<String, int>? personalityTraits;

  /// 체형 구성 정보 (근육량, 지방 패턴 등)
  /// 주의: Hive에서는 custom 객체 저장 시 JSON으로 변환 필요
  @HiveField(12)
  Map<String, dynamic>? bodyCompositionData;

  UserProfile({
    this.name,
    required this.height,
    required this.initialWeight,
    required this.gender,
    required this.age,
    required this.activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.clothingColors,
    this.somatotype,
    this.bodyShape,
    this.personalityTraits,
    this.bodyCompositionData,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  // BMR 계산 (Harris-Benedict 공식)
  double getBMR() {
    if (gender.toLowerCase() == 'male') {
      return 88.362 +
          (13.397 * initialWeight) +
          (4.799 * height) -
          (5.677 * age);
    } else {
      return 447.593 +
          (9.247 * initialWeight) +
          (3.098 * height) -
          (4.330 * age);
    }
  }

  // ===== 기존 TDEE 계산 (표준 방식) =====
  // TDEE 계산 (BMR * 활동 수준 배수)
  double getTDEE() {
    double bmr = getBMR();
    double multiplier = _getActivityMultiplier();
    return bmr * multiplier;
  }

  // ===== 개인화된 대사율 계산 =====
  
  /// 개인화된 BMR (체질, 근육량 반영)
  double getEnhancedBMR() {
    return EnhancedMetabolismCalculator.calculateEnhancedBMR(this);
  }
  
  /// 개인화된 TDEE (체질, 근육량, 성격 반영)
  double getEnhancedTDEE() {
    return EnhancedMetabolismCalculator.calculateEnhancedTDEE(this);
  }
  
  /// 권장 매크로 비율 (체질 기반)
  /// 반환: {'carbs': 40, 'protein': 30, 'fat': 30} (%)
  Map<String, int> getRecommendedMacros() {
    return EnhancedMetabolismCalculator.getRecommendedMacros(this);
  }
  
  /// TDEE 비교 (기존 vs 개인화)
  Map<String, double> getTDEEComparison() {
    return EnhancedMetabolismCalculator.calculateTDEEComparison(this);
  }

  double _getActivityMultiplier() {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'active':
        return 1.725;
      case 'very_active':
        return 1.9;
      default:
        return 1.2;
    }
  }

  // BMI 계산
  double getBMI() {
    double heightInMeters = height / 100;
    return initialWeight / (heightInMeters * heightInMeters);
  }

  // BMI 카테고리
  String getBMICategory() {
    double bmi = getBMI();
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'normal';
    if (bmi < 30) return 'overweight';
    return 'obese';
  }

  // ClothingColors 객체 반환
  ClothingColors getClothingColors() {
    if (clothingColors == null) {
      return ClothingColors.defaultColors;
    }
    return ClothingColors.fromJson(clothingColors!);
  }

  /// BodyComposition 객체 반환 (JSON에서 변환)
  BodyComposition? getBodyComposition() {
    if (bodyCompositionData == null) return null;
    
    try {
      return BodyComposition(
        muscleType: bodyCompositionData!['muscleType'] as String? ?? 'medium',
        fatGainPattern: Map<String, int>.from(
          bodyCompositionData!['fatGainPattern'] as Map? ?? {}
        ),
        fatLossPattern: Map<String, int>.from(
          bodyCompositionData!['fatLossPattern'] as Map? ?? {}
        ),
        currentBodyFat: bodyCompositionData!['currentBodyFat'] != null
            ? Map<String, double>.from(
                bodyCompositionData!['currentBodyFat'] as Map
              )
            : null,
      );
    } catch (e) {
      return null;
    }
  }

  /// BodyComposition 객체를 JSON으로 저장
  void setBodyComposition(BodyComposition composition) {
    bodyCompositionData = {
      'muscleType': composition.muscleType,
      'fatGainPattern': composition.fatGainPattern,
      'fatLossPattern': composition.fatLossPattern,
      'currentBodyFat': composition.currentBodyFat,
    };
  }

  /// Somatotype Enum 반환
  Somatotype getSomatotype() {
    if (somatotype == null) return Somatotype.mixed;
    return Somatotype.fromString(somatotype!);
  }

  /// BodyShape Enum 반환
  BodyShape getBodyShape() {
    if (bodyShape == null) {
      // 성별 기반 기본값
      return gender.toLowerCase() == 'female' 
          ? BodyShape.pear 
          : BodyShape.rectangle;
    }
    return BodyShape.fromString(bodyShape!);
  }

  UserProfile copyWith({
    String? name,
    double? height,
    double? initialWeight,
    String? gender,
    int? age,
    String? activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, int>? clothingColors,
    String? somatotype,
    String? bodyShape,
    Map<String, int>? personalityTraits,
    Map<String, dynamic>? bodyCompositionData,
  }) {
    return UserProfile(
      name: name ?? this.name,
      height: height ?? this.height,
      initialWeight: initialWeight ?? this.initialWeight,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clothingColors: clothingColors ?? this.clothingColors,
      somatotype: somatotype ?? this.somatotype,
      bodyShape: bodyShape ?? this.bodyShape,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      bodyCompositionData: bodyCompositionData ?? this.bodyCompositionData,
    );
  }
}
