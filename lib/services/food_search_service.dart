import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/food_search_result.dart';

/// 음식 검색을 위한 멀티 API 서비스
/// Open Food Facts와 USDA FoodData Central API를 지원
class FoodSearchService {
  static const String _openFoodFactsBaseUrl =
      'https://world.openfoodfacts.org/cgi/search.pl';
  static const String _usdaBaseUrl = 'https://api.nal.usda.gov/fdc/v1';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // API 키 저장 키
  static const String _usdaApiKeyKey = 'usda_api_key';

  /// USDA API 키 설정
  Future<void> setUsdaApiKey(String apiKey) async {
    await _secureStorage.write(key: _usdaApiKeyKey, value: apiKey);
  }

  /// USDA API 키 가져오기
  Future<String?> getUsdaApiKey() async {
    return await _secureStorage.read(key: _usdaApiKeyKey);
  }

  /// 통합 음식 검색
  /// 두 API를 모두 검색하여 결과를 병합
  Future<List<FoodSearchResult>> searchFoods(
    String query, {
    int limit = 20,
    String? barcode,
  }) async {
    List<FoodSearchResult> results = [];

    try {
      // Open Food Facts 검색
      final openFoodResults = await _searchOpenFoodFacts(
        query,
        limit: limit ~/ 2,
        barcode: barcode,
      );
      results.addAll(openFoodResults);

      // USDA 검색 (API 키가 있는 경우)
      final usdaApiKey = await getUsdaApiKey();
      if (usdaApiKey != null && usdaApiKey.isNotEmpty) {
        final usdaResults = await _searchUSDA(
          query,
          apiKey: usdaApiKey,
          limit: limit ~/ 2,
          barcode: barcode,
        );
        results.addAll(usdaResults);
      }

      // 중복 제거 및 정렬 (칼로리 정보 있는 항목 우선)
      results = _deduplicateAndSort(results);
    } catch (e) {
      print('음식 검색 실패: $e');
      // 에러 발생 시 빈 리스트 반환
    }

    return results.take(limit).toList();
  }

  /// 각 API별 검색 상태 표시
  /// 각 API의 검색 결과를 개별적으로 반환
  Future<Map<String, ApiSearchResult>> searchFoodsByApi(
    String query, {
    int limit = 10,
    String? barcode,
  }) async {
    final results = <String, ApiSearchResult>{};

    // Open Food Facts 검색 (항상 수행)
    try {
      var openFoodResults = await _searchOpenFoodFacts(
        query,
        limit: limit,
        barcode: barcode,
      );

      // 바코드 검색인데 결과가 없으면 폴백: 바코드를 검색어로 사용
      if (barcode != null && barcode.isNotEmpty && openFoodResults.isEmpty) {
        print('Open Food Facts 바코드 검색 실패, 폴백 검색 시도: $barcode');
        openFoodResults = await _searchOpenFoodFacts(
          barcode, // 바코드를 검색어로 사용
          limit: limit,
        );
      }

      results['openFoodFacts'] = ApiSearchResult(
        apiName: 'openFoodFacts',
        results: openFoodResults,
        status: openFoodResults.isNotEmpty
            ? SearchStatus.success
            : SearchStatus.noData,
      );
    } catch (e) {
      print('Open Food Facts 검색 오류: $e');
      results['openFoodFacts'] = ApiSearchResult(
        apiName: 'openFoodFacts',
        results: [],
        status: SearchStatus.error,
      );
    }

    // USDA 검색
    final usdaApiKey = await getUsdaApiKey();
    if (usdaApiKey != null && usdaApiKey.isNotEmpty) {
      try {
        var usdaResults = await _searchUSDA(
          query,
          apiKey: usdaApiKey,
          limit: limit,
          barcode: barcode,
        );

        // 바코드 검색인데 결과가 없으면 폴백: 바코드를 검색어로 사용
        if (barcode != null && barcode.isNotEmpty && usdaResults.isEmpty) {
          print('USDA 바코드 검색 실패, 폴백 검색 시도: $barcode');
          usdaResults = await _searchUSDA(
            barcode, // 바코드를 검색어로 사용
            apiKey: usdaApiKey,
            limit: limit,
          );
        }

        results['usda'] = ApiSearchResult(
          apiName: 'usda',
          results: usdaResults,
          status: usdaResults.isNotEmpty
              ? SearchStatus.success
              : SearchStatus.noData,
        );
      } catch (e) {
        print('USDA 검색 오류: $e');
        results['usda'] = ApiSearchResult(
          apiName: 'usda',
          results: [],
          status: SearchStatus.error,
        );
      }
    } else {
      results['usda'] = ApiSearchResult(
        apiName: 'usda',
        results: [],
        status: SearchStatus.notConfigured,
      );
    }

    return results;
  }

