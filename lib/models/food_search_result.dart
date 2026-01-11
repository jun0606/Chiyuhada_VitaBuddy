/// 음식 검색 결과 모델
import 'package:flutter/material.dart';

/// API 검색 상태
enum SearchStatus {
  success, // 데이터 있음
  noData, // 검색했으나 데이터 없음
  notConfigured, // API 키 없음
  error, // 검색 오류
}

/// 각 API별 검색 결과
class ApiSearchResult {
  final String apiName;
  final List<FoodSearchResult> results;
  final SearchStatus status;

  ApiSearchResult({
    required this.apiName,
    required this.results,
    required this.status,
  });

  String get displayName {
    switch (apiName) {
      case 'openFoodFacts':
        return 'Open Food Facts';
      case 'usda':
        return 'USDA FoodData Central';
      default:
        return apiName;
    }
  }

  IconData get apiIcon {
    switch (apiName) {
      case 'openFoodFacts':
        return Icons.eco;
      case 'usda':
        return Icons.gavel;
      default:
        return Icons.search;
    }
  }

  Color get headerColor {
    switch (status) {
      case SearchStatus.success:
        return Colors.green.shade50;
      case SearchStatus.noData:
        return Colors.orange.shade50;
      case SearchStatus.notConfigured:
        return Colors.blue.shade50;
      case SearchStatus.error:
        return Colors.red.shade50;
    }
  }

  Color get textColor {
    switch (status) {
      case SearchStatus.success:
        return Colors.green.shade800;
      case SearchStatus.noData:
        return Colors.orange.shade800;
      case SearchStatus.notConfigured:
        return Colors.blue.shade800;
      case SearchStatus.error:
        return Colors.red.shade800;
    }
  }

  String get statusText {
    switch (status) {
      case SearchStatus.success:
        return '${results.length}개';
      case SearchStatus.noData:
        return '데이터 없음';
      case SearchStatus.notConfigured:
        return '설정 필요';
      case SearchStatus.error:
        return '오류';
    }
  }

  String get statusTitle {
    switch (status) {
      case SearchStatus.success:
        return '검색 결과';
      case SearchStatus.noData:
        return '데이터에 없음';
      case SearchStatus.notConfigured:
        return 'API 키 설정 필요';
      case SearchStatus.error:
        return '검색 실패';
    }
  }

  String get statusDescription {
    switch (status) {
      case SearchStatus.success:
        return '총 ${results.length}개의 결과를 찾았습니다.';
      case SearchStatus.noData:
        return '$displayName 데이터베이스에서 이 음식을 찾을 수 없습니다.';
      case SearchStatus.notConfigured:
        return '설정에서 $displayName API 키를 입력하면 더 정확한 검색이 가능합니다.';
      case SearchStatus.error:
        return '$displayName 검색 중 오류가 발생했습니다.';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case SearchStatus.success:
        return Icons.check_circle;
      case SearchStatus.noData:
        return Icons.search_off;
      case SearchStatus.notConfigured:
        return Icons.settings;
      case SearchStatus.error:
        return Icons.error_outline;
    }
  }
}

class FoodSearchResult {
  final String name;
  final double? caloriesPer100g;
  final String? brand;
  final String dataSource; // 'openFoodFacts' or 'usda'
  final String? imageUrl;
  final Map<String, dynamic>? rawData;

  FoodSearchResult({
    required this.name,
    this.caloriesPer100g,
    this.brand,
    required this.dataSource,
    this.imageUrl,
    this.rawData,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'caloriesPer100g': caloriesPer100g,
    'brand': brand,
    'dataSource': dataSource,
    'imageUrl': imageUrl,
    'rawData': rawData,
  };

  factory FoodSearchResult.fromJson(Map<String, dynamic> json) =>
      FoodSearchResult(
        name: json['name'],
        caloriesPer100g: json['caloriesPer100g'],
        brand: json['brand'],
        dataSource: json['dataSource'],
        imageUrl: json['imageUrl'],
        rawData: json['rawData'],
      );

  /// 출처 표시 텍스트 (공식 라이선스 표기 권고사항 준수)
  String get sourceDisplayText {
    switch (dataSource) {
      case 'openFoodFacts':
        return 'Data from Open Food Facts';
      case 'usda':
        return 'Data provided by USDA FoodData Central';
      default:
        return 'Unknown source';
    }
  }

  /// 출처 아이콘
  IconData get sourceIcon {
    switch (dataSource) {
      case 'openFoodFacts':
        return Icons.eco; // 자연/오픈소스 아이콘
      case 'usda':
        return Icons.gavel; // 정부 아이콘
      default:
        return Icons.help_outline;
    }
  }

  /// 출처 색상
  Color get sourceColor {
    switch (dataSource) {
      case 'openFoodFacts':
        return Colors.green;
      case 'usda':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 출처 배경색
  Color get sourceBackgroundColor {
    switch (dataSource) {
      case 'openFoodFacts':
        return Colors.green.shade50;
      case 'usda':
        return Colors.blue.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  /// 출처 배지 색상
  Color get sourceBadgeColor {
    switch (dataSource) {
      case 'openFoodFacts':
        return Colors.green.shade100;
      case 'usda':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  /// 출처 텍스트 색상
  Color get sourceTextColor {
    switch (dataSource) {
      case 'openFoodFacts':
        return Colors.green.shade800;
      case 'usda':
        return Colors.blue.shade800;
      default:
        return Colors.grey.shade800;
    }
  }
}
