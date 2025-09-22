
// // import 'package:blurr/features/one_on_one_chat/chat_done.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'dart:math' as math;
// // import 'package:camera/camera.dart';

// // /// 채팅방 페이지 (UI 데모용)
// // class OneOnOneChatRoomPage extends StatefulWidget {
// //   final String code;
// //   const OneOnOneChatRoomPage({super.key, required this.code});

// //   @override
// //   State<OneOnOneChatRoomPage> createState() => _OneOnOneChatRoomPageState();
// // }

// // class _OneOnOneChatRoomPageState extends State<OneOnOneChatRoomPage> {
// //   bool _arOn = false; // ✅ AR 필터 on/off 상태
// //   CameraController? _camCtrl;
// //   Future<void>? _camInit;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initCamera();
// //   }

// //   Future<void> _initCamera() async {
// //     try {
// //       final cams = await availableCameras();
// //       // 전면 카메라 선택
// //       final front = cams.firstWhere(
// //         (c) => c.lensDirection == CameraLensDirection.front,
// //         orElse: () => cams.first,
// //       );
// //       // 오디오가 필요 없다면 enableAudio: false
// //       _camCtrl = CameraController(front, ResolutionPreset.medium, enableAudio: true);
// //       _camInit = _camCtrl!.initialize();
// //       await _camInit;
// //       if (mounted) setState(() {});
// //     } catch (e) {
// //       // 실패 시 로그 정도만
// //       // ignore: avoid_print
// //       print('Camera init error: $e');
// //     }
// //   }
// // Widget _selfiePreviewBox({required double width, required double height}) {
// //   final ctrl = _camCtrl;
// //   if (ctrl == null) {
// //     return Container(width: width, height: height, color: Colors.black);
// //   }
// //   return FutureBuilder<void>(
// //     future: _camInit,
// //     builder: (context, snap) {
// //       if (snap.connectionState != ConnectionState.done) {
// //         return SizedBox(
// //           width: width,
// //           height: height,
// //           child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
// //         );
// //       }

// //       // CameraPreview를 컨테이너 비율(340x220)로 꽉 채우기 (cover)
// //       final previewSize = ctrl.value.previewSize; // (w,h) = 카메라 센서 기준
// //       final double pw = previewSize?.width ?? width;
// //       final double ph = previewSize?.height ?? height;

// //       // 가로/세로 전환 때문에 폭/높이가 뒤집혀 보일 수 있어 FittedBox로 안전하게 cover
// //       return ClipRRect(
// //         borderRadius: BorderRadius.circular(10.w),
// //         child: FittedBox(
// //           fit: BoxFit.cover,
// //           child: SizedBox(
// //             // previewSize는 기기 회전에 따라 바뀔 수 있어 넉넉히 잡아서 cover 처리
// //             width: ph,  // portrait에서 카메라 미리보기는 보통 h가 화면 폭 역할
// //             height: pw, // 반대로
// //             child: Transform(
// //               alignment: Alignment.center,
// //               // ✅ 좌우 반전: rotateY(pi) 또는 scaleX: -1 사용
// //               transform: Matrix4.identity()..rotateY(0),
// //               child: CameraPreview(ctrl),
// //             ),
// //           ),
// //         ),
// //       );
// //     },
// //   );
// // }

// //   @override
// //   void dispose() {
// //     _camCtrl?.dispose();
// //     super.dispose();
// //   }


// //   @override
// //   void didChangeDependencies() {
// //     // 선택: 이미지 미리 로드해서 깜빡임 방지
// //     precacheImage(const AssetImage('assets/images/icons/ar_filter_on.png'), context);
// //     precacheImage(const AssetImage('assets/images/icons/ar_filter_off.png'), context);
// //     super.didChangeDependencies();
// //   }
// // Widget camera_box(String name, {bool isSelf = false}) {
// //   return Stack(
// //     children: [
// //       Image.asset('assets/images/one_on_one/member_box.png', width: 375.w),

// //       // 1) 항상 영상 먼저 깔기 (self면 카메라, 아니면 placeholder/상대영상)
// //       if (isSelf && !_arOn)
// //       Positioned(
// //         top: 18.h,
// //         left: 0,
// //         right: 0,
// //         child: Center(
// //           child: SizedBox(
// //             width: 340.w,
// //             height: 220.h,
// //             child: isSelf
// //                 ? _selfiePreviewBox(width: 340.w, height: 220.h) // 내 카메라(미러)
// //                 : ClipRRect(
// //                     borderRadius: BorderRadius.circular(10.w),
// //                     child: Container(color: Colors.black),         // 상대방 자리(임시)
// //                   ),
// //           ),
// //         ),
// //       ),

// //       // 2) AR 오버레이는 "내 박스 + ON"일 때만 위에 얹기
// //       if (isSelf && _arOn)
// //         Positioned(
// //           top: 23.h,
// //           left: 0,
// //           right: 0,
// //           child: Center(
// //             child: Image.asset(
// //               'assets/images/one_on_one/ar_background.png',
// //               width: 152.5.w,
// //             ),
// //           ),
// //         ),
// //       // 이름 배지
// //       Positioned(
// //         top: 22.h,
// //         right: 26.w,
// //         child: Container(
// //           height: 32.27.h,
// //           padding: EdgeInsets.symmetric(horizontal: 9.w),
// //           decoration: BoxDecoration(
// //             color: const Color(0xFF2BACFF),
// //             borderRadius: BorderRadius.circular(13.w),
// //           ),
// //           child: Center(
// //             child: Text(
// //               name,
// //               style: TextStyle(
// //                 fontSize: 14.sp,
// //                 color: Colors.white,
// //                 fontFamily: 'IBMPlexSansKR',
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     ],
// //   );
// // }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           // 배경
// //           Positioned.fill(
// //             child: Image.asset(
// //               'assets/illustrations/one_on_one_bgd.png',
// //               fit: BoxFit.cover,
// //             ),
// //           ),

// //           // 콘텐츠
// //           Positioned(
// //             top: 128.h,
// //             left: 0,
// //             right: 0,
// //             child: Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   camera_box('김상담'),
// //                   // Image.asset('assets/images/one_on_one/member_box.png', width: 375.w),
// //                   SizedBox(height: 28.h),
// //                   camera_box('나비', isSelf: true),
// //                   SizedBox(height: 19.h),

