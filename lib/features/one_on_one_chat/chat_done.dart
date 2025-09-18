import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OneOnOneDone extends StatelessWidget {
  const OneOnOneDone({super.key});

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

          // 뒤로가기 버튼
          Positioned(
            left: -10.w,
            top: 35.h,
            width: 85.w,
            height: 86.5.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
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
