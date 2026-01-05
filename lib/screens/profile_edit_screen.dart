import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import '../models/body_types.dart';
import '../models/body_composition.dart';
import '../widgets/advanced_avatar_widget.dart';
import '../avatar/body_measurements.dart';
import '../l10n/app_localizations.dart';

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
  bool _hasError = false; // 프로필 로드 실패 상태

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

    print('Debug: _loadCurrentProfile called. Profile: ${profile?.name}'); // 디버깅 로그

    // 프로필이 반드시 존재해야 함 (앱 설치 시 프로필 설정 완료)
    if (profile == null) {
      print('Debug: Profile is NULL. Showing error screen instead of redirecting.'); 
      // 리다이렉트 대신 에러 상태 표시
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

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

    _personalityTraits = Map<String, int>.from(
      profile.personalityTraits ??
          {
            'extraversion': 50,
            'conscientiousness': 50,
            'neuroticism': 50,
            'openness': 50,
            'agreeableness': 50,
          },
    );

    setState(() => _isLoading = false);
  }

  void _checkChanges() {
    if (_originalProfile == null) return;

    setState(() {
      _hasChanges =
          _nameController.text != (_originalProfile!.name ?? '') ||
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
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
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
    final bodyComp = BodyComposition.fromBodyShape(
      _bodyShape?.name ?? 'rectangle',
    ).copyWith(muscleType: _muscleType.name);
    updatedProfile.setBodyComposition(bodyComp);

    await provider.saveUserProfile(updatedProfile);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdated),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    if (!mounted) return false;
    final l10n = AppLocalizations.of(context)!;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.discardChanges),
            content: Text(l10n.discardChangesMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.continueEditing),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.exitWithoutSaving),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l10n = AppLocalizations.of(context)!;

    if (_hasError) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profileEdit)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('프로필 정보를 불러올 수 없습니다.'),
              const Text('잠시 후 다시 시도해주세요.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadCurrentProfile();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileEdit),
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
            tabs: [
              Tab(icon: const Icon(Icons.person), text: l10n.basicInfo),
              Tab(icon: const Icon(Icons.fitness_center), text: l10n.bodyInfo),
              Tab(icon: const Icon(Icons.psychology), text: l10n.personality),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
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
                        color: Colors.black.withAlpha(26), // 0.1 opacity
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
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
                      child: Text(
                        l10n.saveChanges,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
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
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
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
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.nameOptional,
              hintText: l10n.nameHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => _checkChanges(),
          ),
          const SizedBox(height: 24),

          // 성별
          Text(l10n.gender, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'female',
                label: Text(l10n.female),
                icon: Icon(Icons.female),
              ),
              ButtonSegment(
                value: 'male',
                label: Text(l10n.male),
                icon: Icon(Icons.male),
              ),
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
          Text(
            '${l10n.age}: $_age${l10n.ageUnit}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _age.toDouble(),
            min: 10,
            max: 100,
            divisions: 90,
            label: '$_age${l10n.ageUnit}',
            onChanged: (value) {
              setState(() {
                _age = value.toInt();
                _checkChanges();
              });
            },
          ),
          const SizedBox(height: 24),

          // 키
          Text(
            '${l10n.height}: ${_height.toInt()}cm',
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
                _checkChanges();
              });
            },
          ),
          const SizedBox(height: 24),

          // 체중
          Text(
            '${l10n.weight}: ${_weight.toInt()}kg',
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
                _checkChanges();
              });
            },
          ),
          const SizedBox(height: 24),

          // 활동 수준
          Text(
            l10n.activityLevel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _activityLevel,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              DropdownMenuItem(
                value: 'sedentary',
                child: Text(l10n.activitySedentary),
              ),
              DropdownMenuItem(value: 'light', child: Text(l10n.activityLight)),
              DropdownMenuItem(
                value: 'moderate',
                child: Text(l10n.activityModerate),
              ),
              DropdownMenuItem(
                value: 'active',
                child: Text(l10n.activityActive),
              ),
              DropdownMenuItem(
                value: 'very_active',
                child: Text(l10n.activityVeryActive),
              ),
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
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 체질 선택
          Text(
            l10n.stepSomatotype,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.somatotypeDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          ...Somatotype.values.where((s) => s != Somatotype.mixed).map((type) {
            final isSelected = _somatotype == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
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
                                _getLocalizedSomatotypeName(context, type),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getLocalizedSomatotypeDesc(context, type),
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
            l10n.stepBodyShape,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.bodyShapeDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          ...BodyShape.values.map((shape) {
            final isSelected = _bodyShape == shape;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
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
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : null,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getLocalizedBodyShapeName(context, shape),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getLocalizedBodyShapeDesc(context, shape),
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
          Text(l10n.muscleType, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<MuscleType>(
            segments: MuscleType.values
                .map(
                  (type) => ButtonSegment(
                    value: type,
                    label: Text(_getLocalizedMuscleType(context, type)),
                  ),
                )
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
                      l10n.muscleInfo,
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
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.personality,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.personalityDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // 외향성
          _buildPersonalitySlider(
            l10n.questionExtraversion,
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
            l10n.questionConscientiousness,
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
            l10n.questionNeuroticism,
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
                      l10n.personalityInfo,
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
            Text(AppLocalizations.of(context)!.no),
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
            Text(AppLocalizations.of(context)!.yes),
          ],
        ),
      ],
    );
  }

  String _getLocalizedSomatotypeName(BuildContext context, Somatotype type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case Somatotype.ectomorph:
        return l10n.somatotypeEctomorph;
      case Somatotype.mesomorph:
        return l10n.somatotypeMesomorph;
      case Somatotype.endomorph:
        return l10n.somatotypeEndomorph;
      case Somatotype.mixed:
        return l10n.somatotypeMixed;
    }
  }

  String _getLocalizedSomatotypeDesc(BuildContext context, Somatotype type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case Somatotype.ectomorph:
        return l10n.somatotypeEctomorphDesc;
      case Somatotype.mesomorph:
        return l10n.somatotypeMesomorphDesc;
      case Somatotype.endomorph:
        return l10n.somatotypeEndomorphDesc;
      case Somatotype.mixed:
        return l10n.somatotypeMixedDesc;
    }
  }

  String _getLocalizedBodyShapeName(BuildContext context, BodyShape shape) {
    final l10n = AppLocalizations.of(context)!;
    switch (shape) {
      case BodyShape.apple:
        return l10n.bodyShapeApple;
      case BodyShape.pear:
        return l10n.bodyShapePear;
      case BodyShape.hourglass:
        return l10n.bodyShapeHourglass;
      case BodyShape.rectangle:
        return l10n.bodyShapeRectangle;
      case BodyShape.invertedTriangle:
        return l10n.bodyShapeInvertedTriangle;
    }
  }

  String _getLocalizedBodyShapeDesc(BuildContext context, BodyShape shape) {
    final l10n = AppLocalizations.of(context)!;
    switch (shape) {
      case BodyShape.apple:
        return l10n.bodyShapeAppleDesc;
      case BodyShape.pear:
        return l10n.bodyShapePearDesc;
      case BodyShape.hourglass:
        return l10n.bodyShapeHourglassDesc;
      case BodyShape.rectangle:
        return l10n.bodyShapeRectangleDesc;
      case BodyShape.invertedTriangle:
        return l10n.bodyShapeInvertedTriangleDesc;
    }
  }

  String _getLocalizedMuscleType(BuildContext context, MuscleType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case MuscleType.low:
        return l10n.muscleLow;
      case MuscleType.medium:
        return l10n.muscleMedium;
      case MuscleType.high:
        return l10n.muscleHigh;
    }
  }
}
