import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'database_service.dart';
import 'package:chiyuhada_vita_buddy/models/workout_data.dart';

/// 헬스 데이터 통합 서비스
///
/// Android Health Connect와 iOS HealthKit을 통합하여
/// 운동 데이터를 가져오고 데이터베이스에 동기화합니다.
///
/// 플랫폼별 지원:
/// - Android: Health Connect API
/// - iOS: HealthKit API
class HealthDataService {
  static const MethodChannel _platform = MethodChannel(
    'com.example.health_connect',
  );

  /// 플랫폼 확인 헬퍼
  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;

  /// Health Connect 앱 설치 상태 확인 (1: 설치됨, 2: 업데이트 필요, 0: 미설치)
  Future<int> checkHealthConnectStatus() async {
    developer.log('🔍 === Health Connect 상태 확인 시작 ===');

    try {
      final dynamic response = await _platform.invokeMethod(
        'isHealthConnectInstalled',
      );
      developer.log('✅ MethodChannel 응답 받음: $response');

      if (response is int) {
        return response;
      } else if (response is bool) {
        return response ? 1 : 0;
      }
      return 0;
    } catch (e) {
      developer.log('❌ 상태 확인 실패: $e');
      return 0;
    }
  }

  /// 기존 호환성을 위한 메서드
  Future<bool> isHealthConnectAvailable() async {
    final status = await checkHealthConnectStatus();
    return status == 1; // 1(설치됨)인 경우만 true 반환
  }

  /// 헬스 커넥트 설치/업데이트를 위해 플레이 스토어 열기
  Future<void> openHealthConnectStore() async {
    try {
      await _platform.invokeMethod('openHealthConnectStore');
    } catch (e) {
      developer.log('❌ 스토어 열기 실패: $e');
    }
  }

  /// 헬스 데이터 접근 권한 요청 (크로스플랫폼)
  Future<bool> requestPermissions() async {
    try {
      developer.log('🔐 헬스 데이터 권한 요청 시작 (플랫폼: ${isAndroid ? 'Android' : isIOS ? 'iOS' : 'Unknown'})');

      // 플랫폼별 권한 요청
      if (isAndroid) {
        return await _requestAndroidPermissions();
      } else if (isIOS) {
        return await _requestIOSPermissions();
      } else {
        developer.log('⚠️ 지원하지 않는 플랫폼');
        return false;
      }
    } catch (e) {
      developer.log('❌ 권한 요청 중 예외 발생: $e');
      return false;
    }
  }

  /// Android 권한 요청
  Future<bool> _requestAndroidPermissions() async {
    try {
      // 필수 권한: 활동 인식 (Android)
      final activityStatus = await Permission.activityRecognition.request();

      // 선택 권한: 신체 센서 (거부되어도 진행 허용)
      final bodySensorsStatus = await Permission.sensors.request();

      developer.log(
        '📋 Android 권한 요청 결과: 필수(활동인식)=${activityStatus.isGranted}, 선택(센서)=${bodySensorsStatus.isGranted}',
      );

      if (activityStatus.isGranted) {
        // OS 권한이 승인되면 실제 Health Connect 데이터 권한 요청
        developer.log('🔗 Android OS 권한 확보됨. Health Connect 데이터 권한 요청 시작');

        final healthConnectGranted = await requestHealthConnectPermissions();

        if (healthConnectGranted) {
          // 권한이 최종 승인되면 캐시 저장
          await _savePermissionCache(true);
          developer.log('💾 Android 모든 권한 확보 및 캐시 저장 완료');
          return true;
        } else {
          developer.log('⚠️ Health Connect 데이터 권한이 거부되었습니다.');
          return false;
        }
      }

      developer.log('⚠️ Android 필수 OS 권한(활동 인식)이 거부되었습니다.');
      return false;
    } catch (e) {
      developer.log('❌ Android 권한 요청 중 예외 발생: $e');
      return false;
    }
  }

