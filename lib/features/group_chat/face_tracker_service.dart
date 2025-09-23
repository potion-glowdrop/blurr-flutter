// lib/features/group_chat/face_tracker_service.dart
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'mouth_state.dart';

/// UI에 전달할 얼굴 상태
class FaceExpression {
  final MouthState mouth;
  final double mouthOpenRatio; // 0.0 ~ 0.5 근처
  final bool leftEyeOpen;
  final bool rightEyeOpen;

  const FaceExpression({
    required this.mouth,
    required this.mouthOpenRatio,
    required this.leftEyeOpen,
    required this.rightEyeOpen,
  });

  static const neutral = FaceExpression(
    mouth: MouthState.neutral,
    mouthOpenRatio: 0.0,
    leftEyeOpen: true,
    rightEyeOpen: true,
  );
}

/// 카메라/ML Kit을 관리하고 표정 상태를 방송하는 서비스
class FaceTrackerService {
  // 외부에서 구독할 값
  final ValueNotifier<FaceExpression> expression =
      ValueNotifier<FaceExpression>(FaceExpression.neutral);

  // AR on/off 상태
  bool get arOn => _arOn;
  bool _arOn = false;

  // ========== 내부 상태 ==========
  CameraController? _camCtrl;
  Future<void>? _camInit;
  FaceDetector? _detector;
  bool _detecting = false;

  // 스무딩/기준선/히스토리
  double _emaMouth = 0.0;
  bool _emaInitialized = false;

  double _mouthBaseline = 0.03;
  int _baselineWarmupFrames = 12;
  int _baselineCount = 0;
  static const double _noiseFloor = 0.005;

  final List<double> _mouthOpenHistory = <double>[];
  static const int _mouthHistMax = 8;

  static const double _deltaOpenUp  = 0.024;
  static const double _deltaCloseDn = 0.012;

  static const double _smileProbThresh = 0.65;
  static const double _smileOpenBonus  = 0.002;

  static const double _talkVarThresh = 0.00022;

  int _stateCooldownMs = 120;
  int _lastStateChangeMs = 0;

  double _ema(double prev, double current, double alpha) =>
      prev + alpha * (current - prev);

  bool _cooldownPassed() =>
      DateTime.now().millisecondsSinceEpoch - _lastStateChangeMs >=
      _stateCooldownMs;

  void _markStateChange() =>
      _lastStateChangeMs = DateTime.now().millisecondsSinceEpoch;