  /// Open Food Facts API 검색
  Future<List<FoodSearchResult>> _searchOpenFoodFacts(
    String query, {
    int limit = 10,
    String? barcode,
  }) async {
    try {
      final Map<String, String> params = {
        'json': 'true',
        'page_size': limit.toString(),
        'fields': 'product_name,brands,nutriments,image_url,code',
      };

      if (barcode != null && barcode.isNotEmpty) {
        // 바코드 검색 시에는 search_terms 대신 code 필드 사용
        params['code'] = barcode;
      } else if (query.isNotEmpty) {
        // 일반 검색 시에만 search_terms 사용
        params['search_terms'] = query;
      }

      final uri = Uri.parse(
        _openFoodFactsBaseUrl,
      ).replace(queryParameters: params);

      print('Open Food Facts API 요청: $uri'); // 디버깅 로그 추가

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'ChiyuhadaVitaBuddy/1.0'},
      );

      print('Open Food Facts API 응답 상태: ${response.statusCode}'); // 디버깅 로그 추가

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List<dynamic>? ?? [];
        final count = data['count'] ?? 0;

        print(
          'Open Food Facts 검색 결과: ${products.length}개 (총 ${count}개)',
        ); // 디버깅 로그 추가

        if (products.isEmpty) {
          print('Open Food Facts API 응답 데이터: $data'); // 디버깅용 전체 응답
        }

