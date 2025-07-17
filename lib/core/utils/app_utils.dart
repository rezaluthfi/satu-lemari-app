import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_colors.dart';

class AppUtils {
  // Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Add +62 prefix if starts with 0
    if (digits.startsWith('0')) {
      digits = '62${digits.substring(1)}';
    }

    // Add + prefix if not present
    if (!digits.startsWith('62')) {
      digits = '62$digits';
    }

    return '+$digits';
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  // Validate password strength
  static bool isStrongPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$')
        .hasMatch(password);
  }

  // Get connection type
  static String getConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Generate random string
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(
          (chars.length * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)
              .floor(),
        ),
      ),
    );
  }

  // Debounce function
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback,
      {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }
}
