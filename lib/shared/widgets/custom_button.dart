import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: _getTextColor(),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w600,
        color: _getTextColor(),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.secondary,
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ButtonType.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          foregroundColor: textColor ?? AppColors.primary,
          elevation: 0,
          side: BorderSide(
            color: borderColor ?? AppColors.primary,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ButtonType.text:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          foregroundColor: textColor ?? AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
    }
  }

  Color _getTextColor() {
    if (textColor != null) return textColor!;

    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return Colors.white;
      case ButtonType.outline:
      case ButtonType.text:
        return AppColors.primary;
    }
  }
}
