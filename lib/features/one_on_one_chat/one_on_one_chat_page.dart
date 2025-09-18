import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 채팅방 페이지 (UI 데모용)
class OneOnOneChatRoomPage extends StatelessWidget {
  final String code;
  const OneOnOneChatRoomPage({super.key, required this.code});

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

          // exit button (크기 제약 추가 + 올바른 onTap)
          Positioned(
            left: 0.w,
            top: 35.h,
            width: 85.w,                 // ✅ Positioned에 폭/높이 지정
            height: 86.5.w,              // ✅ 혹은 child를 SizedBox로 감싸도 됨
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context), // ✅ 콜백으로 감싸기
                customBorder: const CircleBorder(),
                child: Stack(
                  fit: StackFit.expand,             // ✅ 부모 크기를 꽉 채움(유한)
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/icons/exit.png',
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 다른 위젯들...
        ],
      ),
    );
  }
}
