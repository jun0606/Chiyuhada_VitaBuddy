
/// 신체 포즈 타입
///
/// 칼로리 상태와 감정에 따른 바디 랭귀지 표현
enum BodyPose {
  /// 중립 자세 (기본)
  neutral,

  /// 배 만지기 (배고픔)
  touchBelly,

  /// 팔 올리기 (기쁨, 목표 달성)
  armsUp,

  /// 인사 (정상 목표 달성)
  greeting,

  /// 스트레칭 (안도, 과체중 목표 달성)
  stretch,

  /// 거부 (과식 경고)
  refuse,

  /// 환호 (만세)
  cheer,

  /// 손 흔들기
  waveHand,

  /// 승리 (슈퍼맨 포즈)
  victory,

  /// 앞으로 숙이기 (사용 중지됨 - 호환성 유지)
  bendForward,

  /// 고개 숙이기 (사용 중지됨 - 호환성 유지)
  headDown,
}

/// 포즈 키프레임 (시퀀스의 한 단계)
class PoseKeyframe {
  final BodyPoseData poseData;
  final double duration; // 이 프레임 지속 시간 (초)

  PoseKeyframe(this.poseData, this.duration);
}

/// 포즈 시퀀스 (완전한 동작 사이클)
class PoseSequence {
  final List<PoseKeyframe> keyframes;
  final bool loop; // 반복 여부
  final bool returnToNeutral; // 완료 후 중립 자세로 복귀

  PoseSequence({
    required this.keyframes,
    this.loop = false,
    this.returnToNeutral = true,
  });
}

/// 포즈별 조인트 각도 데이터
class BodyPoseData {
  // 팔 각도 (라디안)
  final double leftShoulderAngle;
  final double rightShoulderAngle;
  final double leftElbowAngle;
  final double rightElbowAngle;

  // 다리 각도
  final double leftHipAngle;
  final double rightHipAngle;
  final double leftKneeAngle;
  final double rightKneeAngle;

  // 몸통 각도
  final double torsoAngle;
  final double neckAngle;

  // 수직 오프셋 (점프용)
  final double verticalOffset;

  const BodyPoseData({
    required this.leftShoulderAngle,
    required this.rightShoulderAngle,
    required this.leftElbowAngle,
    required this.rightElbowAngle,
    required this.leftHipAngle,
    required this.rightHipAngle,
    required this.leftKneeAngle,
    required this.rightKneeAngle,
    required this.torsoAngle,
    required this.neckAngle,
    this.verticalOffset = 0.0,
  });

  /// 중립 포즈
  static const BodyPoseData neutral = BodyPoseData(
    leftShoulderAngle: 0.0,
    rightShoulderAngle: 0.0,
    leftElbowAngle: -0.2,
    rightElbowAngle: 0.2,
    leftHipAngle: 0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: 0.0,
    neckAngle: 0.0,
  );

  /// 배 만지기 (배고픔) - 양손을 배 위에
  static const BodyPoseData touchBelly = BodyPoseData(
    leftShoulderAngle: 0.3, // 0.4 → -0.3 (왼팔을 배 중앙으로)
    rightShoulderAngle: -0.4, // 유지 (오른손 정확함)
    leftElbowAngle: -1.3, // 유지
    rightElbowAngle: 1.3, // 유지
    leftHipAngle: 0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: 0.0,
    neckAngle: -0.3, // 배를 보도록
  );

  /// 팔 올리기 (기쁨) - V자 만세 (크로스 방지)
  static const BodyPoseData armsUp = BodyPoseData(
    leftShoulderAngle: 2.0, // greeting 패턴 적용 (양수)
    rightShoulderAngle: -2.0, // greeting 패턴 적용 (음수)
    leftElbowAngle: 0.1,
    rightElbowAngle: -0.1,
    leftHipAngle: 0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: 0.0,
    neckAngle: 0.2, // 고개 약간 위
  );

