
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {


  Widget _tabContent() {
    return SizedBox(
      width: 327.w,
      height: 750.h,
      child: SingleChildScrollView(
        child:
        Column(
          children: [
            alert('2025. 09. 21.', '당신이 예약한 [관계 단절] 세션이 곧 시작돼요. 잠시 호흡을 정리하고 입장해볼까요?'),
            alert('2025. 09. 21.', '상담 전환을 희망하셨나요? 당신의 이야기 흐름을 이해하는 상담사를 추천드릴게요.' ),
            alert('2025. 09. 19.', '상담사를 매칭해드렸어요. 첫 만남을 원하시면 [예약하기]를 눌러주세요.'),
            alert('2025. 09. 19.', '당신의 말이 ‘바람’ 님에게 큰 위로가 되었대요. 서로를 지지해주셔서 감사합니다.'),
            alert('2025. 09. 19.', '당신이 공유한 경험에 [따뜻해요💛] 이모티콘이 5개 도착했어요.'),
            alert('2025. 09. 19.', '지난 그룹 세션 내용을 기반으로 매칭 가능한 상담사가 있습니다. 확인해보세요.'),
            alert('2025. 09. 19.', '아직 참여하지 않은 세션이 있어요. 새로운 이야기들이 기다리고 있어요. 지금 입장해보세요!'),
            alert('2025. 09. 19.', '[구직 스트레스] 서포트 그룹 세션이 30분 뒤에 시작돼요. 오늘도 함께할 준비 되셨나요?'),
            alert('2025. 09. 19.', '[Blurr] 오늘 오전 9시에 ‘1인 가구 외로움’ 주제 세션이 열려요. 관심 있으신가요?'),
            alert('2025. 09. 19.', '[안전 안내] 심야에는 감정 기복이 더 커질 수 있어요. 어려움이 있다면 1393을 누르시면 됩니다.'),
            alert('2025. 09. 19.', '당신의 말에 힘이 담겨 있었어요. 혹시 누군가가 걱정된다면 알려주세요. 함께 할 수 있어요.'),
            alert('2025. 09. 19.', '[주의] 최근 대화 중 감정 기복이 급격히 감지되었어요. 괜찮으신가요? 필요시 바로 도움을 요청하세요.'),
            alert('2025. 09. 19.', '‘나비’ 님이 당신의 이야기에 큰 공감을 보냈어요.'),

            ],
          
        )
      ),
    );
  }

  Widget alert(String date, String contents
  ){
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 15.w),
          decoration: BoxDecoration(color: Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(12.w)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date,style: TextStyle(fontSize: 12.sp, color: Color(0xFF616161), fontWeight: FontWeight.w500 ) ),
              SizedBox(height: 5.h,),
              Text(contents, style: TextStyle(fontSize: 14.sp, fontFamily: 'IBMPlexSansKR', color: Color(0xFF000000), fontWeight: FontWeight.w300),),
 
            ],

          ),

        ),
        SizedBox(height: 20.h,),

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
                  Text('알림',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'IBMPlexSansKR',
                      )),
                  SizedBox(height: 14.h),
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
