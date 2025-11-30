import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class VerticalPolygonGauge extends StatefulWidget {
  final double currentCalories;
  final double dailyGoal;
  final double bmi;
  final bool isOverloaded;

  const VerticalPolygonGauge({
    super.key,
    required this.currentCalories,
    required this.dailyGoal,
    required this.bmi,
    this.isOverloaded = false,
  });

  @override
  State<VerticalPolygonGauge> createState() => _VerticalPolygonGaugeState();
}

class _VerticalPolygonGaugeState extends State<VerticalPolygonGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateParticles(Size size, double fillHeight) {
    // 파티클 생성
    if (_particles.length < 20 && _random.nextDouble() < 0.1) {
      _particles.add(Particle(
        x: _random.nextDouble() * size.width,
        y: size.height,
        speed: 1.0 + _random.nextDouble() * 2.0,
        size: 2.0 + _random.nextDouble() * 3.0,
        opacity: 0.5 + _random.nextDouble() * 0.5,
      ));
    }

    // 파티클 이동 및 제거
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].y -= _particles[i].speed;
      if (_particles[i].y < size.height - fillHeight || _particles[i].y < 0) {
        _particles.removeAt(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(30, 200), // 게이지 크기 축소 (Slim)
          painter: _GaugePainter(
            currentCalories: widget.currentCalories,
            dailyGoal: widget.dailyGoal,
            bmi: widget.bmi,
            isOverloaded: widget.isOverloaded,
            animationValue: _controller.value,
            particles: _particles,
            onUpdateParticles: _updateParticles,
          ),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class _GaugePainter extends CustomPainter {
  final double currentCalories;
  final double dailyGoal;
  final double bmi;
  final bool isOverloaded;
  final double animationValue;
  final List<Particle> particles;
  final Function(Size, double) onUpdateParticles;

  _GaugePainter({
    required this.currentCalories,
    required this.dailyGoal,
    required this.bmi,
    required this.isOverloaded,
    required this.animationValue,
    required this.particles,
    required this.onUpdateParticles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double progress = (currentCalories / dailyGoal).clamp(0.0, 1.5); // 최대 1.5배까지 표시
    final double fillHeight = size.height * (progress > 1.0 ? 1.0 : progress);

    // 1. 테마 색상 결정 (BMI 기반)
    Color baseColor;
    Color glowColor;
    
    if (isOverloaded) {
      baseColor = const Color(0xFFE53935); // Red (Danger)
      glowColor = const Color(0xFFFFEBEE);
    } else if (bmi < 18.5) {
      baseColor = const Color(0xFFFFB300); // Amber/Gold (Underweight - Energy)
      glowColor = const Color(0xFFFFF8E1);
    } else if (bmi >= 23) {
      baseColor = const Color(0xFF43A047); // Green (Overweight - Healing/Control)
      glowColor = const Color(0xFFE8F5E9);
    } else {
      baseColor = const Color(0xFF00ACC1); // Cyan (Normal - Balance)
      glowColor = const Color(0xFFE0F7FA);
    }

    // 2. 배경 기둥 (육각형) 그리기
    final Path bgPath = _createHexagonPath(size, 0);
    final Paint bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bgPath, bgPaint);

    // 테두리
    final Paint borderPaint = Paint()
      ..color = baseColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(bgPath, borderPaint);

    // 3. 채움 효과 (Filling)
    canvas.save();
    
    // 과부하 시 진동 효과 (Shake)
    if (isOverloaded) {
      final double shake = sin(animationValue * pi * 10) * 2;
      canvas.translate(shake, 0);
    }

    // 클리핑을 위한 경로 생성
    final Path fillPath = _createHexagonPath(size, 0);
    canvas.clipPath(fillPath);

    // 그라데이션 채움
    final Rect rect = Rect.fromLTWH(0, size.height - fillHeight, size.width, fillHeight);
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          baseColor.withOpacity(0.8),
          baseColor.withOpacity(0.4),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, fillPaint);

    // 4. 파티클 효과
    onUpdateParticles(size, fillHeight);
    final Paint particlePaint = Paint()..color = Colors.white;
    
    for (var particle in particles) {
      // 채워진 영역 내에 있는 파티클만 그림
      if (particle.y >= size.height - fillHeight) {
        particlePaint.color = Colors.white.withOpacity(particle.opacity);
        canvas.drawCircle(Offset(particle.x, particle.y), particle.size, particlePaint);
      }
    }

    canvas.restore();

    // 5. 과부하 시 가시 효과 (Spikes)
    if (isOverloaded) {
      final Path spikePath = Path();
      final double spikeHeight = size.height * 0.8; // 상단부 위주로
      
      // 랜덤하게 튀어나오는 가시
      if (animationValue % 0.2 < 0.1) {
         spikePath.moveTo(0, spikeHeight);
         spikePath.lineTo(-10, spikeHeight + 10);
         spikePath.lineTo(0, spikeHeight + 20);
         
         spikePath.moveTo(size.width, spikeHeight - 30);
         spikePath.lineTo(size.width + 15, spikeHeight - 20);
         spikePath.lineTo(size.width, spikeHeight - 10);
      }
      
      final Paint spikePaint = Paint()
        ..color = baseColor
        ..style = PaintingStyle.fill;
        
      canvas.drawPath(spikePath, spikePaint);
    }
  }

  Path _createHexagonPath(Size size, double padding) {
    final double w = size.width - padding * 2;
    final double h = size.height - padding * 2;
    final double x = padding;
    final double y = padding;
    
    final Path path = Path();
    // 육각형 포인트 계산 (위아래가 뾰족한 형태가 아닌, 위아래가 평평하고 옆이 긴 형태 - 기둥 느낌)
    // 여기서는 위아래가 뾰족한 형태보다는 직사각형에 가까운 육각형(모서리가 깎인)을 사용
    
    final double cornerSize = w * 0.2; // 모서리 깎임 정도

    path.moveTo(x + cornerSize, y);
    path.lineTo(x + w - cornerSize, y);
    path.lineTo(x + w, y + cornerSize); // 우상단
    path.lineTo(x + w, y + h - cornerSize);
    path.lineTo(x + w - cornerSize, y + h); // 우하단
    path.lineTo(x + cornerSize, y + h);
    path.lineTo(x, y + h - cornerSize); // 좌하단
    path.lineTo(x, y + cornerSize); // 좌상단
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.currentCalories != currentCalories ||
           oldDelegate.dailyGoal != dailyGoal || // 목표 변경 감지
           oldDelegate.bmi != bmi || // BMI 변경 감지 (색상 변경의 핵심)
           oldDelegate.animationValue != animationValue ||
           oldDelegate.isOverloaded != isOverloaded;
  }
}