  /// iOS 권한 요청
  Future<bool> _requestIOSPermissions() async {
    try {
      developer.log('🍎 iOS HealthKit 권한 요청 시작');

      // iOS에서는 MethodChannel을 통해 HealthKit 권한 요청
      final dynamic response = await _platform.invokeMethod('requestIOSHealthKitPermissions');

      bool isGranted = false;
      if (response is bool) {
        isGranted = response;
      }

      developer.log('📋 iOS 권한 요청 결과: $isGranted');

      if (isGranted) {
        // 권한 승인되면 캐시 저장
        await _savePermissionCache(true);
        await markPermissionRequested(); // ✅ 요청 이력 저장 (Optimistic Check용)
        developer.log('💾 iOS HealthKit 권한 확보 및 캐시 저장 완료');
        return true;
      } else {
        developer.log('⚠️ iOS HealthKit 권한이 거부되었습니다.');
        return false;
      }
    } catch (e) {
      developer.log('❌ iOS 권한 요청 중 예외 발생: $e');
      return false;
    }
  }

  /// 실제 헬스 커넥트 데이터 접근 권한 요청
  Future<bool> requestHealthConnectPermissions() async {
    try {
      developer.log('🚀 헬스 커넥트 데이터 권한 요청 (MethodChannel)');
      final dynamic response = await _platform.invokeMethod(
        'requestHealthConnectPermissions',
      );

      bool isGranted = false;
      if (response is bool) {
        isGranted = response;
      } else if (response is int) {
        isGranted = response == 1;
      }

      developer.log('✅ 헬스 커넥트 데이터 권한 결과: $isGranted');
      return isGranted;
    } catch (e) {
      developer.log('❌ 헬스 커넥트 데이터 권한 요청 실패: $e');
      return false;
    }
  }

  /// 헬스 데이터 권한 확인 (크로스플랫폼)
  Future<bool> hasPermissions() async {
    try {
      developer.log('🔍 헬스 데이터 권한 확인 중 (플랫폼: ${isAndroid ? 'Android' : isIOS ? 'iOS' : 'Unknown'})');

      if (isAndroid) {
        return await _hasAndroidPermissions();
      } else if (isIOS) {
        return await _hasIOSPermissions();
      } else {
        developer.log('⚠️ 지원하지 않는 플랫폼');
        return false;
      }
    } catch (e) {
      developer.log('❌ 권한 확인 실패: $e');
      return false;
    }
  }

  /// Android 권한 확인
  Future<bool> _hasAndroidPermissions() async {
    try {
      // 1. OS 레벨 권한 확인 (활동 인식 필수)
      final activityStatus = await Permission.activityRecognition.status;

      if (!activityStatus.isGranted) {
        developer.log('⚠️ Android 활동 인식 권한 없음');
        return false;
      }

      // 2. Health Connect 데이터 권한 확인
      developer.log('🔍 Android Health Connect 데이터 권한 상태 확인');
      final dynamic response = await _platform.invokeMethod(
        'getHealthConnectPermissionsStatus',
      );

      bool isDataGranted = false;
      if (response is bool) {
        isDataGranted = response;
      } else if (response is int) {
        isDataGranted = response == 1;
      }

      developer.log('✅ Android 최종 권한 확인 결과: OS=OK, Data=$isDataGranted');
      return isDataGranted;
    } catch (e) {
      developer.log('❌ Android 권한 확인 실패: $e');
      return false;
    }
  }

