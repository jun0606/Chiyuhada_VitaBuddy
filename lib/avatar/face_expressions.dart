import 'dart:ui';

/// 얼굴 표정 타입
enum FaceExpressionType {
  neutral, // 중립
  happy, // 웃음
  welcome, // 환영
  full, // 배부름
  hungry, // 배고픔
  tired, // 힘듦 (BMI 높을 때)
  satisfied, // 만족 (적절한 칼로리)
  stuffed, // 과식 (너무 많이 먹음)
  refuse, // 거부 (음식 거부 - 과체중용)
  warning, // 경고 (조심 - 보통 체중용)
  greeting, // 인사 (환영 - 정상 체중용)
}

/// 얼굴 표정 데이터 클래스
class FaceExpression {
  final double eyeScale; // 눈 크기 배율 (0.0-1.0)
  final double mouthCurve; // 입 곡선 정도 (-1.0: 아래로, 0.0: 직선, 1.0: 위로)
  final double mouthWidth; // 입 너비 배율 (0.5-1.5)
  final double eyebrowAngle; // 눈썹 각도 (라디안)
  final double eyelidHeight; // 눈꺼풀 높이 (0.0: 완전 감음, 1.0: 완전 뜸)
  final Color eyeColor; // 눈동자 색상
  final bool eyeSparkle; // 눈 반짝임 효과

  const FaceExpression({
    required this.eyeScale,
    required this.mouthCurve,
    required this.mouthWidth,
    required this.eyebrowAngle,
    required this.eyelidHeight,
    required this.eyeColor,
    this.eyeSparkle = false, // 기본값: 반짝임 없음
  });

  /// 중립 표정
  static const FaceExpression neutral = FaceExpression(
    eyeScale: 1.0,
    mouthCurve: 0.0,
    mouthWidth: 1.0,
    eyebrowAngle: 0.0,
    eyelidHeight: 1.0,
    eyeColor: Color(0xFF000000),
  );

  /// 웃는 표정
  static const FaceExpression happy = FaceExpression(
    eyeScale: 0.8,
    mouthCurve: 0.8,
    mouthWidth: 1.2,
    eyebrowAngle: 0.3,
    eyelidHeight: 0.9,
    eyeColor: Color(0xFF000000),
  );

  /// 환영하는 표정
  static const FaceExpression welcome = FaceExpression(
    eyeScale: 1.2,
    mouthCurve: 0.2,
    mouthWidth: 1.1,
    eyebrowAngle: 0.4,
    eyelidHeight: 1.0,
    eyeColor: Color(0xFF0066CC),
  );

  /// 배부른 표정
  static const FaceExpression full = FaceExpression(
    eyeScale: 0.9,
    mouthCurve: -0.1,
    mouthWidth: 1.3,
    eyebrowAngle: -0.2,
    eyelidHeight: 0.6,
    eyeColor: Color(0xFF000000),
  );

  /// 배고픈 표정
  static const FaceExpression hungry = FaceExpression(
    eyeScale: 1.3,
    mouthCurve: 0.1,
    mouthWidth: 1.4,
    eyebrowAngle: 0.5,
    eyelidHeight: 1.0,
    eyeColor: Color(0xFF000000),
  );

  /// 힘든 표정 (BMI 높을 때)
  static const FaceExpression tired = FaceExpression(
    eyeScale: 0.85, // 눈 살짝 작아짐 (힘들어 보임)
    mouthCurve: -0.3, // 입 살짝 벌어짐 (헐떡이는 느낌)
    mouthWidth: 1.0, // 입 너비 보통
    eyebrowAngle: -0.5, // 눈썹 아래로 처짐 (지친 표정)
    eyelidHeight: 0.7, // 눈꺼풀 살짝 감김 (피곤해 보임)
    eyeColor: Color(0xFF666666), // 눈동자 흐릿하게 (무기력한 느낌)
  );

  /// 만족스러운 표정 (적절한 칼로리)
  static const FaceExpression satisfied = FaceExpression(
    eyeScale: 1.0,
    mouthCurve: 0.2, // 0.2 → 0.0 (입술 수평)
    mouthWidth: 1.1,
    eyebrowAngle: 0.2, // 살짝 올라간 눈썹
    eyelidHeight: 0.95, // 편안하게 눈 뜬 상태
    eyeColor: Color(0xFF000000),
  );

  /// 과식한 표정 (너무 많이 먹음)
  static const FaceExpression stuffed = FaceExpression(
    eyeScale: 0.75, // 눈 감김 (힘들어 보임)
    mouthCurve: -0.4, // 입 아래로 (괴로운 표정)
    mouthWidth: 1.2,
    eyebrowAngle: -0.6, // 눈썹 처짐
    eyelidHeight: 0.5, // 눈 거의 감김
    eyeColor: Color(0xFF444444), // 흐릿한 눈동자
  );

