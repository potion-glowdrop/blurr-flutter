// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class LobbyOneOnOnePage extends StatelessWidget {
//   const LobbyOneOnOnePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: GestureDetector(
//         onTap:() => FocusScope.of(context).unfocus(),
//         child: Center(
//           child: _LobbyBody( // 아래에서 쓰는 본문 위젯
//             onExit: () => Navigator.pop(context),
//           ),
//         ),
//       ),
//     );
//   }
// }
// class _LobbyBody extends StatefulWidget {
//   final VoidCallback onExit;
//   const _LobbyBody({required this.onExit});

//   @override
//   State<_LobbyBody> createState() => _LobbyBodyState();
// }

// class _LobbyBodyState extends State<_LobbyBody> {
//   late final TextEditingController _codeCtl;
//   late final FocusNode _codeFocus;

//   @override
//   void initState() {
//     super.initState();
//     _codeCtl = TextEditingController();
//     _codeFocus = FocusNode();
//   }

//   @override
//   void dispose() {
//     _codeCtl.dispose();
//     _codeFocus.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned.fill(
//           child: Image.asset(
//             'assets/illustrations/home_background.png',
//             fit: BoxFit.cover,
//           ),
//         ),


//         Center(
//         child: Stack(
//           children: [
//             // 배경
//             Center(
//               child: Image.asset(
//                 'assets/illustrations/background_pop_up.png',
//                 width: 375.w,
//               ),
//             ),
//             // 팝업 콘텐츠
//             Center(
//               child: Container(
//                 width: 353.w,
//                 height: 423.w,
//                 padding: EdgeInsets.only(left: 27.w, top: 36.h, right: 27.w, bottom: 22.h),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '당신과 가장 잘 맞을\n전문 상담사와 상담해보세요.',
//                       style: TextStyle(
//                         fontFamily: 'IBMPlexSansKR',
//                         fontWeight: FontWeight.w300,
//                         fontSize: 20.sp,
//                       ),
//                     ),
//                     SizedBox(height: 25.h),
//                     Center(
//                       child: Image.asset(
//                         'assets/images/home/therapy.png',
//                         width: 130.w,
//                       ),
//                     ),
//                     SizedBox(height: 19.h),
        
//                     // ✅ 라벨~필드 전체를 탭해도 포커스되게
//                     GestureDetector(
//                       behavior: HitTestBehavior.opaque,
//                       onTap: () => _codeFocus.requestFocus(),
//                       child: Padding(
//                         // 라벨/여백도 포함해 탭 타겟을 두툼하게
//                         padding: EdgeInsets.symmetric(vertical: 8.h),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '코드 입력',
//                               style: TextStyle(
//                                 fontFamily: 'IBMPlexSansKR',
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xFF808080),
//                                 fontSize: 14.sp,
//                               ),
//                             ),
//                             SizedBox(
//                               // width: 309.w,
//                               height: 36.h, // iOS 권장 44px 이상
//                               child: TextField(
//                                 controller: _codeCtl,
//                                 focusNode: _codeFocus,
//                                 textInputAction: TextInputAction.done,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontFamily: 'IBMPlexSansKR',
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xFF17A1FA),
//                                   fontSize: 16.sp,
//                                 ),
//                                 decoration: InputDecoration(
//                                   isDense: false,
//                                   contentPadding: EdgeInsets.symmetric(
//                                     vertical: 16.h, // 내부 터치/시각 높이
//                                     horizontal: 0,   // 언더라인 사용시 좌우 0 유지
//                                   ),
//                                   enabledBorder: UnderlineInputBorder(
//                                     borderSide: BorderSide(
//                                       color: const Color(0xFF808080).withAlpha(43),
//                                       width: 1,
//                                     ),
//                                   ),
//                                   focusedBorder: const UnderlineInputBorder(
//                                     borderSide: BorderSide(
//                                       color: Color(0xFF17A1FA),
//                                       width: 1.5,
//                                     ),
//                                   ),
//                                   disabledBorder: const UnderlineInputBorder(
//                                     borderSide: BorderSide(color: Colors.grey, width: 1),
//                                   ),
//                                 ),
//                                 // onSubmitted: (_) => _submitCode(), // 필요시 사용
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
        
