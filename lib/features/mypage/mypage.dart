import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경
          Positioned.fill(
            child: Image.asset(
              'assets/images/mypage/background.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 130.h,
            child: Column(
              children: [
                SizedBox(
                  width: 130.w,
                  height: 130.w,
                  child: Image.asset('assets/images/mypage/me.png',)),
                SizedBox(height: 27.h,),
                Text('숭실의아픈손가락', style: TextStyle(fontSize: 24.sp, fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w600),),
                SizedBox(height: 16.h,),
                Container(
                  width: 84.w,
                  height: 26.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(13.5.w),
                  ),
                  child: Center(child: Text('정보 수정하기', style: TextStyle(fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w500, fontSize: 10.sp),)),
                ),
                // SizedBox(height: 42.h,),
                // Container(
                //   width: double.infinity,
                //   height: 5.h,
                //   decoration: BoxDecoration(color: Color(0xFFF7F7F0)),
                // ),
                SizedBox(height: 31.h,),
                Container(
                  width: 329.w, 
                  // height: 149.h,
                  padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 21.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.w),
                    color: Color(0xFFF8F8E4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('내 상담 내역', style: TextStyle(fontSize: 12.sp, fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w400, color: Color(0xFF9F9F9F)), ),
                      SizedBox(height: 28.h,),
                      Text('1:1 상담 🗣️', style: TextStyle(fontSize: 16.sp, fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w500, color: Color(0xFF373737)), ),
                      SizedBox(height: 13.h,),
                      Container(
                        width: double.infinity,
                        height: 1.5,
                        color: Color(0xFFECECEC),
                      ),
                      SizedBox(height: 19.h,),
                      Text('그룹 상담 👭', style: TextStyle(fontSize: 16.sp, fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w500, color: Color(0xFF373737)), ),

                    ],
                  ),
                  
                  ),
                  SizedBox(height: 30.h,),
                  SizedBox(
                    width: 300.w,
                    child: Text('도움말', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w400, fontFamily: 'IBMPlexSansKR', color: Color(0xFF948E8E)),),
                  ),
                SizedBox(height: 14.h,),

                Container(
                  width: 345.w,
                  height: 2,
                  decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
                ),
                SizedBox(height: 14.h,),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  width: 345.w,
                  child: Row(
                    children: [
                      Image.asset('assets/images/mypage/personal.png', width: 15.w,),
                      SizedBox(width: 12.w,),
                      Text('개인정보 처리 방침', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w400, fontFamily: 'IBMPlexSansKR'),),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  width: 345.w,
                  child: Row(
                    children: [
                      Image.asset('assets/images/mypage/policy.png', width: 15.w,),
                      SizedBox(width: 12.w,),
                      Text('서비스 이용 약관', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w400, fontFamily: 'IBMPlexSansKR'),),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  width: 345.w,
                  child: Row(
                    children: [
                      Image.asset('assets/images/mypage/licence.png', width: 15.w,),
                      SizedBox(width: 12.w,),
                      Text('오픈소스 라이센스', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w400, fontFamily: 'IBMPlexSansKR'),),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  width: 345.w,
                  child: Row(
                    children: [
                      Image.asset('assets/images/mypage/version.png', width: 15.w,),
                      SizedBox(width: 12.w,),
                      Text('버전 정보', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w400, fontFamily: 'IBMPlexSansKR'),),
                    ],
                  ),
                ),



              ],
            ),

          ),



          // 뒤로가기 버튼
          Positioned(
            left: 23.w,   // ← ScreenUtil은 w/h 반대로 쓰지 않도록 주의!
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