  /// iOS 권한 확인
  Future<bool> _hasIOSPermissions() async {
    try {
      developer.log('🍎 iOS HealthKit 권한 상태 확인');

      // iOS에서는 MethodChannel을 통해 HealthKit 권한 상태 확인
      final dynamic response = await _platform.invokeMethod(
        'getIOSHealthKitPermissionsStatus',
      );

      bool isGranted = false;
      if (response is bool) {
        isGranted = response;
      }

      // [iOS 특화 로직] Native 체크가 실패하더라도, 요청 이력이 있으면 권한이 있다고 가정(Optimistic Check)
      // 이유: iOS는 읽기 권한 상태를 알려주지 않으므로, 쓰기 권한이 없으면 무조건 false로 나옴
      if (!isGranted) {
        final hasRequestedBefore = await checkIfPermissionRequested();
        if (hasRequestedBefore) {
          developer.log(
            '⚠️ iOS Native 권한 확인 실패 -> 과거 요청 이력 기반으로 권한 있음(True) 처리 (Optimistic Check)',
          );
          return true;
        }
      }

      developer.log('✅ iOS HealthKit 권한 확인 결과: $isGranted');
      return isGranted;
    } catch (e) {
      developer.log('❌ iOS 권한 확인 실패: $e');
      return false;
    }
  }