// //                   // ✅ AR 필터 on/off 토글 버튼
// //                   Material(
// //                     color: Colors.transparent,
// //                     child: InkWell(
// //                       onTap: () => setState(() => _arOn = !_arOn),
// //                       borderRadius: BorderRadius.circular(12.r),
// //                       child: Padding(
// //                         padding: EdgeInsets.all(6.w), // 터치 여유
// //                         child: AnimatedSwitcher(
// //                           duration: const Duration(milliseconds: 160),
// //                           switchInCurve: Curves.easeOut,
// //                           switchOutCurve: Curves.easeIn,
// //                           transitionBuilder: (child, anim) =>
// //                               FadeTransition(opacity: anim, child: child),
// //                           child: Image.asset(
// //                             _arOn
// //                                 ? 'assets/images/icons/ar_filter_on.png'
// //                                 : 'assets/images/icons/ar_filter_off.png',
// //                             key: ValueKey(_arOn), // 상태별 키로 전환 애니메이션
// //                             width: 104.w,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           // exit 버튼 (유한 크기 보장 + 올바른 onTap)
// //           Positioned(
// //             left: -10.w,
// //             top: 35.h,
// //             width: 85.w,
// //             height: 86.5.w,
// //             child: Material(
// //               color: Colors.transparent,
// //               child: InkWell(
// //                 onTap: () {
// //                   Navigator.pushReplacement(context, 
// //                     PageRouteBuilder(pageBuilder: (_, __, ___)=> const OneOnOneDone(),
// //                     transitionDuration: const Duration(milliseconds: 220),
// //                     reverseTransitionDuration: const Duration(milliseconds: 180),
// //                     transitionsBuilder: (_, a, __, child)=> FadeTransition(opacity: a, child: child,)
// //                     )
// //                   );
// //                 },
// //                 customBorder: const CircleBorder(),
// //                 child: Stack(
// //                   fit: StackFit.expand,
// //                   alignment: Alignment.center,
// //                   children: [
// //                     Image.asset('assets/images/icons/exit.png', fit: BoxFit.contain),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:blurr/features/one_on_one_chat/chat_done.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'dart:math' as math;
// import 'package:camera/camera.dart';

// // LiveKit: ConnectionState 충돌 방지
// import 'package:livekit_client/livekit_client.dart' hide ConnectionState;
// // WebRTC fit enum
// import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

// /// 채팅방 페이지 (UI 데모용)
// class OneOnOneChatRoomPage extends StatefulWidget {
//   final String code;
//   const OneOnOneChatRoomPage({super.key, required this.code});

//   @override
//   State<OneOnOneChatRoomPage> createState() => _OneOnOneChatRoomPageState();
// }

// class _OneOnOneChatRoomPageState extends State<OneOnOneChatRoomPage> {
//   bool _arOn = false;

//   // ───────── 기존 카메라(연결 전 미리보기) ─────────
//   CameraController? _camCtrl;
//   Future<void>? _camInit;

//   // ───────── LiveKit 2.2.0 상태 ─────────
//   Room? _lkRoom;
//   EventsListener<RoomEvent>? _lkListener;
//   bool _lkConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();      // 연결 전 미리보기
//     _connectLiveKit();  // LiveKit 연결 (토큰/URL은 TODO)
//   }
// Future<void> _toggleAR() async {
//   final next = !_arOn;

//   try {
//     if (next) {
//       // 🔵 AR 켜기: 카메라 OFF
//       if (_lkConnected) {
//         await _lkRoom?.localParticipant?.setCameraEnabled(false);
//       } else {
//         // 연결 전 미리보기일 때: pausePreview()가 있으면 일시정지, 없으면 숨기기만
//         try {
//           await _camCtrl?.pausePreview(); // 일부 버전에서 제공됨
//         } catch (_) {
//           // pausePreview 미지원이면 그냥 숨기기만(실제 stop하려면 dispose 후 재init 필요)
//         }
//       }
//     } else {
//       // 🔴 AR 끄기: 카메라 ON (전면)
//       if (_lkConnected) {
//         await _lkRoom?.localParticipant?.setCameraEnabled(
//           true,
//           cameraCaptureOptions: const CameraCaptureOptions(
//             cameraPosition: CameraPosition.front,
//           ),
//         );
//       } else {
//         try {
//           await _camCtrl?.resumePreview();
//         } catch (_) {
//           // resumePreview 미지원이면 필요 시 재초기화
//           if (_camCtrl == null || _camCtrl?.value.isInitialized != true) {
//             await _initCamera();
//           }
//         }
//       }
//     }
//   } finally {
//     if (mounted) setState(() => _arOn = next);
//   }
// }

//   // ───────── LiveKit 연결 ─────────
//   Future<void> _connectLiveKit() async {
//     try {
//       final String livekitUrl = 'wss://YOUR-LIVEKIT-URL'; // TODO
//       final String token = await _fetchTokenFromBackend(
//         roomName: widget.code,
//         identity: 'nabi-${DateTime.now().millisecondsSinceEpoch}',
//       );

//       final room = Room();
//       _lkRoom = room;

//       // 이벤트 리스너
//       _lkListener = room.createListener()
//         ..on<RoomDisconnectedEvent>((e) {
//           setState(() => _lkConnected = false);
//         })
//         ..on<ParticipantConnectedEvent>((e) {
//           setState(() {}); // UI 갱신
//         })
//         ..on<ParticipantDisconnectedEvent>((e) {
//           setState(() {});
//         })
//         ..on<TrackSubscribedEvent>((e) {
//           setState(() {}); // 원격 트랙 구독됨
//         })
//         ..on<TrackUnsubscribedEvent>((e) {
//           setState(() {});
//         });

//       await room.connect(livekitUrl, token);

//       // 내 카메라/마이크 ON (전면)
//       await room.localParticipant?.setCameraEnabled(
//         true,
//         cameraCaptureOptions:
//             const CameraCaptureOptions(cameraPosition: CameraPosition.front),
//       );
//       await room.localParticipant?.setMicrophoneEnabled(true);

//       if (mounted) setState(() => _lkConnected = true);

//       // 충돌 방지: LiveKit가 카메라 점유 후 기존 카메라 정리
//       await _disposeLocalCamera();
//     } catch (e) {
//       debugPrint('LiveKit connect error: $e');
//     }
//   }

