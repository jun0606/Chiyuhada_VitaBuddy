import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../avatar/body_measurements.dart';
import '../avatar/avatar_animator.dart';
import '../avatar/clothing_colors.dart';
import '../avatar/body_poses.dart';
import '../avatar/face_expressions.dart';
import 'avatar_parts.dart';
import 'clothing_parts.dart';

/// Controller to interact with the avatar widget from outside.
class AvatarController {
  _AdvancedAvatarWidgetState? _state;

  void _attach(_AdvancedAvatarWidgetState state) => _state = state;
  void _detach() => _state = null;

  void setExpression(FaceExpressionType type) => _state?.game.setExpression(type);
  void setPose(BodyPose pose) => _state?.game.setPose(pose);
}

/// Main widget that hosts the avatar widget.
class AdvancedAvatarWidget extends StatefulWidget {
  final AvatarController? controller;
  final double bmi;
  final double height;
  final String gender;
  final LifestylePattern lifestyle;
  final ClothingColors? clothingColors;
  final double width;
  final double heightSize;
  final FaceExpressionType expression;
  final BodyPose pose;

  const AdvancedAvatarWidget({
    super.key,
    this.controller,
    required this.bmi,
    required this.height,
    required this.gender,
    required this.lifestyle,
    this.clothingColors,
    this.width = 300,
    this.heightSize = 400,
    this.expression = FaceExpressionType.neutral,
    this.pose = BodyPose.neutral,
  });

  @override
  State<AdvancedAvatarWidget> createState() => _AdvancedAvatarWidgetState();
}

class _AdvancedAvatarWidgetState extends State<AdvancedAvatarWidget> {
  late AdvancedAvatarGame game;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    game = AdvancedAvatarGame(
      bmi: widget.bmi,
      heightVal: widget.height,
      gender: widget.gender,
      lifestyle: widget.lifestyle,
      clothingColors: widget.clothingColors ?? ClothingColors.defaultColors,
      initialExpression: widget.expression,
      initialPose: widget.pose,
    );
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AdvancedAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 옷 색상 업데이트 체크 (가장 먼저 확인)
    final oldColors = oldWidget.clothingColors ?? ClothingColors.defaultColors;
    final newColors = widget.clothingColors ?? ClothingColors.defaultColors;
    
    bool colorsChanged = oldColors.braColor.value != newColors.braColor.value ||
                        oldColors.tightsColor.value != newColors.tightsColor.value;
    
    // 기본 속성 또는 옷 색상이 변경되었을 때 전체 업데이트
    if (oldWidget.bmi != widget.bmi ||
        oldWidget.height != widget.height ||
        oldWidget.gender != widget.gender ||
        oldWidget.lifestyle != widget.lifestyle ||
        colorsChanged) {
      game.updateAvatar(
        bmi: widget.bmi,
        heightVal: widget.height,
        gender: widget.gender,
        lifestyle: widget.lifestyle,
        clothingColors: newColors, // 새로운 색상 적용
      );
    }
    
    // 🎭 표정 변경 감지
    if (oldWidget.expression != widget.expression) {
      game.setExpression(widget.expression);
    }
    
    // 🧘 포즈 변경 감지
    if (oldWidget.pose != widget.pose) {
      game.setPose(widget.pose);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.heightSize,
      child: GameWidget(game: game),
    );
  }
}

/// Game that contains the avatar component.
class AdvancedAvatarGame extends FlameGame {
  double bmi;
  double heightVal;
  String gender;
  LifestylePattern lifestyle;
  ClothingColors clothingColors;
  FaceExpressionType initialExpression;
  BodyPose initialPose;

  late AdvancedAvatarComponent avatar;

  AdvancedAvatarGame({
    required this.bmi,
    required this.heightVal,
    required this.gender,
    required this.lifestyle,
    required this.clothingColors,
    required this.initialExpression,
    required this.initialPose,
  });

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    avatar = AdvancedAvatarComponent(
      bmi: bmi,
      heightVal: heightVal,
      gender: gender,
      lifestyle: lifestyle,
      clothingColors: clothingColors,
    );
    avatar.position = size / 2;
    add(avatar);
    
