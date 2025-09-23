import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupDone extends StatelessWidget {
  const GroupDone({super.key});

  


  @override
  Widget build(BuildContext context) {
    const String kSummary =
      "증상: 가슴 답답, 집중 끊김, 퇴근 후 무기력\n트리거: 즉시답변 요구, 동시다발 호출, 우선순위 불명확\n자동사고: “내가 늦으면 민폐다”\n영향: 작업 지연·야근 반복, 수면 5–6시간\n대응/계획: 오늘 상위 3개만 처리 / 20시 이후 슬랙·이메일 알림 OFF / 비긴급 요청은 ‘답변 예정 시간’ 템플릿";

    const String kReflection =
      "문제는 능력이 아니라 경계의 부재였다는 걸 확인. 일을 내가 정한 속도로 돌리니 불안이 가라앉고 숨이 길어졌다. ‘천천히, 그러나 꾸준히’가 내 페이스.";

    return Scaffold(
      body: Stack(
        children: [
          // 배경
          Positioned.fill(
            child: Image.asset(
              'assets/illustrations/one_on_one_bgd.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 131.h,
            left: 23.w,
            child: Text('오늘의 세션 완료!', style: TextStyle(fontFamily: 'IBMPlexSansKR', fontSize: 40.sp, fontWeight: FontWeight.w200, color: Color(0xFF000000)),),),

          Positioned(
            top: 211.h,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Image.asset('assets/images/group/wrap-up.png', width: 313.w,),
                      // Positioned(
                      //   top: 60.h,
                      //   left: 0,
                      //   right: 0,
                      //   child: Center(child: SizedBox(width: 253.w, height: 168.h, child: Text(kSummary),)))
                    ],
                  ),
                  SizedBox(height: 10.h,),
                  Stack(
                    children: [
                      Image.asset('assets/images/group/reflection.png', width: 325.w,),
                      Positioned(
                        top: 65.h,
                        left: -15.w,
                        right: 0,
                        child: Center(child: SizedBox(width: 253.w, height: 168.h, child: Text(kReflection),)))
                    ],
                  )

                ],
              ),
            )),
          

          Positioned(bottom:55.h, left:0, right: 0,
          child: Center(child: GestureDetector(
                            onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
            child: Image.asset('assets/images/one_on_one/return.png', width: 299.w,)))),
          

  

          // 뒤로가기 버튼
          Positioned(
            left: -10.w,
            top: 35.h,
            width: 85.w,
            height: 86.5.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                customBorder: const CircleBorder(),
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Image.asset('assets/images/icons/exit.png', fit: BoxFit.contain),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
