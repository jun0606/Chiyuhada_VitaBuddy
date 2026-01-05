import 'package:flutter/material.dart';
import 'package:chiyuhada_vita_buddy/models/workout_data.dart';
import 'package:chiyuhada_vita_buddy/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:chiyuhada_vita_buddy/providers/app_provider.dart';
import 'package:chiyuhada_vita_buddy/l10n/app_localizations.dart';

/// 운동 수동 입력 다이얼로그
class ExerciseInputDialog extends StatefulWidget {
  const ExerciseInputDialog({super.key});

  @override
  State<ExerciseInputDialog> createState() => _ExerciseInputDialogState();
}

class _ExerciseInputDialogState extends State<ExerciseInputDialog> {
  WorkoutType _selectedType = WorkoutType.walking;
  int _duration = 30; // 기본값: 30분
  double _intensity = 1.0; // 기본값: 보통
  double? _calculatedCalories;

  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _calculateCalories();
  }

  /// MET 기반 칼로리 계산
  void _calculateCalories() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final weight = appProvider.weight;

    if (weight > 0) {
      setState(() {
        _calculatedCalories = WorkoutData.calculateCalories(
          type: _selectedType,
          durationMinutes: _duration,
          weightKg: weight,
          intensity: _intensity,
        );
      });
    }
  }

  /// 운동 저장
  Future<void> _saveExercise() async {
    final l10n = AppLocalizations.of(context)!;

    if (_calculatedCalories == null || _calculatedCalories! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.calorieCalcError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // 데이터베이스에 저장
      await _dbService.addExerciseRecord(
        _selectedType.name,
        _duration,
        _calculatedCalories!,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // 성공 시 true 반환

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.workoutSaved(_getTypeName(context, _selectedType)),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.saveError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.exerciseRecord),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 운동 종류 선택
            Text(
              l10n.workoutTypeLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<WorkoutType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: WorkoutType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      _getTypeIcon(type),
                      const SizedBox(width: 8),
                      Text(_getTypeName(context, type)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                  _calculateCalories();
                }
              },
            ),

            const SizedBox(height: 16),

            // 운동 시간
            Text(
              l10n.durationLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _duration.toDouble(),
                    min: 5,
                    max: 180,
                    divisions: 35,
                    label: '$_duration${l10n.minutesUnit}',
                    onChanged: (value) {
                      setState(() {
                        _duration = value.toInt();
                      });
                      _calculateCalories();
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '$_duration${l10n.minutesUnit}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 강도 선택
            Text(
              l10n.intensityLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<double>(
              segments: [
                ButtonSegment(value: 0.8, label: Text(l10n.intensityLow)),
                ButtonSegment(value: 1.0, label: Text(l10n.intensityMedium)),
                ButtonSegment(value: 1.2, label: Text(l10n.intensityHigh)),
              ],
              selected: {_intensity},
              onSelectionChanged: (Set<double> newSelection) {
                setState(() {
                  _intensity = newSelection.first;
                });
                _calculateCalories();
              },
            ),

            const SizedBox(height: 16),

            // 예상 칼로리
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.calcCaloriesLabel),
                  Text(
                    '${_calculatedCalories?.toInt() ?? 0} ${l10n.caloriesUnit}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _saveExercise,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB74D),
          ),
          child: Text(l10n.save),
        ),
      ],
    );
  }

  /// 운동 종류별 아이콘
  Icon _getTypeIcon(WorkoutType type) {
    IconData icon;
    Color color;

    switch (type) {
      case WorkoutType.walking:
        icon = Icons.directions_walk;
        color = Colors.green;
        break;
      case WorkoutType.running:
        icon = Icons.directions_run;
        color = Colors.red;
        break;
      case WorkoutType.cycling:
        icon = Icons.directions_bike;
        color = Colors.blue;
        break;
      case WorkoutType.swimming:
        icon = Icons.pool;
        color = Colors.cyan;
        break;
      case WorkoutType.weightTraining:
        icon = Icons.fitness_center;
        color = Colors.orange;
        break;
      case WorkoutType.yoga:
        icon = Icons.self_improvement;
        color = Colors.purple;
        break;
      case WorkoutType.dancing:
        icon = Icons.music_note;
        color = Colors.pink;
        break;
      case WorkoutType.hiking:
        icon = Icons.terrain;
        color = Colors.brown;
        break;
      case WorkoutType.tennis:
        icon = Icons.sports_tennis;
        color = Colors.yellow[700]!;
        break;
      case WorkoutType.basketball:
        icon = Icons.sports_basketball;
        color = Colors.deepOrange;
        break;
      case WorkoutType.soccer:
        icon = Icons.sports_soccer;
        color = Colors.green[700]!;
        break;
      case WorkoutType.aerobics:
        icon = Icons.accessibility_new;
        color = Colors.teal;
        break;
      case WorkoutType.badminton:
        icon = Icons.sports_baseball;
        color = Colors.indigo;
        break;
      case WorkoutType.baseball:
        icon = Icons.sports_baseball;
        color = Colors.amber;
        break;
      case WorkoutType.boxing:
        icon = Icons.sports_mma;
        color = Colors.red[800]!;
        break;
      case WorkoutType.golf:
        icon = Icons.golf_course;
        color = Colors.green[600]!;
        break;
      case WorkoutType.pilates:
        icon = Icons.accessibility;
        color = Colors.pink[300]!;
        break;
      case WorkoutType.tableTennis:
        icon = Icons.table_chart;
        color = Colors.blue[800]!;
        break;
      case WorkoutType.volleyball:
        icon = Icons.sports_volleyball;
        color = Colors.orange[600]!;
        break;
      case WorkoutType.elliptical:
        icon = Icons.fitness_center;
        color = Colors.purple[400]!;
        break;
      case WorkoutType.rowing:
        icon = Icons.rowing;
        color = Colors.teal[700]!;
        break;
      case WorkoutType.stairClimbing:
        icon = Icons.stairs;
        color = Colors.grey[700]!;
        break;
      case WorkoutType.other:
        icon = Icons.sports;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 24);
  }

  /// 운동 종류 한글 이름
  String _getTypeName(BuildContext context, WorkoutType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case WorkoutType.walking:
        return l10n.walkingActivity;
      case WorkoutType.running:
        return l10n.runningActivity;
      case WorkoutType.cycling:
        return l10n.cyclingActivity;
      case WorkoutType.swimming:
        return l10n.swimmingActivity;
      case WorkoutType.weightTraining:
        return l10n.weightTrainingActivity;
      case WorkoutType.yoga:
        return l10n.yogaActivity;
      case WorkoutType.dancing:
        return l10n.dancingActivity;
      case WorkoutType.hiking:
        return l10n.hikingActivity;
      case WorkoutType.tennis:
        return l10n.tennisActivity;
      case WorkoutType.basketball:
        return l10n.basketballActivity;
      case WorkoutType.soccer:
        return l10n.soccerActivity;
      case WorkoutType.aerobics:
        return l10n.aerobicsActivity;
      case WorkoutType.badminton:
        return l10n.badmintonActivity;
      case WorkoutType.baseball:
        return l10n.baseballActivity;
      case WorkoutType.boxing:
        return l10n.boxingActivity;
      case WorkoutType.golf:
        return l10n.golfActivity;
      case WorkoutType.pilates:
        return l10n.pilatesActivity;
      case WorkoutType.tableTennis:
        return l10n.tableTennisActivity;
      case WorkoutType.volleyball:
        return l10n.volleyballActivity;
      case WorkoutType.elliptical:
        return l10n.ellipticalActivity;
      case WorkoutType.rowing:
        return l10n.rowingActivity;
      case WorkoutType.stairClimbing:
        return l10n.stairClimbingActivity;
      case WorkoutType.other:
        return l10n.otherActivity;
    }
  }
}
