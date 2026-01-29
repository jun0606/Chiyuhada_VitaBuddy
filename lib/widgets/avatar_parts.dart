import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../avatar/body_measurements.dart';
import '../avatar/avatar_animator.dart';
import '../avatar/face_expressions.dart';

/// Base class for all body parts.
abstract class BodyPart extends PositionComponent {
  BodyMeasurements measurements;
  Paint paint = Paint()..color = const Color(0xFFFFD1BC); // Skin color
  
  // 외곽선 페인트 (피부색보다 약간 어둡게)
  Paint outlinePaint = Paint()
    ..color = const Color(0xFFD4A59A) 
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  BodyPart({required this.measurements});

  /// 그림자 렌더링 (입체감)
  void renderShadow(Canvas canvas, Path path) {
    canvas.drawPath(
      path.shift(const Offset(2, 2)),
      Paint()
        ..color = Colors.black.withAlpha(31)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );
  }
  
  /// 외곽선 렌더링 (구분감)
  void renderOutline(Canvas canvas, Path path) {
    canvas.drawPath(path, outlinePaint);
  }
}

class TorsoPart extends BodyPart {
  TorsoPart({required super.measurements});

  @override
  void render(Canvas canvas) {
    final w = measurements.waistWidth;
    final h = measurements.torsoHeight;
    final chest = measurements.chestWidth;
    final hip = measurements.hipWidth;
    final shoulder = measurements.shoulderWidth;
    final isFemale = measurements.gender == 'female';

    final path = Path();
    // Start from center top (neck base)
    path.moveTo(0, -h);
    
    // Right shoulder slope (Trapezius)
    path.cubicTo(
      shoulder * 0.2, -h, 
      shoulder * 0.3, -h * 0.98, 
      shoulder / 2, -h * 0.9
    );

    // Right side (Armpit to Waist)
    if (isFemale) {
      // S-line for female
      path.cubicTo(
        chest / 2 * 1.0, -h * 0.7, // Chest bulge
        w / 2 * 0.8, -h * 0.4,     // Deep waist indent
        w / 2 * 0.85, -h * 0.15    // 허리에서 약간 넓어짐
      );
      // 골반 연결
      path.cubicTo(
        hip / 2 * 0.9, -h * 0.05,  // 골반 시작 전 부드러운 곡선
        hip / 2 * 0.95, 0,         // 골반 연결점
        hip / 2 * 0.95, 0
      );
    } else {
      // V-taper for male
      path.cubicTo(
        chest / 2 * 1.05, -h * 0.75, 
        w / 2 * 0.9, -h * 0.4,
        w / 2 * 0.9, -h * 0.15
      );
      // 골반 연결
      path.cubicTo(
        hip / 2 * 0.92, -h * 0.05,
        hip / 2 * 0.95, 0,
        hip / 2 * 0.95, 0
      );
    }

    // Bottom (Hip line) - 더 자연스러운 곡선
    path.cubicTo(
      hip / 2 * 0.5, h * 0.02,     // 오른쪽에서 중앙으로
      -hip / 2 * 0.5, h * 0.02,    // 중앙에서 왼쪽으로
      -hip / 2 * 0.95, 0           // 왼쪽 끝점
    );

    // Left side (Waist to Armpit)
    if (isFemale) {
      path.cubicTo(
        -hip / 2 * 0.95, 0,
        -hip / 2 * 0.9, -h * 0.05,
        -w / 2 * 0.85, -h * 0.15
      );
      path.cubicTo(
        -w / 2 * 0.8, -h * 0.4,      
        -chest / 2 * 1.0, -h * 0.7,
        -shoulder / 2, -h * 0.9
      );
    } else {
      path.cubicTo(
        -hip / 2 * 0.95, 0,
        -hip / 2 * 0.92, -h * 0.05,
        -w / 2 * 0.9, -h * 0.15
      );
      path.cubicTo(
        -w / 2 * 0.9, -h * 0.4,      
        -chest / 2 * 1.05, -h * 0.75,
        -shoulder / 2, -h * 0.95     
      );
    }

    // Left shoulder slope
    path.cubicTo(
      -shoulder * 0.3, -h * 0.98, 
      -shoulder * 0.2, -h, 
      0, -h
    );

    path.close();
    
    // 🌟 그림자 및 외곽선 적용
    renderShadow(canvas, path);
    canvas.drawPath(path, paint);
    renderOutline(canvas, path);

    // Clavicle hint (both genders, subtle)
    final claviclePaint = Paint()
      ..color = const Color(0x20000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final claviclePath = Path();
    claviclePath.moveTo(shoulder * 0.15, -h * 0.95);
    claviclePath.quadraticBezierTo(shoulder * 0.25, -h * 0.93, shoulder * 0.35, -h * 0.92);
    
    claviclePath.moveTo(-shoulder * 0.15, -h * 0.95);
    claviclePath.quadraticBezierTo(-shoulder * 0.25, -h * 0.93, -shoulder * 0.35, -h * 0.92);
    
    canvas.drawPath(claviclePath, claviclePaint);

    // Render breasts for female
    if (measurements.breastSize > 0) {
      final breastPaint = Paint()..color = const Color(0xFFE0B0A0); // Slightly darker skin tone
      final size = measurements.breastSize;
      
      // Left Breast
      canvas.save();
      canvas.translate(-chest / 4.2, -h * 0.7);
      canvas.rotate(-0.08); // Slight outward tilt
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: size * 1.6, height: size * 1.5), breastPaint);
      canvas.restore();

      // Right Breast
      canvas.save();
      canvas.translate(chest / 4.2, -h * 0.7);
      canvas.rotate(0.08); // Slight outward tilt
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: size * 1.6, height: size * 1.5), breastPaint);
      canvas.restore();
      
      // Cleavage hint
      final cleavagePaint = Paint()..color = const Color(0x10000000)..style = PaintingStyle.stroke..strokeWidth = 1.0;
      canvas.drawArc(Rect.fromCenter(center: Offset(0, -h * 0.7), width: size, height: size), 1.5, 3.2, false, cleavagePaint);
    }
    
    // 복부 돌출 표현 (BMI 기반)
    if (measurements.bellyDepth.abs() > 1.0) {
      final bellyPaint = Paint()
        ..color = const Color(0x08000000)
        ..style = PaintingStyle.fill;
      
      final bellyY = -h * 0.25; // 복부 위치 (허리 약간 아래)
      final bellyWidth = w * 1.2;
      final bellyDepth = measurements.bellyDepth;
      
      // 복부 음영 효과 (돌출 시 음영, 들어갈 시 하이라이트)
      if (bellyDepth > 0) {
        // 배가 나온 경우: 아래쪽 음영
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, bellyY + h * 0.1), 
            width: bellyWidth, 
            height: bellyDepth * 1.5
          ), 
          bellyPaint
        );
      } else {
        // 배가 들어간 경우: 위쪽 하이라이트
        final highlightPaint = Paint()
          ..color = const Color(0x05FFFFFF)
          ..style = PaintingStyle.fill;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, bellyY), 
            width: bellyWidth * 0.8, 
            height: bellyDepth.abs() * 2.0
          ), 
          highlightPaint
        );
      }
    }
    
    // Muscle definition for athletic male/female
    if (measurements.muscleFactor > 4.0 && measurements.fatFactor < 5.0) {
      final musclePaint = Paint()
        ..color = const Color(0x15000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
        
      // Pectorals hint
      canvas.drawArc(
        Rect.fromCenter(center: Offset(0, -h * 0.75), width: chest * 0.8, height: h * 0.2), 
        0.3, 2.5, false, musclePaint
      );
      
      // Abs (Six pack hint)
      final absW = w * 0.4;
      final absH = h * 0.35;
      final absTop = -h * 0.5;
      
      // Center line
      canvas.drawLine(Offset(0, absTop), Offset(0, absTop + absH), musclePaint);
      
      // Horizontal lines
      canvas.drawLine(Offset(-absW/2, absTop + absH*0.3), Offset(absW/2, absTop + absH*0.3), musclePaint);
      canvas.drawLine(Offset(-absW/2, absTop + absH*0.6), Offset(absW/2, absTop + absH*0.6), musclePaint);
      canvas.drawLine(Offset(-absW/2, absTop + absH*0.9), Offset(absW/2, absTop + absH*0.9), musclePaint);
    }
    
    // 배꼽 (Navel)
    _renderNavel(canvas, w, h);
  }
  
  void _renderNavel(Canvas canvas, double w, double h) {
    final navelY = -h * 0.25; // 허리선 근처
    final fat = measurements.fatFactor;
    final muscle = measurements.muscleFactor;
    
    final navelPaint = Paint()
      ..color = const Color(0x20000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    canvas.save();
    canvas.translate(0, navelY);
    
    if (fat > 10.0) {
      // 비만형: 가로로 눌린 모양, 깊이감
      canvas.drawArc(
        Rect.fromCenter(center: Offset.zero, width: 6, height: 2),
        0, 3.14, false, navelPaint
      );
      // 뱃살 접힘 힌트
      final foldPaint = Paint()..color = const Color(0x10000000)..style = PaintingStyle.stroke..strokeWidth = 1.0;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(0, -2), width: 12, height: 4),
        3.14, 3.14, false, foldPaint
      );
    } else if (muscle > 5.0 && fat < 5.0) {
      // 근육형: 작고 명확한 점
      canvas.drawCircle(Offset.zero, 1.5, Paint()..color = const Color(0x30000000));
    } else {
      // 일반: 작은 세로 타원
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 2, height: 3),
        Paint()..color = const Color(0x20000000)
      );
    }
    
    canvas.restore();
  }
}

