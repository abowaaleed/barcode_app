import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/qr_provider.dart';
import '../services/qr_export.dart';
import '../theme/app_theme.dart';

class ExportOptions extends StatelessWidget {
  const ExportOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QrProvider>(
      builder: (ctx, provider, _) {
        if (provider.generatedData.isEmpty) return const SizedBox.shrink();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تصدير', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.saveToHistory();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ في السجل')));
                      },
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('حفظ في السجل'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        QrExport.downloadPng(
                          data: provider.generatedData,
                          qrColor: provider.qrColor,
                          backgroundColor: provider.backgroundColor,
                          size: provider.size.toInt(),
                          logoBase64: provider.showLogo ? provider.logoBase64 : null,
                        );
                      },
                      icon: const Icon(Icons.image, size: 18),
                      label: const Text('PNG'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        QrExport.downloadSvg(
                          data: provider.generatedData,
                          qrColor: provider.qrColor,
                          backgroundColor: provider.backgroundColor,
                        );
                      },
                      icon: const Icon(Icons.code, size: 18),
                      label: const Text('SVG'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
