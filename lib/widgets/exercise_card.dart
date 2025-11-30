import 'package:flutter/material.dart';

/// 운동 기록 카드 위젯
class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final exerciseName = exercise['exercise_name'] ?? '운동';
    final durationMinutes = exercise['duration_minutes'] ?? 0;
    final caloriesBurned = (exercise['calories_burned'] ?? 0.0).toDouble();
    final source = exercise['source'] ?? 'manual';
    final time = exercise['time'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: _buildExerciseIcon(exerciseName),
        title: Text(
          _getDisplayName(exerciseName),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('$durationMinutes분 • ${caloriesBurned.toInt()} kcal'),
            const SizedBox(height: 4),
            _buildSourceBadge(source),
          ],
        ),
        trailing: time.isNotEmpty
            ? Text(
                _formatTime(time),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              )
            : null,
      ),
    );
  }

  /// 운동 종류별 아이콘
  Widget _buildExerciseIcon(String exerciseName) {
    IconData icon;
    Color color;

    switch (exerciseName.toLowerCase()) {
      case 'walking':
        icon = Icons.directions_walk;
        color = Colors.green;
        break;
      case 'running':
        icon = Icons.directions_run;
        color = Colors.red;
        break;
      case 'cycling':
        icon = Icons.directions_bike;
        color = Colors.blue;
        break;
      case 'swimming':
        icon = Icons.pool;
        color = Colors.cyan;
        break;
      case 'weighttraining':
        icon = Icons.fitness_center;
        color = Colors.orange;
        break;
      case 'yoga':
        icon = Icons.self_improvement;
        color = Colors.purple;
        break;
      case 'dancing':
        icon = Icons.music_note;
        color = Colors.pink;
        break;
      case 'hiking':
        icon = Icons.terrain;
        color = Colors.brown;
        break;
      case 'tennis':
        icon = Icons.sports_tennis;
        color = Colors.yellow[700]!;
        break;
      case 'basketball':
        icon = Icons.sports_basketball;
        color = Colors.deepOrange;
        break;
      case 'soccer':
        icon = Icons.sports_soccer;
        color = Colors.green[700]!;
        break;
      default:
        icon = Icons.sports;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    );
  }

  /// 출처 뱃지
  Widget _buildSourceBadge(String source) {
    String label;
    IconData icon;
    Color color;

    switch (source.toLowerCase()) {
      case 'healthconnect':
        label = 'Health Connect';
        icon = Icons.phone_android;
        color = Colors.green;
        break;
      case 'healthkit':
        label = 'HealthKit';
        icon = Icons.apple;
        color = Colors.blue;
        break;
      default:
        label = '수동 입력';
        icon = Icons.edit;
        color = Colors.orange;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 운동 이름 한글화
  String _getDisplayName(String exerciseName) {
    switch (exerciseName.toLowerCase()) {
      case 'walking':
        return '걷기';
      case 'running':
        return '달리기';
      case 'cycling':
        return '자전거';
      case 'swimming':
        return '수영';
      case 'weighttraining':
        return '근력 운동';
      case 'yoga':
        return '요가';
      case 'dancing':
        return '댄스';
      case 'hiking':
        return '등산';
      case 'tennis':
        return '테니스';
      case 'basketball':
        return '농구';
      case 'soccer':
        return '축구';
      default:
        return exerciseName;
    }
  }

  /// 시간 포맷 (HH:MM)
  String _formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}

/// 빈 상태 UI
class EmptyExerciseState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;

  const EmptyExerciseState({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.directions_run,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