class NeckPart extends BodyPart {
  NeckPart({required super.measurements});

  @override
  void render(Canvas canvas) {
    final w = measurements.neckWidth;
    final h = measurements.neckHeight;
    
    // Tapering for refinement
    final topWidth = w * 0.6; // Taper to 60% at the top

    final path = Path();
    path.moveTo(-w / 2, 0); // Bottom left
    path.lineTo(w / 2, 0);  // Bottom right
    
    // Right side curve
    path.cubicTo(
      w / 2, -h * 0.3, 
      topWidth / 2, -h * 0.7, 
      topWidth / 2, -h
    );

    // Top line
    path.lineTo(-topWidth / 2, -h);

    // Left side curve
    path.cubicTo(
      -topWidth / 2, -h * 0.7, 
      -w / 2, -h * 0.3, 
      -w / 2, 0
    );

    path.close();
    
    // 그림자 및 외곽선
    renderShadow(canvas, path);
    canvas.drawPath(path, paint);
    renderOutline(canvas, path);
  }
}

class HeadPart extends PositionComponent {
  HeadPart({required BodyMeasurements measurements});

  // HeadPart는 이제 빈 컨테이너 역할만 수행
  // 실제 렌더링은 자식 컴포넌트들이 담당
}

/// 머리 원을 그리는 컴포넌트
class HeadCirclePart extends BodyPart {
  HeadCirclePart({required super.measurements});

  @override
  void render(Canvas canvas) {
    final size = measurements.headSize;
    final centerOffset = Offset(0, -size * 0.7);
    
    final path = Path()..addOval(Rect.fromCircle(center: centerOffset, radius: size));
    
    // 그림자 및 외곽선
    renderShadow(canvas, path);
    canvas.drawPath(path, paint);
    renderOutline(canvas, path);
  }
}

/// 얼굴 부분 (눈, 입)을 렌더링하는 컴포넌트
class FacePart extends BodyPart {
  final String gender;  // 'male' or 'female'
  EyeState eyeState;
  MouthState mouthState;
  FaceExpression expression;  // 🆕 표정 데이터 저장
  FaceExpressionType currentExpressionType;  // 🆕 현재 표정 타입

  FacePart({
    required super.measurements,
    required this.gender,  // NEW: 성별 파라미터
    this.eyeState = EyeState.open,
    this.mouthState = MouthState.neutral,
    FaceExpression? expression,
    this.currentExpressionType = FaceExpressionType.neutral,
  }) : expression = expression ?? FaceExpression.neutral;

  void updateExpression(EyeState newEye, MouthState newMouth) {
    eyeState = newEye;
    mouthState = newMouth;
  }

  // 🆕 FaceExpression 객체로 표정 업데이트
  void updateFromExpression(
    FaceExpression newExpression, 
    FaceExpressionType expressionType,
    EyeState newEye, 
    MouthState newMouth
  ) {
    expression = newExpression;
    currentExpressionType = expressionType;
    eyeState = newEye;
    mouthState = newMouth;
  }

  @override
  void render(Canvas canvas) {
    final headSize = measurements.headSize;
    final centerOffset = Offset(0, -headSize * 0.7);
    
    _drawEyes(canvas, headSize, centerOffset);
    _drawMouth(canvas, headSize, centerOffset);
    
    // 🆕 Phase 2: 특별 시각 효과 (표정별)
    _drawSpecialEffects(canvas, headSize, centerOffset);
  }

  // 🎭 Phase 2: 표정별 특수 효과
  void _drawSpecialEffects(Canvas canvas, double headSize, Offset centerOffset) {
    // ✅ Phase 1 개선: 표정 타입으로 직접 판단
    switch (currentExpressionType) {
      case FaceExpressionType.happy:
        _drawFloatingHeart(canvas, headSize, centerOffset);
        break;
      case FaceExpressionType.stuffed:
        _drawSweatDrops(canvas, headSize, centerOffset);
        _drawStuffedExtras(canvas, headSize, centerOffset);  // X자 눈, 혀
        break;
      case FaceExpressionType.warning:
        _drawExclamationMark(canvas, headSize, centerOffset);
        break;
      case FaceExpressionType.hungry:
        _drawDrool(canvas, headSize, centerOffset);
        _drawHungryExtras(canvas, headSize, centerOffset);  // 반짝이는 눈
        break;
      case FaceExpressionType.tired:
        _drawDarkCircles(canvas, headSize, centerOffset);
        break;
      case FaceExpressionType.full:
        _drawCheekBlush(canvas, headSize, centerOffset);
        break;
      case FaceExpressionType.refuse:
        _drawRefuseExtras(canvas, headSize, centerOffset);  // V자 눈썹 강조
        break;
      case FaceExpressionType.greeting:
        _drawGreetingSparkles(canvas, headSize, centerOffset); // ✨ 반짝임
        _drawGreetingHearts(canvas, headSize, centerOffset);   // 💕 하트
        _drawSmileAccent(canvas, headSize, centerOffset);      // 😊 미소선
        break;
      default:
        break;
    }
  }

  // ✨ 반짝임 이펙트 (환영)
  void _drawGreetingSparkles(Canvas canvas, double headSize, Offset centerOffset) {
    final sparklePaint = Paint()
      ..color = const Color(0xFFFFD700).withAlpha(204)  // 금색
      ..style = PaintingStyle.fill;
    
    final positions = [
      Offset(-headSize * 0.6, centerOffset.dy - headSize * 0.8),  // 왼쪽 위
      Offset(headSize * 0.6, centerOffset.dy - headSize * 0.8),   // 오른쪽 위
      Offset(-headSize * 0.7, centerOffset.dy - headSize * 0.3),  // 왼쪽
      Offset(headSize * 0.7, centerOffset.dy - headSize * 0.3),   // 오른쪽
    ];
    
    for (var pos in positions) {
      _drawSparkle(canvas, pos, headSize * 0.15, sparklePaint);
    }
  }

  // 💕 하트 이펙트 (환영)
  void _drawGreetingHearts(Canvas canvas, double headSize, Offset centerOffset) {
    final heartPaint = Paint()
      ..color = const Color(0xFFFFB6C1).withAlpha(128)  // 연한 베이비 핑크 (부드럽게)
      ..style = PaintingStyle.fill;
    
    final heartOutlinePaint = Paint()
      ..color = const Color(0xFFFF69B4).withAlpha(204)  // 외곽선도 부드럽게
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5; // 두께 약간 감소
    
    final positions = [
      Offset(-headSize * 0.5, centerOffset.dy + headSize * 0.1),  // 왼쪽 볼
      Offset(headSize * 0.5, centerOffset.dy + headSize * 0.1),   // 오른쪽 볼
    ];
    
    for (var pos in positions) {
      _drawSimpleHeart(canvas, pos, headSize * 0.12, heartPaint, heartOutlinePaint);
    }
  }

