import 'package:flutter/material.dart';
import 'package:chiyuhada_vita_buddy/services/health_data_service.dart';
import 'package:chiyuhada_vita_buddy/services/database_service.dart';
import 'package:chiyuhada_vita_buddy/widgets/exercise_card.dart';
import 'package:chiyuhada_vita_buddy/widgets/exercise_input_dialog.dart';
import 'package:provider/provider.dart';
import 'package:chiyuhada_vita_buddy/providers/app_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodayData();
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
      final burnedCalories = await _dbService.getTotalBurnedCaloriesForDate(today);

      setState(() {
        _todayWorkoutCount = exercises.length;
        _todayCalories = burnedCalories;
        _isLoading = false;
      });

      // 헬스 데이터에서 걸음 수 가져오기 (백그라운드, 권한 확인)
      final hasPermission = await _healthService.hasPermissions();
      if (hasPermission) {
        final steps = await _healthService.getTodaySteps();
        setState(() => _todaySteps = steps);
      }
    } catch (e) {
      developer.log('❌ 운동 데이터 로드 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Health Connect/HealthKit 동기화
  Future<void> _syncHealthData() async {
    setState(() => _isSyncing = true);

    try {
      // 권한 확인
      final hasPermission = await _healthService.hasPermissions();
      if (!hasPermission) {
        // 권한 요청
        final granted = await _healthService.requestPermissions();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('헬스 데이터 권한이 필요합니다'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() => _isSyncing = false);
          return;
        }
      }

      // 동기화 실행
      final count = await _healthService.syncToDatabase();
      
      setState(() {
        _lastSyncTime = DateTime.now();
        _isSyncing = false;
      });

      // 데이터 새로고침
      await _loadTodayData();
      
      // AppProvider 데이터 갱신 (홈 화면 게이지 업데이트용)
      if (mounted) {
        await context.read<AppProvider>().refreshData();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $count개의 운동 데이터 동기화 완료'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      developer.log('❌ 동기화 실패: $e');
      setState(() => _isSyncing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('동기화 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 기록'),
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
          tabs: const [
            Tab(icon: Icon(Icons.sync), text: '자동 기록'),
            Tab(icon: Icon(Icons.edit), text: '수동 기록'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 오늘의 운동 요약 헤더
          _buildSummaryHeader(),
          
          // 동기화 버튼
          _buildSyncButton(),
          
          // 탭 내용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAutoRecordsTab(),
                _buildManualRecordsTab(),
              ],
            ),
          ),
        ],
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
                  label: '소모 칼로리',
                  value: '${_todayCalories.toInt()} kcal',
                  color: Colors.deepOrange,
                ),
                _buildSummaryItem(
                  icon: Icons.directions_run,
                  label: '운동 횟수',
                  value: '$_todayWorkoutCount회',
                  color: Colors.blue,
                ),
                _buildSummaryItem(
                  icon: Icons.directions_walk,
                  label: '걸음 수',
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
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
        label: Text(_isSyncing ? '동기화 중...' : 'Health 데이터 동기화'),
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
      future: _loadAutoRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('데이터 로드 실패: ${snapshot.error}'),
          );
        }

        final records = snapshot.data ?? [];
        
        if (records.isEmpty) {
          return const EmptyExerciseState(
            message: '자동 기록된 운동이 없습니다',
            subtitle: 'Health 데이터 동기화 버튼을 눌러\n스마트폰과 웨어러블의 운동 데이터를 불러오세요',
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
            child: Text('데이터 로드 실패: ${snapshot.error}'),
          );
        }

        final records = snapshot.data ?? [];
        
        if (records.isEmpty) {
          return const EmptyExerciseState(
            message: '수동 기록된 운동이 없습니다',
            subtitle: '오른쪽 하단의 + 버튼을 눌러\n운동을 직접 기록해보세요',
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
    
    // source가 'manual'이 아닌 것만 필터링
    return allRecords.where((record) {
      final source = record['source'] ?? 'manual';
      return source.toLowerCase() != 'manual';
    }).toList();
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
}
