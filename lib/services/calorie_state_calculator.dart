import '../avatar/face_expressions.dart';
import '../avatar/body_poses.dart';

/// 칼로리 섭취 상태
/// 
/// 일일 권장 칼로리 대비 현재 섭취량 기준으로 상태 판단
enum CalorieState {
  /// 매우 부족 (0-30%)
  veryLow,
  
  /// 부족 (30-50%)
  low,
  
  /// 적절 (50-90%)
  optimal,
  
  /// 권장량 달성 (90-110%)
  achieved,
  
  /// 초과 (110-130%)
  exceeded,
  
  /// 과다 (130%+)
  excessive,
}

extension CalorieStateExtension on CalorieState {
  /// 상태 설명
  String get description {
    switch (this) {
      case CalorieState.veryLow:
        return '많이 배고파요 🥺';
      case CalorieState.low:
        return '배고파요 😓';
      case CalorieState.optimal:
        return '적절해요 😊';
      case CalorieState.achieved:
        return '권장량 달성! 🎉';
      case CalorieState.exceeded:
        return '조금 많이 먹었어요 😅';
      case CalorieState.excessive:
        return '너무 많이 먹었어요 😵';
    }
  }
  
  /// 상태별 색상
  int get color {
    switch (this) {
      case CalorieState.veryLow:
      case CalorieState.low:
        return 0xFFFF5252; // 빨강
      case CalorieState.optimal:
        return 0xFF66BB6A; // 초록
      case CalorieState.achieved:
        return 0xFF42A5F5; // 파랑
      case CalorieState.exceeded:
        return 0xFFFFA726; // 주황
      case CalorieState.excessive:
        return 0xFFEF5350; // 진한 빨강
    }
  }
}

/// 칼로리 상태 계산기
class CalorieStateCalculator {
  /// 현재 칼로리 섭취 상태 계산
  /// 
  /// @param current 현재 섭취한 칼로리
  /// @param goal 일일 권장 칼로리
  /// @return CalorieState
  static CalorieState getState(double current, double goal) {
    if (goal <= 0) return CalorieState.optimal;
    
    final percentage = (current / goal) * 100;
    
    if (percentage < 30) {
      return CalorieState.veryLow;
    } else if (percentage < 50) {
      return CalorieState.low;
    } else if (percentage < 90) {
      return CalorieState.optimal;
    } else if (percentage < 110) {
      return CalorieState.achieved;
    } else if (percentage < 130) {
      return CalorieState.exceeded;
    } else {
      return CalorieState.excessive;
    }
  }
  
  /// 칼로리 상태에 따른 권장 표정
  /// 
  /// @param state 칼로리 상태
  /// @return FaceExpressionType
  static FaceExpressionType getRecommendedExpression(CalorieState state) {
    switch (state) {
      case CalorieState.veryLow:
        return FaceExpressionType.hungry;
      case CalorieState.low:
        return FaceExpressionType.neutral;
      case CalorieState.optimal:
        return FaceExpressionType.satisfied;
      case CalorieState.achieved:
        return FaceExpressionType.happy; 
      case CalorieState.exceeded:
        return FaceExpressionType.full;
      case CalorieState.excessive:
        return FaceExpressionType.stuffed;
    }
  }
  
  /// 칼로리 상태에 따른 표정 목록 (로테이션용)
  static List<FaceExpressionType> getExpressionRotationList(CalorieState state) {
    switch (state) {
      case CalorieState.veryLow:
        return [
          FaceExpressionType.hungry,
          FaceExpressionType.hungry,
          FaceExpressionType.neutral,
        ];
        
      case CalorieState.low:
        return [
          FaceExpressionType.neutral,
          FaceExpressionType.hungry,
        ];
        
      case CalorieState.optimal:
        return [
          FaceExpressionType.satisfied,
          FaceExpressionType.happy,
        ];
        
      case CalorieState.achieved:
        return [
          FaceExpressionType.happy,
          FaceExpressionType.welcome,
        ];
        
      case CalorieState.exceeded:
        return [
          FaceExpressionType.full,
          FaceExpressionType.neutral,
        ];
        
      case CalorieState.excessive:
        return [
          FaceExpressionType.stuffed,
          FaceExpressionType.tired,
        ];
    }
  }
  
