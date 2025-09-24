import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SessionSummaryCard extends StatelessWidget {
  final String dateLabel;          // 예: '2025. 09. 22.'
  final String teacherName;        // 예: '김포숑'
  final String durationLabel;      // 예: '58분 21초'
  final String summary;            // 본문 요약
  final VoidCallback? onClose;     // 닫기 아이콘 탭 콜백
  final double? width;             // 기본 393.w
  final double? height;            // 기본 341.h
  final EdgeInsets? padding;       // 기본 EdgeInsets.only(top: 38.h, left: 41.w, right: 41.w)
  final String closeIconAsset;     // 닫기 아이콘 경로

  const SessionSummaryCard({
    super.key,
    required this.dateLabel,
    required this.teacherName,
    required this.durationLabel,
    required this.summary,
    this.onClose,
    this.width,
    this.height,
    this.padding,
    this.closeIconAsset = 'assets/images/icons/x.png',
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? 393.w;
    final cardHeight = height ?? 341.h;

    return Stack(
      children: [
        Container(
          padding: padding ?? EdgeInsets.only(top: 38.h, left: 41.w, right: 41.w),
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withAlpha(11),
                offset: const Offset(1, 1),
                blurRadius: 11.4,
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(44.w),
              topRight: const Radius.circular(44.2),
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansKR',
                      fontSize: 10.sp,
                      color: const Color(0xFF5B865F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '담당 선생님 : $teacherName\n세션 시간: $durationLabel',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansKR',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  summary,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'IBMPlexSansKR',
                    color: const Color(0xFF000000),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 22.w,
          top: 22.w,
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Image.asset(
              closeIconAsset,
              width: 14.5.w,
            ),
          ),
        ),
      ],
    );
  }
}