  // 😊 미소 강조선 (환영)
  void _drawSmileAccent(Canvas canvas, double headSize, Offset centerOffset) {
    final accentPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    // 왼쪽 미소선
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(-headSize * 0.25, centerOffset.dy + headSize * 0.4),
        radius: headSize * 0.1,
      ),
      -0.5, 1.0, false, accentPaint,
    );
    
    // 오른쪽 미소선
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(headSize * 0.25, centerOffset.dy + headSize * 0.4),
        radius: headSize * 0.1,
      ),
      -0.5, 1.0, false, accentPaint,
    );
  }

  // ⭐ 별 그리기 헬퍼 함수 (반짝임용)
  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final innerRadius = size * 0.4;
    final outerRadius = size;
    
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 18) * 3.14159 / 180;
      final innerAngle = (i * 72 + 18) * 3.14159 / 180;
      
      if (i == 0) {
        path.moveTo(
          center.dx + outerRadius * cos(outerAngle),
          center.dy + outerRadius * sin(outerAngle)
        );
      } else {
        path.lineTo(
          center.dx + outerRadius * cos(outerAngle),
          center.dy + outerRadius * sin(outerAngle)
        );
      }
      
      path.lineTo(
        center.dx + innerRadius * cos(innerAngle),
        center.dy + innerRadius * sin(innerAngle)
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }



  // 💧 땀방울 (과식) - 극대화: 5개
  void _drawSweatDrops(Canvas canvas, double headSize, Offset centerOffset) {
    final sweatPaint = Paint()
      ..color = Colors.blue.withAlpha(179)
      ..style = PaintingStyle.fill;
    
    // 이마와 얼굴에 땀방울 5개 (더 잘 보이게)
    final positions = [
      Offset(headSize * 0.4, centerOffset.dy - headSize * 0.7),   // 오른쪽 이마
      Offset(headSize * 0.25, centerOffset.dy - headSize * 0.8),  // 오른쪽 위
      Offset(-headSize * 0.25, centerOffset.dy - headSize * 0.75), // 왼쪽 이마
      Offset(-headSize * 0.4, centerOffset.dy - headSize * 0.65),  // 왼쪽
      Offset(headSize * 0.1, centerOffset.dy - headSize * 0.85),   // 중앙 위
    ];
    
    for (var pos in positions) {
      _drawSingleSweatDrop(canvas, pos, headSize * 0.5, sweatPaint);  // 0.35 → 0.5 (더 크게!)
    }
  }

  void _drawSingleSweatDrop(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(
      center.dx + size * 0.6, center.dy - size * 0.3,
      center.dx, center.dy + size
    );
    path.quadraticBezierTo(
      center.dx - size * 0.6, center.dy - size * 0.3,
      center.dx, center.dy - size
    );
    canvas.drawPath(path, paint);
    
    // 윤곽선 추가 (더 선명하게)
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.blue.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
    );
    
    // 하이라이트
    canvas.drawCircle(
      center + Offset(-size * 0.2, -size * 0.3),
      size * 0.3,
      Paint()..color = Colors.white.withAlpha(242)
    );
  }

  // ❗ 느낌표 (경고)
  void _drawExclamationMark(Canvas canvas, double headSize, Offset centerOffset) {
    final markPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    final markCenter = Offset(headSize * 0.8, centerOffset.dy - headSize * 1.2);
    
    // 느낌표 막대
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: markCenter, width: headSize * 0.1, height: headSize * 0.3),
        Radius.circular(headSize * 0.05)
      ),
      markPaint
    );
    
    // 느낌표 점
    canvas.drawCircle(
      markCenter + Offset(0, headSize * 0.22),
      headSize * 0.06,
      markPaint
    );
  }

  // 🤤 침(군침) (배고픔) - 극대화: 3개
  void _drawDrool(Canvas canvas, double headSize, Offset centerOffset) {
    final droolPaint = Paint()
      ..color = Colors.blue.withAlpha(128)
      ..style = PaintingStyle.fill;
    
    final mouthY = centerOffset.dy + headSize * 0.4;
    
    // 침 3개 (양쪽 + 중앙)
    _drawSingleDrool(canvas, Offset(headSize * 0.25, mouthY), headSize, droolPaint);
    _drawSingleDrool(canvas, Offset(0, mouthY + headSize * 0.02), headSize, droolPaint);
    _drawSingleDrool(canvas, Offset(-headSize * 0.22, mouthY), headSize, droolPaint);
  }

  void _drawSingleDrool(Canvas canvas, Offset start, double headSize, Paint paint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(
      start.dx + headSize * 0.03, start.dy + headSize * 0.2,
      start.dx, start.dy + headSize * 0.35
    );
    path.lineTo(start.dx - headSize * 0.025, start.dy + headSize * 0.35);
    path.quadraticBezierTo(
      start.dx - headSize * 0.03, start.dy + headSize * 0.2,
      start.dx - headSize * 0.025, start.dy
    );
    path.close();
    
    canvas.drawPath(path, paint);
    
    // 침방울 끝
    canvas.drawCircle(
      Offset(start.dx - headSize * 0.0125, start.dy + headSize * 0.37),
      headSize * 0.05,
      paint
    );
  }

  // 💖 두근두근 하트 (행복)
  void _drawFloatingHeart(Canvas canvas, double headSize, Offset centerOffset) {
    // 시간 기반 애니메이션 (간단한 시뮬레이션)
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    // Pulse 효과 (크기 변화)
    final scale = 1.0 + sin(time * 3) * 0.15;
    
    // Floating 효과 (위아래 이동) - 범위 증가
    final floatOffset = sin(time * 2) * 8;  // 4 → 8 (2배 이동 범위)
    
    final heartCenter = Offset(
      headSize * 0.65,  // 오른쪽
      centerOffset.dy - headSize * 1.4 + floatOffset  // 1.15 → 1.4 (더 위로!)
    );
    
    final heartSize = headSize * 0.5 * scale;  // 0.35 → 0.5 (더 크게!)
    
    // 하트 그리기
    final heartPaint = Paint()
      ..color = Colors.pink.shade300
      ..style = PaintingStyle.fill;
    
    final heartOutline = Paint()
      ..color = Colors.pink.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    
    _drawSimpleHeart(canvas, heartCenter, heartSize, heartPaint, heartOutline);
  }

  // 하트 그리기 헬퍼 (베지어 곡선 사용)
  void _drawSimpleHeart(Canvas canvas, Offset center, double size, Paint fillPaint, Paint outlinePaint) {
    final path = Path();
    
    // 하트 아래 끝점에서 시작
    path.moveTo(center.dx, center.dy + size * 0.6);
    
    // 왼쪽 아래 → 왼쪽 위 (곡선)
    path.cubicTo(
      center.dx - size * 0.3, center.dy + size * 0.2,  // 제어점 1
      center.dx - size * 0.6, center.dy - size * 0.1,  // 제어점 2
      center.dx - size * 0.35, center.dy - size * 0.5  // 끝점 (왼쪽 상단)
    );
    
    // 왼쪽 상단 → 중앙 상단 (둥근 모서리)
    path.cubicTo(
      center.dx - size * 0.2, center.dy - size * 0.7,  // 제어점 1
      center.dx - size * 0.05, center.dy - size * 0.7, // 제어점 2
      center.dx, center.dy - size * 0.55              // 끝점 (중앙)
    );
    
    // 중앙 상단 → 오른쪽 상단 (둥근 모서리)
    path.cubicTo(
      center.dx + size * 0.05, center.dy - size * 0.7, // 제어점 1
      center.dx + size * 0.2, center.dy - size * 0.7,  // 제어점 2
      center.dx + size * 0.35, center.dy - size * 0.5  // 끝점 (오른쪽 상단)
    );
    
    // 오른쪽 상단 → 오른쪽 아래 (곡선)
    path.cubicTo(
      center.dx + size * 0.6, center.dy - size * 0.1,  // 제어점 1
      center.dx + size * 0.3, center.dy + size * 0.2,  // 제어점 2
      center.dx, center.dy + size * 0.6                // 끝점 (아래 끝)
    );
    
    path.close();
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);
  }

  // 😋 볼 홍조 (배부름)
  void _drawCheekBlush(Canvas canvas, double headSize, Offset centerOffset) {
    final blushPaint = Paint()
      ..color = Colors.pink.withAlpha(77)
      ..style = PaintingStyle.fill;
    
    final blushY = centerOffset.dy + headSize * 0.1;
    
    // 왼쪽 볼
    canvas.drawCircle(
      Offset(-headSize * 0.4, blushY),
      headSize * 0.15,
      blushPaint
    );
    
    // 오른쪽 볼
    canvas.drawCircle(
      Offset(headSize * 0.4, blushY),
      headSize * 0.15,
      blushPaint
    );
  }

  // 😴 다크서클 (피곤) - 강화
  void _drawDarkCircles(Canvas canvas, double headSize, Offset centerOffset) {
    final circlePaint = Paint()
      ..color = Colors.grey.withAlpha(153)  // 0.4 → 0.6 더 진하게
      ..style = PaintingStyle.fill;
    
    final eyeY = centerOffset.dy - headSize * 0.1;
    
    // 왼쪽 다크서클
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(-headSize * 0.3, eyeY + headSize * 0.15),
        width: headSize * 0.3,  // 0.25 → 0.3 더 크게
        height: headSize * 0.18  // 0.15 → 0.18
      ),
      0, 3.14, false, circlePaint
    );
    
    // 오른쪽 다크서클
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(headSize * 0.3, eyeY + headSize * 0.15),
        width: headSize * 0.3,
        height: headSize * 0.18
      ),
      0, 3.14, false, circlePaint
    );
    
    // 🆕 "ZZZ" 텍스트 추가
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ZZZ',
        style: TextStyle(
          fontSize: headSize * 0.45,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade300,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(headSize * 0.6, centerOffset.dy - headSize * 1.1)
    );
  }

  // 😵 과식 추가 효과 (혀 + 빨간 얼굴)
  void _drawStuffedExtras(Canvas canvas, double headSize, Offset centerOffset) {
    // 🆕 빨간 얼굴 오버레이
    final redFacePaint = Paint()
      ..color = Colors.red.withAlpha(51)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      centerOffset,
      headSize * 0.95,
      redFacePaint
    );
    
    // 혀 (작은 타원)
    final tonguePaint = Paint()
      ..color = Colors.pink.shade400
      ..style = PaintingStyle.fill;
    
    final mouthY = centerOffset.dy + headSize * 0.4;
    final tongueCenter = Offset(0, mouthY + headSize * 0.12);  // 0.08 → 0.12 더 나오게
    
    canvas.drawOval(
      Rect.fromCenter(
        center: tongueCenter,
        width: headSize * 0.15,  // 0.12 → 0.15 더 크게
        height: headSize * 0.1   // 0.08 → 0.1
      ),
      tonguePaint
    );
  }

  // 🤤 배고픔 추가 효과 (반짝이는 별 × 5)
  void _drawHungryExtras(Canvas canvas, double headSize, Offset centerOffset) {
    final starPaint = Paint()
      ..color = Colors.yellow.shade600
      ..style = PaintingStyle.fill;
    
    final eyeY = centerOffset.dy - headSize * 0.1;
    
    // 별 5개 (눈 주변, 더 크게!)
    _drawStar(canvas, Offset(-headSize * 0.5, eyeY - headSize * 0.15), headSize * 0.5, starPaint);    // 왼쪽
    _drawStar(canvas, Offset(-headSize * 0.4, eyeY - headSize * 0.3), headSize * 0.42, starPaint);    // 왼쪽 위
    _drawStar(canvas, Offset(headSize * 0.5, eyeY - headSize * 0.15), headSize * 0.5, starPaint);     // 오른쪽
    _drawStar(canvas, Offset(headSize * 0.4, eyeY - headSize * 0.3), headSize * 0.42, starPaint);     // 오른쪽 위
    _drawStar(canvas, Offset(0, eyeY - headSize * 0.4), headSize * 0.46, starPaint);                  // 중앙
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * 3.14159 / 5) - 3.14159 / 2;
      final radius = i % 2 == 0 ? size : size * 0.4;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    
    // 윤곽선 추가 (더 선명하게)
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.orange.shade800
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
    );
  }

  // ✋ 거부 추가 효과 (볼록한 볼)
  void _drawRefuseExtras(Canvas canvas, double headSize, Offset centerOffset) {
    // 🆕 볼록한 볼 (핑크색 원)
    final puffyPaint = Paint()
      ..color = Colors.pink.withAlpha(102)
      ..style = PaintingStyle.fill;
    
    final cheekY = centerOffset.dy + headSize * 0.15;
    
    // 왼쪽 볼
    canvas.drawCircle(
      Offset(-headSize * 0.5, cheekY),
      headSize * 0.25,
      puffyPaint
    );
    
    // 오른쪽 볼  
    canvas.drawCircle(
      Offset(headSize * 0.5, cheekY),
      headSize * 0.25,
      puffyPaint
    );
    
    // 양 볼에 작은 X 마크
    final xPaint = Paint()
      ..color = Colors.pink.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    // 왼쪽 X
    canvas.drawLine(
      Offset(-headSize * 0.58, cheekY - headSize * 0.08),
      Offset(-headSize * 0.42, cheekY + headSize * 0.08),
      xPaint
    );
    canvas.drawLine(
      Offset(-headSize * 0.42, cheekY - headSize * 0.08),
      Offset(-headSize * 0.58, cheekY + headSize * 0.08),
      xPaint
    );
    
    // 오른쪽 X
    canvas.drawLine(
      Offset(headSize * 0.42, cheekY - headSize * 0.08),
      Offset(headSize * 0.58, cheekY + headSize * 0.08),
      xPaint
    );
    canvas.drawLine(
      Offset(headSize * 0.58, cheekY - headSize * 0.08),
      Offset(headSize * 0.42, cheekY + headSize * 0.08),
      xPaint
    );
  }

  void _drawEyes(Canvas canvas, double headSize, Offset centerOffset) {
    // 🎭 Phase 1: 표정별 맞춤 눈 렌더링
    switch (currentExpressionType) {
      case FaceExpressionType.happy:
        // 💖 행복은 만족 표정과 동일하게 (특수 효과는 하트로!)
        if (gender == 'male') {
          _drawMaleEyes(canvas, headSize, centerOffset);
        } else {
          _drawFemaleEyes(canvas, headSize, centerOffset);
        }
        break;
      case FaceExpressionType.stuffed:
        _drawXEyes(canvas, headSize, centerOffset, isStuffed: true);
        break;
      case FaceExpressionType.refuse:
        _drawXEyes(canvas, headSize, centerOffset, isStuffed: false);
        break;
      case FaceExpressionType.hungry:
        _drawHungryEyes(canvas, headSize, centerOffset);
        break;
      case FaceExpressionType.tired:
        _drawTiredEyes(canvas, headSize, centerOffset);
        break;
      default:
        // 기본: 성별별 렌더링
        if (gender == 'male') {
          _drawMaleEyes(canvas, headSize, centerOffset);
        } else {
          _drawFemaleEyes(canvas, headSize, centerOffset);
        }
        break;
    }
  }

  // 😵 X자 눈 (과식/거부)
  void _drawXEyes(Canvas canvas, double headSize, Offset centerOffset, {required bool isStuffed}) {
    final xPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = isStuffed ? 4.0 : 3.0;
    
    final eyeY = centerOffset.dy - headSize * 0.15;  // 위치 조정
    final xSize = headSize * (isStuffed ? 0.15 : 0.12);
    
    // 왼쪽 X
    final leftCenter = Offset(-headSize * 0.3, eyeY);
    canvas.drawLine(
      leftCenter + Offset(-xSize, -xSize),
      leftCenter + Offset(xSize, xSize),
      xPaint
    );
    canvas.drawLine(
      leftCenter + Offset(-xSize, xSize),
      leftCenter + Offset(xSize, -xSize),
      xPaint
    );
    
    // 오른쪽 X
    final rightCenter = Offset(headSize * 0.3, eyeY);
    canvas.drawLine(
      rightCenter + Offset(-xSize, -xSize),
      rightCenter + Offset(xSize, xSize),
      xPaint
    );
    canvas.drawLine(
      rightCenter + Offset(-xSize, xSize),
      rightCenter + Offset(xSize, -xSize),
      xPaint
    );
  }

  // 🤤 배고픈 눈 (매우 큼)
  void _drawHungryEyes(Canvas canvas, double headSize, Offset centerOffset) {
    final eyeY = centerOffset.dy - headSize * 0.15;  // 위치 조정
    final eyeSize = headSize * 0.32;  // 0.35 → 0.32 약간 축소
    
    final whitePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final outlinePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final pupilPaint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    
    // 왼쪽 큰 눈
    canvas.drawCircle(Offset(-headSize * 0.3, eyeY), eyeSize, whitePaint);
    canvas.drawCircle(Offset(-headSize * 0.3, eyeY), eyeSize, outlinePaint);
    canvas.drawCircle(Offset(-headSize * 0.3, eyeY), eyeSize * 0.5, pupilPaint);
    
    // 하이라이트 × 2
    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(-headSize * 0.35, eyeY - eyeSize * 0.2), eyeSize * 0.2, highlightPaint);
    canvas.drawCircle(Offset(-headSize * 0.22, eyeY - eyeSize * 0.15), eyeSize * 0.12, highlightPaint);
    
    // 오른쪽 큰 눈
    canvas.drawCircle(Offset(headSize * 0.3, eyeY), eyeSize, whitePaint);
    canvas.drawCircle(Offset(headSize * 0.3, eyeY), eyeSize, outlinePaint);
    canvas.drawCircle(Offset(headSize * 0.3, eyeY), eyeSize * 0.5, pupilPaint);
    
    canvas.drawCircle(Offset(headSize * 0.25, eyeY - eyeSize * 0.2), eyeSize * 0.2, highlightPaint);
    canvas.drawCircle(Offset(headSize * 0.38, eyeY - eyeSize * 0.15), eyeSize * 0.12, highlightPaint);
  }

  // 😴 피곤한 눈 (반쯤 감김)
  void _drawTiredEyes(Canvas canvas, double headSize, Offset centerOffset) {
    final eyeY = centerOffset.dy - headSize * 0.15;  // 위치 조정
    final eyeWidth = headSize * 0.25;
    final eyeHeight = headSize * 0.08;
    
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    // 왼쪽 반쯤 감긴 눈
    canvas.drawLine(
      Offset(-headSize * 0.42, eyeY),
      Offset(-headSize * 0.18, eyeY + eyeHeight),
      eyePaint
    );
    
    // 오른쪽 반쯤 감긴 눈
    canvas.drawLine(
      Offset(headSize * 0.18, eyeY + eyeHeight),
      Offset(headSize * 0.42, eyeY),
      eyePaint
    );
    
    // 처진 눈썹
    final eyebrowPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawLine(
      Offset(-headSize * 0.45, eyeY - headSize * 0.12),
      Offset(-headSize * 0.15, eyeY - headSize * 0.18),
      eyebrowPaint
    );
    canvas.drawLine(
      Offset(headSize * 0.15, eyeY - headSize * 0.18),
      Offset(headSize * 0.45, eyeY - headSize * 0.12),
      eyebrowPaint
    );
  }


  void _drawMouth(Canvas canvas, double headSize, Offset centerOffset) {
    if (gender == 'male') {
      _drawMaleMouth(canvas, headSize, centerOffset);
    } else {
      _drawFemaleMouth(canvas, headSize, centerOffset);
    }
  }

  // 👨 남성 눈 렌더링 - 고도화 (작고 날카로운 눈매)
  void _drawMaleEyes(Canvas canvas, double headSize, Offset centerOffset) {
    final eyeY = centerOffset.dy - headSize * 0.1;
    final eyeX = headSize * 0.3;
    final eyeSize = headSize * 0.2;  // 남성 눈 크기 증가 (0.15 → 0.2)
    
    // 왼쪽 눈
    _drawSingleMaleEye(canvas, Offset(-eyeX, eyeY), headSize, eyeSize);
    // 오른쪽 눈
    _drawSingleMaleEye(canvas, Offset(eyeX, eyeY), headSize, eyeSize);
  }
  
  void _drawSingleMaleEye(Canvas canvas, Offset center, double headSize, double eyeSize) {
    // 1. 👁️ 눈썹 (굵고 일자형)
    final eyebrowPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;  // 더 굵게 (2.5 → 3.0)
    
    final eyebrowY = center.dy - eyeSize * 0.9;
    final eyebrowWidth = eyeSize * 1.3;
    
    // 약간 각진 일자형 눈썹
    canvas.drawLine(
      Offset(center.dx - eyebrowWidth / 2, eyebrowY),
      Offset(center.dx + eyebrowWidth / 2, eyebrowY - 1),  // 살짝 각도
      eyebrowPaint
    );
    
    // 2. 👀 눈 (작고 날카로운)
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    switch (eyeState) {
      case EyeState.closed:
        final closedPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawLine(
          center + Offset(-eyeSize * 0.6, 0),
          center + Offset(eyeSize * 0.6, 0),
          closedPaint
        );
        break;
        
      case EyeState.smiling:
        final smilePaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        final smilePath = Path();
        smilePath.addArc(
          Rect.fromCenter(center: center, width: eyeSize * 1.2, height: eyeSize * 0.8),
          3.14, 3.14
        );
        canvas.drawPath(smilePath, smilePaint);
        break;
        
      case EyeState.angry:
        // 화난 눈 (각진 느낌)
        final angryPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawLine(
          center + Offset(-eyeSize * 0.6, -3),
          center + Offset(eyeSize * 0.6, 3),
          angryPaint
        );
        break;
        
      default:
        // 기본: 더 큰 검은 점
        canvas.drawCircle(center, eyeSize * 0.35, eyePaint);
        
        // ✨ 눈 반짝임 효과 (eyeSparkle이 true일 때)
        if (expression.eyeSparkle) {
          _drawSparkle(
            canvas, 
            center + Offset(eyeSize * 0.15, -eyeSize * 0.15), // 눈동자 우상단
            eyeSize * 0.35, // 적절한 크기
            Paint()..color = Colors.white.withAlpha(230)..style = PaintingStyle.fill
          );
        }
        break;
    }
  }

  void _drawSingleEye(Canvas canvas, Offset center, Paint paint) {
    switch (eyeState) {
      case EyeState.closed:
        canvas.drawLine(center + const Offset(-5, 0), center + const Offset(5, 0), paint);
        break;
      case EyeState.smiling:
        canvas.drawArc(Rect.fromCenter(center: center, width: 10, height: 10), 3.14, 3.14, false, paint);
        break;
      case EyeState.sad:
        canvas.drawLine(center + const Offset(-5, -2), center + const Offset(5, 2), paint);
        break;
      case EyeState.wide:
        canvas.drawCircle(center, 4, Paint()..color = Colors.black);
        break;
      case EyeState.angry:
        // Simple angry eye representation
        canvas.drawLine(center + const Offset(-5, -3), center + const Offset(5, 0), paint);
        break;
      default: // Open
        canvas.drawCircle(center, 2, Paint()..color = Colors.black);
        break;
    }
  }

  // 👩 여성 눈 렌더링 - 고도화 (큰 눈, 속눈썹, 하이라이트)
  void _drawFemaleEyes(Canvas canvas, double headSize, Offset centerOffset) {
    final eyeY = centerOffset.dy - headSize * 0.1;
    final eyeX = headSize * 0.3;
    
    // 왼쪽 눈
    _drawSingleFemaleEye(canvas, Offset(-eyeX, eyeY), headSize, true);
    // 오른쪽 눈
    _drawSingleFemaleEye(canvas, Offset(eyeX, eyeY), headSize, false);
  }
  
  void _drawSingleFemaleEye(Canvas canvas, Offset center, double headSize, bool isLeft) {
    // 🎨 FaceExpression 파라미터 활용
    final baseEyeSize = headSize * 0.28;
    final eyeSize = baseEyeSize * expression.eyeScale;  // 표정에 따른 눈 크기 조절
    
    // 1. 👁️ 눈썹 (가늘고 아치형)
    final eyebrowPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final eyebrowPath = Path();
    final eyebrowY = center.dy - eyeSize * 0.8;
    final eyebrowWidth = eyeSize * 1.2;
    
    // 🆕 눈썹 각도 반영
    canvas.save();
    canvas.translate(center.dx, eyebrowY);
    canvas.rotate(expression.eyebrowAngle * (isLeft ? -1 : 1));  // 좌우 대칭
    
    eyebrowPath.moveTo(-eyebrowWidth / 2, 0);
    eyebrowPath.quadraticBezierTo(
      0, -eyeSize * 0.3,  // 아치 정점
      eyebrowWidth / 2, 0
    );
    canvas.drawPath(eyebrowPath, eyebrowPaint);
    canvas.restore();
    
    // 2. 👀 눈 윤곽 (큰 타원)
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final eyeOutlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    switch (eyeState) {
      case EyeState.closed:
        // 눈 감은 상태
        canvas.drawLine(
          center + Offset(-eyeSize * 0.6, 0),
          center + Offset(eyeSize * 0.6, 0),
          eyeOutlinePaint
        );
        break;
        
      case EyeState.smiling:
        // 미소 짓는 눈 (초승달 모양)
        final smilePath = Path();
        smilePath.addArc(
          Rect.fromCenter(center: center, width: eyeSize * 1.2, height: eyeSize),
          3.14, 3.14
        );
        canvas.drawPath(smilePath, eyeOutlinePaint);
        break;
        
      default:
        // 기본 상태: 큰 둥근 눈
        // 🆕 눈꺼풀 높이 반영
        final effectiveEyeHeight = eyeSize * expression.eyelidHeight;
        final eyeRect = Rect.fromCenter(
          center: center,
          width: eyeSize * 1.2,
          height: effectiveEyeHeight
        );
        
        // 흰자
        canvas.drawOval(eyeRect, eyePaint);
        canvas.drawOval(eyeRect, eyeOutlinePaint);
        
        // 눈동자 (🆕 표정 색상 반영)
        final pupilSize = eyeSize * 0.4;
        canvas.drawCircle(center, pupilSize, Paint()..color = expression.eyeColor);
        
        // ✨ 하이라이트 (반짝이는 효과)
        final highlightPaint = Paint()..color = Colors.white;
        canvas.drawCircle(
          center + Offset(-pupilSize * 0.3, -pupilSize * 0.3),
          pupilSize * 0.3,
          highlightPaint
        );
        break;
    }
    
    // 3. 💁 속눈썹 (위쪽에 3-4개)
    if (eyeState != EyeState.closed) {
      final lashPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      // 속눈썹 4개 그리기
      for (int i = 0; i < 4; i++) {
        final lashX = center.dx - eyeSize * 0.5 + (eyeSize * i / 3);
        final lashStartY = center.dy - eyeSize * 0.5;
        final lashEndY = lashStartY - eyeSize * 0.3;
        
        final lashPath = Path();
        lashPath.moveTo(lashX, lashStartY);
        lashPath.quadraticBezierTo(
          lashX + (isLeft ? -2 : 2), lashEndY - 2,
          lashX + (isLeft ? -3 : 3), lashEndY
        );
        canvas.drawPath(lashPath, lashPaint);
      }
    }
  }

  // 👨 남성 입 렌더링 - 고도화 (얇고 직선적)
  void _drawMaleMouth(Canvas canvas, double headSize, Offset centerOffset) {
    final mouthY = centerOffset.dy + headSize * 0.4;
    final center = Offset(0, mouthY);
    final mouthWidth = headSize * 0.4;  // 남성 입 크기 증가 (0.3 → 0.4)
    
    // 얇은 검은색/갈색 입술
    final lipPaint = Paint()
      ..color = const Color(0xFF8B7355).withAlpha(153)  // 피부색에 가까운 갈색
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    switch (mouthState) {
      case MouthState.smile:
        // 😊 미소 (더 많이 올라간 곡선)
        final smilePath = Path();
        smilePath.moveTo(center.dx - mouthWidth / 2, center.dy);
        smilePath.quadraticBezierTo(
          center.dx, center.dy - mouthWidth * 0.25,  // 더 많이 올라감 (0.15 → 0.25)
          center.dx + mouthWidth / 2, center.dy
        );
        canvas.drawPath(smilePath, lipPaint);
        break;
        
      case MouthState.frown:
        // 😔 슬픔 (더 많이 내려간 곡선)
        final frownPath = Path();
        frownPath.moveTo(center.dx - mouthWidth / 2, center.dy);
        frownPath.quadraticBezierTo(
          center.dx, center.dy + mouthWidth * 0.25,  // 더 많이 내려감 (0.15 → 0.25)
          center.dx + mouthWidth / 2, center.dy
        );
        canvas.drawPath(frownPath, lipPaint);
        break;
        
      case MouthState.open:
        // 😮 놀람 (작은 타원)
        canvas.drawOval(
          Rect.fromCenter(center: center, width: mouthWidth * 0.5, height: mouthWidth * 0.4),
          lipPaint
        );
        break;
        
      case MouthState.line:
        // 😐 일자 (완전 직선)
        canvas.drawLine(
          center + Offset(-mouthWidth / 2, 0),
          center + Offset(mouthWidth / 2, 0),
          lipPaint
        );
        break;
        
      default:
        // 기본: 얇은 직선
        canvas.drawLine(
          center + Offset(-mouthWidth * 0.4, 0),
          center + Offset(mouthWidth * 0.4, 0),
          lipPaint
        );
        break;
    }
  }

  // 👩 여성 입 렌더링 - Phase 2: 크고 선명하게
  void _drawFemaleMouth(Canvas canvas, double headSize, Offset centerOffset) {
    // 행복 표정일 때는 입을 더 아래로
    final mouthYOffset = currentExpressionType == FaceExpressionType.happy 
        ? headSize * 0.5  // 행복: 더 아래
        : headSize * 0.4; // 기본
    final mouthY = centerOffset.dy + mouthYOffset;
    final center = Offset(0, mouthY);
    // 🎨 입 크기 조정 (눈을 가리지 않도록)
    final baseMouthWidth = headSize * 0.35;  // 0.5 → 0.35 (원래 크기로)
    final mouthWidth = baseMouthWidth * expression.mouthWidth;
    final curveOffset = expression.mouthCurve * 5.0;  // 10.0 → 5.0 (위로 덜 올라감)
    
    // 💋 Phase 2: 더 진한 핑크색
    final lipPaint = Paint()
      ..color = const Color(0xFFFF9EBB)
      ..style = PaintingStyle.fill;
    
    final lipOutlinePaint = Paint()
      ..color = const Color(0xFFFF1493)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    switch (mouthState) {
      case MouthState.smile:
        // 😊 미소
        _drawHeartLips(canvas, center + Offset(0, -curveOffset.abs()), mouthWidth * 1.2, lipPaint, lipOutlinePaint, true);
        break;
        
      case MouthState.frown:
        // 😔 슬픔
        _drawHeartLips(canvas, center + Offset(0, curveOffset.abs()), mouthWidth, lipPaint, lipOutlinePaint, false);
        break;
        
      case MouthState.open:
        // 😮 놀람 - 크게!
        canvas.drawOval(
          Rect.fromCenter(center: center, width: mouthWidth * 0.8, height: mouthWidth),
          lipPaint
        );
        canvas.drawOval(
          Rect.fromCenter(center: center, width: mouthWidth * 0.8, height: mouthWidth),
          lipOutlinePaint
        );
        break;
        
      default:
        // 기본 상태: 하트 모양 입술
        final adjustedCenter = Offset(center.dx, center.dy - curveOffset);
        _drawHeartLips(canvas, adjustedCenter, mouthWidth, lipPaint, lipOutlinePaint, curveOffset > 0);
        break;
    }
  }
  
  // 💕 하트 모양 입술 그리기
  void _drawHeartLips(Canvas canvas, Offset center, double width, Paint fillPaint, Paint outlinePaint, bool isSmiling) {
    final lipPath = Path();
    final halfWidth = width / 2;
    final height = width * 0.4;
    
    // 윗입술 (큐피드 활 모양)
    lipPath.moveTo(center.dx - halfWidth, center.dy);
    
    // 왼쪽 곡선
    lipPath.quadraticBezierTo(
      center.dx - halfWidth * 0.6, center.dy - height * 0.6,
      center.dx - halfWidth * 0.2, center.dy - height * 0.4
    );
    
    // 가운데 V자 (큐피드 활)
    lipPath.quadraticBezierTo(
      center.dx, center.dy - height * 0.2,
      center.dx + halfWidth * 0.2, center.dy - height * 0.4
    );
    
    // 오른쪽 곡선
    lipPath.quadraticBezierTo(
      center.dx + halfWidth * 0.6, center.dy - height * 0.6,
      center.dx + halfWidth, center.dy
    );
    
    // 아랫입술 (도톰하게)
    final bottomCurve = isSmiling ? height * 0.9 : height * 1.1;
    lipPath.quadraticBezierTo(
      center.dx + halfWidth * 0.5, center.dy + bottomCurve,
      center.dx, center.dy + bottomCurve * 0.9
    );
    lipPath.quadraticBezierTo(
      center.dx - halfWidth * 0.5, center.dy + bottomCurve,
      center.dx - halfWidth, center.dy
    );
    
    lipPath.close();
    
    // 그리기
    canvas.drawPath(lipPath, fillPaint);
    canvas.drawPath(lipPath, outlinePaint);
  }
}

