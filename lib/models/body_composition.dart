import 'package:hive/hive.dart';

part 'body_composition.g.dart';

/// 체형 구성 정보 (근육량, 지방 축적/감소 패턴)
@HiveType(typeId: 1)
class BodyComposition {
  /// 근육 타입
  @HiveField(0)
  final String muscleType; // 'low', 'medium', 'high'

  /// 부위별 지방 축적 경향 (우선순위, 1=가장 먼저)
  /// 예: {'abdomen': 1, 'chest': 2, 'hips': 3, 'thighs': 4, 'arms': 5, 'face': 6}
  @HiveField(1)
  final Map<String, int> fatGainPattern;

  /// 부위별 지방 감소 경향 (우선순위, 1=가장 먼저)
  /// 예: {'face': 1, 'arms': 2, 'chest': 3, 'abdomen': 4, 'hips': 5, 'thighs': 6}
  @HiveField(2)
  final Map<String, int> fatLossPattern;

  /// 현재 부위별 체지방 비율 추정치 (%)
  @HiveField(3)
  final Map<String, double>? currentBodyFat;

  BodyComposition({
    required this.muscleType,
    required this.fatGainPattern,
    required this.fatLossPattern,
    this.currentBodyFat,
  });

  /// 기본 체형별 패턴 생성
  factory BodyComposition.fromBodyShape(String bodyShape) {
    switch (bodyShape) {
      case 'apple':
        return BodyComposition(
          muscleType: 'medium',
          fatGainPattern: {
            'abdomen': 1,
            'chest': 2,
            'face': 3,
            'arms': 4,
            'hips': 5,
            'thighs': 6,
          },
          fatLossPattern: {
            'thighs': 1,
            'hips': 2,
            'arms': 3,
            'face': 4,
            'chest': 5,
            'abdomen': 6,
          },
        );

      case 'pear':
        return BodyComposition(
          muscleType: 'medium',
          fatGainPattern: {
            'hips': 1,
            'thighs': 2,
            'abdomen': 3,
            'chest': 4,
            'arms': 5,
            'face': 6,
          },
          fatLossPattern: {
            'face': 1,
            'arms': 2,
            'chest': 3,
            'abdomen': 4,
            'hips': 5,
            'thighs': 6,
          },
        );

      case 'hourglass':
        return BodyComposition(
          muscleType: 'medium',
          fatGainPattern: {
            'chest': 1,
            'hips': 1,
            'face': 2,
            'arms': 2,
            'abdomen': 3,
            'thighs': 3,
          },
          fatLossPattern: {
            'face': 1,
            'arms': 1,
            'chest': 2,
            'abdomen': 2,
            'hips': 3,
            'thighs': 3,
          },
        );

      case 'rectangle':
      case 'inverted_triangle':
      default:
        // 균등 분포
        return BodyComposition(
          muscleType: 'medium',
          fatGainPattern: {
            'abdomen': 1,
            'chest': 2,
            'hips': 2,
            'thighs': 2,
            'arms': 3,
            'face': 3,
          },
          fatLossPattern: {
            'face': 1,
            'arms': 1,
            'chest': 2,
            'abdomen': 2,
            'hips': 2,
            'thighs': 2,
          },
        );
    }
  }

  BodyComposition copyWith({
    String? muscleType,
    Map<String, int>? fatGainPattern,
    Map<String, int>? fatLossPattern,
    Map<String, double>? currentBodyFat,
  }) {
    return BodyComposition(
      muscleType: muscleType ?? this.muscleType,
      fatGainPattern: fatGainPattern ?? this.fatGainPattern,
      fatLossPattern: fatLossPattern ?? this.fatLossPattern,
      currentBodyFat: currentBodyFat ?? this.currentBodyFat,
    );
  }
}
