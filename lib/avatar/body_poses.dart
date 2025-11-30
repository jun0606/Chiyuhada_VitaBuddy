import 'dart:ui';

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

  /// 손 흔들기 (거부)
  waveHand,

  /// 앞으로 숙이기 (힘듦, 과식)
  bendForward,

  /// 점프 (매우 기쁨, 목표 달성)
  jump,

  /// 고개 숙이기 (슬픔, 배고픔)
  headDown,

  /// 만세 (환호, 저체중 목표 달성)
  cheer,

  /// 인사 (정상 목표 달성)
  greeting,

  /// 스트레칭 (안도, 과체중 목표 달성)
  stretch,

  /// 거부 (과식 경고)
  refuse,
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

  /// 팔 올리기 (기쁨) - 크게
  static const BodyPoseData armsUp = BodyPoseData(
    leftShoulderAngle: -3.2, // 팔 더 크게 위로
    rightShoulderAngle: 3.2, // 팔 더 크게 위로
    leftElbowAngle: -0.3,
    rightElbowAngle: 0.3,
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

  /// 점프 (매우 기쁨)
  static const BodyPoseData jump = BodyPoseData(
    leftShoulderAngle: -2.0,
    rightShoulderAngle: 2.0,
    leftElbowAngle: -0.5,
    rightElbowAngle: 0.5,
    leftHipAngle: -0.3, // 다리 올림
    rightHipAngle: -0.3,
    leftKneeAngle: -0.8, // 무릎 굽힘
    rightKneeAngle: -0.8,
    torsoAngle: 0.0,
    neckAngle: 0.3,
    verticalOffset: -20.0, // 위로 점프
  );

  /// 고개 숙이기 (슬픔)
  static const BodyPoseData headDown = BodyPoseData(
    leftShoulderAngle: 0.3,
    rightShoulderAngle: 0.3,
    leftElbowAngle: -0.2,
    rightElbowAngle: 0.2,
    leftHipAngle: 0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: 0.2,
    neckAngle: -0.6, // 고개 크게 아래
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

  /// 스트레칭 (안도)
  static const BodyPoseData stretch = BodyPoseData(
    leftShoulderAngle: -1.5, // 양팔 벌리기
    rightShoulderAngle: 1.5,
    leftElbowAngle: -1.5, // 머리 뒤로
    rightElbowAngle: 1.5,
    leftHipAngle: 0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: 0.0,
    neckAngle: 0.1,
  );

  /// 거부 (과식 - 그만 먹기 제스처)
  static const BodyPoseData refuse = BodyPoseData(
    leftShoulderAngle: -1.0, // 팔을 약간 들어올림
    rightShoulderAngle: 1.0,
    leftElbowAngle: -1.5, // 팔꿈치를 굽혀서 손바닥을 보이는 느낌 (Stop)
    rightElbowAngle: 1.5,
    leftHipAngle: 0.0,
    rightHipAngle: 0.0,
    leftKneeAngle: 0.0,
    rightKneeAngle: 0.0,
    torsoAngle: -0.1, // 약간 뒤로 물러섬
    neckAngle: 0.0,
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
      case BodyPose.jump:
        return BodyPoseData.jump;
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
      case BodyPose.jump:
        return _jumpSequence;
      case BodyPose.waveHand:
        return _waveHandSequence;
      case BodyPose.cheer:
        return _cheerSequence;
      case BodyPose.greeting:
        return _greetingSequence;
      default:
        return null; // 시퀀스 없음, 단일 포즈 사용
    }
  }

  // 🦘 점프 시퀀스 (개선: 자연스러운 다리 동작)
  static final PoseSequence _jumpSequence = PoseSequence(
    keyframes: [
      // 1. 준비 단계 1 (살짝 웅크리기 시작)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: -0.2,
          rightShoulderAngle: -0.2,
          leftElbowAngle: -0.2,
          rightElbowAngle: -0.2,
          leftHipAngle: 0.2,  // 살짝 구부림
          rightHipAngle: 0.2,
          leftKneeAngle: 0.3, // 살짝 구부림
          rightKneeAngle: 0.3,
          torsoAngle: 0.1,    // 약간 앞으로
          neckAngle: 0.0,
          verticalOffset: 5.0, // 살짝 아래로
        ),
        0.15,
      ),
      // 2. 준비 단계 2 (완전히 웅크리기 - 최저점)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.3,  // 팔 뒤로 스윙
          rightShoulderAngle: 0.3,
          leftElbowAngle: -0.3,
          rightElbowAngle: -0.3,
          leftHipAngle: 0.5,  // 많이 구부림
          rightHipAngle: 0.5,
          leftKneeAngle: 0.8, // 많이 구부림
          rightKneeAngle: 0.8,
          torsoAngle: 0.3,    // 앞으로 숙임
          neckAngle: -0.1,
          verticalOffset: 15.0, // 최대한 아래로
        ),
        0.15,
      ),
      // 3. 도약 순간 (다리를 힘껏 펴며 발차기)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: -0.5, // 팔 위로 스윙 시작
          rightShoulderAngle: -0.5,
          leftElbowAngle: -0.3,
          rightElbowAngle: -0.3,
          leftHipAngle: -0.1, // 시작 펴기
          rightHipAngle: -0.1,
          leftKneeAngle: 0.3, // 빠르게 펴기
          rightKneeAngle: 0.3,
          torsoAngle: 0.0,
          neckAngle: 0.0,
          verticalOffset: 5.0, // 상승 시작
        ),
        0.1,
      ),
      // 4. 상승 중 (다리를 완전히 펴고 상승)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: -1.2, // 팔을 크게 위로
          rightShoulderAngle: -1.2,
          leftElbowAngle: -0.2,
          rightElbowAngle: -0.2,
          leftHipAngle: -0.3, // 완전히 펴기
          rightHipAngle: -0.3,
          leftKneeAngle: -0.2, // 완전히 펴기
          rightKneeAngle: -0.2,
          torsoAngle: -0.1,    // 약간 뒤로
          neckAngle: 0.1,
          verticalOffset: -40.0, // 상승 중
        ),
        0.15,
      ),
      // 5. 공중 최고점 (다리 살짝 구부림)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: -1.2,
          rightShoulderAngle: -1.2,
          leftElbowAngle: -0.2,
          rightElbowAngle: -0.2,
          leftHipAngle: -0.2,
          rightHipAngle: -0.2,
          leftKneeAngle: -0.1,
          rightKneeAngle: -0.1,
          torsoAngle: 0.0,
          neckAngle: 0.2,
          verticalOffset: -60.0, // 최고점
        ),
        0.2,
      ),
      // 6. 착지 준비 (다리 구부리기 시작)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: -0.5, // 팔 내리며 균형
          rightShoulderAngle: -0.5,
          leftElbowAngle: -0.3,
          rightElbowAngle: -0.3,
          leftHipAngle: 0.3,  // 착지 준비
          rightHipAngle: 0.3,
          leftKneeAngle: 0.4, // 착지 준비
          rightKneeAngle: 0.4,
          torsoAngle: 0.2,
          neckAngle: 0.0,
          verticalOffset: -20.0, // 하강 중
        ),
        0.15,
      ),
      // 7. 착지 충격 흡수 (무릎과 엉덩이로 충격 흡수)
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.2,
          rightShoulderAngle: 0.2,
          leftElbowAngle: -0.3,
          rightElbowAngle: -0.3,
          leftHipAngle: 0.4,  // 충격 흡수
          rightHipAngle: 0.4,
          leftKneeAngle: 0.5, // 충격 흡수
          rightKneeAngle: 0.5,
          torsoAngle: 0.2,
          neckAngle: -0.1,
          verticalOffset: 5.0, // 아직 약간 아래
        ),
        0.2,
      ),
      // 8. 정상 복귀
      PoseKeyframe(
        const BodyPoseData(
          leftShoulderAngle: 0.0,
          rightShoulderAngle: 0.0,
          leftElbowAngle: -0.2,
          rightElbowAngle: -0.2,
          leftHipAngle: 0.0,
          rightHipAngle: 0.0,
          leftKneeAngle: 0.0,
          rightKneeAngle: 0.0,
          torsoAngle: 0.0,
          neckAngle: 0.0,
          verticalOffset: 0.0,
        ),
        0.15,
      ),
    ],
  );

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
}
