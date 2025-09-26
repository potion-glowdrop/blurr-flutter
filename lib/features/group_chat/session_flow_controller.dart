// // lib/features/group_chat/session_flow_controller.dart
// import 'dart:async';
// import 'package:flutter/foundation.dart';

// enum SessionStage { opening, prompt, answering, closing, done }

// class SessionPlan {
//   final List<String> prompts; // 질문 리스트
//   final int openingSec;
//   final int promptSec;   // 각 질문 공지 시간
//   final int answerSec;   // 각 답변 시간
//   final int closingSec;

//   const SessionPlan({
//     required this.prompts,
//     this.openingSec = 15,
//     this.promptSec = 15,
//     this.answerSec = 40,
//     this.closingSec = 15,
//   });
// }

// class SessionFlowController {
//   final List<String> _participants; // 표시 이름들 순서대로
//   final SessionPlan plan;

//   // 외부로 내보내는 상태 (UI 바인딩용)
//   final ValueNotifier<SessionStage> stage = ValueNotifier(SessionStage.opening);
//   final ValueNotifier<int> secondsLeft = ValueNotifier(0);
//   final ValueNotifier<String> activeName = ValueNotifier(''); // 턴
//   final ValueNotifier<String> infoText = ValueNotifier('');   // SessionInfoCard 텍스트
//   final ValueNotifier<int> questionIndex = ValueNotifier(-1); // 현재 질문 idx

//   Timer? _ticker;
//   int _pIdx = 0;   // 현재 스피커 인덱스
//   bool _running = false;

//   SessionFlowController({
//     required List<String> participants,
//     required this.plan,
//   }) : _participants = List.of(participants);

//   List<String> get participants => List.unmodifiable(_participants);

//   void start() {
//     if (_running) return;
//     _running = true;
//     _goOpening();
//   }

//   void dispose() {
//     _ticker?.cancel();
//     stage.dispose();
//     secondsLeft.dispose();
//     activeName.dispose();
//     infoText.dispose();
//     questionIndex.dispose();
//   }

//   // ---- 외부 컨트롤 버튼 ----
//   void skipToNextSpeaker() {
//     if (stage.value == SessionStage.answering) {
//       _goNextSpeakerOrNextPrompt();
//     }
//   }

//   void extendAnswer(int extraSec) {
//     if (stage.value == SessionStage.answering && secondsLeft.value > 0) {
//       secondsLeft.value += extraSec;
//     }
//   }

//   void endNow() => _goClosing(force: true);

//   // ---- 내부 상태 전이 ----
//   void _goOpening() {
//     stage.value = SessionStage.opening;
//     questionIndex.value = -1;
//     infoText.value = '안녕하세요. 오늘 함께 자리해주셔서 반갑습니다.이 방은 ‘취업 스트레스와 마음건강’이라는 주제로, 서로의 경험을 나누는 시간이에요.여기서는 평가나 조언보다, 있는 그대로의 이야기를 존중하는 것이 가장 중요합니다.혹시 대답하기 어려운 질문이 나오면 ‘패스’하셔도 괜찮습니다.그럼 첫 번째 질문으로 시작해볼게요.';
//     _startCountdown(plan.openingSec, onDone: _goPromptFirst);
//   }

//   void _goPromptFirst() {
//     _pIdx = 0;
//     questionIndex.value = 0;
//     _goPrompt();
//   }

//   void _goPrompt() {
//     stage.value = SessionStage.prompt;
//     final q = plan.prompts[questionIndex.value];
//     infoText.value = '질문 ${questionIndex.value + 1}: $q';
//     activeName.value = ''; // 프롬프트 동안엔 특정 발화자 없음
//     _startCountdown(plan.promptSec, onDone: _goAnswering);
//   }

//   void _goAnswering() {
//     stage.value = SessionStage.answering;
//     // 현재 턴은 _pIdx
//     final name = _participants[_pIdx];
//     activeName.value = name;
//     final q = plan.prompts[questionIndex.value];
//     infoText.value = '질문 ${questionIndex.value + 1}에 대한 ${name}의 답변 시간입니다.';

//     // infoText.value = '질문 ${questionIndex.value + 1}에 대한 ${name}의 답변 시간입니다.';
//     _startCountdown(plan.answerSec, onDone: _goNextSpeakerOrNextPrompt);
//   }

