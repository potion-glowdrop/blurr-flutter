
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class LobbyGroupPage extends StatelessWidget {
//   const LobbyGroupPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // ScreenUtil 초기화가 상위에서 되어 있다면 생략 가능
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: const Center(child: _GroupLobbyBody()),
//       ),
//     );
//   }
// }

// class _GroupLobbyBody extends StatefulWidget {
//   const _GroupLobbyBody();

//   @override
//   State<_GroupLobbyBody> createState() => _GroupLobbyBodyState();
// }

// class _GroupLobbyBodyState extends State<_GroupLobbyBody> {
//   // 토픽 목록
//   final List<String> _topics = const [
//     '혼자라는 느낌',
//     '멈추기 힘들 것들',
//     '잃어버린 것들',
//     '가족 이야기',
//   ];

//   // 단일 선택 인덱스
//   int _selectedIndex = -1;

//   //남은 시간
//   Timer? _ticker;
//   Duration _remaining = Duration.zero;


//   // 토픽 버튼 UI
//   Widget _topicButton(int i) {
//     final bool selected = i == _selectedIndex;
//     final String label = _topics[i];

//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: () => setState(() => _selectedIndex = i),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Image.asset(
//             selected
//                 ? 'assets/images/icons/topic_selected_btn.png'
//                 : 'assets/images/icons/topic_btn.png',
//             width: 319.w,
//             fit: BoxFit.fill,
//           ),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontFamily: 'IBMPlexSansKR',
//               fontSize: 20.sp,
//               fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
//               color: selected ? const Color(0xFF17A1FA) : const Color(0xFF777777),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _goNext() {
//     if (_selectedIndex < 0) return;
//     final topic = _topics[_selectedIndex];

//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (_, __, ___) => GroupRoomPage(topic: topic),
//         transitionDuration: const Duration(milliseconds: 220),
//         reverseTransitionDuration: const Duration(milliseconds: 180),
//         transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // 배경
//         Positioned.fill(
//           child: Image.asset(
//             'assets/illustrations/home_background.png',
//             fit: BoxFit.cover,
//           ),
//         ),

//         // 카드 배경
//         Positioned(
//           top: 96.h,
//           left: 0,
//           right: 0,
//           child: Center(
//             child: Image.asset(
//               'assets/images/home/group_lobby_bkg.png',
//               width: 375.w,
//               height: 595.h,
//               fit: BoxFit.fill,
//             ),
//           ),
//         ),

//         // 콘텐츠
//         Positioned(
//           top: 102.h,
//           left: 0,
//           right: 0,
//           child: Center(
//             child: Container(
//               width: 355.w,
//               height: 595.h,
//               padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 30.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '이 공간에서 마음에 담아둔 \n이야기를 꺼내보세요.',
//                     style: TextStyle(
//                       fontFamily: 'IBMPlexSansKR',
//                       fontWeight: FontWeight.w300,
//                       fontSize: 20.sp,
//                     ),
//                   ),
//                   SizedBox(height: 17.h),
//                   Text(
//                     '오늘 하고 싶은 이야기는 무엇인가요?',
//                     style: TextStyle(
//                       fontFamily: 'IBMPlexSansKR',
//                       fontSize: 14.sp,
//                       color: const Color(0xFF48674C),
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                   SizedBox(height: 28.h),

//                   // 상단 장식(원형 박스)
//                   Center(
//                     child: Container(
//                       width: 186.w,
//                       height: 96.h,
//                       padding: EdgeInsets.only(top: 19.h),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(45.w),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text('다음 세션까지 남은 시간', style: TextStyle(fontFamily: 'IBMPlexSansKr', fontSize: 12.sp, fontWeight: FontWeight.w400),),
//                           Text('52:21', style: TextStyle(fontSize: 36.sp, color: Color(0xFF17A1FA)),)
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 22.h),

//                   // 토픽 버튼들 (단일 선택)
//                   Center(child: _topicButton(0)),
//                   SizedBox(height: 15.h),
//                   Center(child: _topicButton(1)),
//                   SizedBox(height: 15.h),
//                   Center(child: _topicButton(2)),
//                   SizedBox(height: 15.h),
//                   Center(child: _topicButton(3)),
//                   SizedBox(height: 20.h),

//                   SizedBox(height: 10.h),
//                   Text(
//                     '매 정각에 세션이 시작됩니다.\n정각 5분 전부터 그룹 룸에 입장이 가능합니다.',
//                     style: TextStyle(
//                       fontSize: 10.sp,
//                       fontWeight: FontWeight.w200,
//                       fontFamily: 'IBMPlexSansKR',
//                       color: const Color(0xFF969696),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//                   // 입장 버튼: 선택 전 비활성
//                   Positioned(
//                     bottom: 97.h,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: IgnorePointer(
//                         ignoring: _selectedIndex < 0,
//                         child: InkWell(
//                           onTap: _goNext,
//                           borderRadius: BorderRadius.circular(12.r),
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(vertical: 4.h),
//                             child: Image.asset(
//                               'assets/images/icons/enter.png',
//                               width: 360.w,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),


