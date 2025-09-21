
// import 'package:blurr/features/one_on_one_chat/chat_done.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'dart:math' as math;
// import 'package:camera/camera.dart';

// /// 채팅방 페이지 (UI 데모용)
// class OneOnOneChatRoomPage extends StatefulWidget {
//   final String code;
//   const OneOnOneChatRoomPage({super.key, required this.code});

//   @override
//   State<OneOnOneChatRoomPage> createState() => _OneOnOneChatRoomPageState();
// }

// class _OneOnOneChatRoomPageState extends State<OneOnOneChatRoomPage> {
//   bool _arOn = false; // ✅ AR 필터 on/off 상태
//   CameraController? _camCtrl;
//   Future<void>? _camInit;

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   Future<void> _initCamera() async {
//     try {
//       final cams = await availableCameras();
//       // 전면 카메라 선택
//       final front = cams.firstWhere(
//         (c) => c.lensDirection == CameraLensDirection.front,
//         orElse: () => cams.first,
//       );
//       // 오디오가 필요 없다면 enableAudio: false
//       _camCtrl = CameraController(front, ResolutionPreset.medium, enableAudio: true);
//       _camInit = _camCtrl!.initialize();
//       await _camInit;
//       if (mounted) setState(() {});
//     } catch (e) {
//       // 실패 시 로그 정도만
//       // ignore: avoid_print
//       print('Camera init error: $e');
//     }
//   }
// Widget _selfiePreviewBox({required double width, required double height}) {
//   final ctrl = _camCtrl;
//   if (ctrl == null) {
//     return Container(width: width, height: height, color: Colors.black);
//   }
//   return FutureBuilder<void>(
//     future: _camInit,
//     builder: (context, snap) {
//       if (snap.connectionState != ConnectionState.done) {
//         return SizedBox(
//           width: width,
//           height: height,
//           child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
//         );
//       }

//       // CameraPreview를 컨테이너 비율(340x220)로 꽉 채우기 (cover)
//       final previewSize = ctrl.value.previewSize; // (w,h) = 카메라 센서 기준
//       final double pw = previewSize?.width ?? width;
//       final double ph = previewSize?.height ?? height;

//       // 가로/세로 전환 때문에 폭/높이가 뒤집혀 보일 수 있어 FittedBox로 안전하게 cover
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(10.w),
//         child: FittedBox(
//           fit: BoxFit.cover,
//           child: SizedBox(
//             // previewSize는 기기 회전에 따라 바뀔 수 있어 넉넉히 잡아서 cover 처리
//             width: ph,  // portrait에서 카메라 미리보기는 보통 h가 화면 폭 역할
//             height: pw, // 반대로
//             child: Transform(
//               alignment: Alignment.center,
//               // ✅ 좌우 반전: rotateY(pi) 또는 scaleX: -1 사용
//               transform: Matrix4.identity()..rotateY(0),
//               child: CameraPreview(ctrl),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

//   @override
//   void dispose() {
//     _camCtrl?.dispose();
//     super.dispose();
//   }


//   @override
//   void didChangeDependencies() {
//     // 선택: 이미지 미리 로드해서 깜빡임 방지
//     precacheImage(const AssetImage('assets/images/icons/ar_filter_on.png'), context);
//     precacheImage(const AssetImage('assets/images/icons/ar_filter_off.png'), context);
//     super.didChangeDependencies();
//   }
// Widget camera_box(String name, {bool isSelf = false}) {
//   return Stack(
//     children: [
//       Image.asset('assets/images/one_on_one/member_box.png', width: 375.w),

//       // 1) 항상 영상 먼저 깔기 (self면 카메라, 아니면 placeholder/상대영상)
//       if (isSelf && !_arOn)
//       Positioned(
//         top: 18.h,
//         left: 0,
//         right: 0,
//         child: Center(
//           child: SizedBox(
//             width: 340.w,
//             height: 220.h,
//             child: isSelf
//                 ? _selfiePreviewBox(width: 340.w, height: 220.h) // 내 카메라(미러)
//                 : ClipRRect(
//                     borderRadius: BorderRadius.circular(10.w),
//                     child: Container(color: Colors.black),         // 상대방 자리(임시)
//                   ),
//           ),
//         ),
//       ),

//       // 2) AR 오버레이는 "내 박스 + ON"일 때만 위에 얹기
//       if (isSelf && _arOn)
//         Positioned(
//           top: 23.h,
//           left: 0,
//           right: 0,
//           child: Center(
//             child: Image.asset(
//               'assets/images/one_on_one/ar_background.png',
//               width: 152.5.w,
//             ),
//           ),
//         ),
//       // 이름 배지
//       Positioned(
//         top: 22.h,
//         right: 26.w,
//         child: Container(
//           height: 32.27.h,
//           padding: EdgeInsets.symmetric(horizontal: 9.w),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2BACFF),
//             borderRadius: BorderRadius.circular(13.w),
//           ),
//           child: Center(
//             child: Text(
//               name,
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 color: Colors.white,
//                 fontFamily: 'IBMPlexSansKR',
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // 배경
//           Positioned.fill(
//             child: Image.asset(
//               'assets/illustrations/one_on_one_bgd.png',
//               fit: BoxFit.cover,
//             ),
//           ),

//           // 콘텐츠
//           Positioned(
//             top: 128.h,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   camera_box('김상담'),
//                   // Image.asset('assets/images/one_on_one/member_box.png', width: 375.w),
//                   SizedBox(height: 28.h),
//                   camera_box('나비', isSelf: true),
//                   SizedBox(height: 19.h),

//                   // ✅ AR 필터 on/off 토글 버튼
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: () => setState(() => _arOn = !_arOn),
//                       borderRadius: BorderRadius.circular(12.r),
//                       child: Padding(
//                         padding: EdgeInsets.all(6.w), // 터치 여유
//                         child: AnimatedSwitcher(
//                           duration: const Duration(milliseconds: 160),
//                           switchInCurve: Curves.easeOut,
//                           switchOutCurve: Curves.easeIn,
//                           transitionBuilder: (child, anim) =>
//                               FadeTransition(opacity: anim, child: child),
//                           child: Image.asset(
//                             _arOn
//                                 ? 'assets/images/icons/ar_filter_on.png'
//                                 : 'assets/images/icons/ar_filter_off.png',
//                             key: ValueKey(_arOn), // 상태별 키로 전환 애니메이션
//                             width: 104.w,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // exit 버튼 (유한 크기 보장 + 올바른 onTap)
//           Positioned(
//             left: -10.w,
//             top: 35.h,
//             width: 85.w,
//             height: 86.5.w,
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () {
//                   Navigator.pushReplacement(context, 
//                     PageRouteBuilder(pageBuilder: (_, __, ___)=> const OneOnOneDone(),
//                     transitionDuration: const Duration(milliseconds: 220),
//                     reverseTransitionDuration: const Duration(milliseconds: 180),
//                     transitionsBuilder: (_, a, __, child)=> FadeTransition(opacity: a, child: child,)
//                     )
//                   );
//                 },
//                 customBorder: const CircleBorder(),
//                 child: Stack(
//                   fit: StackFit.expand,
//                   alignment: Alignment.center,
//                   children: [
//                     Image.asset('assets/images/icons/exit.png', fit: BoxFit.contain),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:blurr/features/one_on_one_chat/chat_done.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:camera/camera.dart';

// LiveKit: ConnectionState 충돌 방지
import 'package:livekit_client/livekit_client.dart' hide ConnectionState;
// WebRTC fit enum
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

/// 채팅방 페이지 (UI 데모용)
class OneOnOneChatRoomPage extends StatefulWidget {
  final String code;
  const OneOnOneChatRoomPage({super.key, required this.code});

  @override
  State<OneOnOneChatRoomPage> createState() => _OneOnOneChatRoomPageState();
}

class _OneOnOneChatRoomPageState extends State<OneOnOneChatRoomPage> {
  bool _arOn = false;

  // ───────── 기존 카메라(연결 전 미리보기) ─────────
  CameraController? _camCtrl;
  Future<void>? _camInit;

  // ───────── LiveKit 2.2.0 상태 ─────────
  Room? _lkRoom;
  EventsListener<RoomEvent>? _lkListener;
  bool _lkConnected = false;

  @override
  void initState() {
    super.initState();
    _initCamera();      // 연결 전 미리보기
    _connectLiveKit();  // LiveKit 연결 (토큰/URL은 TODO)
  }
Future<void> _toggleAR() async {
  final next = !_arOn;

  try {
    if (next) {
      // 🔵 AR 켜기: 카메라 OFF
      if (_lkConnected) {
        await _lkRoom?.localParticipant?.setCameraEnabled(false);
      } else {
        // 연결 전 미리보기일 때: pausePreview()가 있으면 일시정지, 없으면 숨기기만
        try {
          await _camCtrl?.pausePreview(); // 일부 버전에서 제공됨
        } catch (_) {
          // pausePreview 미지원이면 그냥 숨기기만(실제 stop하려면 dispose 후 재init 필요)
        }
      }
    } else {
      // 🔴 AR 끄기: 카메라 ON (전면)
      if (_lkConnected) {
        await _lkRoom?.localParticipant?.setCameraEnabled(
          true,
          cameraCaptureOptions: const CameraCaptureOptions(
            cameraPosition: CameraPosition.front,
          ),
        );
      } else {
        try {
          await _camCtrl?.resumePreview();
        } catch (_) {
          // resumePreview 미지원이면 필요 시 재초기화
          if (_camCtrl == null || _camCtrl?.value.isInitialized != true) {
            await _initCamera();
          }
        }
      }
    }
  } finally {
    if (mounted) setState(() => _arOn = next);
  }
}

  // ───────── LiveKit 연결 ─────────
  Future<void> _connectLiveKit() async {
    try {
      final String livekitUrl = 'wss://YOUR-LIVEKIT-URL'; // TODO
      final String token = await _fetchTokenFromBackend(
        roomName: widget.code,
        identity: 'nabi-${DateTime.now().millisecondsSinceEpoch}',
      );

      final room = Room();
      _lkRoom = room;

      // 이벤트 리스너
      _lkListener = room.createListener()
        ..on<RoomDisconnectedEvent>((e) {
          setState(() => _lkConnected = false);
        })
        ..on<ParticipantConnectedEvent>((e) {
          setState(() {}); // UI 갱신
        })
        ..on<ParticipantDisconnectedEvent>((e) {
          setState(() {});
        })
        ..on<TrackSubscribedEvent>((e) {
          setState(() {}); // 원격 트랙 구독됨
        })
        ..on<TrackUnsubscribedEvent>((e) {
          setState(() {});
        });

      await room.connect(livekitUrl, token);

      // 내 카메라/마이크 ON (전면)
      await room.localParticipant?.setCameraEnabled(
        true,
        cameraCaptureOptions:
            const CameraCaptureOptions(cameraPosition: CameraPosition.front),
      );
      await room.localParticipant?.setMicrophoneEnabled(true);

      if (mounted) setState(() => _lkConnected = true);

      // 충돌 방지: LiveKit가 카메라 점유 후 기존 카메라 정리
      await _disposeLocalCamera();
    } catch (e) {
      debugPrint('LiveKit connect error: $e');
    }
  }

  // TODO: 실제 백엔드 호출로 교체
  Future<String> _fetchTokenFromBackend({
    required String roomName,
    required String identity,
  }) async {
    throw UnimplementedError('TODO: implement token fetch');
  }

  // ───────── 기존 카메라(연결 전) ─────────
  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      _camCtrl =
          CameraController(front, ResolutionPreset.medium, enableAudio: true);
      _camInit = _camCtrl!.initialize();
      await _camInit;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _disposeLocalCamera() async {
    try {
      await _camCtrl?.dispose();
      _camCtrl = null;
      _camInit = null;
    } catch (_) {}
  }

  Widget _selfiePreviewBox({required double width, required double height}) {
    final ctrl = _camCtrl;
    if (ctrl == null) {
      return Container(width: width, height: height, color: Colors.black);
    }
    return FutureBuilder<void>(
      future: _camInit,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(
            width: width,
            height: height,
            child:
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final previewSize = ctrl.value.previewSize;
        final double pw = previewSize?.width ?? width;
        final double ph = previewSize?.height ?? height;

        return ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: FittedBox(
            fit: BoxFit.cover,
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
        );
      },
    );
  }

// ===== 공통 헬퍼 =====
VideoTrack? _firstLocalVideoTrack(LocalParticipant? lp) {
  if (lp == null) return null;
  for (final pub in lp.videoTrackPublications) {
    final t = pub.track;                 // LocalVideoTrack?
    if (t != null && !pub.isScreenShare) {
      return t;                          // upcast: LocalVideoTrack -> VideoTrack
    }
  }
  return null;
}

VideoTrack? _firstRemoteVideoTrack(RemoteParticipant? rp) {
  if (rp == null) return null;
  for (final pub in rp.videoTrackPublications) {
    if (pub.subscribed && !pub.isScreenShare) {
      final t = pub.track;               // RemoteVideoTrack?
      if (t != null) return t;           // upcast -> VideoTrack
    }
  }
  return null;
}

// ===== 내 비디오 =====
Widget _localVideoBox() {
  final room = _lkRoom;
  if (room == null) return Container(color: Colors.black);

  final track = _firstLocalVideoTrack(room.localParticipant); // VideoTrack?
  if (track == null) return Container(color: Colors.black);

  return ClipRRect(
    borderRadius: BorderRadius.circular(10.w),
    child: VideoTrackRenderer(
      track, // <-- VideoTrack (nonnull)
      mirrorMode: VideoViewMirrorMode.mirror,
      fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    ),
  );
}

// ===== 상대 비디오 (첫 번째 원격 참가자) =====
Widget _remoteVideoBox() {
  final room = _lkRoom;
  if (room == null) return Container(color: Colors.black);

  final rp = room.remoteParticipants.values.isNotEmpty
      ? room.remoteParticipants.values.first
      : null;

  final track = _firstRemoteVideoTrack(rp); // VideoTrack?
  if (track == null) return Container(color: Colors.black);

  return ClipRRect(
    borderRadius: BorderRadius.circular(10.w),
    child: VideoTrackRenderer(
      track, // <-- VideoTrack (nonnull)
      fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    ),
  );
}


  @override
  void dispose() {
    _lkListener?.dispose();
    _lkRoom?.dispose();
    _camCtrl?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(
        const AssetImage('assets/images/icons/ar_filter_on.png'), context);
    precacheImage(
        const AssetImage('assets/images/icons/ar_filter_off.png'), context);
    super.didChangeDependencies();
  }
Widget _arCircle() {
  return Center(
    child: Image.asset(
      'assets/images/one_on_one/ar_background.png',
      width: 152.5.w,
    ),
  );
}

Widget camera_box(String name, {bool isSelf = false}) {
  final live = _lkConnected;

  Widget content() {
    // ✅ AR ON이면 (내 박스에서) 카메라 대신 AR 동그라미만
    if (isSelf && _arOn) return _arCircle();

    // ✅ AR OFF이면 기존 로직대로 카메라/미리보기
    if (live) {
      return isSelf ? _localVideoBox() : _remoteVideoBox();
    } else {
      return isSelf
          ? _selfiePreviewBox(width: 340.w, height: 220.h)
          : ClipRRect(
              borderRadius: BorderRadius.circular(10.w),
              child: Container(color: Colors.black),
            );
    }
  }

  return Stack(
    children: [
      Image.asset('assets/images/one_on_one/member_box.png', width: 375.w),
      Positioned(
        top: 18.h,
        left: 0,
        right: 0,
        child: Center(
          child: SizedBox(width: 340.w, height: 220.h, child: content()),
        ),
      ),
      // ⛔️ (삭제) if (isSelf && _arOn)로 위에 덧씌우던 AR 오버레이 — 이제 content()에서 대체하므로 필요 없음

      // 이름 배지
      Positioned(
        top: 22.h,
        right: 26.w,
        child: Container(
          height: 32.27.h,
          padding: EdgeInsets.symmetric(horizontal: 9.w),
          decoration: BoxDecoration(
            color: const Color(0xFF2BACFF),
            borderRadius: BorderRadius.circular(13.w),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontFamily: 'IBMPlexSansKR',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

  // // ───────── UI 박스: 연결 전/후 스위칭 ─────────
  // Widget camera_box(String name, {bool isSelf = false}) {
  //   final live = _lkConnected;

  //   Widget content() {
  //     if (live) {
  //       return isSelf ? _localVideoBox() : _remoteVideoBox();
  //     } else {
  //       return isSelf
  //           ? _selfiePreviewBox(width: 340.w, height: 220.h)
  //           : ClipRRect(
  //               borderRadius: BorderRadius.circular(10.w),
  //               child: Container(color: Colors.black),
  //             );
  //     }
  //   }

  //   return Stack(
  //     children: [
  //       Image.asset('assets/images/one_on_one/member_box.png', width: 375.w),
  //       Positioned(
  //         top: 18.h,
  //         left: 0,
  //         right: 0,
  //         child: Center(
  //           child: SizedBox(width: 340.w, height: 220.h, child: content()),
  //         ),
  //       ),
  //       if (isSelf && _arOn)
  //         Positioned(
  //           top: 23.h,
  //           left: 0,
  //           right: 0,
  //           child: Center(
  //             child: Image.asset(
  //               'assets/images/one_on_one/ar_background.png',
  //               width: 152.5.w,
  //             ),
  //           ),
  //         ),
  //       Positioned(
  //         top: 22.h,
  //         right: 26.w,
  //         child: Container(
  //           height: 32.27.h,
  //           padding: EdgeInsets.symmetric(horizontal: 9.w),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF2BACFF),
  //             borderRadius: BorderRadius.circular(13.w),
  //           ),
  //           child: Center(
  //             child: Text(
  //               name,
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //                 color: Colors.white,
  //                 fontFamily: 'IBMPlexSansKR',
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ───────── Scaffold ─────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/illustrations/one_on_one_bgd.png',
                fit: BoxFit.cover),
          ),
          Positioned(
            top: 128.h,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  camera_box('김상담'),
                  SizedBox(height: 28.h),
                  camera_box('나비', isSelf: true),
                  SizedBox(height: 19.h),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleAR,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.all(6.w),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: Image.asset(
                            _arOn
                                ? 'assets/images/icons/ar_filter_on.png'
                                : 'assets/images/icons/ar_filter_off.png',
                            key: ValueKey(_arOn),
                            width: 104.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: -10.w,
            top: 35.h,
            width: 85.w,
            height: 86.5.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const OneOnOneDone(),
                      transitionDuration: const Duration(milliseconds: 220),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 180),
                      transitionsBuilder: (_, a, __, child) =>
                          FadeTransition(opacity: a, child: child),
                    ),
                  );
                },
                customBorder: const CircleBorder(),
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Image.asset('assets/images/icons/exit.png',
                        fit: BoxFit.contain),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
