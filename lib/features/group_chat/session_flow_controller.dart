// lib/features/group_chat/session_flow_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

enum SessionStage { opening, prompt, answering, closing, done }

class SessionPlan {
  final List<String> prompts; // 질문 리스트
  final int openingSec;
  final int promptSec;   // 각 질문 공지 시간
  final int answerSec;   // 각 답변 시간
  final int closingSec;

  const SessionPlan({
    required this.prompts,
    this.openingSec = 15,
    this.promptSec = 15,
    this.answerSec = 40,
    this.closingSec = 15,
  });
}

class SessionFlowController {
  final List<String> _participants; // 표시 이름들 순서대로
  final SessionPlan plan;

  // 외부로 내보내는 상태 (UI 바인딩용)
  final ValueNotifier<SessionStage> stage = ValueNotifier(SessionStage.opening);
  final ValueNotifier<int> secondsLeft = ValueNotifier(0);
  final ValueNotifier<String> activeName = ValueNotifier(''); // 턴
  final ValueNotifier<String> infoText = ValueNotifier('');   // SessionInfoCard 텍스트
  final ValueNotifier<int> questionIndex = ValueNotifier(-1); // 현재 질문 idx

  Timer? _ticker;
  int _pIdx = 0;   // 현재 스피커 인덱스
  bool _running = false;

  SessionFlowController({
    required List<String> participants,
    required this.plan,
  }) : _participants = List.of(participants);

  List<String> get participants => List.unmodifiable(_participants);

  void start() {
    if (_running) return;
    _running = true;
    _goOpening();
  }

  void dispose() {
    _ticker?.cancel();
    stage.dispose();
    secondsLeft.dispose();
    activeName.dispose();
    infoText.dispose();
    questionIndex.dispose();
  }

  // ---- 외부 컨트롤 버튼 ----
  void skipToNextSpeaker() {
    if (stage.value == SessionStage.answering) {
      _goNextSpeakerOrNextPrompt();
    }
  }

  void extendAnswer(int extraSec) {
    if (stage.value == SessionStage.answering && secondsLeft.value > 0) {
      secondsLeft.value += extraSec;
    }
  }

  void endNow() => _goClosing(force: true);

  // ---- 내부 상태 전이 ----
  void _goOpening() {
    stage.value = SessionStage.opening;
    questionIndex.value = -1;
    infoText.value = '오프닝 멘트 시간입니다. 잠시 뒤 질문이 시작돼요.';
    _startCountdown(plan.openingSec, onDone: _goPromptFirst);
  }

  void _goPromptFirst() {
    _pIdx = 0;
    questionIndex.value = 0;
    _goPrompt();
  }

  void _goPrompt() {
    stage.value = SessionStage.prompt;
    final q = plan.prompts[questionIndex.value];
    infoText.value = '질문 ${questionIndex.value + 1}: $q';
    activeName.value = ''; // 프롬프트 동안엔 특정 발화자 없음
    _startCountdown(plan.promptSec, onDone: _goAnswering);
  }

  void _goAnswering() {
    stage.value = SessionStage.answering;
    // 현재 턴은 _pIdx
    final name = _participants[_pIdx];
    activeName.value = name;
    final q = plan.prompts[questionIndex.value];
    infoText.value = '질문 ${questionIndex.value + 1}에 대한 ${name}의 답변 시간입니다.';
    _startCountdown(plan.answerSec, onDone: _goNextSpeakerOrNextPrompt);
  }

  void _goNextSpeakerOrNextPrompt() {
    // 다음 스피커로 회전
    _pIdx++;
    if (_pIdx >= _participants.length) {
      // 다음 질문으로
      _pIdx = 0;
      if (questionIndex.value + 1 >= plan.prompts.length) {
        _goClosing();
      } else {
        questionIndex.value += 1;
        _goPrompt();
      }
    } else {
      _goAnswering();
    }
  }

  void _goClosing({bool force = false}) {
    stage.value = SessionStage.closing;
    activeName.value = '';
    infoText.value = '클로징 멘트 시간입니다. 오늘 대화 수고하셨어요.';
    _startCountdown(force ? 1 : plan.closingSec, onDone: () {
      stage.value = SessionStage.done;
      infoText.value = '세션이 종료되었습니다.';
      secondsLeft.value = 0;
      activeName.value = '';
      _ticker?.cancel();
    });
  }

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
