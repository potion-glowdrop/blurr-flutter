import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SessionInfoCard extends StatelessWidget {
  final String text;

  const SessionInfoCard({super.key, required this.text});

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
