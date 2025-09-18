import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  const GroupRoomPage({
    super.key,
    required this.topic,
    this.myTurn = true,
  });

  @override
  State<GroupRoomPage> createState() => _GroupRoomPageState();
}

class _GroupRoomPageState extends State<GroupRoomPage> {
  bool _arOn = true; // AR 필터 On/Off 상태

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
                  const ParticipantsRow(
                    participants: ['이슬', '나비', '바다', '새싹', '파도'],
                    activeName: '나비',
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

          // 하단 컨트롤 박스
          Positioned(
            bottom: 0.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 393.w,
                height: 241.h,
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
                          child: Image.asset(
                            'assets/images/group/textbox.png',
                            width: 356.w,
                            height: 51.w,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 26.h),

                    // 내 차례일 때와 아닐 때 UI 분기
                    if (widget.myTurn)
                      SizedBox(
                        width: 193.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ArToggleButton(
                              arOn: _arOn,
                              onTap: () => setState(() => _arOn = !_arOn),
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
                              onTap: () => setState(() => _arOn = !_arOn),
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


// class GroupRoomPage extends StatelessWidget {
//   final String topic;
//   bool myturn = false;
//   GroupRoomPage({super.key, required this.topic});
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

//           Positioned(
//             top: 100.h,
//             left: 0,
//             right: 0,
//             child: 
//           Center(
//             child: Column(
//               children: [
//                 SessionInfoCard(text: '이번 세션의 당신의 닉네임은 나비입니다. 그룹 대화 방에서는 음성과 표정으로 소통할 수 있습니다.'),
//                 SizedBox(height: 11,),
//                 ParticipantsRow(participants: ['이슬', '나비', '바다', '새싹', '파도'], activeName: '나비')
//               ],
//             ),
//           )
//           ),
//                       Positioned(
//                         top: 300.h,
//                         left: 0,
//                         right: 0,
//                         child: Center(
//                           child: Stack(
//                             children: [
//                               SizedBox(
//                                 width: 258.w,
//                                 height: 258.w,
//                                 child: OverflowBox(
//                                   maxWidth: 310.w,   // 넘칠 수 있는 최대 크기
//                                   maxHeight: 310.w,
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(10.w),
//                                     child: Image.asset(
//                                       'assets/images/group/round_table.png',
//                                       width: 310.w,
//                                       height: 310.w,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             Positioned(
//                               top: 0,
//                               bottom: 0,
//                               left: 0,
//                               right: 0,
//                               child: Center(
//                                 child: Image.asset('assets/images/group/glow.png', width: 150.w,),
//                               ),
//                             ),

//                               Positioned(
//                                 top: 0,
//                                 bottom: 0,
//                                 left: 0,
//                                 right: 0,
//                                 child: Center(
//                                   child: SizedBox(
//                                     width: 72.w,
//                                     height: 72.w,
//                                     child: OverflowBox(
//                                       maxWidth: 198.w,
//                                       maxHeight: 198.w,
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadiusGeometry.circular(10.w),
//                                         child: Image.asset('assets/images/group/center_piece.png',
//                                         width: 198.w,
//                                         height: 198.w,),
//                                       ),
//                                     ),
                                                                    
//                                   ),
//                                 ),
//                               ),

//                             ],
//                           ),
//                         ),
//                       ),




//           Positioned(
//             bottom: 0.h,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Container(
//                 width: 393.w,
//                 height: 241.h,
//                 padding: EdgeInsets.only(top: 21.h),
//                 decoration: BoxDecoration(
//                 color: Color(0xFFFFFFFF),
//                   borderRadius: BorderRadius.circular(44.w),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Color(0xFF000000).withAlpha(15),
//                       offset: Offset(1, 1),
//                       blurRadius: 2.7
//                     )
//                   ]
//                 ),
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       width: 331.w,
//                       height: 29.h,
//                       child: OverflowBox(
//                         maxHeight: 51.w,
//                         maxWidth: 356.w,
//                         child: ClipRRect(
//                           borderRadius: BorderRadiusGeometry.circular(10),
//                           child: Image.asset('assets/images/group/textbox.png', width: 356.w, height: 51.w,)
//                           )),

//                       ),
//                     SizedBox(height: 26.h,),
//                     if(myturn)
//                       SizedBox(
//                         width: 277.w,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                               SizedBox(
//                                 width: 44.w,
//                                 height: 44.w,
//                                 child: OverflowBox(
//                                   maxWidth: 104.w,   // 넘칠 수 있는 최대 크기
//                                   maxHeight: 104.w,
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(10.w),
//                                     child: Image.asset(
//                                       'assets/images/icons/ar_filter_off.png',
//                                       width: 104.w,
//                                       height: 104.w,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 44.w,
//                                 height: 44.w,
//                                 child: OverflowBox(
//                                   maxWidth: 104.w,   // 넘칠 수 있는 최대 크기
//                                   maxHeight: 104.w,
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(10.w),
//                                     child: Image.asset(
//                                       'assets/images/icons/pass.png',
//                                       width: 104.w,
//                                       height: 104.w,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       )
//                     else
//                       SizedBox(                        width: 277.w,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                           Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () => setState(() => _arOn = !_arOn),
//                               borderRadius: BorderRadius.circular(12.r),
//                               child: Padding(
//                                 padding: EdgeInsets.all(6.w), // 터치 여유
//                                 child: AnimatedSwitcher(
//                                   duration: const Duration(milliseconds: 160),
//                                   switchInCurve: Curves.easeOut,
//                                   switchOutCurve: Curves.easeIn,
//                                   transitionBuilder: (child, anim) =>
//                                       FadeTransition(opacity: anim, child: child),
//                                   child: Image.asset(
//                                     _arOn
//                                         ? 'assets/images/icons/ar_filter_on.png'
//                                         : 'assets/images/icons/ar_filter_off.png',
//                                     key: ValueKey(_arOn), // 상태별 키로 전환 애니메이션
//                                     width: 104.w,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                               SizedBox(
//                                 width: 44.w,
//                                 height: 44.w,
//                                 child: OverflowBox(
//                                   maxWidth: 104.w,   // 넘칠 수 있는 최대 크기
//                                   maxHeight: 104.w,
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(10.w),
//                                     child: Image.asset(
//                                       'assets/images/icons/pass.png',
//                                       width: 104.w,
//                                       height: 104.w,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       )
                                          
//                   ],
//                 ),
//               ),
//             ),
            

//           ),



//           // 뒤로가기 버튼
//           Positioned(
//             left: 23.w,   // ← ScreenUtil은 w/h 반대로 쓰지 않도록 주의!
//             top: 53.h,
//             child: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: SizedBox(
//                 width: 44.w,
//                 height: 44.w,
//                 child: Image.asset(
//                   'assets/images/icons/back_btn.png',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