  /// 손 흔들기 (거부)
  static const BodyPoseData waveHand = BodyPoseData(
    leftShoulderAngle: 0.0,
    rightShoulderAngle: -1.5, // 오른손 들기
    leftElbowAngle: -0.2,
    rightElbowAngle: -0.8, // 팔꿈치 약간 굽힘
    leftHipAngle: 0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: 0.1, // 약간 기울기
    neckAngle: -0.3, // 고개 흔들기
  );

  /// 앞으로 숙이기 (힘듦, 과식)
  static const BodyPoseData bendForward = BodyPoseData(
    leftShoulderAngle: 0.8,
    rightShoulderAngle: 0.8,
    leftElbowAngle: -0.5,
    rightElbowAngle: 0.5,
    leftHipAngle: 0.3,
    rightHipAngle: 0.3,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: 0.2, // 앞으로 숙임
    neckAngle: -0.4, // 고개 아래
  );

  /// 고개 숙이기 (슬픔)
  static const BodyPoseData headDown = BodyPoseData(
    leftShoulderAngle: 0.3,
    rightShoulderAngle: 0.3,
    leftElbowAngle: -0.2,
    rightElbowAngle: 0.2,
    leftHipAngle:0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: 0.0,      // 변경: 0.2 → 0.0 (몸은 똑바로)
    neckAngle: -0.8,      // 변경: -0.6 → -0.8 (고개를 더 숙임)
  );

  /// 만세 (환호) - 크로스 방식
  static const BodyPoseData cheer = BodyPoseData(
    leftShoulderAngle: -3.4, // 왼팔 더 크게 회전
    rightShoulderAngle: 3.4, // 오른팔 더 크게 회전 (크로스)
    leftElbowAngle: 0.0, // 쭉 폄
    rightElbowAngle: 0.0,
    leftHipAngle: 0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: 0.0,
    neckAngle: 0.3, // 하늘 보기
  );

  /// 인사 (정상) - 양손 환영
  static const BodyPoseData greeting = BodyPoseData(
    leftShoulderAngle: 2.0, // 왼손 반시계방향 (부호 반전 시도)
    rightShoulderAngle: -2.0, // 오른손 시계방향 (부호 반전 시도)
    leftElbowAngle: 0.1, // 팔꿈치 거의 폄 (부호도 반전)
    rightElbowAngle: -0.1,
    leftHipAngle: 0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: 0.0,
    neckAngle: 0.15, // 고개 기울기
  );

  /// 스트레칭 (기지개) - 팔을 위로 쭉 뻗음
  static const BodyPoseData stretch = BodyPoseData(
    leftShoulderAngle: -2.8, // 팔을 위로 (약 160도)
    rightShoulderAngle: 2.8,
    leftElbowAngle: -0.1, // 팔꿈치를 거의 폄
    rightElbowAngle: 0.1,
    leftHipAngle: 0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: 0.0,
    neckAngle: 0.2, // 고개를 약간 들어 하늘 보기
  );

  /// 거부 (과식 - 그만 먹기 제스처) -> 가슴 윗부분에 양손 모으기
  static const BodyPoseData refuse = BodyPoseData(
    leftShoulderAngle: 0.3, // 왼쪽 팔을 몸에 더 가깝게
    rightShoulderAngle: -0.3, // 오른쪽 팔을 몸에서 더 멀게
    leftElbowAngle: -2.4, // 왼쪽 하박을 가슴 쪽으로 더 높이 (2.1 → 2.4)
    rightElbowAngle: 2.4, // 오른쪽 하박을 가슴 쪽으로 더 높이
    leftHipAngle: 0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: -0.2, // 몸을 뒤로 젖힘
    neckAngle: -0.1, // 고개를 약간 뒤로
  );
}

