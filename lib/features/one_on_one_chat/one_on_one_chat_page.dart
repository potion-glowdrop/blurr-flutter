
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 채팅방 페이지 (UI 데모용)
class OneOnOneChatRoomPage extends StatefulWidget {
  final String code;
  const OneOnOneChatRoomPage({super.key, required this.code});

  @override
  State<OneOnOneChatRoomPage> createState() => _OneOnOneChatRoomPageState();
}

class _OneOnOneChatRoomPageState extends State<OneOnOneChatRoomPage> {
  bool _arOn = false; // ✅ AR 필터 on/off 상태

  @override
  void didChangeDependencies() {
    // 선택: 이미지 미리 로드해서 깜빡임 방지
    precacheImage(const AssetImage('assets/images/icons/ar_filter_on.png'), context);
    precacheImage(const AssetImage('assets/images/icons/ar_filter_off.png'), context);
    super.didChangeDependencies();
  }

  Widget camera_box(String name){
    // name = '홍길동';
    return Stack(
      children: [
        Image.asset('assets/images/one_on_one/member_box.png', width: 375.w),
        if(_arOn==true)
          Positioned(
            top: 23.h,
            left: 0,
            right: 0,
            child: 
              Center(
                child: Image.asset('assets/images/one_on_one/ar_background.png', width: 152.5.w,),
              )
            )
        else
          Positioned(
          top: 18.w,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 340.w,
              height: 220.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Colors.black
              ),
            ),
          )),
        Positioned(
          top: 22.h,
          right: 26.w,
          child: 
          Container(
            // width: 58.w,
            height: 32.27.h,
            padding: EdgeInsets.symmetric(horizontal: 9.w),
            decoration: BoxDecoration(
              color: Color(0xFF2BACFF),
              borderRadius: BorderRadius.circular(13.w),
            ),
            child: Center(child: Text(name, style: TextStyle(fontSize: 14.sp, color: Color(0xFFFFFFFF), fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w500),)),
          )
        ),

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
              'assets/illustrations/one_on_one_bgd.png',
              fit: BoxFit.cover,
            ),
          ),

          // 콘텐츠
          Positioned(
            top: 128.h,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  camera_box('김상담'),
                  // Image.asset('assets/images/one_on_one/member_box.png', width: 375.w),
                  SizedBox(height: 28.h),
                  camera_box('나비'),
                  SizedBox(height: 19.h),

                  // ✅ AR 필터 on/off 토글 버튼
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _arOn = !_arOn),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.all(6.w), // 터치 여유
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
                            key: ValueKey(_arOn), // 상태별 키로 전환 애니메이션
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

          // exit 버튼 (유한 크기 보장 + 올바른 onTap)
          Positioned(
            left: -10.w,
            top: 35.h,
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
      ),
    );
  }
}
