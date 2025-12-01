import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/data_migration_service.dart';
import '../services/calorie_state_calculator.dart';
import '../services/background_calorie_service.dart';
import '../services/health_data_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/advanced_avatar_widget.dart';
import '../avatar/body_measurements.dart';
import '../avatar/avatar_animations.dart';
import '../avatar/face_expressions.dart';
import '../avatar/clothing_colors.dart';
import '../avatar/body_poses.dart';
import 'dart:developer' as developer;

class AppProvider with ChangeNotifier, WidgetsBindingObserver {
  UserProfile? _userProfile;
  
  // 칼로리 관리 (개선된 구조)
  double _intakeCalories = 0.0;              // 섭취 칼로리 (식사)
  double _exerciseBurnedCalories = 0.0;      // 운동 소모 칼로리
  int _exerciseTotalMinutes = 0;             // 오늘 총 운동 시간(분)
  
  // 목표 설정 (신체 데이터 기반 동적 계산)
  double _tdeeCalories = 0.0;             // 계산된 TDEE (유지) - 초기화 시 계산
  double _goalCalories = 0.0;             // 사용자 목표 - 초기화 시 설정
  String _calorieMode = 'maintain';       // maintain/loss/bulk
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // 날짜 변경 감지용
  DateTime _lastCheckedDate = DateTime.now();
  Timer? _midnightTimer; // 자정 체크용 타이머
  Timer? _tdeeUpdateTimer; // TDEE 갱신용 타이머 (1분마다)
  
  // 알림 Hysteresis (과식 경고)
  DateTime? _lastOverLimitNotificationTime;
  
  static const String _keyLastUpdate = 'calorie_last_update_ms';
  static const String _keyCurrentCalories = 'calorie_current_value';
  static const String _keyCalorieMode = 'calorie_mode';
  static const String _keyGoalCalories = 'goal_calories';
  
  // 아바타 상태
  AvatarAnimationType _currentAnimationType = AvatarAnimationType.idle;
  FaceExpressionType _currentExpression = FaceExpressionType.neutral;
  BodyPose _currentPose = BodyPose.neutral;
  
  // 자동 표정 로테이션
  Timer? _expressionTimer;
  final bool _autoRotationEnabled = true;
  
  // 플래시 효과 이벤트
  String? _flashEvent; // 'food' 또는 'exercise'

  // Getters
  UserProfile? get userProfile => _userProfile;
  
  // 기본 칼로리 값 (기존 호환성)
  double get currentCalories => _intakeCalories;              // 섭취
  double get currentBurnedCalories => _exerciseBurnedCalories; // 운동
  double get dailyCalorieGoal => _goalCalories;                // 목표
  
  // 새로운 칼로리 계산
  double get tdeePerMinute => _tdeeCalories / 1440;
  
  /// TDEE 기반 시간 소모 (운동 시간 제외)
  double get tdeeBurnedCalories {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final elapsedMinutes = now.difference(startOfDay).inMinutes;
    
    // 경과 시간 - 운동 시간 = 순수 일상 활동 시간
    final activeMinutes = max(0, elapsedMinutes - _exerciseTotalMinutes);
    return tdeePerMinute * activeMinutes;
  }
  
  /// 총 소모 칼로리 (운동 + TDEE)
  double get totalBurnedCalories => _exerciseBurnedCalories + tdeeBurnedCalories;
  
  /// 잔여 칼로리 (더 먹을 수 있는 양)
  /// = 목표 - 섭취 + (운동 + TDEE 소모)
  double get remainingCalories => _goalCalories - _intakeCalories + totalBurnedCalories;
  
  /// 순 칼로리 (체중 증감 예측용)
  double get netCalories => _intakeCalories - totalBurnedCalories;
  
  // 기존 호환성
  double get totalCalories => _intakeCalories;
  double get calorieProgress => _intakeCalories / _goalCalories;
  
