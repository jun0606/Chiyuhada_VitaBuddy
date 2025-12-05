import 'package:health/health.dart';
import 'dart:developer' as developer;
import 'database_service.dart';

/// 헬스 데이터 통합 서비스
/// 
/// Android Health Connect와 iOS HealthKit을 통합하여
/// 운동 데이터를 가져오고 데이터베이스에 동기화합니다.
class HealthDataService {
  final Health _healthPlugin = Health();
  
  /// 지원하는 헬스 데이터 타입
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.DISTANCE_DELTA,
  ];
  
  /// 헬스 데이터 접근 권한 요청
  /// 
  /// Android: Health Connect 권한
  /// iOS: HealthKit 권한
  Future<bool> requestPermissions() async {
    try {
      developer.log('🔐 헬스 데이터 권한 요청 중...');
      
      // 읽기 권한
      final types = _dataTypes;
      
      // 쓰기 권한 (운동 기록 저장용)
      final permissions = [
        HealthDataAccess.READ,
        HealthDataAccess.WRITE,
      ];
      
      // 권한 요청
      bool? hasPermissions = await _healthPlugin.hasPermissions(
        types,
        permissions: permissions,
      );
      
      // 이미 권한이 있는 경우
      if (hasPermissions == true) {
        developer.log('✅ 헬스 데이터 권한이 이미 허용됨');
        return true;
      }
      
      // 권한 요청
      final requested = await _healthPlugin.requestAuthorization(
        types,
        permissions: permissions,
      );
      
      if (requested) {
        developer.log('✅ 헬스 데이터 권한 허용됨');
      } else {
        developer.log('❌ 헬스 데이터 권한 거부됨');
      }
      
      return requested;
    } catch (e) {
      developer.log('❌ 권한 요청 실패: $e');
      return false;
    }
  }
  
  /// 헬스 데이터 권한 확인
  Future<bool> hasPermissions() async {
    try {
      final types = _dataTypes;
      final permissions = [
        HealthDataAccess.READ,
        HealthDataAccess.WRITE,
      ];
      
      bool? hasPermissions = await _healthPlugin.hasPermissions(
        types,
        permissions: permissions,
      );
      
      return hasPermissions ?? false;
    } catch (e) {
      developer.log('❌ 권한 확인 실패: $e');
      return false;
    }
  }
  
  /// 오늘 걸음 수 가져오기
  Future<int> getTodaySteps() async {
    try {
      developer.log('👣 오늘 걸음 수 조회 중...');
      
      // 오늘 자정부터 현재까지
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // 걸음 수 데이터 조회
      final types = [HealthDataType.STEPS];
      final healthData = await _healthPlugin.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: types,
      );
      
      // 걸음 수 합산
      int totalSteps = 0;
      for (var data in healthData) {
        if (data.value is NumericHealthValue) {
          totalSteps += (data.value as NumericHealthValue).numericValue.toInt();
        }
      }
      
      developer.log('✅ 오늘 걸음 수: $totalSteps');
      return totalSteps;
    } catch (e) {
      developer.log('❌ 걸음 수 조회 실패: $e');
      return 0;
    }
  }
  
  /// 오늘 칼로리 소모량 가져오기
  Future<double> getTodayCaloriesBurned() async {
    try {
      developer.log('🔥 오늘 칼로리 소모량 조회 중...');
      
      // 오늘 자정부터 현재까지
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // 칼로리 데이터 조회
      final types = [HealthDataType.ACTIVE_ENERGY_BURNED];
      final healthData = await _healthPlugin.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: types,
      );
      
      // 칼로리 합산
      double totalCalories = 0.0;
      for (var data in healthData) {
        if (data.value is NumericHealthValue) {
          totalCalories += (data.value as NumericHealthValue).numericValue;
        }
      }
      
      developer.log('✅ 오늘 칼로리 소모: ${totalCalories.toInt()} kcal');
      return totalCalories;
    } catch (e) {
      developer.log('❌ 칼로리 조회 실패: $e');
      return 0.0;
    }
  }
  
  /// 운동 세션 가져오기
  /// 
  /// [start]: 조회 시작 시간
  /// [end]: 조회 종료 시간
  Future<List<Map<String, dynamic>>> getWorkouts(
    DateTime start,
    DateTime end,
  ) async {
    try {
      developer.log('🏃 운동 세션 조회 중: $start ~ $end');
      
      // 운동 데이터 조회
      final types = [HealthDataType.WORKOUT];
      final healthData = await _healthPlugin.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: types,
      );
      
      // 운동 세션 파싱
      List<Map<String, dynamic>> workouts = [];
      for (var data in healthData) {
        if (data.value is WorkoutHealthValue) {
          final workout = data.value as WorkoutHealthValue;
          workouts.add({
            'id': data.uuid,
            'type': workout.workoutActivityType.name,
            'start_time': data.dateFrom.toIso8601String(),
            'end_time': data.dateTo.toIso8601String(),
            'duration_minutes': data.dateTo.difference(data.dateFrom).inMinutes,
            'calories': workout.totalEnergyBurned ?? 0.0,
            'distance': workout.totalDistance ?? 0.0,
            'source': data.sourcePlatform.name,
          });
        }
      }
      
      developer.log('✅ 운동 세션 ${workouts.length}개 조회 완료');
      return workouts;
    } catch (e) {
      developer.log('❌ 운동 세션 조회 실패: $e');
      return [];
    }
  }
  
  /// 데이터베이스 동기화
  /// 
  /// Health Connect/HealthKit의 운동 데이터를 로컬 데이터베이스에 동기화합니다.
  /// 중복 방지를 위해 external_id를 사용합니다.
  Future<int> syncToDatabase() async {
    try {
      developer.log('🔄 헬스 데이터 동기화 시작...');
      
      // 1. 마지막 동기화 시간 확인 (기본: 최근 7일)
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      // 2. 운동 세션 가져오기
      final workouts = await getWorkouts(sevenDaysAgo, now);
      
      if (workouts.isEmpty) {
        developer.log('ℹ️ 동기화할 운동 데이터가 없습니다.');
        return 0;
      }
      
      // 3. DatabaseService import 및 초기화
      final DatabaseService dbService = DatabaseService();
      
      // 4. 중복 체크 및 저장
      int savedCount = 0;
      int skippedCount = 0;
      
      for (var workout in workouts) {
        final externalId = workout['id'] as String;
        
        // 중복 확인
        final isDuplicate = await dbService.checkExerciseDuplicate(externalId);
        
        if (isDuplicate) {
          developer.log('⏭️ 이미 동기화된 운동: $externalId');
          skippedCount++;
          continue;
        }
        
        // DB에 저장
        try {
          await dbService.insertExerciseFromHealth(workout);
          savedCount++;
          developer.log('✅ 저장 완료: ${workout['type']} (${workout['duration_minutes']}분, ${workout['calories'].toInt()}kcal)');
        } catch (e) {
          developer.log('❌ 저장 실패: $externalId - $e');
        }
      }
      
      developer.log('📝 동기화 완료: $savedCount개 저장, $skippedCount개 건너뜀 (총 ${workouts.length}개)');
      
      return savedCount;
    } catch (e) {
      developer.log('❌ 동기화 실패: $e');
      return 0;
    }
  }
}
