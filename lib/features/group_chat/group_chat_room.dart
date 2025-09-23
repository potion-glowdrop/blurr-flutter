import 'dart:math' as math;

import 'package:blurr/features/group_chat/face_avatar_painter.dart';
import 'package:blurr/features/group_chat/mouth_state.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class ParticipantAvatar extends StatelessWidget {
  final String name;       // 이름 (ex: '새싹')
  final String image;      // 기본 이미지 경로
  final String turnImage;  // 턴일 때 이미지 경로
  final String turn;       // 현재 턴의 이름
  final String? badge;

  // 위치 값
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  // 크기 조정
  final double size;       // 기본 사이즈 (ex: 46)
  final double sizeTurn;   // 턴일 때 사이즈 (ex: 72)

  final bool arOn;
  final bool isSelf;

  //ML 결과
  final MouthState? mouthStateOverride;
  final double? mouthOpenRatioOverride;
  final bool? leftEyeOpenOverride;
  final bool? rightEyeOpenOverride;

  const ParticipantAvatar({
    super.key,
    required this.name,
    required this.image,
    required this.turnImage,
    required this.turn,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.size = 46,
    this.sizeTurn = 72,
    this.badge,
    this.arOn = false,
    this.isSelf = false,
    this.mouthOpenRatioOverride,
    this.mouthStateOverride,
    this.leftEyeOpenOverride,
    this.rightEyeOpenOverride
  });

  @override
  Widget build(BuildContext context) {
    final bool isTurn = (turn == name);
    final double avatarSize = isTurn ? sizeTurn.w : size.w;
    final bool hasBadge = (badge?.trim().isNotEmpty ?? false);

    MouthState mouth = (isSelf && isTurn) ? MouthState.talking : MouthState.neutral;
    double ratio = (mouth == MouthState.talking) ? 0.22 : 0.02;
    bool leftOpen = true;
    bool rightOpen = true;

    mouth = mouthStateOverride ?? mouth;
    ratio = mouthOpenRatioOverride ?? ratio;
    leftOpen = leftEyeOpenOverride ?? leftOpen;
    rightOpen = rightEyeOpenOverride ?? rightOpen;

    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: avatarSize,
                      height: avatarSize,
                      child: OverflowBox(
                        maxHeight: isTurn ? (sizeTurn * 1.78).w : (size * 2.3).w,
                        maxWidth: isTurn ? (sizeTurn * 1.78).w : (size * 2.3).w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.w),
                          child: Image.asset(
                            isTurn ? turnImage : image,
                            width: isTurn ? (sizeTurn * 1.78).w : (size * 2.3).w,
                          ),
                        ),
                      ),
                    ),
                    if(isSelf && arOn)
                      Positioned.fill(child: IgnorePointer(child: CustomPaint(
                        painter: FaceAvatarPainter(mouthState : mouth, mouthOpenRatio: ratio, leftEyeOpen: leftOpen, rightEyeOpen: rightOpen),
                      ),)),
                    if(hasBadge)Positioned(
                    right: -5.w,
                    top: 0,
                    child: 
                      Container(
                        width: 22.w, height: 22.w, 
                        decoration: BoxDecoration( 
                          color: Color(0xFFFFFFFF), 
                          borderRadius: BorderRadius.circular(11.w),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(1, 1),
                              blurRadius: 4.w,
                              color: isTurn?Color(0xFF2BACFF):Color(0xFF000000).withAlpha(7)
                            )
                          ]
                          ),
                          child: Center(child: Text(badge??'', style: TextStyle(fontSize: 14.sp),)),
                          )
                          ),

                  ],
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 21.w,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: isTurn ? const Color(0xFF2BACFF) : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(13.w),
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isTurn ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                      fontFamily: 'IBMPlexSansKR',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class ParticipantsRow extends StatelessWidget {
  final List<String> participants; // 전체 참가자 이름
  final String activeName;         // 발언자 이름

  const ParticipantsRow({
    super.key,
    required this.participants,
    required this.activeName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320.w,
      height: 25.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: participants.map((name) {
          final isActive = name == activeName;

          if (isActive) {
            return Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansKR',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF17A1FA), // 파란색
                  ),
                ),
                SizedBox(width: 3.w),
                Image.asset(
                  'assets/images/icons/mic.png',
                  width: 12.w,
                ),
              ],
            );
          } else {
            return Text(
              name,
              style: TextStyle(
                fontFamily: 'IBMPlexSansKR',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFBDBDBD), // 회색
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}

class SessionInfoCard extends StatelessWidget {
  final String text; // 표시할 문구

  const SessionInfoCard({
    super.key,
    required this.text,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 353.w,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withAlpha(20),
            blurRadius: 4,
            offset: const Offset(1, 1),
          )
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 21.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 44.w,
            height: 44.w,
            child: OverflowBox(
              maxWidth: 104.w,
              maxHeight: 104.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.w),
                child: Image.asset(
                  'assets/images/icons/ai_host.png',
                  width: 104.w,
                  height: 104.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 260.w,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'IBMPlexSansKR',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class GroupRoomPage extends StatefulWidget {
  final String topic;
  final bool myTurn; // 내 차례인지 여부
  final String turn;

  const GroupRoomPage({
    super.key,
    required this.topic,
    this.turn = "바람",
    this.myTurn = false,
  });

  @override
  State<GroupRoomPage> createState() => _GroupRoomPageState();
}
// 파일 상단 import
// ... 기존 GroupRoomPage 코드 내
class _GroupRoomPageState extends State<GroupRoomPage> {
  bool _arOn = true;
  String turn = "나비";
  final String myName = "나비";
  String _myBadge = '☁️';
  final List<String> _emojis = const ['☀️','☁️','☔️','⚡️','🌪️','🌈','❄️'];

  // === ML/Camera ===
  CameraController? _camCtrl;
  Future<void>? _camInit;
  FaceDetector? _detector;
  bool _detecting = false;

  // === 내 표정 상태 ===
  MouthState _mouth = MouthState.neutral;
  double _mouthRatio = 0.0;
  bool _leftOpen = true;
  bool _rightOpen = true;

  // === 스무딩/기준선/히스토리 ===
  double _emaMouth = 0.0;
  bool _emaInitialized = false;

  double _mouthBaseline = 0.03; // 초기 baseline
  int _baselineWarmupFrames = 12;
  int _baselineCount = 0;
  static const double _noiseFloor = 0.005;

  // talking 판정용(변동성)
  final List<double> _mouthOpenHistory = <double>[];
  static const int _mouthHistMax = 8;

  // 히스테리시스 문턱(기준선 대비)
  static const double _deltaOpenUp  = 0.024;
  static const double _deltaCloseDn = 0.012;

  // 스마일 조건
  static const double _smileProbThresh = 0.65;
  static const double _smileOpenBonus  = 0.002;

  // talking 변동성 문턱
  static const double _talkVarThresh = 0.00022;

  // 쿨다운
  int _stateCooldownMs = 120;
  int _lastStateChangeMs = 0;

  // 유틸
  double _ema(double prev, double current, double alpha) => prev + alpha * (current - prev);
  bool _cooldownPassed() => DateTime.now().millisecondsSinceEpoch - _lastStateChangeMs >= _stateCooldownMs;
  void _markStateChange() => _lastStateChangeMs = DateTime.now().millisecondsSinceEpoch;

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
    return h / w; // 높이/너비
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

  // 입 gap / 입 너비(컨투어 우선, 랜드마크 폴백)
  double? _mouthGapOverWidth(Face f) {
    final upperInner = f.contours[FaceContourType.upperLipBottom]?.points;
    final lowerInner = f.contours[FaceContourType.lowerLipTop]?.points;
    if (upperInner != null && lowerInner != null && upperInner.isNotEmpty && lowerInner.isNotEmpty) {
      final u = upperInner[upperInner.length ~/ 2];
      final l = lowerInner[lowerInner.length ~/ 2];
      final gap = (l.y - u.y).abs().toDouble();

      final outer = f.contours[FaceContourType.upperLipTop]?.points;
      if (outer != null && outer.isNotEmpty) {
        final left  = outer.first;
        final right = outer.last;
        final width = (right.x - left.x).abs().toDouble();
        if (width > 0) return gap / width; // 보통 0.1~0.5
      }
    }
    // fallback 1: 외곽 컨투어 + 얼굴 높이
    final upper = f.contours[FaceContourType.upperLipTop]?.points;
    final lower = f.contours[FaceContourType.lowerLipBottom]?.points;
    if (upper != null && lower != null && upper.isNotEmpty && lower.isNotEmpty) {
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

    // 왼/오 미묘 차이는 둘 다 open 처리(깜빡임 과민 억제)
    const softMargin = 0.08;
    final probDiffSmall = (pL - pR).abs() < softMargin;
    final earDiffSmall  = ((earL ?? 0) - (earR ?? 0)).abs() < 0.05;
    if (left != right && (probDiffSmall || earDiffSmall)) {
      left = true; right = true;
    }
    return (leftOpen: left, rightOpen: right);
  }


  @override
  void initState() {
    super.initState();
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true, // 눈/웃음 확률
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    if (_arOn) _ensureArStreamOn();
  }

  @override
  void dispose() {
    _stopImageStreamIfRunning();
    _camCtrl?.dispose();
    _detector?.close();
    super.dispose();
  }

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

  // CameraImage -> InputImage (간단 버전)
  InputImage _toInputImage(CameraImage image, CameraDescription desc) {
    final WriteBuffer buffer = WriteBuffer();
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

  // 입 벌림 비율(입 gap / 입 너비) 계산
  double? _mouthOpenRatioFromFace(Face f) {
    final upperInner = f.contours[FaceContourType.upperLipBottom]?.points;
    final lowerInner = f.contours[FaceContourType.lowerLipTop]?.points;
    if (upperInner != null && lowerInner != null && upperInner.isNotEmpty && lowerInner.isNotEmpty) {
      final u = upperInner[upperInner.length ~/ 2];
      final l = lowerInner[lowerInner.length ~/ 2];
      final gap = (l.y - u.y).abs().toDouble();

      final outer = f.contours[FaceContourType.upperLipTop]?.points;
      if (outer != null && outer.isNotEmpty) {
        final left  = outer.first;
        final right = outer.last;
        final width = (right.x - left.x).abs().toDouble();
        if (width > 0) return gap / width; // 보통 0.1~0.5
      }
    }
    // fallback
    final upper = f.contours[FaceContourType.upperLipTop]?.points;
    final lower = f.contours[FaceContourType.lowerLipBottom]?.points;
    if (upper != null && lower != null && upper.isNotEmpty && lower.isNotEmpty) {
      final u = upper[upper.length ~/ 2];
      final l = lower[lower.length ~/ 2];
      final gap = (l.y - u.y).abs().toDouble();
      final h = f.boundingBox.height.toDouble();
      if (h > 0) return gap / h;
    }
    return null;
  }

  // ✅ 추가: EMA & 근사 비교
  bool _near(double a, double b, [double eps = 0.004]) => (a - b).abs() < eps;

double? _mouthOpenRatioFromLandmarks(Face f) {
  final ml = f.landmarks[FaceLandmarkType.leftMouth]?.position;
  final mr = f.landmarks[FaceLandmarkType.rightMouth]?.position;
  final mb = f.landmarks[FaceLandmarkType.bottomMouth]?.position;

  if (ml == null || mr == null || mb == null) return null;

  // Point<int> -> double 변환 주의
  final mouthWidth = (mr.x - ml.x).abs().toDouble();
  if (mouthWidth <= 0) return null;

  final mouthCornerY = ((ml.y + mr.y) / 2.0);
  final gap = (mb.y - mouthCornerY).abs().toDouble();

  return (gap / mouthWidth).clamp(0.0, 0.8);
}

// 👉 관문: 여기 하나만 쓰게 만들기 (랜드마크 → 컨투어 → 폴백)
double _mouthOpenRatioSmartOrZero(Face f) {
  final byLm = _mouthOpenRatioFromLandmarks(f);
  if (byLm != null) return byLm;

  final byContour = _mouthOpenRatioFromFace(f);
  if (byContour != null) return byContour;

  final upper = f.landmarks[FaceLandmarkType.noseBase]?.position;
  final mb    = f.landmarks[FaceLandmarkType.bottomMouth]?.position;
  final width = f.boundingBox.width.toDouble();
  if (upper != null && mb != null && width > 0) {
    final gap = (mb.y - upper.y).abs().toDouble();
    return (gap / width).clamp(0.0, 0.8);
  }
  return 0.0;
}
  Future<void> _onCameraImage(CameraImage image) async {
    if (_detecting || _detector == null) return;
    _detecting = true;
    try {
      final input = _toInputImage(image, _camCtrl!.description);
      final faces = await _detector!.processImage(input);

      if (faces.isEmpty) {
        if (!mounted) return;
        setState(() {
          _mouth = MouthState.neutral;
          _mouthRatio = 0.0;
          _leftOpen = true;
          _rightOpen = true;
        });
        return;
      }

      final f = faces.first;

      // ----- 눈 상태 -----
      final eyes = _eyesOpen(f);

      // ----- 스마일 확률 -----
      final smileP = f.smilingProbability ?? 0.0;

      // ----- 원시 비율(입 gap/입 너비) -----
      final rawRatio = _mouthGapOverWidth(f) ?? 0.0;

      // ----- inter-eye 정규화 + yaw 블렌딩 -----
      final eyeDist = _interEyeDist(f);
      final faceH   = f.boundingBox.height;
      double ratio2ByEye = rawRatio;
      if (eyeDist != null && eyeDist > 0 && faceH > 0) {
        final k = faceH / eyeDist; // 동일 gap을 inter-eye 기준으로 환산
        ratio2ByEye = rawRatio * k;
      }

      final yawDeg = (f.headEulerAngleY ?? 0.0).abs();
      // yawBlend: 8°부터 영향, 30° 이상 최대
      double yawBlend = ((yawDeg - 8.0) / 22.0).clamp(0.0, 1.0);
      yawBlend = yawBlend * yawBlend; // quad easing
      double blended = rawRatio * (1.0 - yawBlend) + ratio2ByEye * yawBlend;

      // cos 감쇠(너무 과하지 않게 바닥값)
      final yawCos = math.cos((yawDeg * math.pi) / 180.0).clamp(0.70, 1.0);
      final ratioPoseCorrected = blended * yawCos;

      // ----- EMA 스무딩 -----
      if (!_emaInitialized) {
        _emaMouth = ratioPoseCorrected;
        _emaInitialized = true;
      } else {
        _emaMouth = _ema(_emaMouth, ratioPoseCorrected, 0.40);
      }

      // ----- baseline 초기 캘리브레이션 (웃음 아닐 때) -----
      if (_baselineCount < _baselineWarmupFrames && smileP < 0.2) {
        _mouthBaseline =
            ((_mouthBaseline * _baselineCount) + rawRatio) / (_baselineCount + 1);
        _baselineCount++;
      }

      // 최종 사용 비율
      final ema = _emaMouth;

      // 변동성 기록 (talking 판정용)
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

      // 히스테리시스용 기준선 대비
      final aboveRaw = ema - _mouthBaseline;

      // 노이즈 바닥 제거
      final effAbove = (aboveRaw > _noiseFloor) ? (aboveRaw - _noiseFloor) : 0.0;

      // yaw가 클수록 열림 문턱 강화(열릴 때만)
      double _posePenaltyFactorYaw(double yaw) {
        const safe = 10.0, span = 22.0; // 10~32°
        double t = ((yaw.abs() - safe) / span).clamp(0.0, 1.0);
        t = t * t;
        return (1.0 + 0.9 * t); // 1.0~1.9
      }
      final posePenalty = _posePenaltyFactorYaw(yawDeg);

      final wantOpen  = effAbove > (_deltaOpenUp * posePenalty);
      final wantClose = effAbove < _deltaCloseDn;

      // raw 게이트: 현재 프레임도 어느 정도 열려 있어야 함(웃음 중이면 더 엄격)
      final smileNow = (smileP > _smileProbThresh);
      final openBoostWhenSmile = smileNow ? 1.15 : 1.0;
      final rawOpenGate = ( (ratioPoseCorrected - _mouthBaseline) >
          (_deltaOpenUp * posePenalty * 0.95 * openBoostWhenSmile) );

      // 급락 중이면 열림 전이 금지(웃음 잔상 방지)
      double delta = 0.0;
      if (_mouthOpenHistory.length >= 2) {
        delta = _mouthOpenHistory.last - _mouthOpenHistory[_mouthOpenHistory.length - 2];
      }
      final closingFast = delta < -0.004;
      final smileDecayGuard = (!smileNow) && closingFast;

      // ----- 상태머신 + 쿨다운 -----
      MouthState next = _mouth;
      if (_cooldownPassed()) {
        switch (_mouth) {
          case MouthState.neutral:
          case MouthState.smiling:
            if (wantOpen && rawOpenGate && !smileDecayGuard) {
              next = (smileNow && (ratioPoseCorrected - _mouthBaseline) > _smileOpenBonus)
                  ? MouthState.smiling
                  : (variance > _talkVarThresh ? MouthState.talking : MouthState.open);
            } else {
              next = (smileNow && (ratioPoseCorrected - _mouthBaseline) > _smileOpenBonus)
                  ? MouthState.smiling
                  : MouthState.neutral;
            }
            break;

          case MouthState.open:
          case MouthState.talking:
            if (wantClose) {
              next = (smileNow && (ratioPoseCorrected - _mouthBaseline) > _smileOpenBonus)
                  ? MouthState.smiling
                  : MouthState.neutral;
            } else {
              next = (variance > _talkVarThresh) ? MouthState.talking : MouthState.open;
            }
            break;
        }
        if (next != _mouth) _markStateChange();
      }

      // 중립이고 고요하면 baseline을 아주 느리게 따라감(드리프트 방지)
      final likelyClosedNow = (smileP < 0.25) && (variance < 0.00008);
      if (next == MouthState.neutral && likelyClosedNow) {
        _mouthBaseline = _ema(_mouthBaseline, ema, 0.02);
      }

      // setState (불필요 리빌드 최소화)
      final newRatio = ema.clamp(0.0, 0.5);
      if (!mounted) return;
      if (next != _mouth ||
          (newRatio - _mouthRatio).abs() > 0.003 ||
          eyes.leftOpen != _leftOpen ||
          eyes.rightOpen != _rightOpen) {
        setState(() {
          _mouth = next;
          _mouthRatio = newRatio;
          _leftOpen = eyes.leftOpen;
          _rightOpen = eyes.rightOpen;
        });
      }
    } catch (e) {
      debugPrint('onCameraImage error: $e');
    } finally {
      _detecting = false;
    }
  }


// class _GroupRoomPageState extends State<GroupRoomPage> {
//   bool _arOn = true; // AR 필터 On/Off 상태
//   String turn = "나비";
//   final String myName = "나비";
//   String _myBadge = '☁️';
//   final List<String> _emojis = const ['☀️','☁️','☔️','⚡️','🌪️','🌈','❄️'];

//   CameraController? _camCtrl;
//   Future<void>? _camInit;
//   FaceDetector? _detector;
//   bool _detecting = false;

//   MouthState _mouth = MouthState.neutral;
//   double _mouthRatio = 0.02;
//   bool _leftOpen = true;
//   bool _rightOpen = true;

//   @override
//   void initState(){
//     super.initState();
//     _detector = FaceDetector(options: FaceDetectorOptions(
//       enableLandmarks: true,
//       enableContours: true,
//       enableClassification: true,
//       performanceMode: FaceDetectorMode.accurate
//     ));
//     if(_arOn) _ensureArStreamOn();
//   }

//   @override
//   void dispose(){
//     _stopImageStreamIfRunning();
//     _camCtrl?.dispose();
//     _detector?.close();
//     super.dispose();
//   }

//   Future<void> _ensureArStreamOn() async{
//     if(_camCtrl?.value.isInitialized==true&&_camCtrl!.value.isStreamingImages) return;
//     try{
//       final cams = await availableCameras();
//       final front = cams.firstWh
//     }
//   }
  void _toggleAr() async {
    setState(() => _arOn = !_arOn);
    if (_arOn) {
      // 켬 → 스트림 시작
      _emaInitialized = false;
      _mouthOpenHistory.clear();
      _baselineCount = 0;
      await _ensureArStreamOn();
    } else {
      // 끔 → 스트림 중단 + 상태 리셋
      await _stopImageStreamIfRunning();
      setState(() {
        _mouth = MouthState.neutral;
        _mouthRatio = 0.0;
        _mouthBaseline = 0.03; // baseline 리셋
        _emaMouth = 0.0;
        _emaInitialized = false;
        _leftOpen = true;
        _rightOpen = true;
        _mouthOpenHistory.clear();
        _baselineCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경
          Positioned.fill(
            child: Image.asset(
              'assets/illustrations/one_on_one_bgd.png',
              fit: BoxFit.cover,
            ),
          ),

          // 상단 카드 + 참여자
          Positioned(
            top: 100.h,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  const SessionInfoCard(
                    text:
                        '이번 세션의 당신의 닉네임은 나비입니다. 그룹 대화 방에서는 음성과 표정으로 소통할 수 있습니다.',
                  ),
                  SizedBox(height: 11.h),
                  ParticipantsRow(
                    participants: const ['이슬', '나비', '바람', '새싹', '파도'],
                    activeName: turn,
                  ),
                ],
              ),
            ),
          ),

          // 원형 테이블/센터 피스
          Positioned(
            top: 300.h,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  SizedBox(
                    width: 258.w,
                    height: 258.w,
                    child: OverflowBox(
                      maxWidth: 310.w,
                      maxHeight: 310.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.w),
                        child: Image.asset(
                          'assets/images/group/round_table.png',
                          width: 310.w,
                          height: 310.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Image.asset(
                        'assets/images/group/glow.png',
                        width: 150.w,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: SizedBox(
                        width: 72.w,
                        height: 72.w,
                        child: OverflowBox(
                          maxWidth: 198.w,
                          maxHeight: 198.w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.w),
                            child: Image.asset(
                              'assets/images/group/center_piece.png',
                              width: 198.w,
                              height: 198.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),

          ParticipantAvatar(
            name: '새싹',
            image: 'assets/images/group/saessak.png',
            turnImage: 'assets/images/group/saessak_turn.png',
            turn: turn,
            top: turn == '새싹' ? 255.w : 275.w,
            left: 0,
            right: 0,
            badge: '새싹' == myName? _myBadge: null,
            arOn : _arOn && ('새싹'==myName),
            isSelf: '새싹'==myName,
          ),
          ParticipantAvatar(
            name: '파도',
            image: 'assets/images/group/pado.png',
            turnImage: 'assets/images/group/pado_turn.png',
            turn: turn,
            top: turn == '파도' ? 354.w : 374.w,
            left: 250.w,
            right: 0,
            badge: '파도' == myName? _myBadge: null,
            arOn : _arOn && ('파도'==myName),
            isSelf: '파도'==myName,


          ),
          ParticipantAvatar(
            name: '나비',
            image: 'assets/images/group/nabi.png',
            turnImage: 'assets/images/group/nabi_turn.png',
            turn: turn,
            top: turn == '나비' ? 354.w : 374.w,
            left: 0,
            right: 250.w,
            badge: '나비' == myName? _myBadge: null,
            arOn : _arOn && ('나비'==myName),
            isSelf: '나비'==myName,
            mouthStateOverride: _mouth,
            mouthOpenRatioOverride: _mouthRatio,
            leftEyeOpenOverride: _leftOpen,
            rightEyeOpenOverride: _rightOpen,


          ),
          ParticipantAvatar(
            name: '이슬',
            image: 'assets/images/group/iseul.png',
            turnImage: 'assets/images/group/iseul_turn.png',
            turn: turn,
            top: turn == '이슬' ? 495.w : 510.w,
            left: 140.w,
            right: 0,
            badge: '이슬' == myName? _myBadge: null,
            arOn : _arOn && ('이슬'==myName),
            isSelf: '이슬'==myName,


          ),
          ParticipantAvatar(
            name: '바람',
            image: 'assets/images/group/baram.png',
            turnImage: 'assets/images/group/baram_turn.png',
            turn: turn,
            top: turn == '바람' ? 485.w : 500.w,
            left: 0,
            right: 150.w,
            badge: '바람' == myName? _myBadge: null,
            arOn : _arOn && ('바람'==myName),
            isSelf: '바람'==myName,

          ),




          // 하단 컨트롤 박스
          Positioned(
            bottom: 0.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 393.w,
                height: 210.h,
                padding: EdgeInsets.only(top: 21.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(44.w),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withAlpha(15),
                      offset: const Offset(1, 1),
                      blurRadius: 2.7,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 331.w,
                      height: 29.h,
                      child: OverflowBox(
                        maxHeight: 51.w,
                        maxWidth: 356.w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/group/textbox.png',
                                width: 356.w,
                                height: 51.w,
                              ),
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: _emojis.map((e) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _myBadge = e; // 선택한 이모지를 내 아바타 배지로 갱신
                                          });
                                        },
                                        child: Text(
                                          e,
                                          style: TextStyle(fontSize: 16.sp),
                                        ),
                                      );
                                    }).toList(), // ✅ 바로 넣어주면 됨
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 35.h),

                    // 내 차례일 때와 아닐 때 UI 분기
                    if (widget.myTurn)
                      SizedBox(
                        width: 193.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ArToggleButton(
                              arOn: _arOn,
                              onTap: _toggleAr,
                            ),
                            _IconButtonImage(
                              asset: 'assets/images/icons/pass.png',
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: 277.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ArToggleButton(
                              arOn: _arOn,
                              onTap: _toggleAr,
                            ),
                            _IconButtonImage(
                              asset: 'assets/images/icons/prolong.png',
                            ),
                            _IconButtonImage(
                              asset: 'assets/images/icons/end.png',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 뒤로가기 버튼
          Positioned(
            left: 23.w,
            top: 53.h,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: SizedBox(
                width: 44.w,
                height: 44.w,
                child: Image.asset(
                  'assets/images/icons/back_btn.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArToggleButton extends StatelessWidget {
  final bool arOn;
  final VoidCallback onTap;

  const _ArToggleButton({
    required this.arOn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.w,
      height: 44.w,
      child: OverflowBox(
        maxWidth: 104.w,
        maxHeight: 104.w,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Image.asset(
                  arOn
                      ? 'assets/images/icons/ar_filter_on.png'
                      : 'assets/images/icons/ar_filter_off.png',
                  key: ValueKey(arOn),
                  width: 104.w,
                  height: 104.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// 단순 아이콘 버튼(이미지) 래퍼
class _IconButtonImage extends StatelessWidget {
  final String asset;

  const _IconButtonImage({required this.asset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.w,
      height: 44.w,
      child: OverflowBox(
        maxWidth: 104.w,
        maxHeight: 104.w,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: Image.asset(
            asset,
            width: 104.w,
            height: 104.w,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
