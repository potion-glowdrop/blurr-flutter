# blurr : 흐려서 다시 그리는 마음의 공간 
<p align="center">
  <img src="thumbnail.png" width="70%">
</p>


- 🫥 익명으로 이야기할 수 있어요.
- 🎧 실시간 음성 변조로 목소리를 보호할 수 있어요.
- 🤖 AI 사회자가 대화를 안전하게 이끌어줘요.
- 🚨 위험 신호를 자동으로 감지할 수 있어요.
- 🎭 AR 필터로 부담 없이 참여할 수 있어요.

## ✨ Product Highlights
- AI 기반 익명 그룹 상담 플랫폼
  - 메타버스 아바타 + 실시간 음성 변조로 노출 걱정 없이 이야기할 수 있는 안전한 공간을 제공합니다.
- AI 사회자(Moderation Engine)
  - 발언 순서·시간·주제를 자동 관리하고 대화 흐름을 유지하는 AI 사회자가 세션 품질을 일정하게 보장합니다.
- 저마찰(Zero-friction) 정서 케어 루프
  - 익명 그룹 상담 → 1:1 전문가 매칭 → 위기 연결까지 한 앱 안에서 자연스럽게 이동할 수 있습니다.
- 한국어 기반 위기 감지 AI 탑재
  - 우울·자살 위험 점수를 실시간 산출하여 필요 시 서울시 자살예방센터(1393) 등 긴급기관 연결을 지원합니다.
- LiveKit / WebRTC 기반 초저지연 음성 세션
  - 다수 참여자의 음성을 안정적으로 동기화하고, DataChannel로 텍스트·이모티콘 반응까지 실시간 경험을 제공합니다.
- 온디바이스 안전성 강화
  - 위험 감지 모델(ONNX)을 로컬 실행해 네트워크와 무관하게 즉각적인 대응이 가능합니다.
- Flutter + Server-Driven Session Flow
  - 앱 단에서는 UI/로직을 단순화하고, 서버가 세션 상태(PREAMBLE → SPEAKING → INTERMISSION)를 권위적으로 동기화합니다.
 
## 🎬 시연 영상

[![Blurr Demo](thumbnail2.png)](https://youtu.be/f17hUKxD40I?si=QWGlzGnhmBqF4agV&t=48)

<p align="center">
  <a href="https://youtu.be/f17hUKxD40I?si=QWGlzGnhmBqF4agV&t=48">
    👉 동영상으로 시연 보기
  </a>
</p>

## 📁 Project Structure

```text
lib/
  main.dart
  config/
    routes.dart
    env.dart
  core/
    constants/
    utils/
  features/
    onboarding/
      onboarding_page.dart
    session/
      session_page.dart
      session_flow_controller.dart
      risk_detector_adapter.dart
    safety/
      safety_banner.dart
    auth/
      login_page.dart
      signup_page.dart
  services/
    livekit_service.dart
    stt_service.dart
    api_client.dart
  widgets/
    blurr_avatar.dart
    common_button.dart

assets/
  images/
  lottie/
  icons/

android/
ios/
web/
windows/

pubspec.yaml
README.md

