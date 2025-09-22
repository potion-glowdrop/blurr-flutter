// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class RecordPage extends StatelessWidget {
//   const RecordPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // 배경
//           Positioned.fill(
//             child: Image.asset(
//               'assets/illustrations/widget_background.png',
//               fit: BoxFit.cover,
//             ),
//           ),

//           // 뒤로가기 버튼
//           Positioned(
//             left: 23.w,   // ← ScreenUtil은 w/h 반대로 쓰지 않도록 주의!
//             top: 53.h,
//             child: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: SizedBox(
//                 width: 44.w,
//                 height: 44.w,
//                 child: Image.asset(
//                   'assets/images/icons/back_btn.png',
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 미니 달력 (312.w x 279.h 안에 들어가도록 구성)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiniCalendar extends StatefulWidget {
  const MiniCalendar({
    super.key,
    this.month,                // 표시할 달(기본: 이번 달)
    this.initialSelectedDate,  // 초기 선택 날짜
    this.onSelected,
    this.minYear,
    this.maxYear,
  });

  final DateTime? month;
  final DateTime? initialSelectedDate;
  final ValueChanged<DateTime>? onSelected;
  final int? minYear; // 기본: 현재연도-5
  final int? maxYear; // 기본: 현재연도+5

  @override
  State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> {
  static const _brandBlue = Color(0xFF2BACFF);

  late DateTime _month; // 항상 1일로 고정된 달 기준
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = widget.month != null
        ? DateTime(widget.month!.year, widget.month!.month, 1)
        : DateTime(now.year, now.month, 1);
    _selected = widget.initialSelectedDate;
  }

  int _daysInMonth(DateTime m) => DateTime(m.year, m.month + 1, 0).day;
  int _startOffsetSundayFirst(DateTime m) {
    final w = DateTime(m.year, m.month, 1).weekday; // Mon=1..Sun=7
    return w % 7; // Sun=0, Mon=1..Sat=6
  }

  void _setMonth(int year, int month) {
    final clampedMonth = month.clamp(1, 12);
    final next = DateTime(year, clampedMonth, 1);

    // 선택된 날짜가 새 달에 유효하지 않으면 마지막 날로 클램프
    if (_selected != null && (_selected!.year != year || _selected!.month != clampedMonth)) {
      final last = _daysInMonth(next);
      _selected = DateTime(year, clampedMonth, _selected!.day.clamp(1, last));
    }
    setState(() => _month = next);
  }

  void _addMonths(int delta) {
    _setMonth(_month.year, _month.month + delta);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final minY = widget.minYear ?? (now.year - 5);
    final maxY = widget.maxYear ?? (now.year + 5);

    final days = _daysInMonth(_month);
    final offset = _startOffsetSundayFirst(_month);

    // ===== 레이아웃 치수 =====
    final totalH = 279.h;
    final header1H = 36.h; // 년/월 드롭다운 바
    final gap1 = 8.h;
    final dowHeaderH = 24.h; // 요일 헤더
    final gap2 = 6.h;
    final rowH = ((totalH - header1H - gap1 - dowHeaderH - gap2) / 6).floorToDouble();

    final textBase = TextStyle(
      fontFamily: 'IBMPlexSansKR',
      color: Colors.black,
      height: 1.0,
    );

    return Container(
      width: 312.w,
      height: totalH,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      child: Column(
        children: [
          // ================== 상단: 월/년 드롭다운 + 좌우 화살표 ==================
          SizedBox(
            height: header1H,
            child: Row(
              children: [
                SizedBox(width: 10.w,),
                // 월 드롭다운 (1월~12월)
                _MonthDropdown(
                  value: _month.month,
                  onChanged: (m) => _setMonth(_month.year, m),
                  textStyle: textBase.copyWith(fontWeight: FontWeight.w500, fontSize: 16.sp),
                ),
                SizedBox(width: 5.w),
                // 년 드롭다운
                _YearDropdown(
                  value: _month.year,
                  min: minY,
                  max: maxY,
                  onChanged: (y) => _setMonth(y, _month.month),
                  textStyle: textBase.copyWith(fontWeight: FontWeight.w500, fontSize: 16.sp),
                ),
                const Spacer(),
                _NavButton(icon: Icons.chevron_left, onTap: () => _addMonths(-1)),
                SizedBox(width: 4.w),
                _NavButton(icon: Icons.chevron_right, onTap: () => _addMonths(1)),
              ],
            ),
          ),

          SizedBox(height: gap1),

          // ================== 요일 헤더 ==================
          SizedBox(
            height: dowHeaderH,
            child: Row(
              children: List.generate(7, (i) {
                final names = const ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
                final isSun = i == 0, isSat = i == 6;
                return Expanded(
                  child: Center(
                    child: Text(
                      names[i],
                      style: textBase.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: (isSun || isSat) ? _brandBlue : const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: gap2),

          // ================== 날짜 그리드 ==================
          Expanded(
            child: Column(
              children: List.generate(6, (row) {
                return SizedBox(
                  height: rowH,
                  child: Row(
                    children: List.generate(7, (col) {
                      final cell = row * 7 + col;      // 0..41
                      final dayNum = cell - offset + 1; // 1..days
                      final inMonth = dayNum >= 1 && dayNum <= days;

                      if (!inMonth) return const Expanded(child: SizedBox.expand());

                      final date = DateTime(_month.year, _month.month, dayNum);
                      final isSelected = _selected != null &&
                          _selected!.year == date.year &&
                          _selected!.month == date.month &&
                          _selected!.day == date.day;

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() => _selected = date);
                            widget.onSelected?.call(date);
                          },
                          child: Center(
                            child: Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: isSelected
                                  ? BoxDecoration(
                                      color: _brandBlue,
                                      borderRadius: BorderRadius.circular(8.r),
                                    )
                                  : null,
                              alignment: Alignment.center,
                              child: Text(
                                '$dayNum',
                                style: textBase.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: isSelected?FontWeight.w600:FontWeight.w300,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── sub-widgets ───────────────────────────

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Icon(icon, size: 20.sp, color: Colors.white),
        ),
      ),
    );
  }
}

class _MonthDropdown extends StatelessWidget {
  const _MonthDropdown({
    required this.value,
    required this.onChanged,
    required this.textStyle,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(12, (i) {
      final m = i + 1;
      return DropdownMenuItem<int>(
        value: m,
        child: Text('$m월', style: textStyle),
      );
    });

    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: value,
        items: items,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 18.sp),
        dropdownColor: Colors.white,
        style: textStyle,
      ),
    );
  }
}

class _YearDropdown extends StatelessWidget {
  const _YearDropdown({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.textStyle,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (int y = min; y <= max; y++)
        DropdownMenuItem<int>(
          value: y,
          child: Text('$y년', style: textStyle),
        )
    ];

    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: value,
        items: items,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 18.sp),
        dropdownColor: Colors.white,
        style: textStyle,
      ),
    );
  }
}

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  int _currentTab = 0; // 0: 그룹 상담, 1: 내담록

  Widget _toggleButton({
    required String label,
    required int index,
  }) {
    final bool selected = _currentTab == index;
    return InkWell(
      onTap: () => setState(() => _currentTab = index),
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            selected
                ? 'assets/images/icons/toggle_btn_selected.png'
                : 'assets/images/icons/toggle_btn_unselected.png',
            width: 101.w,
            fit: BoxFit.fill,
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSansKR',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: selected ? const Color(0xFF17A1FA) : const Color(0xFF616161),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabContent() {
    return SizedBox(
      width: 327.w,
      // height: 663.h,
      child: SingleChildScrollView(
        child: _currentTab == 0?Column(
          children: [
            alert(),
            alert(),
            alert(),
            alert(),
            alert(),
            alert(),

            ],
          
        ):Column(
          children: [
            //calendar
            Container(
              width: 312.w,
              height: 294.h,
              child: MiniCalendar(
                month: DateTime(2025, 4, 1),               // 특정 달을 보려면 지정
                // initialSelectedDate: DateTime(2025, 4, 13), // 초기 선택
              ),
            ),
            SizedBox(height: 30.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 146.w,
                  height: 97.h,
                  // padding: EdgeInsets.only(top: 15.h, left: 12.w, right: 12.w, bottom: 21.h),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(center: Alignment.center, radius: 1.0, colors: [Color.fromRGBO(255, 255, 255, 1.0), 
                    Color.fromRGBO(255, 255, 255, 0.7)
                    ],
                    stops: [0.71, 1.0]
                    ),
                    boxShadow: [BoxShadow(color: Color(0xFFCBCBCB).withAlpha(45), offset: Offset(1, 1), blurRadius: 4.w)
                    ],
                    borderRadius: BorderRadius.circular(12.w)                    
                              ),
                  child: Stack(
                    children: [
                  Positioned(
                      top: 15.h,
                      left: 12.w,
                      child:
                      Text('이번 달 상담 빈도', style: TextStyle(fontSize: 14.sp, fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w300),)
                    ),
                    Positioned(
                      left: 13.w,
                      bottom: 6.h,
                      child: Text('3', style: TextStyle(fontSize: 40.sp, color: Color(0xFF17A1FA), fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w200))),
                    Positioned(
                      left: 39.w,
                      bottom: 20.h,
                      child: Text('일', style: TextStyle(fontSize: 10.sp, color: Color(0xFF000000), fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w200)))

                    ],
                  ),
                ),
                                Container(
                  width: 146.w,
                  height: 97.h,
                  // padding: EdgeInsets.only(top: 15.h, left: 12.w, right: 12.w, bottom: 21.h),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(center: Alignment.center, radius: 1.0, colors: [Color.fromRGBO(255, 255, 255, 1.0), 
                    Color.fromRGBO(255, 255, 255, 0.7)
                    ],
                    stops: [0.71, 1.0]
                    ),
                    boxShadow: [BoxShadow(color: Color(0xFFCBCBCB).withAlpha(45), offset: Offset(1, 1), blurRadius: 4.w)
                    ],
                    borderRadius: BorderRadius.circular(12.w)                    
                              ),
                  child: Stack(
                    children: [
                  Positioned(
                      top: 15.h,
                      left: 12.w,
                      child:
                      Text('누적 상담 회차', style: TextStyle(fontSize: 14.sp, fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w300),)
                    ),
                    Positioned(
                      left: 13.w,
                      bottom: 6.h,
                      child: Text('9', style: TextStyle(fontSize: 40.sp, color: Color(0xFF17A1FA), fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w200))),
                    Positioned(
                      left: 39.w,
                      bottom: 20.h,
                      child: Text('회', style: TextStyle(fontSize: 10.sp, color: Color(0xFF000000), fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w200)))

                    ],
                  ),
                ),


              ],
            ),
            SizedBox(height: 20.h,),
                                Container(
                  width: double.infinity,
                  height: 97.h,
                  // padding: EdgeInsets.only(top: 15.h, left: 12.w, right: 12.w, bottom: 21.h),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(center: Alignment.center, radius: 1.0, colors: [Color.fromRGBO(255, 255, 255, 1.0), 
                    Color.fromRGBO(255, 255, 255, 0.7)
                    ],
                    stops: [0.71, 1.0]
                    ),
                    boxShadow: [BoxShadow(color: Color(0xFFCBCBCB).withAlpha(45), offset: Offset(1, 1), blurRadius: 4.w)
                    ],
                    borderRadius: BorderRadius.circular(12.w)                    
                              ),
                  child: Stack(
                    children: [
                  Positioned(
                      top: 15.h,
                      left: 12.w,
                      child:
                      Text('누적 상담 시간', style: TextStyle(fontSize: 14.sp, fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w300),)
                    ),
                    Positioned(
                      left: 13.w,
                      bottom: 6.h,
                      child: Text('8', style: TextStyle(fontSize: 40.sp, color: Color(0xFF17A1FA), fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w200))),
                    Positioned(
                      left: 39.w,
                      bottom: 20.h,
                      child: Text('시간', style: TextStyle(fontSize: 10.sp, color: Color(0xFF000000), fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w200))),
                    Positioned(
                      left: 71.w,
                      bottom: 6.h,
                      child: Text('53', style: TextStyle(fontSize: 40.sp, color: Color(0xFF17A1FA), fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w200))),
                    Positioned(
                      left: 119.w,
                      bottom: 20.h,
                      child: Text('분', style: TextStyle(fontSize: 10.sp, color: Color(0xFF000000), fontFamily: 'IBMPlexSansKR', fontWeight: FontWeight.w200)))


                    ],
                  ),
                ),



          ],
        ),
      ),
    );
  }

  Widget alert(){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 12.w,),
            Text('2025. 09. 22.',style: TextStyle(fontSize: 12.sp, color: Color(0xFF616161) ) ),
          ],
        ),
        SizedBox(height: 4.h,),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 15.w),
          decoration: BoxDecoration(color: Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(12.w)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('혼자라는 느낌', style: TextStyle(fontSize: 14.sp, fontFamily: 'IBMPlexSansKR', color: Color(0xFF75A97A), fontWeight: FontWeight.w400),),
              SizedBox(height: 5.h,),
              Text('22:31', style: TextStyle(fontSize: 14.sp, fontFamily: 'IBMPlexSansKR', color: Color(0xFF797979), fontWeight: FontWeight.w500),),
              SizedBox(height: 30.h,),
              Text('오늘 다른 사람들의 이야기를 들으며, 나도 혼자가 아니라는 걸 느꼈다. 조금은 마음이 가벼워졌다.', style: TextStyle(fontSize: 14.sp, fontFamily: 'IBMPlexSansKR', color: Color(0xFF000000), fontWeight: FontWeight.w300),),
            ],
          ),
        ),
        SizedBox(height: 8.h,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 12.w,),
            Text('이 주제로 지금까지 3번 참여했어요 !',style: TextStyle(fontSize: 12.sp, color: Color(0xFFA3A3A3,), fontWeight: FontWeight.w600 ) ),
          ],
        ),
        SizedBox(height: 22.h,),

      ],
    );
  }

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

          // 상단 타이틀 + 토글 + 탭 콘텐츠
          Positioned(
            top: 96.h,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('기록',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'IBMPlexSansKR',
                      )),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _toggleButton(label: '그룹 상담', index: 0),
                      SizedBox(width: 8.w),
                      _toggleButton(label: '내담록', index: 1),
                    ],
                  ),
                  SizedBox(height: 30.h,),
                  _tabContent(),
                ],
              ),
            ),
          ),

          // 뒤로가기 버튼
          Positioned(
            left: 23.w,
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