/// 포즈 계산 및 전환 도우미
class BodyPoseCalculator {
  /// 포즈 타입에 따른 포즈 데이터 반환
  static BodyPoseData getPoseData(BodyPose pose) {
    switch (pose) {
      case BodyPose.touchBelly:
        return BodyPoseData.touchBelly;
      case BodyPose.armsUp:
        return BodyPoseData.armsUp;
      case BodyPose.waveHand:
        return BodyPoseData.waveHand;
      case BodyPose.bendForward:
        return BodyPoseData.bendForward;
      case BodyPose.headDown:
        return BodyPoseData.headDown;
      case BodyPose.cheer:
        return BodyPoseData.cheer;
      case BodyPose.greeting:
        return BodyPoseData.greeting;
      case BodyPose.stretch:
        return BodyPoseData.stretch;
      case BodyPose.refuse:
        return BodyPoseData.refuse;
      case BodyPose.neutral:
      default:
        return BodyPoseData.neutral;
    }
  }

  /// 부드러운 포즈 전환을 위한 보간
  static BodyPoseData lerp(BodyPoseData start, BodyPoseData end, double t) {
    return BodyPoseData(
      leftShoulderAngle:
          start.leftShoulderAngle +
          (end.leftShoulderAngle - start.leftShoulderAngle) * t,
      rightShoulderAngle:
          start.rightShoulderAngle +
          (end.rightShoulderAngle - start.rightShoulderAngle) * t,
      leftElbowAngle:
          start.leftElbowAngle +
          (end.leftElbowAngle - start.leftElbowAngle) * t,
      rightElbowAngle:
          start.rightElbowAngle +
          (end.rightElbowAngle - start.rightElbowAngle) * t,
      leftHipAngle:
          start.leftHipAngle + (end.leftHipAngle - start.leftHipAngle) * t,
      rightHipAngle:
          start.rightHipAngle + (end.rightHipAngle - start.rightHipAngle) * t,
      leftKneeAngle:
          start.leftKneeAngle + (end.leftKneeAngle - start.leftKneeAngle) * t,
      rightKneeAngle:
          start.rightKneeAngle +
          (end.rightKneeAngle - start.rightKneeAngle) * t,
      torsoAngle: start.torsoAngle + (end.torsoAngle - start.torsoAngle) * t,
      neckAngle: start.neckAngle + (end.neckAngle - start.neckAngle) * t,
      verticalOffset:
          start.verticalOffset +
          (end.verticalOffset - start.verticalOffset) * t,
    );
  }

  /// 시퀀스 기반 포즈 반환 (완전한 동작 사이클)
  static PoseSequence? getSequence(BodyPose pose) {
    switch (pose) {
      case BodyPose.waveHand:
        return _waveHandSequence;
      case BodyPose.cheer:
        return _cheerSequence;
      case BodyPose.greeting:
        return _greetingSequence;
      case BodyPose.bendForward:
        return _bendForwardSequence;
      case BodyPose.touchBelly:
        return _touchBellySequence;
      case BodyPose.victory:
        return _victorySequence;
      default:
        return null; // 시퀀스 없음, 단일 포즈 사용
    }
  }


