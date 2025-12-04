import 'package:flutter/material.dart';
import '../widgets/advanced_avatar_widget.dart';
import '../avatar/body_measurements.dart';
import '../avatar/body_poses.dart';
import '../avatar/face_expressions.dart';

class PolygonTestScreen extends StatefulWidget {
  const PolygonTestScreen({super.key});

  @override
  State<PolygonTestScreen> createState() => _PolygonTestScreenState();
}

class _PolygonTestScreenState extends State<PolygonTestScreen> {
  double _bmi = 22.0;
  double _height = 170.0;
  String _gender = 'female';
  LifestylePattern _lifestyle = LifestylePattern.active;


  
  // Controller 방식 적용
  final AvatarController _controller = AvatarController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고도화된 아바타 시뮬레이터'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey.shade200,
                ),
                child: AdvancedAvatarWidget(
                  controller: _controller, // 컨트롤러 주입
                  bmi: _bmi,
                  height: _height,
                  gender: _gender,
                  lifestyle: _lifestyle,
                  width: 300,
                  heightSize: 400,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            height: 350, // 하단 패널 높이 확보
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('신체 설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  
                  // 성별 & 생활 패턴
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: _gender,
                        items: const [
                          DropdownMenuItem(value: 'female', child: Text('여성')),
                          DropdownMenuItem(value: 'male', child: Text('남성')),
                        ],
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<LifestylePattern>(
                        value: _lifestyle,
                        items: const [
                          DropdownMenuItem(value: LifestylePattern.sedentary, child: Text('좌식 (운동부족)')),
                          DropdownMenuItem(value: LifestylePattern.active, child: Text('활동적 (일반)')),
                          DropdownMenuItem(value: LifestylePattern.athletic, child: Text('운동선수 (근육)')),
                        ],
                        onChanged: (v) => setState(() => _lifestyle = v!),
                      ),
                    ],
                  ),

                  // BMI & 키
                  _buildSlider('BMI', _bmi, 15, 40, (v) => setState(() => _bmi = v)),
                  _buildSlider('키 (cm)', _height, 150, 190, (v) => setState(() => _height = v)),

                  const Divider(),
                  const Text('상호작용 (표정 & 제스처)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  
                  const Text('표정 (Expressions)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildExpressionBtn('😐 중립', FaceExpressionType.neutral),
                      _buildExpressionBtn('😄 행복', FaceExpressionType.happy),
                      _buildExpressionBtn('🤗 환영', FaceExpressionType.welcome),
                      _buildExpressionBtn('😋 배부름', FaceExpressionType.full),
                      _buildExpressionBtn('🤤 배고픔', FaceExpressionType.hungry),
                      _buildExpressionBtn('😢 피곤', FaceExpressionType.tired),
                      _buildExpressionBtn('😌 만족', FaceExpressionType.satisfied),
                      _buildExpressionBtn('🤢 과식', FaceExpressionType.stuffed),
                      _buildExpressionBtn('✋ 거부', FaceExpressionType.refuse),
                      _buildExpressionBtn('😠 경고', FaceExpressionType.warning),
                      _buildExpressionBtn('✨ 인사', FaceExpressionType.greeting), // 추가됨
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('포즈 (Poses)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPoseBtn('🧍 중립', BodyPose.neutral),
                      _buildPoseBtn('👋 인사', BodyPose.greeting),
                      _buildPoseBtn('🎉 환호', BodyPose.cheer),
                      _buildPoseBtn('🙆 기지개', BodyPose.stretch),
                      _buildPoseBtn('🤔 배고픔', BodyPose.touchBelly),
                      _buildPoseBtn('🙌 팔들기', BodyPose.armsUp),
                      _buildPoseBtn('👋 손흔들기', BodyPose.waveHand),
                      // 제거: _buildPoseBtn('🙇 숙이기', BodyPose.bendForward), - 아바타 구조상 불가
                      // 제거: _buildPoseBtn('😔 고개숙임', BodyPose.headDown), - 아바타 구조상 불가
                      _buildPoseBtn('✋ 거부', BodyPose.refuse),
                      _buildPoseBtn('🦸 승리', BodyPose.victory),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: 100,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 40, child: Text(value.toStringAsFixed(1))),
      ],
    );
  }

  Widget _buildExpressionBtn(String label, FaceExpressionType type) {
    return ElevatedButton(
      onPressed: () => _controller.setExpression(type),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildPoseBtn(String label, BodyPose pose) {
    return OutlinedButton(
      onPressed: () {
        _controller.setPose(pose);
        // ✨ 인사 포즈일 때 표정도 같이 설정 (이펙트 확인용)
        if (pose == BodyPose.greeting) {
          _controller.setExpression(FaceExpressionType.greeting);
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
