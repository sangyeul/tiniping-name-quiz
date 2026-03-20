import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NetworkAlert extends StatefulWidget {
  final Widget child;

  const NetworkAlert({super.key, required this.child});

  @override
  State<NetworkAlert> createState() => _NetworkAlertState();
}

class _NetworkAlertState extends State<NetworkAlert> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.none) && mounted && !_shown) {
      _shown = true;
      _showOfflineAlert();
    }
  }

  void _showOfflineAlert() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: AppColors.error),
            SizedBox(width: 8),
            Text('오프라인'),
          ],
        ),
        content: const Text(
          '인터넷에 연결되어 있지 않습니다.\n'
          '퀴즈는 플레이 가능하지만, 정답 후 원본 이미지를 볼 수 없어요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('확인', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
