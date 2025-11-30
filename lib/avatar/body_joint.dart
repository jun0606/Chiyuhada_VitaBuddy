import 'dart:ui';

/// 신체 관절을 나타내는 클래스
class BodyJoint {
  final String name;
  Offset position;
  double angle;

  BodyJoint(
    this.name,
    this.position, {
    this.angle = 0.0,
  });
}