  /// 권한 캐시 저장 헬퍼 메서드
  Future<void> _savePermissionCache(bool granted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('health_permission_granted', granted);
      await prefs.setInt(
        'health_permission_check_time',
        DateTime.now().millisecondsSinceEpoch,
      );
      await prefs.setString('health_platform', isAndroid ? 'android' : isIOS ? 'ios' : 'unknown');
      developer.log('💾 권한 캐시 저장 완료: $granted (플랫폼: ${isAndroid ? 'Android' : isIOS ? 'iOS' : 'Unknown'})');
    } catch (e) {
      developer.log('⚠️ 캐시 저장 실패: $e');
    }
  }

  /// 권한 요청 이력이 있는지 확인
  Future<bool> checkIfPermissionRequested() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('health_permission_requested_v1') ?? false;
    } catch (e) {
      developer.log('⚠️ 권한 요청 이력 확인 실패: $e');
      return false;
    }
  }

  /// 권한 요청 이력 저장 (다시 묻지 않음)
  Future<void> markPermissionRequested() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('health_permission_requested_v1', true);
      developer.log('💾 권한 요청 이력 저장 완료');
    } catch (e) {
      developer.log('⚠️ 권한 요청 이력 저장 실패: $e');
    }
  }

  /// 권한 캐시 초기화 (디버깅용)
  Future<void> clearPermissionCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('health_permission_granted');
      await prefs.remove('health_permission_check_time');
      await prefs.remove('health_platform');
      await prefs.remove('health_permission_requested_v1'); // 요청 이력도 초기화
      developer.log('🗑️ 권한 캐시 초기화 완료');
    } catch (e) {
      developer.log('⚠️ 캐시 초기화 실패: $e');
    }
  }

  /// 오늘 걸음 수 가져오기
  Future<int> getTodaySteps() async {
    try {
      developer.log('👣 오늘 걸음 수 조회 시작');
      final dynamic result = await _platform.invokeMethod('getTodaySteps');

      if (result is int) {
        developer.log('✅ 오늘 걸음 수: $result');
        return result;
      } else if (result is double) {
        final steps = result.toInt();
        developer.log('✅ 오늘 걸음 수: $steps');
        return steps;
      }

      developer.log('⚠️ 걸음 수 조회 결과가 숫자가 아님: $result');
      return 0;
    } catch (e) {
      developer.log('❌ 걸음 수 조회 실패: $e');
      return 0;
    }
  }

  /// 오늘 칼로리 소모량 가져오기
  Future<double> getTodayCaloriesBurned() async {
    try {
      developer.log('🔥 오늘 칼로리 소모량 조회 시작');
      final dynamic result = await _platform.invokeMethod(
        'getTodayCaloriesBurned',
      );

      if (result is double) {
        developer.log('✅ 오늘 칼로리 소모량: $result');
        return result;
      } else if (result is int) {
        final calories = result.toDouble();
        developer.log('✅ 오늘 칼로리 소모량: $calories');
        return calories;
      }

      developer.log('⚠️ 칼로리 조회 결과가 숫자가 아님: $result');
      return 0.0;
    } catch (e) {
      developer.log('❌ 칼로리 조회 실패: $e');
      return 0.0;
    }
  }

  /// 실시간 움직임 칼로리 소비량 가져오기 (Health Connect에서 직접 조회)
  Future<double> getRealtimeActivityCalories() async {
    try {
      return await getTodayCaloriesBurned();
    } catch (e) {
      developer.log('❌ 실시간 움직임 칼로리 조회 실패: $e');
      return 0.0;
    }
  }

  /// 운동 세션 가져오기
  Future<List<Map<String, dynamic>>> getWorkouts(
    DateTime start,
    DateTime end,
  ) async {
    try {
      developer.log(
        '🏃 운동 세션 조회 시작: ${start.toIso8601String()} ~ ${end.toIso8601String()}',
      );
      final dynamic result = await _platform.invokeMethod('getWorkouts', {
        'startTime': start.millisecondsSinceEpoch,
        'endTime': end.millisecondsSinceEpoch,
      });

      developer.log('🔍 getWorkouts native 응답 타입: ${result.runtimeType}');

      if (result is List) {
        final workouts = result
            .map((item) {
              try {
                return Map<String, dynamic>.from(item as Map);
              } catch (e) {
                developer.log('⚠️ 개별 운동 데이터 변환 실패: $e');
                return null;
              }
            })
            .whereType<Map<String, dynamic>>()
            .toList();

        developer.log('✅ 운동 세션 ${workouts.length}개 조회 완료');
        return workouts;
      }
      developer.log('⚠️ 운동 세션 조회 결과가 리스트가 아님: $result');
      return [];
    } catch (e, stackTrace) {
      developer.log('❌ getWorkouts 호출 실패: $e');
      developer.log('📋 스택 트레이스: $stackTrace');
      return [];
    }
  }

  /// 데이터베이스 동기화
  /// 오늘의 운동 데이터를 Health Connect에서 조회하여 데이터베이스에 저장
  Future<int> syncToDatabase() async {
    developer.log('🔄 헬스 데이터 동기화 시작');

    try {
      // 오늘 날짜 범위 설정
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      developer.log(
        '📅 날짜 범위: ${today.toIso8601String()} ~ ${tomorrow.toIso8601String()}',
      );

      // Health Connect에서 오늘 운동 데이터 조회
      developer.log('🏃 Health Connect 데이터 조회 시작');
      final workouts = await getWorkouts(today, tomorrow);
      developer.log('📊 오늘 운동 데이터 ${workouts.length}개 조회됨');

      if (workouts.isEmpty) {
        developer.log('ℹ️ 동기화할 새로운 운동 데이터가 없습니다');
        return 0;
      }

      // 각 데이터 상세 로깅
      for (int i = 0; i < workouts.length; i++) {
        developer.log('🔍 원본 데이터 [$i]: ${workouts[i]}');
      }

      // 데이터베이스에 저장 (중복 방지)
      developer.log('💾 데이터베이스 저장 시작');
      final db = DatabaseService();
      int savedCount = 0;

      for (int i = 0; i < workouts.length; i++) {
        final workout = workouts[i];
        try {
          developer.log(
            '🔍 처리 중인 운동 데이터 [$i]: id=${workout['id']}, type=${workout['type']}',
          );

          // external_id로 중복 확인 및 업데이트 체크
          final externalId = workout['id'] as String?;
          if (externalId != null) {
            developer.log('🔍 중복 및 업데이트 확인: externalId=$externalId');
            final existingRecord = await db.getExerciseByExternalId(externalId);

            if (existingRecord != null) {
              final newCalories =
                  (workout['calories'] as num?)?.toDouble() ?? 0.0;
              final oldCalories =
                  (existingRecord['calories_burned'] as num?)?.toDouble() ??
                  0.0;

              if (newCalories > oldCalories) {
                developer.log(
                  '🔄 기존 데이터 업데이트 (칼로리 증가): $oldCalories -> $newCalories',
                );
                await db.updateExerciseRecords(existingRecord['id'], {
                  'calories_burned': newCalories,
                  'distance_meters': (workout['distance'] as num?)?.toDouble(),
                });
                savedCount++; // 업데이트도 성공 횟수에 포함
              } else {
                developer.log('⏭️ 중복 데이터 건너뜀 (변화 없음): $externalId');
              }
              continue;
            }
          } else {
            developer.log('⚠️ external_id가 없음');
          }

          // 데이터 타입 변환 검증
          final startTimeMillis = workout['start_time'];
          final endTimeMillis = workout['end_time'];
          final durationMinutes = workout['duration_minutes'];

          developer.log(
            '🔍 처리 중인 운동 데이터 [$i]: id=${workout['id']}, type=${workout['type']}',
          );
          developer.log(
            '🔍 원본 타입: startTime=${startTimeMillis.runtimeType}, duration=${durationMinutes.runtimeType}',
          );

          if (startTimeMillis == null || endTimeMillis == null) {
            developer.log('❌ 시간 데이터가 없음');
            continue;
          }

          final int start = startTimeMillis is int
              ? startTimeMillis
              : (startTimeMillis as num).toInt();
          final int end = endTimeMillis is int
              ? endTimeMillis
              : (endTimeMillis as num).toInt();
          final int duration = durationMinutes is int
              ? durationMinutes
              : (durationMinutes as num).toInt();

          developer.log(
            '🔍 운동 데이터 [${workout['id']}] 칼로리: ${workout['calories']} kcal / 거리: ${workout['distance']} m',
          );

          // WorkoutData 객체 생성
          final workoutData = WorkoutData(
            id: externalId ?? DateTime.now().millisecondsSinceEpoch.toString(),
            type: _parseWorkoutTypeFromMap(workout),
            startTime: DateTime.fromMillisecondsSinceEpoch(start),
            endTime: DateTime.fromMillisecondsSinceEpoch(end),
            durationMinutes: duration,
            caloriesBurned: (workout['calories'] as num?)?.toDouble() ?? 0.0,
            distanceMeters: (workout['distance'] as num?)?.toDouble(),
            source: DataSource.healthConnect,
            externalId: externalId,
            customName: workout['title'], // Health Connect 세션 제목
            packageName: workout['package_name'], // 데이터 소스 패키지명
          );

          final mapData = workoutData.toMap();
          developer.log('🔍 DB 저장 직전 데이터 (toMap): $mapData');
          developer.log(
            '💾 DB 저장 시도: ${workoutData.displayName}, id=$externalId, calories=${workoutData.caloriesBurned}',
          );

          // 데이터베이스에 저장
          final resultId = await db.insertExerciseFromHealth(mapData);
          if (resultId > 0) {
            savedCount++;
            developer.log('✅ 저장 성공: id=$resultId');
          } else {
            developer.log('⚠️ 저장 실패: 결과 ID=$resultId');
          }
        } catch (e, stackTrace) {
          developer.log('❌ 개별 데이터 처리 중 오류 [$i]: $e');
          developer.log('📋 스택 트레이스: $stackTrace');
        }
      }

      developer.log('💾 데이터베이스 저장 완료: $savedCount/${workouts.length}개 성공');

      // 저장 검증: 실제로 데이터베이스에 저장되었는지 확인
      developer.log('🔍 저장 검증 시작');
      final verifyDb = DatabaseService();
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final savedRecords = await verifyDb.getExerciseRecordsForDate(todayStr);
      final autoRecords = savedRecords.where((record) {
        final source = record['source'] ?? 'manual';
        return source.toLowerCase() != 'manual';
      }).toList();

      developer.log(
        '✅ 저장 검증 결과: 전체 ${savedRecords.length}개, 자동 ${autoRecords.length}개',
      );

      for (final record in autoRecords) {
        developer.log(
          '🔍 저장된 자동 기록: id=${record['id']}, exercise_name=${record['exercise_name']}, source=${record['source']}',
        );
      }

      developer.log('🎉 헬스 데이터 동기화 완료: $savedCount개 저장됨');
      return savedCount;
    } catch (e, stackTrace) {
      developer.log('❌ 헬스 데이터 동기화 실패: $e');
      developer.log('📋 스택 트레이스: $stackTrace');
      return 0;
    }
  }

  /// Map에서 WorkoutType 파싱 (헬퍼 메서드)
  WorkoutType _parseWorkoutTypeFromMap(Map<String, dynamic> workout) {
    final typeStr = workout['type'] as String?;
    if (typeStr == null) return WorkoutType.other;

    return WorkoutType.values.firstWhere(
      (type) => type.name.toLowerCase() == typeStr.toLowerCase(),
      orElse: () => WorkoutType.other,
    );
  }

  /// Health Connect 클라이언트 초기화 (임시 구현)
  Future<void> initialize() async {
    developer.log('🚀 Health Connect 클라이언트 초기화 (임시 구현)');
    // 실제로는 Health Connect SDK 초기화가 필요함
  }

  /// 최신 체중 가져오기 (임시 구현)
  Future<double?> getLatestWeight() async {
    developer.log('⚖️ 최신 체중 조회 (임시 구현)');
    return null;
  }

  /// 체중 기록 가져오기 (임시 구현)
  Future<List<Map<String, dynamic>>> getWeightHistory({int days = 30}) async {
    developer.log('📊 체중 기록 조회 (임시 구현 - 빈 리스트)');
    return [];
  }

  /// 권한 상태 종합 진단 (사용자 친화적 버전)
  ///
  /// 사용자에게 필요한 정보만 제공하고 민감한 내부 정보는 제외
  Future<String> diagnosePermissions() async {
    try {
      // 1. 실시간 권한 상태 확인
      final activityStatus = await Permission.activityRecognition.status;
      final sensorStatus = await Permission.sensors.status; // 선택사항
      final healthDataPermission = await hasPermissions();

      // 활동 인식과 헬스 데이터 권한만 필수로 체크
      final hasAllRequiredPermissions =
          activityStatus.isGranted && healthDataPermission;

      // 사용자 친화적 결과 생성
      final buffer = StringBuffer();
      buffer.writeln('🔍 VitaBuddy 권한 진단 결과\n');

      if (hasAllRequiredPermissions) {
        buffer.writeln('✅ 모든 필수 권한이 정상적으로 설정되어 있습니다.');
        buffer.writeln('📱 건강 데이터를 사용할 수 있습니다.');

        // 선택사항 권한 상태도 알려주기
        if (!sensorStatus.isGranted) {
          buffer.writeln('ℹ️ 센서 권한은 선택사항이지만, 허용하면 더 정확한 데이터를 얻을 수 있습니다.');
        }
      } else {
        buffer.writeln('❌ 일부 필수 권한이 설정되지 않았습니다:');

        if (!activityStatus.isGranted) {
          buffer.writeln('• 활동 인식 권한이 필요합니다');
        }
        if (!healthDataPermission) {
          buffer.writeln('• 건강 데이터 권한이 필요합니다');
        }

        buffer.writeln('\n🛠️ 해결 방법:');
        buffer.writeln('1. 휴대폰 설정 → 앱 → VitaBuddy 선택');
        buffer.writeln('2. 권한 메뉴에서 필요한 권한들을 허용해주세요');
        buffer.writeln('3. 권한 진단을 다시 실행해보세요');
      }

      buffer.writeln('\n💡 건강 데이터를 활용하면 더 정확한 칼로리 관리가 가능합니다.');

      return buffer.toString();
    } catch (e) {
      // 오류 발생 시 간단한 메시지만 표시
      return '⚠️ 권한 진단 중 오류가 발생했습니다.\n앱을 재시작하거나 개발자에게 문의해주세요.';
    }
  }
}
