import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qr_type.dart';
import '../providers/qr_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dynamic_form.dart';
import '../widgets/qr_preview.dart';
import '../widgets/barcode_preview.dart';
import '../widgets/customization_panel.dart';
import '../widgets/export_options.dart';

class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  Widget _buildPreview(QrProvider provider) {
    if (provider.selectedType == QrDataType.barcode) {
      final code = provider.formData['code'] as String? ?? '';
      final barcodeType = provider.formData['barcodeType'] as String? ?? 'UPC-A';
      return BarcodePreviewWidget(
        code: code,
        type: barcodeType,
        barColor: provider.qrColor,
        backgroundColor: provider.backgroundColor,
      );
    }
    return QrPreviewWidget(
      data: provider.generatedData,
      qrColor: provider.qrColor,
      backgroundColor: provider.backgroundColor,
      size: provider.size,
      showLogo: provider.showLogo,
      logoBase64: provider.logoBase64,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QrProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (provider.selectedType == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pop(context));
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(provider.selectedType!.title),
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
            tooltip: 'الرئيسية',
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 768;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: SingleChildScrollView(child: const DynamicForm())),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildPreview(provider),
                          const SizedBox(height: 16),
                          const CustomizationPanel(),
                          const SizedBox(height: 16),
                          const ExportOptions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const DynamicForm(),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildPreview(provider),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CustomizationPanel(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ExportOptions(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInfo(BuildContext context) {
    final type = context.read<QrProvider>().selectedType;
    if (type == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(type!.icon, size: 20),
          const SizedBox(width: 8),
          Text(type.title),
        ]),
        content: Text('عند مسح هذا الرمز، سيقوم الهاتف بالإجراء المناسب:\n\n${_actionDescription(type)}'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('فهمت'))],
      ),
    );
  }

  String _actionDescription(QrDataType type) {
    return switch (type) {
      QrDataType.vcard => 'حفظ جهة اتصال جديدة في الهاتف بالبيانات المدخلة.',
      QrDataType.wifi => 'الاتصال بشبكة WiFi مباشرة دون إدخال كلمة السر.',
      QrDataType.whatsapp => 'فتح واتساب مع رسالة جاهزة للرقم المحدد.',
      QrDataType.sms => 'فتح تطبيق الرسائل مع نص جاهز.',
      QrDataType.email => 'فتح تطبيق البريد مع موضوع ونص جاهزين.',
      QrDataType.phone => 'فتح تطبيق الاتصال لبدء مكالمة.',
      QrDataType.website => 'فتح الرابط في المتصفح.',
      QrDataType.socialMedia => 'فتح الحساب في التطبيق أو المتصفح.',
      QrDataType.appStore => 'التوجيه إلى المتجر المناسب حسب نظام التشغيل.',
      QrDataType.googleReviews => 'فتح صفحة تقييم النشاط التجاري.',
      QrDataType.digitalMenu => 'فتح رابط القائمة الرقمية.',
      QrDataType.geoLocation => 'فتح الموقع في تطبيق الخرائط.',
      QrDataType.calendarEvent => 'إضافة الحدث إلى تقويم الهاتف.',
      QrDataType.paymentLink => 'فتح رابط الدفع.',
      QrDataType.cryptoWallet => 'فتح المحفظة الرقمية لتحويل العملة.',
      QrDataType.freeText => 'عرض النص بعد المسح.',
      QrDataType.totp => 'إضافة رمز المصادقة إلى تطبيق التوثيق.',
      QrDataType.barcode => 'مسح الرقم التسلسلي للمنتج.',
    };
  }
}
