import 'package:flutter/material.dart';
import 'avatar_parts.dart';

/// 스포츠 브라
class SportsBraPart extends BodyPart {
  SportsBraPart({required super.measurements}) {
    paint.color = measurements.clothingColors.braColor;
  }

  @override
  void render(Canvas canvas) {
    final chest = measurements.chestWidth;
    final h = measurements.torsoHeight;
    final breastSize = measurements.breastSize;
    final isFemale = measurements.gender == 'female';
    
    if (!isFemale || breastSize <= 0) return; // 여성만
    
    final path = Path();
    
    // 스포츠 브라 상단 (가슴 위)
    final topY = -h * 0.8;
    final bottomY = -h * 0.6;
    
    // 중앙 시작
    path.moveTo(-chest * 0.15, topY);
    
    // 오른쪽 어깨 스트랩
    path.lineTo(-chest * 0.2, topY - h * 0.05);
    path.lineTo(-chest * 0.35, -h * 0.95); // 어깨로
    
    // 오른쪽 외곽
    path.lineTo(-chest * 0.45, -h * 0.85);
    path.cubicTo(
      -chest * 0.5, -h * 0.75,
      -chest * 0.48, bottomY + h * 0.05,
      -chest * 0.4, bottomY
    );
    
    // 하단
    path.lineTo(chest * 0.4, bottomY);
    
    // 왼쪽 외곽
    path.cubicTo(
      chest * 0.48, bottomY + h * 0.05,
      chest * 0.5, -h * 0.75,
      chest * 0.45, -h * 0.85
    );
    
    // 왼쪽 어깨 스트랩
    path.lineTo(chest * 0.35, -h * 0.95);
    path.lineTo(chest * 0.2, topY - h * 0.05);
    path.lineTo(chest * 0.15, topY);
    
    path.close();
    canvas.drawPath(path, paint);
    
    // 스트랩 강조
    final strapPaint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // 오른쪽 스트랩
    canvas.drawLine(
      Offset(-chest * 0.3, -h * 0.92),
      Offset(-chest * 0.42, -h * 0.82),
      strapPaint
    );
    
    // 왼쪽 스트랩
    canvas.drawLine(
      Offset(chest * 0.3, -h * 0.92),
      Offset(chest * 0.42, -h * 0.82),
      strapPaint
    );
    
    // 음영 (입체감)
    final shadowPaint = Paint()
      ..color = const Color(0x10000000)
      ..style = PaintingStyle.fill;
    
    // 가슴 아래 음영
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, bottomY + h * 0.02),
        width: chest * 0.6,
        height: h * 0.05
      ),
      shadowPaint
    );
  }
}

/// 타이즈/레깅스 (다리 형태를 정확히 따라감)
class TightsPart extends BodyPart {
  final bool isLeft;
  
  TightsPart({required super.measurements, required this.isLeft}) {
    paint.color = measurements.clothingColors.tightsColor;
  }

  @override
  void render(Canvas canvas) {
    // LegPart와 동일한 치수 사용
    final w = measurements.thighWidth;
    final l = measurements.legLength;
    final kneeY = measurements.thighLength;
    final isFemale = measurements.gender == 'female';
    
    // 타이즈 끝 위치 (무릎 위)
    final tightsEndY = kneeY * 0.85;  // 무릎보다 약간 위
    
    final path = Path();
    
    // Start at top center
    path.moveTo(0, 0);
    
    // Outer Thigh (Curved outward) - 무릎 위까지만
    path.cubicTo(
      w * (isFemale ? 0.65 : 0.6), l * 0.1, 
      w * (isFemale ? 0.6 : 0.55), l * 0.3, 
      w * 0.45, tightsEndY // 타이즈 끝 (무릎 위)
    );
    
    // 타이즈 하단 (무릎 위)
    path.lineTo(-w * 0.45, tightsEndY);
    
    // Inner Thigh - 무릎 위까지만
    path.cubicTo(
      -w * (isFemale ? 0.45 : 0.4), l * 0.3, 
      -w * (isFemale ? 0.45 : 0.4), l * 0.1, 
      0, 0
    );
    
    path.close();
    canvas.drawPath(path, paint);
    
    // 타이즈 하단 밴드 (무릎 위)
    final hemPaint = Paint()
      ..color = const Color(0x30000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(-w * 0.45, tightsEndY),
      Offset(w * 0.45, tightsEndY),
      hemPaint
    );
  }
}

