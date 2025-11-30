import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';
import '../widgets/advanced_avatar_widget.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedGender = 'male';
  String _selectedActivityLevel = 'moderate';

  final List<String> _genders = ['male', 'female'];
  final List<String> _activityLevels = [
    'sedentary',
    'light',
    'moderate',
    'active',
    'very_active',
  ];

  final Map<String, String> _genderLabels = {'male': '남성', 'female': '여성'};

  final Map<String, String> _activityLabels = {
    'sedentary': '좌식 생활',
    'light': '가벼운 활동',
    'moderate': '중간 활동',
    'active': '활동적',
    'very_active': '매우 활동적',
  };

  @override
  void initState() {
    super.initState();
    // 입력 필드 변경 시 아바타 실시간 업데이트를 위한 리스너 추가
    _heightController.addListener(_updateAvatarPreview);
    _weightController.addListener(_updateAvatarPreview);
  }

  @override
  void dispose() {
    _heightController.removeListener(_updateAvatarPreview);
    _weightController.removeListener(_updateAvatarPreview);
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  /// 아바타 미리보기 업데이트
  void _updateAvatarPreview() {
    setState(() {});
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        height: double.parse(_heightController.text),
        initialWeight: double.parse(_weightController.text),
        gender: _selectedGender,
        age: int.parse(_ageController.text),
        activityLevel: _selectedActivityLevel,
      );

      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.saveUserProfile(profile);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 설정')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo/logowind.jpeg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '환영합니다!',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '건강 관리를 시작하기 위해 기본 정보를 입력해주세요',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 이름 (선택사항)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '이름 (선택사항)',
                    hintText: '예: 홍길동',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                // 키
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '키 (cm)',
                    hintText: '예: 170',
                    prefixIcon: Icon(Icons.height),
                    suffixText: 'cm',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '키를 입력해주세요';
                    }
                    final height = double.tryParse(value);
                    if (height == null || height < 50 || height > 250) {
                      return '올바른 키를 입력해주세요 (50-250cm)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 체중
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '현재 체중 (kg)',
                    hintText: '예: 70',
                    prefixIcon: Icon(Icons.monitor_weight),
                    suffixText: 'kg',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '체중을 입력해주세요';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 20 || weight > 300) {
                      return '올바른 체중을 입력해주세요 (20-300kg)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 아바타 미리보기
                Center(
                  child: Column(
                    children: [
                      Text(
                        '나의 아바타 미리보기',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildAvatarPreview(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 나이
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '나이',
                    hintText: '예: 30',
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixText: '세',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '나이를 입력해주세요';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 1 || age > 120) {
                      return '올바른 나이를 입력해주세요 (1-120세)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 성별 선택
                Text('성별', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _genders.map((gender) {
                    return ChoiceChip(
                      label: Text(_genderLabels[gender]!),
                      selected: _selectedGender == gender,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedGender = gender);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 활동 수준 선택
                Text(
                  '일일 활동 수준',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Column(
                  children: _activityLevels.map((level) {
                    return RadioListTile<String>(
                      title: Text(_activityLabels[level]!),
                      subtitle: _getActivityDescription(level),
                      value: level,
                      groupValue: _selectedActivityLevel,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedActivityLevel = value);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('프로필 저장 및 시작'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 아바타 미리보기 위젯 생성
  Widget _buildAvatarPreview() {
    // 입력값 검증 및 기본값 설정
    final height = double.tryParse(_heightController.text) ?? 170.0;
    final weight = double.tryParse(_weightController.text) ?? 60.0;
    final age = int.tryParse(_ageController.text) ?? 30;

    // AppProvider 통합 헬퍼 메서드 사용
    return Provider.of<AppProvider>(
      context,
      listen: false,
    ).buildAvatarPreviewWidget(
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      height: height,
      weight: weight,
      gender: _selectedGender,
      age: age,
      activityLevel: _selectedActivityLevel,
    );
  }

  Widget _getActivityDescription(String level) {
    switch (level) {
      case 'sedentary':
        return const Text('대부분 앉아서 생활 (사무직 등)');
      case 'light':
        return const Text('가벼운 운동이나 일상 활동');
      case 'moderate':
        return const Text('중간 정도의 운동 (주 3-5회)');
      case 'active':
        return const Text('활동적인 생활 (주 6-7회 운동)');
      case 'very_active':
        return const Text('매우 활동적 (하루 2회 이상 운동)');
      default:
        return const Text('');
    }
  }
}
