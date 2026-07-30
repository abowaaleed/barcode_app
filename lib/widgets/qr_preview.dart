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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A3A) : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.qr_code_2, size: 48, color: AppColors.primary.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            Text('أدخل البيانات لمعاينة الباركود',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
            const SizedBox(height: 4),
            Text('سيظهر الرمز هنا فور إدخال المعلومات المطلوبة',
              style: TextStyle(fontSize: 11,
                color: (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary).withValues(alpha: 0.7))),
          ],
        ),
      );
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
