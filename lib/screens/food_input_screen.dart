import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';

class FoodInputScreen extends StatefulWidget {
  const FoodInputScreen({super.key});

  @override
  State<FoodInputScreen> createState() => _FoodInputScreenState();
}

class _FoodInputScreenState extends State<FoodInputScreen> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _customFoodController = TextEditingController();
  final _customCaloriesController = TextEditingController();

  List<Map<String, dynamic>> _foods = [];
  List<Map<String, dynamic>> _filteredFoods = [];
  Map<String, dynamic>? _selectedFood;
  bool _isLoading = false;
  String _selectedCategory = '전체';

  final List<String> _categories = [
    '전체',
    '과일',
    '주식',
    '국',
    '육류',
    '어류',
    '반찬',
    '야채',
    '유제품',
    '제과',
    '과자',
    '음료',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    _loadFoods();
    _searchController.addListener(_filterFoods);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _customFoodController.dispose();
    _customCaloriesController.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    setState(() => _isLoading = true);
    try {
      _foods = await DatabaseService().getFoods();
      _filterFoods();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('음식 데이터를 불러오는데 실패했습니다: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterFoods() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (_selectedCategory == '전체') {
        _filteredFoods = _foods.where((food) {
          return food['name'].toLowerCase().contains(query);
        }).toList();
      } else {
        _filteredFoods = _foods.where((food) {
          return food['name'].toLowerCase().contains(query) &&
              food['category'] == _selectedCategory;
        }).toList();
      }
    });
  }

  void _selectFood(Map<String, dynamic> food) {
    setState(() {
      _selectedFood = food;
      _quantityController.text = '1';
    });
  }

  Future<void> _addFoodIntake() async {
    if (_selectedFood == null) return;

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('올바른 수량을 입력해주세요')));
      return;
    }

    final caloriesPer100g = _selectedFood!['calories_per_100g'];
    final totalCalories = (caloriesPer100g * quantity).round();

    try {
      print('🔍 음식 추가 시도: ${_selectedFood!['name']}, $totalCalories kcal');
      
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).addFoodIntake(_selectedFood!['id'], quantity, totalCalories.toDouble());

      print('✅ 음식 추가 완료');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedFood!['name']} ${totalCalories}kcal 추가되었습니다',
          ),
        ),
      );

      // 선택 초기화
      setState(() {
        _selectedFood = null;
        _quantityController.text = '1';
      });

      // 성공적으로 추가되었음을 알리고 화면 닫기
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ 음식 추가 실패: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('음식 추가에 실패했습니다: $e')));
    }
  }

  Future<void> _addCustomFood() async {
    final foodName = _customFoodController.text.trim();
    final caloriesText = _customCaloriesController.text.trim();

    if (foodName.isEmpty || caloriesText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('음식 이름과 칼로리를 입력해주세요')));
      return;
    }

    final calories = double.tryParse(caloriesText);
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('올바른 칼로리를 입력해주세요')));
      return;
    }

    try {
      final foodId = await DatabaseService().addFood(foodName, calories);
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).addFoodIntake(foodId, 1.0, calories);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$foodName ${calories.toInt()}kcal 추가되었습니다')),
      );

      // 입력 필드 초기화
      _customFoodController.clear();
      _customCaloriesController.clear();
      _loadFoods(); // 목록 새로고침
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('사용자 음식 추가에 실패했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음식 입력'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCustomFoodDialog(),
            tooltip: '직접 음식 추가',
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 카테고리 필터
          _buildSearchAndFilter(),

          // 선택된 음식 표시
          if (_selectedFood != null) _buildSelectedFood(),

          // 음식 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFoods.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다'))
                : ListView.builder(
                    itemCount: _filteredFoods.length,
                    itemBuilder: (context, index) {
                      final food = _filteredFoods[index];
                      return _buildFoodItem(food);
                    },
                  ),
          ),
        ],
      ),

      // 추가 버튼
      floatingActionButton: _selectedFood != null
          ? FloatingActionButton.extended(
              onPressed: _addFoodIntake,
              icon: const Icon(Icons.add),
              label: const Text('섭취 추가'),
            )
          : null,
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // 검색 필드
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: '음식 검색...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // 카테고리 필터
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                      _filterFoods();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFood() {
    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final caloriesPer100g = _selectedFood!['calories_per_100g'];
    final totalCalories = (caloriesPer100g * quantity).round();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFood!['name'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${caloriesPer100g}kcal / 100g',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '수량',
                suffixText: '인분',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${totalCalories}kcal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> food) {
    final isSelected = _selectedFood?['id'] == food['id'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(food['name']),
        subtitle: Text('${food['calories_per_100g']}kcal / 100g'),
        trailing: Text(food['category'] ?? '기타'),
        onTap: () => _selectFood(food),
        selected: isSelected,
      ),
    );
  }

  void _showAddCustomFoodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('직접 음식 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _customFoodController,
              decoration: const InputDecoration(
                labelText: '음식 이름',
                hintText: '예: 김치찌개',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customCaloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '칼로리 (100g당)',
                hintText: '예: 45',
                suffixText: 'kcal',
              ),
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
              _addCustomFood();
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}
