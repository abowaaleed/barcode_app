import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';

class QrPreviewWidget extends StatelessWidget {
  final String data;
  final Color qrColor;
  final Color backgroundColor;
  final double size;
  final bool showLogo;
  final String? logoBase64;

  const QrPreviewWidget({
    super.key,
    required this.data,
    this.qrColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.size = 200,
    this.showLogo = false,
    this.logoBase64,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A3A) : const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: size,
            eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: qrColor),
            dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: qrColor),
            backgroundColor: backgroundColor,
            embeddedImage: showLogo && logoBase64 != null
                ? MemoryImage(base64Decode(logoBase64!.split(',').last))
                : null,
            embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              Text('باركود جاهز للمسح', style: TextStyle(fontSize: 12,
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