/// 볼(뺨) 부분 - BMI에 따라 크기 변화
class CheekPart extends BodyPart {
  final bool isLeft;
  MouthState mouthState;

  CheekPart({
    required super.measurements,
    required this.isLeft,
    this.mouthState = MouthState.neutral,
  });

  void updateMouthState(MouthState newMouth) {
    mouthState = newMouth;
  }

  @override
  @override
  void render(Canvas canvas) {
    final headSize = measurements.headSize;
    final bmi = measurements.bmi;
    final centerOffset = Offset(0, -headSize * 0.7);
    
    // 🎯 BMI에 따른 볼 크기 계산
    double cheekSize;
    if (bmi < 18.5) {
      // 저체중
      cheekSize = headSize * 0.15;
    } else if (bmi < 25) {
      // 정상
      cheekSize = headSize * 0.2;
    } else if (bmi < 30) {
      // 과체중
      cheekSize = headSize * 0.28;
    } else {
      // 비만
      cheekSize = headSize * 0.35;
    }
    
    // 볼 위치 (얼굴 안쪽으로 이동하여 잘 보이게)
    // 눈 바로 아래, 코 옆쪽으로 당김
    double xOffset = 0.25; // 0.35 → 0.25 (안쪽으로)
    if (bmi >= 30) xOffset = 0.3; // 비만일 때도 너무 바깥으로 가지 않게
    
    final cheekX = (isLeft ? -1 : 1) * headSize * xOffset;
    final cheekY = centerOffset.dy + headSize * 0.3; // 0.2 → 0.3 (아래로)
    final center = Offset(cheekX, cheekY);
    
    // 🎨 볼 그리기
    if (bmi >= 25) {
      // 1. 과체중/비만: 입체적인 볼살 (유방처럼 둥근 음영)
      
      // 기본 살색 베이스 (약간 어두운 톤으로 그림자 역할)
      final shadowColor = const Color(0xFFD2B48C).withAlpha(153); // Tan color (진하게)
      final highlightColor = const Color(0xFFFFE4E1).withAlpha(102); // MistyRose
      
      // 그라데이션
      final gradient = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [highlightColor, shadowColor],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: cheekSize));
      
