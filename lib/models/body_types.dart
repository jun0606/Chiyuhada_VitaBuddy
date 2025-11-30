/// 체질 타입 (Somatotype)
enum Somatotype {
  /// 외배엽형 - 마른 체질, 빠른 대사
  ectomorph,

  /// 중배엽형 - 근육형 체질, 표준 대사
  mesomorph,

  /// 내배엽형 - 살찌기 쉬운 체질, 느린 대사
  endomorph,

  /// 혼합형 또는 알 수 없음
  mixed;

  /// 화면 표시용 한글 이름
  String get displayName {
    switch (this) {
      case Somatotype.ectomorph:
        return '외배엽형 (마른 체질)';
      case Somatotype.mesomorph:
        return '중배엽형 (근육 체질)';
      case Somatotype.endomorph:
        return '내배엽형 (살찌기 쉬운 체질)';
      case Somatotype.mixed:
        return '혼합형';
    }
  }

  /// 설명
  String get description {
    switch (this) {
      case Somatotype.ectomorph:
        return '빠른 신진대사로 살이 잘 안 찌지만, 근육을 만들기 어렵습니다.';
      case Somatotype.mesomorph:
        return '근육을 쉽게 만들고, 체중 조절이 비교적 용이합니다.';
      case Somatotype.endomorph:
        return '지방이 쉽게 축적되고, 체중 감량이 어려울 수 있습니다.';
      case Somatotype.mixed:
        return '여러 체질의 특성을 가지고 있습니다.';
    }
  }

  /// BMR 보정 계수
  double get bmrModifier {
    switch (this) {
      case Somatotype.ectomorph:
        return 1.07; // +7%
      case Somatotype.mesomorph:
        return 1.00; // 표준
      case Somatotype.endomorph:
        return 0.93; // -7%
      case Somatotype.mixed:
        return 1.00;
    }
  }

  /// 문자열로부터 Enum 변환
  static Somatotype fromString(String value) {
    switch (value.toLowerCase()) {
      case 'ectomorph':
        return Somatotype.ectomorph;
      case 'mesomorph':
        return Somatotype.mesomorph;
      case 'endomorph':
        return Somatotype.endomorph;
      default:
        return Somatotype.mixed;
    }
  }
}

/// 체형 타입 (Body Shape)
enum BodyShape {
  /// 사과형 - 상체 비만
  apple,

  /// 배형 - 하체 비만
  pear,

  /// 모래시계형 - 균형형
  hourglass,

  /// 직사각형 - 평면적
  rectangle,

  /// 역삼각형 - 넓은 어깨
  invertedTriangle;

  /// 화면 표시용 한글 이름
  String get displayName {
    switch (this) {
      case BodyShape.apple:
        return '🍎 사과형';
      case BodyShape.pear:
        return '🍐 배형';
      case BodyShape.hourglass:
        return '⏳ 모래시계형';
      case BodyShape.rectangle:
        return '📏 직사각형';
      case BodyShape.invertedTriangle:
        return '🔺 역삼각형';
    }
  }

  /// 설명
  String get description {
    switch (this) {
      case BodyShape.apple:
        return '상체와 복부에 지방이 주로 축적됩니다.';
      case BodyShape.pear:
        return '하체(엉덩이, 허벅지)에 지방이 주로 축적됩니다.';
      case BodyShape.hourglass:
        return '가슴과 엉덩이가 비슷하고 허리가 잘록합니다.';
      case BodyShape.rectangle:
        return '전체적으로 평면적이고 균등한 체형입니다.';
      case BodyShape.invertedTriangle:
        return '어깨가 넓고 엉덩이가 좁은 체형입니다.';
    }
  }

  /// 문자열로부터 Enum 변환
  static BodyShape fromString(String value) {
    switch (value.toLowerCase()) {
      case 'apple':
        return BodyShape.apple;
      case 'pear':
        return BodyShape.pear;
      case 'hourglass':
        return BodyShape.hourglass;
      case 'rectangle':
        return BodyShape.rectangle;
      case 'inverted_triangle':
      case 'invertedtriangle':
        return BodyShape.invertedTriangle;
      default:
        return BodyShape.rectangle;
    }
  }
}

/// 근육 타입
enum MuscleType {
  /// 낮음
  low,

  /// 보통
  medium,

  /// 높음
  high;

  /// 화면 표시용 한글 이름
  String get displayName {
    switch (this) {
      case MuscleType.low:
        return '적음';
      case MuscleType.medium:
        return '보통';
      case MuscleType.high:
        return '많음';
    }
  }

  /// BMR 보정 계수
  double get bmrModifier {
    switch (this) {
      case MuscleType.low:
        return 0.97; // -3%
      case MuscleType.medium:
        return 1.00; // 표준
      case MuscleType.high:
        return 1.05; // +5%
    }
  }

  /// 문자열로부터 Enum 변환
  static MuscleType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return MuscleType.low;
      case 'high':
        return MuscleType.high;
      default:
        return MuscleType.medium;
    }
  }
}
