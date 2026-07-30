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
      return Container(
        height: size + 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary).withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_2, size: 48, color: (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary).withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              Text('املأ البيانات لإنشاء الرمز', style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary).withValues(alpha: 0.2)),
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
          Text('امسح الرمز للبدء', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
        ],
      ),
    );
  }
}
