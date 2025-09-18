// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class RecordPage extends StatelessWidget {
//   const RecordPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // 배경
//           Positioned.fill(
//             child: Image.asset(
//               'assets/illustrations/widget_background.png',
//               fit: BoxFit.cover,
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  int _currentTab = 0; // 0: 그룹 상담, 1: 내담록

  Widget _toggleButton({
    required String label,
    required int index,
  }) {
    final bool selected = _currentTab == index;
    return InkWell(
      onTap: () => setState(() => _currentTab = index),
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            selected
                ? 'assets/images/icons/toggle_btn_selected.png'
                : 'assets/images/icons/toggle_btn_unselected.png',
            width: 101.w,
            fit: BoxFit.fill,
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSansKR',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: selected ? const Color(0xFF17A1FA) : const Color(0xFF616161),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabContent() {
    return SizedBox(
      width: 327.w,
      height: 663.h,
      child: SingleChildScrollView(
        child: _currentTab == 0?Column(
          children: [
            alert(),
            alert(),
            alert(),
            alert(),
            alert(),
            alert(),

            ],
          
        ):Column(
          children: [
            //calendar
            Container(
              width: 312.w,
              height: 279.h,
              color: Colors.red,
            ),
            SizedBox(height: 54.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 146.w,
                  height: 97.h,
                  color: Colors.red,
                ),
                Container(
                  width: 146.w,
                  height: 97.h,
                  color: Colors.red,
                )

              ],
            ),
            SizedBox(height: 20.h,),
            Container(
                  width: double.infinity,
                  height: 97.h,
                  color: Colors.red,
            )



          ],
        ),
      ),
    );
  }

  Widget alert(){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 12.w,),
            Text('2025. 09. 22.',style: TextStyle(fontSize: 12.sp, color: Color(0xFF616161) ) ),
          ],
        ),
        SizedBox(height: 4.h,),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 15.w),
          decoration: BoxDecoration(color: Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(12.w)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('혼자라는 느낌', style: TextStyle(fontSize: 14.sp, fontFamily: 'IBMPlexSansKR', color: Color(0xFF75A97A), fontWeight: FontWeight.w400),),
              SizedBox(height: 5.h,),
              Text('22:31', style: TextStyle(fontSize: 14.sp, fontFamily: 'IBMPlexSansKR', color: Color(0xFF797979), fontWeight: FontWeight.w500),),
              SizedBox(height: 30.h,),
              Text('오늘 다른 사람들의 이야기를 들으며, 나도 혼자가 아니라는 걸 느꼈다. 조금은 마음이 가벼워졌다.', style: TextStyle(fontSize: 14.sp, fontFamily: 'IBMPlexSansKR', color: Color(0xFF000000), fontWeight: FontWeight.w300),),
            ],
          ),
        ),
        SizedBox(height: 8.h,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 12.w,),
            Text('이 주제로 지금까지 3번 참여했어요 !',style: TextStyle(fontSize: 12.sp, color: Color(0xFFA3A3A3,), fontWeight: FontWeight.w600 ) ),
          ],
        ),
        SizedBox(height: 22.h,),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경
          Positioned.fill(
            child: Image.asset(
              'assets/illustrations/widget_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // 상단 타이틀 + 토글 + 탭 콘텐츠
          Positioned(
            top: 96.h,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('기록',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'IBMPlexSansKR',
                      )),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _toggleButton(label: '그룹 상담', index: 0),
                      SizedBox(width: 8.w),
                      _toggleButton(label: '내담록', index: 1),
                    ],
                  ),
                  SizedBox(height: 30.h,),
                  _tabContent(),
                ],
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
