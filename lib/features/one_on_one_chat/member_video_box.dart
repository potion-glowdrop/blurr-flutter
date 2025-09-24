import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 멤버 비디오 박스(배경 프레임 + 이름 배지 + 콘텐츠 슬롯)
/// - isSelf && arOn: AR 오버레이만 그림(프리뷰 없음)
/// - lkConnected: isSelf면 로컬, 아니면 원격 비디오
/// - 그 외: isSelf면 프리뷰(+옵션 오버레이), 아니면 플레이스홀더(검은 박스)
class MemberVideoBox extends StatelessWidget {
  final String name;
  final bool isSelf;
  final bool arOn;
  final bool lkConnected;

  /// 내부 콘텐츠 영역 크기 (기존 340.w x 220.h)
  final double contentWidth;
  final double contentHeight;

  /// 프리뷰+오버레이 빌더 (파라미터로 showPreview/showOverlay 제어)
  final Widget Function({required bool showPreview, required bool showOverlay})
      buildPreviewWithOverlay;

  /// 로컬 비디오 위젯(내 카메라: LiveKit)
  final Widget Function() buildLocal;

  /// 원격 비디오 위젯(상대 카메라: LiveKit)
  final Widget Function() buildRemote;

  /// 원격 미연결 시 표시할 플레이스홀더
  final Widget placeholder;

  const MemberVideoBox({
    super.key,
    required this.name,
    required this.isSelf,
    required this.arOn,
    required this.lkConnected,
    required this.contentWidth,
    required this.contentHeight,
    required this.buildPreviewWithOverlay,
    required this.buildLocal,
    required this.buildRemote,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    Widget content() {
      if (isSelf && arOn) {
        // 프리뷰 없이 오버레이만
        return buildPreviewWithOverlay(showPreview: false, showOverlay: true);
      }

      if (lkConnected) {
        return isSelf ? buildLocal() : buildRemote();
      } else {
        return isSelf
            ? buildPreviewWithOverlay(
                showPreview: true,
                showOverlay: arOn,
              )
            : placeholder;
      }
    }

    return Stack(
      children: [
        Image.asset('assets/images/one_on_one/member_box.png', width: 375.w),
        Positioned(
          top: 18.h,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: contentWidth,
              height: contentHeight,
              child: content(),
            ),
          ),
        ),
        // 이름 배지
        Positioned(
          top: 22.h,
          right: 26.w,
          child: Container(
            height: 32.27.h,
            padding: EdgeInsets.symmetric(horizontal: 9.w),
            decoration: BoxDecoration(
              color: const Color(0xFF2BACFF),
              borderRadius: BorderRadius.circular(13.w),
            ),
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontFamily: 'IBMPlexSansKR',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
