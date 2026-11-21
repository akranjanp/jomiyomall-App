import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final Color? backgroundColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          );

    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: content,
            )
          : ElevatedButton(
              style: backgroundColor != null
                  ? ElevatedButton.styleFrom(backgroundColor: backgroundColor)
                  : null,
              onPressed: isLoading ? null : onPressed,
              child: content,
            ),
    );
  }
}
