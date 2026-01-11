import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';
import '../services/food_search_service.dart';
import '../models/food_input_mode.dart';
import '../models/food_search_result.dart';
import '../widgets/barcode_scanner_widget.dart';
import '../l10n/app_localizations.dart';
import 'settings_screen.dart';

class FoodInputScreen extends StatefulWidget {
  const FoodInputScreen({super.key});

  @override
  State<FoodInputScreen> createState() => _FoodInputScreenState();
}

class _FoodInputScreenState extends State<FoodInputScreen> {
  late BuildContext _screenContext; // 음식 입력 화면의 context 저장
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

  // 인터넷 검색 관련
  bool _isOnlineSearch = false; // 로컬 vs 인터넷 검색 토글
  List<FoodSearchResult> _onlineSearchResults = [];
  bool _isOnlineSearching = false;
  String? _onlineSearchQuery;
  FoodSearchResult? _selectedOnlineFood;

  // 각 API별 검색 결과
  Map<String, ApiSearchResult>? _apiSearchResults;

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
    _screenContext = context; // ✅ 음식 입력 화면의 context 저장
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
        if (_selectedOnlineFood != null) _buildSelectedOnlineFood(),
        Expanded(
          child: _isOnlineSearch
              ? _buildOnlineSearchResults()
              : _isLoading
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
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context)?.search100gHint ??
                    '100g당 입력은 검색 탭을 이용해주세요.',
              ),
            ),
          ),
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
          // 검색 모드 토글 (로컬/인터넷)
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(
                        AppLocalizations.of(context)?.localSearch ?? '로컬 검색',
                      ),
                      icon: Icon(Icons.phone_android),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(
                        AppLocalizations.of(context)?.onlineSearch ?? '인터넷 검색',
                      ),
                      icon: Icon(Icons.cloud),
                    ),
                  ],
                  selected: {_isOnlineSearch},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _isOnlineSearch = newSelection.first;
                      // 검색 결과 초기화
                      _onlineSearchResults.clear();
                      _onlineSearchQuery = null;
                      _selectedOnlineFood = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              // 바코드 스캔 버튼
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanBarcode,
                tooltip: '바코드 스캔',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 검색 필드
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _isOnlineSearch
                  ? AppLocalizations.of(context)?.searchOnlineHint ??
                        '인터넷에서 음식 검색...'
                  : AppLocalizations.of(context)!.searchFoodHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isOnlineSearch
                  ? IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _performOnlineSearch,
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: _isOnlineSearch ? (_) => _performOnlineSearch() : null,
          ),

          if (!_isOnlineSearch) ...[
            const SizedBox(height: 12),
            // 카테고리 필터 (로컬 검색만)
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

  /// 인터넷 검색 결과 표시 (각 API별 상태 표시)
  Widget _buildOnlineSearchResults() {
    if (_isOnlineSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    // 바코드 검색 결과가 있으면 직접 표시
    if (_onlineSearchResults.isNotEmpty && _apiSearchResults == null) {
      return SafeArea(
        child: ListView(
          children: _onlineSearchResults.map(_buildOnlineFoodItem).toList(),
        ),
      );
    }

    if (_apiSearchResults == null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)?.onlineSearch ?? '인터넷 검색'),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)?.searchFoodHint ??
                    '음식명을 입력하고 검색 버튼을 눌러주세요',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 유효한 결과가 있는 API를 상단으로 정렬
    final sortedKeys = _apiSearchResults!.keys.toList()
      ..sort((a, b) {
        final aSuccess = _apiSearchResults![a]!.status == SearchStatus.success;
        final bSuccess = _apiSearchResults![b]!.status == SearchStatus.success;
        if (aSuccess && !bSuccess) return -1;
        if (!aSuccess && bSuccess) return 1;
        return 0; // 기존 순서 유지
      });

    return SafeArea(
      child: ListView(
        children: sortedKeys.map((key) {
          return _buildApiSection(_apiSearchResults![key]!);
        }).toList(),
      ),
    );
  }

  /// 각 API 섹션 표시
  Widget _buildApiSection(ApiSearchResult apiResult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Container(
          padding: const EdgeInsets.all(16),
          color: apiResult.headerColor,
          child: Row(
            children: [
              Icon(apiResult.apiIcon, color: apiResult.textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${apiResult.displayName} (${apiResult.statusText})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: apiResult.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 검색 결과 또는 상태 메시지
        if (apiResult.status == SearchStatus.success) ...[
          ...apiResult.results.map(_buildOnlineFoodItem),
        ] else ...[
          _buildApiStatusItem(apiResult),
        ],
      ],
    );
  }

  /// API 상태 아이템 표시
  Widget _buildApiStatusItem(ApiSearchResult apiResult) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: apiResult.headerColor,
      child: ListTile(
        leading: Icon(apiResult.statusIcon, color: apiResult.textColor),
        title: Text(
          apiResult.statusTitle,
          style: TextStyle(
            color: apiResult.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          apiResult.statusDescription,
          style: TextStyle(color: apiResult.textColor.withOpacity(0.8)),
        ),
        onTap: apiResult.status == SearchStatus.notConfigured
            ? () => _navigateToSettings()
            : null,
      ),
    );
  }

  /// 설정 화면으로 이동 (API 키 설정 유도)
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    ).then((_) {
      // 설정에서 돌아왔을 때 검색 재시도 가능하도록 상태 업데이트 필요 시 처리
    });
  }

  /// 인터넷 검색 음식 아이템
  Widget _buildOnlineFoodItem(FoodSearchResult food) {
    final isSelected = _selectedOnlineFood?.name == food.name;
    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final totalCalories = food.caloriesPer100g != null
        ? (food.caloriesPer100g! * quantity).round()
        : 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : food.sourceBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: food.sourceColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: food.sourceBadgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                food.sourceIcon,
                color: food.sourceTextColor,
                size: 20,
              ),
            ),
            title: Text(
              food.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: food.sourceTextColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (food.caloriesPer100g != null)
                  Text(
                    '${food.caloriesPer100g}kcal / 100g',
                    style: TextStyle(
                      color: food.sourceTextColor.withOpacity(0.8),
                    ),
                  ),
                if (food.brand != null)
                  Text(
                    '브랜드: ${food.brand}',
                    style: TextStyle(
                      fontSize: 12,
                      color: food.sourceTextColor.withOpacity(0.7),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: food.sourceBadgeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    food.sourceDisplayText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: food.sourceTextColor,
                    ),
                  ),
                ),
              ],
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Icon(Icons.add_circle_outline, color: food.sourceColor),
            onTap: food.caloriesPer100g == null || food.caloriesPer100g == 0
                ? () => _showCalorieInputDialog(context, food)
                : () => _selectOnlineFood(food),
            selected: isSelected,
          ),
          if (isSelected && food.caloriesPer100g != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: food.sourceBackgroundColor.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)?.quantityLabel ?? '수량:',
                    style: TextStyle(
                      color: food.sourceTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: food.sourceColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: food.sourceColor,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '= ${totalCalories}kcal',
                    style: TextStyle(
                      color: food.sourceTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _addOnlineFoodToIntake(food),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: food.sourceColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.of(context)?.addFood ?? '추가'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 선택된 온라인 음식 표시
  Widget _buildSelectedOnlineFood() {
    if (_selectedOnlineFood == null) return const SizedBox.shrink();

    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final totalCalories = _selectedOnlineFood!.caloriesPer100g != null
        ? (_selectedOnlineFood!.caloriesPer100g! * quantity).round()
        : 0;

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
                  _selectedOnlineFood!.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedOnlineFood!.caloriesPer100g != null)
                  Text(
                    '${_selectedOnlineFood!.caloriesPer100g}kcal / 100g',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                Text(
                  _selectedOnlineFood!.sourceDisplayText,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
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

  /// 온라인 음식 선택
  void _selectOnlineFood(FoodSearchResult food) {
    setState(() {
      _selectedOnlineFood = food;
      _quantityController.text = '1';
    });
  }

  /// 온라인 음식을 섭취에 추가
  Future<void> _addOnlineFoodToIntake(FoodSearchResult food) async {
    if (food.caloriesPer100g == null) return;

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidQuantity)),
      );
      return;
    }

    final totalCalories = (food.caloriesPer100g! * quantity).round();

    try {
      // 로컬 DB에 저장 (재사용을 위해)
      final foodId = await DatabaseService().addFood(
        food.name,
        food.caloriesPer100g!,
      );

      // 섭취 기록
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).addFoodIntake(foodId, quantity, totalCalories.toDouble());

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
          content: Text('${food.name} ${totalCalories}kcal ${l10n.foodAdded}'),
        ),
      );

      // 선택 초기화
      setState(() {
        _selectedOnlineFood = null;
        _quantityController.text = '1';
      });

      // 화면 닫기
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('온라인 음식 추가 실패: $e');
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.foodAddFailed}: $e')));
    }
  }

  /// 바코드 스캔
  Future<void> _scanBarcode() async {
    await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWidget(
          onBarcodeDetected: (barcode) async {
            // ✅ 검색 시작 (검색 완료 후 검색 결과를 표시하고 사용자가 선택할 때까지 기다림)
            await _searchFoodByBarcode(barcode);
            // 검색 완료 후 바로 화면을 닫지 않고, 사용자가 음식을 선택할 때까지 기다림
          },
          onClose: () {
            // ✅ 콜백에서 저장된 context 사용
            if (mounted) {
              Navigator.of(_screenContext).pop();
            }
          },
        ),
      ),
    );
  }

  /// 바코드로 음식 검색 (각 API별 결과 표시)
  Future<void> _searchFoodByBarcode(String barcode) async {
    // 검색 중복 방지
    if (_isOnlineSearching) return;

    try {
      if (mounted) {
        setState(() {
          _isOnlineSearching = true;
          _selectedSourceTab = 2; // ✅ 검색 탭으로 즉시 전환
          _isOnlineSearch = true; // ✅ 인터넷 검색 모드 즉시 활성화
          _onlineSearchQuery = '바코드($barcode) 검색 중...';
          _apiSearchResults = null;
          _onlineSearchResults = [];
        });
      }

      final foodService = FoodSearchService();
      // 각 API별 결과를 개별적으로 얻어서 표시
      final apiResults = await foodService.searchFoodsByApi(
        barcode,
        limit: 5,
        barcode: barcode, // 바코드 검색 모드 활성화
      );

      // mounted 체크 후 UI 업데이트
      if (mounted) {
        // 각 API별 결과를 저장 (인터넷 검색과 동일한 방식)
        setState(() {
          _isOnlineSearching = false;
          _apiSearchResults = apiResults;
          _onlineSearchResults = []; // 호환성을 위해 빈 리스트로 설정
          _onlineSearchQuery = '바코드 검색 결과: $barcode'; // 검색 쿼리 표시
        });
      }
    } catch (e) {
      // mounted 체크 후 에러 처리
      if (mounted) {
        setState(() => _isOnlineSearching = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('바코드 검색 실패: $e')));
      }
    }
  }

  /// 온라인 검색 수행
  Future<void> _performOnlineSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isOnlineSearching = true;
      _onlineSearchQuery = query;
      _onlineSearchResults.clear();
      _apiSearchResults = null;
      _selectedOnlineFood = null;
    });

    try {
      final foodService = FoodSearchService();
      final apiResults = await foodService.searchFoodsByApi(query, limit: 10);

      // 각 API 결과를 합쳐서 기존 포맷으로 변환 (하위 호환성 유지)
      final allResults = <FoodSearchResult>[];
      apiResults.forEach((apiName, apiResult) {
        if (apiResult.status == SearchStatus.success) {
          allResults.addAll(apiResult.results);
        }
      });

      setState(() {
        _apiSearchResults = apiResults;
        _onlineSearchResults = allResults;
        _isOnlineSearching = false;
      });
    } catch (e) {
      print('온라인 검색 실패: $e');
      setState(() => _isOnlineSearching = false);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('검색 실패: $e')));
      }
    }
  }

  /// 칼로리 없는 음식에 대한 입력 다이얼로그
  Future<void> _showCalorieInputDialog(
    BuildContext context,
    FoodSearchResult food,
  ) async {
    final controller = TextEditingController();
    final quantityController = TextEditingController(text: '100'); // 기본 100g

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${food.name} 칼로리 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)?.calorieInfoNotFound ??
                  '이 음식의 칼로리 정보를 찾을 수 없습니다.\n'
                      '구글에서 검색하거나 직접 입력해주세요.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            // 구글 검색 버튼
            OutlinedButton.icon(
              icon: const Icon(Icons.search),
              label: Text(
                AppLocalizations.of(context)?.searchGoogle ?? '구글에서 검색',
              ),
              onPressed: () async {
                final url =
                    'https://www.google.com/search?q=${Uri.encodeComponent("${food.name} calories per 100g")}';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            // 직접 입력
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '칼로리 (kcal)',
                hintText: '100g당 칼로리 입력',
                border: OutlineInputBorder(),
                suffixText: 'kcal / 100g',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? '취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final caloriesText = controller.text.trim();
              if (caloriesText.isNotEmpty) {
                final calories = double.tryParse(caloriesText);
                if (calories != null && calories > 0) {
                  // 사용자 입력 칼로리로 음식 업데이트
                  final updatedFood = FoodSearchResult(
                    name: food.name,
                    caloriesPer100g: calories,
                    brand: food.brand,
                    dataSource: 'user_input', // 사용자 입력 표시
                    imageUrl: food.imageUrl,
                    rawData: food.rawData,
                  );

                  // 로컬 DB에 저장
                  await DatabaseService().addFood(food.name, calories);

                  Navigator.pop(context);

                  // 선택된 음식으로 설정
                  setState(() {
                    _selectedOnlineFood = updatedFood;
                    _quantityController.text = '1';
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)?.calorieInfoSaved ??
                              '칼로리 정보가 저장되었습니다',
                        ),
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                                context,
                              )?.enterValidCaloriesDialog ??
                              '올바른 칼로리 값을 입력해주세요',
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: Text(AppLocalizations.of(context)?.save ?? '저장'),
          ),
        ],
      ),
    );
  }
}
