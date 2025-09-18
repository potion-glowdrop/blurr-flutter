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
  bool _granted = false;
  bool _requesting = false;

  PermissionStatus? _cam;
  PermissionStatus? _mic;

  @override
  void initState() {
    super.initState();
    _check();
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
  }

  bool get _isPermanentlyBlocked {
    final c = _cam, m = _mic;
    return (c?.isPermanentlyDenied ?? false) ||
           (m?.isPermanentlyDenied ?? false) ||
           (c?.isRestricted ?? false) ||
           (m?.isRestricted ?? false);
  }

  @override
  Widget build(BuildContext context) {
    // child는 항상 그리되, 미허용 시 오버레이로 막음
    return Stack(
      children: [
        widget.child,

        if (_checking) ...[
          const ModalBarrier(dismissible: false, color: Colors.black26),
          const Center(child: CircularProgressIndicator()),
        ] else if (!_granted) ...[
          // 반투명 스크림 + 가운데 카드 (전부 앱 내에서 처리)
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
                        _isPermanentlyBlocked
                          ? '영상 상담을 위해 카메라/마이크 권한이 필요해요.\n현재 기기 설정에서 권한이 꺼져 있어, 이 화면에서 요청을 다시 띄울 수 없어요.'
                          : '영상 상담을 위해 카메라/마이크 권한을 허용해 주세요.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isPermanentlyBlocked)
                            FilledButton(
                              onPressed: _requesting ? null : _request,
                              child: _requesting
                                  ? const SizedBox(
                                      width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('권한 허용'),
                            )
                          else
                            FilledButton.tonal(
                              onPressed: () {}, // 설정으로 보내지 않음(요청대로)
                              child: const Text('확인'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          // "나중에" 동작이 필요 없다면 제거해도 됨
                          // 여기서는 단순히 스낵바만 보여주고 막아둠
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('권한 허용 전에는 기능을 사용할 수 없어요.')),
                          );
                        },
                        child: const Text('나중에'),
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
