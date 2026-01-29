import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/app_provider.dart';
import '../services/health_data_service.dart';
import '../models/user_profile.dart';
import '../models/body_types.dart';
import '../models/body_composition.dart';
import '../l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();

    // 프로필 설정 화면 초기화 로그
    print('🎯 프로필 설정 화면 initState - PRINT');
    debugPrint('🎯 프로필 설정 화면 initState - DEBUG PRINT');
    developer.log('🎯 프로필 설정 화면 초기화 - 현재 단계: $_currentStep');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎯 프로필 설정 화면 렌더링 완료 - POST FRAME');
      debugPrint('🎯 프로필 설정 화면 렌더링 완료 - POST FRAME DEBUG');
      developer.log('🎯 프로필 설정 화면 렌더링 완료 - 현재 단계: $_currentStep');
    });
  }

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

  // Step 7: 헬스 데이터 권한
  bool _isRequestingPermission = false;

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
    try {
      // 디버깅 정보 수집 및 로깅
      developer.log('🔍 프로필 저장 디버깅 시작', name: 'ProfileSave');
      developer.log(
        '📱 기기 정보: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      );
      try {
        final dir = await getApplicationDocumentsDirectory();
        developer.log('💾 저장소 경로: ${dir.path}');
      } catch (e) {
        developer.log('❌ 저장소 경로 확인 실패: $e');
      }
      developer.log('🗄️ Hive 박스 상태: ${Hive.isBoxOpen('userProfile')}');

      // 로딩 상태 표시
      if (!mounted) return;
      setState(() => _isRequestingPermission = true);
      developer.log('✅ UI 로딩 상태 설정 완료');

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

      // 저장 (AppProvider 내부에서 이미 검증 완료)
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      try {
        await appProvider.saveUserProfile(profile);
      } catch (e, stackTrace) {
        if (!mounted) return;

        // 콘솔에 상세 오류 정보 출력
        developer.log('❌ 프로필 설정 저장 실패', error: e, stackTrace: stackTrace);
        developer.log('📊 프로필 데이터: ${profile.toJson()}');
        developer.log(
          '📱 기기 정보: ${profile.height}cm, ${profile.initialWeight}kg, ${profile.age}세, ${profile.gender}',
        );
        developer.log('🎯 체질 정보: ${profile.somatotype}, ${profile.bodyShape}');

        // 오류 유형별 처리
        String errorMessage = '프로필 저장에 실패했습니다.';
        if (e.toString().contains('데이터베이스')) {
          errorMessage = '데이터베이스 오류로 저장에 실패했습니다. 잠시 후 다시 시도해주세요.';
          developer.log('🔧 데이터베이스 관련 오류 감지');
        } else if (e.toString().contains('JSON')) {
          errorMessage = '데이터 변환 오류로 저장에 실패했습니다.';
          developer.log('🔧 JSON 변환 관련 오류 감지');
        } else if (e.toString().contains('Hive')) {
          errorMessage = '저장소 오류로 저장에 실패했습니다.';
          developer.log('🔧 Hive 저장소 관련 오류 감지');
        }

        // 사용자에게 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      if (!mounted) return;

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필이 성공적으로 저장되었습니다!'),
          duration: Duration(seconds: 2),
        ),
      );

      // 홈 화면으로 이동
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (!mounted) return;

      // 에러 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로필 저장 실패: $e'),
          duration: const Duration(seconds: 4),
        ),
      );

      developer.log('❌ 프로필 저장 실패: $e');
    } finally {
      if (mounted) {
        setState(() => _isRequestingPermission = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.profileSetup} (${_currentStep + 1}/$_totalSteps)'),
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
                        child: Text(l10n.previous),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed()
                          ? () {
                              developer.log(
                                '🎯 완료 버튼 클릭됨 - 단계: $_currentStep, 진행 가능: ${_canProceed()}',
                              );
                              if (_currentStep == _totalSteps - 1) {
                                developer.log('🎯 최종 단계 - 프로필 저장 시작');
                                _saveProfile();
                              } else {
                                developer.log(
                                  '➡️ 다음 단계로 이동: $_currentStep -> ${_currentStep + 1}',
                                );
                                _nextStep();
                              }
                            }
                          : () {
                              developer.log(
                                '🚫 완료 버튼 비활성화됨 - 단계: $_currentStep, 진행 불가: ${_canProceed()}',
                              );
                              // 버튼이 비활성화된 이유를 더 자세히 로깅
                              _logButtonDisabledReason();
                            },
                      child: Text(
                        _currentStep == _totalSteps - 1
                            ? l10n.complete
                            : l10n.next,
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
    developer.log('🔍 _canProceed() 검증 시작 - 현재 단계: $_currentStep');

    bool result;
    switch (_currentStep) {
      case 0: // 기본 정보
        bool nameValid = _nameController.text.trim().isNotEmpty;
        bool heightValid = _height > 0;
        bool weightValid = _weight > 0;
        bool ageValid = _age > 0;

        developer.log(
          '📝 단계 0 검증: 이름=$nameValid(${_nameController.text.trim()}), 키=$heightValid($_height), 체중=$weightValid($_weight), 나이=$ageValid($_age)',
        );
        result = nameValid && heightValid && weightValid && ageValid;
        break;
      case 1: // 식사 패턴
        result = _mealPattern != null && _mealPattern!.isNotEmpty;
        developer.log(
          '🍽️ 단계 1 검증: 식사패턴=${result ? '설정됨(${_mealPattern!.length}개 항목)' : '미설정'}',
        );
        break;
      case 2: // 체질 선택
        result = _selectedSomatotype != null;
        developer.log(
          '🏋️ 단계 2 검증: 체질=${result ? _selectedSomatotype!.name : '미선택'}',
        );
        break;
      case 3: // 체형 선택
        result = _selectedBodyShape != null;
        developer.log(
          '👤 단계 3 검증: 체형=${result ? _selectedBodyShape!.name : '미선택'}',
        );
        break;
      case 4: // 상세 정보
        result = true;
        developer.log('⚙️ 단계 4 검증: 상세정보=항상통과');
        break;
      case 5: // 성격 테스트
        result = true;
        developer.log('🧠 단계 5 검증: 성격테스트=항상통과');
        break;
      case 6: // 헬스 데이터 권한
        result = true; // 권한은 선택사항
        developer.log('🏥 단계 6 검증: 헬스권한=항상통과(선택사항)');
        break;
      default:
        result = false;
        developer.log('❌ 단계 $_currentStep 검증: 알 수 없는 단계');
    }

    developer.log('✅ _canProceed() 결과: $result');
    return result;
  }

  // 버튼 비활성화 이유 로깅
  void _logButtonDisabledReason() {
    developer.log('🔍 버튼 비활성화 상세 분석 - 단계: $_currentStep');

    switch (_currentStep) {
      case 0:
        developer.log('📝 단계 0 문제점:');
        developer.log(
          '  - 이름: ${_nameController.text.trim().isNotEmpty ? '입력됨' : '미입력'} (${_nameController.text.trim()})',
        );
        developer.log('  - 키: ${_height > 0 ? '설정됨' : '미설정'} (${_height}cm)');
        developer.log('  - 체중: ${_weight > 0 ? '설정됨' : '미설정'} (${_weight}kg)');
        developer.log('  - 나이: ${_age > 0 ? '설정됨' : '미설정'} (${_age}세)');
        break;
      case 1:
        developer.log('🍽️ 단계 1 문제점:');
        developer.log('  - 식사 패턴: ${_mealPattern != null ? '설정됨' : '미설정'}');
        if (_mealPattern != null) {
          developer.log('  - 식사 개수: ${_mealPattern!['mealsPerDay']}개');
        }
        break;
      case 2:
        developer.log('🏋️ 단계 2 문제점:');
        developer.log(
          '  - 체질 선택: ${_selectedSomatotype != null ? '선택됨' : '미선택'}',
        );
        break;
      case 3:
        developer.log('👤 단계 3 문제점:');
        developer.log(
          '  - 체형 선택: ${_selectedBodyShape != null ? '선택됨' : '미선택'}',
        );
        break;
      default:
        developer.log('❓ 알 수 없는 단계: $_currentStep');
    }

    // 현재 상태 요약
    developer.log('📊 현재 프로필 상태 요약:');
    developer.log('  - 이름: ${_nameController.text.trim()}');
    developer.log('  - 키/체중/나이: ${_height}cm / ${_weight}kg / ${_age}세');
    developer.log('  - 성별: $_gender');
    developer.log('  - 활동수준: $_activityLevel');
    developer.log('  - 식사패턴: ${_mealPattern != null ? '있음' : '없음'}');
    developer.log('  - 체질: ${_selectedSomatotype?.name ?? '없음'}');
    developer.log('  - 체형: ${_selectedBodyShape?.name ?? '없음'}');
  }

  // ===== Step 1: 기본 정보 =====
  Widget _buildStep1BasicInfo() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.basicInfo,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.basicInfoDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // 이름 (필수)
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.nameOptional, // 지역화된 문자열 사용
              hintText: l10n.nameHint,
            ),
            onChanged: (value) {
              setState(() {}); // 실시간 검증을 위해 상태 업데이트
            },
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
                icon: const Icon(Icons.female),
              ),
              ButtonSegment(
                value: 'male',
                label: Text(l10n.male),
                icon: const Icon(Icons.male),
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
          Text(
            '${l10n.age}: $_age${l10n.yearsOld}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _age.toDouble(),
            min: 10,
            max: 100,
            divisions: 90,
            label: '$_age${l10n.yearsOld}',
            onChanged: (value) {
              setState(() {
                _age = value.toInt();
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
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mealPatternSetup,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.mealPatternDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // 프리셋 버튼들
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMealPresetChip(l10n.meals2, 2),
              _buildMealPresetChip(l10n.meals3, 3),
              _buildMealPresetChip(l10n.meals4Plus, 4),
            ],
          ),

          if (_mealPattern != null) ...[
            const SizedBox(height: 24),
            Text(
              l10n.configuredMealTimes,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._buildMealTimesList(l10n),
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
    final l10n = AppLocalizations.of(context)!;
    List<Map<String, dynamic>> meals;

    switch (mealCount) {
      case 2:
        meals = [
          {
            'name': l10n.mealLunchPreset,
            'enabled': true,
            'hour': 12,
            'minute': 0,
          },
          {
            'name': l10n.mealDinnerPreset,
            'enabled': true,
            'hour': 18,
            'minute': 0,
          },
        ];
        break;
      case 3:
        meals = [
          {
            'name': l10n.mealBreakfastPreset,
            'enabled': true,
            'hour': 7,
            'minute': 0,
          },
          {
            'name': l10n.mealLunchPreset,
            'enabled': true,
            'hour': 12,
            'minute': 0,
          },
          {
            'name': l10n.mealDinnerPreset,
            'enabled': true,
            'hour': 18,
            'minute': 0,
          },
        ];
        break;
      case 4:
        meals = [
          {
            'name': l10n.mealBreakfastPreset,
            'enabled': true,
            'hour': 7,
            'minute': 0,
          },
          {
            'name': l10n.mealSnackMorningPreset,
            'enabled': true,
            'hour': 10,
            'minute': 30,
          },
          {
            'name': l10n.mealLunchPreset,
            'enabled': true,
            'hour': 12,
            'minute': 0,
          },
          {
            'name': l10n.mealDinnerPreset,
            'enabled': true,
            'hour': 18,
            'minute': 0,
          },
        ];
        break;
      default:
        meals = [];
    }

    _mealPattern = {'mealsPerDay': mealCount, 'meals': meals, 'snacks': []};
  }

  List<Widget> _buildMealTimesList(AppLocalizations l10n) {
    final meals = _mealPattern!['meals'] as List;
    return meals.map((meal) {
      final name = meal['name'] as String;
      final hour = meal['hour'] as int;
      final minute = meal['minute'] as int;
      final timeString =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

      // 식사 이름 지역화 - 현지화 키와 비교
      String localizedName = name;
      if (name == l10n.mealBreakfastPreset)
        localizedName = l10n.mealBreakfast;
      else if (name == l10n.mealLunchPreset)
        localizedName = l10n.mealLunch;
      else if (name == l10n.mealDinnerPreset)
        localizedName = l10n.mealDinner;
      else if (name == l10n.mealSnackMorningPreset)
        localizedName = l10n.mealSnackMorning;
      else if (name == l10n.mealSnackAfternoonPreset)
        localizedName = l10n.mealSnackAfternoon;

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.restaurant),
          title: Text(localizedName),
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
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.somatotypeSelection,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.somatotypeDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // 체질 선택 카드들
          ...Somatotype.values.where((s) => s != Somatotype.mixed).map((type) {
            final isSelected = _selectedSomatotype == type;

            // Enum 이름 지역화
            String displayName = type.displayName;
            String description = type.description;

            switch (type) {
              case Somatotype.ectomorph:
                displayName = l10n.somatotypeEctomorph;
                description = l10n.somatotypeEctomorphDesc;
                break;
              case Somatotype.mesomorph:
                displayName = l10n.somatotypeMesomorph;
                description = l10n.somatotypeMesomorphDesc;
                break;
              case Somatotype.endomorph:
                displayName = l10n.somatotypeEndomorph;
                description = l10n.somatotypeEndomorphDesc;
                break;
              default:
                break;
            }

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
                                displayName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
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
            label: Text(l10n.unsure),
          ),
        ],
      ),
    );
  }

  // ===== Step 4: 체형 선택 =====
  Widget _buildStep4BodyShapeSelection() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bodyShapeSelection,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.bodyShapeDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // 체형 선택 카드들
          ...BodyShape.values.map((shape) {
            final isSelected = _selectedBodyShape == shape;

            // Enum 이름 지역화
            String displayName = shape.displayName;
            String description = shape.description;

            switch (shape) {
              case BodyShape.rectangle:
                displayName = l10n.bodyShapeRectangle;
                description = l10n.bodyShapeRectangleDesc;
                break;
              case BodyShape.invertedTriangle:
                displayName = l10n.bodyShapeInvertedTriangle;
                description = l10n.bodyShapeInvertedTriangleDesc;
                break;
              case BodyShape.hourglass:
                displayName = l10n.bodyShapeHourglass;
                description = l10n.bodyShapeHourglassDesc;
                break;
              case BodyShape.pear:
                displayName = l10n.bodyShapePear;
                description = l10n.bodyShapePearDesc;
                break;
              case BodyShape.apple:
                displayName = l10n.bodyShapeApple;
                description = l10n.bodyShapeAppleDesc;
                break;
            }

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
                                displayName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
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
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.stepDetailInfo,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.detailInfoDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // 근육량
          Text(l10n.muscleType, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<MuscleType>(
            segments: MuscleType.values.map((type) {
              String label = type.displayName;
              switch (type) {
                case MuscleType.low:
                  label = l10n.muscleLow;
                  break;
                case MuscleType.medium:
                  label = l10n.muscleMedium;
                  break;
                case MuscleType.high:
                  label = l10n.muscleHigh;
                  break;
              }
              return ButtonSegment(value: type, label: Text(label));
            }).toList(),
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

  // ===== Step 6: 성격 테스트 =====
  Widget _buildStep6PersonalityTest() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.stepPersonality,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
            _extraversion,
            (value) => setState(() => _extraversion = value),
            l10n,
          ),
          const SizedBox(height: 32),

          // 성실성
          _buildPersonalitySlider(
            l10n.questionConscientiousness,
            _conscientiousness,
            (value) => setState(() => _conscientiousness = value),
            l10n,
          ),
          const SizedBox(height: 32),

          // 신경성
          _buildPersonalitySlider(
            l10n.questionNeuroticism,
            _neuroticism,
            (value) => setState(() => _neuroticism = value),
            l10n,
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
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(l10n.no),
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
            Text(l10n.yes),
          ],
        ),
      ],
    );
  }

  // ===== Step 7: 헬스 데이터 권한 =====
  Widget _buildStep7HealthPermission() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.healthDataPermission,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.healthPermissionContent,
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
                        l10n.healthPermissionAllowInfo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionFeature(l10n.healthPermissionInfo1),
                  const SizedBox(height: 12),
                  _buildPermissionFeature(l10n.healthPermissionInfo2),
                  const SizedBox(height: 12),
                  _buildPermissionFeature(l10n.healthPermissionInfo3),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 선택 옵션
          Text(
            l10n.permissionSelect,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // 권한 허용 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRequestingPermission
                  ? null
                  : () async {
                      setState(() => _isRequestingPermission = true);

                      try {
                        // 아주 기본적인 테스트부터 시작
                        print('=== BUTTON CLICK TEST 1 ===');
                        debugPrint('=== BUTTON CLICK TEST 1 DEBUG ===');

                        // developer.log 호출 전 테스트
                        print('=== BUTTON CLICK TEST 2 ===');
                        debugPrint('=== BUTTON CLICK TEST 2 DEBUG ===');

                        developer.log('🔧 HealthDataService 생성 시도');
                        print('🔧 PRINT: HealthDataService 생성 시도');

                        // developer.log 호출 후 테스트
                        print('=== BUTTON CLICK TEST 3 ===');
                        debugPrint('=== BUTTON CLICK TEST 3 DEBUG ===');

                        developer.log('🔧 HealthDataService 생성 시도');
                        final healthService = HealthDataService();
                        developer.log('✅ HealthDataService 생성 완료');

                        bool permissionGranted;

                        // 플랫폼별 권한 요청 처리
                        if (Platform.isAndroid) {
                          // Android: Health Connect 권한 요청
                          developer.log('🤖 Android Health Connect 권한 요청 시작');

                          try {
                            await healthService.initialize();
                            developer.log('✅ Health Connect 초기화 완료');
                          } catch (e) {
                            throw Exception(
                              l10n.healthConnectInitFailed(e.toString()),
                            );
                          }

                          // Health Connect 상태 확인
                          final status = await healthService.checkHealthConnectStatus();
                          if (status == 2) {
                            await healthService.openHealthConnectStore();
                            throw Exception(l10n.healthConnectUpdateRequired);
                          } else if (status == 0) {
                            await healthService.openHealthConnectStore();
                            throw Exception(l10n.healthConnectNotInstalled);
                          }

                          permissionGranted = await healthService.requestPermissions();
                          developer.log('📱 Android 권한 요청 결과: $permissionGranted');

                        } else if (Platform.isIOS) {
                          // iOS: HealthKit 권한 요청
                          developer.log('🍎 iOS HealthKit 권한 요청 시작');

                          permissionGranted = await healthService.requestPermissions();
                          developer.log('📱 iOS 권한 요청 결과: $permissionGranted');

                        } else {
                          developer.log('⚠️ 지원하지 않는 플랫폼');
                          permissionGranted = false;
                        }

                        if (permissionGranted && mounted) {
                          // 권한 얻었으면 동기화 시도
                          developer.log('🔄 헬스 데이터 동기화 시작');

                          final appProvider = Provider.of<AppProvider>(
                            context,
                            listen: false,
                          );
                          developer.log('✅ AppProvider 획득 성공');

                          try {
                            await appProvider.syncHealthData();
                            developer.log('✅ 헬스 데이터 동기화 완료');
                          } catch (e) {
                            developer.log('❌ 헬스 데이터 동기화 실패: $e');
                            throw Exception('동기화 실패: $e');
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.healthPermissionGranted),
                              ),
                            );
                          }
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.healthPermissionDenied),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isRequestingPermission = false);
                        }
                      }
                    },
              icon: _isRequestingPermission
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: _isRequestingPermission
                  ? const Text('Loading...')
                  : Text(l10n.allowAndSync),
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
                  SnackBar(
                    content: Text(l10n.healthPermissionDenyInfo),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              label: Text(l10n.setupLater),
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
                      l10n.healthPermissionDenyInfo,
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

  Widget _buildPermissionFeature(String title, [String? description]) {
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
              if (description != null) ...[
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
            ],
          ),
        ),
      ],
    );
  }
}
