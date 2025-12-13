import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/health_data_service.dart';
import '../models/user_profile.dart';
import '../models/body_types.dart';
import '../models/body_composition.dart';
import 'home_screen.dart';

/// 고급 프로필 설정 화면 (7단계)
///
/// Step 1: 기본 정보
/// Step 2: 식사 패턴
/// Step 3: 체질 선택
/// Step 4: 체형 선택
/// Step 5: 상세 정보
/// Step 6: 성격 테스트
/// Step 7: 헬스 데이터 권한
class EnhancedProfileSetupScreen extends StatefulWidget {
  const EnhancedProfileSetupScreen({super.key});

  @override
  State<EnhancedProfileSetupScreen> createState() =>
      _EnhancedProfileSetupScreenState();
}

class _EnhancedProfileSetupScreenState
    extends State<EnhancedProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;

  // Step 1: 기본 정보
  final _nameController = TextEditingController();
  double _height = 170.0;
  double _weight = 60.0;
  String _gender = 'female';
  int _age = 30;
  String _activityLevel = 'moderate';

  // Step 2: 식사 패턴
  Map<String, dynamic>? _mealPattern;

  // Step 3: 체질 선택
  Somatotype? _selectedSomatotype;

  // Step 4: 체형 선택
  BodyShape? _selectedBodyShape;

  // Step 5: 상세 정보
  MuscleType _muscleType = MuscleType.medium;

  // Step 6: 성격 테스트
  double _extraversion = 50.0;
  double _conscientiousness = 50.0;
  double _neuroticism = 50.0;

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveProfile() async {
    // BodyComposition 생성
    final bodyComposition = BodyComposition.fromBodyShape(
      _selectedBodyShape?.name ?? 'rectangle',
    ).copyWith(muscleType: _muscleType.name);

    // UserProfile 생성
    final profile = UserProfile(
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      height: _height,
      initialWeight: _weight,
      gender: _gender,
      age: _age,
      activityLevel: _activityLevel,
      somatotype: _selectedSomatotype?.name,
      bodyShape: _selectedBodyShape?.name,
      personalityTraits: {
        'extraversion': _extraversion.round(),
        'conscientiousness': _conscientiousness.round(),
        'neuroticism': _neuroticism.round(),
        'openness': 50,
        'agreeableness': 50,
      },
    );

    // BodyComposition 저장
    profile.setBodyComposition(bodyComposition);

    // 식사 패턴 저장
    if (_mealPattern != null) {
      profile.setMealPattern(_mealPattern!);
    }

    // 저장
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.saveUserProfile(profile);

    // 홈 화면으로 이동
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 설정 (${_currentStep + 1}/$_totalSteps)'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Column(
        children: [
          // 진행률 표시
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey[200],
          ),

          // 페이지 내용
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1BasicInfo(),
                _buildStep2MealPattern(),
                _buildStep3SomatotypeSelection(),
                _buildStep4BodyShapeSelection(),
                _buildStep5DetailedInfo(),
                _buildStep6PersonalityTest(),
                _buildStep7HealthPermission(),
              ],
            ),
          ),

          // 하단 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('이전'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _nextStep : null,
                      child: Text(
                        _currentStep == _totalSteps - 1 ? '완료' : '다음',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // 기본 정보
        return _height > 0 && _weight > 0 && _age > 0;
      case 1: // 식사 패턴
        return _mealPattern != null && _mealPattern!.isNotEmpty;
      case 2: // 체질 선택
        return _selectedSomatotype != null;
      case 3: // 체형 선택
        return _selectedBodyShape != null;
      case 4: // 상세 정보
        return true;
      case 5: // 성격 테스트
        return true;
      case 6: // 헬스 데이터 권한
        return true; // 권한은 선택사항
      default:
        return false;
    }
  }

  // ===== Step 1: 기본 정보 =====
  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 정보',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '정확한 칼로리 계산을 위해 기본 정보를 입력해주세요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // 이름 (선택)
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '이름 (선택사항)',
              hintText: '예: 홍길동',
            ),
          ),
          const SizedBox(height: 24),

          // 성별
          Text('성별', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'female',
                label: Text('여성'),
                icon: Icon(Icons.female),
              ),
              ButtonSegment(
                value: 'male',
                label: Text('남성'),
                icon: Icon(Icons.male),
              ),
            ],
            selected: {_gender},
            onSelectionChanged: (Set<String> selected) {
              setState(() {
                _gender = selected.first;
              });
            },
          ),
          const SizedBox(height: 24),

          // 나이
          Text('나이: $_age세', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _age.toDouble(),
            min: 10,
            max: 100,
            divisions: 90,
            label: '$_age세',
            onChanged: (value) {
              setState(() {
                _age = value.toInt();
              });
            },
          ),
          const SizedBox(height: 24),

          // 키
          Text(
            '키: ${_height.toInt()}cm',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _height,
            min: 130,
            max: 220,
            divisions: 90,
            label: '${_height.toInt()}cm',
            onChanged: (value) {
              setState(() {
                _height = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // 체중
          Text(
            '체중: ${_weight.toInt()}kg',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _weight,
            min: 30,
            max: 200,
            divisions: 170,
            label: '${_weight.toInt()}kg',
            onChanged: (value) {
              setState(() {
                _weight = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // 활동 수준
          Text('활동 수준', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _activityLevel,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'sedentary', child: Text('거의 운동 안 함')),
              DropdownMenuItem(value: 'light', child: Text('가벼운 운동 (주 1-3일)')),
              DropdownMenuItem(
                value: 'moderate',
                child: Text('보통 운동 (주 3-5일)'),
              ),
              DropdownMenuItem(value: 'active', child: Text('적극적 운동 (주 6-7일)')),
              DropdownMenuItem(
                value: 'very_active',
                child: Text('매우 적극적 (하루 2회 이상)'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _activityLevel = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // ===== Step 2: 식사 패턴 ====="
  Widget _buildStep2MealPattern() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '식사 패턴 설정',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '하루 식사 패턴을 설정하면 맞춤 알림을 받을 수 있어요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // 프리셋 버튼들
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMealPresetChip('2식', 2),
              _buildMealPresetChip('3식 (권장)', 3),
              _buildMealPresetChip('4식+', 4),
            ],
          ),

          if (_mealPattern != null) ...[
            const SizedBox(height: 24),
            Text('설정된 식사 시간', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ..._buildMealTimesList(),
          ],
        ],
      ),
    );
  }

  Widget _buildMealPresetChip(String label, int mealCount) {
    final isSelected =
        _mealPattern != null &&
        (_mealPattern!['mealsPerDay'] as int?) == mealCount;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _applyMealPreset(mealCount);
          });
        }
      },
    );
  }

  void _applyMealPreset(int mealCount) {
    List<Map<String, dynamic>> meals;

    switch (mealCount) {
      case 2:
        meals = [
          {'name': '점심', 'enabled': true, 'hour': 12, 'minute': 0},
          {'name': '저녁', 'enabled': true, 'hour': 18, 'minute': 0},
        ];
        break;
      case 3:
        meals = [
          {'name': '아침', 'enabled': true, 'hour': 7, 'minute': 0},
          {'name': '점심', 'enabled': true, 'hour': 12, 'minute': 0},
          {'name': '저녁', 'enabled': true, 'hour': 18, 'minute': 0},
        ];
        break;
      case 4:
        meals = [
          {'name': '아침', 'enabled': true, 'hour': 7, 'minute': 0},
          {'name': '오전간식', 'enabled': true, 'hour': 10, 'minute': 30},
          {'name': '점심', 'enabled': true, 'hour': 12, 'minute': 0},
          {'name': '저녁', 'enabled': true, 'hour': 18, 'minute': 0},
        ];
        break;
      default:
        meals = [];
    }

    _mealPattern = {'mealsPerDay': mealCount, 'meals': meals, 'snacks': []};
  }

  List<Widget> _buildMealTimesList() {
    final meals = _mealPattern!['meals'] as List;
    return meals.map((meal) {
      final name = meal['name'] as String;
      final hour = meal['hour'] as int;
      final minute = meal['minute'] as int;
      final timeString =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.restaurant),
          title: Text(name),
          trailing: Text(
            timeString,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }).toList();
  }

  // ===== Step 3: 체질 선택 =====
  Widget _buildStep3SomatotypeSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '체질 선택',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '당신의 체질 타입을 선택하세요. 대사율 계산에 반영됩니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // 체질 선택 카드들
          ...Somatotype.values.where((s) => s != Somatotype.mixed).map((type) {
            final isSelected = _selectedSomatotype == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                elevation: isSelected ? 8 : 2,
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSomatotype = type;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.displayName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedSomatotype = Somatotype.mixed;
              });
            },
            icon: const Icon(Icons.help_outline),
            label: const Text('잘 모르겠어요'),
          ),
        ],
      ),
    );
  }

  // ===== Step 4: 체형 선택 =====
  Widget _buildStep4BodyShapeSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '체형 선택',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '살이 주로 어디에 찌나요? 아바타 표현에 반영됩니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // 체형 선택 카드들
          ...BodyShape.values.map((shape) {
            final isSelected = _selectedBodyShape == shape;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                elevation: isSelected ? 8 : 2,
                color: isSelected
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedBodyShape = shape;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : null,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shape.displayName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                shape.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===== Step 5: 상세 정보 =====
  Widget _buildStep5DetailedInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상세 정보',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '추가 정보로 더 정확한 칼로리 계산이 가능합니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // 근육량
          Text('근육량', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<MuscleType>(
            segments: MuscleType.values
                .map(
                  (type) =>
                      ButtonSegment(value: type, label: Text(type.displayName)),
                )
                .toList(),
            selected: {_muscleType},
            onSelectionChanged: (Set<MuscleType> selected) {
              setState(() {
                _muscleType = selected.first;
              });
            },
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '근육량이 많을수록 기초대사량이 높아집니다.',
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Step 6: 성격 테스트 =====
  Widget _buildStep6PersonalityTest() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '간단한 성격 테스트',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '일상 활동량 계산에 반영됩니다. (NEAT)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // 외향성
          _buildPersonalitySlider(
            '평소 활기차고 외향적인가요?',
            _extraversion,
            (value) => setState(() => _extraversion = value),
          ),
          const SizedBox(height: 32),

          // 성실성
          _buildPersonalitySlider(
            '계획적이고 규칙적인가요?',
            _conscientiousness,
            (value) => setState(() => _conscientiousness = value),
          ),
          const SizedBox(height: 32),

          // 신경성
          _buildPersonalitySlider(
            '앉아 있을 때 자주 움직이나요?\n(손동작, 다리 떨기 등)',
            _neuroticism,
            (value) => setState(() => _neuroticism = value),
          ),
          const SizedBox(height: 24),

          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '성격 특성에 따라 일일 권장 칼로리가 조정됩니다.',
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalitySlider(
    String question,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('아니다'),
            Expanded(
              child: Slider(
                value: value,
                min: 0,
                max: 100,
                divisions: 20,
                label: value.round().toString(),
                onChanged: onChanged,
              ),
            ),
            const Text('그렇다'),
          ],
        ),
      ],
    );
  }

  // ===== Step 7: 헬스 데이터 권한 =====
  Widget _buildStep7HealthPermission() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '헬스 데이터 권한',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '웨어러블 기기와의 자동 동기화를 위해 건강 데이터 접근 권한이 필요합니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // 권한 설명 카드
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        color: Colors.blue.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '권한 허용 시 제공되는 기능',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionFeature(
                    '걸음 수 자동 동기화',
                    '매일 걸음 수를 자동으로 가져와 칼로리 계산에 반영합니다.',
                  ),
                  const SizedBox(height: 12),
                  _buildPermissionFeature(
                    '칼로리 소모량 추적',
                    '운동 및 일상 활동으로 소모된 칼로리를 정확히 계산합니다.',
                  ),
                  const SizedBox(height: 12),
                  _buildPermissionFeature(
                    '운동 기록 자동 저장',
                    '웨어러블 기기의 운동 데이터를 앱에 자동으로 저장합니다.',
                  ),
                  const SizedBox(height: 12),
                  _buildPermissionFeature(
                    '개인 맞춤 추천',
                    '더 정확한 데이터를 기반으로 식단과 운동을 추천합니다.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 선택 옵션
          Text('권한 선택', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          // 권한 허용 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final healthService = HealthDataService();
                final permissionGranted = await healthService
                    .requestPermissions();

                if (permissionGranted && mounted) {
                  // 권한 얻었으면 동기화 시도
                  final appProvider = Provider.of<AppProvider>(
                    context,
                    listen: false,
                  );
                  await appProvider.syncHealthData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('헬스 데이터 권한이 허용되었습니다')),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('헬스 데이터 권한이 거부되었습니다'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('권한 허용하고 자동 동기화 사용'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 나중에 설정 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // 권한 없이 진행
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('설정 > 헬스 데이터 권한에서 언제든 권한을 허용할 수 있습니다'),
                    duration: Duration(seconds: 4),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('나중에 설정하기'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 안내 텍스트
          Card(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '권한을 허용하지 않아도 앱의 기본 기능은 사용할 수 있습니다. 웨어러블 데이터 동기화만 제한됩니다.',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionFeature(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
