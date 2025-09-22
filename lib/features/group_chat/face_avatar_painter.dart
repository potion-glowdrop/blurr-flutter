// import 'dart:math' as math;
// import 'package:flutter/material.dart';

// enum SimpleMouthState { neutral, smiling, open, talking }

// class FaceAvatarPainter extends CustomPainter {
//   final Offset center;
//   final double radius;
//   final bool leftEyeOpen;
//   final bool rightEyeOpen;
//   final SimpleMouthState mouthState;
//   final double mouthOpenRatio; // 0~대충 0.5
//   final Image? sticker;

//   FaceAvatarPainter({
//     required this.center,
//     required this.radius,
//     required this.leftEyeOpen,
//     required this.rightEyeOpen,
//     required this.mouthState,
//     this.mouthOpenRatio = 0.0,
//     this.sticker,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final stroke = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3
//       ..strokeCap = StrokeCap.round
//       ..color = const Color(0xFF222222);

//     final fill = Paint()
//       ..style = PaintingStyle.fill
//       ..color = const Color(0xFF222222);

//     // 배경 스티커 or 기본 원
//     if (sticker != null) {
//       final dst = Rect.fromCircle(center: center, radius: radius * 1.8);
//       final src = Rect.fromLTWH(
//         0, 0, sticker!.width!.toDouble(), sticker!.height!.toDouble(),
//       );
//       canvas.drawImageRect(sticker!, src, dst, Paint());
//     } else {
//       canvas.drawCircle(center, radius, stroke);
//     }

//     // 눈
//     final eyeY  = center.dy - radius * 0.20;
//     final eyeDX = radius * 0.35;
//     final eyeR  = radius * 0.10;

//     if (leftEyeOpen) {
//       canvas.drawCircle(Offset(center.dx - eyeDX, eyeY), eyeR, fill);
//     } else { 
//       canvas.drawLine(
//         Offset(center.dx - eyeDX - eyeR, eyeY),
//         Offset(center.dx - eyeDX + eyeR, eyeY),
//         stroke,
//       );
//     }

//     if (rightEyeOpen) {
//       canvas.drawCircle(Offset(center.dx + eyeDX, eyeY), eyeR, fill);
//     } else {
//       canvas.drawLine(
//         Offset(center.dx + eyeDX - eyeR, eyeY),
//         Offset(center.dx + eyeDX + eyeR, eyeY),
//         stroke,
//       );
//     }

//     // 입
//     final mouthY     = center.dy + radius * 0.25;
//     final mouthWBase = radius * 0.60;
//     final talkingNarrowFactor = 0.75;
//     final dynamicNarrow = (1.0 - (mouthOpenRatio * 2.2)).clamp(0.6, 1.0);
//     final talkingWidthFactor = (talkingNarrowFactor * dynamicNarrow).clamp(0.55, 1.0);
//     final mouthW = (mouthState == SimpleMouthState.talking || mouthState == SimpleMouthState.open)
//         ? mouthWBase * talkingWidthFactor : mouthWBase;

//     final mouthHClosed = mouthWBase * 0.05;
//     final mouthHOpen   = mouthWBase * (0.20 + mouthOpenRatio * 1.2);
//     final mouthH = (mouthState == SimpleMouthState.talking)
//         ? (mouthHOpen * 1.10).clamp(mouthHClosed, radius * 0.7)
//         : mouthHOpen;

//     switch (mouthState) {
//       case SimpleMouthState.neutral:
//         canvas.drawLine(
//           Offset(center.dx - mouthWBase / 2, mouthY),
//           Offset(center.dx + mouthWBase / 2, mouthY),
//           stroke,
//         );
//         break;
//       case SimpleMouthState.smiling:
//         final smileW  = mouthWBase * 1.10;
//         final smileH  = (mouthWBase * 0.55).clamp(6.0, radius * 0.9);
//         final smileUp = radius * 0.02;
//         final rectSmile = Rect.fromCenter(
//           center: Offset(center.dx, mouthY - smileUp),
//           width: smileW,
//           height: smileH,
//         );
//         canvas.drawArc(rectSmile, math.pi * 0.10, math.pi * 0.80, false, stroke);
//         break;
//       case SimpleMouthState.open:
//       case SimpleMouthState.talking:
//         final rect = Rect.fromCenter(
//           center: Offset(center.dx, mouthY),
//           width: mouthW,
//           height: mouthH,
//         );
//         canvas.drawOval(rect, stroke);
//         break;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant FaceAvatarPainter old) =>
//       old.center != center ||
//       old.radius != radius ||
//       old.leftEyeOpen != leftEyeOpen ||
//       old.rightEyeOpen != rightEyeOpen ||
//       old.mouthState != mouthState ||
//       old.mouthOpenRatio != mouthOpenRatio ||
//       old.sticker != sticker;
// }