      final volumePaint = Paint()
        ..shader = gradient
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); // Blur 감소
      
      canvas.drawCircle(center, cheekSize, volumePaint);
      
      // 아래쪽 그림자
      final bottomShadowPath = Path();
      bottomShadowPath.addArc(
        Rect.fromCenter(center: center + Offset(0, cheekSize * 0.1), width: cheekSize * 1.8, height: cheekSize * 1.8),
        0.5, 2.14,
      );
      
      final bottomShadowPaint = Paint()
        ..color = Colors.black.withAlpha(38) // 그림자도 약간 진하게
        ..style = PaintingStyle.stroke
        ..strokeWidth = cheekSize * 0.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
        
      canvas.drawPath(bottomShadowPath, bottomShadowPaint);
      
    } else {
      // 3. 정상/저체중: 기존의 은은한 홍조 (선명하게)
      final cheekPaint = Paint()
        ..color = const Color(0xFFFF9E80).withAlpha(153) // 0.4 → 0.6 (진하게)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0); // 5.0 → 3.0 (또렷하게)
      
      canvas.drawCircle(center, cheekSize, cheekPaint);
    }
    
    // 😊 표정이 smile일 때 볼에 붉은 기 추가 (여성만)
    if (measurements.gender == 'female' && mouthState == MouthState.smile) {
      final blushPaint = Paint()
        ..color = const Color(0xFFFF1493).withAlpha(153)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      
      canvas.drawCircle(
        Offset(cheekX, cheekY),
        cheekSize * 0.8,
        blushPaint,
      );
    }
  }
}