  /// BMI 카테고리 판단
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'underweight';
    } else if (bmi < 25) {
      return 'normal';
    } else if (bmi < 30) {
      return 'overweight';
    } else {
      return 'obese';
    }
  }
  
  /// BMI와 칼로리 상태에 따른 표정 로테이션 목록
  static List<FaceExpressionType> getExpressionRotationListWithBMI(
    CalorieState state,
    double bmi,
  ) {
    final bmiCategory = getBMICategory(bmi);
    
    switch (state) {
      case CalorieState.veryLow:
      case CalorieState.low:
        if (bmiCategory == 'underweight') {
          return [
            FaceExpressionType.tired,
            FaceExpressionType.tired,
            FaceExpressionType.neutral,
          ];
        } else {
          return [
            FaceExpressionType.hungry,
            FaceExpressionType.hungry,
            FaceExpressionType.neutral,
          ];
        }
        
      case CalorieState.optimal:
      case CalorieState.achieved:
        if (bmiCategory == 'underweight') {
          return [
            FaceExpressionType.happy,
            FaceExpressionType.satisfied,
          ];
        }
        return [
          FaceExpressionType.satisfied,
          FaceExpressionType.happy,
        ];
        
      case CalorieState.exceeded:
      case CalorieState.excessive:
        if (bmiCategory == 'underweight') {
          return [
            FaceExpressionType.stuffed,
            FaceExpressionType.stuffed,
            FaceExpressionType.tired,
          ];
        } else if (bmiCategory == 'overweight' || bmiCategory == 'obese') {
          return [
            FaceExpressionType.refuse,
            FaceExpressionType.refuse,
            FaceExpressionType.warning,
          ];
        } else {
          return [
            FaceExpressionType.full,
            FaceExpressionType.tired,
          ];
        }
    }
  }

  /// BMI와 칼로리 상태에 따른 권장 바디 포즈 (Idle Matrix 구현)
  static BodyPose getRecommendedPose(CalorieState state, double bmi) {
    final bmiCategory = getBMICategory(bmi);
    
    switch (state) {
      case CalorieState.veryLow:
      case CalorieState.low:
        // 배고픔 상태
        if (bmiCategory == 'underweight') {
          return BodyPose.bendForward; // 방전 (비틀거림/숙임)
        } else if (bmiCategory == 'overweight' || bmiCategory == 'obese') {
          return BodyPose.neutral; // 인내 (굳건히 버팀)
        } else {
          return BodyPose.touchBelly; // 일반적인 배고픔
        }
        
      case CalorieState.optimal:
      case CalorieState.achieved:
        // 적정 상태
        if (bmiCategory == 'underweight') {
          return BodyPose.jump; // 활력 (에너지 넘침)
        } else if (bmiCategory == 'overweight' || bmiCategory == 'obese') {
          return BodyPose.stretch; // 준비 (운동 의지)
        } else {
          return BodyPose.neutral; // 편안함
        }
        
      case CalorieState.exceeded:
      case CalorieState.excessive:
        // 과식 상태
        if (bmiCategory == 'underweight') {
          return BodyPose.touchBelly; // 버거움 (배부름)
        } else if (bmiCategory == 'overweight' || bmiCategory == 'obese') {
          return BodyPose.refuse; // 거부/후회 (강한 부정)
        } else {
          return BodyPose.headDown; // 나른함 (식곤증)
        }
    }
  }

  /// BMI와 칼로리 상태에 따른 권장 표정 (Idle Matrix 구현)
  static FaceExpressionType getRecommendedExpressionWithBMI(
    CalorieState state,
    double bmi,
  ) {
    final bmiCategory = getBMICategory(bmi);
    
    switch (state) {
      case CalorieState.veryLow:
      case CalorieState.low:
        // 배고픔
        if (bmiCategory == 'underweight') {
          return FaceExpressionType.tired; // 방전
        } else if (bmiCategory == 'overweight' || bmiCategory == 'obese') {
          return FaceExpressionType.warning; // 인내 (진지함)
        } else {
          return FaceExpressionType.hungry; // 배고픔
        }
        
      case CalorieState.optimal:
      case CalorieState.achieved:
        // 적정
        if (bmiCategory == 'underweight') {
          return FaceExpressionType.happy; // 활력
        } else {
          return FaceExpressionType.satisfied; // 만족/준비
        }
        
      case CalorieState.exceeded:
      case CalorieState.excessive:
        // 과식
        if (bmiCategory == 'underweight') {
          return FaceExpressionType.stuffed; // 버거움
        } else if (bmiCategory == 'overweight' || bmiCategory == 'obese') {
          return FaceExpressionType.refuse; // 거부
        } else {
          return FaceExpressionType.tired; // 나른함
        }
    }
  }
}

