import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../utils/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String date;
  final Map<String, dynamic> summaryData;

  const HistoryDetailScreen({
    super.key,
    required this.date,
    required this.summaryData,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, List<dynamic>>> _detailsFuture;
  late Map<String, dynamic> _realtimeSummaryData; // 실시간 요약 데이터

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _realtimeSummaryData = Map.from(widget.summaryData); // 초기값 복사
    _loadDetails();
  }

  void _loadDetails() {
    _detailsFuture = _fetchDetails();
    _updateRealtimeSummary(); // 실시간 요약 데이터 업데이트
  }

  Future<Map<String, List<dynamic>>> _fetchDetails() async {
    final db = DatabaseService();
    final date = widget.date;

    final foods = await db.getFoodIntakesForDate(date);
    final exercises = await db.getExerciseRecordsForDate(date);
    // 체중 기록은 별도 API가 없어서 전체 조회 후 필터링하거나,
    // 여기서는 간단히 요약 데이터의 체중만 보여주는 것으로 처리할 수도 있음.
    // 하지만 상세 기록을 위해 weight_records 테이블 조회가 필요하다면 추가해야 함.
    // 현재는 음식과 운동 위주로 보여줌.

    return {'foods': foods, 'exercises': exercises};
  }

  /// 실시간 요약 데이터 계산 및 업데이트
  Future<void> _updateRealtimeSummary() async {
    final db = DatabaseService();
    final date = widget.date;

    final foods = await db.getFoodIntakesForDate(date);
    final exercises = await db.getExerciseRecordsForDate(date);

    // 실시간 계산
    final totalIntake = foods.fold(
      0.0,
      (sum, food) => sum + (food['calories'] as double? ?? 0.0),
    );
    final totalBurned = exercises.fold(
      0.0,
      (sum, ex) => sum + (ex['calories_burned'] as double? ?? 0.0),
    );

    setState(() {
      _realtimeSummaryData = {
        'total_intake': totalIntake,
        'total_burned': totalBurned,
        'weight': widget.summaryData['weight'], // 체중은 유지
      };
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intake = widget.summaryData['total_intake'] as double? ?? 0.0;
    final burned = widget.summaryData['total_burned'] as double? ?? 0.0;
    final weight = widget.summaryData['weight'] as double?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.date,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.mealsTab),
            Tab(text: AppLocalizations.of(context)!.exercisesTab),
            Tab(text: AppLocalizations.of(context)!.summaryTab),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${AppLocalizations.of(context)!.errorOccurred}: ${snapshot.error}',
              ),
            );
          }

          final data = snapshot.data!;
          final foods = data['foods'] as List<Map<String, dynamic>>;
          final exercises = data['exercises'] as List<Map<String, dynamic>>;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildFoodList(foods),
              _buildExerciseList(exercises),
              _buildSummaryView(intake, burned, weight),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFoodList(List<Map<String, dynamic>> foods) {
    if (foods.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noMealRecords));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final item = foods[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.orange),
            title: Text(
              item['food_name'] ?? AppLocalizations.of(context)!.unknownFood,
            ),
            subtitle: Text(item['time'].toString().substring(11, 16)),
            trailing: Text(
              '${(item['calories'] as double).toInt()} kcal',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onLongPress: () => _showFoodEditDialog(item),
          ),
        );
      },
    );
  }

  Widget _buildExerciseList(List<Map<String, dynamic>> exercises) {
    if (exercises.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noExerciseRecords),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final item = exercises[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.fitness_center, color: Colors.blue),
            title: Text(
              item['exercise_name'] ?? AppLocalizations.of(context)!.exercise,
            ),
            subtitle: Text('${item['duration_minutes']}분 수행'),
            trailing: Text(
              '-${(item['calories_burned'] as double).toInt()} kcal',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryView(double intake, double burned, double? weight) {
    // 실시간 요약 데이터 사용 (수정 반영)
    final realtimeIntake =
        _realtimeSummaryData['total_intake'] as double? ?? intake;
    final realtimeBurned =
        _realtimeSummaryData['total_burned'] as double? ?? burned;
    final realtimeWeight = _realtimeSummaryData['weight'] as double? ?? weight;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildSummaryCard(
            AppLocalizations.of(context)!.totalIntakeCalories,
            '${realtimeIntake.toInt()} kcal',
            Icons.restaurant_menu,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            AppLocalizations.of(context)!.totalBurnedCalories,
            '${realtimeBurned.toInt()} kcal',
            Icons.local_fire_department,
            Colors.red,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            AppLocalizations.of(context)!.recordedWeight,
            realtimeWeight != null
                ? '${realtimeWeight.toStringAsFixed(1)} kg'
                : AppLocalizations.of(context)!.noRecord,
            Icons.monitor_weight,
            Colors.blue,
          ),
          const SizedBox(height: 32),
          Text(
            '${AppLocalizations.of(context)!.netCalorieChange}: ${(realtimeIntake - realtimeBurned).toInt()} kcal',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 음식 기록 수정 다이얼로그
  Future<void> _showFoodEditDialog(Map<String, dynamic> foodItem) async {
    final l10n = AppLocalizations.of(context)!;
    final quantityController = TextEditingController(
      text: (foodItem['quantity'] as double?)?.toString() ?? '1.0',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.edit} ${foodItem['food_name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 현재 정보 표시
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.current}: ${foodItem['food_name']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${l10n.quantity}: ${foodItem['quantity']}회분'),
                  Text(
                    '${l10n.calories}: ${(foodItem['calories'] as double).toInt()} kcal',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 수량 수정 필드
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.quantity,
                hintText: l10n.quantityHint,
                suffixText: '회분',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          // 삭제 버튼
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.confirm),
                  content: Text('${foodItem['food_name']}을(를) 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await DatabaseService().deleteFoodIntake(foodItem['id']);
                  if (mounted) {
                    Navigator.pop(context, true); // 수정 다이얼로그 닫기
                    _loadDetails(); // 데이터 새로고침
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('삭제되었습니다')));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.saveError}: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),

          // 수정 버튼
          ElevatedButton(
            onPressed: () async {
              final newQuantity = double.tryParse(quantityController.text);
              if (newQuantity == null || newQuantity <= 0) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.invalidQuantity)));
                return;
              }

              // 칼로리 재계산 (기존 음식의 100g당 칼로리 사용)
              final caloriesPer100g =
                  foodItem['calories_per_100g'] as double? ?? 0.0;
              final newCalories = caloriesPer100g * newQuantity;

              try {
                await DatabaseService().updateFoodIntake(
                  foodItem['id'],
                  quantity: newQuantity,
                  calories: newCalories,
                );

                if (mounted) {
                  Navigator.pop(context, true); // 수정 다이얼로그 닫기

                  // AppProvider 데이터 즉시 동기화 (칼로리바 업데이트)
                  await context.read<AppProvider>().refreshData();

                  _loadDetails(); // HistoryDetailScreen 요약 데이터 새로고침
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.goalSaved)));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.saveError}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    // 수정이 완료되었으면 부모 화면에 알림 (필요시)
    if (result == true) {
      // 상위 화면 새로고침을 위해 콜백 호출 가능
    }
  }
}
