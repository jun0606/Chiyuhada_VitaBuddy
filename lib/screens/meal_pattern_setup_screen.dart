import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// 식사 패턴 설정 화면
///
/// 사용자의 하루 식사 패턴(횟수, 시간)을 설정합니다.
/// 온보딩 및 기존 사용자 모두 사용 가능합니다.
class MealPatternSetupScreen extends StatefulWidget {
  final Map<String, dynamic>? initialPattern;
  final bool isOnboarding;

  const MealPatternSetupScreen({
    super.key,
    this.initialPattern,
    this.isOnboarding = false,
  });

  @override
  State<MealPatternSetupScreen> createState() => _MealPatternSetupScreenState();
}

class _MealPatternSetupScreenState extends State<MealPatternSetupScreen> {
  String _selectedPreset = '3meals'; // '2meals', '3meals', '4meals', 'custom'
  List<Map<String, dynamic>> _meals = [];
  bool _includeSnacks = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialPattern != null) {
      // 기존 패턴 로드
      _loadExistingPattern();
    } else {
      // 기본 3식 패턴
      _applyPreset('3meals');
    }
  }

  void _loadExistingPattern() {
    final pattern = widget.initialPattern!;
    final meals =
        (pattern['meals'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    setState(() {
      _meals = List.from(meals);
      _includeSnacks = (pattern['snacks'] as List?)?.isNotEmpty ?? false;

      // 프리셋 감지
      if (meals.length == 2) {
        _selectedPreset = '2meals';
      } else if (meals.length == 3) {
        _selectedPreset = '3meals';
      } else if (meals.length >= 4) {
        _selectedPreset = '4meals';
      } else {
        _selectedPreset = 'custom';
      }
    });
  }

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;

      switch (preset) {
        case '2meals':
          _meals = [
            {'name': '점심', 'enabled': true, 'hour': 12, 'minute': 0},
            {'name': '저녁', 'enabled': true, 'hour': 18, 'minute': 0},
          ];
          break;
        case '3meals':
          _meals = [
            {'name': '아침', 'enabled': true, 'hour': 7, 'minute': 0},
            {'name': '점심', 'enabled': true, 'hour': 12, 'minute': 0},
            {'name': '저녁', 'enabled': true, 'hour': 18, 'minute': 0},
          ];
          break;
        case '4meals':
          _meals = [
            {'name': '아침', 'enabled': true, 'hour': 7, 'minute': 0},
            {'name': '오전 간식', 'enabled': true, 'hour': 10, 'minute': 30},
            {'name': '점심', 'enabled': true, 'hour': 12, 'minute': 0},
            {'name': '저녁', 'enabled': true, 'hour': 18, 'minute': 0},
          ];
          break;
        case 'custom':
          if (_meals.isEmpty) {
            _meals = [
              {'name': '식사 1', 'enabled': true, 'hour': 12, 'minute': 0},
            ];
          }
          break;
      }
    });
  }

  void _addMeal() {
    setState(() {
      _meals.add({
        'name': '식사 ${_meals.length + 1}',
        'enabled': true,
        'hour': 12,
        'minute': 0,
      });
    });
  }

  void _removeMeal(int index) {
    setState(() {
      _meals.removeAt(index);
    });
  }

  Future<void> _selectTime(int index) async {
    final meal = _meals[index];
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: meal['hour'], minute: meal['minute']),
    );

    if (picked != null) {
      setState(() {
        _meals[index]['hour'] = picked.hour;
        _meals[index]['minute'] = picked.minute;
      });
    }
  }

  void _updateMealName(int index, String newName) {
    setState(() {
      _meals[index]['name'] = newName;
    });
  }

  Map<String, dynamic> _buildMealPattern() {
    return {
      'mealsPerDay': _meals.length,
      'meals': _meals,
      'snacks': _includeSnacks
          ? [
              {'type': 'morning', 'enabled': false, 'hour': 10, 'minute': 30},
              {'type': 'afternoon', 'enabled': false, 'hour': 15, 'minute': 30},
            ]
          : [],
    };
  }

  void _saveMealPattern() {
    final pattern = _buildMealPattern();
    Navigator.pop(context, pattern);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mealPatternSetup),
        automaticallyImplyLeading: !widget.isOnboarding,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.mealPatternTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.mealPatternSubtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // 프리셋 선택
                    _buildPresetSelector(),
                    const SizedBox(height: 24),

                    // 식사 목록
                    Text(
                      l10n.mealTimes,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._meals.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final meal = entry.value;
                      return _buildMealTile(index, meal);
                    }),

                    // 커스텀 모드에서 식사 추가 버튼
                    if (_selectedPreset == 'custom') ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _addMeal,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addMeal),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // 간식 옵션
                    _buildSnackOption(),
                  ],
                ),
              ),
            ),

            // 저장 버튼
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _meals.isNotEmpty ? _saveMealPattern : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(widget.isOnboarding ? l10n.next : l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPresetChip(l10n.meals2Preset, '2meals'),
        _buildPresetChip(l10n.meals3Preset, '3meals'),
        _buildPresetChip(l10n.meals4Preset, '4meals'),
        _buildPresetChip(l10n.customPreset, 'custom'),
      ],
    );
  }

  Widget _buildPresetChip(String label, String value) {
    final isSelected = _selectedPreset == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _applyPreset(value);
        }
      },
    );
  }

  Widget _buildMealTile(int index, Map<String, dynamic> meal) {
    final l10n = AppLocalizations.of(context)!;
    final timeString =
        '${meal['hour'].toString().padLeft(2, '0')}:${meal['minute'].toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.restaurant),
        title: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: l10n.mealNameHint,
          ),
          controller: TextEditingController(text: meal['name']),
          onChanged: (value) => _updateMealName(index, value),
        ),
        subtitle: Text(timeString),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () => _selectTime(index),
            ),
            if (_selectedPreset == 'custom' && _meals.length > 1)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeMeal(index),
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnackOption() {
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      title: Text(l10n.snackNotifications),
      subtitle: Text(l10n.snackNotificationsDesc),
      value: _includeSnacks,
      onChanged: (value) {
        setState(() {
          _includeSnacks = value;
        });
      },
    );
  }
}