/// 골반 커버 (타이즈 색상)
class PelvisCoverPart extends BodyPart {
  PelvisCoverPart({required super.measurements}) {
    paint.color = measurements.clothingColors.tightsColor;
  }

  @override
  void render(Canvas canvas) {
    final hipW = measurements.hipWidth;
    final pelvisH = measurements.torsoHeight * 0.25;
    final isFemale = measurements.gender == 'female';
    
    final path = Path();
    
    // PelvisPart와 유사하지만 약간 작게
    path.moveTo(0, 0);
    
    // Right hip
    if (isFemale) {
      path.cubicTo(
        hipW / 2 * 0.65, 0,
        hipW / 2 * 0.95, pelvisH * 0.15,
        hipW / 2 * 0.95, pelvisH * 0.7
      );
    } else {
      path.cubicTo(
        hipW / 2 * 0.75, 0,
        hipW / 2 * 0.95, pelvisH * 0.25,
        hipW / 2 * 0.95, pelvisH * 0.6
      );
    }
    
    // Right leg socket
    path.quadraticBezierTo(
      hipW / 2 * 0.85, pelvisH * 0.95,
      hipW / 4, pelvisH
    );
    
    // Crotch
    path.lineTo(-hipW / 4, pelvisH);
    
    // Left leg socket
    path.quadraticBezierTo(
      -hipW / 2 * 0.85, pelvisH * 0.95,
      -hipW / 2 * 0.95, pelvisH * (isFemale ? 0.7 : 0.6)
    );
    
    // Left hip
    if (isFemale) {
      path.cubicTo(
        -hipW / 2 * 0.95, pelvisH * 0.15,
        -hipW / 2 * 0.65, 0,
        0, 0
      );
    } else {
      path.cubicTo(
        -hipW / 2 * 0.95, pelvisH * 0.25,
        -hipW / 2 * 0.75, 0,
        0, 0
      );
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // 허리 밴드
    final bandPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(-hipW * 0.4, pelvisH * 0.05),
      Offset(hipW * 0.4, pelvisH * 0.05),
      bandPaint
    );
  }
}

/// 반바지 (선택적)
class ShortsPart extends BodyPart {
  ShortsPart({required super.measurements}) {
    paint.color = const Color(0xFF1A1A3A); // 남색
  }

  @override
  void render(Canvas canvas) {
    final hip = measurements.hipWidth;
    final thighW = measurements.thighWidth;
    final pelvisH = measurements.torsoHeight * 0.25;
    final shortsLength = measurements.thighLength * 0.35;
    
    final path = Path();
    
    path.moveTo(-hip / 2 * 0.8, 0);
    path.lineTo(hip / 4, pelvisH * 0.3);
    path.lineTo(thighW * 0.6, pelvisH + shortsLength);
    path.lineTo(thighW * 0.3, pelvisH + shortsLength * 1.1);
    path.lineTo(0, pelvisH * 1.2);
    path.lineTo(-thighW * 0.3, pelvisH + shortsLength * 1.1);
    path.lineTo(-thighW * 0.6, pelvisH + shortsLength);
    path.lineTo(-hip / 4, pelvisH * 0.3);
    path.close();
    
    canvas.drawPath(path, paint);
    
    final bandPaint = Paint()
      ..color = const Color(0xFF0D0D1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(-hip / 2 * 0.8, pelvisH * 0.05),
      Offset(hip / 2 * 0.8, pelvisH * 0.05),
      bandPaint
    );
  }
}
