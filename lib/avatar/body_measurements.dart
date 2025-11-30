import 'clothing_colors.dart';

enum LifestylePattern {
  sedentary, // 좌식 (운동 부족)
  active,    // 활동적 (일반)
  athletic,  // 운동선수 (근육형)
}

/// 신체 치수 계산 클래스
/// BMI, 키, 성별, 생활 패턴을 입력받아 각 신체 부위의 구체적인 크기를 계산합니다.
class BodyMeasurements {
  final double bmi;
  final double height;
  final String gender;
  final LifestylePattern lifestyle;
  final ClothingColors clothingColors;

  late final double scale;
  late final double shoulderWidth;
  late final double chestWidth;
  late final double waistWidth;
  late final double hipWidth;
  late final double thighWidth;
  late final double calfWidth;
  late final double armWidth;
  late final double headSize;
  late final double neckWidth;

  // 세로 길이 (비율)
  late final double headHeight;
  late final double neckHeight;
  late final double torsoHeight;
  late final double legLength;
  late final double armLength;
  late final double forearmLength;
  late final double elbowWidth;
  late final double wristWidth;
  late final double thighLength;
  late final double calfLength;
  late final double kneeWidth;
  late final double ankleWidth;
  
  // 복부 깊이 (앞뒤 방향 돌출)
  late final double bellyDepth;
  
  // 성별 특화 치수
  late final double breastSize; // 여성 가슴 크기
  
  // 체형 계수 (렌더링용)
  late final double fatFactor;
  late final double muscleFactor;

  BodyMeasurements({
    required this.bmi,
    required this.height,
    required this.gender,
    this.lifestyle = LifestylePattern.active,
    this.clothingColors = ClothingColors.defaultColors,
  }) {
    _calculateDimensions();
  }

  void _calculateDimensions() {
    // 1. 기본 스케일 (170cm 기준)
    scale = height / 170.0;

    // 2. 비만도 및 근육량 계수 계산
    // 로컬 변수가 아닌 인스턴스 변수에 할당
    double rawFatFactor = (bmi - 22.0).clamp(-10.0, 30.0);
    double rawMuscleFactor = 0.0;

    switch (lifestyle) {
      case LifestylePattern.sedentary:
        rawFatFactor *= 1.2;
        rawMuscleFactor = -2.0;
        break;
      case LifestylePattern.active:
        rawMuscleFactor = 2.0;
        break;
      case LifestylePattern.athletic:
        rawFatFactor *= 0.8;
        rawMuscleFactor = 8.0;
        break;
    }
    
    fatFactor = rawFatFactor;
    muscleFactor = rawMuscleFactor;

    // 3. 부위별 치수 계산 (단위: 픽셀, scale 적용 전 기본값)
    
    // 머리 (현실적인 비율로 축소: 8등신 기준 헤드 높이 ~22cm -> 반지름 ~11)
    // User Feedback: Head is too small. Increasing to ~14.0 (Radius) -> Diameter 28.0 (~1/6.5 ratio)
    headSize = (14.0 + (fatFactor * 0.05).clamp(0.0, 2.0)) * scale;
    headHeight = headSize * 2.2; // 얼굴 세로 길이

    // 목 (성별별 차별화)
    double baseNeck = gender == 'male' ? 3.8 : 3.9; // 남성: 3.8, 여성: 3.9 (자연스러운 두께)
    neckWidth = (baseNeck + (fatFactor * 0.06) + (muscleFactor * 0.08)) * scale;
    neckHeight = 12.0 * scale; // 목 길이 조정 (User Feedback: Neck missing)

    // 어깨 (남녀 차이 + 근육 영향)
    // 여성 어깨를 좀 더 좁게 (38 -> 36)
    double baseShoulder = gender == 'male' ? 45.0 : 36.0;
    shoulderWidth = (baseShoulder + (fatFactor * 0.3) + (muscleFactor * 0.8)) * scale;

    // 가슴
    double baseChest = gender == 'male' ? 40.0 : 36.0; // 여성 흉곽 자체는 작음
    chestWidth = (baseChest + (fatFactor * 0.5) + (muscleFactor * 0.5)) * scale;

    // 허리 (지방 영향 큼)
    // 여성 허리 더 잘록하게 (28 -> 26)
    double baseWaist = gender == 'male' ? 32.0 : 26.0;
    waistWidth = (baseWaist + (fatFactor * 1.2).clamp(-5.0, 50.0)) * scale;

    // 골반 (여성이 더 큼)
    // 여성 골반 더 넓게 (42 -> 44)
    double baseHip = gender == 'male' ? 34.0 : 44.0;
    hipWidth = (baseHip + (fatFactor * 0.8) + (muscleFactor * 0.2)) * scale;

    // 복부 돌출 계산 (BMI와 생활 패턴 기반)
    double baseBelly = 0.0; // 기본값: 평평
    if (bmi > 25) {
      // 과체중: 배가 나옴
      baseBelly = ((bmi - 25) * 2.0).clamp(0.0, 20.0);
    } else if (bmi < 18.5) {
      // 저체중: 배가 약간 들어감
      baseBelly = ((bmi - 18.5) * 1.5).clamp(-5.0, 0.0);
    }

    // 생활 패턴 보정
    switch (lifestyle) {
      case LifestylePattern.sedentary:
        baseBelly += 3.0; // 좌식 생활: 배가 더 나옴
        break;
      case LifestylePattern.athletic:
        baseBelly -= 2.0; // 운동선수: 복근으로 평평
        break;
      default:
        break;
    }

    bellyDepth = baseBelly * scale;

    // 팔 (근육 영향)
    double baseArm = 10.0; // 팔 두께 약간 감소
    armWidth = (baseArm + (fatFactor * 0.3) + (muscleFactor * 0.4)) * scale;
    elbowWidth = armWidth * 0.85; // 팔꿈치는 조금 얇음
    wristWidth = armWidth * 0.6;  // 손목은 더 얇음
    
    // 팔 길이 분할 (총 길이 증가: 65 -> 70)
    armLength = 34.0 * scale; // 상완
    forearmLength = 36.0 * scale; // 전완

    // 허벅지 (지방 + 근육 영향)
    double baseThigh = 16.0;
    thighWidth = (baseThigh + (fatFactor * 0.5) + (muscleFactor * 0.6)) * scale;
    kneeWidth = thighWidth * 0.7; // 무릎
    thighLength = 48.0 * scale; // 허벅지 길이 증가
    
    // 종아리
    double baseCalf = 12.0;
    calfWidth = (baseCalf + (fatFactor * 0.3) + (muscleFactor * 0.4)) * scale;
    ankleWidth = calfWidth * 0.6; // 발목
    calfLength = 45.0 * scale; // 종아리 길이 증가
    
    legLength = thighLength + calfLength; // 전체 다리 길이 (93.0)

    // 몸통 길이 (조정: 75 -> 60, 골반 별도 고려)
    torsoHeight = 60.0 * scale;
    
    // 성별 특화 치수
    if (gender == 'female') {
      // 여성 가슴 크기 (BMI와 지방 비율 반영, 현실적인 크기로 조정)
      breastSize = (10.0 + (fatFactor * 0.3).clamp(0, 6)) * scale;
    } else {
      breastSize = 0.0; // 남성은 0
    }
  }
  