//         // Exit 버튼(좌상단)
//         Positioned(
//           left: -10.w,
//           top: 35.h,
//           width: 85.w,
//           height: 86.5.w,
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: () => Navigator.pop(context),
//               customBorder: const CircleBorder(),
//               child: Stack(
//                 fit: StackFit.expand,
//                 alignment: Alignment.center,
//                 children: [
//                   Image.asset('assets/images/icons/exit.png', fit: BoxFit.contain, ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// /// 다음 페이지(그룹 룸) — 선택된 토픽을 전달받아 표시하는 예시
// class GroupRoomPage extends StatelessWidget {
//   final String topic;
//   const GroupRoomPage({super.key, required this.topic});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('그룹 룸: $topic')),
//       body: Center(
//         child: Text(
//           '선택한 주제: $topic',
//           style: TextStyle(fontFamily: 'IBMPlexSansKR', fontSize: 18.sp),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:blurr/features/group_chat/group_room_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LobbyGroupPage extends StatelessWidget {
  const LobbyGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: const Center(child: _GroupLobbyBody()),
      ),
    );
  }
}

class _GroupLobbyBody extends StatefulWidget {
  const _GroupLobbyBody();

  @override
  State<_GroupLobbyBody> createState() => _GroupLobbyBodyState();
}

class _GroupLobbyBodyState extends State<_GroupLobbyBody> {
  // 토픽 목록
  final List<String> _topics = const [
    '혼자라는 느낌',
    '멈추기 힘들 것들',
    '잃어버린 것들',
    '가족 이야기',
  ];

  // 단일 선택 인덱스
  int _selectedIndex = -1;

  // ====== ⏱ 남은 시간(다음 정각 55분까지) ======
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _updateRemaining();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  // 다음 HH:55:00 타임스탬프
  DateTime _next55(DateTime now) {
    final current55 = DateTime(now.year, now.month, now.day, now.hour, 55);
    if (now.isBefore(current55)) return current55;
    // 이미 55분을 지났으면 다음 시간의 55분
    final nextHour = now.add(const Duration(hours: 1));
    return DateTime(nextHour.year, nextHour.month, nextHour.day, nextHour.hour, 55);
    // (자정 넘어가는 것도 DateTime이 자동 처리)
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final target = _next55(now);
    final diff = target.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  String _format(Duration d) {
    final m = d.inMinutes;          // 0~59
    final s = d.inSeconds % 60;     // 0~59
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  // =============================================

  // 토픽 버튼 UI
  Widget _topicButton(int i) {
    final bool selected = i == _selectedIndex;
    final String label = _topics[i];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedIndex = i),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            selected
                ? 'assets/images/icons/topic_selected_btn.png'
                : 'assets/images/icons/topic_btn.png',
            width: 319.w,
            fit: BoxFit.fill,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBMPlexSansKR',
              fontSize: 20.sp,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              color: selected ? const Color(0xFF17A1FA) : const Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  void _goNext() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GroupRoomPage(topic: '그룹'),
        transitionDuration: Duration(milliseconds: 220),
        reverseTransitionDuration: Duration(milliseconds: 180),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 배경
        Positioned.fill(
          child: Image.asset(
            'assets/illustrations/home_background.png',
            fit: BoxFit.cover,
          ),
        ),

        // 카드 배경
        Positioned(
          top: 96.h,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              'assets/images/home/group_lobby_bkg.png',
              width: 375.w,
              height: 595.h,
              fit: BoxFit.fill,
            ),
          ),
        ),

        // 콘텐츠
        Positioned(
          top: 102.h,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 355.w,
              height: 595.h,
              padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이 공간에서 마음에 담아둔 \n이야기를 꺼내보세요.',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansKR',
                      fontWeight: FontWeight.w300,
                      fontSize: 20.sp,
                    ),
                  ),
                  SizedBox(height: 17.h),
                  Text(
                    '오늘 하고 싶은 이야기는 무엇인가요?',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansKR',
                      fontSize: 14.sp,
                      color: const Color(0xFF48674C),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // 상단 장식(원형 박스) + 카운트다운
                  Center(
                    child: Container(
                      width: 186.w,
                      height: 96.h,
                      padding: EdgeInsets.only(top: 19.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(45.w),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '다음 세션까지 남은 시간',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansKR',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _format(_remaining),                         // ⏱ 실시간 업데이트
                            style: TextStyle(
                              fontSize: 36.sp,
                              color: const Color(0xFF17A1FA),
                              fontFamily: 'IBMPlexSansKR',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),

                  // 토픽 버튼들 (단일 선택)
                  Center(child: _topicButton(0)),
                  SizedBox(height: 15.h),
                  Center(child: _topicButton(1)),
                  SizedBox(height: 15.h),
                  Center(child: _topicButton(2)),
                  SizedBox(height: 15.h),
                  Center(child: _topicButton(3)),
                  SizedBox(height: 20.h),

                  SizedBox(height: 10.h),
                  Text(
                    '매 정각에 세션이 시작됩니다.\n정각 5분 전부터 그룹 룸에 입장이 가능합니다.',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w200,
                      fontFamily: 'IBMPlexSansKR',
                      color: const Color(0xFF969696),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 입장 버튼
        Positioned(
          bottom: 97.h,
          left: 0,
          right: 0,
          child: Center(
            child: IgnorePointer(
              ignoring: _selectedIndex < 0,
              child: InkWell(
                onTap: _goNext,
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Image.asset(
                    'assets/images/icons/enter.png',
                    width: 360.w,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Exit 버튼(좌상단)
        Positioned(
          right: 0.w,
          top: 90.h,
          width: 85.w,
          height: 86.5.w,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/images/icons/exit.png', fit: BoxFit.contain),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