  // 상태
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isProfileComplete => _userProfile != null;
  String get calorieMode => _calorieMode;
  AvatarAnimationType get currentAnimationType => _currentAnimationType;
  FaceExpressionType get currentExpression => _currentExpression;
  BodyPose get currentPose => _currentPose;
  String? get flashEvent => _flashEvent; // 플래시 이벤트
  
  // BMI 관련
  double get bmi => _userProfile?.getBMI() ?? 0.0;
  String get bmiCategory => _userProfile?.getBMICategory() ?? 'unknown';
  
  // 칼로리 상태
  bool get isOverCalorieLimit => _intakeCalories > _goalCalories;
  bool get isNearLimit => _intakeCalories > _goalCalories * 0.8;

  // 초기화
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Lifecycle observer 등록
    WidgetsBinding.instance.addObserver(this);
    _lastCheckedDate = DateTime.now();

    try {
      await NotificationService().initialize();
      await Hive.initFlutter();
      
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserProfileAdapter());
      }

      var box = await Hive.openBox<UserProfile>('userProfile');
      await DataMigrationService.migrateUserProfiles(box);
      
      _userProfile = box.get('profile');

      if (_userProfile != null) {
        // TDEE 계산
        _tdeeCalories = _userProfile!.getEnhancedTDEE();
        
        // 저장된 목표 및 모드 로드
        final prefs = await SharedPreferences.getInstance();
        _calorieMode = prefs.getString(_keyCalorieMode) ?? 'maintain';
        
        // 저장된 목표가 있으면 사용, 없으면 TDEE 기본값
        if (prefs.containsKey(_keyGoalCalories)) {
          _goalCalories = prefs.getDouble(_keyGoalCalories)!;
        } else {
          _goalCalories = _tdeeCalories;
        }
        
        await _scheduleWeightCheckReminder();
        
        developer.log('✅ 프로필 로드: ${_userProfile!.name}');
        developer.log('   TDEE: ${_tdeeCalories.toInt()} kcal');
        developer.log('   목표: ${_goalCalories.toInt()} kcal ($_calorieMode 모드)');
      }

      await _loadTodayCalories();
      
      // 헬스 데이터 동기화
      syncHealthData();
      
      // 백그라운드 서비스 초기화
      await _initializeBackgroundService();

      // 자정 체크 타이머 시작
      _scheduleMidnightCheck();
      
      // TDEE 갱신 타이머 시작 (1분마다 UI 업데이트)
      _startTDEEUpdateTimer();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = '초기화 오류: $e';
      developer.log('❌ 초기화 실패: $e');
    } finally {
      // ✅ 웰컴 그리팅: notifyListeners 이전에 greeting 상태로 설정
      developer.log('=== 웰컴 그리팅 설정 시작 ===');
      _currentExpression = FaceExpressionType.greeting;
      _currentPose = BodyPose.greeting;
      developer.log('✅ 표정 설정: ${_currentExpression.toString()}');
      developer.log('✅ 포즈 설정: ${_currentPose.toString()}');
      resetExpressionTimer(); // 자동 로테이션 일시 중지
      
      _isLoading = false;
      notifyListeners(); // 이제 greeting 상태로 UI 업데이트됨
      
      developer.log('👋 웰컴 그리팅 시작 (초기화 완료) - 3초 대기 중...');
      
      // 3초 후 정상 상태로 복귀
      Future.delayed(const Duration(seconds: 3), () {
        if (_isDisposed) return; // 안전장치
        developer.log('⏰ 3초 경과 - 웰컴 그리팅 종료, 상태 복귀 시작');
        _updateAvatarByCalorieStatus();
        startAutoExpressionRotation();
        developer.log('=== 웰컴 그리팅 종료 ===');
      });
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _expressionTimer?.cancel();
    _midnightTimer?.cancel();
    _tdeeUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 백그라운드 진입 시 필요한 작업
    } else if (state == AppLifecycleState.resumed) {
      _checkDateChange();
      
      // 데이터 새로고침
      _loadTodayCalories();
      notifyListeners();
    }
  }

  // 날짜 변경 확인 및 데이터 리로드
  Future<void> _checkDateChange() async {
    final now = DateTime.now();
    if (now.day != _lastCheckedDate.day || 
        now.month != _lastCheckedDate.month || 
        now.year != _lastCheckedDate.year) {
      
      developer.log('📅 날짜 변경 감지: ${_lastCheckedDate.toString()} -> ${now.toString()}');
      _lastCheckedDate = now;
      
      // 날짜가 바뀌면 데이터 리로드 (새로운 날의 데이터는 0부터 시작)
      await _loadTodayCalories();
      notifyListeners();
    }
  }

  // 자정 체크 예약
  void _scheduleMidnightCheck() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1); // 내일 00:00
    final duration = tomorrow.difference(now);
    
    _midnightTimer?.cancel(); // 기존 타이머 취소
    _midnightTimer = Timer(duration, () {
      developer.log('🌙 자정 도달 - 칼로리 초기화 실행');
      _checkDateChange(); // 날짜 변경 체크 및 초기화
      _scheduleMidnightCheck(); // 다음 자정 예약
    });
  }

  // TDEE 갱신 타이머 시작
  void _startTDEEUpdateTimer() {
    _tdeeUpdateTimer?.cancel();
    
    // 1분마다 UI 업데이트 (TDEE는 시간 경과에 따라 변함)
    _tdeeUpdateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        // 값은 getter에서 계산되므로 알림만 보내면 됨
        notifyListeners();
        // developer.log('🔄 TDEE 업데이트: ${tdeeBurnedCalories.toInt()} kcal');
      },
    );
  }

  // 의상 색상 업데이트
  Future<void> updateClothingColors(ClothingColors colors) async {
    if (_userProfile == null) return;
    
    // toJson()은 Map<String, dynamic>을 반환하므로 Map<String, int>로 변환
    final colorMap = <String, int>{
      'braColor': colors.braColor.value,
      'tightsColor': colors.tightsColor.value,
    };
    
    final updatedProfile = _userProfile!.copyWith(clothingColors: colorMap);
    await saveUserProfile(updatedProfile);
  }
  Future<void> updateWeight(double newWeight) async {
    if (_userProfile == null) return;
    
    final updatedProfile = _userProfile!.copyWith(initialWeight: newWeight);
    await saveUserProfile(updatedProfile);
    await saveUserProfile(updatedProfile);
  }

  // 목표 칼로리 및 모드 업데이트
  Future<void> updateCalorieGoal(double goal, String mode) async {
    _goalCalories = goal;
    _calorieMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyGoalCalories, goal);
    await prefs.setString(_keyCalorieMode, mode);
    
    notifyListeners();
    developer.log('🎯 목표 업데이트: ${goal.toInt()} kcal ($mode)');
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();

    try {
      var box = await Hive.openBox<UserProfile>('userProfile');
      await box.put('profile', profile);
      _userProfile = profile;
      
      // TDEE 계산 및 저장
      _tdeeCalories = profile.getEnhancedTDEE();
      _goalCalories = _tdeeCalories; // 기본값은 TDEE로 설정
      
      // SharedPreferences에 프로필 데이터 저장 (백그라운드 작업용)
      await _saveUserProfileToPrefs(profile);
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '프로필 저장 오류: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 오늘 칼로리 로드 (섭취 + 소비 + 운동 시간)
  Future<void> _loadTodayCalories() async {
    try {
      String today = DateTime.now().toIso8601String().split('T')[0];
      
      // 섭취 및 운동 칼로리
      _intakeCalories = await DatabaseService().getTotalCaloriesForDate(today);
      _exerciseBurnedCalories = await DatabaseService().getTotalBurnedCaloriesForDate(today);
      
      // 오늘 총 운동 시간 계산
      final exerciseRecords = await DatabaseService().getExerciseRecordsForDate(today);
      _exerciseTotalMinutes = exerciseRecords.fold<int>(
        0,
        (sum, record) => sum + (record['duration_minutes'] as int? ?? 0),
      );
      
      developer.log('📊 칼로리 로드: 섭취 ${_intakeCalories.toInt()}, 운동 ${_exerciseBurnedCalories.toInt()}, 운동시간 $_exerciseTotalMinutes분');
      
      // 🎭 칼로리 로드 후 아바타 상태 업데이트
      _updateAvatarByCalorieStatus();
    } catch (e) {
      _errorMessage = '데이터 로드 오류: $e';
      developer.log('❌ 칼로리 로드 실패: $e');
    }
  }

  // 음식 섭취 추가
  Future<void> addFoodIntake(int foodId, double quantity, double calories) async {
    try {
      developer.log('🍔 음식 추가 시작: $calories kcal');
      await DatabaseService().addFoodIntake(foodId, quantity, calories);
      _intakeCalories += calories;
      
      developer.log('📊 현재 섭취: $_intakeCalories / 목표: $_goalCalories');
      
      // 🎭 음식 섭취 시 아바타 반응
      _updateAvatarByCalorieStatus();
      
      // 플래시 효과 트리거
      _flashEvent = 'food';
      notifyListeners();
      
      // 플래시 이벤트 초기화
      await Future.delayed(const Duration(milliseconds: 300));
      _flashEvent = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = '음식 추가 오류: $e';
      developer.log('❌ 음식 추가 실패: $e');
      notifyListeners();
    }
  }

  /// 🎭 칼로리 상태별 아바타 자동 업데이트
  void _updateAvatarByCalorieStatus() {
    developer.log('🎭 아바타 상태 업데이트 시작');
    
    if (_goalCalories == 0) {
      developer.log('⚠️ 목표 칼로리가 0입니다. 임시 값(2000)으로 설정하여 진행합니다.');
      _goalCalories = 2000.0; // 안전장치
    }
    
    final percentage = _intakeCalories / _goalCalories;
    developer.log('📊 섭취 비율: ${(percentage * 100).toStringAsFixed(1)}% ($_intakeCalories / $_goalCalories)');
    
    FaceExpressionType newExpression;
    BodyPose newPose;

    // 🟢 이상적 범위 (80-100%)
    if (percentage >= 0.8 && percentage <= 1.0) {
      developer.log('🟢 이상적 범위 감지');
      newExpression = FaceExpressionType.satisfied;
      newPose = BodyPose.cheer;
      developer.log('😊 만족 - 칼로리 달성! 환호하는 아바타');
    }
    // 🔴 과식 (120% 초과)
    else if (percentage > 1.2) {
      developer.log('🔴 과식 범위 감지');
      newExpression = FaceExpressionType.stuffed;
      newPose = BodyPose.bendForward;
      developer.log('😰 과식 - 힘들어하는 아바타');
    }
    // 😔 낮은 칼로리 (50% 미만)
    else if (percentage < 0.5) {
      developer.log('💙 저칼로리 범위 감지');
      newExpression = FaceExpressionType.hungry;
      newPose = BodyPose.touchBelly;
      developer.log('😔 에너지 부족 - 배고픈 아바타');
    }
    // 🙂 보통 범위 (50-80%)
    else {
      developer.log('⚪ 보통 범위 감지');
      newExpression = FaceExpressionType.neutral;
      newPose = BodyPose.neutral;
      developer.log('🙂 보통 상태 - 중립 아바타');
    }

    // 상태 변경이 있을 때만 업데이트
    if (_currentExpression != newExpression || _currentPose != newPose) {
      _currentExpression = newExpression;
      _currentPose = newPose;
      
      // 수동 변경이 아니므로 타이머 리셋은 하지 않음 (자동 로테이션 흐름 유지)
      notifyListeners();
    }
  }
  
  /// 💪 운동 완료 시 아바타 축하 반응
  Future<void> celebrateExercise() async {
    setExpression(FaceExpressionType.satisfied);
    setPose(BodyPose.armsUp);
    developer.log('💪 운동 완료 - 뿌듯한 아바타');
    
    // 플래시 효과 트리거
    _flashEvent = 'exercise';
    notifyListeners();
    
    // 3초 후 정상 상태로 복귀
    await Future.delayed(const Duration(seconds: 3));
    _flashEvent = null;
    _updateAvatarByCalorieStatus();
  }
  
  /// 🎉 목표 달성 시 아바타 축하 반응
  Future<void> celebrateGoalAchievement() async {
    setExpression(FaceExpressionType.happy);
    setPose(BodyPose.cheer);
    developer.log('🎉 목표 달성 - 환호하는 아바타');
    
    // 5초 후 정상 상태로 복귀
    await Future.delayed(const Duration(seconds: 5));
    _updateAvatarByCalorieStatus();
  }

  // 히스토리 요약 데이터 가져오기 (단일 - 오늘/어제 등)
  Future<Map<String, dynamic>> getHistorySummary() async {
    try {
      final summaries = await DatabaseService().getDailySummaries(limit: 1);
      if (summaries.isNotEmpty) {
        return summaries.first;
      }
      return {'total_days': 0, 'avg_calories': 0.0};
    } catch (e) {
      developer.log('히스토리 요약 로드 오류: $e');
      return {'total_days': 0, 'avg_calories': 0.0};
    }
  }

  // 히스토리 목록 가져오기 (복수)
  Future<List<Map<String, dynamic>>> getHistorySummaries({int limit = 30}) async {
    try {
      return await DatabaseService().getDailySummaries(limit: limit);
    } catch (e) {
      developer.log('히스토리 목록 로드 오류: $e');
      return [];
    }
  }

  // 아바타 관련 메서드
  Widget buildAvatarWidget({double? height, double? width}) {
    if (_userProfile == null) {
      return const SizedBox();
    }
    
    // 현재 상태에 따른 아바타 렌더링
    return AdvancedAvatarWidget(
      bmi: bmi,
      height: _userProfile!.height,
      gender: _userProfile!.gender,
      lifestyle: _mapActivityLevelToLifestylePattern(_userProfile!.activityLevel),
      expression: _currentExpression,
      pose: _currentPose,
      clothingColors: _userProfile!.getClothingColors(),
    );
  }

  // 표정 설정
  void setExpression(FaceExpressionType expression, {bool autoReturn = false}) {
    _currentExpression = expression;
    notifyListeners();

    if (autoReturn) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_currentExpression == expression) {
          _currentExpression = FaceExpressionType.neutral;
          notifyListeners();
        }
      });
    }

    // 🔧 수동으로 표정을 설정할 때는 자동 로테이션 일시 중지
    resetExpressionTimer();
  }

  // 포즈 설정
  void setPose(BodyPose pose, {bool autoReturn = false}) {
    _currentPose = pose;
    notifyListeners();

    if (autoReturn) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_currentPose == pose) {
          _currentPose = BodyPose.neutral;
          notifyListeners();
        }
      });
    }
    
    // 🔧 수동으로 포즈를 설정할 때는 자동 로테이션 일시 중지
    resetExpressionTimer();
  }

  // 자동 표정 로테이션 시작
  void startAutoExpressionRotation() {
    if (!_autoRotationEnabled) return;
    _expressionTimer?.cancel();
    _scheduleNextExpression();
  }

  void resetExpressionTimer() {
    _expressionTimer?.cancel();
  }

  /// 웰컴 그리팅 트리거 (홈 화면 진입 시 호출)
  void triggerWelcomeGreeting() {
    developer.log('=== 홈 화면 진입 - 웰컴 그리팅 시작 ===');
    
    // 현재 표정/포즈를 greeting으로 변경
    _currentExpression = FaceExpressionType.greeting;
    _currentPose = BodyPose.greeting;
    developer.log('✅ 표정 설정: ${_currentExpression.toString()}');
    developer.log('✅ 포즈 설정: ${_currentPose.toString()}');
    
    // 자동 로테이션 일시 중지
    resetExpressionTimer();
    
    notifyListeners();
    
    developer.log('👋 웰컴 그리팅 표시 중 - 3초 대기...');
    
    // 3초 후 정상 상태로 복귀
    Future.delayed(const Duration(seconds: 3), () {
      if (_isDisposed) return;
      developer.log('⏰ 3초 경과 - 웰컴 그리팅 종료, 상태 복귀');
      _updateAvatarByCalorieStatus();
      startAutoExpressionRotation();
      developer.log('=== 웰컴 그리팅 종료 ===');
    });
  }

  void _scheduleNextExpression() {
    if (!_autoRotationEnabled) return;
    
    final seconds = 5 + Random().nextInt(11);
    _expressionTimer = Timer(Duration(seconds: seconds), () {
      _rotateExpression();
      _scheduleNextExpression();
    });
  }

  void _rotateExpression() {
    // ✅ greeting 중이면 로테이션 하지 않음 (웰컴 그리팅 보호)
    if (_currentPose == BodyPose.greeting) {
      developer.log('👋 greeting 상태이므로 자동 로테이션 건너뜀');
      return;
    }
    
    final calorieState = CalorieStateCalculator.getState(
      _intakeCalories, _goalCalories);
    final currentBMI = bmi;

    final expressionList = CalorieStateCalculator
        .getExpressionRotationListWithBMI(calorieState, currentBMI);

    final currentIndex = expressionList.indexOf(_currentExpression);
    FaceExpressionType nextExpression;
    
    if (currentIndex == -1 || currentIndex >= expressionList.length - 1) {
      nextExpression = expressionList.first;
    } else {
      nextExpression = expressionList[currentIndex + 1];
    }

    // 표정 변경
    _currentExpression = nextExpression;
    
    // 포즈도 상태에 맞게 업데이트
    _currentPose = CalorieStateCalculator.getRecommendedPose(calorieState, currentBMI);
    
    notifyListeners();
  }

  // 헬퍼 메서드들
  LifestylePattern _mapActivityLevelToLifestylePattern(String activityLevel) {
    switch (activityLevel) {
      case 'sedentary': return LifestylePattern.sedentary;
      case 'very_active': return LifestylePattern.athletic;
      default: return LifestylePattern.active;
    }
  }

  Future<void> _scheduleWeightCheckReminder() async {
    try {
      await NotificationService().scheduleWeightCheckReminder(
        hour: 8, minute: 0);
    } catch (e) {
      _errorMessage = '알림 예약 오류: $e';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadTodayCalories();
    notifyListeners();
  }

  // 헬퍼 메서드들
  String getGenderFromProvider() {
    return _userProfile?.gender ?? 'female';
  }

  double getHeightFromProvider() {
    return _userProfile?.height ?? 170.0;
  }

  double getWeightFromProvider() {
    return _userProfile?.initialWeight ?? 60.0;
  }

  // Convenience Getters
  double get weight => _userProfile?.initialWeight ?? 60.0;
  double get height => _userProfile?.height ?? 170.0;
  int get age => _userProfile?.age ?? 25;
  String get gender => _userProfile?.gender ?? 'female';

  void setAnimationType(AvatarAnimationType animationType) {
    _currentAnimationType = animationType;
    notifyListeners();
  }

  /// 축하 애니메이션 트리거 (칼로리 목표 달성 시 등)
  void triggerCeremony() {
    // 칼로리 상태에 따라 적절한 표정과 포즈 설정
    final calorieStatus = CalorieStateCalculator.getState(_intakeCalories, _goalCalories);
    
    if (calorieStatus == CalorieState.optimal || calorieStatus == CalorieState.achieved) {
      // 이상적인 칼로리 섭취 - 기쁜 표정
      setExpression(FaceExpressionType.happy, autoReturn: true);
      setPose(BodyPose.armsUp, autoReturn: true);
    } else if (calorieStatus == CalorieState.veryLow || calorieStatus == CalorieState.low) {
      // 너무 적게 섭취 - 배고픈 표정
      setExpression(FaceExpressionType.hungry, autoReturn: true);
      setPose(BodyPose.touchBelly, autoReturn: true);
    } else if (calorieStatus == CalorieState.exceeded || calorieStatus == CalorieState.excessive) {
      // 과다 섭취 - 거부 표정
      setExpression(FaceExpressionType.refuse, autoReturn: true);
      setPose(BodyPose.refuse, autoReturn: true);
    }
  }

  Widget buildAvatarPreviewWidget({
    String? name,
    double? height,
    double? weight,
    String? gender,
    int? age,
    String? activityLevel,
  }) {
    final previewHeight = height ?? 170.0;
    final previewWeight = weight ?? 60.0;
    final previewGender = gender ?? 'female';
    final previewActivityLevel = activityLevel ?? 'moderate';
    final previewBMI = previewWeight / ((previewHeight / 100) * (previewHeight / 100));

    return AdvancedAvatarWidget(
      bmi: previewBMI,
      height: previewHeight,
      gender: previewGender,
      lifestyle: _mapActivityLevelToLifestylePattern(previewActivityLevel),
    );
  }
  
  // ========== Phase 3: 백그라운드 서비스 ==========
  
  /// 백그라운드 서비스 초기화
  Future<void> _initializeBackgroundService() async {
    try {
      await BackgroundCalorieService.initialize();
      
      // 프로필이 있으면 데이터 저장
      if (_userProfile != null) {
        await _saveUserProfileToPrefs(_userProfile!);
        
        // 현재 목표 칼로리도 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('daily_calorie_goal', _goalCalories);
      }
      
      developer.log('✅ 백그라운드 서비스 초기화 완료');
    } catch (e) {
      developer.log('❌ 백그라운드 서비스 초기화 실패: $e');
    }
  }
  
  /// 사용자 프로필을 SharedPreferences에 저장
  Future<void> _saveUserProfileToPrefs(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('user_weight', profile.initialWeight);
      await prefs.setDouble('user_height', profile.height);
      await prefs.setInt('user_age', profile.age);
      await prefs.setString('user_gender', profile.gender);
      await prefs.setString('user_activity_level', profile.activityLevel);
    } catch (e) {
      developer.log('프로필 저장 오류: $e');
    }
  }
  
  // ========== Phase 4: 헬스 데이터 통합 ==========
  
  /// Health Connect/HealthKit 데이터 동기화
  Future<void> syncHealthData() async {
    try {
      developer.log('🔄 헬스 데이터 동기화 시작...');
      
      final healthService = HealthDataService();
      
      // 권한 확인 (권한이 없으면 동기화 시도하지 않음)
      final hasPermission = await healthService.hasPermissions();
      if (!hasPermission) {
        developer.log('ℹ️ 헬스 데이터 권한 없음 (동기화 건너뜀)');
        return;
      }
      
      // 데이터 동기화
      final syncedCount = await healthService.syncToDatabase();
      
      // 오늘의 칼로리 데이터 새로고침 (섭취 + 소모)
      await _loadTodayCalories();
      
      if (syncedCount > 0) {
        developer.log('✅ 헬스 데이터 동기화 완료: $syncedCount개');
        notifyListeners(); // 데이터 변경 알림
      }
    } catch (e) {
      developer.log('❌ 헬스 데이터 동기화 실패: $e');
    }
  }
}