  // ====== public lifecycle ======
  Future<void> init() async {
    _detector ??= FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<void> start() async {
    if (_arOn) return;
    _arOn = true;
    await _ensureArStreamOn();
  }

  Future<void> stop() async {
    if (!_arOn) return;
    _arOn = false;
    await _stopImageStreamIfRunning();
    _resetStates();
    expression.value = FaceExpression.neutral;
  }

  Future<void> toggle() async {
    if (_arOn) {
      await stop();
    } else {
      await start();
    }
  }

  Future<void> dispose() async {
    await _stopImageStreamIfRunning();
    await _camCtrl?.dispose();
    _camCtrl = null;
    await _detector?.close();
    _detector = null;
    expression.dispose();
  }

  // ====== camera/stream ======
  Future<void> _ensureArStreamOn() async {
    if (_camCtrl?.value.isInitialized == true &&
        _camCtrl!.value.isStreamingImages) return;

    try {
      final cams = await availableCameras();
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      _camCtrl = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      _camInit = _camCtrl!.initialize();
      await _camInit;
      await _camCtrl!.startImageStream(_onCameraImage);
    } catch (e) {
      debugPrint('AR init error: $e');
    }
  }

  Future<void> _stopImageStreamIfRunning() async {
    try {
      if (_camCtrl?.value.isStreamingImages == true) {
        await _camCtrl!.stopImageStream();
      }
    } catch (_) {}
  }

  void _resetStates() {
    _emaInitialized = false;
    _mouthOpenHistory.clear();
    _baselineCount = 0;
    _mouthBaseline = 0.03;
    _emaMouth = 0.0;
  }

  // ====== helpers ======
  InputImage _toInputImage(CameraImage image, CameraDescription desc) {
    final buffer = WriteBuffer();
    for (final Plane p in image.planes) {
      buffer.putUint8List(p.bytes);
    }
    final bytes = buffer.done().buffer.asUint8List();
    final size = Size(image.width.toDouble(), image.height.toDouble());
    final rotation = InputImageRotationValue.fromRawValue(desc.sensorOrientation)
        ?? InputImageRotation.rotation0deg;
    final format = InputImageFormatValue.fromRawValue(image.format.raw)
        ?? InputImageFormat.yuv420;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: size,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  double? _earFromContour(Face face, FaceContourType t) {
    final c = face.contours[t];
    if (c == null || c.points.isEmpty) return null;
    double minX = c.points.first.x.toDouble(), maxX = minX;
    double minY = c.points.first.y.toDouble(), maxY = minY;
    for (final p in c.points) {
      final x = p.x.toDouble(), y = p.y.toDouble();
      if (x < minX) minX = x; if (x > maxX) maxX = x;
      if (y < minY) minY = y; if (y > maxY) maxY = y;
    }
    final w = (maxX - minX).abs(), h = (maxY - minY).abs();
    if (w <= 0) return null;
    return h / w;
  }

  Offset? _centerOfContour(Face face, FaceContourType t) {
    final c = face.contours[t];
    if (c == null || c.points.isEmpty) return null;
    double sx = 0, sy = 0;
    for (final p in c.points) { sx += p.x.toDouble(); sy += p.y.toDouble(); }
    return Offset(sx / c.points.length, sy / c.points.length);
  }

  double? _interEyeDist(Face face) {
    final lc = _centerOfContour(face, FaceContourType.leftEye);
    final rc = _centerOfContour(face, FaceContourType.rightEye);
    if (lc == null || rc == null) return null;
    return (rc - lc).distance;
  }

  double? _mouthGapOverWidth(Face f) {
    final upperInner = f.contours[FaceContourType.upperLipBottom]?.points;
    final lowerInner = f.contours[FaceContourType.lowerLipTop]?.points;
    if (upperInner != null && lowerInner != null &&
        upperInner.isNotEmpty && lowerInner.isNotEmpty) {
      final u = upperInner[upperInner.length ~/ 2];
      final l = lowerInner[lowerInner.length ~/ 2];
      final gap = (l.y - u.y).abs().toDouble();

      final outer = f.contours[FaceContourType.upperLipTop]?.points;
      if (outer != null && outer.isNotEmpty) {
        final left = outer.first;
        final right = outer.last;
        final width = (right.x - left.x).abs().toDouble();
        if (width > 0) return gap / width;
      }
    }
    // fallback 1: 외곽 컨투어 + 얼굴 높이
    final upper = f.contours[FaceContourType.upperLipTop]?.points;
    final lower = f.contours[FaceContourType.lowerLipBottom]?.points;
    if (upper != null && lower != null &&
        upper.isNotEmpty && lower.isNotEmpty) {
      final u = upper[upper.length ~/ 2];
      final l = lower[lower.length ~/ 2];
      final gap = (l.y - u.y).abs().toDouble();
      final h = f.boundingBox.height.toDouble();
      if (h > 0) return gap / h;
    }
    // fallback 2: 랜드마크
    final ml = f.landmarks[FaceLandmarkType.leftMouth]?.position;
    final mr = f.landmarks[FaceLandmarkType.rightMouth]?.position;
    final mb = f.landmarks[FaceLandmarkType.bottomMouth]?.position;
    if (ml != null && mr != null && mb != null) {
      final width = (mr.x - ml.x).abs().toDouble();
      if (width > 0) {
        final mouthCornerY = ((ml.y + mr.y) / 2.0);
        final gap = (mb.y - mouthCornerY).abs().toDouble();
        return (gap / width).clamp(0.0, 0.8);
      }
    }
    return null;
  }

  ({bool leftOpen, bool rightOpen}) _eyesOpen(Face f) {
    const probOpenThresh = 0.40;
    final pL = f.leftEyeOpenProbability  ?? 0.5;
    final pR = f.rightEyeOpenProbability ?? 0.5;
    final byProbL = pL > probOpenThresh, byProbR = pR > probOpenThresh;

    final earL = _earFromContour(f, FaceContourType.leftEye);
    final earR = _earFromContour(f, FaceContourType.rightEye);
    const earOpenThresh = 0.20;
    final byEarL = (earL != null) ? (earL > earOpenThresh) : false;
    final byEarR = (earR != null) ? (earR > earOpenThresh) : false;

    bool left  = byProbL || byEarL;
    bool right = byProbR || byEarR;

    // soft tie-break
    const softMargin = 0.08;
    final probDiffSmall = (pL - pR).abs() < softMargin;
    final earDiffSmall  = ((earL ?? 0) - (earR ?? 0)).abs() < 0.05;
    if (left != right && (probDiffSmall || earDiffSmall)) {
      left = true; right = true;
    }
    return (leftOpen: left, rightOpen: right);
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (_detecting || _detector == null) return;
    _detecting = true;
    try {
      final input = _toInputImage(image, _camCtrl!.description);
      final faces = await _detector!.processImage(input);

      if (faces.isEmpty) {
        expression.value = FaceExpression.neutral;
        return;
      }
      final f = faces.first;

      // 눈
      final eyes = _eyesOpen(f);
      // 스마일
      final smileP = f.smilingProbability ?? 0.0;
      // 원시 비율
      final rawRatio = _mouthGapOverWidth(f) ?? 0.0;

      // inter-eye 정규화 + yaw 보정
      final eyeDist = _interEyeDist(f);
      final faceH   = f.boundingBox.height;
      double ratio2ByEye = rawRatio;
      if (eyeDist != null && eyeDist > 0 && faceH > 0) {
        final k = faceH / eyeDist;
        ratio2ByEye = rawRatio * k;
      }

      final yawDeg = (f.headEulerAngleY ?? 0.0).abs();
      double yawBlend = ((yawDeg - 8.0) / 22.0).clamp(0.0, 1.0);
      yawBlend = yawBlend * yawBlend;
      double blended = rawRatio * (1.0 - yawBlend) + ratio2ByEye * yawBlend;

      final yawCos = math.cos((yawDeg * math.pi) / 180.0).clamp(0.70, 1.0);
      final ratioPoseCorrected = blended * yawCos;

      // EMA
      if (!_emaInitialized) {
        _emaMouth = ratioPoseCorrected;
        _emaInitialized = true;
      } else {
        _emaMouth = _ema(_emaMouth, ratioPoseCorrected, 0.40);
      }

      // baseline warmup (웃지 않을 때)
      if (_baselineCount < _baselineWarmupFrames && smileP < 0.2) {
        _mouthBaseline =
            ((_mouthBaseline * _baselineCount) + rawRatio) / (_baselineCount + 1);
        _baselineCount++;
      }

      final ema = _emaMouth;

      // 변동성
      _mouthOpenHistory.add(ema);
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

      // 히스테리시스
      final aboveRaw = ema - _mouthBaseline;
      final effAbove = (aboveRaw > _noiseFloor) ? (aboveRaw - _noiseFloor) : 0.0;

      double _posePenaltyFactorYaw(double yaw) {
        const safe = 10.0, span = 22.0;
        double t = ((yaw.abs() - safe) / span).clamp(0.0, 1.0);
        t = t * t;
        return (1.0 + 0.9 * t);
      }
      final posePenalty = _posePenaltyFactorYaw(yawDeg);

      final wantOpen  = effAbove > (_deltaOpenUp * posePenalty);
      final wantClose = effAbove < _deltaCloseDn;

      final smileNow = (smileP > _smileProbThresh);
      final openBoostWhenSmile = smileNow ? 1.15 : 1.0;
      final rawOpenGate = ((ratioPoseCorrected - _mouthBaseline) >
          (_deltaOpenUp * posePenalty * 0.95 * openBoostWhenSmile));

      double delta = 0.0;
      if (_mouthOpenHistory.length >= 2) {
        delta = _mouthOpenHistory.last -
            _mouthOpenHistory[_mouthOpenHistory.length - 2];
      }
      final closingFast = delta < -0.004;
      final smileDecayGuard = (!smileNow) && closingFast;

      MouthState next = expression.value.mouth;
      if (_cooldownPassed()) {
        switch (next) {
          case MouthState.neutral:
          case MouthState.smiling:
            if (wantOpen && rawOpenGate && !smileDecayGuard) {
              next = (smileNow &&
                      (ratioPoseCorrected - _mouthBaseline) > _smileOpenBonus)
                  ? MouthState.smiling
                  : (variance > _talkVarThresh
                      ? MouthState.talking
                      : MouthState.open);
            } else {
              next = (smileNow &&
                      (ratioPoseCorrected - _mouthBaseline) > _smileOpenBonus)
                  ? MouthState.smiling
                  : MouthState.neutral;
            }
            break;

          case MouthState.open:
          case MouthState.talking:
            if (wantClose) {
              next = (smileNow &&
                      (ratioPoseCorrected - _mouthBaseline) > _smileOpenBonus)
                  ? MouthState.smiling
                  : MouthState.neutral;
            } else {
              next = (variance > _talkVarThresh)
                  ? MouthState.talking
                  : MouthState.open;
            }
            break;
        }
        if (next != expression.value.mouth) _markStateChange();
      }

      final likelyClosedNow = (smileP < 0.25) && (variance < 0.00008);
      if (next == MouthState.neutral && likelyClosedNow) {
        _mouthBaseline = _ema(_mouthBaseline, ema, 0.02);
      }

      final newRatio = ema.clamp(0.0, 0.5);

      // 브로드캐스트 (불필요한 emit 줄이려면 diff 체크 가능)
      expression.value = FaceExpression(
        mouth: next,
        mouthOpenRatio: newRatio,
        leftEyeOpen: eyes.leftOpen,
        rightEyeOpen: eyes.rightOpen,
      );
    } catch (e) {
      debugPrint('onCameraImage error: $e');
    } finally {
      _detecting = false;
    }
  }
}
