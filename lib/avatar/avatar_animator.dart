import 'dart:math';
import 'package:flutter/material.dart';
import 'body_poses.dart';
import 'face_expressions.dart';

/// 아바타 애니메이터
/// 표정과 포즈를 관리하고, 각 신체 부위의 목표 회전각(Target Rotation)을 계산합니다.
class AvatarAnimator {
  FaceExpressionType currentExpression = FaceExpressionType.neutral;
  BodyPose currentPose = BodyPose.neutral;
  
  double _animationTime = 0.0;
  bool _isBlinking = false;
  double _blinkTimer = 0.0;

  // 애니메이션 보간 변수
  BodyPoseData _prevPoseData = BodyPoseCalculator.getPoseData(BodyPose.neutral);
  BodyPoseData _targetPoseData = BodyPoseCalculator.getPoseData(BodyPose.neutral);
  double _transitionProgress = 1.0; // 1.0 = 완료
  double _transitionDuration = 0.5; // 기본 전환 시간 (초)

  // 시퀀스 애니메이션 변수
  PoseSequence? _currentSequence;
  int _currentKeyframeIndex = 0;
  double _keyframeProgress = 0.0;

  void setExpression(FaceExpressionType type) {
    currentExpression = type;
  }

  void setPose(BodyPose pose, {double duration = 0.5}) {
    currentPose = pose;
    
    // 시퀀스가 있는지 확인
    final sequence = BodyPoseCalculator.getSequence(pose);
    
    if (sequence != null) {
      // 시퀀스 시작
      _currentSequence = sequence;
      _currentKeyframeIndex = 0;
      _keyframeProgress = 0.0;
      
      // 첫 번째 키프레임으로 전환 시작
      if (_transitionProgress < 1.0) {
        _prevPoseData = BodyPoseCalculator.lerp(
          _prevPoseData, 
          _targetPoseData, 
          _transitionProgress
        );
      } else {
        _prevPoseData = _targetPoseData;
      }
      
      _targetPoseData = sequence.keyframes[0].poseData;
      _transitionProgress = 0.0;
      _transitionDuration = 0.3;  // 첫 프레임으로 빠르게 전환
    } else {
      // 단일 포즈 (기존 로직)
      _currentSequence = null;
      
      if (_transitionProgress < 1.0) {
        _prevPoseData = BodyPoseCalculator.lerp(
          _prevPoseData, 
          _targetPoseData, 
          _transitionProgress
        );
      } else {
        _prevPoseData = _targetPoseData;
      }
      
      _targetPoseData = BodyPoseCalculator.getPoseData(pose);
      _transitionProgress = 0.0;
      _transitionDuration = duration;
    }
  }

  void update(double dt) {
    _animationTime += dt;
    
    // 시퀀스 처리
    if (_currentSequence != null) {
      _updateSequence(dt);
    } else {
      _updateSinglePose(dt);
    }
    
    // 눈 깜빡임 로직 (랜덤)
    _blinkTimer -= dt;
    if (_blinkTimer <= 0) {
      _isBlinking = !_isBlinking;
      _blinkTimer = _isBlinking ? 0.15 : (Random().nextDouble() * 3.0 + 2.0); // 0.15초 감고, 2~5초 뜸
    }
  }

  void _updateSinglePose(double dt) {
    // 포즈 전환 진행
    if (_transitionProgress < 1.0) {
      _transitionProgress += dt / _transitionDuration;
      if (_transitionProgress > 1.0) _transitionProgress = 1.0;
    }
  }

  void _updateSequence(double dt) {
    // 현재 키프레임으로의 전환 진행
    if (_transitionProgress < 1.0) {
      _transitionProgress += dt / _transitionDuration;
      if (_transitionProgress > 1.0) _transitionProgress = 1.0;
      return;
    }
    
    // 현재 키프레임 유지 시간
    final currentKeyframe = _currentSequence!.keyframes[_currentKeyframeIndex];
    _keyframeProgress += dt;
    
    if (_keyframeProgress >= currentKeyframe.duration) {
      // 다음 키프레임으로
      _currentKeyframeIndex++;
      _keyframeProgress = 0.0;
      
      if (_currentKeyframeIndex >= _currentSequence!.keyframes.length) {
        // 시퀀스 완료
        if (_currentSequence!.returnToNeutral) {
          // 중립 자세로 복귀
          setPose(BodyPose.neutral);
        } else {
          // 마지막 프레임 유지
          _currentSequence = null;
        }
      } else {
        // 다음 키프레임으로 전환 시작
        _prevPoseData = _targetPoseData;
        _targetPoseData = _currentSequence!.keyframes[_currentKeyframeIndex].poseData;
        _transitionProgress = 0.0;
        _transitionDuration = 0.2;  // 키프레임 간 빠른 전환
      }
    }
  }

  /// 현재 표정 데이터 반환
  FaceExpression getFaceExpression() {
    return FaceExpressionCalculator.getExpression(currentExpression);
  }

  /// 현재 상태에 따른 눈 모양 반환
  EyeState getEyeState() {
    if (_isBlinking) return EyeState.closed;

    switch (currentExpression) {
      case FaceExpressionType.happy:
      case FaceExpressionType.welcome:
      case FaceExpressionType.satisfied:
        return EyeState.smiling;
      case FaceExpressionType.tired:
      case FaceExpressionType.hungry:
        return EyeState.sad;
      case FaceExpressionType.stuffed:
      case FaceExpressionType.refuse:
      case FaceExpressionType.warning:
        return EyeState.angry; // 또는 wide
      default:
        return EyeState.open;
    }
  }

  /// 현재 상태에 따른 입 모양 반환
  MouthState getMouthState() {
    switch (currentExpression) {
      case FaceExpressionType.happy:
      case FaceExpressionType.welcome:
      case FaceExpressionType.satisfied:
        return MouthState.smile;
      case FaceExpressionType.tired:
      case FaceExpressionType.hungry:
        return MouthState.frown;
      case FaceExpressionType.stuffed:
      case FaceExpressionType.refuse:
        return MouthState.line;
      case FaceExpressionType.warning:
        return MouthState.open;
      default:
        return MouthState.neutral;
    }
  }

  /// 포즈에 따른 관절 각도 계산 (Map 반환)
  Map<String, double> getJointAngles() {
    // 현재 프레임의 보간된 포즈 데이터 계산
    final data = BodyPoseCalculator.lerp(
      _prevPoseData, 
      _targetPoseData, 
      Curves.easeInOutCubic.transform(_transitionProgress) // 부드러운 가속/감속 적용
    );
    
    // 숨쉬기 등 미세한 움직임 추가 (Idle Animation)
    final breath = sin(_animationTime * 2) * 0.05;

    return {
      'head': data.neckAngle + breath * 0.5,
      'leftArm': data.leftShoulderAngle + breath,
      'rightArm': data.rightShoulderAngle - breath,
      'leftElbow': data.leftElbowAngle,
      'rightElbow': data.rightElbowAngle,
      'torso': data.torsoAngle, // 몸통 각도 추가
      'verticalOffset': data.verticalOffset, // 수직 오프셋 (점프 등)
      // 필요한 경우 다리 각도 등도 추가 가능
    };
  }
}

enum EyeState { open, closed, smiling, sad, wide, angry }
enum MouthState { neutral, smile, frown, open, line }