        return products.map((product) {
          final nutriments =
              product['nutriments'] as Map<String, dynamic>? ?? {};

          // 칼로리 변환 우선순위
          double? calories = _convertEnergyToKcal(nutriments);

          return FoodSearchResult(
            name: product['product_name'] ?? 'Unknown Product',
            caloriesPer100g: calories,
            brand: product['brands'],
            dataSource: 'openFoodFacts',
            imageUrl: product['image_url'],
            rawData: product,
          );
        }).toList();
      } else {
        print(
          'Open Food Facts API 오류: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Open Food Facts 검색 실패: $e');
    }

    return [];
  }

  /// USDA FoodData Central API 검색
  Future<List<FoodSearchResult>> _searchUSDA(
    String query, {
    required String apiKey,
    int limit = 10,
    String? barcode,
  }) async {
    try {
      final Map<String, String> params = {
        'api_key': apiKey,
        'pageSize': limit.toString(),
      };

      if (barcode != null && barcode.isNotEmpty) {
        // 바코드 검색: GTIN 필드 사용 + Branded만 검색
        params['query'] = 'gtinUpc:$barcode';
        params['dataType'] = 'Branded';
      } else {
        // 일반 검색: dataType 생략 (모든 타입 검색)
        params['query'] = query;
      }

      final uri = Uri.parse(
        '$_usdaBaseUrl/foods/search',
      ).replace(queryParameters: params);

      print('USDA API 요청: $uri'); // 디버깅 로그

      final response = await http.get(uri);

      print('USDA API 응답 상태: ${response.statusCode}'); // 디버깅 로그

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods'] as List<dynamic>? ?? [];
        final totalHits = data['totalHits'] ?? 0;

        print('USDA 검색 결과: ${foods.length}개 (총 ${totalHits}개)'); // 디버깅 로그

        if (foods.isEmpty) {
          print('USDA API 응답 데이터: $data'); // 디버깅용 전체 응답
        }

        return foods.map((food) {
          final nutrients = food['foodNutrients'] as List<dynamic>? ?? [];

          // USDA 영양소에서 칼로리 추출
          double? caloriesPer100g = _extractCaloriesFromUSDANutrients(
            nutrients,
          );

          if (caloriesPer100g == null) {
            print('USDA 칼로리 추출 실패: ${food['description']}'); // 디버깅 로그
          }

          return FoodSearchResult(
            name: food['description'] ?? 'Unknown Food',
            caloriesPer100g: caloriesPer100g,
            brand: food['brandName'] ?? food['brandOwner'],
            dataSource: 'usda',
            rawData: food,
          );
        }).toList();
      } else {
        print('USDA API 오류: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('USDA 검색 실패: $e');
    }

    return [];
  }

  /// 바코드로 음식 검색 (모든 API에서 병렬 검색)
  Future<List<FoodSearchResult>> searchByBarcodeAllAPIs(String barcode) async {
    try {
      print('🔍 바코드 검색 시작 (모든 API): $barcode');

      final results = <FoodSearchResult>[];
      final futures = <Future<List<FoodSearchResult>>>[];

      // Open Food Facts 검색 (바코드 + 폴백)
      futures.add(_searchOpenFoodFacts('', limit: 5, barcode: barcode));
      futures.add(_searchOpenFoodFacts(barcode, limit: 3)); // 폴백 검색

      // USDA 검색 (API 키가 있는 경우)
      final usdaApiKey = await getUsdaApiKey();
      if (usdaApiKey != null && usdaApiKey.isNotEmpty) {
        futures.add(
          _searchUSDA('', apiKey: usdaApiKey, limit: 5, barcode: barcode),
        );
        futures.add(
          _searchUSDA(barcode, apiKey: usdaApiKey, limit: 3),
        ); // 폴백 검색
      }

      // 모든 API 검색 완료 대기
      final apiResults = await Future.wait(futures);

      // 결과 수집
      for (final apiResult in apiResults) {
        results.addAll(apiResult);
      }

      // 바코드 검색은 중복 제거하지 않고 모든 API 결과 표시
      // (사용자가 각 API별 결과를 모두 보고 선택할 수 있도록)
      final sortedResults = results.toList()
        ..sort((a, b) {
          // 칼로리 정보 있는 항목 우선
          if (a.caloriesPer100g != null && b.caloriesPer100g == null) return -1;
          if (a.caloriesPer100g == null && b.caloriesPer100g != null) return 1;
          return a.name.compareTo(b.name);
        });

      print('✅ 바코드 검색 완료: ${sortedResults.length}개 결과 (중복 유지)');
      return sortedResults;
    } catch (e) {
      print('바코드 검색 실패: $e');
      return [];
    }
  }

  /// 기존 호환성을 위한 단일 결과 반환 메서드 (deprecated)
  @deprecated
  Future<FoodSearchResult?> searchByBarcode(String barcode) async {
    final results = await searchByBarcodeAllAPIs(barcode);
    return results.isNotEmpty ? results.first : null;
  }

  /// 검색 결과 중복 제거 및 정렬
  List<FoodSearchResult> _deduplicateAndSort(List<FoodSearchResult> results) {
    // 이름으로 그룹화하여 중복 제거
    final Map<String, FoodSearchResult> uniqueResults = {};

    for (final result in results) {
      final key = result.name.toLowerCase().trim();
      if (!uniqueResults.containsKey(key) ||
          (result.caloriesPer100g != null &&
              uniqueResults[key]?.caloriesPer100g == null)) {
        uniqueResults[key] = result;
      }
    }

    // 칼로리 정보 있는 항목 우선 정렬
    final sorted = uniqueResults.values.toList()
      ..sort((a, b) {
        // 칼로리 정보 있는 항목 우선
        if (a.caloriesPer100g != null && b.caloriesPer100g == null) return -1;
        if (a.caloriesPer100g == null && b.caloriesPer100g != null) return 1;

        // 이름으로 알파벳 순 정렬
        return a.name.compareTo(b.name);
      });

    return sorted;
  }

  /// 캐시 키 생성
  String _generateCacheKey(String query, {String? barcode}) {
    if (barcode != null) {
      return 'barcode_$barcode';
    }
    return 'search_${query.toLowerCase().trim()}';
  }

  /// 다양한 에너지 단위를 kcal로 변환
  /// Open Food Facts nutriments에서 칼로리 추출
  double? _convertEnergyToKcal(Map<String, dynamic> nutriments) {
    // 단위 변환 계수 정의 (kcal로 변환)
    const Map<String, double> energyUnitFactors = {
      // kcal 계열 (1.0 = 그대로 사용)
      'kcal': 1.0,
      'calories': 1.0,
      'calorie': 1.0,
      'cal': 1.0,
      'kilocalories': 1.0,
      'kcalories': 1.0,
      'cals': 1.0,

      // kJ 계열 (kJ → kcal 변환: 1 kcal = 4.184 kJ)
      'kj': 1 / 4.184,
      'kilojoules': 1 / 4.184,
      'kilojoule': 1 / 4.184,
      'joules': 1 / 4.184,
      'j': 1 / 4.184,
    };

    // 1. kcal 단위 우선 (가장 정확함)
    if (nutriments['energy-kcal_100g'] != null) {
      return (nutriments['energy-kcal_100g'] as num).toDouble();
    }
    if (nutriments['energy-kcal'] != null) {
      return (nutriments['energy-kcal'] as num).toDouble();
    }

    // 2. kJ 단위 변환
    if (nutriments['energy-kj_100g'] != null) {
      final kj = (nutriments['energy-kj_100g'] as num).toDouble();
      return kj / 4.184;
    }
    if (nutriments['energy-kj'] != null) {
      final kj = (nutriments['energy-kj'] as num).toDouble();
      return kj / 4.184;
    }

    // 3. 일반 energy 필드 (단위 확인 필요)
    if (nutriments['energy_100g'] != null) {
      final energy = (nutriments['energy_100g'] as num).toDouble();
      final unit = nutriments['energy_unit']?.toString().toLowerCase();

      if (unit != null && energyUnitFactors.containsKey(unit)) {
        final factor = energyUnitFactors[unit]!;
        return energy * factor;
      } else {
        // 단위가 명시되지 않은 경우, 값 범위로 추론
        if (energy > 5000) {
          // 5000 이상이면 kJ로 간주
          return energy / 4.184;
        } else {
          // 그 외는 kcal로 간주
          return energy;
        }
      }
    }

    // 4. serving 기준 에너지 변환
    if (nutriments['energy-kj_serving'] != null) {
      final kj = (nutriments['energy-kj_serving'] as num).toDouble();
      return kj / 4.184;
    }
    if (nutriments['energy-kcal_serving'] != null) {
      return (nutriments['energy-kcal_serving'] as num).toDouble();
    }

    // 5. 기타 에너지 관련 필드들 (모든 가능한 필드명 시도)
    final energyFields = [
      'energy',
      'energy_value',
      'calories',
      'calories_100g',
      'kcal',
      'kcal_100g',
      'cal',
      'cal_100g',
      'energy_serving',
      'calories_serving',
      'kcal_serving',
      'cal_serving',
    ];

    for (final field in energyFields) {
      if (nutriments[field] != null) {
        final value = (nutriments[field] as num).toDouble();
        if (value > 0) {
          // 값 범위 기반 단위 추론
          if (value > 5000) {
            // 5000 이상이면 kJ로 간주
            return value / 4.184;
          } else {
            // 그 외는 kcal로 간주
            return value;
          }
        }
      }
    }

    return null; // 칼로리 정보 없음
  }

  /// USDA 영양소 데이터에서 칼로리 추출
  double? _extractCaloriesFromUSDANutrients(List<dynamic> nutrients) {
    // 단위 변환 계수 정의 (kcal로 변환)
    const Map<String, double> energyUnitFactors = {
      // kcal 계열
      'kcal': 1.0,
      'calories': 1.0,
      'calorie': 1.0,
      'cal': 1.0,
      'kilocalories': 1.0,
      'kcalories': 1.0,
      'cals': 1.0,

      // kJ 계열 (kJ → kcal 변환)
      'kj': 1 / 4.184,
      'kilojoules': 1 / 4.184,
      'kilojoule': 1 / 4.184,
      'joules': 1 / 4.184,
      'j': 1 / 4.184,
    };

    for (final nutrient in nutrients) {
      final nutrientId = nutrient['nutrientId'];
      final nutrientName = nutrient['nutrientName']?.toString().toLowerCase();
      final unitName = nutrient['unitName']?.toString().toLowerCase();
      final value = nutrient['value'];

      if (value != null) {
        final numValue = (value as num).toDouble();

        // 1. Energy (kcal) - nutrientId 우선 (가장 정확)
        if (nutrientId == 1008) {
          return numValue;
        }

        // 2. Energy (kJ) - nutrientId 우선
        if (nutrientId == 1062) {
          return numValue / 4.184;
        }

        // 3. 이름 + 단위 기반 매칭
        if (nutrientName?.contains('energy') == true) {
          if (unitName != null && energyUnitFactors.containsKey(unitName)) {
            final factor = energyUnitFactors[unitName]!;
            return numValue * factor;
          } else {
            // 단위 정보가 없는 경우 값 범위로 추론
            if (numValue > 5000) {
              return numValue / 4.184;
            } else {
              return numValue;
            }
          }
        }

        // 4. 일반적인 칼로리 관련 필드들
        if (nutrientName?.contains('calories') == true ||
            nutrientName?.contains('calorie') == true ||
            nutrientName?.contains('kilocalories') == true ||
            nutrientName?.contains('kcal') == true) {
          if (unitName != null && energyUnitFactors.containsKey(unitName)) {
            final factor = energyUnitFactors[unitName]!;
            return numValue * factor;
          } else {
            // 단위 정보가 없는 경우 값 범위로 추론
            if (numValue > 5000) {
              return numValue / 4.184;
            } else {
              return numValue;
            }
          }
        }
      }
    }

    return null; // 칼로리 정보 없음
  }
}
