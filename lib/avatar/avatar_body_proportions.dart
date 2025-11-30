import '../models/user_profile.dart';
import '../models/body_types.dart';
import 'body_measurements.dart';

/// 아바타 체형 비율 조정 서비스
/// 
/// 사용자의 체형 타입에 따라 아바타의 신체 비율을 조정합니다.
class AvatarBodyProportions {
  /// 체형이 반영된 BodyMeasurements 생성
  /// 
  /// 1. 기본 BMI 기반 측정값 생성
  /// 2. 체형 타입에 따라 비율 조정
  static BodyMeasurements getProportions(
    UserProfile profile,
    double bmi,
  ) {
    // 1. 기본 BMI 기반 비율
    final baseMeasurements = BodyMeasurements.fromBMI(
      bmi,
      profile.height,
      profile.gender,
    );

    // 2. 체형 보정 적용
    final bodyShape = profile.getBodyShape();
    return _applyBodyShapeModifier(baseMeasurements, bodyShape);
  }

  /// 체형별 비율 보정 적용
  static BodyMeasurements _applyBodyShapeModifier(
    BodyMeasurements base,
    BodyShape bodyShape,
  ) {
    switch (bodyShape) {
      case BodyShape.apple:
        // 사과형: 상체 비대, 하체 가늘음
        return base.copyWith(
          shoulderWidth: base.shoulderWidth * 1.10, // +10% 어깨
          chestWidth: base.chestWidth * 1.15, // +15% 가슴
          waistWidth: base.waistWidth * 1.20, // +20% 허리 (복부 강조)
          hipWidth: base.hipWidth * 0.95, // -5% 엉덩이
          thighCircumference: base.thighCircumference * 0.90, // -10% 허벅지
        );

      case BodyShape.pear:
        // 배형: 하체 비대, 상체 가늘음
        return base.copyWith(
          shoulderWidth: base.shoulderWidth * 0.95, // -5% 어깨
          chestWidth: base.chestWidth * 0.90, // -10% 가슴
          waistWidth: base.waistWidth * 0.85, // -15% 허리 (잘록함)
          hipWidth: base.hipWidth * 1.20, // +20% 엉덩이
          thighCircumference: base.thighCircumference * 1.15, // +15% 허벅지
        );

      case BodyShape.hourglass:
        // 모래시계형: 가슴/엉덩이 크고, 허리 잘록함
        return base.copyWith(
          chestWidth: base.chestWidth * 1.10, // +10% 가슴
          waistWidth: base.waistWidth * 0.80, // -20% 허리 (강조된 곡선)
          hipWidth: base.hipWidth * 1.10, // +10% 엉덩이
        );

      case BodyShape.rectangle:
        // 직사각형: 평면적, 곡선 적음
        return base.copyWith(
          waistWidth: base.waistWidth * 1.05, // +5% 허리 (곡선 감소)
        );

      case BodyShape.invertedTriangle:
        // 역삼각형: 넓은 어깨, 좁은 엉덩이
        return base.copyWith(
          shoulderWidth: base.shoulderWidth * 1.15, // +15% 어깨
          chestWidth: base.chestWidth * 1.10, // +10% 가슴
          waistWidth: base.waistWidth * 0.95, // -5% 허리
          hipWidth: base.hipWidth * 0.90, // -10% 엉덩이
        );

      default:
        return base;
    }
  }

  /// 체중 변화 시뮬레이션
  /// 
  /// 체중 변화량과 체형 패턴에 따라 부위별 변화량을 계산합니다.
  /// 
  /// @param profile 사용자 프로필
  /// @param currentWeight 현재 체중
  /// @param targetWeight 목표 체중
  /// @return 부위별 변화 비율 맵
  static Map<String, double> simulateWeightChange(
    UserProfile profile,
    double currentWeight,
    double targetWeight,
  ) {
    final weightChange = targetWeight - currentWeight;
    final bodyComposition = profile.getBodyComposition();

    if (bodyComposition == null) {
      // 기본: 균등 분포
      return {
        'chest': weightChange * 0.20,
        'waist': weightChange * 0.30,
        'hips': weightChange * 0.25,
        'thighs': weightChange * 0.25,
      };
    }

    // 체중 증가 vs 감소에 따라 다른 패턴 사용
    final pattern = weightChange > 0
        ? bodyComposition.fatGainPattern
        : bodyComposition.fatLossPattern;

    return _distributeWeightChange(weightChange.abs(), pattern);
  }

  /// 부위별 체중 변화 분배
  /// 
  /// 우선순위 패턴에 따라 체중 변화를 부위별로 분배합니다.
  /// 
  /// 우선순위 가중치:
  /// - 1순위: 50%
  /// - 2순위: 25%
  /// - 3순위: 15%
  /// - 나머지: 10% 균등 분배
  static Map<String, double> _distributeWeightChange(
    double weight,
    Map<String, int> pattern,
  ) {
    Map<String, double> distribution = {};

    // 우선순위별 부위 그룹화
    Map<int, List<String>> priorityGroups = {};
    pattern.forEach((part, priority) {
      priorityGroups.putIfAbsent(priority, () => []).add(part);
    });

    // 우선순위 1-3을 처리
    double remainingWeight = weight;
    
    // 1순위: 50%
    if (priorityGroups.containsKey(1)) {
      final parts = priorityGroups[1]!;
      final perPart = (weight * 0.50) / parts.length;
      for (var part in parts) {
        distribution[part] = perPart;
      }
      remainingWeight -= weight * 0.50;
    }

    // 2순위: 25%
    if (priorityGroups.containsKey(2)) {
      final parts = priorityGroups[2]!;
      final perPart = (weight * 0.25) / parts.length;
      for (var part in parts) {
        distribution[part] = perPart;
      }
      remainingWeight -= weight * 0.25;
    }

    // 3순위: 15%
    if (priorityGroups.containsKey(3)) {
      final parts = priorityGroups[3]!;
      final perPart = (weight * 0.15) / parts.length;
      for (var part in parts) {
        distribution[part] = perPart;
      }
      remainingWeight -= weight * 0.15;
    }

    // 나머지 부위들: 남은 10%를 균등 분배
    final otherParts = pattern.keys.where((part) {
      final priority = pattern[part]!;
      return priority > 3;
    }).toList();

    if (otherParts.isNotEmpty) {
      final perPart = remainingWeight / otherParts.length;
      for (var part in otherParts) {
        distribution[part] = perPart;
      }
    }

    return distribution;
  }

  /// 체형별 특징 설명
  static String getBodyShapeDescription(BodyShape shape) {
    switch (shape) {
      case BodyShape.apple:
        return '체중 증가 시 복부가 먼저 나오며, 감량 시 복부가 가장 늦게 빠집니다.';
      case BodyShape.pear:
        return '체중 증가 시 하체가 먼저 두꺼워지며, 감량 시 상체부터 빠집니다.';
      case BodyShape.hourglass:
        return '체중 변화 시 전신이 균등하게 변화하며 곡선을 유지합니다.';
      case BodyShape.rectangle:
        return '체중 변화 시 전체적으로 균등하게 변화합니다.';
      case BodyShape.invertedTriangle:
        return '넓은 어깨와 좁은 엉덩이가 특징이며, 상체 위주로 변화합니다.';
    }
  }
}
