import 'package:flutter/material.dart';
import 'package:chiyuhada_vita_buddy/models/workout_data.dart';
import 'package:chiyuhada_vita_buddy/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:chiyuhada_vita_buddy/providers/app_provider.dart';

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
    if (_calculatedCalories == null || _calculatedCalories! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('칼로리 계산 오류가 발생했습니다'),
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
            content: Text('${_getTypeName(_selectedType)} 운동이 기록되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('운동 기록'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 운동 종류 선택
            const Text('운동 종류', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<WorkoutType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: WorkoutType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      _getTypeIcon(type),
                      const SizedBox(width: 8),
                      Text(_getTypeName(type)),
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
            const Text('운동 시간 (분)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _duration.toDouble(),
                    min: 5,
                    max: 180,
                    divisions: 35,
                    label: '$_duration분',
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
                    '$_duration분',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 강도 선택
            const Text('운동 강도', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 0.8, label: Text('낮음')),
                ButtonSegment(value: 1.0, label: Text('보통')),
                ButtonSegment(value: 1.2, label: Text('높음')),
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
                  const Text('예상 칼로리 소모량'),
                  Text(
                    '${_calculatedCalories?.toInt() ?? 0} kcal',
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
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveExercise,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB74D),
          ),
          child: const Text('저장'),
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
      case WorkoutType.other:
        icon = Icons.sports;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 24);
  }

  /// 운동 종류 한글 이름
  String _getTypeName(WorkoutType type) {
    switch (type) {
      case WorkoutType.walking:
        return '걷기';
      case WorkoutType.running:
        return '달리기';
      case WorkoutType.cycling:
        return '자전거';
      case WorkoutType.swimming:
        return '수영';
      case WorkoutType.weightTraining:
        return '근력 운동';
      case WorkoutType.yoga:
        return '요가';
      case WorkoutType.dancing:
        return '댄스';
      case WorkoutType.hiking:
        return '등산';
      case WorkoutType.tennis:
        return '테니스';
      case WorkoutType.basketball:
        return '농구';
      case WorkoutType.soccer:
        return '축구';
      case WorkoutType.other:
        return '기타 운동';
    }
  }
}