  // 편의를 위한 게터
  double get totalArmLength => armLength + forearmLength;
  
  // 둘레 측정 (렌더링용)
  double get thighCircumference => thighWidth * 2;
  double get calfCircumference => calfWidth * 2;
  
  /// copyWith 메서드 - 일부 속성만 변경
  BodyMeasurements copyWith({
    double? shoulderWidth,
    double? chestWidth,
    double? waistWidth,
    double? hipWidth,
    double? thighCircumference,
    double? calfCircumference,
    double? breastSize,
  }) {
    // 새 인스턴스 생성 후 속성 직접 수정
    final copy = BodyMeasurements(
      bmi: bmi,
      height: height,
      gender: gender,
      lifestyle: lifestyle,
      clothingColors: clothingColors,
    );
    
    // 선택적으로 제공된 값으로 덮어쓰기
    if (shoulderWidth != null) copy.shoulderWidth = shoulderWidth;
    if (chestWidth != null) copy.chestWidth = chestWidth;
    if (waistWidth != null) copy.waistWidth = waistWidth;
    if (hipWidth != null) copy.hipWidth = hipWidth;
    if (thighCircumference != null) {
      copy.thighWidth = thighCircumference / 2;
    }
    if (calfCircumference != null) {
      copy.calfWidth = calfCircumference / 2;
    }
    if (breastSize != null) copy.breastSize = breastSize;
    
    return copy;
  }
  
  /// BMI, 키, 성별로 기본 측정값 생성
  factory BodyMeasurements.fromBMI(
    double bmi,
    double height,
    String gender, {
    LifestylePattern lifestyle = LifestylePattern.active,
    ClothingColors? clothingColors,
  }) {
    return BodyMeasurements(
      bmi: bmi,
      height: height,
      gender: gender,
      lifestyle: lifestyle,
      clothingColors: clothingColors ?? ClothingColors.defaultColors,
    );
  }
}
