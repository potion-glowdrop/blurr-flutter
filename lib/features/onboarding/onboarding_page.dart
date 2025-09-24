import 'package:blurr/api/member_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../home/home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageCtrl = PageController();
  int _page = 0;

  // 폼 상태 (현재 닉네임/동의 페이지는 비활성화 상태라 유지만)
  final _formKey = GlobalKey<FormState>();
  final _nickCtrl = TextEditingController();
  String? _gender;
  String? _region; // ex) 서울특별시
  bool _agree = false;
  String? _age;
  String? _story;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nickCtrl.dispose();
    super.dispose();
  }

  void _goNext(int lastIndex) {
    if (_page < lastIndex) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() {
    _finish();
  }
Future<void> _finish() async {
  final nickname = _nickCtrl.text.trim().isEmpty ? '익명' : _nickCtrl.text.trim();
  final gender = _gender ?? '밝히고 싶지 않음';
  final age = _age ?? '20대';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // ✅ X-Client-Id 준비(캐시/생성)
    await MemberApi.I.prepare();

    final registered = await MemberApi.I.isRegistered();
    if (!registered) {
      await MemberApi.I.register(
        genderKo: gender,
        ageKo: age,
        nickname: nickname,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // 로딩 닫기
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainContentPage()),
    );
  } catch (e) {
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('회원 처리 중 오류가 발생했어요: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _IntroPage(),
      _IntroPage2(),
      _IntroPage3(),
      _IntroPage4(),
      _GenderPage(
        selected: _gender,
        onSelect: (v) => setState(() => _gender = v), // ✅ 괄호 오타 수정
      ),
      _AgePage(
        selected: _age,
        onSelect: (v) => setState(() => _age = v),
      ),
      _StoryPage(
        selected: _story,
        onSelect: (v) => setState(() => _story = v),
      ),
      _IntroPage5(),
      // _RegionPage(
      //   value: _region,
      //   onChanged: (v) => setState(() => _region = v),
      // ),
      // _ConsentPage(
      //   value: _agree,
      //   onChanged: (v) => setState(() => _agree = v),
      // ),
    ];
    final lastIndex = pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/illustrations/onboarding_bgd.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // 상단 스킵
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: _skip,
                        child: const Text('건너뛰기', style: TextStyle(color: Color(0xFFFFFFFF)),),
                      ),
                    ],
                  ),
                ),
                // 본문
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: pages,
                  ),
                ),
                // 인디케이터
                _PageDots(current: _page, total: pages.length),
                const SizedBox(height: 12),
                // 하단 네비게이션 (필요 최소만 복구)

                // 하단 네비게이션
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Row(
                    children: [
                      if (_page > 0)
                        OutlinedButton(
                          // (이전 버튼 스타일 동일)
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: const Color(0xFF9F9F9F),
                            side: const BorderSide(color: Colors.transparent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () => _pageCtrl.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          ),
                          child: const Text('이전', style: TextStyle(fontFamily: 'IBMPlexSans', color: Color(0xFFFAFBF1))),
                        )
                      else
                        const SizedBox(width: 80),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xFF9F9F9F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          // 아이콘은 고정 크기라면 패딩을 조금 줄이는 게 보기 좋아요
                          padding: EdgeInsets.symmetric(horizontal: _page < lastIndex ? 12 : 20, vertical: 12),
                        ),
                        onPressed: () => _goNext(lastIndex),
                        child: _page < lastIndex
                            ?SizedBox(
                              width: 44.w,
                              height: 44.w,
                              child: OverflowBox(
                                maxHeight: 105.w,
                                maxWidth: 105.h,
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(10.w),
                                  child: Image.asset(
                                      'assets/images/icons/next.png',
                                      width: 105.w, // 필요에 맞게 조정 (예: 24.w) // 필요에 맞게 조정 (예: 24.h)
                                      // semanticLabel: '다음', // 접근성 필요시
                                    ),
                                ),
                              ),
                            )
                            : const Text('완료', style: TextStyle(fontFamily: 'IBMPlexSans')),
                      ),
                    ],
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