//   // TODO: 실제 백엔드 호출로 교체
//   Future<String> _fetchTokenFromBackend({
//     required String roomName,
//     required String identity,
//   }) async {
//     throw UnimplementedError('TODO: implement token fetch');
//   }

//   // ───────── 기존 카메라(연결 전) ─────────
//   Future<void> _initCamera() async {
//     try {
//       final cams = await availableCameras();
//       final front = cams.firstWhere(
//         (c) => c.lensDirection == CameraLensDirection.front,
//         orElse: () => cams.first,
//       );
//       _camCtrl =
//           CameraController(front, ResolutionPreset.medium, enableAudio: true);
//       _camInit = _camCtrl!.initialize();
//       await _camInit;
//       if (mounted) setState(() {});
//     } catch (e) {
//       debugPrint('Camera init error: $e');
//     }
//   }

//   Future<void> _disposeLocalCamera() async {
//     try {
//       await _camCtrl?.dispose();
//       _camCtrl = null;
//       _camInit = null;
//     } catch (_) {}
//   }

//   Widget _selfiePreviewBox({required double width, required double height}) {
//     final ctrl = _camCtrl;
//     if (ctrl == null) {
//       return Container(width: width, height: height, color: Colors.black);
//     }
//     return FutureBuilder<void>(
//       future: _camInit,
//       builder: (context, snap) {
//         if (snap.connectionState != ConnectionState.done) {
//           return SizedBox(
//             width: width,
//             height: height,
//             child:
//                 const Center(child: CircularProgressIndicator(strokeWidth: 2)),
//           );
//         }
//         final previewSize = ctrl.value.previewSize;
//         final double pw = previewSize?.width ?? width;
//         final double ph = previewSize?.height ?? height;

//         return ClipRRect(
//           borderRadius: BorderRadius.circular(10.w),
//           child: FittedBox(
//             fit: BoxFit.cover,
//             child: SizedBox(
//               width: ph,
//               height: pw,
//               child: Transform(
//                 alignment: Alignment.center,
//                 transform: Matrix4.identity()..rotateY(0),
//                 child: CameraPreview(ctrl),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

// // ===== 공통 헬퍼 =====
// VideoTrack? _firstLocalVideoTrack(LocalParticipant? lp) {
//   if (lp == null) return null;
//   for (final pub in lp.videoTrackPublications) {
//     final t = pub.track;                 // LocalVideoTrack?
//     if (t != null && !pub.isScreenShare) {
//       return t;                          // upcast: LocalVideoTrack -> VideoTrack
//     }
//   }
//   return null;
// }

// VideoTrack? _firstRemoteVideoTrack(RemoteParticipant? rp) {
//   if (rp == null) return null;
//   for (final pub in rp.videoTrackPublications) {
//     if (pub.subscribed && !pub.isScreenShare) {
//       final t = pub.track;               // RemoteVideoTrack?
//       if (t != null) return t;           // upcast -> VideoTrack
//     }
//   }
//   return null;
// }

// // ===== 내 비디오 =====
// Widget _localVideoBox() {
//   final room = _lkRoom;
//   if (room == null) return Container(color: Colors.black);

//   final track = _firstLocalVideoTrack(room.localParticipant); // VideoTrack?
//   if (track == null) return Container(color: Colors.black);

//   return ClipRRect(
//     borderRadius: BorderRadius.circular(10.w),
//     child: VideoTrackRenderer(
//       track, // <-- VideoTrack (nonnull)
//       mirrorMode: VideoViewMirrorMode.mirror,
//       fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//     ),
//   );
// }

// // ===== 상대 비디오 (첫 번째 원격 참가자) =====
// Widget _remoteVideoBox() {
//   final room = _lkRoom;
//   if (room == null) return Container(color: Colors.black);

//   final rp = room.remoteParticipants.values.isNotEmpty
//       ? room.remoteParticipants.values.first
//       : null;

//   final track = _firstRemoteVideoTrack(rp); // VideoTrack?
//   if (track == null) return Container(color: Colors.black);

//   return ClipRRect(
//     borderRadius: BorderRadius.circular(10.w),
//     child: VideoTrackRenderer(
//       track, // <-- VideoTrack (nonnull)
//       fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//     ),
//   );
// }


//   @override
//   void dispose() {
//     _lkListener?.dispose();
//     _lkRoom?.dispose();
//     _camCtrl?.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     precacheImage(
//         const AssetImage('assets/images/icons/ar_filter_on.png'), context);
//     precacheImage(
//         const AssetImage('assets/images/icons/ar_filter_off.png'), context);
//     super.didChangeDependencies();
//   }
// Widget _arCircle() {
//   return Center(
//     child: Image.asset(
//       'assets/images/one_on_one/ar_background.png',
//       width: 152.5.w,
//     ),
//   );
// }

// Widget camera_box(String name, {bool isSelf = false}) {
//   final live = _lkConnected;

//   Widget content() {
//     // ✅ AR ON이면 (내 박스에서) 카메라 대신 AR 동그라미만
//     if (isSelf && _arOn) return _arCircle();

//     // ✅ AR OFF이면 기존 로직대로 카메라/미리보기
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
//       // ⛔️ (삭제) if (isSelf && _arOn)로 위에 덧씌우던 AR 오버레이 — 이제 content()에서 대체하므로 필요 없음

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

//   // // ───────── UI 박스: 연결 전/후 스위칭 ─────────
//   // Widget camera_box(String name, {bool isSelf = false}) {
//   //   final live = _lkConnected;

//   //   Widget content() {
//   //     if (live) {
//   //       return isSelf ? _localVideoBox() : _remoteVideoBox();
//   //     } else {
//   //       return isSelf
//   //           ? _selfiePreviewBox(width: 340.w, height: 220.h)
//   //           : ClipRRect(
//   //               borderRadius: BorderRadius.circular(10.w),
//   //               child: Container(color: Colors.black),
//   //             );
//   //     }
//   //   }

