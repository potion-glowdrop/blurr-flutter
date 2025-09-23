import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blurr/features/group_chat/face_avatar_painter.dart';
import 'package:blurr/features/group_chat/mouth_state.dart';

class ParticipantAvatar extends StatelessWidget {
  final String name;
  final String image;
  final String turnImage;
  final String turn;
  final String? badge;

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  final double size;
  final double sizeTurn;

  final bool arOn;
  final bool isSelf;

  final MouthState? mouthStateOverride;
  final double? mouthOpenRatioOverride;
  final bool? leftEyeOpenOverride;
  final bool? rightEyeOpenOverride;

  const ParticipantAvatar({
    super.key,
    required this.name,
    required this.image,
    required this.turnImage,
    required this.turn,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.size = 46,
    this.sizeTurn = 72,
    this.badge,
    this.arOn = false,
    this.isSelf = false,
    this.mouthOpenRatioOverride,
    this.mouthStateOverride,
    this.leftEyeOpenOverride,
    this.rightEyeOpenOverride,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTurn = (turn == name);
    final double avatarSize = isTurn ? sizeTurn.w : size.w;
    final bool hasBadge = (badge?.trim().isNotEmpty ?? false);

    MouthState mouth = (isSelf && isTurn) ? MouthState.talking : MouthState.neutral;
    double ratio = (mouth == MouthState.talking) ? 0.22 : 0.02;
    bool leftOpen = true;
    bool rightOpen = true;

    mouth = mouthStateOverride ?? mouth;
    ratio = mouthOpenRatioOverride ?? ratio;
    leftOpen = leftEyeOpenOverride ?? leftOpen;
    rightOpen = rightEyeOpenOverride ?? rightOpen;

    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: avatarSize,
                      height: avatarSize,
                      child: OverflowBox(
                        maxHeight: isTurn ? (sizeTurn * 1.78).w : (size * 2.3).w,
                        maxWidth: isTurn ? (sizeTurn * 1.78).w : (size * 2.3).w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.w),
                          child: Image.asset(
                            isTurn ? turnImage : image,
                            width: isTurn ? (sizeTurn * 1.78).w : (size * 2.3).w,
                          ),
                        ),
                      ),
                    ),
                    if (isSelf && arOn)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: FaceAvatarPainter(
                              mouthState: mouth,
                              mouthOpenRatio: ratio,
                              leftEyeOpen: leftOpen,
                              rightEyeOpen: rightOpen,
                            ),
                          ),
                        ),
                      ),
                    if (hasBadge)
                      Positioned(
                        right: -5.w,
                        top: 0,
                        child: Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(11.w),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(1, 1),
                                blurRadius: 4.w,
                                color: isTurn ? const Color(0xFF2BACFF) : const Color(0xFF000000).withAlpha(7),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              badge ?? '',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 21.w,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: isTurn ? const Color(0xFF2BACFF) : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(13.w),
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isTurn ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                      fontFamily: 'IBMPlexSansKR',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
