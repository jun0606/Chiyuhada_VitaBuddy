package com.chiyuhada.vitabuddy

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord
import androidx.health.connect.client.records.BasalMetabolicRateRecord
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.TotalCaloriesBurnedRecord
import androidx.health.connect.client.records.WeightRecord
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneOffset
import java.time.temporal.ChronoUnit

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.health_connect"
    private var lastResult: MethodChannel.Result? = null

    // Health Connect 권한 요청을 위한 런처
    private val requestPermissionsLauncher = registerForActivityResult(
        PermissionController.createRequestPermissionResultContract()
    ) { granted ->
        Log.d("HealthConnect", "권한 요청 결과 도착: ${granted.size}개 허용됨")
        lastResult?.success(if (granted.isNotEmpty()) 1 else 0)
        lastResult = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestHealthConnectPermissions" -> {
                        try {
                            lastResult = result
                            val permissions = setOf(
                                HealthPermission.getReadPermission(StepsRecord::class),
                                HealthPermission.getReadPermission(ActiveCaloriesBurnedRecord::class),
                                HealthPermission.getReadPermission(BasalMetabolicRateRecord::class),
                                HealthPermission.getReadPermission(TotalCaloriesBurnedRecord::class),
                                HealthPermission.getReadPermission(DistanceRecord::class),
                                HealthPermission.getReadPermission(ExerciseSessionRecord::class),
                                HealthPermission.getWritePermission(ExerciseSessionRecord::class),
                                HealthPermission.getReadPermission(WeightRecord::class),
                                HealthPermission.getWritePermission(WeightRecord::class)
                            )
                            requestPermissionsLauncher.launch(permissions)
                        } catch (e: Exception) {
                            Log.e("HealthConnect", "권한 요청 런처 실행 실패: ${e.message}")
                            result.error("LAUNCH_FAILED", e.message, null)
                            lastResult = null
                        }
                    }
                    "getHealthConnectPermissionsStatus" -> {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val healthConnectClient = HealthConnectClient.getOrCreate(this@MainActivity)
                                val permissions = setOf(
                                    HealthPermission.getReadPermission(StepsRecord::class),
                                    HealthPermission.getReadPermission(ActiveCaloriesBurnedRecord::class),
                                    HealthPermission.getReadPermission(BasalMetabolicRateRecord::class),
                                    HealthPermission.getReadPermission(TotalCaloriesBurnedRecord::class),
                                    HealthPermission.getReadPermission(DistanceRecord::class),
                                    HealthPermission.getReadPermission(ExerciseSessionRecord::class),
                                    HealthPermission.getReadPermission(WeightRecord::class)
                                )
                                val granted = healthConnectClient.permissionController.getGrantedPermissions()
                                Log.d("HealthConnect", "허용된 모든 권한: ${granted.joinToString { it.toString() }}")
                                
                                val missingPermissions = permissions.filter { it !in granted }
                                if (missingPermissions.isNotEmpty()) {
                                    Log.w("HealthConnect", "누락된 권한 발견: ${missingPermissions.joinToString()}")
                                }
                                
                                // 최소한 걸음 수나 칼로리, 운동 세션 중 하나라도 있으면 진행 가능으로 판단
                                val essentialPermissions = setOf(
                                    HealthPermission.getReadPermission(StepsRecord::class),
                                    HealthPermission.getReadPermission(ActiveCaloriesBurnedRecord::class),
                                    HealthPermission.getReadPermission(BasalMetabolicRateRecord::class),
                                    HealthPermission.getReadPermission(ExerciseSessionRecord::class)
                                )
                                val hasEssential = granted.any { it in essentialPermissions }
                                
                                withContext(Dispatchers.Main) {
                                    result.success(if (hasEssential) 1 else 0)
                                }
                            } catch (e: Exception) {
                                Log.e("HealthConnect", "권한 상태 확인 실패: ${e.message}")
                                withContext(Dispatchers.Main) {
                                    result.success(0)
                                }
                            }
                        }
                    }
                    "isHealthConnectInstalled" -> {
                        try {
                            val status = HealthConnectClient.getSdkStatus(this)
                            Log.d("HealthConnect", "SDK Status: $status")
                            
                            val response = when (status) {
                                HealthConnectClient.SDK_AVAILABLE -> 1
                                HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED -> 2
                                else -> 0
                            }
                            result.success(response)
                        } catch (e: Exception) {
                            result.success(0)
                        }
                    }
                    "openHealthConnectStore" -> {
                        try {
                            val status = HealthConnectClient.getSdkStatus(this)

                            // Android 14+ (Framework 지원 기기)인 경우 시스템 설정으로 유도 시도
                            if (android.os.Build.VERSION.SDK_INT >= 34) {
                                try {
                                    val intent = Intent("android.settings.HEALTH_SETTINGS")
                                    startActivity(intent)
                                    result.success(true)
                                    return@setMethodCallHandler
                                } catch (e: Exception) {
                                    Log.d("HealthConnect", "System health settings intent failed, falling back to market")
                                }
                            }

                            // 일반적인 혹은 Fallback 스토어 이동
                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                data = Uri.parse("market://details?id=com.google.android.apps.healthdata")
                                setPackage("com.android.vending")
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            try {
                                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata"))
                                startActivity(intent)
                                result.success(true)
                            } catch (e2: Exception) {
                                result.error("STORE_FAILED", e2.message, null)
                            }
                        }
                    }
                    "getWorkouts" -> {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val workouts = getWorkoutsData(call.argument("startTime"), call.argument("endTime"))
                                withContext(Dispatchers.Main) {
                                    result.success(workouts)
                                }
                            } catch (e: Exception) {
                                Log.e("HealthConnect", "운동 데이터 조회 실패: ${e.message}")
                                withContext(Dispatchers.Main) {
                                    result.error("GET_WORKOUTS_FAILED", e.message, null)
                                }
                            }
                        }
                    }
                    "getTodaySteps" -> {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val steps = getTodayStepsData()
                                withContext(Dispatchers.Main) {
                                    result.success(steps)
                                }
                            } catch (e: Exception) {
                                Log.e("HealthConnect", "걸음 수 조회 실패: ${e.message}")
                                withContext(Dispatchers.Main) {
                                    result.success(0) // 실패 시 0 반환
                                }
                            }
                        }
                    }
                    "getTodayCaloriesBurned" -> {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val calories = getTodayCaloriesData()
                                withContext(Dispatchers.Main) {
                                    result.success(calories)
                                }
                            } catch (e: Exception) {
                                Log.e("HealthConnect", "칼로리 조회 실패: ${e.message}")
                                withContext(Dispatchers.Main) {
                                    result.success(0.0) // 실패 시 0.0 반환
                                }
                            }
                        }
                    }
                    "syncToDatabase" -> {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val syncedCount = syncHealthDataToDatabase()
                                withContext(Dispatchers.Main) {
                                    result.success(syncedCount)
                                }
                            } catch (e: Exception) {
                                Log.e("HealthConnect", "데이터 동기화 실패: ${e.message}")
                                withContext(Dispatchers.Main) {
                                    result.success(0) // 실패 시 0 반환
                                }
                            }
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    // 운동 데이터 조회
    private suspend fun getWorkoutsData(startTime: Long?, endTime: Long?): List<Map<String, Any>> {
        val healthConnectClient = HealthConnectClient.getOrCreate(this@MainActivity)

        // 시간 범위 설정 (기본값: 최근 7일)
        val endInstant = endTime?.let { Instant.ofEpochMilli(it) } ?: Instant.now()
        val startInstant = startTime?.let { Instant.ofEpochMilli(it) } ?: endInstant.minus(7, ChronoUnit.DAYS)

        val timeRangeFilter = TimeRangeFilter.between(startInstant, endInstant)

        // 운동 세션 데이터 조회
        val workoutRequest = ReadRecordsRequest(
            recordType = ExerciseSessionRecord::class,
            timeRangeFilter = timeRangeFilter
        )

        val workouts = mutableListOf<Map<String, Any>>()

        try {
            val response = healthConnectClient.readRecords(workoutRequest)
            Log.d("HealthConnect", "운동 세션 조회 결과: ${response.records.size}개 발견")

            for (record in response.records) {
                Log.d("HealthConnect", "세션 처리 중: id=${record.metadata.id}, type=${record.exerciseType}, start=${record.startTime}")

                // 칼로리 조회 - 다중 전략 적용 (Google Health Connect 공식 저장 방식 기반)
                var totalCalories = 0.0
                val sessionDuration = ChronoUnit.MINUTES.between(record.startTime, record.endTime)

                // 전략 1: ActiveCaloriesBurnedRecord 집계 (±5분 범위)
                val activeCalFilter = TimeRangeFilter.between(
                    record.startTime.minus(5, ChronoUnit.MINUTES),
                    record.endTime.plus(5, ChronoUnit.MINUTES)
                )

                try {
                    val activeCalRequest = AggregateRequest(
                        metrics = setOf(ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL),
                        timeRangeFilter = activeCalFilter
                    )
                    val activeCalResponse = healthConnectClient.aggregate(activeCalRequest)
                    totalCalories = activeCalResponse[ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL]?.inKilocalories ?: 0.0
                    Log.d("HealthConnect", "  - ActiveCalories 집계 (±5분): $totalCalories kcal")
                } catch (e: Exception) {
                    Log.w("HealthConnect", "  - ActiveCalories 집계 실패: ${e.message}")
                }

                // 전략 2: TotalCaloriesBurnedRecord 확인 (활동 + BMR 포함)
                if (totalCalories == 0.0) {
                    try {
                        val totalCalRequest = AggregateRequest(
                            metrics = setOf(TotalCaloriesBurnedRecord.ENERGY_TOTAL),
                            timeRangeFilter = activeCalFilter
                        )
                        val totalCalResponse = healthConnectClient.aggregate(totalCalRequest)
                        val totalCalResult = totalCalResponse[TotalCaloriesBurnedRecord.ENERGY_TOTAL]?.inKilocalories ?: 0.0

                        // TotalCalories에서 BMR 추정치를 제외하여 활동 칼로리로 변환
                        // (대략적인 계산: Total - (BMR * 시간))
                        val estimatedBmrPerHour = 1.2 // 시간당 대략적인 BMR (성인 평균)
                        val sessionHours = sessionDuration / 60.0
                        val estimatedBmr = estimatedBmrPerHour * sessionHours

                        totalCalories = maxOf(0.0, totalCalResult - estimatedBmr)
                        Log.d("HealthConnect", "  - TotalCalories 기반 활동 칼로리 추정: $totalCalories kcal (총: $totalCalResult, BMR 추정: $estimatedBmr)")
                    } catch (e: Exception) {
                        Log.w("HealthConnect", "  - TotalCalories 확인 실패: ${e.message}")
                    }
                }

                // 전략 3: ActiveCaloriesBurnedRecord 개별 레코드 조회 (±5분)
                if (totalCalories == 0.0) {
                    val activeReadRequest = ReadRecordsRequest(
                        recordType = ActiveCaloriesBurnedRecord::class,
                        timeRangeFilter = activeCalFilter
                    )
                    val activeReadResponse = healthConnectClient.readRecords(activeReadRequest)
                    totalCalories = activeReadResponse.records.sumOf { it.energy.inKilocalories }
                    Log.d("HealthConnect", "  - ActiveCalories 개별 조회 (±5분): ${activeReadResponse.records.size}개, 합계: $totalCalories kcal")
                }

                // 전략 4: 더 넓은 범위에서 ActiveCaloriesBurnedRecord 조회 (±15분)
                if (totalCalories == 0.0) {
                    val broadFilter = TimeRangeFilter.between(
                        record.startTime.minus(15, ChronoUnit.MINUTES),
                        record.endTime.plus(15, ChronoUnit.MINUTES)
                    )
                    val broadReadRequest = ReadRecordsRequest(
                        recordType = ActiveCaloriesBurnedRecord::class,
                        timeRangeFilter = broadFilter
                    )
                    val broadReadResponse = healthConnectClient.readRecords(broadReadRequest)
                    totalCalories = broadReadResponse.records.sumOf { it.energy.inKilocalories }
                    Log.d("HealthConnect", "  - ActiveCalories 개별 조회 (±15분): ${broadReadResponse.records.size}개, 합계: $totalCalories kcal")
                }

                // 전략 5: 운동 시간 기반 칼로리 추정 (최후의 수단)
                if (totalCalories == 0.0 && sessionDuration > 0) {
                    // 기본 MET 값 기반 추정 (운동 종류별 평균)
                    val baseMetValue = when (record.exerciseType) {
                        ExerciseSessionRecord.EXERCISE_TYPE_RUNNING -> 8.3
                        ExerciseSessionRecord.EXERCISE_TYPE_BIKING,
                        ExerciseSessionRecord.EXERCISE_TYPE_BIKING_STATIONARY -> 6.8
                        ExerciseSessionRecord.EXERCISE_TYPE_SWIMMING_POOL,
                        ExerciseSessionRecord.EXERCISE_TYPE_SWIMMING_OPEN_WATER -> 7.0
                        ExerciseSessionRecord.EXERCISE_TYPE_WALKING -> 3.5
                        ExerciseSessionRecord.EXERCISE_TYPE_STRENGTH_TRAINING -> 5.0
                        ExerciseSessionRecord.EXERCISE_TYPE_YOGA -> 2.5
                        else -> 4.0 // 일반 활동
                    }

                    val sessionHours = sessionDuration / 60.0
                    // 평균 체중 70kg 가정 (실제로는 사용자 프로필에서 가져와야 함)
                    totalCalories = baseMetValue * 70.0 * sessionHours
                    Log.d("HealthConnect", "  - MET 기반 칼로리 추정: $totalCalories kcal (MET: $baseMetValue, 시간: ${sessionHours}h, 체중: 70kg)")
                }

                // 거리 집계
                val distanceRequest = AggregateRequest(
                    metrics = setOf(DistanceRecord.DISTANCE_TOTAL),
                    timeRangeFilter = activeCalFilter
                )
                val distanceResponse = healthConnectClient.aggregate(distanceRequest)
                var totalDistance = distanceResponse[DistanceRecord.DISTANCE_TOTAL]?.inMeters ?: 0.0

                if (totalDistance == 0.0) {
                    val readRequest = ReadRecordsRequest(
                        recordType = DistanceRecord::class,
                        timeRangeFilter = activeCalFilter
                    )
                    val readResponse = healthConnectClient.readRecords(readRequest)
                    totalDistance = readResponse.records.sumOf { it.distance.inMeters }
                }
                Log.d("HealthConnect", "  - 세션 거리: $totalDistance")

                val workout = mapOf<String, Any>(
                    "id" to record.metadata.id,
                    "title" to (record.title ?: ""),
                    "notes" to (record.notes ?: ""),
                    "type_int" to record.exerciseType,
                    "type" to mapExerciseType(record.exerciseType),
                    "start_time" to record.startTime.toEpochMilli(),
                    "end_time" to record.endTime.toEpochMilli(),
                    "duration_minutes" to ChronoUnit.MINUTES.between(record.startTime, record.endTime).toInt(),
                    "calories" to totalCalories,
                    "distance" to totalDistance,
                    "package_name" to record.metadata.dataOrigin.packageName
                )
                workouts.add(workout)
            }

            Log.d("HealthConnect", "운동 데이터 ${workouts.size}개 조회 완료")
        } catch (e: Exception) {
            Log.e("HealthConnect", "운동 데이터 조회 실패: ${e.message}")
            throw e
        }

        return workouts
    }

    // 오늘 걸음 수 조회
    private suspend fun getTodayStepsData(): Int {
        val healthConnectClient = HealthConnectClient.getOrCreate(this@MainActivity)

        // 오늘 시작과 끝 시간 (현지 시간대 기준)
        val today = LocalDateTime.now().toLocalDate().atStartOfDay()
        val startInstant = today.atZone(java.time.ZoneId.systemDefault()).toInstant()
        val endInstant = startInstant.plus(1, ChronoUnit.DAYS)

        val timeRangeFilter = TimeRangeFilter.between(startInstant, endInstant)

        val stepsRequest = AggregateRequest(
            metrics = setOf(StepsRecord.COUNT_TOTAL),
            timeRangeFilter = timeRangeFilter
        )

        try {
            val response = healthConnectClient.aggregate(stepsRequest)
            val totalSteps = response[StepsRecord.COUNT_TOTAL] ?: 0L
            Log.d("HealthConnect", "오늘 걸음 수 (Aggregated): $totalSteps ($startInstant ~ $endInstant)")
            return totalSteps.toInt()
        } catch (e: Exception) {
            Log.e("HealthConnect", "걸음 수 집계 실패: ${e.message}")
            throw e
        }
    }

    // 오늘 칼로리 소모량 조회
    private suspend fun getTodayCaloriesData(): Double {
        val healthConnectClient = HealthConnectClient.getOrCreate(this@MainActivity)

        // 오늘 시작과 끝 시간 (현지 시간대 기준)
        val today = LocalDateTime.now().toLocalDate().atStartOfDay()
        val startInstant = today.atZone(java.time.ZoneId.systemDefault()).toInstant()
        val endInstant = startInstant.plus(1, ChronoUnit.DAYS)

        val timeRangeFilter = TimeRangeFilter.between(startInstant, endInstant)

        val caloriesRequest = AggregateRequest(
            metrics = setOf(ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL),
            timeRangeFilter = timeRangeFilter
        )

        try {
            val response = healthConnectClient.aggregate(caloriesRequest)
            var totalCalories = response[ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL]?.inKilocalories ?: 0.0
            Log.d("HealthConnect", "오늘 활동 칼로리 (Aggregated): $totalCalories kcal")
            
            // Total Calories 레코드도 확인
            try {
                val totalCalRequest = AggregateRequest(
                    metrics = setOf(TotalCaloriesBurnedRecord.ENERGY_TOTAL),
                    timeRangeFilter = timeRangeFilter
                )
                val totalCalResponse = healthConnectClient.aggregate(totalCalRequest)
                val totalCalResult = totalCalResponse[TotalCaloriesBurnedRecord.ENERGY_TOTAL]?.inKilocalories ?: 0.0
                Log.d("HealthConnect", "오늘 전체 칼로리 (TotalCaloriesRecord): $totalCalResult kcal")
            } catch (e: Exception) {
                Log.w("HealthConnect", "TotalCalories 집계 실패: ${e.message}")
            }

            // BMR 확인
            try {
                val bmrReadRequest = ReadRecordsRequest(
                    recordType = BasalMetabolicRateRecord::class,
                    timeRangeFilter = timeRangeFilter
                )
                val bmrReadResponse = healthConnectClient.readRecords(bmrReadRequest)
                Log.d("HealthConnect", "오늘 BMR 레코드: ${bmrReadResponse.records.size}개 발견")
            } catch (e: Exception) {
                Log.w("HealthConnect", "BMR 조회 실패: ${e.message}")
            }

            // 폴백: 활동 칼로리가 0이면 레코드 상세 덤프 (디버깅용)
            if (totalCalories == 0.0) {
                val readRequest = ReadRecordsRequest(
                    recordType = ActiveCaloriesBurnedRecord::class,
                    timeRangeFilter = timeRangeFilter
                )
                val readResponse = healthConnectClient.readRecords(readRequest)
                totalCalories = readResponse.records.sumOf { it.energy.inKilocalories }
                
                if (totalCalories == 0.0) {
                    Log.w("HealthConnect", "⚠️ HC에 활동 칼로리 레코드가 아예 없습니다. (오늘 범위)")
                    
                    // 더 넓은 범위(최근 7일)에서 가장 최근 칼로리 레코드 1개라도 있는지 확인
                    val broadRequest = ReadRecordsRequest(
                        recordType = ActiveCaloriesBurnedRecord::class,
                        timeRangeFilter = TimeRangeFilter.between(Instant.now().minus(7, ChronoUnit.DAYS), Instant.now()),
                        pageSize = 1,
                        ascendingOrder = false
                    )
                    val broadResponse = healthConnectClient.readRecords(broadRequest)
                    if (broadResponse.records.isNotEmpty()) {
                        val lastRec = broadResponse.records.first()
                        Log.d("HealthConnect", "💡 힌트: 최근 7일 내 마지막 칼로리 기록 발견 - 시간: ${lastRec.startTime}, 값: ${lastRec.energy.inKilocalories} kcal")
                    } else {
                        Log.w("HealthConnect", "💡 힌트: 최근 7일 내에도 칼로리 기록이 전혀 없습니다.")
                    }
                }
            }
            
            Log.d("HealthConnect", "조회 범위: $startInstant ~ $endInstant")
            return totalCalories
        } catch (e: Exception) {
            Log.e("HealthConnect", "칼로리 집계 실패: ${e.message}")
            throw e
        }
    }

    // 건강 데이터 동기화 (Flutter 측에서 데이터베이스 저장 처리)
    private suspend fun syncHealthDataToDatabase(): Int {
        // 오늘 시작과 끝 시간 (현지 시간대 기준)
        val today = LocalDateTime.now().toLocalDate().atStartOfDay()
        val startInstant = today.atZone(java.time.ZoneId.systemDefault()).toInstant()
        val endInstant = startInstant.plus(1, ChronoUnit.DAYS)

        val workouts = getWorkoutsData(startInstant.toEpochMilli(), endInstant.toEpochMilli())

        // 실제로는 Flutter 측에서 데이터베이스 저장을 처리하므로,
        // 여기서는 조회된 데이터 개수만 반환
        Log.d("HealthConnect", "동기화할 운동 데이터: ${workouts.size}개")
        return workouts.size
    }

    // Health Connect 운동 타입을 앱의 운동 타입으로 매핑
    private fun mapExerciseType(exerciseType: Int): String {
        return when (exerciseType) {
            ExerciseSessionRecord.EXERCISE_TYPE_WALKING -> "walking"
            ExerciseSessionRecord.EXERCISE_TYPE_RUNNING -> "running"
            ExerciseSessionRecord.EXERCISE_TYPE_BIKING,
            ExerciseSessionRecord.EXERCISE_TYPE_BIKING_STATIONARY -> "cycling"
            ExerciseSessionRecord.EXERCISE_TYPE_SWIMMING_POOL,
            ExerciseSessionRecord.EXERCISE_TYPE_SWIMMING_OPEN_WATER -> "swimming"
            ExerciseSessionRecord.EXERCISE_TYPE_STRENGTH_TRAINING -> "weightTraining"
            ExerciseSessionRecord.EXERCISE_TYPE_YOGA -> "yoga"
            ExerciseSessionRecord.EXERCISE_TYPE_DANCING -> "dancing"
            ExerciseSessionRecord.EXERCISE_TYPE_HIKING -> "hiking"
            ExerciseSessionRecord.EXERCISE_TYPE_TENNIS -> "tennis"
            ExerciseSessionRecord.EXERCISE_TYPE_BASKETBALL -> "basketball"
            ExerciseSessionRecord.EXERCISE_TYPE_SOCCER -> "soccer"
            // Note: Some exercise types may not have constants in older Health Connect versions
            // They will fall through to "other" case
            ExerciseSessionRecord.EXERCISE_TYPE_ELLIPTICAL -> "elliptical"
            ExerciseSessionRecord.EXERCISE_TYPE_ROWING_MACHINE -> "rowing"
            ExerciseSessionRecord.EXERCISE_TYPE_STAIR_CLIMBING,
            ExerciseSessionRecord.EXERCISE_TYPE_STAIR_CLIMBING_MACHINE -> "stairClimbing"
            else -> "other"
        }
    }
}
