import 'dart:math';
import 'package:flutter/material.dart';
import '../models/calorie_status.dart';

/// 고도화된 칼로리 게이지 위젯
/// 
/// 7단계 색상 그라데이션과 애니메이션이 적용된 칼로리 게이지
class EnhancedCalorieGauge extends StatelessWidget {
  final double current;
  final double goal;
  final double burned;      // 운동 소모
  final double tdeeBurned;  // TDEE 소모 (시간 기반)
  final bool showLabel;
  final double height;

  const EnhancedCalorieGauge({
    super.key,
    required this.current,
    required this.goal,
    this.burned = 0.0,
    this.tdeeBurned = 0.0,
    this.showLabel = true,
    this.height = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    // 섭취 중심 계산 (일관성)
    final totalBurned = burned + tdeeBurned;
    final netCalories = current - totalBurned;  // 순 칼로리 (체중 영향)
    final remaining = goal - current + totalBurned;  // 잔여 여유
    
    // 상태 판단: 섭취 칼로리 기준 (색상은 여전히 섭취량 기준으로 위험도 표시가 안전함, 혹은 순칼로리 기준?)
    // 사용자 피드백: "순칼로리 값은 동기화되어야 한다" -> 상태도 순칼로리 기준이 맞음
    final status = getCalorieStatus(max(0, netCalories), goal);
    
    // 바 길이: 순 칼로리 / 목표 (음수면 0)
    final netPercentage = max(0.0, netCalories / goal);
    final displayNetPercentage = min(netPercentage, 2.0); 
    
    // 총 섭취량 비율 (배경에 흐릿하게 표시하여 '먹은 양' 인지)
    final intakePercentage = current / goal;
    final displayIntakePercentage = min(intakePercentage, 2.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상태 라벨
        if (showLabel) ...[
          Row(
            children: [
              Icon(status.icon, color: status.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status.message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: status.color,
                  ),
                ),
              ),
              // 운동 소모 표시
              if (burned > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 12, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        '-${burned.toInt()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        
        // 게이지 바
        Tooltip(
          message: '''섭취: ${current.toInt()} kcal
━━━━━━━━━━━━
운동: -${burned.toInt()} kcal
TDEE: -${tdeeBurned.toInt()} kcal
소모 합계: -${totalBurned.toInt()} kcal
━━━━━━━━━━━━
${netCalories >= 0 ? '현재 칼로리' : '현재 칼로리'}: ${netCalories.toInt()} kcal
남은 여유: ${remaining.toInt()} kcal''',
          triggerMode: TooltipTriggerMode.tap,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height / 2 - 2),
              child: Stack(
                children: [
                  // 배경 그라데이션
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.shade200,
                          Colors.grey.shade100,
                        ],
                      ),
                    ),
                  ),
                  
                  // 1. 총 섭취량 바 (흐릿하게 배경으로 표시 - 먹은 양 인지용)
                  if (displayIntakePercentage > 0)
                    FractionallySizedBox(
                      widthFactor: min(displayIntakePercentage, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3), // 흐릿한 회색
                          borderRadius: BorderRadius.circular(height / 2),
                        ),
                      ),
                    ),
                  
                  // 2. 순 칼로리 바 (메인 - 실제 체중 영향)
                  if (displayNetPercentage > 0)
                    FractionallySizedBox(
                      widthFactor: min(displayNetPercentage, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getGradientColors(status),
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: status.color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // 3. 중심 텍스트 (현재 칼로리 / 목표)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${netCalories.toInt()} / ${goal.toInt()}', // 현재 칼로리 표시
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: displayNetPercentage > 0.5 ? Colors.white : Colors.black87,
                            shadows: displayNetPercentage > 0.5
                                ? [
                                    const Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black26,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(현재 칼로리)',
                          style: TextStyle(
                            fontSize: 10,
                            color: displayNetPercentage > 0.5 ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 상태별 그라데이션 색상 목록
  List<Color> _getGradientColors(CalorieStatus status) {
    final baseColor = status.color;
    return [
      baseColor.withOpacity(0.7),
      baseColor,
      baseColor.withOpacity(0.9),
    ];
  }
}

/// 애니메이션이 적용된 칼로리 게이지
class AnimatedCalorieGauge extends StatefulWidget {
  final double current;
  final double goal;
  final double burned;      // 운동 소모
  final double tdeeBurned;  // TDEE 소모
  final bool showLabel;
  final double height;
  final Duration duration;

  const AnimatedCalorieGauge({
    super.key,
    required this.current,
    required this.goal,
    this.burned = 0.0,
    this.tdeeBurned = 0.0,
    this.showLabel = true,
    this.height = 30.0,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCalorieGauge> createState() => _AnimatedCalorieGaugeState();
}

class _AnimatedCalorieGaugeState extends State<AnimatedCalorieGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _burnedAnimation; // 소모 칼로리 애니메이션
  double _previousValue = 0.0;
  double _previousBurnedValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.current,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _burnedAnimation = Tween<double>(
      begin: 0.0,
      end: widget.burned,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCalorieGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.current != widget.current || oldWidget.burned != widget.burned) {
      _previousValue = _animation.value;
      _previousBurnedValue = _burnedAnimation.value;
      
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.current,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      
      _burnedAnimation = Tween<double>(
        begin: _previousBurnedValue,
        end: widget.burned,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller, // 컨트롤러 전체 감지
      builder: (context, child) {
        return EnhancedCalorieGauge(
          current: _animation.value,
          burned: _burnedAnimation.value,
          tdeeBurned: widget.tdeeBurned, // TDEE는 애니메이션 없이 그대로 전달
          goal: widget.goal,
          showLabel: widget.showLabel,
          height: widget.height,
        );
      },
    );
  }
}