/// 귀 부분
class EarPart extends BodyPart {
  final bool isLeft;

  EarPart({
    required super.measurements,
    required this.isLeft,
  });

  @override
  void render(Canvas canvas) {
    final headSize = measurements.headSize;
    final centerOffset = Offset(0, -headSize * 0.7);
    
    // 귀 크기
    final earHeight = headSize * 0.4;
    final earWidth = headSize * 0.25;
    
    // 귀 위치 (머리 양 옆)
    final earX = (isLeft ? -1 : 1) * headSize * 0.95;
    final earY = centerOffset.dy + headSize * 0.1;
    final earCenter = Offset(earX, earY);
    
    // 1. 👂 바깥 귀 윤곽 (타원형)
    final outerEarRect = Rect.fromCenter(
      center: earCenter,
      width: earWidth,
      height: earHeight,
    );
    
    canvas.drawOval(outerEarRect, paint);
    renderOutline(canvas, Path()..addOval(outerEarRect));
    
    // 2. 귓바퀴 (내부 곡선)
    final innerPath = Path();
    final innerX = earX + (isLeft ? earWidth * 0.15 : -earWidth * 0.15);
    
    innerPath.moveTo(innerX, earY - earHeight * 0.3);
    innerPath.quadraticBezierTo(
      innerX + (isLeft ? earWidth * 0.1 : -earWidth * 0.1), earY - earHeight * 0.1,
      innerX, earY + earHeight * 0.1
    );
    
    final innerPaint = Paint()
      ..color = paint.color.withAlpha(128)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(innerPath, innerPaint);
    
    // 3. 귓불 (아래쪽 둥근 부분 강조)
    final earlobePaint = Paint()
      ..color = paint.color.withAlpha(77)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    
    canvas.drawCircle(
      Offset(earX, earY + earHeight * 0.4),
      earWidth * 0.3,
      earlobePaint,
    );
  }
}

