import 'package:flutter/material.dart';

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
    final meals = (pattern['meals'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    
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
      'snacks': _includeSnacks ? [
        {'type': 'morning', 'enabled': false, 'hour': 10, 'minute': 30},
        {'type': 'afternoon', 'enabled': false, 'hour': 15, 'minute': 30},
      ] : [],
    };
  }

  void _saveMealPattern() {
    final pattern = _buildMealPattern();
    Navigator.pop(context, pattern);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식사 패턴 설정'),
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
                    const Text(
                      '하루 식사 패턴을 알려주세요',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '맞춤형 알림을 위해 식사 시간을 설정해주세요',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    
                    // 프리셋 선택
                    _buildPresetSelector(),
                    const SizedBox(height: 24),
                    
                    // 식사 목록
                    const Text(
                      '식사 시간',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        label: const Text('식사 추가'),
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
                child: Text(widget.isOnboarding ? '다음' : '저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPresetChip('2식', '2meals'),
        _buildPresetChip('3식 (권장)', '3meals'),
        _buildPresetChip('4식+', '4meals'),
        _buildPresetChip('커스텀', 'custom'),
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
    final timeString = '${meal['hour'].toString().padLeft(2, '0')}:${meal['minute'].toString().padLeft(2, '0')}';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.restaurant),
        title: TextField(
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: '식사 이름',
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
    return SwitchListTile(
      title: const Text('간식 알림'),
      subtitle: const Text('오전/오후 간식 시간 알림을 받을 수 있어요'),
      value: _includeSnacks,
      onChanged: (value) {
        setState(() {
          _includeSnacks = value;
        });
      },
    );
  }
}
