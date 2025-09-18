// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class NotificationPage extends StatelessWidget {
//   const NotificationPage({super.key});


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

//           Positioned(
//             top: 96.h,
//             left: 0,
//             right: 0,
//             child: Center(child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('기록', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w400, fontFamily: 'IBMPlexSansKR'),),
//                 SizedBox(height: 14.h,),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                   Stack(
//                     children: [
//                       Image.asset('assets/images/icons/toggle_btn_selected.png', width: 101.w, ),
//                       Positioned(
//                         right: 0,
//                         left: 0,
//                         top: 0,
//                         bottom: 0,
//                         child: Center(child: Text('그룹 상담', style: TextStyle(fontWeight: FontWeight.w400, fontFamily: 'IBMPlexSansKr', fontSize: 16.sp, color: Color(0xFF17A1FA),  ) )))
//                     ],
//                   ),
//                   Stack(
//                     children: [
//                       Image.asset('assets/images/icons/toggle_btn_unselected.png', width: 101.w, ),
//                       Positioned(
//                         right: 0,
//                         left: 0,
//                         bottom: 0,
//                         top: 0,
//                         child: Text('내담록', style: TextStyle(fontWeight: FontWeight.w400, fontFamily: 'IBMPlexSansKr', fontSize: 16.sp, color: Color(0xFF616161) ),))
//                     ],
//                   ),
//                 ],)


//               ],
//             ),)
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

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {


  Widget _tabContent() {
    return SizedBox(
      width: 327.w,
      height: 663.h,
      child: SingleChildScrollView(
        child:
        Column(
          children: [
            alert(),
            alert(),
            alert(),
            alert(),
            alert(),
            alert(),

            ],
          
        )
      ),
    );
  }

  Widget alert(){
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 15.w),
          decoration: BoxDecoration(color: Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(12.w)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('2025. 09. 22.',style: TextStyle(fontSize: 12.sp, color: Color(0xFF616161), fontWeight: FontWeight.w500 ) ),
              SizedBox(height: 5.h,),
              Text('오늘 다른 사람들의 이야기를 들으며, 나도 혼자가 아니라는 걸 느꼈다. 조금은 마음이 가벼워졌다.', style: TextStyle(fontSize: 14.sp, fontFamily: 'IBMPlexSansKR', color: Color(0xFF000000), fontWeight: FontWeight.w300),),
 
            ],

          ),

        ),
        SizedBox(height: 20.h,),

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
                  Text('알림',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'IBMPlexSansKR',
                      )),
                  SizedBox(height: 14.h),
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
