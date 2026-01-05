import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// 운동 기록 카드 위젯
class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exerciseName = exercise['exercise_type'] ?? exercise['exercise_name'] ?? '운동';
    final customName = exercise['custom_name'];
    final durationMinutes = exercise['duration_minutes'] ?? 0;
    final caloriesBurned = (exercise['calories_burned'] ?? 0.0).toDouble();
    final source = exercise['source'] ?? 'manual';
    final packageName = exercise['package_name'];
    final time = exercise['time'] ?? '';

    // 동적 이름 우선 순위: custom_name > 번역된 exercise_type
    final displayTitle = (customName != null && customName.toString().isNotEmpty)
        ? customName.toString()
        : _getDisplayName(context, exerciseName.toString());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: _buildExerciseIcon(exerciseName),
        title: Text(
          displayTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '$durationMinutes${l10n.minutesUnit} • ${caloriesBurned.toInt()} ${l10n.caloriesUnit}',
            ),
            const SizedBox(height: 4),
            _buildSourceBadge(context, source, packageName),
          ],
        ),
        trailing: time.isNotEmpty
            ? Text(
                _formatTime(time),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
      backgroundColor: color.withAlpha(51), // 0.2 opacity
      child: Icon(icon, color: color),
    );
  }

  /// 출처 뱃지
  Widget _buildSourceBadge(BuildContext context, String source, [String? packageName]) {
    String label;
    IconData icon;
    Color color;
    final l10n = AppLocalizations.of(context)!;

    switch (source.toLowerCase()) {
      case 'healthconnect':
        label = l10n.sourceHealthConnect;
        icon = Icons.phone_android;
        color = Colors.green;
        break;
      case 'healthkit':
        label = l10n.sourceHealthKit;
        icon = Icons.apple;
        color = Colors.blue;
        break;
      default:
        label = l10n.sourceManual;
        icon = Icons.edit;
        color = Colors.orange;
    }

    // 패키지 명에서 앱 명칭 추출 시도 (예: com.sec.android.app.shealth -> Samsung Health)
    if (packageName != null && packageName.isNotEmpty && source.toLowerCase() == 'healthconnect') {
      if (packageName.contains('shealth')) {
        label = 'Samsung Health';
      } else if (packageName.contains('fitness')) {
        label = 'Google Fit';
      } else if (packageName.contains('strava')) {
        label = 'Strava';
      } else if (packageName.contains('garmin')) {
        label = 'Garmin';
      } else {
        // 패키지 명의 마지막 부분을 대문자로 표시
        label = packageName.split('.').last;
        label = label[0].toUpperCase() + label.substring(1);
      }
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

  /// 운동 이름 한글화 (이제 다국어 지원)
  String _getDisplayName(BuildContext context, String exerciseName) {
    final l10n = AppLocalizations.of(context)!;
    switch (exerciseName.toLowerCase()) {
      case 'walking':
        return l10n.walkingActivity;
      case 'running':
        return l10n.runningActivity;
      case 'cycling':
        return l10n.cyclingActivity;
      case 'swimming':
        return l10n.swimmingActivity;
      case 'weighttraining':
        return l10n.weightTrainingActivity;
      case 'yoga':
        return l10n.yogaActivity;
      case 'dancing':
        return l10n.dancingActivity;
      case 'hiking':
        return l10n.hikingActivity;
      case 'tennis':
        return l10n.tennisActivity;
      case 'basketball':
        return l10n.basketballActivity;
      case 'soccer':
        return l10n.soccerActivity;
      default:
        return l10n.otherActivity;
    }
  }

  /// 시간 포맷 (HH:MM)
  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    
    try {
      if (timeStr.contains('T')) {
        final dateTime = DateTime.parse(timeStr);
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
      // 이미 HH:mm 형식인 경우 (예: "14:30")
      return timeStr;
    } catch (e) {
      return timeStr;
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
            Icon(icon, size: 80, color: Colors.grey[300]),
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
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