  /// 거부하는 표정 (음식 거부 - 과체중용)
  static const FaceExpression refuse = FaceExpression(
    eyeScale: 0.9,
    mouthCurve: -0.5, // 입 아래로 (싫은 표정)
    mouthWidth: 0.8, // 입 작게
    eyebrowAngle: -0.4, // 눈썹 찌푸림
    eyelidHeight: 0.8, // 눈 약간 감김
    eyeColor: Color(0xFF555555),
  );

  /// 경고하는 표정 (조심 - 보통 체중용)
  static const FaceExpression warning = FaceExpression(
    eyeScale: 1.1, // 눈 크게 (주의)
    mouthCurve: 0.0, // 입 일자
    mouthWidth: 0.9,
    eyebrowAngle: 0.6, // 눈썹 올림 (놀람)
    eyelidHeight: 1.0, // 눈 크게 뜸
    eyeColor: Color(0xFFFF6600), // 주황색 (경고)
  );

  /// 인사하는 표정 (환영) - 부드럽고 귀여운
  static const FaceExpression greeting = FaceExpression(
    eyeScale: 1.2, // 눈 크게 (welcome과 동일)
    mouthCurve: 0.45, // 0.35 -> 0.45 (더 예쁜 곡선)
    mouthWidth: 0.95, // 1.05 -> 0.95 (작고 귀엽게)
    eyebrowAngle: 0.4, // 눈썹 올림 (welcome과 동일)
    eyelidHeight: 1.0, // 눈 크게 뜸 (welcome과 동일)
    eyeColor: Color(0xFF000000), // 검은색 (자연스러운 눈동자)
    eyeSparkle: true, // 눈 반짝임 효과 활성화
  );
}

/// 얼굴 표정 계산기
class FaceExpressionCalculator {
  /// 표정 타입에 따른 표정 데이터 반환
  static FaceExpression getExpression(FaceExpressionType type) {
    switch (type) {
      case FaceExpressionType.happy:
        return FaceExpression.happy;
      case FaceExpressionType.welcome:
        return FaceExpression.welcome;
      case FaceExpressionType.full:
        return FaceExpression.full;
      case FaceExpressionType.hungry:
        return FaceExpression.hungry;
      case FaceExpressionType.tired:
        return FaceExpression.tired;
      case FaceExpressionType.satisfied:
        return FaceExpression.satisfied;
      case FaceExpressionType.stuffed:
        return FaceExpression.stuffed;
      case FaceExpressionType.refuse:
        return FaceExpression.refuse;
      case FaceExpressionType.warning:
        return FaceExpression.warning;
      case FaceExpressionType.greeting:
        return FaceExpression.greeting;
      case FaceExpressionType.neutral:
      default:
        return FaceExpression.neutral;
    }
  }

  /// 시간 기반으로 깜빡임 효과 추가
  static FaceExpression addBlinkEffect(
    FaceExpression baseExpression,
    double time,
  ) {
    // 3-5초마다 깜빡임
    final blinkCycle = (time * 0.3) % (2 * 3.14159);
    final blinkFactor = (blinkCycle < 0.2) ? 0.1 : 1.0; // 짧은 시간 동안 눈을 감음

    return FaceExpression(
      eyeScale: baseExpression.eyeScale,
      mouthCurve: baseExpression.mouthCurve,
      mouthWidth: baseExpression.mouthWidth,
      eyebrowAngle: baseExpression.eyebrowAngle,
      eyelidHeight: baseExpression.eyelidHeight * blinkFactor,
      eyeColor: baseExpression.eyeColor,
    );
  }

  /// 부드러운 표정 전환을 위한 보간
  static FaceExpression lerp(FaceExpression a, FaceExpression b, double t) {
    return FaceExpression(
      eyeScale: lerpDouble(a.eyeScale, b.eyeScale, t) ?? a.eyeScale,
      mouthCurve: lerpDouble(a.mouthCurve, b.mouthCurve, t) ?? a.mouthCurve,
      mouthWidth: lerpDouble(a.mouthWidth, b.mouthWidth, t) ?? a.mouthWidth,
      eyebrowAngle:
          lerpDouble(a.eyebrowAngle, b.eyebrowAngle, t) ?? a.eyebrowAngle,
      eyelidHeight:
          lerpDouble(a.eyelidHeight, b.eyelidHeight, t) ?? a.eyelidHeight,
      eyeColor: Color.lerp(a.eyeColor, b.eyeColor, t) ?? a.eyeColor,
    );
  }
}
