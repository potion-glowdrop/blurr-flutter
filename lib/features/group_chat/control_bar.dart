import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ControlBar extends StatelessWidget {
  final bool myTurn;
  final bool arOn;
  final VoidCallback onToggleAr;
  final VoidCallback? onPass;     // 내 차례일 때만
  final VoidCallback? onProlong;  // 남 차례일 때
  final VoidCallback? onEnd;      // 남 차례일 때

  /// ✅ 이모지 관련 (원래 기능 복구)
  final List<String> emojis;                // 표시할 이모지 목록
  final String? selectedEmoji;              // 현재 선택된 이모지(선택 표시용)
  final ValueChanged<String>? onEmojiSelected; // 이모지 탭 콜백

  /// 이모지바를 숨기고 싶으면 false
  final bool showEmojiBar;

  const ControlBar({
    super.key,
    required this.myTurn,
    required this.arOn,
    required this.onToggleAr,
    this.onPass,
    this.onProlong,
    this.onEnd,
    this.emojis = const ['☀️','☁️','☔️','⚡️','🌪️','🌈','❄️'],
    this.selectedEmoji,
    this.onEmojiSelected,
    this.showEmojiBar = true,
  });

  @override
  Widget build(BuildContext context) {
    // 이모지 바 유무에 따라 높이 조정 (원본 241.h)
    final double barHeight = showEmojiBar ? 241.h : 210.h;

    return Container(
      width: 393.w,
      height: barHeight,
      padding: EdgeInsets.only(top: 21.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(44.w),
        boxShadow: [BoxShadow(color: const Color(0xFF000000).withAlpha(15), offset: const Offset(1,1), blurRadius: 2.7)],
      ),
      child: Column(
        children: [
          if (showEmojiBar) ...[
            // ==== 이모지 선택 바 (원래 디자인 복구) ====
// ==== 이모지 선택 바 (수정본) ====
SizedBox(
  width: 331.w,
  height: 29.h,
  child: OverflowBox(
    maxHeight: 51.w,
    maxWidth: 356.w,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          // 배경 이미지는 맨 아래
          Positioned.fill(
            child: Image.asset(
              'assets/images/group/textbox.png',
              fit: BoxFit.cover,
            ),
          ),
          // 이모지 Row는 위에, 충분한 패딩 + 히트박스
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: emojis.map((e) {
                    final bool isSelected = (selectedEmoji != null && selectedEmoji == e);
                    return SizedBox(
                      width: 28.w,  // 🔹 탭 영역 확보
                      height: 28.h, // 🔹 탭 영역 확보
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque, // 🔹 빈 공간도 탭 처리
                        onTap: () => onEmojiSelected?.call(e),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 120),
                          scale: isSelected ? 1.2 : 1.0,
                          child: Text(
                            e,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              height: 1.0,
                              shadows: isSelected
                                  ? [const Shadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0,1))]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),
            SizedBox(height: 26.h),
          ] else
            SizedBox(height: 35.h),

          // ==== 버튼 영역 ====
          if (myTurn)
            SizedBox(
              width: 193.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ArToggleButton(arOn: arOn, onTap: onToggleAr),
                  _IconButtonImage(asset: 'assets/images/icons/pass.png', onTap: onPass),
                ],
              ),
            )
          else
            SizedBox(
              width: 277.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ArToggleButton(arOn: arOn, onTap: onToggleAr),
                  _IconButtonImage(asset: 'assets/images/icons/prolong.png', onTap: onProlong),
                  _IconButtonImage(asset: 'assets/images/icons/end.png', onTap: onEnd),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ArToggleButton extends StatelessWidget {
  final bool arOn;
  final VoidCallback onTap;
  const _ArToggleButton({required this.arOn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.w,
      height: 44.w,
      child: OverflowBox(
        maxWidth: 104.w,
        maxHeight: 104.w,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Image.asset(
                arOn
                    ? 'assets/images/icons/ar_filter_on.png'
                    : 'assets/images/icons/ar_filter_off.png',
                width: 104.w,
                height: 104.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconButtonImage extends StatelessWidget {
  final String asset;
  final VoidCallback? onTap;
  const _IconButtonImage({required this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.w,
      height: 44.w,
      child: OverflowBox(
        maxWidth: 104.w,
        maxHeight: 104.w,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Image.asset(
                asset,
                width: 104.w,
                height: 104.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
