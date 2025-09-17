import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

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

          // 뒤로가기 버튼
          Positioned(
            left: 37.w,   // ← ScreenUtil은 w/h 반대로 쓰지 않도록 주의!
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
