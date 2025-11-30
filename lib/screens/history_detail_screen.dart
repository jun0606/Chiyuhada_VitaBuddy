import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';
import '../utils/app_colors.dart';

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

class _HistoryDetailScreenState extends State<HistoryDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, List<dynamic>>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDetails();
  }

  void _loadDetails() {
    _detailsFuture = _fetchDetails();
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
    
    return {
      'foods': foods,
      'exercises': exercises,
    };
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
          style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
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
          tabs: const [
            Tab(text: '식사'),
            Tab(text: '운동'),
            Tab(text: '요약'),
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
            return Center(child: Text('오류 발생: ${snapshot.error}'));
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
      return const Center(child: Text('기록된 식사가 없습니다.'));
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
            title: Text(item['food_name'] ?? '알 수 없는 음식'),
            subtitle: Text('${item['time'].toString().substring(11, 16)}'),
            trailing: Text(
              '${(item['calories'] as double).toInt()} kcal',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseList(List<Map<String, dynamic>> exercises) {
    if (exercises.isEmpty) {
      return const Center(child: Text('기록된 운동이 없습니다.'));
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
            title: Text(item['exercise_name'] ?? '운동'),
            subtitle: Text('${item['duration_minutes']}분 수행'),
            trailing: Text(
              '-${(item['calories_burned'] as double).toInt()} kcal',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryView(double intake, double burned, double? weight) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildSummaryCard('총 섭취 칼로리', '${intake.toInt()} kcal', Icons.restaurant_menu, Colors.orange),
          const SizedBox(height: 16),
          _buildSummaryCard('총 소비 칼로리', '${burned.toInt()} kcal', Icons.local_fire_department, Colors.red),
          const SizedBox(height: 16),
          _buildSummaryCard('기록된 체중', weight != null ? '${weight.toStringAsFixed(1)} kg' : '기록 없음', Icons.monitor_weight, Colors.blue),
          const SizedBox(height: 32),
          Text(
            '순수 칼로리 변동: ${(intake - burned).toInt()} kcal',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
              Text(title, style: const TextStyle(color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
            ],
          ),
        ],
      ),
    );
  }
}
