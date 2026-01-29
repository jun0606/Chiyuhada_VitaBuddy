import 'package:hive/hive.dart';
import '../avatar/clothing_colors.dart';
import '../services/enhanced_metabolism_calculator.dart';
import 'body_composition.dart';
import 'body_types.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class SleepConfig {
  /// 수면 모드 ('manual', 'device', 'hybrid')
  @HiveField(0)
  final String mode;

  /// 수동 수면 시작 시간 (HH:mm)
  @HiveField(1)
  final String manualSleepTime;

  /// 수동 기상 시간 (HH:mm)
  @HiveField(2)
  final String manualWakeTime;

  /// 마지막 기기 동기화 시간 (Milliseconds since epoch)
  @HiveField(3)
  final int? lastDeviceSyncTime;

  const SleepConfig({
    this.mode = 'hybrid',
    this.manualSleepTime = '23:00',
    this.manualWakeTime = '07:00',
    this.lastDeviceSyncTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'manualSleepTime': manualSleepTime,
      'manualWakeTime': manualWakeTime,
      'lastDeviceSyncTime': lastDeviceSyncTime,
    };
  }

  factory SleepConfig.fromJson(Map<String, dynamic> json) {
    return SleepConfig(
      mode: json['mode'] ?? 'hybrid',
      manualSleepTime: json['manualSleepTime'] ?? '23:00',
      manualWakeTime: json['manualWakeTime'] ?? '07:00',
      lastDeviceSyncTime: json['lastDeviceSyncTime'],
    );
  }

  SleepConfig copyWith({
    String? mode,
    String? manualSleepTime,
    String? manualWakeTime,
    int? lastDeviceSyncTime,
  }) {
    return SleepConfig(
      mode: mode ?? this.mode,
      manualSleepTime: manualSleepTime ?? this.manualSleepTime,
      manualWakeTime: manualWakeTime ?? this.manualWakeTime,
      lastDeviceSyncTime: lastDeviceSyncTime ?? this.lastDeviceSyncTime,
    );
  }
}

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

  /// 식사 패턴 정보 (하루 식사 횟수, 시간 등)
  /// 구조: {'mealsPerDay': 3, 'meals': [...], 'snacks': [...]}
  @HiveField(13)
  Map<String, dynamic>? mealPattern;

  /// 에너지 알림 민감도 설정
  /// 'low': 덜 민감 (알림 적게)
  /// 'normal': 보통 (기본값)
  /// 'high': 더 민감 (알림 많이)
  @HiveField(14)
  String? alertSensitivity;

  /// 수면 설정
  @HiveField(15)
  SleepConfig sleepConfig;

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
    this.mealPattern,
    this.alertSensitivity,
    this.sleepConfig = const SleepConfig(),
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
          bodyCompositionData!['fatGainPattern'] as Map? ?? {},
        ),
        fatLossPattern: Map<String, int>.from(
          bodyCompositionData!['fatLossPattern'] as Map? ?? {},
        ),
        currentBodyFat: bodyCompositionData!['currentBodyFat'] != null
            ? Map<String, double>.from(
                bodyCompositionData!['currentBodyFat'] as Map,
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

  /// 식사 패턴 정보 반환
  Map<String, dynamic>? getMealPattern() {
    return mealPattern;
  }

  /// 식사 패턴 저장
  void setMealPattern(Map<String, dynamic> pattern) {
    mealPattern = pattern;
    updatedAt = DateTime.now();
  }

  /// 활성화된 식사 목록 반환
  List<Map<String, dynamic>> getEnabledMeals() {
    if (mealPattern == null) return [];

    final meals = mealPattern!['meals'] as List?;
    if (meals == null) return [];

    return meals
        .where((meal) => meal['enabled'] == true)
        .map((meal) => meal as Map<String, dynamic>)
        .toList();
  }

  /// 식사 패턴이 설정되었는지 확인
  bool hasMealPattern() {
    return mealPattern != null && mealPattern!.isNotEmpty;
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
    Map<String, dynamic>? mealPattern,
    String? alertSensitivity,
    SleepConfig? sleepConfig,
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
      mealPattern: mealPattern ?? this.mealPattern,
      alertSensitivity: alertSensitivity ?? this.alertSensitivity,
      sleepConfig: sleepConfig ?? this.sleepConfig,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'height': height,
      'initialWeight': initialWeight, // ✅ 올바른 필드명 사용
      'gender': gender,
      'activityLevel': activityLevel,
      'somatotype': somatotype,
      'bodyShape': bodyShape,
      'personalityTraits': personalityTraits,
      'bodyCompositionData': bodyCompositionData, // ✅ 올바른 JSON 키 사용
      'mealPattern': mealPattern,
      'alertSensitivity': alertSensitivity,
      'clothingColors': clothingColors,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'sleepConfig': sleepConfig.toJson(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      age: json['age'],
      height: json['height'],
      initialWeight: json['initialWeight'] ?? json['weight'], // ✅ 호환성 유지
      gender: json['gender'],
      activityLevel: json['activityLevel'],
      somatotype: json['somatotype'],
      bodyShape: json['bodyShape'],
      personalityTraits: json['personalityTraits'] != null
          ? Map<String, int>.from(json['personalityTraits'])
          : null,
      bodyCompositionData: json['bodyCompositionData'] != null
          ? Map<String, dynamic>.from(json['bodyCompositionData'])
          : json['bodyComposition'] !=
                null // ✅ 구버전 호환성
          ? Map<String, dynamic>.from(json['bodyComposition'])
          : null,
      mealPattern: json['mealPattern'] != null
          ? Map<String, dynamic>.from(json['mealPattern'])
          : null,
      alertSensitivity: json['alertSensitivity'],
      clothingColors: json['clothingColors'] != null
          ? Map<String, int>.from(json['clothingColors'])
          : null,
      sleepConfig: json['sleepConfig'] != null
          ? SleepConfig.fromJson(json['sleepConfig'])
          : const SleepConfig(),
    );
  }
}
