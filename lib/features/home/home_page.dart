import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../record/record_page.dart';
import '../notification/notification_page.dart';
import '../mypage/mypage.dart';

class MainContentPage extends StatefulWidget {
  const MainContentPage({super.key});

  @override
  State<MainContentPage> createState() => _MainContentPageState();
}

class _MainContentPageState extends State<MainContentPage> {
  late final PageController _pageController;
  int _page = 0;

  // 1) 페이지 리스트로 관리
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = [
      _buildGroupChat(),
      _buildOneOnOneChat(),
      // _buildGroupChat(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/illustrations/home_background_btm.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 211.h,
            left: 0,
            right: 0,
            child: SizedBox(             // 2) Center 생략해도 됨
              width: 1.0.sw,
              height: 420.h,
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _page = i),
                      children: _pages,   // 리스트 사용
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) { // 개수 자동
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: active ? 18.w : 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: active ? const Color(0xFF17A1FA) : const Color(0xFFD9D9D9),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // 하단 커스텀 바 (그대로)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 66.h),
              child: SizedBox(
                width: 316.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavIconButton(
                      asset: 'assets/images/icons/notification_btn.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const NotificationPage(),
                            transitionDuration: const Duration(milliseconds: 220),
                            reverseTransitionDuration: const Duration(milliseconds: 180),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(opacity: animation, child: child),
                          ),
                        );
                      },
                    ),
                    _NavIconButton(
                      asset: 'assets/images/icons/record_btn.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const RecordPage(),
                            transitionDuration: const Duration(milliseconds: 220),
                            reverseTransitionDuration: const Duration(milliseconds: 180),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(opacity: animation, child: child),
                          ),
                        );
                      },
                    ),
                    _NavIconButton(
                      asset: 'assets/images/icons/mypage_btn.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const MyPage(),
                            transitionDuration: const Duration(milliseconds: 220),
                            reverseTransitionDuration: const Duration(milliseconds: 180),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(opacity: animation, child: child),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChat() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/home/group_chat.png', width: 259.w),
          SizedBox(height: 38.h),
          Text(
            '비슷한 경험을 가진 사람들이 모여\n안전하게 대화할 수 있는 그룹 채팅입니다.',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'IBMPlexSansKR',
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/icons/15min.png', width: 136.w),
              SizedBox(width: 19.w),
              Image.asset('assets/images/icons/30min.png', width: 136.w),
            ],
          ),
        ],
      ),
    );
  }
}

  Widget _buildOneOnOneChat() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/home/one_on_one.png', width: 259.w),
          SizedBox(height: 38.h),
          Text(
            '전문 상담가와 깊은 대화를 나눠보세요.\n대화가 자동으로 정리되어 내담록으로 기록됩니다.',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'IBMPlexSansKR',
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 16.h),
          Image.asset('assets/images/icons/enter.png', width: 289.w),

        ],
      ),
    );
  }


class _NavIconButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  const _NavIconButton({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox.square(
        dimension: 44.w,
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}
