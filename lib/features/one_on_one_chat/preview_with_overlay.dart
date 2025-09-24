import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:blurr/features/one_on_one_chat/face_dots_painter.dart';
import 'package:blurr/features/one_on_one_chat/face_tracking_service.dart';

class PreviewWithOverlay extends StatelessWidget {
  final FaceTrackingService tracker;
  final ui.Image? sticker;
  final double w;
  final double h;
  final bool showPreview;
  final bool showOverlay;

  const PreviewWithOverlay({
    super.key,
    required this.tracker,
    required this.sticker,
    required this.w,
    required this.h,
    this.showPreview = true,
    this.showOverlay = true,
  });


  @override
  Widget build(BuildContext context) {
        if(!showPreview && !showOverlay){
      return SizedBox(width: w, height: h,);
    }
    final ctrl = tracker.controller;
    if (ctrl == null) {
      return Container(width: w, height: h, color: Colors.black);
    }

    return FutureBuilder<void>(
      future: tracker.cameraInitFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(
            width: w,
            height: h,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final previewSize = ctrl.value.previewSize;
        final double pw = previewSize?.width ?? w;
        final double ph = previewSize?.height ?? h;

        return ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: Stack(
            fit: StackFit.expand,
            children: [

              // 카메라 프리뷰
              if (showPreview)
                FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: ph,
                    height: pw,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(0),
                      child: CameraPreview(ctrl),
                    ),
                  ),
                ),

              // 오버레이 (서비스의 값 구독)
              if (showOverlay)
                LayoutBuilder(
                  builder: (context, c) {
                    final imgSize = Size(
                      ctrl.value.previewSize?.height ?? h,
                      ctrl.value.previewSize?.width ?? w,
                    );
                    final widgetSize = Size(c.maxWidth, c.maxHeight);
                    final fitted = applyBoxFit(BoxFit.contain, imgSize, widgetSize);
                    final dest = fitted.destination;
                    final dx = (widgetSize.width - dest.width);
                    final dy = (widgetSize.height - dest.height);
                    final contentRect = Rect.fromLTWH(dx, dy, dest.width, dest.height);

                    return ValueListenableBuilder<List<Face>>(
                      valueListenable: tracker.faces,
                      builder: (_, faces, __) {
                        return ValueListenableBuilder<MouthState>(
                          valueListenable: tracker.mouthState,
                          builder: (_, ms, __) {
                            return ValueListenableBuilder<double>(
                              valueListenable: tracker.mouthOpenRatio,
                              builder: (_, ratio, __) {
                                return CustomPaint(
                                  painter: FaceDotsPainter(
                                    faces: faces,
                                    imageSize: imgSize,
                                    widgetSize: widgetSize,
                                    contentRect: contentRect,
                                    mirror: true,
                                    sticker: sticker,
                                    mouthState: ms,
                                    mouthOpenRatio: ratio,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
