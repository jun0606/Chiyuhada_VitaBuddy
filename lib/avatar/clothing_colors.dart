import 'package:flutter/material.dart';

/// 아바타 옷 색상 설정
class ClothingColors {
  final Color braColor;      // 스포츠 브라 색상
  final Color tightsColor;   // 타이즈/골반 커버 색상
  
  const ClothingColors({
    this.braColor = const Color(0xFFE8E8E8),    // 기본: 연한 회색
    this.tightsColor = const Color(0xFF2A2A2A), // 기본: 진한 회색
  });
  
  /// 기본 색상 프리셋
  static const ClothingColors defaultColors = ClothingColors();
  
  /// 색상 프리셋 1: 핑크/블랙
  static const ClothingColors pinkBlack = ClothingColors(
    braColor: Color(0xFFFFB6C1),    // 라이트 핑크
    tightsColor: Color(0xFF1A1A1A), // 블랙
  );
  
  /// 색상 프리셋 2: 흰색/네이비
  static const ClothingColors whiteNavy = ClothingColors(
    braColor: Color(0xFFFFFFFF),    // 흰색
    tightsColor: Color(0xFF1A237E), // 네이비
  );
  
  /// 색상 프리셋 3: 민트/차콜
  static const ClothingColors mintCharcoal = ClothingColors(
    braColor: Color(0xFF98D8C8),    // 민트
    tightsColor: Color(0xFF36454F), // 차콜
  );
  
  /// 색상 프리셋 4: 라벤더/퍼플
  static const ClothingColors lavenderPurple = ClothingColors(
    braColor: Color(0xFFE6E6FA),    // 라벤더
    tightsColor: Color(0xFF4B0082), // 인디고
  );
  
  /// 색상 프리셋 5: 코랄/그레이
  static const ClothingColors coralGray = ClothingColors(
    braColor: Color(0xFFFF7F50),    // 코랄
    tightsColor: Color(0xFF708090), // 슬레이트 그레이
  );
  
  /// 모든 프리셋
  static const List<ClothingColors> presets = [
    defaultColors,
    pinkBlack,
    whiteNavy,
    mintCharcoal,
    lavenderPurple,
    coralGray,
  ];
  
  /// 프리셋 이름
  static const List<String> presetNames = [
    '기본 (회색)',
    '핑크/블랙',
    '흰색/네이비',
    '민트/차콜',
    '라벤더/퍼플',
    '코랄/그레이',
  ];
  
  /// copyWith
  ClothingColors copyWith({
    Color? braColor,
    Color? tightsColor,
  }) {
    return ClothingColors(
      braColor: braColor ?? this.braColor,
      tightsColor: tightsColor ?? this.tightsColor,
    );
  }
  
  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'braColor': braColor.value,
      'tightsColor': tightsColor.value,
    };
  }
  
  /// JSON 역직렬화
  factory ClothingColors.fromJson(Map<String, dynamic> json) {
    return ClothingColors(
      braColor: Color(json['braColor'] as int),
      tightsColor: Color(json['tightsColor'] as int),
    );
  }
}