//   //   return Stack(
//   //     children: [
//   //       Image.asset('assets/images/one_on_one/member_box.png', width: 375.w),
//   //       Positioned(
//   //         top: 18.h,
//   //         left: 0,
//   //         right: 0,
//   //         child: Center(
//   //           child: SizedBox(width: 340.w, height: 220.h, child: content()),
//   //         ),
//   //       ),
//   //       if (isSelf && _arOn)
//   //         Positioned(
//   //           top: 23.h,
//   //           left: 0,
//   //           right: 0,
//   //           child: Center(
//   //             child: Image.asset(
//   //               'assets/images/one_on_one/ar_background.png',
//   //               width: 152.5.w,
//   //             ),
//   //           ),
//   //         ),
//   //       Positioned(
//   //         top: 22.h,
//   //         right: 26.w,
//   //         child: Container(
//   //           height: 32.27.h,
//   //           padding: EdgeInsets.symmetric(horizontal: 9.w),
//   //           decoration: BoxDecoration(
//   //             color: const Color(0xFF2BACFF),
//   //             borderRadius: BorderRadius.circular(13.w),
//   //           ),
//   //           child: Center(
//   //             child: Text(
//   //               name,
//   //               style: TextStyle(
//   //                 fontSize: 14.sp,
//   //                 color: Colors.white,
//   //                 fontFamily: 'IBMPlexSansKR',
//   //                 fontWeight: FontWeight.w500,
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   // ───────── Scaffold ─────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset('assets/illustrations/one_on_one_bgd.png',
//                 fit: BoxFit.cover),
//           ),
//           Positioned(
//             top: 128.h,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   camera_box('김상담'),
//                   SizedBox(height: 28.h),
//                   camera_box('나비', isSelf: true),
//                   SizedBox(height: 19.h),
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: _toggleAR,
//                       borderRadius: BorderRadius.circular(12.r),
//                       child: Padding(
//                         padding: EdgeInsets.all(6.w),
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
//                             key: ValueKey(_arOn),
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
//           Positioned(
//             left: -10.w,
//             top: 35.h,
//             width: 85.w,
//             height: 86.5.w,
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     PageRouteBuilder(
//                       pageBuilder: (_, __, ___) => const OneOnOneDone(),
//                       transitionDuration: const Duration(milliseconds: 220),
//                       reverseTransitionDuration:
//                           const Duration(milliseconds: 180),
//                       transitionsBuilder: (_, a, __, child) =>
//                           FadeTransition(opacity: a, child: child),
//                     ),
//                   );
//                 },
//                 customBorder: const CircleBorder(),
//                 child: Stack(
//                   fit: StackFit.expand,
//                   alignment: Alignment.center,
//                   children: [
//                     Image.asset('assets/images/icons/exit.png',
//                         fit: BoxFit.contain),
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
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui'; // for YUV -> bytes
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show WriteBuffer;

import 'package:blurr/features/one_on_one_chat/chat_done.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// LiveKit: ConnectionState 충돌 방지
import 'package:livekit_client/livekit_client.dart' hide ConnectionState;
// WebRTC fit enum
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

// ML Kit
enum MouthState { neutral, smiling, open, talking }

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

  // 이미지 스트림(ML Kit)
  FaceDetector? _faceDetector;
  bool _detecting = false;
  List<Face> _faces = [];

  // ───────── LiveKit 2.2.0 상태 ─────────
  Room? _lkRoom;
  EventsListener<RoomEvent>? _lkListener;
  bool _lkConnected = false;
  ui.Image? _faceSticker;



  MouthState _mouthState = MouthState.neutral;
  double _mouthOpenRatio = 0.0;
  // === 입 상태 안정화 파라미터들 ===
  double _emaMouth = 0.0;
  bool _emaInitialized = false;
  // 입 벌림 노이즈 무시용 바닥값
  static const double _noiseFloor = 0.005; // 0.3%~0.5% 정도

  // 기준선 캘리브레이션
  double _mouthBaseline = 0.03; // 얼굴 높이 대비 기본 닫힘값(합리적 초기값)
  int _baselineWarmupFrames = 12; // 초기 캘리브레이션 프레임 수
  int _baselineCount = 0;

  // 히스테리시스(기준선 대비)
  static const double _deltaOpenUp   = 0.024; // 열릴 때: baseline + 0.020 이상
  static const double _deltaCloseDn  = 0.012; // 닫힐 때: baseline + 0.012 미만 (더 낮아야 안정)

  // 웃음 조건
  static const double _smileProbThresh = 0.65;
  static const double _smileOpenBonus  = 0.002; // 웃음은 baseline보다 이 정도는 벌어져야 인정

  // 말하기(변동성) 조건
  static const double _talkVarThresh = 0.00022;

  // 쿨다운 (ms)
  int _stateCooldownMs = 120;
  int _lastStateChangeMs = 0;
double _ema(double prev, double current, double alpha) {
  // alpha: 0.0~1.0 (0.2~0.35 권장)
  return prev + alpha * (current - prev);
}

bool _cooldownPassed() {
  final now = DateTime.now().millisecondsSinceEpoch;
  return (now - _lastStateChangeMs) >= _stateCooldownMs;
}

void _markStateChange() {
  _lastStateChangeMs = DateTime.now().millisecondsSinceEpoch;
}

// 간단 스무딩/말하기 감지용(프레임 변동성)
final List<double> _mouthOpenHistory = <double>[];
static const int _mouthHistMax = 8; // 최근 8프레임 정도
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

    // 정규화 기준 개선: 얼굴 높이 대신 "입 너비"나 "동공 거리"가 입 벌림에 더 민감
    final mouthOuterLeft  = _contour(f, FaceContourType.upperLipTop)?.first;
    final mouthOuterRight = _contour(f, FaceContourType.upperLipTop)?.last;

    double norm;
    if (mouthOuterLeft != null && mouthOuterRight != null) {
      norm = (mouthOuterRight.dx - mouthOuterLeft.dx).abs(); // 입 너비로 정규화
    } else {
      norm = f.boundingBox.height; // fallback
    }

    if (norm <= 0) return null;
    return mouthGap / norm; // 보통 0.10~0.50 범위로 커짐 → 더 민감
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

  Future<void> _loadFaceSticker() async {
    final asset = const AssetImage('assets/images/one_on_one/ar_background.png');
    final config = ImageConfiguration.empty;
    final completer = Completer<ui.Image>();
    final stream = asset.resolve(config);
    late final ImageStreamListener listener;

    listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
      stream.removeListener(listener);
    }, onError: (Object error, StackTrace? stackTrace) { // ✅ 변수명 바꿈
      completer.completeError(error, stackTrace);
      stream.removeListener(listener);
    });

    stream.addListener(listener);

    final img = await completer.future;
    if (mounted) setState(() => _faceSticker = img);
  }


  @override
  void initState() {
    super.initState();
    _initFaceDetector();
    _initCamera();      // 연결 전 미리보기 + (필요 시) 스트림
    _connectLiveKit();  // LiveKit 연결 (토큰/URL은 TODO)
  }

  void _initFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true, // 눈 뜸/감음 확률
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }
Future<void> _toggleAR() async {
  final next = !_arOn;
  try {
    if (next) {
      // LiveKit 카메라는 끄고
      if (_lkConnected) {
        await _lkRoom?.localParticipant?.setCameraEnabled(false);
      }
      // ⬇️ 로컬 카메라/스트림 확보 (프리뷰는 렌더 안해도 OK)
      if (_camCtrl == null || _camCtrl?.value.isInitialized != true) {
        await _initCamera(startStream: true);
      } else {
        await _startImageStreamIfNeeded();
      }

      // (선택) 잔상 제거만 하고, 새 스트림이 곧 채워줄 것이므로 유지
      _faces = [];
      _emaInitialized = false;
      if (mounted) setState(() {});
} else {
  // 🔴 AR OFF
  await _stopImageStreamIfRunning(); // ⬅️ 스트림 중단
  _faces = [];                       // ⬅️ 잔상 제거
  _emaInitialized = false;

  if (_lkConnected) {
    await _lkRoom?.localParticipant?.setCameraEnabled(
      true,
      cameraCaptureOptions: const CameraCaptureOptions(
        cameraPosition: CameraPosition.front,
      ),
    );
    await _disposeLocalCamera();
  } else {
    // 연결 전: 프리뷰는 보이되(위 showPreview:true), 오버레이는 _arOn=false라 안 그림
    try {
      await _camCtrl?.resumePreview();
    } catch (_) {
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

      // 충돌 방지: LiveKit가 카메라 점유 후 기존 카메라 정리(미리보기를 우리가 안 쓰므로)
      await _stopImageStreamIfRunning();
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
  Future<void> _initCamera({bool startStream = false}) async {
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
        imageFormatGroup: ImageFormatGroup.yuv420, // ML Kit용
      );
      _camInit = _camCtrl!.initialize();
      await _camInit;

      if (startStream) {
        await _startImageStreamIfNeeded();
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _disposeLocalCamera() async {
    try {
      await _stopImageStreamIfRunning();
      await _camCtrl?.dispose();
      _camCtrl = null;
      _camInit = null;
    } catch (_) {}
  }

  // ───────── ML Kit 이미지 스트림 ─────────
  Future<void> _startImageStreamIfNeeded() async {
    if (_camCtrl == null || !_camCtrl!.value.isInitialized) return;
    if (_camCtrl!.value.isStreamingImages) return;

    try {
      await _camCtrl!.startImageStream(_onCameraImage);
    } catch (e) {
      debugPrint('startImageStream error: $e');
    }
  }

  Future<void> _stopImageStreamIfRunning() async {
    if (_camCtrl == null) return;
    if (_camCtrl!.value.isStreamingImages) {
      try {
        await _camCtrl!.stopImageStream();
      } catch (e) {
        debugPrint('stopImageStream error: $e');
      }
    }
  }

InputImage _toInputImage(CameraImage image, CameraDescription desc) {
  // 모든 plane을 한 덩어리 바이트로 합치기
  final writeBuffer = WriteBuffer();
  for (final Plane plane in image.planes) {
    writeBuffer.putUint8List(plane.bytes);
  }
  final allBytes = writeBuffer.done().buffer.asUint8List();

  // 메타데이터 구성 (최신 API는 InputImageMetadata 사용)
  final imageSize = Size(image.width.toDouble(), image.height.toDouble());

  final rotation =
      InputImageRotationValue.fromRawValue(desc.sensorOrientation) ??
          InputImageRotation.rotation0deg;

  // CameraController(ImageFormatGroup.yuv420) 기준
  final format =
      InputImageFormatValue.fromRawValue(image.format.raw) ??
          InputImageFormat.yuv420;

  // ✅ 최신 API: planeData 리스트 대신, bytesPerRow(주로 첫 plane)만 요구
  final metadata = InputImageMetadata(
    size: imageSize,
    rotation: rotation,
    format: format,
    bytesPerRow: image.planes.isNotEmpty ? image.planes.first.bytesPerRow : 0,
  );

  return InputImage.fromBytes(
    bytes: allBytes,
    metadata: metadata,
  );
}

    Future<void> _onCameraImage(CameraImage image) async {
      if (_detecting || _faceDetector == null) return;
      _detecting = true;
      try {
        final input = _toInputImage(image, _camCtrl!.description);
        final faces = await _faceDetector!.processImage(input);
        _faces = faces;

        // ===== 입 상태 업데이트 (첫 번째 얼굴 기준) =====
        if (_faces.isNotEmpty) {
          final f = _faces.first;

          final smileP = f.smilingProbability ?? 0.0;
          final rawRatio = _computeMouthOpenRatio(f) ?? 0.0;
        // === 1) 눈 중심 거리로 정규화한 대체 ratio 계산 ===========================
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
      // 컨투어 중심(더 안정적). 없으면 랜드마크로 대체 가능.
      final lc = _centerOfContour(face, FaceContourType.leftEye);
      final rc = _centerOfContour(face, FaceContourType.rightEye);
      if (lc == null || rc == null) return null;
      return (rc - lc).distance;
    }

    // 입 gap은 기존 _computeMouthOpenRatio 안에서 계산됨.
    // 여기서는 '정규화 기준'만 교체해서 ratio2를 만들자.
    double ratio2ByEye = rawRatio;
    final eyeDist = _interEyeDist(f);
    if (eyeDist != null && eyeDist > 0) {
      // 기존 rawRatio는 faceHeight로 나눈 값.
      // 동일한 mouthGap을 inter-eye로 나눈 값으로 근사: raw * (faceHeight / eyeDist)
      final faceHeight = f.boundingBox.height;
      final k = (faceHeight > 0) ? (faceHeight / eyeDist) : 1.0;
      ratio2ByEye = rawRatio * k;
    }

    // === 2) Yaw가 클수록 inter-eye 정규화 비중 ↑ (퍼스펙티브 보정) ===========
    final double yawDeg  = f.headEulerAngleY ?? 0.0;
    final double yawAbs  = yawDeg.abs();

    // yawBlend: 0(정면) → 1(많이 틀어짐)
    double yawBlend = ((yawAbs - 8.0) / 22.0).clamp(0.0, 1.0); // 8°부터 영향, 30° 이상 최대
    final double ratioBlended = rawRatio * (1.0 - yawBlend) + ratio2ByEye * yawBlend;

    // === 3) 추가 감쇠: cos(yaw) (너무 크지 않게 바닥값 유지) =================
    final double yawCos = math.cos((yawAbs * math.pi) / 180.0).clamp(0.70, 1.0);
    final double ratioPoseCorrected = ratioBlended * yawCos;

    // === 4) EMA에 들어가는 값 교체 ===========================================
    if (!_emaInitialized) {
      _emaMouth = ratioPoseCorrected;
      _emaInitialized = true;
    } else {
      _emaMouth = _ema(_emaMouth, ratioPoseCorrected, 0.40); // 반응성↑
    }
    _mouthOpenRatio = _emaMouth;

    // === 포즈 보정: 옆을 볼수록 ratio 감쇠 (cosine) ===
    final double rollDeg = f.headEulerAngleZ ?? 0.0; // 기울임(선택)

    // 과도 감쇠 방지: cos이 너무 작아지지 않게 바닥값 0.65

    // 필요 시 roll도 반영하고 싶으면 다음 줄을 사용 (아니면 yawCos만 쓰세요)
    // final double rollCos = math.cos((rollDeg.abs() * math.pi) / 180.0).clamp(0.80, 1.0);
    // final double poseCos = (yawCos * rollCos).clamp(0.60, 1.0);

    final double poseCos = yawCos;

    // 감쇠 적용

      // 초기 캘리브레이션
      if (_baselineCount < _baselineWarmupFrames && smileP < 0.2) {
        _mouthBaseline = ((_mouthBaseline * _baselineCount) + rawRatio) / (_baselineCount + 1);
        _baselineCount++;
      }

      // EMA
      if (!_emaInitialized) {
        _emaMouth = ratioPoseCorrected;
        _emaInitialized = true;
      } else {
        _emaMouth = _ema(_emaMouth, ratioPoseCorrected, 0.40); // 알파는 0.35~0.45 권장
      }
      _mouthOpenRatio = _emaMouth;

      // 변동성
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

      // 상태 결정 (히스테리시스 + 쿨다운)
      final above = _emaMouth - _mouthBaseline;
      // === 포즈 패널티(강화): 옆을 볼수록 열림 문턱을 크게 =====================
double _posePenaltyFactorYaw(double yaw) {
  // 10도까지는 안전, 10~32도 구간에서 1.0→최대 1.9배까지 강화
  const safe = 10.0;
  const span = 22.0; // 10→32도
  double t = ((yaw.abs() - safe) / span).clamp(0.0, 1.0);
  // 곡선(더 급격)으로: quad easing
  t = t * t;
  return (1.0 + 0.9 * t); // 1.0~1.9
}

final double posePenalty = _posePenaltyFactorYaw(yawDeg);

// 기존:
// final bool wantOpen  = effAbove > _deltaOpenUp;
// final bool wantClose = effAbove < _deltaCloseDn;

// 노이즈 바닥 포함
final double effAbove = ((_emaMouth - _mouthBaseline) > _noiseFloor)
    ? ((_emaMouth - _mouthBaseline) - _noiseFloor)
    : 0.0;

    // 변경(열림만 패널티 적용, 닫힘은 그대로 빨리 닫히게):
    final bool wantOpen  = effAbove > (_deltaOpenUp * posePenalty);
    final bool wantClose = effAbove < _deltaCloseDn;
    // === 전이 보조 게이트들 (EMA 꼬리/웃음 잔상 오인 방지) ===
    final double currentAboveRaw = (ratioPoseCorrected - _mouthBaseline);

    // 현재 프레임(raw)도 문턱을 넘었는지 확인 (웃는 중에는 좀 더 엄격하게)
    final bool smileCurrently = (smileP > _smileProbThresh);
    final double openBoostWhenSmile = smileCurrently ? 1.15 : 1.0;
    final bool rawOpenGate = currentAboveRaw >
        (_deltaOpenUp * posePenalty * 0.95 * openBoostWhenSmile);

    // 바로 직전 프레임 대비 급격히 닫히는 중이면 "열림" 전이 금지
    double delta = 0.0;
    if (_mouthOpenHistory.length >= 2) {
      delta = _mouthOpenHistory.last - _mouthOpenHistory[_mouthOpenHistory.length - 2];
    }
    final bool closingFast = delta < -0.004; // 필요시 0.003~0.006 사이 튜닝
    final bool smileDecayGuard = (!smileCurrently) && closingFast;

      MouthState next = _mouthState;
      double _posePenaltyFactor(double yaw, double roll) {
        // 안전 구간(safe) 이후부터 선형 가중. 최댓값은 1.6배 정도.
        const double yawSafe = 12.0;  // 12도까지는 벌점 없음
        const double yawScale = 24.0; // 12~36도 사이에서 0→1로 스케일
        const double rollSafe = 18.0;
        const double rollScale = 36.0;

        double y = (yaw.abs() - yawSafe) / yawScale;
        double r = (roll.abs() - rollSafe) / rollScale;
        y = y.isFinite ? y.clamp(0.0, 1.0) : 0.0;
        r = r.isFinite ? r.clamp(0.0, 1.0) : 0.0;

        // yaw 영향 더 큼; 1.0 ~ 1.6 범위
        return (1.0 + 0.45 * y + 0.15 * r).clamp(1.0, 1.6);
      }

      // final double posePenalty = _posePenaltyFactor(yawDeg, rollDeg);
      // final bool wantOpen = above > (_deltaOpenUp * posePenalty);
      // final bool wantClose = above < _deltaCloseDn;

      // === 포즈 패널티: 옆을 볼수록(또는 기울일수록) 열림 문턱을 올림 ===
    if (_cooldownPassed()) {
      MouthState next = _mouthState;

      switch (_mouthState) {
        case MouthState.neutral:
        case MouthState.smiling:
          if (wantOpen && rawOpenGate && !smileDecayGuard) {
            // 웃음이면 smiling 유지, 아니면 open/talking
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

      if (next != _mouthState) {
        _mouthState = next;
        _markStateChange();
      }
    }
    // 중립 + 변동성 낮고 웃음도 약할 때는 baseline을 아주 느리게 보정
    final bool likelyClosedNow = (smileP < 0.25) && (variance < 0.00008);
    if (_mouthState == MouthState.neutral && likelyClosedNow) {
      _mouthBaseline = _ema(_mouthBaseline, _emaMouth, 0.02); // 2% 속도
    }

}

    if (mounted) setState(() {});
  } catch (e, st) {
    debugPrint('onCameraImage error: $e\n$st');
  } finally {
    _detecting = false;
  }
} // 👈👈👈 이 중괄호(함수 닫힘)까지 꼭 있어야 함!

  // ───────── 프리뷰(연결 전/AR 모드용) ─────────
  Widget _mlkitPreviewWithOverlay({
    required double w,
    required double h,
    bool showPreview = true,
    bool showOverlay = true,
  }) {
    final ctrl = _camCtrl;
    if (ctrl == null) {
      return Container(width: w, height: h, color: Colors.black);
    }
    return FutureBuilder<void>(
      future: _camInit,
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
            if(showPreview)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: ph,
                  height: pw,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(0), // 전면 미러는 실제 렌더에서 적용
                    child: CameraPreview(ctrl),
                  ),
                ),
              ),
              // 오버레이
            if(showOverlay)
              LayoutBuilder(builder: (context, c){
                final imgSize = Size(ctrl.value.previewSize?.width?? w, ctrl.value.previewSize?.height ?? h);
                final widgetSize = Size(c.maxWidth, c.maxHeight);
                return CustomPaint(
                  painter: _FaceDotsPainter(faces: _faces, imageSize: imgSize, widgetSize: widgetSize, mirror: true, sticker:_faceSticker, mouthState: _mouthState, mouthOpenRatio: _mouthOpenRatio)
                );
              },)
              // LayoutBuilder(
              //   builder: (context, c) {
              //     final imgSize = Size(
              //       ctrl.value.previewSize?.width ?? w,
              //       ctrl.value.previewSize?.height ?? h,
              //     );
              //     final widgetSize = Size(c.maxWidth, c.maxHeight);
              //     return CustomPaint(
              //       painter: _FaceDotsPainter(
              //         faces: _faces,
              //         imageSize: imgSize,
              //         widgetSize: widgetSize,
              //         mirror: true,
              //         sticker: _faceSticker,
              //         mouthState: _mouthState,           // ← 추가
              //         mouthOpenRatio: _mouthOpenRatio,   // ← 추가
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  // ===== 공통 헬퍼 =====
  VideoTrack? _firstLocalVideoTrack(LocalParticipant? lp) {
    if (lp == null) return null;
    for (final pub in lp.videoTrackPublications) {
      final t = pub.track; // LocalVideoTrack?
      if (t != null && !pub.isScreenShare) {
        return t; // upcast: LocalVideoTrack -> VideoTrack
      }
    }
    return null;
  }

  VideoTrack? _firstRemoteVideoTrack(RemoteParticipant? rp) {
    if (rp == null) return null;
    for (final pub in rp.videoTrackPublications) {
      if (pub.subscribed && !pub.isScreenShare) {
        final t = pub.track; // RemoteVideoTrack?
        if (t != null) return t; // upcast -> VideoTrack
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
    _stopImageStreamIfRunning();
    _camCtrl?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(const AssetImage('assets/images/icons/ar_filter_on.png'), context);
    precacheImage(const AssetImage('assets/images/icons/ar_filter_off.png'), context);

    // 스티커도 프리캐시 & 디코드
    precacheImage(const AssetImage('assets/images/one_on_one/ar_background.png'), context);
    _loadFaceSticker();

    super.didChangeDependencies();
  }


  Widget camera_box(String name, {bool isSelf = false}) {
    final live = _lkConnected;

    Widget content() {
      if (isSelf && _arOn) {
        // 프리뷰도, 오버레이도 비표시
        return _mlkitPreviewWithOverlay(
          w: 340.w, h: 220.h,
          showPreview: false,
          showOverlay: true, 
        );
      }

      if (_lkConnected) {
        return isSelf ? _localVideoBox() : _remoteVideoBox();
      } else {
          return isSelf
              ? _mlkitPreviewWithOverlay(
                  w: 340.w,
                  h: 220.h,
                  showPreview: true,      // 카메라 화면은 보이게
                  showOverlay: _arOn,     // ⬅️ AR이 켜졌을 때만 오버레이(아바타) 그림
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child: Container(color: Colors.black),
                );
      }
    }

    // if(_lkConnected){
    //   return isSelf> _localVideoBox() : _remoteVideoBox();
    // }else{
    //   return isSelf?_mlkitPreviewWithOverlay(w: 340.w, h: 220.h, showPreview: !_arOn):ClipRRect(borderRadius: BorderRadius.circular(10.w), child: Container(color:Colors.black),,),
    // }


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

/// ===============================================
///  간단 AR 오버레이: 동그라미 얼굴 + 눈/입 + 눈감김 처리
/// ===============================================
class _FaceDotsPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;  // 카메라 원본 크기 (w,h)
  final Size widgetSize; // 위젯 렌더 크기
  final bool mirror;
  final ui.Image? sticker;
  final MouthState mouthState;
  final double mouthOpenRatio;

  _FaceDotsPainter({
    required this.faces,
    required this.imageSize,
    required this.widgetSize,
    required this.mirror,
    this.sticker,
    required this.mouthState,
    required this.mouthOpenRatio,
  });

  Offset _map(Offset p) {
    // BoxFit.cover 가정: 더 큰 스케일을 사용
    final scale = math.max(
      widgetSize.width / imageSize.width,
      widgetSize.height / imageSize.height,
    );
    final dx = (widgetSize.width  - imageSize.width  * scale) / 2;
    final dy = (widgetSize.height - imageSize.height * scale) / 2;

    double x = p.dx * scale + dx;
    double y = p.dy * scale + dy;

    // if (mirror) {
    //   x = widgetSize.width - x; // 좌우 반전
    // }
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF222222);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF222222);

    for (final f in faces) {
      final box = f.boundingBox;
      final center = _map(box.center);
      final radius = (box.shortestSide *
              (widgetSize.width / imageSize.width)) *
          0.6;

      if(sticker!=null){
        final dst = Rect.fromCircle(center:center, radius: radius * 1.8);
        final src = Rect.fromLTWH(0, 0, sticker!.width.toDouble(), sticker!.height.toDouble());
        canvas.drawImageRect(sticker!, src, dst, Paint());
      }else{
        canvas.drawCircle(center, radius, stroke);
      }

      // 얼굴 동그라미
      // canvas.drawCircle(center, radius, stroke);

      // 눈 위치(대략): 위쪽 1/4
      final eyeY = center.dy - radius * 0.20;
      final eyeDX = radius * 0.35;
      final eyeR = radius * 0.10;

      // --- 눈 open/closed를 더 안정적으로 판정 ---
      // 0) 얼굴이 너무 작으면(노이즈) 눈 감김 판정을 하지 않음
// --- 눈 open/closed를 윙크 지원으로 재설계 ---

// --- 눈 open/closed를 더 안정적으로 판정 ---
// 0) 얼굴이 너무 작으면(노이즈) 눈 감김 판정을 하지 않음
const double minFaceWidthPx = 100; // 기기/해상도 따라 80~120 사이로 조정
final bool tinyFace = box.width < minFaceWidthPx;

// 1) ML Kit 확률 기반 (임계값 낮춤)
final double pL = f.leftEyeOpenProbability  ?? 0.5;
final double pR = f.rightEyeOpenProbability ?? 0.5;
const double probOpenThresh = 0.40; // 0.6 → 0.40로 낮춰 민감도↑
final bool byProbLeftOpen  = pL > probOpenThresh;
final bool byProbRightOpen = pR > probOpenThresh;

// 2) 컨투어 기반 EAR(세로/가로 비율) 계산 (간이: 박스 높이/너비)
double? _earFromContour(Face face, FaceContourType t) {
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
  return height / width; // 보통 눈 뜨면 높이/너비 비율이 커짐
}

final earL = _earFromContour(f, FaceContourType.leftEye);
final earR = _earFromContour(f, FaceContourType.rightEye);

// EAR 임계값 (카메라/해상도 따라 0.16~0.24 사이 튜닝)
const double earOpenThresh = 0.20;
final bool byEarLeftOpen  = (earL != null) ? (earL > earOpenThresh) : false;
final bool byEarRightOpen = (earR != null) ? (earR > earOpenThresh) : false;

// 3) 규칙 결합
bool leftOpen  = tinyFace ? true : (byProbLeftOpen  || byEarLeftOpen);
bool rightOpen = tinyFace ? true : (byProbRightOpen || byEarRightOpen);

// 4) 좌우 비대칭 완화: 한쪽만 미묘하게 닫힘일 때는 둘 다 open 처리
const double softMargin = 0.08; // 확률 차이가 작으면 동의했다고 간주
if (!tinyFace) {
  if (leftOpen != rightOpen) {
    // 확률 기반 편차가 작거나 EAR 편차가 작으면 둘 다 open으로
    final probDiffSmall = (pL - pR).abs() < softMargin;
    final earDiffSmall  = ( (earL ?? 0) - (earR ?? 0) ).abs() < 0.05;
    if (probDiffSmall || earDiffSmall) {
      leftOpen = true;
      rightOpen = true;
    }
  }
}
// 8) 그리기 (기존과 동일)
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

      // 입: 상태별로 다르게
      final mouthY = center.dy + radius * 0.25;

      // 1) 기본 가로폭(말 아닐 때)
      final double mouthWBase = radius * 0.60;

      // 2) 말할 때 가로폭을 좁히는 계수(0~1, 작을수록 더 좁음)
      const double talkNarrowFactor = 0.75; // 더 좁히고 싶으면 0.65, 0.6 등

      // (선택) 입 벌림 비율로 약간 동적 조절
      final double dynamicNarrow =
          (1.0 - (mouthOpenRatio * 2.2)).clamp(0.6, 1.0); // 0.6~1.0
      final double talkingWidthFactor =
          (talkNarrowFactor * dynamicNarrow).clamp(0.55, 1.0);

      // 3) 최종 가로폭 선택
      final double mouthW = (mouthState == MouthState.talking || mouthState == MouthState.open)
          ? mouthWBase * talkingWidthFactor
          : mouthWBase;

      // 세로 높이(열림용)
      final double mouthHClosed = mouthWBase * 0.05;                      // 닫힌 입 두께
      final double mouthHOpen   = mouthWBase * (0.20 + mouthOpenRatio * 1.2);

      // (선택) 말할 때는 세로 살짝 ↑
      final double mouthH = (mouthState == MouthState.talking)
          ? (mouthHOpen * 1.10).clamp(mouthHClosed, radius * 0.7)
          : mouthHOpen;

      // 선 모양(가독성↑)

      switch (mouthState) {
        case MouthState.neutral:
          // ✅ neutral: 일자 선
          canvas.drawLine(
            Offset(center.dx - mouthWBase / 2, mouthY),
            Offset(center.dx + mouthWBase / 2, mouthY),
            stroke,
          );
          break;

        case MouthState.smiling:
          // ✅ smiling: 위로 휘는 아치가 확실히 보이도록 파라미터 보강
          final double smileW   = mouthWBase * 1.10;                    // 조금 더 넓게
          final double smileH   = (mouthWBase * 0.55).clamp(6.0, radius * 0.9); // 높이를 충분히
          final double smileUp  = radius * 0.02;                         // 약간 위로 올리기

          final Rect rectSmile = Rect.fromCenter(
            center: Offset(center.dx, mouthY - smileUp),
            width: smileW,
            height: smileH,
          );

          // 시작각/스윕각도 충분히 크게: 18°~162° (π*0.1 ~ π*0.9)
          canvas.drawArc(rectSmile, math.pi * 0.10, math.pi * 0.80, false, stroke);
          break;

        case MouthState.open:
        case MouthState.talking:
          // ✅ 말/열림: 타원
          final Rect mouthRect = Rect.fromCenter(
            center: Offset(center.dx, mouthY),
            width: mouthW,                          // talking이면 좁아짐
            height: mouthH,
          );
          canvas.drawOval(mouthRect, stroke);
          break;
      }

    }
  } 

@override
bool shouldRepaint(covariant _FaceDotsPainter old) =>
    old.faces != faces ||
    old.imageSize != imageSize ||
    old.widgetSize != widgetSize ||
    old.mirror != mirror ||
    old.sticker != sticker ||
    old.mouthState != mouthState ||           // ← 추가
    old.mouthOpenRatio != mouthOpenRatio;     // ← 추가

}
