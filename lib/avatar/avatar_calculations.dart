/// 아바타 체형 계산 유틸리티 클래스
library;
import 'package:flutter/material.dart';
import 'body_joint.dart';

/// 호흡 애니메이션 파라미터 클래스
class BreathingParams {
  final double minScale; // 최소 호흡 스케일 (숨 들이마실 때)
  final double maxScale; // 최대 호흡 스케일 (숨 내쉴 때)
  final Duration duration; // 호흡 주기
  final bool showTiredFace; // 힘든 표정 표시 여부

  const BreathingParams({
    required this.minScale,
    required this.maxScale,
    required this.duration,
    required this.showTiredFace,
  });
}

class AvatarCalculations {
  /// 부위별 체형 변형 계산
  static Map<String, double> calculateBodyPartScales(
    double bmi,
    String activityLevel,
    String gender,
  ) {
    // 기본 스케일
    double bellyScale = 1.0; // 배
    double hipScale = 1.0; // 엉덩이
    double thighScale = 1.0; // 허벅지
    double armScale = 1.0; // 팔
    double faceScale = 1.0; // 얼굴

    // BMI 기반 변형
    if (bmi < 18.5) {
      // 저체중: 전체적으로 마름
      bellyScale = 0.8;
      hipScale = 0.85;
      thighScale = 0.85;
      armScale = 0.9;
      faceScale = 0.9;
    } else if (bmi < 25.0) {
      // 정상: 균형 잡힘
      bellyScale = 1.0;
      hipScale = 1.0;
      thighScale = 1.0;
      armScale = 1.0;
      faceScale = 1.0;
    } else if (bmi < 30.0) {
      // 과체중: 배와 엉덩이에 지방 축적
      bellyScale = 1.3;
      hipScale = 1.2;
      thighScale = 1.1;
      armScale = 1.05;
      faceScale = 1.1;
    } else {
      // 비만: 전신 지방 축적
      bellyScale = 1.6;
      hipScale = 1.4;
      thighScale = 1.3;
      armScale = 1.2;
      faceScale = 1.3;
    }

    // 상하복부별 세부 조정
    double upperBellyScale = bellyScale;
    double lowerBellyScale = bellyScale;

    if (bmi >= 25.0) {
      // 과체중 이상: 하복부가 상복부보다 조금 더 축적됨
      upperBellyScale = bellyScale * 0.95;
      lowerBellyScale = bellyScale * 1.05;
    }
    if (bmi >= 30.0) {
      // 비만: 하복부가 조금 더 축적됨
      upperBellyScale = bellyScale * 0.9;
      lowerBellyScale = bellyScale * 1.1;
    }

    // 활동 수준에 따른 추가 변형
    switch (activityLevel) {
      case 'sedentary':
        // 좌식 생활: 배와 엉덩이에 더 많은 지방 축적
        bellyScale *= 1.1;
        hipScale *= 1.05;
        armScale *= 0.95; // 근육량 감소
        break;
      case 'light':
        // 가벼운 활동: 약간의 근육 증가
        armScale *= 1.02;
        thighScale *= 1.01;
        break;
      case 'moderate':
        // 중간 활동: 균형 잡힌 근육 발달
        armScale *= 1.05;
        thighScale *= 1.03;
        bellyScale *= 0.98; // 약간의 지방 감소
        break;
      case 'active':
        // 활동적: 근육량 증가, 지방 감소
        armScale *= 1.08;
        thighScale *= 1.05;
        bellyScale *= 0.95;
        hipScale *= 0.98;
        break;
      case 'very_active':
        // 매우 활동적: 현저한 근육 발달, 지방 최소화
        armScale *= 1.12;
        thighScale *= 1.08;
        bellyScale *= 0.9;
        hipScale *= 0.95;
        break;
    }

    // 성별에 따른 추가 조정
    if (gender == 'female') {
      // 여성: 엉덩이와 허벅지에 더 많은 지방 축적
      hipScale *= 1.05;
      thighScale *= 1.03;
    } else {
      // 남성: 배에 더 많은 지방 축적
      bellyScale *= 1.05;
      armScale *= 1.02; // 근육량 더 많음
    }

    // 추가적인 BMI 기반 스케일 계산
    double neckScale = 1.0; // 목
    double torsoScale = 1.0; // 몸통 전체
    double calfScale = 1.0; // 종아리
    double footScale = 1.0; // 발
    double shoulderScale = 1.0; // 어깨 너비

    // BMI에 따른 추가 스케일 조정
    if (bmi < 18.5) {
      // 저체중: 전체적으로 가늘고 긴 형태
      neckScale = 0.9;
      torsoScale = 0.9;
      calfScale = 0.85;
      footScale = 0.9;
      shoulderScale = 0.9;
    } else if (bmi < 25.0) {
      // 정상: 균형 잡힌 비율
      neckScale = 1.0;
      torsoScale = 1.0;
      calfScale = 1.0;
      footScale = 1.0;
      shoulderScale = 1.0;
    } else if (bmi < 30.0) {
      // 과체중: 목과 몸통이 두껍고 짧아짐
      neckScale = 1.1;
      torsoScale = 1.2;
      calfScale = 1.1;
      footScale = 1.05;
      shoulderScale = 1.1;
    } else {
      // 비만: 더 두껍고 짧은 형태
      neckScale = 1.2;
      torsoScale = 1.4;
      calfScale = 1.2;
      footScale = 1.1;
      shoulderScale = 1.2;
    }

    // 성별에 따른 추가 조정
    if (gender == 'male') {
      // 남성: 더 넓은 어깨, 강한 목
      shoulderScale *= 1.1;
      neckScale *= 1.05;
    } else {
      // 여성: 더 좁은 어깨, 가는 목
      shoulderScale *= 0.95;
      neckScale *= 0.95;
    }

    return {
      'belly': bellyScale.clamp(0.7, 2.0),
      'upperBelly': upperBellyScale.clamp(0.7, 2.0), // 상복부 - BMI에 따른 차별화 적용
      'lowerBelly': lowerBellyScale.clamp(0.7, 2.0), // 하복부 - BMI에 따른 차별화 적용
      'hip': hipScale.clamp(0.8, 1.8),
      'thigh': thighScale.clamp(0.8, 1.6),
      'arm': armScale.clamp(0.8, 1.4),
      'face': faceScale.clamp(0.8, 1.5),
      'chest': armScale.clamp(0.8, 1.4), // 가슴은 근육량에 따라 변형
      'neck': neckScale.clamp(0.8, 1.4), // 목 길이와 두께
      'torso': torsoScale.clamp(0.8, 1.6), // 몸통 전체 높이
      'calf': calfScale.clamp(0.8, 1.4), // 종아리
      'foot': footScale.clamp(0.8, 1.2), // 발
      'shoulder': shoulderScale.clamp(0.8, 1.3), // 어깨 너비
    };
  }

