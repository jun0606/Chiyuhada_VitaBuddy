import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';

class WeightRecordScreen extends StatefulWidget {
  const WeightRecordScreen({super.key});

  @override
  State<WeightRecordScreen> createState() => _WeightRecordScreenState();
}

class _WeightRecordScreenState extends State<WeightRecordScreen> {
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  List<Map<String, dynamic>> _weightRecords = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWeightRecords();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadWeightRecords() async {
    setState(() => _isLoading = true);
    try {
      _weightRecords = await DatabaseService().getWeightRecords();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('체중 기록을 불러오는데 실패했습니다: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addWeightRecord() async {
    final weightText = _weightController.text.trim();
    if (weightText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('체중을 입력해주세요')));
      return;
    }

    final weight = double.tryParse(weightText);
    if (weight == null || weight < 20 || weight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 체중을 입력해주세요 (20-300kg)')),
      );
      return;
    }

    try {
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).updateWeight(weight);

      // 노트가 있는 경우 데이터베이스에 직접 추가
      final notes = _notesController.text.trim();
      if (notes.isNotEmpty) {
        await DatabaseService().addWeightRecord(weight, notes: notes);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${weight}kg 체중이 기록되었습니다')));

      // 입력 필드 초기화
      _weightController.clear();
      _notesController.clear();

      // 기록 새로고침
      await _loadWeightRecords();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('체중 기록에 실패했습니다: $e')));
    }
  }

  Future<void> _deleteWeightRecord(int id) async {
    try {
      // SQLite에서 직접 삭제 (간단한 구현)
      final db = await DatabaseService().database;
      await db.delete('weight_records', where: 'id = ?', whereArgs: [id]);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('체중 기록이 삭제되었습니다')));

      await _loadWeightRecords();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('기록 삭제에 실패했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('체중 기록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeightRecords,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 체중 입력 섹션
                _buildWeightInput(),

                // 차트 섹션
                if (_weightRecords.isNotEmpty) _buildChart(),

                // 기록 목록
                Expanded(
                  child: _weightRecords.isEmpty
                      ? const Center(child: Text('체중 기록이 없습니다'))
                      : _buildRecordsList(),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWeightDialog(),
        tooltip: '체중 기록 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeightInput() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘의 체중', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '체중 (kg)',
                      hintText: '예: 70.5',
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addWeightRecord,
                  child: const Text('기록'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '메모 (선택사항)',
                hintText: '예: 운동 후 측정',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    // 최근 30일 데이터만 표시
    final recentRecords = _weightRecords.take(30).toList().reversed.toList();

    if (recentRecords.length < 2) {
      return const SizedBox.shrink();
    }

    final spots = recentRecords.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final record = entry.value;
      return FlSpot(index, record['weight']);
    }).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('체중 변화 추이', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}kg');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < recentRecords.length) {
                            final date = DateTime.parse(
                              recentRecords[index]['date'],
                            );
                            return Text('${date.month}/${date.day}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    return ListView.builder(
      itemCount: _weightRecords.length,
      itemBuilder: (context, index) {
        final record = _weightRecords[index];
        final date = DateTime.parse(record['date']);
        final weight = record['weight'];
        final notes = record['notes'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${weight}kg',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.year}년 ${date.month}월 ${date.day}일',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (notes != null && notes.isNotEmpty)
                  Text(
                    notes,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(record['id']),
            ),
          ),
        );
      },
    );
  }

  void _showAddWeightDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('체중 기록 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '체중 (kg)',
                hintText: '예: 70.5',
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '메모 (선택사항)',
                hintText: '예: 운동 후 측정',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addWeightRecord();
            },
            child: const Text('기록'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 체중 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteWeightRecord(id);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
