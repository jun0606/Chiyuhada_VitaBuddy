import 'package:flutter/material.dart';
import 'package:chiyuhada_vita_buddy/services/health_data_service.dart';
import 'package:chiyuhada_vita_buddy/services/database_service.dart';
import 'package:chiyuhada_vita_buddy/widgets/exercise_card.dart';
import 'package:chiyuhada_vita_buddy/widgets/exercise_input_dialog.dart';
import 'package:provider/provider.dart';
import 'package:chiyuhada_vita_buddy/providers/app_provider.dart';
import 'package:chiyuhada_vita_buddy/l10n/app_localizations.dart';
import 'dart:developer' as developer;

/// 운동 기록 화면
///
/// Health Connect/HealthKit 데이터 동기화 및 수동 입력 지원
class ExerciseRecordScreen extends StatefulWidget {
  const ExerciseRecordScreen({super.key});

  @override
  State<ExerciseRecordScreen> createState() => _ExerciseRecordScreenState();
}

class _ExerciseRecordScreenState extends State<ExerciseRecordScreen>
    with SingleTickerProviderStateMixin {
  final HealthDataService _healthService = HealthDataService();
  final DatabaseService _dbService = DatabaseService();

  late TabController _tabController;

  // 오늘의 운동 요약 데이터
  int _todaySteps = 0;
  double _todayCalories = 0.0;
  int _todayWorkoutCount = 0;
  bool _isLoading = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  // UI 강제 새로고침용 키
  Key _autoRecordsKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodayData();

    // 운동 기록 화면 진입 시 자동 동기화 (실시간성 향상)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _autoSyncOnScreenEntry();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 오늘의 운동 데이터 로드
  Future<void> _loadTodayData() async {
    setState(() => _isLoading = true);

    try {
      // 데이터베이스에서 오늘 운동 기록 가져오기
      final today = DateTime.now().toIso8601String().split('T')[0];
      final exercises = await _dbService.getExerciseRecordsForDate(today);
      final burnedCalories = await _dbService.getTotalBurnedCaloriesForDate(
        today,
      );

      setState(() {
        _todayWorkoutCount = exercises.length;
        _todayCalories = burnedCalories;
        _isLoading = false;
      });

      // 수동 입력된 칼로리 계산
      final manualCalories = exercises.where((record) {
        final source = record['source'] ?? 'manual';
        return source.toString().toLowerCase() == 'manual';
      }).fold<double>(0.0, (sum, record) {
        return sum + (record['calories_burned'] as num? ?? 0.0).toDouble();
      });

      // 헬스 데이터에서 걸음 수 및 칼로리 가져오기 (백그라운드, 권한 확인)
      final hasPermission = await _healthService.hasPermissions();
      if (hasPermission) {
        final steps = await _healthService.getTodaySteps();
        final healthKitCalories = await _healthService.getTodayCaloriesBurned();
        
        setState(() {
          _todaySteps = steps;
          // HealthKit(활동량+웨어러블) + 수동 입력(DB) 합산
          if (healthKitCalories > 0) {
            _todayCalories = healthKitCalories + manualCalories;
          } else {
            // HealthKit 데이터가 없으면 기존 DB 합계 사용
            // (이미 위에서 _todayCalories = burnedCalories 로 초기화됨)
          }
        });
        
        developer.log('📊 칼로리 계산: HealthKit($healthKitCalories) + Manual($manualCalories) = $_todayCalories');
      }
    } catch (e) {
      developer.log('❌ 운동 데이터 로드 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Health Connect/HealthKit 동기화
  Future<void> _syncHealthData() async {
    developer.log('🚀 동기화 시작');
    setState(() => _isSyncing = true);

    try {
      // 권한 확인
      developer.log('🔐 권한 확인 시작');
      final hasPermission = await _healthService.hasPermissions();
      developer.log('✅ 권한 상태: $hasPermission');

      if (!hasPermission) {
        // 권한 요청
        developer.log('🔑 권한 요청 시작');
        final granted = await _healthService.requestPermissions();
        developer.log('✅ 권한 요청 결과: $granted');

        if (!granted) {
          developer.log('⚠️ 권한 거부됨');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.healthPermissionWarning,
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() => _isSyncing = false);
          return;
        }
      }

      // 동기화 실행
      developer.log('🔄 syncToDatabase() 호출 시작');
      final count = await _healthService.syncToDatabase();
      developer.log('✅ syncToDatabase() 완료: $count개 저장됨');

      setState(() {
        _lastSyncTime = DateTime.now();
        _isSyncing = false;
      });

      // 데이터 새로고침
      developer.log('🔄 UI 데이터 새로고침 시작');
      await _loadTodayData();

      // FutureBuilder 강제 리빌드 (데이터 변경 감지용)
      setState(() {
        _autoRecordsKey = UniqueKey();
      });
      developer.log('✅ UI 데이터 새로고침 및 강제 리빌드 완료');

      // AppProvider 데이터 갱신 (홈 화면 게이지 업데이트용)
      if (mounted) {
        await context.read<AppProvider>().refreshData();
        developer.log('✅ AppProvider 데이터 갱신 완료');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.syncSuccess(count)),
            backgroundColor: Colors.green,
          ),
        );
      }

      developer.log('🎉 동기화 프로세스 완료');
    } catch (e, stackTrace) {
      developer.log('❌ 동기화 실패: $e');
      developer.log('📋 스택 트레이스: $stackTrace');
      setState(() => _isSyncing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.syncError(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exerciseRecord),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFCC80), // 연한 오렌지
                Color(0xFFFFE0B2), // 더 연한 오렌지
              ],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.sync), text: l10n.autoRecord),
            Tab(icon: const Icon(Icons.edit), text: l10n.manualRecord),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 오늘의 운동 요약 헤더
            _buildSummaryHeader(),

            // 동기화 버튼
            _buildSyncButton(),

            // 탭 내용
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildAutoRecordsTab(), _buildManualRecordsTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 수동 입력 다이얼로그 열기
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => const ExerciseInputDialog(),
          );

          // 저장 성공 시 데이터 새로고침
          if (result == true) {
            _loadTodayData();
          }
        },
        backgroundColor: const Color(0xFFFFB74D),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 오늘의 운동 요약 헤더
  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade100, Colors.orange.shade50],
        ),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  icon: Icons.local_fire_department,
                  label: AppLocalizations.of(context)!.caloriesBurned,
                  value: '${_todayCalories.toInt()} kcal',
                  color: Colors.deepOrange,
                ),
                _buildSummaryItem(
                  icon: Icons.directions_run,
                  label: AppLocalizations.of(context)!.workoutCount,
                  value: '$_todayWorkoutCount',
                  color: Colors.blue,
                ),
                _buildSummaryItem(
                  icon: Icons.directions_walk,
                  label: AppLocalizations.of(context)!.steps,
                  value: '$_todaySteps',
                  color: Colors.green,
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// 동기화 버튼
  Widget _buildSyncButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _isSyncing ? null : _syncHealthData,
        icon: _isSyncing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync),
        label: Text(
          _isSyncing
              ? AppLocalizations.of(context)!.syncing
              : AppLocalizations.of(context)!.syncHealthData,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB74D),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  /// 자동 기록 탭
  Widget _buildAutoRecordsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      key: _autoRecordsKey,
      future: _loadAutoRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              AppLocalizations.of(
                context,
              )!.dataLoadError(snapshot.error.toString()),
            ),
          );
        }

        final records = snapshot.data ?? [];

        if (records.isEmpty) {
          return EmptyExerciseState(
            message: AppLocalizations.of(context)!.noAutoRecords,
            subtitle: AppLocalizations.of(context)!.noAutoRecordsSubtitle,
            icon: Icons.sync,
          );
        }

        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            return ExerciseCard(exercise: records[index]);
          },
        );
      },
    );
  }

  /// 수동 기록 탭
  Widget _buildManualRecordsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadManualRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              AppLocalizations.of(
                context,
              )!.dataLoadError(snapshot.error.toString()),
            ),
          );
        }

        final records = snapshot.data ?? [];

        if (records.isEmpty) {
          return EmptyExerciseState(
            message: AppLocalizations.of(context)!.noManualRecords,
            subtitle: AppLocalizations.of(context)!.noManualRecordsSubtitle,
            icon: Icons.add_circle_outline,
          );
        }

        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            return ExerciseCard(exercise: records[index]);
          },
        );
      },
    );
  }

  /// 자동 기록 데이터 로드
  Future<List<Map<String, dynamic>>> _loadAutoRecords() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final allRecords = await _dbService.getExerciseRecordsForDate(today);

    developer.log('📊 오늘 전체 운동 기록: ${allRecords.length}개');
    for (final record in allRecords) {
      developer.log(
        '🔍 기록 상세: id=${record['id']}, source=${record['source']}, exercise_name=${record['exercise_name']}',
      );
    }

    // source가 'manual'이 아닌 것만 필터링
    final autoRecords = allRecords.where((record) {
      final source = record['source'] ?? 'manual';
      final isAuto = source.toLowerCase() != 'manual';
      developer.log('🔍 필터링: source="$source" -> isAuto=$isAuto');
      return isAuto;
    }).toList();

    developer.log('✅ 자동 기록 필터링 결과: ${autoRecords.length}개');
    return autoRecords;
  }

  /// 수동 기록 데이터 로드
  Future<List<Map<String, dynamic>>> _loadManualRecords() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final allRecords = await _dbService.getExerciseRecordsForDate(today);

    // source가 'manual'인 것만 필터링
    return allRecords.where((record) {
      final source = record['source'] ?? 'manual';
      return source.toLowerCase() == 'manual';
    }).toList();
  }

  /// 운동 기록 화면 진입 시 자동 동기화
  Future<void> _autoSyncOnScreenEntry() async {
    try {
      developer.log('🏃 운동 기록 화면 진입 - 자동 동기화 확인');

      // 마지막 동기화 시간 확인 (5분 이내에 동기화했으면 건너뜀)
      final shouldSkipSync =
          _lastSyncTime != null &&
          DateTime.now().difference(_lastSyncTime!).inMinutes < 5;

      if (shouldSkipSync) {
        developer.log('⏭️ 최근 동기화(5분 이내)로 자동 동기화 건너뜀');
        return;
      }

      // 권한 확인 (권한 없으면 조용히 건너뜀)
      final hasPermission = await _healthService.hasPermissions();
      if (!hasPermission) {
        developer.log('ℹ️ 헬스 권한 없음 - 자동 동기화 건너뜀');
        return;
      }

      developer.log('🔄 운동 기록 화면 자동 동기화 시작');

      // 자동 동기화 실행 (UI 차단 없이 백그라운드)
      final count = await _healthService.syncToDatabase();

      if (count > 0) {
        developer.log('✅ 자동 동기화 완료: $count개 새 기록');
        setState(() {
          _lastSyncTime = DateTime.now();
        });

        // 데이터 새로고침
        await _loadTodayData();
        setState(() {
          _autoRecordsKey = UniqueKey(); // FutureBuilder 강제 리빌드
        });

        // AppProvider 데이터 갱신 (홈 화면 게이지 업데이트)
        if (mounted) {
          await context.read<AppProvider>().refreshData();
        }

        // 사용자에게 자동 동기화 완료 알림 (옵션)
        if (mounted && count > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('자동 동기화 완료: ${count}개의 운동 기록을 추가했습니다'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green.shade600,
            ),
          );
        }
      } else {
        developer.log('ℹ️ 자동 동기화: 새로운 기록 없음');
      }
    } catch (e) {
      developer.log('⚠️ 운동 기록 화면 자동 동기화 실패: $e');
      // 자동 동기화 실패는 사용자에게 알리지 않음 (조용히 실패)
    }
  }
}