  /// BMI 계산
  static double calculateBMI(double weight, double height) {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// FK 체인을 위한 관절 로컬 좌표 계산
  static Map<String, Offset> calculateLocalJointPositions(
    Map<String, BodyJoint> bodyJoints,
  ) {
    // 각 관절의 로컬 좌표를 계산 (부모 관절 기준)
    final localPositions = <String, Offset>{};

    // 루트 관절 (엉덩이 중심)부터 시작
    final rootJoint = bodyJoints['waist']!;
    localPositions['waist'] = Offset.zero;

    // 왼쪽 다리 체인
    _calculateLimbChainLocalPositions(bodyJoints, localPositions, 'waist', [
      'leftHip',
      'leftKnee',
      'leftAnkle',
    ]);

    // 오른쪽 다리 체인
    _calculateLimbChainLocalPositions(bodyJoints, localPositions, 'waist', [
      'rightHip',
      'rightKnee',
      'rightAnkle',
    ]);

    // 왼쪽 팔 체인
    _calculateLimbChainLocalPositions(
      bodyJoints,
      localPositions,
      'leftShoulder',
      ['leftElbow', 'leftWrist'],
    );

    // 오른쪽 팔 체인
    _calculateLimbChainLocalPositions(
      bodyJoints,
      localPositions,
      'rightShoulder',
      ['rightElbow', 'rightWrist'],
    );

    // 다른 관절들
    localPositions['head'] =
        bodyJoints['head']!.position - bodyJoints['neck']!.position;
    localPositions['neck'] =
        bodyJoints['neck']!.position - bodyJoints['waist']!.position;

    return localPositions;
  }

  /// 팔다리 체인의 로컬 좌표 계산 헬퍼
  static void _calculateLimbChainLocalPositions(
    Map<String, BodyJoint> bodyJoints,
    Map<String, Offset> localPositions,
    String rootJointName,
    List<String> chainJointNames,
  ) {
    final rootJoint = bodyJoints[rootJointName]!;
    BodyJoint currentJoint = rootJoint;

    for (final jointName in chainJointNames) {
      final joint = bodyJoints[jointName]!;
      // 부모 관절을 기준으로 한 로컬 좌표
      localPositions[jointName] = joint.position - currentJoint.position;
      currentJoint = joint;
    }
  }

  /// BMI 기반 호흡 파라미터 계산
  static BreathingParams calculateBreathingParams(double bmi) {
    if (bmi >= 30.0) {
      // 고도 비만: 빠르고 강한 호흡 + 힘든 표정
      return BreathingParams(
        minScale: 0.85, // 더 많이 숨을 들이마심 (힘들어 보임)
        maxScale: 1.15, // 더 많이 숨을 내쉴 때 팽창
        duration: Duration(seconds: 1), // 빠른 호흡
        showTiredFace: true, // 힘든 표정 표시
      );
    } else if (bmi >= 25.0) {
      // 비만: 중간 강도의 호흡
      return BreathingParams(
        minScale: 0.90,
        maxScale: 1.10,
        duration: Duration(milliseconds: 1500), // 1.5초 주기
        showTiredFace: false,
      );
    } else if (bmi >= 18.5) {
      // 정상: 기본 호흡
      return BreathingParams(
        minScale: 0.95,
        maxScale: 1.05,
        duration: Duration(seconds: 2), // 2초 주기
        showTiredFace: false,
      );
    } else {
      // 저체중: 약한 호흡
      return BreathingParams(
        minScale: 0.97,
        maxScale: 1.03,
        duration: Duration(seconds: 3), // 느린 호흡
        showTiredFace: false,
      );
    }
  }
}
