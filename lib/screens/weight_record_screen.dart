import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';

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
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.weightLoadFailed}: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addWeightRecord() async {
    final weightText = _weightController.text.trim();
    if (weightText.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterWeight)));
      return;
    }

    final weight = double.tryParse(weightText);
    if (weight == null || weight < 20 || weight > 300) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterValidWeight)));
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

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${weight}kg ${l10n.weightRecorded}')),
      );

      // 입력 필드 초기화
      _weightController.clear();
      _notesController.clear();

      // 기록 새로고침
      await _loadWeightRecords();
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.weightRecordFailed}: $e')));
    }
  }

  Future<void> _deleteWeightRecord(int id) async {
    try {
      // SQLite에서 직접 삭제 (간단한 구현)
      final db = await DatabaseService().database;
      await db.delete('weight_records', where: 'id = ?', whereArgs: [id]);

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.weightRecordDeleted)));

      await _loadWeightRecords();
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.deleteFailed}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weightRecord),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeightRecords,
            tooltip: l10n.refreshTooltip,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
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
                        ? Center(child: Text(l10n.noWeightRecords))
                        : _buildRecordsList(),
                  ),
                ],
              ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWeightDialog(),
        tooltip: '${l10n.add} ${l10n.weightRecord}',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeightInput() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todaysWeight,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${l10n.weight} (kg)',
                      hintText: l10n.weightHint,
                      suffixText: 'kg',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addWeightRecord,
                  child: Text(l10n.record),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.noteOptional,
                hintText: l10n.noteHint,
                border: const OutlineInputBorder(),
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
            Text(
              AppLocalizations.of(context)!.weightTrend,
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
                        ).colorScheme.primary.withAlpha(26), // 0.1 opacity
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.add} ${l10n.weightRecord}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${l10n.weight} (kg)',
                hintText: l10n.weightHint,
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.noteOptional,
                hintText: l10n.noteHint,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addWeightRecord();
            },
            child: Text(l10n.record),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecord),
        content: Text(l10n.confirmDeleteWeight),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteWeightRecord(id);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