//   void _goNextSpeakerOrNextPrompt() {
//     // 다음 스피커로 회전
//     _pIdx++;
//     if (_pIdx >= _participants.length) {
//       // 다음 질문으로
//       _pIdx = 0;
//       if (questionIndex.value + 1 >= plan.prompts.length) {
//         _goClosing();
//       } else {
//         questionIndex.value += 1;
//         _goPrompt();
//       }
//     } else {
//       _goAnswering();
//     }
//   }

//   void _goClosing({bool force = false}) {
//     stage.value = SessionStage.closing;
//     activeName.value = '';
//     infoText.value = '오늘 이렇게 함께 나눠주셔서 감사합니다.취업 스트레스는 누구에게나 무겁지만, 혼자가 아니라는 사실이 위로가 되길 바랍니다.서울시 청년 마음건강 지원사업처럼, 우리에게는 마음을 돌볼 수 있는 여러 통로가 있습니다.Blurr 또한 언제든 편히 머물 수 있는 공간이 되기를 바랍니다.오늘의 대화를 여기서 마무리하겠습니다.';
//     _startCountdown(force ? 1 : plan.closingSec, onDone: () {
//       stage.value = SessionStage.done;
//       infoText.value = '세션이 종료되었습니다.';
//       secondsLeft.value = 0;
//       activeName.value = '';
//       _ticker?.cancel();
//     });
//   }

//   void _startCountdown(int sec, {required VoidCallback onDone}) {
//     _ticker?.cancel();
//     secondsLeft.value = sec;
//     _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
//       final next = secondsLeft.value - 1;
//       secondsLeft.value = next;
//       if (next <= 0) {
//         t.cancel();
//         onDone();
//       }
//     });
//   }
// }
import 'dart:async';
import 'package:flutter/foundation.dart';

enum SessionStage { opening, prompt, answering, wrapup, closing, done }

class SessionPlan {
  // 질문 리스트
  final List<String> prompts;

  // Opening을 여러 파트로 나눠 순차 표시
  final List<String> openingParts;
  final int openingPartSec;

  // 각 질문 공지(프롬프트) 시간
  final int promptSec;

  // 각 답변 시간
  final int answerSec;

  // 각 질문이 끝난 뒤 Wrap-up 시간/문구 (질문별 개별 문구가 있으면 prompts 길이에 맞춰 전달)
  final int wrapupSec;
  final List<String>? wrapups;

  // 세션 종료 멘트 시간
  final int closingSec;

  const SessionPlan({
    required this.prompts,
    this.openingParts = const [],
    this.openingPartSec = 8,
    this.promptSec = 15,
    this.answerSec = 40,
    this.wrapupSec = 7,
    this.wrapups,
    this.closingSec = 15,
  });
}

class SessionFlowController {
  final List<String> _participants; // 표시 이름들 순서대로
  final SessionPlan plan;

  // 외부로 내보내는 상태 (UI 바인딩용)
  final ValueNotifier<SessionStage> stage = ValueNotifier(SessionStage.opening);
  final ValueNotifier<int> secondsLeft = ValueNotifier(0);
  final ValueNotifier<String> activeName = ValueNotifier(''); // 현재 턴 화자
  final ValueNotifier<String> infoText = ValueNotifier('');   // 상단 카드 텍스트
  final ValueNotifier<int> questionIndex = ValueNotifier(-1); // 현재 질문 idx

  Timer? _ticker;
  bool _running = false;

  // 내부 인덱스
  int _pIdx = 0;       // 현재 스피커 인덱스
  int _openIdx = 0;    // 오프닝 파트 인덱스

  SessionFlowController({
    required List<String> participants,
    required this.plan,
  }) : _participants = List.of(participants);

  List<String> get participants => List.unmodifiable(_participants);

  // ───────────────── start / dispose ─────────────────
  void start() {
    if (_running) return;
    _running = true;
    if (plan.openingParts.isEmpty) {
      _goPromptFirst();
    } else {
      _goOpeningPart(0);
    }
  }

  void dispose() {
    _ticker?.cancel();
    stage.dispose();
    secondsLeft.dispose();
    activeName.dispose();
    infoText.dispose();
    questionIndex.dispose();
  }

  // ───────────────── 외부 컨트롤 ─────────────────
  void skipToNextSpeaker() {
    if (stage.value == SessionStage.answering) {
      _goNextSpeakerOrWrapup();
    }
  }

