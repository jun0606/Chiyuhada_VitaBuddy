import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CalorieIndicator extends StatelessWidget {
  final double currentCalories;
  final double dailyGoal;
  final double progress;

  const CalorieIndicator({
    super.key,
    required this.currentCalories,
    required this.dailyGoal,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final isOverLimit = currentCalories > dailyGoal;

    Color progressColor;
    if (isOverLimit) {
      progressColor = Colors.red;
    } else if (clampedProgress > 0.8) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return Column(
      children: [
        // 칼로리 텍스트
        Text(
          '${currentCalories.toInt()} / ${dailyGoal.toInt()} kcal',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // 진행률 바
        LinearPercentIndicator(
          percent: clampedProgress,
          lineHeight: 20.0,
          backgroundColor: Colors.grey.shade300,
          progressColor: progressColor,
          barRadius: const Radius.circular(10),
          center: Text(
            '${(clampedProgress * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 상태 메시지
        Text(
          _getStatusMessage(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: progressColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getStatusMessage() {
    if (currentCalories > dailyGoal) {
      final overAmount = (currentCalories - dailyGoal).toInt();
      return '권장량 초과: ${overAmount}kcal';
    } else {
      final remaining = (dailyGoal - currentCalories).toInt();
      return '남은 칼로리: ${remaining}kcal';
    }
  }
}