  // 👋 손 흔들기 시퀀스 (귀엽고 부드럽게!)
  static final PoseSequence _waveHandSequence = PoseSequence(
    keyframes: [
      // 1. 손 들기 (천천히)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.0,
          rightShoulderAngle: -1.4, // -1.5 → -1.4 (덜 높게)
          leftElbowAngle: -0.2,
          rightElbowAngle: -1.3, // -1.2 → -1.3 (살짝 더 구부림)
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.05, // 0.0 → 0.05 (살짝 기울기)
          neckAngle: 0.15, // 0.0 → 0.15 (고개 살짝 옆으로 - 귀여움!)
        ),
        0.4, // 0.3 → 0.4 (더 천천히)
      ),
      // 2. 오른쪽으로 (부드럽게)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.0,
          rightShoulderAngle: -1.4,
          leftElbowAngle: -0.2,
          rightElbowAngle: -0.9, // -0.8 → -0.9 (각도 줄임)
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.05,
          neckAngle: 0.15,
        ),
        0.25, // 0.2 → 0.25 (더 부드럽게)
      ),
      // 3. 왼쪽으로 (부드럽게)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.0,
          rightShoulderAngle: -1.4,
          leftElbowAngle: -0.2,
          rightElbowAngle: -1.5, // -1.6 → -1.5 (각도 줄임)
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.05,
          neckAngle: 0.15,
        ),
        0.25, // 0.2 → 0.25
      ),
      // 4. 오른쪽으로 (다시)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.0,
          rightShoulderAngle: -1.4,
          leftElbowAngle: -0.2,
          rightElbowAngle: -0.9,
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.05,
          neckAngle: 0.15,
        ),
        0.25,
      ),
      // 5. 왼쪽으로 (마지막)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.0,
          rightShoulderAngle: -1.4,
          leftElbowAngle: -0.2,
          rightElbowAngle: -1.5,
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.05,
          neckAngle: 0.15,
        ),
        0.25,
      ),
    ],
  );

  // 🙌 만세 시퀀스
  static final PoseSequence _cheerSequence = PoseSequence(
    keyframes: [
      // 1. 점프 + 팔 올리기 (크로스 - 크게)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: -3.4,
          rightShoulderAngle: 3.4, // 더 크게 회전
          leftElbowAngle: 0.0,
          rightElbowAngle: 0.0,
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.0,
          neckAngle: 0.0,
          verticalOffset: -40.0,
        ),
        0.3,
      ),
      // 2. 착지 (크로스 - 크게)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: -3.4,
          rightShoulderAngle: 3.4, // 더 크게 회전 유지
          leftElbowAngle: 0.0,
          rightElbowAngle: 0.0,
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.0,
          neckAngle: 0.0,
          verticalOffset: 0.0,
        ),
        0.3,
      ),
    ],
  );

  // 👋 양손 인사 시퀀스 -> 한 손 흔들기 (왼손 골반, 오른손 흔들기)
  static final PoseSequence _greetingSequence = PoseSequence(
    loop: true,
    keyframes: [
      // 1. 손 들기 (천천히)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.5, // 골반에 손
          rightShoulderAngle: -1.4,
          leftElbowAngle: -1.2, // 골반에 손
          rightElbowAngle: -1.3,
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.05,
          neckAngle: 0.15,
        ),
        0.4,
      ),
      // 2. 오른쪽으로 (부드럽게)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.5, // 골반에 손
          rightShoulderAngle: -1.4,
          leftElbowAngle: -1.2, // 골반에 손
          rightElbowAngle: -0.9,
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.05,
          neckAngle: 0.15,
        ),
        0.25,
      ),
      // 3. 왼쪽으로 (부드럽게)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.5, // 골반에 손
          rightShoulderAngle: -1.4,
          leftElbowAngle: -1.2, // 골반에 손
          rightElbowAngle: -1.5,
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.05,
          neckAngle: 0.15,
        ),
        0.25,
      ),
      // 4. 오른쪽으로 (다시)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.5, // 골반에 손
          rightShoulderAngle: -1.4,
          leftElbowAngle: -1.2, // 골반에 손
          rightElbowAngle: -0.9,
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.05,
          neckAngle: 0.15,
        ),
        0.25,
      ),
      // 5. 왼쪽으로 (마지막)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.5, // 골반에 손
          rightShoulderAngle: -1.4,
          leftElbowAngle: -1.2, // 골반에 손
          rightElbowAngle: -1.5,
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.05,
          neckAngle: 0.15,
        ),
        0.25,
      ),
    ],
  );

  /// 앞으로 숙이며 시계추처럼 좌우로 흔들림 (과식으로 힘들어함)
  static final PoseSequence _bendForwardSequence = PoseSequence(
    keyframes: [
      // 1. 왼쪽으로 기울임
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.9,
          rightShoulderAngle: 0.7,
          leftElbowAngle: -0.6,
          rightElbowAngle: 0.4,
          leftHipAngle: 0.4,    // 왼쪽에 무게
          rightHipAngle: 0.2,
          leftKneeAngle: 0.25,  // 왼쪽 무릎 더 굽힘
          rightKneeAngle: 0.05,
          torsoAngle: 0.2,      // 0.1 → 0.2 (대칭)
          neckAngle: -0.4,
        ),
        1.0,  // 왼쪽 1초
      ),
      
      // 2. 오른쪽으로 기울임
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.7,
          rightShoulderAngle: 0.9,
          leftElbowAngle: -0.4,
          rightElbowAngle: 0.6,
          leftHipAngle: 0.2,
          rightHipAngle: 0.4,   // 오른쪽에 무게
          leftKneeAngle: 0.05,
          rightKneeAngle: 0.25, // 오른쪽 무릎 더 굽힘
          torsoAngle: 0.2,      // 0.3 → 0.2 (대칭)
          neckAngle: -0.4,
        ),
        1.0,  // 오른쪽 1초
      ),
    ],
    loop: true,  // 왼쪽 ↔ 오른쪽 무한 왕복
  );

  /// 배 만지며 힘없이 흔들거림 (배고픔으로 힘없음)
  static final PoseSequence _touchBellySequence = PoseSequence(
    keyframes: [
      // 1. 왼쪽으로 흔들거림 (힘없이)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.3,   // 배 만지기 유지
          rightShoulderAngle: -0.4,
          leftElbowAngle: -1.3,
          rightElbowAngle: 1.3,
          leftHipAngle: 0.1,        // 살짝 왼쪽으로 (작은 각도)
          rightHipAngle: 0.0,
          leftKneeAngle: 0.15,      // 약간 무릎 굽힘 (힘없음)
          rightKneeAngle: 0.05,
          torsoAngle: 0.05,         // 살짝 앞으로 (배고픔)
          neckAngle: -0.4,          // 고개 숙임
        ),
        0.8,  // 0.8초 (불안정한 느낌)
      ),
      
      // 2. 오른쪽으로 흔들거림 (힘없이)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.3,   // 배 만지기 유지
          rightShoulderAngle: -0.4,
          leftElbowAngle: -1.3,
          rightElbowAngle: 1.3,
          leftHipAngle: 0.0,
          rightHipAngle: 0.1,       // 살짝 오른쪽으로
          leftKneeAngle: 0.05,
          rightKneeAngle: 0.15,     // 약간 무릎 굽힘
          torsoAngle: 0.05,         // 유지
          neckAngle: -0.4,
        ),
        0.8,  // 0.8초
      ),
    ],
    loop: true,  // 힘없이 계속 흔들거림
  );

  /// 승리 포즈 (슈퍼맨) - 웅크렸다가 힘차게 뻗기
  static final PoseSequence _victorySequence = PoseSequence(
    keyframes: [
      // 1. 준비 (살짝 웅크림)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.5,
          rightShoulderAngle: 0.5,
          leftElbowAngle: -1.0,   // 팔을 모음
          rightElbowAngle: 1.0,
          leftHipAngle: 0.2,      // 살짝 앉음
          rightHipAngle: 0.2,
          leftKneeAngle: 0.3,     // 무릎 굽힘
          rightKneeAngle: 0.3,
          torsoAngle: 0.1,        // 앞으로 숙임
          neckAngle: -0.2,
        ),
        0.3,  // 0.3초 동안 준비
      ),
      
      // 2. 승리 포즈! (한 팔 찌르기)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: -0.5, // 왼손은 허리에 (당당하게)
          rightShoulderAngle: 2.8, // 오른손 하늘 높이 찌르기! (약 160도)
          leftElbowAngle: -1.2,    // 왼팔 굽혀서 허리에
          rightElbowAngle: 0.0,    // 오른팔 쫙 폄
          leftHipAngle: 0.0,       // 똑바로 섬
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: -0.1,        // 가슴을 폄 (뒤로 살짝)
          neckAngle: 0.2,          // 고개 들고 하늘 보기
        ),
        2.0,  // 2초 동안 포즈 유지
      ),
    ],
    loop: false,  // 한 번만 재생하고 유지 (또는 loop: true로 반복 강조 가능, 일단 false로 유지)
    returnToNeutral: true, // 끝나면 중립으로 복귀
  );
}