class HairPart extends BodyPart {
  final String gender;
  
  HairPart({required super.measurements, required this.gender});

  @override
  void render(Canvas canvas) {
    final headSize = measurements.headSize;
    final hairColor = Paint()..color = const Color(0xFF2C1810); // Dark brown
    
    // HairPart는 이제 head의 자식이므로 head의 로컬 좌표계를 사용
    // HeadPart의 centerOffset(0, -headSize*0.7)을 그대로 적용
    final centerOffset = Offset(0, -headSize * 0.7);
    
    // 🎯 근본적 해결: clipRect로 렌더링 영역 제한
    // 포니테일이 보이도록 높이를 늘림
    canvas.save();
    final clipRect = Rect.fromLTWH(
      -headSize * 2.5,           // 좌측 (충분히 넓게)
      centerOffset.dy - headSize * 1.6,  // 상단 (머리 위쪽)
      headSize * 5.0,            // 너비 (충분히 넓게)
      headSize * 3.5             // 높이 (포니테일까지 보이도록)
    );
    canvas.clipRect(clipRect);
    
    if (gender == 'male') {
      _renderMaleHair(canvas, headSize, hairColor, centerOffset);
    } else {
      _renderFemaleHair(canvas, headSize, hairColor, centerOffset);
    }
    
    canvas.restore();
  }
  
  void _renderMaleHair(Canvas canvas, double headSize, Paint hairColor, Offset centerOffset) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset(centerOffset.dx, centerOffset.dy - headSize * 0.2), radius: headSize * 1.1));
    canvas.drawPath(path, hairColor);
  }
  
  void _renderFemaleHair(Canvas canvas, double headSize, Paint hairColor, Offset centerOffset) {
    final baseY = centerOffset.dy;
    
    // 💇‍♀️ 일반적인 긴 머리 스타일
    
    // 1. 뒷머리 전체 (어깨까지 자연스럽게 흐름)
    final backHair = Path();
    
    // 상단 (머리 꼭대기)
    backHair.moveTo(-headSize * 1.1, baseY - headSize * 0.5);
    backHair.quadraticBezierTo(0, baseY - headSize * 1.5, headSize * 1.1, baseY - headSize * 0.5);
    
    // 오른쪽 측면 (자연스럽게 흘러내림)
    backHair.cubicTo(
      headSize * 1.2, baseY,
      headSize * 1.15, baseY + headSize * 0.8,
      headSize * 1.0, baseY + headSize * 1.5  // 어깨 높이
    );
    
    // 오른쪽 아래 (어깨선)
    backHair.cubicTo(
      headSize * 0.9, baseY + headSize * 2.0,
      headSize * 0.6, baseY + headSize * 2.3,
      headSize * 0.3, baseY + headSize * 2.5  // 끝부분
    );
    
    // 아래쪽 중앙 (약간 둥글게)
    backHair.quadraticBezierTo(
      0, baseY + headSize * 2.6,
      -headSize * 0.3, baseY + headSize * 2.5
    );
    
    // 왼쪽 아래
    backHair.cubicTo(
      -headSize * 0.6, baseY + headSize * 2.3,
      -headSize * 0.9, baseY + headSize * 2.0,
      -headSize * 1.0, baseY + headSize * 1.5
    );
    
    // 왼쪽 측면 (위로 올라감)
    backHair.cubicTo(
      -headSize * 1.15, baseY + headSize * 0.8,
      -headSize * 1.2, baseY,
      -headSize * 1.1, baseY - headSize * 0.5
    );
    
    backHair.close();
    canvas.drawPath(backHair, hairColor);
    
    // 2. 사이드 헤어 (얼굴 양 옆, 여성성 강조)
    // 왼쪽 사이드
    final leftSide = Path();
    leftSide.moveTo(-headSize * 0.85, baseY - headSize * 0.3);
    leftSide.cubicTo(
      -headSize * 1.0, baseY + headSize * 0.2,
      -headSize * 0.95, baseY + headSize * 0.8,
      -headSize * 0.85, baseY + headSize * 1.3
    );
    leftSide.quadraticBezierTo(
      -headSize * 0.75, baseY + headSize * 1.4,
      -headSize * 0.7, baseY + headSize * 1.1
    );
    leftSide.cubicTo(
      -headSize * 0.75, baseY + headSize * 0.6,
      -headSize * 0.75, baseY + headSize * 0.1,
      -headSize * 0.7, baseY - headSize * 0.25
    );
    leftSide.close();
    canvas.drawPath(leftSide, hairColor);
    
    // 오른쪽 사이드
    final rightSide = Path();
    rightSide.moveTo(headSize * 0.85, baseY - headSize * 0.3);
    rightSide.cubicTo(
      headSize * 1.0, baseY + headSize * 0.2,
      headSize * 0.95, baseY + headSize * 0.8,
      headSize * 0.85, baseY + headSize * 1.3
    );
    rightSide.quadraticBezierTo(
      headSize * 0.75, baseY + headSize * 1.4,
      headSize * 0.7, baseY + headSize * 1.1
    );
    rightSide.cubicTo(
      headSize * 0.75, baseY + headSize * 0.6,
      headSize * 0.75, baseY + headSize * 0.1,
      headSize * 0.7, baseY - headSize * 0.25
    );
    rightSide.close();
    canvas.drawPath(rightSide, hairColor);
  }
}

class FrontHairPart extends BodyPart {
  final String gender;
  
  FrontHairPart({required super.measurements, required this.gender});

  @override
  void render(Canvas canvas) {
    final headSize = measurements.headSize;
    final hairColor = Paint()..color = const Color(0xFF2C1810);
    
    // Apply same offset as HeadPart
    final centerOffset = Offset(0, -headSize * 0.7);
    
    canvas.save();
    canvas.translate(centerOffset.dx, centerOffset.dy);
    
    if (gender == 'male') {
      // Male bangs
      canvas.drawArc(Rect.fromCircle(center: Offset(0, -headSize * 0.5), radius: headSize), 3.14, 3.14, true, hairColor);
    } else {
      // Female bangs
      canvas.drawArc(Rect.fromCircle(center: Offset(0, -headSize * 0.5), radius: headSize), 3.14, 3.14, true, hairColor);
    }
    
    canvas.restore();
  }
}

class ShoulderPart extends BodyPart {
  final bool isLeft;
  ShoulderPart({required super.measurements, required this.isLeft});

  @override
  void render(Canvas canvas) {
    // Shoulders are now integrated into Torso and Arm paths.
    // No additional rendering needed.
  }
}

class UpperArmPart extends BodyPart {
  final bool isLeft;
  UpperArmPart({required super.measurements, required this.isLeft});

  @override
  void render(Canvas canvas) {
    final w = measurements.armWidth;
    final l = measurements.armLength;
    final muscle = measurements.muscleFactor;
    final fat = measurements.fatFactor;
    
    final path = Path();
    path.moveTo(0, 0); // Shoulder joint
    
    // Outer arm (Deltoid + Triceps)
    double tricepBulge = 0.0;
    if (muscle > 5.0) tricepBulge += w * 0.2; // 근육형 삼두
    if (fat > 10.0) tricepBulge += w * 0.3;   // 비만형 팔뚝살
    
    path.cubicTo(
      w * 0.8, l * 0.2, 
      w * (0.5 + tricepBulge/w), l * 0.5, 
      w * 0.35, l // Elbow outer (Reduced width for matching)
    );
    
    // Elbow connection (Rounded end)
    path.cubicTo(
      w * 0.15, l + w * 0.15, // Control point 1 (Right side)
      -w * 0.15, l + w * 0.15, // Control point 2 (Left side)
      -w * 0.35, l // End point
    );
    
    // Inner arm (Biceps)
    double bicepBulge = 0.0;
    if (muscle > 5.0) bicepBulge += w * 0.25; // 근육형 이두
    
    path.cubicTo(
      -w * (0.5 + bicepBulge/w), l * 0.5, 
      -w * 0.6, l * 0.2, 
      0, 0
    );
    
    path.close();
    
    // 그림자 및 외곽선
    renderShadow(canvas, path);
    canvas.drawPath(path, paint);
    renderOutline(canvas, path);
    
    // Muscle details
    if (muscle > 5.0 && fat < 5.0) {
      final musclePaint = Paint()..color = const Color(0x10000000)..style = PaintingStyle.stroke..strokeWidth = 1.0;
      // Deltoid separation
      canvas.drawArc(Rect.fromCenter(center: Offset(0, l*0.2), width: w, height: l*0.3), 0.5, 2.1, false, musclePaint);
    }
  }
}

