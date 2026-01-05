import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';
import '../models/food_input_mode.dart';
import '../l10n/app_localizations.dart';

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

  // 전체 칼로리 모드용
  final _totalCalorieFoodNameController = TextEditingController();
  final _totalCalorieValueController = TextEditingController();

  // 1회 제공량 모드용
  final _servingFoodNameController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _servingCaloriesController = TextEditingController();
  final _servingCountController = TextEditingController(text: '1');

  List<Map<String, dynamic>> _foods = [];
  List<Map<String, dynamic>> _filteredFoods = [];
  Map<String, dynamic>? _selectedFood;
  bool _isLoading = false;
  String _selectedCategory = 'catTotal';

  // 입력 모드
  FoodInputMode _inputMode = FoodInputMode.totalCalories;

  // 최근 음식 & 즐겨찾기
  List<Map<String, dynamic>> _recentFoods = [];
  List<Map<String, dynamic>> _favorites = [];
  Set<int> _favoriteFoodIds = {}; // 빠른 조회용

  // 소스 탭
  int _selectedSourceTab = 0; // 0: 최근, 1: 즐겨찾기, 2: 검색, 3: 직접

  // 직접 추가 시 선택된 카테고리
  String _selectedCustomCategory = '기타';

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

  String _getLocalizedCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case '전체':
        return l10n.catTotal;
      case '과일':
        return l10n.catFruit;
      case '주식':
        return l10n.catStaple;
      case '국':
        return l10n.catSoup;
      case '육류':
        return l10n.catMeat;
      case '어류':
        return l10n.catFish;
      case '반찬':
        return l10n.catSide;
      case '야채':
        return l10n.catVegetable;
      case '유제품':
        return l10n.catDairy;
      case '제과':
        return l10n.catBakery;
      case '과자':
        return l10n.catSnack;
      case '음료':
        return l10n.catBeverage;
      case '기타':
        return l10n.catEtc;
      default:
        // DB에서 가져온 추가 카테고리가 있다면 그대로 표시
        return category;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFoods();
    _loadRecentAndFavorites();
    _searchController.addListener(_filterFoods);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _customFoodController.dispose();
    _customCaloriesController.dispose();
    _totalCalorieFoodNameController.dispose();
    _totalCalorieValueController.dispose();
    _servingFoodNameController.dispose();
    _servingSizeController.dispose();
    _servingCaloriesController.dispose();
    _servingCountController.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    setState(() => _isLoading = true);
    try {
      _foods = await DatabaseService().getFoods();
      _filterFoods();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.loadFoodsFailed}: $e'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRecentAndFavorites() async {
    try {
      final recent = await DatabaseService().getRecentFoods(days: 7);
      final favs = await DatabaseService().getFavorites();
      final cats = await DatabaseService().getUniqueCategories();

      setState(() {
        _recentFoods = recent;
        _favorites = favs;
        _favoriteFoodIds = favs.map((f) => f['id'] as int).toSet();

        // 기본 카테고리와 DB 카테고리 병합 (중복 제거)
        final Set<String> allCats = {..._categories, ...cats};
        _categories.clear();
        _categories.addAll(allCats.toList()..sort());
      });
    } catch (e) {
      // 조용히 실패 (선택적 기능이므로)
      print('최근 음식/즐겨찾기/카테고리 로드 실패: $e');
    }
  }

  void _filterFoods() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (_selectedCategory == 'catTotal') {
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invalidQuantity)));
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

      // 즉시 아바타 반응 트리거
      if (context.mounted) {
        Provider.of<AppProvider>(
          context,
          listen: false,
        ).triggerFoodAddedCeremony();
      }

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedFood!['name']} ${totalCalories}kcal ${l10n.foodAdded}',
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.foodAddFailed}: $e')));
    }
  }

  Future<void> _addCustomFood() async {
    final foodName = _customFoodController.text.trim();
    final caloriesText = _customCaloriesController.text.trim();

    if (foodName.isEmpty || caloriesText.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterFoodNameAndCalories)));
      return;
    }

    final calories = double.tryParse(caloriesText);
    if (calories == null || calories <= 0) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterValidCalories)));
      return;
    }

    try {
      final l10n = AppLocalizations.of(context)!;
      final foodId = await DatabaseService().addFood(foodName, calories);
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).addFoodIntake(foodId, 1.0, calories);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$foodName ${calories.toInt()}kcal ${l10n.foodAdded}'),
        ),
      );

      // 입력 필드 초기화
      _customFoodController.clear();
      _customCaloriesController.clear();
      _loadFoods(); // 목록 새로고침
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.userFoodAddFailed}: $e')));
    }
  }

  /// 전체 칼로리 모드로 음식 추가
  Future<void> _addTotalCalorie() async {
    final foodName = _totalCalorieFoodNameController.text.trim();
    final caloriesText = _totalCalorieValueController.text.trim();
    final quantityText = _quantityController.text.trim();

    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterFoodName)),
      );
      return;
    }
    if (caloriesText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enterFoodNameAndCalories),
        ),
      );
      return;
    }

    final calories = double.tryParse(caloriesText);
    final quantity = double.tryParse(quantityText) ?? 1.0;

    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enterValidCalories),
        ),
      );
      return;
    }

    final totalCalories = calories * quantity;

    try {
      // DB에 100g당 칼로리로 저장 (호환성 유지)
      final foodId = await DatabaseService().addFood(
        foodName,
        calories,
        category: _selectedCustomCategory,
      );
      final l10n = AppLocalizations.of(context)!;
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).addFoodIntake(foodId, quantity, totalCalories);

      // 즉시 아바타 반응 트리거
      if (context.mounted) {
        Provider.of<AppProvider>(
          context,
          listen: false,
        ).triggerFoodAddedCeremony();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$foodName ${totalCalories.toInt()}kcal ${l10n.foodAdded}',
          ),
        ),
      );

      // 입력 필드 초기화
      _totalCalorieFoodNameController.clear();
      _totalCalorieValueController.clear();
      _quantityController.text = '1';

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.foodAddFailed}: $e')));
    }
  }

  /// 빠른 기록 (칼로리 나중에 입력)
  Future<void> _addQuickRecord() async {
    final foodName = _totalCalorieFoodNameController.text.trim();

    if (foodName.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterFoodName)));
      return;
    }

    try {
      // 0kcal로 임시 저장
      final foodId = await DatabaseService().addFood(
        foodName,
        0.0,
        category: _selectedCustomCategory,
      );
      final l10n = AppLocalizations.of(context)!;
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).addFoodIntake(foodId, 1.0, 0.0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$foodName ${l10n.quickSaveSuccess}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );

      // 입력 필드 초기화
      _totalCalorieFoodNameController.clear();

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.foodAddFailed}: $e'),
        ),
      );
    }
  }

  /// 1회 제공량 모드로 음식 추가
  Future<void> _addServingSize() async {
    final foodName = _servingFoodNameController.text.trim();
    final servingCaloriesText = _servingCaloriesController.text.trim();
    final servingCountText = _servingCountController.text.trim();

    if (foodName.isEmpty || servingCaloriesText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enterFoodNameAndCalories),
        ),
      );
      return;
    }

    final servingCalories = double.tryParse(servingCaloriesText);
    final servingCount = double.tryParse(servingCountText) ?? 1.0;

    if (servingCalories == null || servingCalories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enterValidCalories),
        ),
      );
      return;
    }

    final totalCalories = servingCalories * servingCount;

    try {
      // DB에 저장
      final foodId = await DatabaseService().addFood(
        foodName,
        servingCalories,
        category: _selectedCustomCategory,
      );
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).addFoodIntake(foodId, servingCount, totalCalories);

      // 즉시 아바타 반응 트리거
      if (context.mounted) {
        Provider.of<AppProvider>(
          context,
          listen: false,
        ).triggerFoodAddedCeremony();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$foodName ${totalCalories.toInt()}kcal ${AppLocalizations.of(context)!.foodAdded}',
          ),
        ),
      );

      // 입력 필드 초기화
      _servingFoodNameController.clear();
      _servingSizeController.clear();
      _servingCaloriesController.clear();
      _servingCountController.text = '1';

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.foodAddFailed}: $e'),
        ),
      );
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> food) async {
    final foodId = food['id'] as int;
    final isFav = _favoriteFoodIds.contains(foodId);

    try {
      if (isFav) {
        await DatabaseService().removeFavorite(foodId);
        setState(() {
          _favoriteFoodIds.remove(foodId);
          _favorites.removeWhere((f) => f['id'] == foodId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${food['name']} ${AppLocalizations.of(context)!.favoriteRemoved}',
              ),
            ),
          );
        }
      } else {
        await DatabaseService().addFavorite(foodId);
        setState(() {
          _favoriteFoodIds.add(foodId);
          _favorites.insert(0, food); // 맨 앞에 추가
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${food['name']} ${AppLocalizations.of(context)!.favoriteAdded}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('즐겨찾기 토글 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.foodInput),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadFoods();
              _loadRecentAndFavorites();
            },
            tooltip: '새로고침',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. 탭 선택 (최근/즐겨찾기/검색/직접) - 항상 표시
            _buildSourceTabSelector(),

            // 2. 탭 내용
            Expanded(child: _buildSourceTabContent()),
          ],
        ),
      ),

      // FAB - 100g당 모드에서 선택된 음식이 있을 때만 표시 (검색 탭에서만 유효)
      floatingActionButton:
          _selectedSourceTab == 2 &&
              _inputMode == FoodInputMode.per100g &&
              _selectedFood != null
          ? FloatingActionButton.extended(
              onPressed: _addFoodIntake,
              icon: const Icon(Icons.add),
              label: Text(l10n.addIntake),
            )
          : null,
    );
  }

  Widget _buildDirectInputForm() {
    if (_inputMode == FoodInputMode.perServing) {
      return _buildServingSizeInput();
    } else {
      return _buildTotalCalorieInput();
    }
  }

  Widget _buildSourceTabSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem(0, AppLocalizations.of(context)!.recent, Icons.history),
          _buildTabItem(1, AppLocalizations.of(context)!.favorites, Icons.star),
          _buildTabItem(2, AppLocalizations.of(context)!.search, Icons.search),
          _buildTabItem(
            3,
            AppLocalizations.of(context)!.customAdd,
            Icons.add_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _selectedSourceTab == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedSourceTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: isSelected
                ? Border(
                    bottom: BorderSide(color: colorScheme.primary, width: 3),
                  )
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceTabContent() {
    switch (_selectedSourceTab) {
      case 0:
        return _buildRecentFoodsTab();
      case 1:
        return _buildFavoritesTab();
      case 2:
        return _buildSearchTab();
      case 3:
        return _buildCustomFoodTab();
      default:
        return _buildSearchTab();
    }
  }

  Widget _buildRecentFoodsTab() {
    if (_recentFoods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.noRecentFoods),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _recentFoods.length,
      itemBuilder: (context, index) {
        final food = _recentFoods[index];
        return _buildFoodItem(food, isRecent: true);
      },
    );
  }

  Widget _buildFavoritesTab() {
    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.noFavoriteFoods),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.addFavoriteHint,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final food = _favorites[index];
        return _buildFoodItem(food);
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        _buildSearchAndFilter(),
        if (_selectedFood != null) _buildSelectedFood(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredFoods.isEmpty
              ? Center(
                  child: Text(AppLocalizations.of(context)!.noSearchResults),
                )
              : ListView.builder(
                  itemCount: _filteredFoods.length,
                  itemBuilder: (context, index) {
                    final food = _filteredFoods[index];
                    return _buildFoodItem(food);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCustomFoodTab() {
    return Column(
      children: [
        // 입력 모드 선택 (전체/1회/100g/빠른)
        _buildInputModeSelector(),

        // 모드별 입력 폼
        if (_inputMode == FoodInputMode.perServing)
          _buildServingSizeInput()
        else if (_inputMode == FoodInputMode.totalCalories ||
            _inputMode == FoodInputMode.quickRecord)
          _buildTotalCalorieInput()
        else
          // 100g당 모드는 여기서 지원하지 않거나 별도 처리 (여기서는 간단히 안내 문구 또는 기존 커스텀 폼 사용)
          // 기존 _addCustomFood 로직을 사용하는 폼을 보여줄 수도 있음.
          // 하지만 일관성을 위해 Total/Serving/Quick 위주로 구성.
          Expanded(child: Center(child: Text('100g당 입력은 검색 탭을 이용해주세요.'))),
      ],
    );
  }

  Widget _buildInputModeSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<FoodInputMode>(
          segments: [
            ButtonSegment(
              value: FoodInputMode.totalCalories,
              label: Text(AppLocalizations.of(context)!.inputModeTotal),
              icon: const Icon(Icons.straighten, size: 16),
            ),
            ButtonSegment(
              value: FoodInputMode.perServing,
              label: Text(AppLocalizations.of(context)!.inputModeServing),
              icon: const Icon(Icons.restaurant_menu, size: 16),
            ),
            ButtonSegment(
              value: FoodInputMode.per100g,
              label: Text(AppLocalizations.of(context)!.inputMode100g),
              icon: const Icon(Icons.balance, size: 16),
            ),
            ButtonSegment(
              value: FoodInputMode.quickRecord,
              label: Text(AppLocalizations.of(context)!.inputModeQuick),
              icon: const Icon(Icons.bolt, size: 16),
            ),
          ],
          selected: {_inputMode},
          onSelectionChanged: (Set<FoodInputMode> newSelection) {
            setState(() {
              _inputMode = newSelection.first;
              // 상태 초기화
              _selectedFood = null;
              _totalCalorieFoodNameController.clear();
              _totalCalorieValueController.clear();
              _servingFoodNameController.clear();
              _servingSizeController.clear();
              _servingCaloriesController.clear();
              _quantityController.text = '1';
              _servingCountController.text = '1';
            });
          },
        ),
      ),
    );
  }

  Widget _buildTotalCalorieInput() {
    final isQuickMode = _inputMode == FoodInputMode.quickRecord;

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 설명
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      isQuickMode ? Icons.bolt : Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isQuickMode
                            ? AppLocalizations.of(context)!.quickRecordHelp
                            : AppLocalizations.of(context)!.totalCalorieHelp,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 음식 이름
            TextField(
              controller: _totalCalorieFoodNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.foodName,
                hintText: AppLocalizations.of(context)!.foodNameHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.restaurant),
              ),
              textInputAction: isQuickMode
                  ? TextInputAction.done
                  : TextInputAction.next,
            ),

            if (!isQuickMode) ...[
              const SizedBox(height: 16),

              // 칼로리
              TextField(
                controller: _totalCalorieValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.calories,
                  hintText: AppLocalizations.of(context)!.caloriesHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.local_fire_department),
                  suffixText: AppLocalizations.of(context)!.caloriesUnit,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // 수량
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.quantity,
                  hintText: '${AppLocalizations.of(context)!.defaultLabel}: 1',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.shopping_bag),
                  suffixText: AppLocalizations.of(context)!.unitServings,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 추가 버튼
            ElevatedButton.icon(
              onPressed: isQuickMode ? _addQuickRecord : _addTotalCalorie,
              icon: Icon(isQuickMode ? Icons.bolt : Icons.add),
              label: Text(
                isQuickMode
                    ? AppLocalizations.of(context)!.saveTemporary
                    : AppLocalizations.of(context)!.add,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServingSizeInput() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 설명
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.servingInfoHelp,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 음식 이름
            TextField(
              controller: _servingFoodNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.foodName,
                hintText: AppLocalizations.of(context)!.foodNameHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.restaurant),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 1회 제공량 칼로리
            TextField(
              controller: _servingCaloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.servingCalories,
                hintText: AppLocalizations.of(context)!.caloriesHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.local_fire_department),
                suffixText: AppLocalizations.of(context)!.caloriesUnit,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 섭취한 횟수
            TextField(
              controller: _servingCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.servingCount,
                hintText: '${AppLocalizations.of(context)!.defaultLabel}: 1',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.repeat),
                suffixText: AppLocalizations.of(context)!.servingUnit,
              ),
            ),

            const SizedBox(height: 24),

            // 추가 버튼
            ElevatedButton.icon(
              onPressed: _addServingSize,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.add),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
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
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchFoodHint,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
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
                    label: Text(_getLocalizedCategory(context, category)),
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
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.quantityHint,
                suffixText: AppLocalizations.of(context)!.servingsHint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
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

  Future<void> _showFoodAddDialog(Map<String, dynamic> food) async {
    _quantityController.text = '1';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(food['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${food['calories_per_100g']}kcal / 100g',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.quantity,
                suffixText: AppLocalizations.of(context)!.unitCount,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              // 다이얼로그 닫기
              Navigator.pop(context);

              // 선택된 음식 설정
              setState(() => _selectedFood = food);

              // 음식 추가
              await _addFoodIntake();
            },
            child: Text(AppLocalizations.of(context)!.addFoodButton),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> food, {bool isRecent = false}) {
    final isSelected = _selectedFood?['id'] == food['id'];
    final foodId = food['id'] as int;
    final isFavorite = _favoriteFoodIds.contains(foodId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(food['name']),
        subtitle: Text(
          isRecent
              ? AppLocalizations.of(context)!.consumedOn(
                  food['last_eaten']?.toString().substring(0, 10) ??
                      AppLocalizations.of(context)!.unknown,
                )
              : '${food['calories_per_100g']}kcal / 100g',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: () => _toggleFavorite(food),
            ),
            if (isRecent)
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () => _showFoodAddDialog(food),
              ),
          ],
        ),
        onTap: () => _showFoodAddDialog(food),
        selected: isSelected,
      ),
    );
  }

  void _showAddCustomFoodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.customAdd),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _customFoodController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.foodName,
                hintText: AppLocalizations.of(context)!.foodNameHint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customCaloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${AppLocalizations.of(context)!.calories} (100g)',
                hintText: AppLocalizations.of(context)!.caloriesHint,
                suffixText: AppLocalizations.of(context)!.caloriesUnit,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addCustomFood();
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }
}