    // 초기 상태 설정
    avatar.animator.setExpression(initialExpression);
    avatar.animator.setPose(initialPose);
  }

  void updateAvatar({
    required double bmi,
    required double heightVal,
    required String gender,
    required LifestylePattern lifestyle,
    ClothingColors? clothingColors,
  }) {
    this.bmi = bmi;
    this.heightVal = heightVal;
    this.gender = gender;
    this.lifestyle = lifestyle;
    if (clothingColors != null) {
      this.clothingColors = clothingColors;
    }
    avatar.updateProperties(bmi, heightVal, gender, lifestyle, this.clothingColors);
  }

  void setExpression(FaceExpressionType type) => avatar.animator.setExpression(type);
  void setPose(BodyPose pose) => avatar.animator.setPose(pose);
}

/// Component that assembles all body parts.
class AdvancedAvatarComponent extends PositionComponent {
  double bmi;
  double heightVal;
  String gender;
  LifestylePattern lifestyle;
  ClothingColors clothingColors;
  late BodyMeasurements measurements;

  // Body parts
  late HeadPart head;
  late HeadCirclePart headCircle;
  late FacePart face;
  late CheekPart leftCheek;
  late CheekPart rightCheek;
  late EarPart leftEar;
  late EarPart rightEar;
  late TorsoPart torso;
  late NeckPart neck;
  late HairPart hair;
  late FrontHairPart frontHair;
  late ShoulderPart leftShoulder;
  late ShoulderPart rightShoulder;
  late UpperArmPart leftUpperArm;
  late UpperArmPart rightUpperArm;
  late ForearmPart leftForearm;
  late ForearmPart rightForearm;
  late PelvisPart pelvis;
  late LegPart leftLeg;
  late LegPart rightLeg;

  // Clothing parts
  late SportsBraPart sportsBra;  // 스포츠 브라 (필수)
  late TightsPart leftTights;  // 왼쪽 타이즈
  late TightsPart rightTights; // 오른쪽 타이즈
  late PelvisCoverPart pelvisCover; // 골반 커버
  // late BodyPart? shorts;  // 반바지 (선택적, 주석 처리)

  AdvancedAvatarComponent({
    required this.bmi,
    required this.heightVal,
    required this.gender,
    required this.lifestyle,
    this.clothingColors = ClothingColors.defaultColors,
  }) {
    _calculateMeasurements();
  }

  void _calculateMeasurements() {
    measurements = BodyMeasurements(
      bmi: bmi,
      height: heightVal,
      gender: gender,
      lifestyle: lifestyle,
      clothingColors: clothingColors,
    );
  }

  /// Re‑create parts when properties change.
  void updateProperties(
    double newBmi,
    double newHeight,
    String newGender,
    LifestylePattern newLifestyle,
    ClothingColors newClothingColors,
  ) {
    bmi = newBmi;
    heightVal = newHeight;
    gender = newGender;
    lifestyle = newLifestyle;
    clothingColors = newClothingColors;
    _calculateMeasurements();
    _rebuild();
  }