  void extendAnswer(int extraSec) {
    if (stage.value == SessionStage.answering && secondsLeft.value > 0) {
      secondsLeft.value += extraSec;
    }
  }

  void endNow() => _goClosing(force: true);

  // ───────────────── 상태 전이 ─────────────────
  // Opening: 여러 파트를 순차적으로 보여준다.
  void _goOpeningPart(int idx) {
    stage.value = SessionStage.opening;
    questionIndex.value = -1;
    activeName.value = '';

    _openIdx = idx;
    infoText.value = plan.openingParts[idx];
    _startCountdown(plan.openingPartSec, onDone: () {
      final next = _openIdx + 1;
      if (next < plan.openingParts.length) {
        _goOpeningPart(next);
      } else {
        _goPromptFirst();
      }
    });
  }

  void _goPromptFirst() {
    _pIdx = 0;
    questionIndex.value = 0;
    _goPrompt();
  }

  void _goPrompt() {
    stage.value = SessionStage.prompt;
    activeName.value = ''; // 프롬프트 동안 특정 발화자 없음
    final q = plan.prompts[questionIndex.value];
    // ✅ 질문만 보여준다 (요구 3)
    infoText.value = '${questionIndex.value + 1}번째 질문입니다. $q';
    _startCountdown(plan.promptSec, onDone: _goAnswering);
  }
  //   void _goPrompt() {
  //   stage.value = SessionStage.prompt;
  //   activeName.value = '';

  //   final q = plan.prompts[questionIndex.value];
  //   infoText.value = q; // ✅ '질문 n:' 프리픽스 제거

  //   _startCountdown(plan.promptSec, onDone: _goAnswering);
  // }

  void _goAnswering() {
    stage.value = SessionStage.answering;
    final name = _participants[_pIdx];
    activeName.value = name;

    final q = plan.prompts[questionIndex.value];
    infoText.value = '$q $name님의 답변 차례입니다'; // ✅ 질문 + 순서 안내

    _startCountdown(plan.answerSec, onDone: _goNextSpeakerOrWrapup);
  }

  // 현재 질문에 대해 모든 스피커가 끝났으면 wrapup으로,
  // 아니면 다음 스피커로
  void _goNextSpeakerOrWrapup() {
    _pIdx++;
    if (_pIdx >= _participants.length) {
      _pIdx = 0;
      _goWrapupOrNextPrompt();
    } else {
      _goAnswering();
    }
  }

  void _goWrapupOrNextPrompt() {
    // 질문 종료 후 wrap-up 단계 → 다음 질문
    final hasWrap = plan.wrapupSec > 0;
    if (hasWrap) {
      _goWrapup();
    } else {
      _goNextPromptOrClosing();
    }
  }

  void _goWrapup() {
    stage.value = SessionStage.wrapup;
    activeName.value = '';

    final idx = questionIndex.value;
    final custom = (plan.wrapups != null && idx >= 0 && idx < plan.wrapups!.length)
        ? plan.wrapups![idx]
        : '지금까지 각자의 이야기를 잘 들었습니다. 방금 주제에서 느낀 포인트를 잠시 정리해볼게요.';

    infoText.value = custom;
    _startCountdown(plan.wrapupSec, onDone: _goNextPromptOrClosing);
  }

  void _goNextPromptOrClosing() {
    if (questionIndex.value + 1 >= plan.prompts.length) {
      _goClosing();
    } else {
      questionIndex.value += 1;
      _goPrompt();
    }
  }

  void _goClosing({bool force = false}) {
    stage.value = SessionStage.closing;
    activeName.value = '';
    infoText.value = '오늘 함께해주셔서 감사합니다. 혼자가 아니라는 사실을 기억하며, 여기서 얻은 따뜻함이 계속 이어지길 바랍니다.';
    _startCountdown(force ? 1 : plan.closingSec, onDone: () {
      stage.value = SessionStage.done;
      infoText.value = '세션이 종료되었습니다.';
      secondsLeft.value = 0;
      activeName.value = '';
      _ticker?.cancel();
    });
  }

  // ───────────────── 공통 타이머 ─────────────────
  void _startCountdown(int sec, {required VoidCallback onDone}) {
    _ticker?.cancel();
    secondsLeft.value = sec;
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = secondsLeft.value - 1;
      secondsLeft.value = next;
      if (next <= 0) {
        t.cancel();
        onDone();
      }
    });
  }
}
