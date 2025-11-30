/// 운동 종류 Enum
enum WorkoutType {
  walking,         // 걷기
  running,         // 달리기
  cycling,         // 자전거
  swimming,        // 수영
  weightTraining,  // 근력 운동
  yoga,            // 요가
  dancing,         // 댄스
  hiking,          // 등산
  tennis,          // 테니스
  basketball,      // 농구
  soccer,          // 축구
  other,           // 기타
}

/// 데이터 출처 Enum
enum DataSource {
  manual,         // 수동 입력
  healthConnect,  // Android Health Connect
  healthKit,      // iOS HealthKit
}

/// 운동 데이터 모델
class WorkoutData {
  final String id;
  final WorkoutType type;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double caloriesBurned;
  final double? distanceMeters;
  final int? averageHeartRate;
  final int? steps;
  final DataSource source;
  final String? externalId;  // 중복 방지용

  WorkoutData({
    required this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.distanceMeters,
    this.averageHeartRate,
    this.steps,
    required this.source,
    this.externalId,
  });

  /// 데이터베이스에 저장할 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_name': type.name,
      'exercise_type': type.name,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'date': startTime.toIso8601String().split('T')[0],
      'time': startTime.toIso8601String(),
      'distance_meters': distanceMeters,
      'average_heart_rate': averageHeartRate,
      'steps': steps,
      'source': source.name,
      'external_id': externalId,
    };
  }

  /// Map에서 WorkoutData 생성
  factory WorkoutData.fromMap(Map<String, dynamic> map) {
    return WorkoutData(
      id: map['id']?.toString() ?? '',
      type: _parseWorkoutType(map['exercise_type'] ?? map['exercise_name']),
      startTime: DateTime.parse(map['time']),
      endTime: DateTime.parse(map['time']).add(
        Duration(minutes: map['duration_minutes'] ?? 0),
      ),
      durationMinutes: map['duration_minutes'] ?? 0,
      caloriesBurned: (map['calories_burned'] ?? 0.0).toDouble(),
      distanceMeters: map['distance_meters']?.toDouble(),
      averageHeartRate: map['average_heart_rate'],
      steps: map['steps'],
      source: _parseDataSource(map['source']),
      externalId: map['external_id'],
    );
  }

  /// MET 값 테이블 (운동 종류별 대사량)
  /// MET (Metabolic Equivalent of Task): 안정 시 대비 몇 배의 에너지를 소비하는지
  static const Map<WorkoutType, double> metValues = {
    WorkoutType.walking: 3.5,         // 걷기 (보통 속도)
    WorkoutType.running: 8.0,         // 달리기 (8km/h)
    WorkoutType.cycling: 6.0,         // 자전거 (보통 속도)
    WorkoutType.swimming: 7.0,        // 수영 (자유형)
    WorkoutType.weightTraining: 5.0,  // 근력 운동
    WorkoutType.yoga: 2.5,            // 요가
    WorkoutType.dancing: 4.5,         // 댄스
    WorkoutType.hiking: 6.5,          // 등산
    WorkoutType.tennis: 7.3,          // 테니스
    WorkoutType.basketball: 6.5,      // 농구
    WorkoutType.soccer: 7.0,          // 축구
    WorkoutType.other: 4.0,           // 기타 (중간값)
  };

  /// MET 기반 칼로리 계산
  /// 
  /// 공식: 칼로리 = MET × 체중(kg) × 시간(hour)
  /// 
  /// [type]: 운동 종류
  /// [durationMinutes]: 운동 시간 (분)
  /// [weightKg]: 체중 (kg)
  /// [intensity]: 강도 (1.0 = 보통, 1.2 = 높음, 0.8 = 낮음)
  static double calculateCalories({
    required WorkoutType type,
    required int durationMinutes,
    required double weightKg,
    double intensity = 1.0,
  }) {
    final met = metValues[type] ?? 4.0;
    final hours = durationMinutes / 60.0;
    return met * weightKg * hours * intensity;
  }

  /// 문자열을 WorkoutType으로 변환
  static WorkoutType _parseWorkoutType(String? typeStr) {
    if (typeStr == null) return WorkoutType.other;
    
    try {
      return WorkoutType.values.firstWhere(
        (t) => t.name.toLowerCase() == typeStr.toLowerCase(),
        orElse: () => WorkoutType.other,
      );
    } catch (e) {
      return WorkoutType.other;
    }
  }

  /// 문자열을 DataSource로 변환
  static DataSource _parseDataSource(String? sourceStr) {
    if (sourceStr == null) return DataSource.manual;
    
    try {
      return DataSource.values.firstWhere(
        (s) => s.name.toLowerCase() == sourceStr.toLowerCase(),
        orElse: () => DataSource.manual,
      );
    } catch (e) {
      return DataSource.manual;
    }
  }

  /// 운동 종류를 한글 이름으로 변환
  String get displayName {
    switch (type) {
      case WorkoutType.walking:
        return '걷기';
      case WorkoutType.running:
        return '달리기';
      case WorkoutType.cycling:
        return '자전거';
      case WorkoutType.swimming:
        return '수영';
      case WorkoutType.weightTraining:
        return '근력 운동';
      case WorkoutType.yoga:
        return '요가';
      case WorkoutType.dancing:
        return '댄스';
      case WorkoutType.hiking:
        return '등산';
      case WorkoutType.tennis:
        return '테니스';
      case WorkoutType.basketball:
        return '농구';
      case WorkoutType.soccer:
        return '축구';
      case WorkoutType.other:
        return '기타 운동';
    }
  }

  /// 데이터 출처를 한글 이름으로 변환
  String get sourceDisplayName {
    switch (source) {
      case DataSource.manual:
        return '수동 입력';
      case DataSource.healthConnect:
        return 'Health Connect';
      case DataSource.healthKit:
        return 'HealthKit';
    }
  }

  @override
  String toString() {
    return 'WorkoutData(type: $displayName, duration: $durationMinutes분, calories: ${caloriesBurned.toInt()}kcal, source: $sourceDisplayName)';
  }
}