  void _rebuild() {
    // Clear existing children.
    removeAll(children);

    // Create parts.
    torso = TorsoPart(measurements: measurements);
    neck = NeckPart(measurements: measurements);
    pelvis = PelvisPart(measurements: measurements);
    head = HeadPart(measurements: measurements);
    headCircle = HeadCirclePart(measurements: measurements);
    face = FacePart(measurements: measurements, gender: gender);  // gender 전달
    leftCheek = CheekPart(measurements: measurements, isLeft: true);
    rightCheek = CheekPart(measurements: measurements, isLeft: false);
    leftEar = EarPart(measurements: measurements, isLeft: true);
    rightEar = EarPart(measurements: measurements, isLeft: false);
    hair = HairPart(measurements: measurements, gender: gender);
    frontHair = FrontHairPart(measurements: measurements, gender: gender);
    leftShoulder = ShoulderPart(measurements: measurements, isLeft: true);
    rightShoulder = ShoulderPart(measurements: measurements, isLeft: false);
    leftUpperArm = UpperArmPart(measurements: measurements, isLeft: true);
    rightUpperArm = UpperArmPart(measurements: measurements, isLeft: false);
    leftForearm = ForearmPart(measurements: measurements, isLeft: true);
    rightForearm = ForearmPart(measurements: measurements, isLeft: false);
    leftLeg = LegPart(measurements: measurements, isLeft: true);
    rightLeg = LegPart(measurements: measurements, isLeft: false);

    // Create clothing
    sportsBra = SportsBraPart(measurements: measurements);
    leftTights = TightsPart(measurements: measurements, isLeft: true);
    rightTights = TightsPart(measurements: measurements, isLeft: false);
    pelvisCover = PelvisCoverPart(measurements: measurements);
    // shorts = ShortsPart(measurements: measurements); // 선택적

    // Positioning.
    // Hair is behind head
    hair.position = Vector2(0, -measurements.torsoHeight * 0.95 - measurements.neckHeight);
    hair.priority = -100;
    
    // Shoulders (Visual only, arms attach to Torso coordinates)
    leftShoulder.position = Vector2(-measurements.shoulderWidth / 2, -measurements.torsoHeight * 0.9);
    rightShoulder.position = Vector2(measurements.shoulderWidth / 2, -measurements.torsoHeight * 0.9);
    
    // Neck connects to top of Torso
    neck.position = Vector2(0, -measurements.torsoHeight * 0.95);
    
    // Head sits on Neck
    head.position = Vector2(0, -measurements.neckHeight);
    
    // Front Hair sits on Head
    frontHair.position = Vector2(0, 0);
    
    // Arms attach to Shoulder joints (approx top corners of Torso)
    leftUpperArm.position = Vector2(-measurements.shoulderWidth / 2, -measurements.torsoHeight * 0.9);
    rightUpperArm.position = Vector2(measurements.shoulderWidth / 2, -measurements.torsoHeight * 0.9);
    
    // Forearms attach to bottom of UpperArms
    leftForearm.position = Vector2(0, measurements.armLength);
    rightForearm.position = Vector2(0, measurements.armLength);
    
    // Pelvis attaches to bottom of Torso
    pelvis.position = Vector2(0, 0);
    
    // Legs attach to Hip sockets in Pelvis
    // Pelvis height is approx torsoHeight * 0.25
    final pelvisHeight = measurements.torsoHeight * 0.25;
    leftLeg.position = Vector2(-measurements.hipWidth / 3, pelvisHeight * 0.5);
    rightLeg.position = Vector2(measurements.hipWidth / 3, pelvisHeight * 0.5);

    // Clothing positions
    // Sports bra attaches to torso
    sportsBra.position = Vector2(0, 0);

    // Tights attach to each leg
    leftTights.position = Vector2(0, 0);
    rightTights.position = Vector2(0, 0);
    
    // Pelvis cover attaches to pelvis
    pelvisCover.position = Vector2(0, 0);

    // Shorts (optional)
    // shorts?.position = Vector2(0, 0);

    // Build hierarchy with proper rendering order.
    
    // 다리
    pelvis.add(leftLeg);
    pelvis.add(rightLeg);
    
    // 타이즈를 각 다리 위에 렌더링 (다리 형태를 따라감)
    leftLeg.add(leftTights);
    rightLeg.add(rightTights);
    leftTights.priority = 5;   // 다리 위에 표시
    rightTights.priority = 5;
    
    // 골반 커버를 골반 위에 렌더링
    pelvis.add(pelvisCover);
    pelvisCover.priority = 5;  // 골반 위에 표시

    // 반바지 (선택적)
    // pelvis.add(shorts);
    // shorts?.priority = 10;

    // 🎯 뒷머리를 루트 컴포넌트의 자식으로 추가 (가장 먼저 렌더링)
    // head와 위치/각도는 update에서 동기화
    add(hair);
    hair.priority = -200;  // 모든 것보다 먼저 (가장 뒤)

    add(leftShoulder);
    add(rightShoulder);
    add(torso);

    // 스포츠 브라 (몸통 위)
    torso.add(sportsBra);
    sportsBra.priority = 15;

    torso.add(neck);
    neck.add(head);
    
    // 렌더링 순서: leftEar(-5) → rightEar(-5) → headCircle(0) → leftCheek(3) → rightCheek(3) → face(5) → frontHair(10)
    head.add(leftEar);
    leftEar.position = Vector2(0, 0);
    leftEar.priority = -5;  // 귀 (머리 원보다 먼저)
    
    head.add(rightEar);
    rightEar.position = Vector2(0, 0);
    rightEar.priority = -5;
    
    head.add(headCircle);
    headCircle.position = Vector2(0, 0);
    headCircle.priority = 0;  // 머리 원
    
    head.add(leftCheek);
    leftCheek.position = Vector2(0, 0);
    leftCheek.priority = 12;  // 볼 (앞머리보다 위에 표시! 7 → 12)
    
    head.add(rightCheek);
    rightCheek.position = Vector2(0, 0);
    rightCheek.priority = 12;
    
    head.add(face);
    face.position = Vector2(0, 0);
    face.priority = 5;  // 얼굴
    
    head.add(frontHair);
    frontHair.position = Vector2(0, 0);
    frontHair.priority = 10;  // 앞머리 (마지막)
    torso.add(pelvis);
    torso.add(leftUpperArm);
    leftUpperArm.priority = 20; // 스포츠 브라(15)보다 위에 표시
    leftUpperArm.add(leftForearm);
    torso.add(rightUpperArm);
    rightUpperArm.priority = 20; // 스포츠 브라(15)보다 위에 표시
    rightUpperArm.add(rightForearm);
    
    // Forearm position (attached to elbow)
    leftForearm.position = Vector2(0, measurements.armLength);
    rightForearm.position = Vector2(0, measurements.armLength);
  }