//                     // SizedBox(height: 10.h),
        
//                     // 입장 버튼(이미지)도 터치 영역 넓히기
//                     Center(
//                       child: InkWell(
//                         onTap: () {
//                           // TODO: 코드 검증/이동 로직
//                           // _submitCode();
//                         },
//                         borderRadius: BorderRadius.circular(12.r),
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(vertical: 8.h), // 추가 터치 여유
//                           child: Image.asset(
//                             'assets/images/icons/enter.png',
//                             width: 289.w,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               right: 0,
//               top: 200.h,
//               child: SizedBox(
//                 width: 85.w,
//                 height: 86.5.w,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Image.asset(
//                       'assets/images/icons/exit.png',
//                       width: 85.w,
//                       height: 86.5.w,
//                       fit: BoxFit.contain,
//                     ),
//                     Material(
//                       type: MaterialType.transparency,
//                       child: InkResponse(
//                         onTap: () => Navigator.pop(context), // 필요시
//                         customBorder: const CircleBorder(),
//                         radius: 15,
//                         containedInkWell: false,
//                         child: SizedBox(width: 30.w, height: 30.w),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),


        
//             // 닫기 버튼(작은 히트박스만 터치)
//           ],
//         ),
//           ),
//           // Positioned(
//           //   left: 37.w,   // ← ScreenUtil은 w/h 반대로 쓰지 않도록 주의!
//           //   top: 53.h,
//           //   child: GestureDetector(
//           //     onTap: () => Navigator.pop(context),
//           //     child: SizedBox(
//           //       width: 44.w,
//           //       height: 44.w,
//           //       child: Image.asset(
//           //         'assets/images/icons/back_btn.png',
//           //         fit: BoxFit.contain,
//           //       ),
//           //     ),
//           //   ),
//           // ),
//           //             Positioned(
//           //     right: 0,
//           //     child: SizedBox(
//           //       width: 85.w,
//           //       height: 86.5.w,
//           //       child: Stack(
//           //         alignment: Alignment.center,
//           //         children: [
//           //           Image.asset(
//           //             'assets/images/icons/exit.png',
//           //             width: 85.w,
//           //             height: 86.5.w,
//           //             fit: BoxFit.contain,
//           //           ),
//           //           Material(
//           //             type: MaterialType.transparency,
//           //             child: InkResponse(
//           //               // onTap: () => Navigator.pop(context), // 필요시
//           //               customBorder: const CircleBorder(),
//           //               radius: 15,
//           //               containedInkWell: false,
//           //               child: SizedBox(width: 30.w, height: 30.w),
//           //             ),
//           //           ),
//           //         ],
//           //       ),
//           //     ),
//           //   ),


//       ],
//     );

//     // // 👉 여기에 네가 만든 로비 UI 그대로 붙여넣기
//     // // exit 버튼 onTap: widget.onExit();
//     // // TextField: controller: _codeCtl, focusNode: _codeFocus (중앙정렬이면 textAlign: TextAlign.center)
//     // return _buildLobbyContent(context); // 네 기존 코드로 구성
//   }
// }
// // Widget _buildLobbyOneOnOne() {
// // }
import 'package:blurr/features/one_on_one_chat/one_on_one_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LobbyOneOnOnePage extends StatelessWidget {
  const LobbyOneOnOnePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: _LobbyBody(
            onExit: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}

class _LobbyBody extends StatefulWidget {
  final VoidCallback onExit;
  const _LobbyBody({required this.onExit});

  @override
  State<_LobbyBody> createState() => _LobbyBodyState();
}

class _LobbyBodyState extends State<_LobbyBody> {
  late final TextEditingController _codeCtl;
  late final FocusNode _codeFocus;

  bool _submitting = false; // ✅ 로딩 상태

