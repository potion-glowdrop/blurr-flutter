// // lib/features/one_on_one_chat/face_dots_painter.dart
// import 'dart:math' as math;
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// // ✅ enum을 여기로 이동 (페이지 파일에서 제거)
// enum MouthState { neutral, smiling, open, talking }

// class FaceDotsPainter extends CustomPainter {
//   final List<Face> faces;
//   final Size imageSize;
//   final Size widgetSize;
//   final bool mirror;
//   final ui.Image? sticker;
//   final MouthState mouthState;
//   final double mouthOpenRatio;
//   final Rect contentRect;

//   FaceDotsPainter({
//     required this.faces,
//     required this.imageSize,
//     required this.widgetSize,
//     required this.contentRect,
//     required this.mirror,
//     this.sticker,
//     required this.mouthState,
//     required this.mouthOpenRatio,
//   });

//   Offset _map(Offset p) {
//     final scale = math.max(
//       widgetSize.width / imageSize.width,
//       widgetSize.height / imageSize.height,
//     );
//     final dx = (widgetSize.width  - imageSize.width  * scale) / 2;
//     final dy = (widgetSize.height - imageSize.height * scale) / 2;
//     double x = p.dx * scale + dx;
//     double y = p.dy * scale + dy;
//     // if (mirror) x = widgetSize.width - x;
//     return Offset(x, y);
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     final stroke = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3
//       ..color = const Color(0xFF222222);

//     final fill = Paint()
//       ..style = PaintingStyle.fill
//       ..color = const Color(0xFF222222);

//     for (final f in faces) {
//       final box = f.boundingBox;
//       final center = _map(box.center);
//       final scale = math.max(widgetSize.width/imageSize.width, widgetSize.height/imageSize.height);
//       final radius = (box.shortestSide * scale * 0.6);

//       if (sticker != null) {
//         final dst = Rect.fromCircle(center: center, radius: radius * 1.8);
//         final src = Rect.fromLTWH(0, 0, sticker!.width.toDouble(), sticker!.height.toDouble());
//         canvas.drawImageRect(sticker!, src, dst, Paint());
//       } else {
//         canvas.drawCircle(center, radius, stroke);
//       }

//       // ── 눈(확률 + EAR 융합, 원본 로직 그대로) ──
//       const double minFaceWidthPx = 100;
//       final bool tinyFace = box.width < minFaceWidthPx;
//       final double pL = f.leftEyeOpenProbability  ?? 0.5;
//       final double pR = f.rightEyeOpenProbability ?? 0.5;
//       const double probOpenThresh = 0.40;
//       final bool byProbLeftOpen  = pL > probOpenThresh;
//       final bool byProbRightOpen = pR > probOpenThresh;

//       double? earFromContour(Face face, FaceContourType t) {
//         final contour = face.contours[t];
//         if (contour == null || contour.points.isEmpty) return null;
//         double minX = contour.points.first.x.toDouble();
//         double maxX = minX;
//         double minY = contour.points.first.y.toDouble();
//         double maxY = minY;
//         for (final p in contour.points) {
//           final x = p.x.toDouble(), y = p.y.toDouble();
//           if (x < minX) minX = x;
//           if (x > maxX) maxX = x;
//           if (y < minY) minY = y;
//           if (y > maxY) maxY = y;
//         }
//         final width = (maxX - minX).abs();
//         final height = (maxY - minY).abs();
//         if (width <= 0) return null;
//         return height / width;
//       }

//       final earL = earFromContour(f, FaceContourType.leftEye);
//       final earR = earFromContour(f, FaceContourType.rightEye);
//       const double earOpenThresh = 0.20;
//       final bool byEarLeftOpen  = (earL != null) ? (earL > earOpenThresh) : false;
//       final bool byEarRightOpen = (earR != null) ? (earR > earOpenThresh) : false;

//       bool leftOpen  = tinyFace ? true : (byProbLeftOpen  || byEarLeftOpen);
//       bool rightOpen = tinyFace ? true : (byProbRightOpen || byEarRightOpen);

//       const double softMargin = 0.08;
//       if (!tinyFace && leftOpen != rightOpen) {
//         final probDiffSmall = (pL - pR).abs() < softMargin;
//         final earDiffSmall  = (((earL ?? 0) - (earR ?? 0)).abs() < 0.05);
//         if (probDiffSmall || earDiffSmall) {
//           leftOpen = true; rightOpen = true;
//         }
//       }

//       final eyeY = center.dy - radius * 0.20;
//       final eyeDX = radius * 0.35;
//       final eyeR = radius * 0.10;

//       if (leftOpen) {
//         canvas.drawCircle(Offset(center.dx - eyeDX, eyeY), eyeR, fill);
//       } else {
//         canvas.drawLine(
//           Offset(center.dx - eyeDX - eyeR, eyeY),
//           Offset(center.dx - eyeDX + eyeR, eyeY),
//           stroke,
//         );
//       }
//       if (rightOpen) {
//         canvas.drawCircle(Offset(center.dx + eyeDX, eyeY), eyeR, fill);
//       } else {
//         canvas.drawLine(
//           Offset(center.dx + eyeDX - eyeR, eyeY),
//           Offset(center.dx + eyeDX + eyeR, eyeY),
//           stroke,
//         );
//       }