  // Animator instance.
  final AvatarAnimator animator = AvatarAnimator();

  @override
  Future<void> onLoad() async {
    // Initial build.
    _rebuild();
  }

  @override
  void update(double dt) {
    super.update(dt);
    animator.update(dt);
    final angles = animator.getJointAngles();
    head.angle = angles['head'] ?? 0.0;
    leftUpperArm.angle = angles['leftArm'] ?? 0.0;
    rightUpperArm.angle = angles['rightArm'] ?? 0.0;
    leftForearm.angle = angles['leftElbow'] ?? 0.0;
    rightForearm.angle = angles['rightElbow'] ?? 0.0;
    torso.angle = angles['torso'] ?? 0.0; // 몸통 회전 적용
    
    // ↕️ 수직 오프셋 적용 (점프 등)
    final verticalOffset = angles['verticalOffset'] ?? 0.0;
    torso.position = Vector2(0, verticalOffset);

    // 🎯 뒷머리를 head와 동기화 (회전 변환 포함)
    // 각 관절의 회전을 고려한 위치 계산
    final torsoAngle = torso.angle;
    final neckAngle = neck.angle;
    final headAngle = head.angle;
    
    // neck 위치를 torso 회전만큼 변환
    final neckRotated = Vector2(
      neck.position.x * cos(torsoAngle) - neck.position.y * sin(torsoAngle),
      neck.position.x * sin(torsoAngle) + neck.position.y * cos(torsoAngle),
    );
    
    // head 위치를 torso + neck 회전만큼 변환
    final totalNeckAngle = torsoAngle + neckAngle;
    final headRotated = Vector2(
      head.position.x * cos(totalNeckAngle) - head.position.y * sin(totalNeckAngle),
      head.position.x * sin(totalNeckAngle) + head.position.y * cos(totalNeckAngle),
    );
    
    // 최종 위치: torso + 회전된 neck + 회전된 head
    hair.position = torso.position + neckRotated + headRotated;
    
    // 최종 각도: 모든 회전 누적
    hair.angle = torsoAngle + neckAngle + headAngle;

    // 표정 업데이트 (FacePart에 FaceExpression 객체 + 타입 전달)
    final faceExpression = animator.getFaceExpression();
    final expressionType = animator.currentExpression;  // 표정 타입 직접 전달
    final eyeState = animator.getEyeState();
    final mouthState = animator.getMouthState();
    face.updateFromExpression(faceExpression, expressionType, eyeState, mouthState);
    
    // 🍎 볼에 표정 동기화 (붉은 기 표시를 위해)
    leftCheek.updateMouthState(mouthState);
    rightCheek.updateMouthState(mouthState);
  }
}
