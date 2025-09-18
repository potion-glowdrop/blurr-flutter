import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AVPermissionGate extends StatefulWidget {
  final Widget child;
  const AVPermissionGate({super.key, required this.child});

  @override
  State<AVPermissionGate> createState() => _AVPermissionGateState();
}

class _AVPermissionGateState extends State<AVPermissionGate> {
  bool _checking = true;
  bool _requesting = false;
  bool _granted = false;
  bool _autoAsked = false;

  PermissionStatus? _cam;
  PermissionStatus? _mic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await _check();
    // ✅ 아직 미허용이면 자동으로 1회 요청
    if (!_granted && !_autoAsked) {
      _autoAsked = true;
      await _request();
    }
  }

  Future<void> _check() async {
    final cam = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    setState(() {
      _cam = cam;
      _mic = mic;
      _granted = cam.isGranted && mic.isGranted;
      _checking = false;
    });
    _debugPrint('check', cam, mic);
  }

  Future<void> _request() async {
    if (_requesting) return;
    setState(() => _requesting = true);

    final results = await [Permission.camera, Permission.microphone].request();
    final cam = results[Permission.camera];
    final mic = results[Permission.microphone];

    setState(() {
      _cam = cam;
      _mic = mic;
      _granted = (cam?.isGranted ?? false) && (mic?.isGranted ?? false);
      _requesting = false;
    });
    _debugPrint('request', cam, mic);
  }

  bool get _permanentlyBlocked =>
      (_cam?.isPermanentlyDenied ?? false) ||
      (_mic?.isPermanentlyDenied ?? false) ||
      (_cam?.isRestricted ?? false) ||
      (_mic?.isRestricted ?? false);

  void _debugPrint(String tag, PermissionStatus? cam, PermissionStatus? mic) {
    // 콘솔 확인용
    // ignore: avoid_print
    print('[AVPermissionGate/$tag] camera=$cam, mic=$mic, granted=$_granted');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        if (_checking || _requesting) ...[
          const ModalBarrier(dismissible: false, color: Colors.black26),
          const Center(child: CircularProgressIndicator()),
        ] else if (!_granted) ...[
          const ModalBarrier(dismissible: false, color: Colors.black38),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('권한이 필요합니다',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                        _permanentlyBlocked
                          ? '카메라/마이크 권한이 영구적으로 거부되어 시스템 팝업을 다시 띄울 수 없어요.\n앱 기능 사용을 위해 권한을 허용해 주세요.'
                          : '영상 상담을 위해 카메라와 마이크 권한이 필요합니다.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_permanentlyBlocked)
                            FilledButton(
                              onPressed: _request,
                              child: const Text('다시 요청'),
                            )
                          else
                            FilledButton.tonal(
                              onPressed: () {}, // 설정 이동을 원치 않는 요구사항에 따라 no-op
                              child: const Text('확인'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