//       // ── 입(원본 로직 유지) ──
//       final mouthY = center.dy + radius * 0.25;
//       final double mouthWBase = radius * 0.60;
//       const double talkNarrowFactor = 0.75;
//       final double dynamicNarrow = (1.0 - (mouthOpenRatio * 2.2)).clamp(0.6, 1.0);
//       final double talkingWidthFactor = (talkNarrowFactor * dynamicNarrow).clamp(0.55, 1.0);
//       final double mouthW = (mouthState == MouthState.talking || mouthState == MouthState.open)
//           ? mouthWBase * talkingWidthFactor
//           : mouthWBase;

//       final double mouthHClosed = mouthWBase * 0.05;
//       final double mouthHOpen   = mouthWBase * (0.20 + mouthOpenRatio * 1.2);
//       final double mouthH = (mouthState == MouthState.talking)
//           ? (mouthHOpen * 1.10).clamp(mouthHClosed, radius * 0.7)
//           : mouthHOpen;

//       switch (mouthState) {
//         case MouthState.neutral:
//           canvas.drawLine(
//             Offset(center.dx - mouthWBase / 2, mouthY),
//             Offset(center.dx + mouthWBase / 2, mouthY),
//             stroke,
//           );
//           break;
//         case MouthState.smiling:
//           final double smileW  = mouthWBase * 1.10;
//           final double smileH  = (mouthWBase * 0.55).clamp(6.0, radius * 0.9);
//           final double smileUp = radius * 0.02;
//           final Rect rectSmile = Rect.fromCenter(
//             center: Offset(center.dx, mouthY - smileUp),
//             width: smileW,
//             height: smileH,
//           );
//           canvas.drawArc(rectSmile, math.pi * 0.10, math.pi * 0.80, false, stroke);
//           break;
//         case MouthState.open:
//         case MouthState.talking:
//           final Rect mouthRect = Rect.fromCenter(
//             center: Offset(center.dx, mouthY),
//             width: mouthW,
//             height: mouthH,
//           );
//           canvas.drawOval(mouthRect, stroke);
//           break;
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant FaceDotsPainter old) =>
//       old.faces != faces ||
//       old.imageSize != imageSize ||
//       old.widgetSize != widgetSize ||
//       old.mirror != mirror ||
//       old.sticker != sticker ||
//       old.mouthState != mouthState ||
//       old.mouthOpenRatio != mouthOpenRatio;
// }
// lib/features/one_on_one_chat/face_dots_painter.dart
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum MouthState { neutral, smiling, open, talking }

class FaceDotsPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;    // 카메라 원본(회전 반영 후) 이미지 좌표계 크기
  final Size widgetSize;   // 전체 위젯 크기(사용 X, 필요시 유지)
  final Rect contentRect;  // FittedBox(applyBoxFit)로 실제 프리뷰가 그려지는 영역
  final bool mirror;
  final ui.Image? sticker;
  final MouthState mouthState;
  final double mouthOpenRatio;

  FaceDotsPainter({
    required this.faces,
    required this.imageSize,
    required this.widgetSize,
    required this.contentRect,
    required this.mirror,
    this.sticker,
    required this.mouthState,
    required this.mouthOpenRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ===== 프리뷰가 그려지는 contentRect에 좌표계를 맞춘다 =====
    canvas.save();

    // 1) contentRect의 왼위 모서리로 이동
    canvas.translate(contentRect.left, contentRect.top);

    // 2) 좌우 반전(전면 카메라 미러) – contentRect 내부에서 수행
    if (mirror) {
      canvas.translate(contentRect.width, 0);
      canvas.scale(-1, 1);
    }

    // 3) 이미지좌표 -> contentRect 크기로 스케일
    final sx = contentRect.width  / imageSize.width;
    final sy = contentRect.height / imageSize.height;
    canvas.scale(sx, sy);

    // ===== 이제부터는 "이미지 좌표계"로 그리면 됨 =====
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF222222);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF222222);

    for (final f in faces) {
      final box = f.boundingBox;            // 이미지 좌표계
      final center = Offset(box.center.dx, box.center.dy);

      // ⬇️ 이전엔 화면 스케일을 곱했는데, 위에서 canvas.scale() 했으므로 "이미지 단위" 그대로 사용
      final radius = box.shortestSide * 0.6;

      if (sticker != null) {
        final dst = Rect.fromCircle(center: center, radius: radius * 1.8);
        final src = Rect.fromLTWH(0, 0, sticker!.width.toDouble(), sticker!.height.toDouble());
        canvas.drawImageRect(sticker!, src, dst, Paint());
      } else {
        canvas.drawCircle(center, radius, stroke);
      }

      // ── 눈(확률 + EAR 융합) ──
      const double minFaceWidthPx = 100;
      final bool tinyFace = box.width < minFaceWidthPx;

      final double pL = f.leftEyeOpenProbability  ?? 0.5;
      final double pR = f.rightEyeOpenProbability ?? 0.5;
      const double probOpenThresh = 0.40;
      final bool byProbLeftOpen  = pL > probOpenThresh;
      final bool byProbRightOpen = pR > probOpenThresh;

      double? earFromContour(Face face, FaceContourType t) {
        final contour = face.contours[t];
        if (contour == null || contour.points.isEmpty) return null;
        double minX = contour.points.first.x.toDouble();
        double maxX = minX;
        double minY = contour.points.first.y.toDouble();
        double maxY = minY;
        for (final p in contour.points) {
          final x = p.x.toDouble(), y = p.y.toDouble();
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
        final width = (maxX - minX).abs();
        final height = (maxY - minY).abs();
        if (width <= 0) return null;
        return height / width;
      }

      final earL = earFromContour(f, FaceContourType.leftEye);
      final earR = earFromContour(f, FaceContourType.rightEye);
      const double earOpenThresh = 0.20;
      final bool byEarLeftOpen  = (earL != null) ? (earL > earOpenThresh) : false;
      final bool byEarRightOpen = (earR != null) ? (earR > earOpenThresh) : false;

      bool leftOpen  = tinyFace ? true : (byProbLeftOpen  || byEarLeftOpen);
      bool rightOpen = tinyFace ? true : (byProbRightOpen || byEarRightOpen);

      const double softMargin = 0.08;
      if (!tinyFace && leftOpen != rightOpen) {
        final probDiffSmall = (pL - pR).abs() < softMargin;
        final earDiffSmall  = (((earL ?? 0) - (earR ?? 0)).abs() < 0.05);
        if (probDiffSmall || earDiffSmall) {
          leftOpen = true; rightOpen = true;
        }
      }

      // 눈/입 위치도 이미지 좌표계 기준으로 설정
      final eyeY = center.dy - radius * 0.20;
      final eyeDX = radius * 0.35;
      final eyeR = radius * 0.10;

      if (leftOpen) {
        canvas.drawCircle(Offset(center.dx - eyeDX, eyeY), eyeR, fill);
      } else {
        canvas.drawLine(
          Offset(center.dx - eyeDX - eyeR, eyeY),
          Offset(center.dx - eyeDX + eyeR, eyeY),
          stroke,
        );
      }
      if (rightOpen) {
        canvas.drawCircle(Offset(center.dx + eyeDX, eyeY), eyeR, fill);
      } else {
        canvas.drawLine(
          Offset(center.dx + eyeDX - eyeR, eyeY),
          Offset(center.dx + eyeDX + eyeR, eyeY),
          stroke,
        );
      }

      // ── 입 ──
      final mouthY = center.dy + radius * 0.25;
      final double mouthWBase = radius * 0.60;
      const double talkNarrowFactor = 0.75;
      final double dynamicNarrow = (1.0 - (mouthOpenRatio * 2.2)).clamp(0.6, 1.0);
      final double talkingWidthFactor = (talkNarrowFactor * dynamicNarrow).clamp(0.55, 1.0);
      final double mouthW = (mouthState == MouthState.talking || mouthState == MouthState.open)
          ? mouthWBase * talkingWidthFactor
          : mouthWBase;

      final double mouthHClosed = mouthWBase * 0.05;
      final double mouthHOpen   = mouthWBase * (0.20 + mouthOpenRatio * 1.2);
      final double mouthH = (mouthState == MouthState.talking)
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
          final double smileW  = mouthWBase * 1.10;
          final double smileH  = (mouthWBase * 0.55).clamp(6.0, radius * 0.9);
          final double smileUp = radius * 0.02;
          final Rect rectSmile = Rect.fromCenter(
            center: Offset(center.dx, mouthY - smileUp),
            width: smileW,
            height: smileH,
          );
          canvas.drawArc(rectSmile, math.pi * 0.10, math.pi * 0.80, false, stroke);
          break;
        case MouthState.open:
        case MouthState.talking:
          final Rect mouthRect = Rect.fromCenter(
            center: Offset(center.dx, mouthY),
            width: mouthW,
            height: mouthH,
          );
          canvas.drawOval(mouthRect, stroke);
          break;
      }
    }

    canvas.restore(); // ← 변환 복원
  }

  @override
  bool shouldRepaint(covariant FaceDotsPainter old) =>
      old.faces != faces ||
      old.imageSize != imageSize ||
      old.widgetSize != widgetSize ||
      old.contentRect != contentRect ||  // ✅ contentRect 변경 시에도 리페인트
      old.mirror != mirror ||
      old.sticker != sticker ||
      old.mouthState != mouthState ||
      old.mouthOpenRatio != mouthOpenRatio;
}
