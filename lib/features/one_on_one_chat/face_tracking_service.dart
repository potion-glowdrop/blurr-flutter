// lib/features/one_on_one_chat/face_tracking_service.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show WriteBuffer, ValueNotifier;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:blurr/features/one_on_one_chat/face_dots_painter.dart'; // MouthState

class FaceTrackingService {
  // ───────── Camera & MLKit ─────────
  CameraController? _camCtrl;
  Future<void>? _camInit;
  FaceDetector? _faceDetector;
  bool _detecting = false;

  CameraController? get controller => _camCtrl;
  Future<void>? get cameraInitFuture => _camInit;

  // 외부로 제공되는 상태 (구독용)
  final faces = ValueNotifier<List<Face>>(<Face>[]);
  final mouthState = ValueNotifier<MouthState>(MouthState.neutral);
  final mouthOpenRatio = ValueNotifier<double>(0.0);

  // ───────── 입 상태 안정화 파라미터들 (원문 그대로) ─────────
  double _emaMouth = 0.0;
  bool _emaInitialized = false;

  static const double _noiseFloor = 0.005; // 0.3%~0.5% 정도

  double _mouthBaseline = 0.03; // 얼굴 높이 대비 기본 닫힘값(합리적 초기값)
  int _baselineWarmupFrames = 12; // 초기 캘리브레이션 프레임 수
  int _baselineCount = 0;

  static const double _deltaOpenUp   = 0.024; // 열릴 때: baseline + 0.020 이상
  static const double _deltaCloseDn  = 0.012; // 닫힐 때: baseline + 0.012 미만

  static const double _smileProbThresh = 0.65;
  static const double _smileOpenBonus  = 0.002;

  static const double _talkVarThresh = 0.00022;

  int _stateCooldownMs = 120;
  int _lastStateChangeMs = 0;

  // 간단 스무딩/말하기 감지용(프레임 변동성)
  final List<double> _mouthOpenHistory = <double>[];
  static const int _mouthHistMax = 8; // 최근 8프레임 정도

  // ───────── lifecycle ─────────
  Future<void> init({bool startStream = false}) async {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    final cams = await availableCameras();
    final front = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cams.first,
    );