class ForearmPart extends BodyPart {
  final bool isLeft;
  ForearmPart({required super.measurements, required this.isLeft});

  @override
  void render(Canvas canvas) {
    final w = measurements.armWidth * 0.85; // 전완은 상완보다 약간 얇음
    final l = measurements.forearmLength;
    final muscle = measurements.muscleFactor;
    
    final path = Path();
    
    // Define extensorBulge early
    double extensorBulge = 0.0;
    if (muscle > 5.0) extensorBulge = w * 0.15;
    
    // 1. Start at Inner Elbow (Match UpperArm bottom width)
    path.moveTo(-w * 0.35, 0);
    
    // 2. Inner Forearm (Flexors) -> To Wrist Inner
    path.cubicTo(
      -w * 0.4, l * 0.3, 
      -w * (0.5 + extensorBulge/w), l * 0.7, 
      -w * 0.3, l 
    );
    
    // 3. Wrist Bottom (Inner to Outer)
    path.lineTo(w * 0.3, l);
    
    // 4. Outer Forearm (Extensors) -> To Outer Elbow
    path.cubicTo(
      w * 0.4, l * 0.7, 
      w * (0.5 + extensorBulge/w), l * 0.3, 
      w * 0.35, 0 
    );
    
    // 5. Elbow Joint Top Curve (Outer to Inner)
    path.cubicTo(
      w * 0.15, -w * 0.2, // Control 1
      -w * 0.15, -w * 0.2, // Control 2
      -w * 0.35, 0 // End point (Back to start)
    );
    
    path.close();
    
    // 그림자 및 외곽선
    renderShadow(canvas, path);
    canvas.drawPath(path, paint);
    renderOutline(canvas, path);
    
    // Hand rendering (attached to Forearm)
    _renderHand(canvas, w, l);
  }
  
  void _renderHand(Canvas canvas, double armW, double armL) {
    final handY = armL;
    final handSize = armW * 1.1;
    
    final handPath = Path();
    handPath.moveTo(-handSize * 0.3, handY);
    
    // Thumb
    handPath.quadraticBezierTo(
      -handSize * 0.8, handY + handSize * 0.4, 
      -handSize * 0.4, handY + handSize * 0.6
    );

    // Fingers area
    handPath.cubicTo(
      -handSize * 0.4, handY + handSize * 1.2, 
      handSize * 0.4, handY + handSize * 1.2, 
      handSize * 0.3, handY
    );
    
    handPath.close();
    
    // 손에도 그림자/외곽선 적용
    renderShadow(canvas, handPath);
    canvas.drawPath(handPath, paint);
    renderOutline(canvas, handPath);
  }
}

class PelvisPart extends BodyPart {
  PelvisPart({required super.measurements});

  @override
  void render(Canvas canvas) {
    final w = measurements.hipWidth;
    final h = measurements.torsoHeight * 0.25;
    final isFemale = measurements.gender == 'female';
    
    final path = Path();
    // Top center (connects to Torso)
    path.moveTo(0, 0);
    
    // Right hip curve
    if (isFemale) {
      path.cubicTo(
        w / 2 * 0.7, -h * 0.05,  // 위쪽에서 시작 (부드러운 연결)
        w / 2 * 0.95, h * 0.15,  // 골반 곡선
        w / 2, h * 0.7           // 하단
      );
    } else {
      path.cubicTo(
        w / 2 * 0.8, -h * 0.05,  // 위쪽에서 시작
        w / 2, h * 0.25,         // 골반 곡선
        w / 2, h * 0.6           // 하단
      );
    }
    
    // Right leg socket area
    path.quadraticBezierTo(
      w / 2 * 0.9, h, 
      w / 4, h
    );
    
    // Crotch area
    path.lineTo(-w / 4, h);
    
    // Left leg socket area
    path.quadraticBezierTo(
      -w / 2 * 0.9, h, 
      -w / 2, h * (isFemale ? 0.7 : 0.6)
    );
    
    // Left hip curve
    if (isFemale) {
      path.cubicTo(
        -w / 2, h * 0.15,        // 골반 곡선
        -w / 2 * 0.7, -h * 0.05, // 위쪽으로 부드럽게
        0, 0                     // 시작점
      );
    } else {
      path.cubicTo(
        -w / 2, h * 0.25,
        -w / 2 * 0.8, -h * 0.05,
        0, 0
      );
    }
    
    path.close();
    
    // 그림자 및 외곽선
    renderShadow(canvas, path);
    canvas.drawPath(path, paint);
    renderOutline(canvas, path);
    
    // Underwear line (optional)
    final linePaint = Paint()..color = const Color(0x10000000)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    canvas.drawLine(Offset(-w/3, h*0.2), Offset(w/3, h*0.2), linePaint);
  }
}

class LegPart extends BodyPart {
  final bool isLeft;
  LegPart({required super.measurements, required this.isLeft});

  @override
  void render(Canvas canvas) {
    final w = measurements.thighWidth;
    final l = measurements.legLength;
    final kneeY = measurements.thighLength;
    final ankleY = l;
    final isFemale = measurements.gender == 'female';
    final muscle = measurements.muscleFactor;
    final fat = measurements.fatFactor;
    
    final path = Path();
    
    // Start at top center
    path.moveTo(0, 0);
    
    // Outer Thigh
    double thighBulge = 0.0;
    if (fat > 10.0) thighBulge += w * 0.15; // 비만형 허벅지
    if (muscle > 5.0) thighBulge += w * 0.1; // 근육형 대퇴사두
    
    path.cubicTo(
      w * (isFemale ? 0.65 : 0.6) + thighBulge, l * 0.1, 
      w * (isFemale ? 0.6 : 0.55) + thighBulge, l * 0.3, 
      w * 0.4, kneeY // Knee outer
    );
    
    // Outer Calf
    double calfBulge = 0.0;
    if (muscle > 5.0) calfBulge += w * 0.15; // 비복근
    
    path.cubicTo(
      w * (isFemale ? 0.5 : 0.45) + calfBulge, l * 0.6, 
      w * (isFemale ? 0.45 : 0.4) + calfBulge * 0.8, l * 0.2, // Fixed: ankleY is used later
      w * 0.2, ankleY // Ankle outer
    );
    
    // Foot connection
    path.lineTo(-w * 0.2, ankleY);
    
    // Inner Calf
    path.cubicTo(
      -w * (isFemale ? 0.35 : 0.3) - calfBulge * 0.5, l * 0.8, 
      -w * (isFemale ? 0.4 : 0.35) - calfBulge * 0.8, l * 0.6, 
      -w * 0.3, kneeY // Knee inner
    );
    
    // Inner Thigh
    double innerThighBulge = 0.0;
    if (fat > 10.0) innerThighBulge += w * 0.1; // 허벅지 안쪽 살
    
    path.cubicTo(
      -w * (isFemale ? 0.45 : 0.4) - innerThighBulge, l * 0.3, 
      -w * (isFemale ? 0.45 : 0.4) - innerThighBulge, l * 0.1, 
      0, 0
    );
    
    path.close();
    
    // 그림자 및 외곽선
    renderShadow(canvas, path);
    canvas.drawPath(path, paint);
    renderOutline(canvas, path);
    
    // Knee detail (subtle shadow)
    final kneePaint = Paint()
      ..color = const Color(0x10000000)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, kneeY), width: w * 0.5, height: w * 0.3), 
      kneePaint
    );
    
    // Muscle details
    if (muscle > 5.0 && fat < 5.0) {
      final musclePaint = Paint()..color = const Color(0x10000000)..style = PaintingStyle.stroke..strokeWidth = 1.0;
      // Quadriceps separation
      canvas.drawArc(Rect.fromCenter(center: Offset(0, l*0.25), width: w*0.8, height: l*0.3), 0.2, 2.7, false, musclePaint);
    }
    
    // Foot
    final footPaint = Paint()..color = const Color(0xFF333333); // Shoes
    // Shoe shape
    final shoePath = Path();
    shoePath.moveTo(-w * 0.25, ankleY);
    shoePath.quadraticBezierTo(0, ankleY + w * 0.2, w * 0.25, ankleY); // Ankle opening
    shoePath.lineTo(w * 0.3, ankleY + w * 0.5); // Heel back
    shoePath.quadraticBezierTo(w * 0.4, ankleY + w * 0.8, 0, ankleY + w * 0.8); // Sole
    shoePath.quadraticBezierTo(-w * 0.6, ankleY + w * 0.8, -w * 0.5, ankleY + w * 0.5); // Toe
    shoePath.close();
    
    // 신발에도 그림자 적용
    renderShadow(canvas, shoePath);
    canvas.drawPath(shoePath, footPaint);
  }
}