/// 0. 인트로
class _IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Text(
              '환영합니다 👋',
              style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w500, fontFamily: 'IBMPlexSansKR', color: Color(0xFF606E5C)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Text(
              'Blurr은 서로의 상처를\n보듬고, 지워주는 공간입니다.',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, fontFamily: 'IBMPlexSansKR', color: Color(0xFF606E5C)),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Text(
              '지금부터, \n당신의 이야기를 듣고자해요.',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, fontFamily: 'IBMPlexSansKR', color: Color(0xFF606E5C)),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Text(
              '천천히,\n마음 가는 대로,\n답해 주세요.',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, fontFamily: 'IBMPlexSansKR', color: Color(0xFF606E5C)),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Text(
              '지금부터 당신을\n위한 공간을\n준비해드릴게요.',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, fontFamily: 'IBMPlexSansKR', color: Color(0xFF606E5C)),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderPage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _GenderPage({super.key, required this.selected, required this.onSelect});

  static const _choices = ['여성', '남성', '밝히고 싶지 않음'];
  static const _primary = Color(0xFF17A1FA);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 100.h),
            Text(
              '당신의 성별을 알려주세요.',
              style: TextStyle(
                fontFamily: 'IBMPlexSansKR',
                fontSize: 32.sp,
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 83.h),
            ..._choices.map((label) {
              final isSelected = label == selected;
              return Padding(
                padding: EdgeInsets.only(bottom: 23.h),
                child: _SelectableTile(
                  label: label,
                  selected: isSelected,
                  onTap: () => onSelect(label),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _AgePage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _AgePage({super.key, required this.selected, required this.onSelect});

  static const _choices = ['10대', '20대', '30대', '40대', '50대 이상'];
  static const _primary = Color(0xFF17A1FA);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 100.h),
            Text(
              '당신의 나이를 알려주세요.',
              style: TextStyle(
                fontFamily: 'IBMPlexSansKR',
                fontSize: 32.sp,
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 83.h),
            ..._choices.map((label) {
              final isSelected = label == selected;
              return Padding(
                padding: EdgeInsets.only(bottom: 23.h),
                child: _SelectableTile(
                  label: label,
                  selected: isSelected,
                  onTap: () => onSelect(label),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _StoryPage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _StoryPage({super.key, required this.selected, required this.onSelect});

  static const _choices = [
    '외로움을 자주 느껴요', // ✅ 오탈자 수정
    '금연하고싶어요',
    '학교에 가기 싫어요',
    '정체성이 혼란스러워요',
    '요즘 힘든 일이 있어요',
  ];
  static const _primary = Color(0xFF17A1FA);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 60.h),
            SizedBox(
              width: 353.w,
              child: Text(
                '당신의 이야기를\n듣고싶어요.',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansKR',
                  fontSize: 32.sp,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: 353.w,
              child: Text(
                '다른 사람들과 어떤 이야기를 나누고 싶나요?\n상담받고 싶은 주제가 없다면 추가해주세요.',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'IBMPlexSansKR',
                  color: const Color(0xFF515151),
                ),
              ),
            ),
            SizedBox(height: 41.h),
            ..._choices.map((label) {
              final isSelected = label == selected;
              return Padding(
                padding: EdgeInsets.only(bottom: 23.h),
                child: _SelectableTile(
                  label: label,
                  selected: isSelected,
                  onTap: () => onSelect(label),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SelectableTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _primary = Color(0xFF17A1FA);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.w),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 351.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(22.w),
            border: Border.all(
              color: selected ? _primary : Colors.transparent,
              width: selected ? 2 : 0,
            ),
            boxShadow: [
              BoxShadow(
                offset: const Offset(1, 1),
                color: const Color(0xFF000000).withAlpha(25),
                blurRadius: 4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'IBMPlexSansKR',
              color: selected ? _primary : const Color(0xFF000000),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int current;
  final int total;
  const _PageDots({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == current ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == current ? Colors.white : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
