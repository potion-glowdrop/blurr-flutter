// lib/features/group_chat/face_avatar_painter.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:blurr/features/group_chat/mouth_state.dart';

class FaceAvatarPainter extends CustomPainter {
  final MouthState mouthState;
  /// ML에서 넘어오는 값(대략 0.0 ~ 0.5 권장). 내부에서 안전 clamp합니다.
  final double mouthOpenRatio;
  final bool leftEyeOpen;
  final bool rightEyeOpen;

  /// 선택: 색/두께 튜닝 포인트 (기본값은 기존과 동일한 느낌)
  final Color color;
  /// 선 두께를 size.shortestSide * strokeFactor로 계산 (기본 2.8%)
  final double strokeFactor;
  /// mouthOpenRatio 상한. (0.35~0.5 사이 권장)
  final double maxOpenRatio;

  const FaceAvatarPainter({
    required this.mouthState,
    required this.mouthOpenRatio,
    this.leftEyeOpen = true,
    this.rightEyeOpen = true,
    this.color = const Color(0xFF222222),
    this.strokeFactor = 0.028, // 2.8%: 150px 기준 대략 4.2px
    this.maxOpenRatio = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final strokeWidth = (s * strokeFactor).clamp(1.5, 6.0);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = (s / 2) * 0.92;
    final center = Offset(size.width / 2, size.height / 2);

    // 눈
    final eyeY  = center.dy - radius * 0.20;
    final eyeDX = radius * 0.35;
    final eyeR  = radius * 0.10;

    if (leftEyeOpen) {
      canvas.drawCircle(Offset(center.dx - eyeDX, eyeY), eyeR, fill);
    } else {
      canvas.drawLine(
        Offset(center.dx - eyeDX - eyeR, eyeY),
        Offset(center.dx - eyeDX + eyeR, eyeY),
        stroke,
      );
    }
    if (rightEyeOpen) {
      canvas.drawCircle(Offset(center.dx + eyeDX, eyeY), eyeR, fill);
    } else {
      canvas.drawLine(
        Offset(center.dx + eyeDX - eyeR, eyeY),
        Offset(center.dx + eyeDX + eyeR, eyeY),
        stroke,
      );
    }

    // 입
    final mouthY     = center.dy + radius * 0.25;
    final mouthWBase = radius * 0.60;

    final ratio = mouthOpenRatio.isFinite
        ? mouthOpenRatio.clamp(0.0, maxOpenRatio)
        : 0.0;

    // 말할 때 가로폭 살짝 좁힘(동적)
    const talkNarrow = 0.75;
    final dynamicNarrow = (1.0 - (ratio * 2.2)).clamp(0.6, 1.0);
    final talkingWidthFactor =
        (talkNarrow * dynamicNarrow).clamp(0.55, 1.0);

    final isOpenish =
        mouthState == MouthState.talking || mouthState == MouthState.open;

    final mouthW = isOpenish ? mouthWBase * talkingWidthFactor : mouthWBase;

    final mouthHClosed = mouthWBase * 0.05;
    final mouthHOpen   = mouthWBase * (0.20 + ratio * 1.2);
    final mouthH = (mouthState == MouthState.talking)
        ? (mouthHOpen * 1.10).clamp(mouthHClosed, radius * 0.7)
        : mouthHOpen;

    switch (mouthState) {
      case MouthState.neutral:
        canvas.drawLine(
          Offset(center.dx - mouthWBase / 2, mouthY),
          Offset(center.dx + mouthWBase / 2, mouthY),
          stroke,
        );
        break;

      case MouthState.smiling:
        // 아치 더 확실하게
        final smileW  = mouthWBase * 1.12;
        final smileH  = (mouthWBase * 0.56).clamp(strokeWidth * 1.5, radius * 0.9);
        final smileUp = radius * 0.02;
        final rectSmile = Rect.fromCenter(
          center: Offset(center.dx, mouthY - smileUp),
          width: smileW,
          height: smileH,
        );
        canvas.drawArc(rectSmile, math.pi * 0.10, math.pi * 0.80, false, stroke);
        break;

      case MouthState.open:
      case MouthState.talking:
        final rect = Rect.fromCenter(
          center: Offset(center.dx, mouthY),
          width: mouthW,
          height: mouthH,
        );
        canvas.drawOval(rect, stroke);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant FaceAvatarPainter old) =>
      old.mouthState != mouthState ||
      old.mouthOpenRatio != mouthOpenRatio ||
      old.leftEyeOpen != leftEyeOpen ||
      old.rightEyeOpen != rightEyeOpen ||
      old.color != color ||
      old.strokeFactor != strokeFactor ||
      old.maxOpenRatio != maxOpenRatio;
}
