import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import '../models/body_types.dart';
import '../models/body_composition.dart';
import '../widgets/advanced_avatar_widget.dart';
import '../avatar/body_measurements.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 원본 데이터 (취소 시 복구용)
  UserProfile? _originalProfile;

  // 수정 중인 데이터
  late TextEditingController _nameController;
  late double _height;
  late double _weight;
  late String _gender;
  late int _age;
  late String _activityLevel;
  Somatotype? _somatotype;
  BodyShape? _bodyShape;
  late MuscleType _muscleType;
  late Map<String, int> _personalityTraits;

  bool _hasChanges = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _nameController = TextEditingController();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final provider = context.read<AppProvider>();
    final profile = provider.userProfile;

    if (profile != null) {
      _originalProfile = profile;
      _nameController.text = profile.name ?? '';
      _height = profile.height;
      _weight = profile.initialWeight;
      _gender = profile.gender;
      _age = profile.age;
      _activityLevel = profile.activityLevel;
      _somatotype = profile.getSomatotype();
      _bodyShape = profile.getBodyShape();
      
      final bodyComp = profile.getBodyComposition();
      _muscleType = bodyComp != null 
          ? MuscleType.fromString(bodyComp.muscleType)
          : MuscleType.medium;
      
      _personalityTraits = Map<String, int>.from(profile.personalityTraits ?? {
        'extraversion': 50,
        'conscientiousness': 50,
        'neuroticism': 50,
        'openness': 50,
        'agreeableness': 50,
      });
    }

    setState(() => _isLoading = false);
  }

  void _checkChanges() {
    if (_originalProfile == null) return;

    setState(() {
      _hasChanges = _nameController.text != (_originalProfile!.name ?? '') ||
          _height != _originalProfile!.height ||
          _weight != _originalProfile!.initialWeight ||
          _gender != _originalProfile!.gender ||
          _age != _originalProfile!.age ||
          _activityLevel != _originalProfile!.activityLevel ||
          _somatotype?.name != _originalProfile!.somatotype ||
          _bodyShape?.name != _originalProfile!.bodyShape ||
          !_arePersonalityTraitsEqual();
    });
  }

  bool _arePersonalityTraitsEqual() {
    final original = _originalProfile?.personalityTraits ?? {};
    if (_personalityTraits.length != original.length) return false;
    
    for (var key in _personalityTraits.keys) {
      if (_personalityTraits[key] != original[key]) return false;
    }
    return true;
  }

  Future<void> _saveChanges() async {
    if (_originalProfile == null) return;

    final provider = context.read<AppProvider>();

    final updatedProfile = _originalProfile!.copyWith(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      height: _height,
      initialWeight: _weight,
      gender: _gender,
      age: _age,
      activityLevel: _activityLevel,
      somatotype: _somatotype?.name,
      bodyShape: _bodyShape?.name,
      personalityTraits: _personalityTraits,
      updatedAt: DateTime.now(),
    );

    // BodyComposition 업데이트
    final bodyComp = BodyComposition.fromBodyShape(_bodyShape?.name ?? 'rectangle')
        .copyWith(muscleType: _muscleType.name);
    updatedProfile.setBodyComposition(bodyComp);

    await provider.saveUserProfile(updatedProfile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필이 업데이트되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('변경사항 취소'),
            content: const Text('변경한 내용을 저장하지 않고 나가시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('계속 수정'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('나가기'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('프로필 수정'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFA5D6A7), // 연한 초록
                  Color(0xFFE8F5E9), // 더 연한 초록
                ],
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.person), text: '기본'),
              Tab(icon: Icon(Icons.fitness_center), text: '신체'),
              Tab(icon: Icon(Icons.psychology), text: '성격'),
            ],
          ),
        ),
        body: Column(
          children: [
            // 아바타 미리보기
            _buildAvatarPreview(),

            // 탭 내용
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicInfoTab(),
                  _buildBodyInfoTab(),
                  _buildPersonalityTab(),
                ],
              ),
            ),

            // 저장 버튼
            if (_hasChanges)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '변경사항 저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    final bmi = _weight / ((_height / 100) * (_height / 100));
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Center(
        child: AdvancedAvatarWidget(
          bmi: bmi,
          height: _height,
          gender: _gender,
          lifestyle: _mapActivityLevel(_activityLevel),
          clothingColors: _originalProfile?.getClothingColors(),
          width: 150,
          heightSize: 180,
        ),
      ),
    );
  }

  LifestylePattern _mapActivityLevel(String activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return LifestylePattern.sedentary;
      case 'light':
      case 'moderate':
      case 'active':
        return LifestylePattern.active;
      case 'very_active':
        return LifestylePattern.athletic;
      default:
        return LifestylePattern.active;
    }
  }

  // 기본 정보 탭
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '이름 (선택사항)',
              hintText: '예: 홍길동',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _checkChanges(),
          ),
          const SizedBox(height: 24),

          // 성별
          Text('성별', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'female', label: Text('여성'), icon: Icon(Icons.female)),
              ButtonSegment(value: 'male', label: Text('남성'), icon: Icon(Icons.male)),
            ],
            selected: {_gender},
            onSelectionChanged: (Set<String> selected) {
              setState(() {
                _gender = selected.first;
                _checkChanges();
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
                _checkChanges();
              });
            },
          ),
          const SizedBox(height: 24),

          // 키
          Text('키: ${_height.toInt()}cm', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _height,
            min: 130,
            max: 220,
            divisions: 90,
            label: '${_height.toInt()}cm',
            onChanged: (value) {
              setState(() {
                _height = value;
                _checkChanges();
              });
            },
          ),
          const SizedBox(height: 24),

          // 체중
          Text('체중: ${_weight.toInt()}kg', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _weight,
            min: 30,
            max: 200,
            divisions: 170,
            label: '${_weight.toInt()}kg',
            onChanged: (value) {
              setState(() {
                _weight = value;
                _checkChanges();
              });
            },
          ),
          const SizedBox(height: 24),

          // 활동 수준
          Text('활동 수준', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _activityLevel,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'sedentary', child: Text('거의 운동 안 함')),
              DropdownMenuItem(value: 'light', child: Text('가벼운 운동 (주 1-3일)')),
              DropdownMenuItem(value: 'moderate', child: Text('보통 운동 (주 3-5일)')),
              DropdownMenuItem(value: 'active', child: Text('적극적 운동 (주 6-7일)')),
              DropdownMenuItem(value: 'very_active', child: Text('매우 적극적 (하루 2회 이상)')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _activityLevel = value;
                  _checkChanges();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // 신체 정보 탭
  Widget _buildBodyInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 체질 선택
          Text(
            '체질 유형',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '당신의 체질 타입을 선택하세요. 대사율 계산에 반영됩니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          ...Somatotype.values.where((s) => s != Somatotype.mixed).map((type) {
            final isSelected = _somatotype == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _somatotype = type;
                      _checkChanges();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? Theme.of(context).colorScheme.primary : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.displayName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type.description,
                                style: Theme.of(context).textTheme.bodySmall,
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

          const SizedBox(height: 24),

          // 체형 선택
          Text(
            '체형 유형',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '살이 주로 어디에 찌나요? 아바타 표현에 반영됩니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          ...BodyShape.values.map((shape) {
            final isSelected = _bodyShape == shape;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected ? Theme.of(context).colorScheme.secondaryContainer : null,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _bodyShape = shape;
                      _checkChanges();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? Theme.of(context).colorScheme.secondary : null,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shape.displayName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                shape.description,
                                style: Theme.of(context).textTheme.bodySmall,
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

          const SizedBox(height: 24),

          // 근육량
          Text('근육량', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<MuscleType>(
            segments: MuscleType.values
                .map((type) => ButtonSegment(
                      value: type,
                      label: Text(type.displayName),
                    ))
                .toList(),
            selected: {_muscleType},
            onSelectionChanged: (Set<MuscleType> selected) {
              setState(() {
                _muscleType = selected.first;
                _checkChanges();
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

  // 성격 정보 탭
  Widget _buildPersonalityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '성격 특성',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
            _personalityTraits['extraversion']?.toDouble() ?? 50.0,
            (value) {
              setState(() {
                _personalityTraits['extraversion'] = value.round();
                _checkChanges();
              });
            },
          ),
          const SizedBox(height: 32),

          // 성실성
          _buildPersonalitySlider(
            '계획적이고 규칙적인가요?',
            _personalityTraits['conscientiousness']?.toDouble() ?? 50.0,
            (value) {
              setState(() {
                _personalityTraits['conscientiousness'] = value.round();
                _checkChanges();
              });
            },
          ),
          const SizedBox(height: 32),

          // 신경성
          _buildPersonalitySlider(
            '앉아 있을 때 자주 움직이나요?\n(손동작, 다리 떨기 등)',
            _personalityTraits['neuroticism']?.toDouble() ?? 50.0,
            (value) {
              setState(() {
                _personalityTraits['neuroticism'] = value.round();
                _checkChanges();
              });
            },
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
}