    _camCtrl = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // ML Kit용
    );

    _camInit = _camCtrl!.initialize();
    await _camInit;

    if (startStream) {
      await startStreamIfNeeded();
    }
  }

  Future<void> startStreamIfNeeded() async {
    final ctrl = _camCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (ctrl.value.isStreamingImages) return;

    try {
      await ctrl.startImageStream(_onCameraImage);
    } catch (e) {
      debugPrint('startImageStream error: $e');
    }
  }

  Future<void> stopStreamIfRunning() async {
    final ctrl = _camCtrl;
    if (ctrl == null) return;
    if (ctrl.value.isStreamingImages) {
      try {
        await ctrl.stopImageStream();
      } catch (e) {
        debugPrint('stopImageStream error: $e');
      }
    }
  }

  Future<void> resumePreviewIfPossible() async {
    try {
      await _camCtrl?.resumePreview();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stopStreamIfRunning();
    await _camCtrl?.dispose();
    _camCtrl = null;
    _camInit = null;

    await _faceDetector?.close();
    _faceDetector = null;
  }

  // ───────── helpers ─────────
  double _ema(double prev, double current, double alpha) {
    return prev + alpha * (current - prev);
  }

  bool _cooldownPassed() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - _lastStateChangeMs) >= _stateCooldownMs;
  }

  void _markStateChange() {
    _lastStateChangeMs = DateTime.now().millisecondsSinceEpoch;
  }

  Offset? _landmark(Face f, FaceLandmarkType t) {
    final lm = f.landmarks[t];
    if (lm == null) return null;
    return Offset(lm.position.x.toDouble(), lm.position.y.toDouble());
  }

  List<Offset>? _contour(Face f, FaceContourType t) {
    final c = f.contours[t];
    if (c == null || c.points.isEmpty) return null;
    return c.points.map((p) => Offset(p.x.toDouble(), p.y.toDouble())).toList();
  }

  /// 입 벌림 비율을 반환 (얼굴 높이에 대한 윗입술-아랫입술 거리 비율)
  double? _computeMouthOpenRatio(Face f) {
    // inner contour 우선
    final upperInner = _contour(f, FaceContourType.upperLipBottom);
    final lowerInner = _contour(f, FaceContourType.lowerLipTop);

    if (upperInner != null && lowerInner != null) {
      final u = upperInner[upperInner.length ~/ 2];
      final l = lowerInner[lowerInner.length ~/ 2];
      final mouthGap = (l.dy - u.dy).abs();

      // 정규화 기준 개선: 얼굴 높이 대신 "입 너비"가 더 민감
      final mouthOuterLeft  = _contour(f, FaceContourType.upperLipTop)?.first;
      final mouthOuterRight = _contour(f, FaceContourType.upperLipTop)?.last;

      double norm;
      if (mouthOuterLeft != null && mouthOuterRight != null) {
        norm = (mouthOuterRight.dx - mouthOuterLeft.dx).abs(); // 입 너비로 정규화
      } else {
        norm = f.boundingBox.height; // fallback
      }

      if (norm <= 0) return null;
      return mouthGap / norm;
    }

    // fallback: 기존 외곽 컨투어
    final upper = _contour(f, FaceContourType.upperLipTop);
    final lower = _contour(f, FaceContourType.lowerLipBottom);
    if (upper != null && lower != null) {
      final u = upper[upper.length ~/ 2];
      final l = lower[lower.length ~/ 2];
      final mouthGap = (l.dy - u.dy).abs();
      final norm = f.boundingBox.height;
      if (norm <= 0) return null;
      return mouthGap / norm;
    }

    // 마지막 fallback: 랜드마크
    final mouthLeft  = _landmark(f, FaceLandmarkType.leftMouth);
    final mouthRight = _landmark(f, FaceLandmarkType.rightMouth);
    final mouthBottom = _landmark(f, FaceLandmarkType.bottomMouth);
    if (mouthLeft != null && mouthRight != null && mouthBottom != null) {
      final midX = (mouthLeft.dx + mouthRight.dx) / 2;
      final mid = Offset(midX, (mouthLeft.dy + mouthRight.dy) / 2);
      final mouthGap = (mouthBottom.dy - mid.dy).abs();
      final norm = (mouthRight.dx - mouthLeft.dx).abs(); // 입 너비 정규화 시도
      if (norm <= 0) return null;
      return mouthGap / norm;
    }

    return null;
  }

  InputImage _toInputImage(CameraImage image, CameraDescription desc) {
    final writeBuffer = WriteBuffer();
    for (final Plane plane in image.planes) {
      writeBuffer.putUint8List(plane.bytes);
    }
    final allBytes = writeBuffer.done().buffer.asUint8List();

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final rotation =
        InputImageRotationValue.fromRawValue(desc.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.yuv420;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.isNotEmpty ? image.planes.first.bytesPerRow : 0,
    );

    return InputImage.fromBytes(bytes: allBytes, metadata: metadata);
  }

  // ───────── main image callback ─────────
  Future<void> _onCameraImage(CameraImage image) async {
    if (_detecting || _faceDetector == null || _camCtrl == null) return;
    _detecting = true;
    try {
      final input = _toInputImage(image, _camCtrl!.description);
      final detected = await _faceDetector!.processImage(input);
      faces.value = detected;

      if (detected.isNotEmpty) {
        final f = detected.first;

        final smileP = f.smilingProbability ?? 0.0;
        final rawRatio = _computeMouthOpenRatio(f) ?? 0.0;

        // === 1) inter-eye 정규화로 보강 ===
        Offset? _centerOfContour(Face face, FaceContourType t) {
          final c = face.contours[t];
          if (c == null || c.points.isEmpty) return null;
          double sumX = 0, sumY = 0;
          for (final p in c.points) {
            sumX += p.x.toDouble();
            sumY += p.y.toDouble();
          }
          return Offset(sumX / c.points.length, sumY / c.points.length);
        }

        double? _interEyeDist(Face face) {
          final lc = _centerOfContour(face, FaceContourType.leftEye);
          final rc = _centerOfContour(face, FaceContourType.rightEye);
          if (lc == null || rc == null) return null;
          return (rc - lc).distance;
        }

        double ratio2ByEye = rawRatio;
        final eyeDist = _interEyeDist(f);
        if (eyeDist != null && eyeDist > 0) {
          final faceHeight = f.boundingBox.height;
          final k = (faceHeight > 0) ? (faceHeight / eyeDist) : 1.0;
          ratio2ByEye = rawRatio * k;
        }

        // === 2) Yaw에 따른 blend ===
        final double yawDeg  = f.headEulerAngleY ?? 0.0;
        final double yawAbs  = yawDeg.abs();

        double yawBlend = ((yawAbs - 8.0) / 22.0).clamp(0.0, 1.0);
        final double ratioBlended = rawRatio * (1.0 - yawBlend) + ratio2ByEye * yawBlend;

        // === 3) 추가 감쇠: cos(yaw) ===
        final double yawCos = math.cos((yawAbs * math.pi) / 180.0).clamp(0.70, 1.0);
        final double ratioPoseCorrected = ratioBlended * yawCos;

        // === 4) EMA ===
        if (!_emaInitialized) {
          _emaMouth = ratioPoseCorrected;
          _emaInitialized = true;
        } else {
          _emaMouth = _ema(_emaMouth, ratioPoseCorrected, 0.40);
        }
        mouthOpenRatio.value = _emaMouth;

        // 초기 캘리브레이션 (웃음이 아닐 때에만)
        if (_baselineCount < _baselineWarmupFrames && smileP < 0.2) {
          _mouthBaseline = ((_mouthBaseline * _baselineCount) + rawRatio) / (_baselineCount + 1);
          _baselineCount++;
        }

        // 변동성(말하기 감지)
        _mouthOpenHistory.add(_emaMouth);
        if (_mouthOpenHistory.length > _mouthHistMax) {
          _mouthOpenHistory.removeAt(0);
        }
        double mean = 0;
        for (final v in _mouthOpenHistory) { mean += v; }
        mean /= _mouthOpenHistory.length;
        double varSum = 0;
        for (final v in _mouthOpenHistory) { varSum += (v - mean) * (v - mean); }
        final variance = (_mouthOpenHistory.length > 1)
            ? varSum / (_mouthOpenHistory.length - 1)
            : 0;

        // 상태 결정
        final double effAbove = ((_emaMouth - _mouthBaseline) > _noiseFloor)
            ? ((_emaMouth - _mouthBaseline) - _noiseFloor)
            : 0.0;

        double _posePenaltyFactorYaw(double yaw) {
          const safe = 10.0;
          const span = 22.0; // 10→32도
          double t = ((yaw.abs() - safe) / span).clamp(0.0, 1.0);
          t = t * t;
          return (1.0 + 0.9 * t); // 1.0~1.9
        }

        final double posePenalty = _posePenaltyFactorYaw(yawDeg);
        final bool wantOpen  = effAbove > (_deltaOpenUp * posePenalty);
        final bool wantClose = effAbove < _deltaCloseDn;

        final double currentAboveRaw = (ratioPoseCorrected - _mouthBaseline);
        final bool smileCurrently = (smileP > _smileProbThresh);
        final double openBoostWhenSmile = smileCurrently ? 1.15 : 1.0;
        final bool rawOpenGate = currentAboveRaw >
            (_deltaOpenUp * posePenalty * 0.95 * openBoostWhenSmile);

        double delta = 0.0;
        if (_mouthOpenHistory.length >= 2) {
          delta = _mouthOpenHistory.last - _mouthOpenHistory[_mouthOpenHistory.length - 2];
        }
        final bool closingFast = delta < -0.004;
        final bool smileDecayGuard = (!smileCurrently) && closingFast;

        if (_cooldownPassed()) {
          var next = mouthState.value;

          switch (mouthState.value) {
            case MouthState.neutral:
            case MouthState.smiling:
              if (wantOpen && rawOpenGate && !smileDecayGuard) {
                next = (smileCurrently && currentAboveRaw > _smileOpenBonus)
                    ? MouthState.smiling
                    : (variance > _talkVarThresh ? MouthState.talking : MouthState.open);
              } else {
                next = (smileCurrently && currentAboveRaw > _smileOpenBonus)
                    ? MouthState.smiling
                    : MouthState.neutral;
              }
              break;

            case MouthState.open:
            case MouthState.talking:
              if (wantClose) {
                next = (smileCurrently && currentAboveRaw > _smileOpenBonus)
                    ? MouthState.smiling
                    : MouthState.neutral;
              } else {
                next = (variance > _talkVarThresh) ? MouthState.talking : MouthState.open;
              }
              break;
          }

          if (next != mouthState.value) {
            mouthState.value = next;
            _markStateChange();
          }
        }

        // 중립 + 변동성 낮고 웃음도 약할 때 baseline을 아주 느리게 보정
        final bool likelyClosedNow = (smileP < 0.25) && (variance < 0.00008);
        if (mouthState.value == MouthState.neutral && likelyClosedNow) {
          _mouthBaseline = _ema(_mouthBaseline, _emaMouth, 0.02); // 2% 속도
        }
      }
    } catch (e, st) {
      debugPrint('onCameraImage error: $e\n$st');
    } finally {
      _detecting = false;
    }
  }
}
