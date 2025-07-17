import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/constants/app_colors.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final Widget? offlineWidget;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.offlineWidget,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      return;
    }

    if (!mounted) return;
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _connectionStatus = result;
    });
  }

  bool get _isOffline {
    return _connectionStatus.isEmpty ||
        _connectionStatus.every((result) => result == ConnectivityResult.none);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline) widget.offlineWidget ?? _buildOfflineIndicator(),
      ],
    );
  }

  Widget _buildOfflineIndicator() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: AppColors.error,
        padding: const EdgeInsets.all(8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              'Tidak ada koneksi internet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