  @override
  void initState() {
    super.initState();
    _codeCtl = TextEditingController();
    _codeFocus = FocusNode();
  }

  @override
  void dispose() {
    _codeCtl.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _submitUIOnly() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    // ✅ 여기선 UI만: 실제 검증 로직 대신 지연만
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _submitting = false);

    // ✅ 채팅방 페이지로 이동 (플레이스홀더)
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => OneOnOneChatRoomPage(code: _codeCtl.text.trim()),
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/illustrations/home_background.png',
            fit: BoxFit.cover,
          ),
        ),

        Center(
          child: Stack(
            children: [
              // 배경
              Center(
                child: Image.asset(
                  'assets/illustrations/background_pop_up.png',
                  width: 375.w,
                ),
              ),
              // 팝업 콘텐츠
              Center(
                child: Container(
                  width: 353.w,
                  height: 423.w,
                  padding: EdgeInsets.only(left: 27.w, top: 36.h, right: 27.w, bottom: 22.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '당신과 가장 잘 맞을\n전문 상담사와 상담해보세요.',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansKR',
                          fontWeight: FontWeight.w300,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 25.h),
                      Center(
                        child: Image.asset(
                          'assets/images/home/therapy.png',
                          width: 130.w,
                        ),
                      ),
                      SizedBox(height: 19.h),

                      // 라벨 탭해도 포커스
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _codeFocus.requestFocus(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '코드 입력',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSansKR',
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF808080),
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(
                                height: 36.h,
                                child: TextField(
                                  controller: _codeCtl,
                                  focusNode: _codeFocus,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _submitUIOnly(),     // ✅ 엔터 제출
                                  textAlign: TextAlign.center,
                                  enabled: !_submitting,                   // 로딩 중 비활성
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSansKR',
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF17A1FA),
                                    fontSize: 16.sp,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: false,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                      horizontal: 0,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: const Color(0xFF808080).withAlpha(43),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF17A1FA),
                                        width: 1.5,
                                      ),
                                    ),
                                    disabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey, width: 1),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 입장 버튼
                      Center(
                        child: InkWell(
                          onTap: _submitting ? null : _submitUIOnly,       // ✅ 버튼 제출
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: _submitting ? 0.35 : 1.0,
                                  child: Image.asset(
                                    'assets/images/icons/enter.png',
                                    width: 289.w,
                                  ),
                                ),
                                // ✅ 로딩 인디케이터 (버튼 위에)
                                // AnimatedSwitcher(
                                //   duration: const Duration(milliseconds: 180),
                                //   child: _submitting
                                //       ? const SizedBox(
                                //           key: ValueKey('loader'),
                                //           width: 22,
                                //           height: 22,
                                //           child: CircularProgressIndicator(strokeWidth: 2),
                                //         )
                                //       : const SizedBox(key: ValueKey('idle'), width: 0, height: 0),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 닫기 버튼
              Positioned(
                right: 0,
                top: 200.h,
                child: SizedBox(
                  width: 85.w,
                  height: 86.5.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icons/exit.png',
                        width: 85.w,
                        height: 86.5.w,
                        fit: BoxFit.contain,
                      ),
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: widget.onExit,
                          customBorder: const CircleBorder(),
                          child: const SizedBox.expand(), // 전체 히트박스
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _submitting
                    ? Stack(
                        key: const ValueKey('globalLoading'),
                        children: const [
                          ModalBarrier(dismissible: false, color: Colors.black26),
                          Center(
                            child: SizedBox(
                              width: 36, height: 36,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('noLoading')),
              ),

            ],
          ),
        ),

        // ✅ 로딩 스크림(선택): 전체 화면 반투명 + 스피너
        // 버튼 위 스피너만으로 충분하면 이 블록은 삭제해도 됩니다.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _submitting
              ? Container(
                  key: const ValueKey('scrim'),
                  color: Colors.black.withOpacity(0.08),
                )
              : const SizedBox.shrink(key: ValueKey('noscrim')),
        ),
      ],
    );
  }
}

