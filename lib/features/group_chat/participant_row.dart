import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ParticipantsRow extends StatelessWidget {
  final List<String> participants;
  final String activeName;

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
                    color: const Color(0xFF17A1FA),
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
                color: const Color(0xFFBDBDBD),
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}
