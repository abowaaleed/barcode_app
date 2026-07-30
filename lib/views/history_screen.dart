import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qr_type.dart';
import '../models/qr_history_item.dart';
import '../providers/qr_provider.dart';
import '../theme/app_theme.dart';
import 'form_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('السجل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, size: 20),
            onPressed: () {
              context.read<QrProvider>().clearHistory();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مسح السجل')));
            },
          ),
        ],
      ),
      body: Consumer<QrProvider>(
        builder: (ctx, provider, _) {
          if (provider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary).withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text('لا توجد رموز محفوظة', style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                  const SizedBox(height: 6),
                  Text('أنشئ رمزاً واحفظه ليظهر هنا', style: TextStyle(fontSize: 12, color: (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary).withValues(alpha: 0.7))),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.history.length,
            itemBuilder: (_, i) {
              final item = provider.history[i];
              return _HistoryCard(item: item, index: i);
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final QrHistoryItem item;
  final int index;

  const _HistoryCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.type.category == QrCategory.personal
                ? const Color(0xFF6C63FF).withValues(alpha: 0.15)
                : item.type.category == QrCategory.links
                    ? const Color(0xFF00D9A6).withValues(alpha: 0.15)
                    : item.type.category == QrCategory.locationEvents
                        ? const Color(0xFFFF6B6B).withValues(alpha: 0.15)
                        : item.type.category == QrCategory.financial
                            ? const Color(0xFFFFB347).withValues(alpha: 0.15)
                            : const Color(0xFF4FC3F7).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.type.icon, size: 20, color: isDark ? Colors.white70 : Colors.black54),
        ),
        title: Text(item.type.title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
        subtitle: Text(
          _previewData(item),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.refresh, size: 18, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
              onPressed: () {
                context.read<QrProvider>().restoreFromHistory(item);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FormScreen()));
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 18, color: AppColors.error),
              onPressed: () => context.read<QrProvider>().removeFromHistory(index),
            ),
          ],
        ),
      ),
    );
  }

  String _previewData(QrHistoryItem item) {
    return switch (item.type) {
      QrDataType.vcard => item.data['name'] as String? ?? '',
      QrDataType.wifi => item.data['ssid'] as String? ?? '',
      QrDataType.whatsapp => item.data['phone'] as String? ?? '',
      QrDataType.sms => item.data['phone'] as String? ?? '',
      QrDataType.email => item.data['email'] as String? ?? '',
      QrDataType.phone => item.data['phone'] as String? ?? '',
      QrDataType.website => item.data['url'] as String? ?? '',
      QrDataType.socialMedia => '${item.data['platform']}: ${item.data['username']}',
      QrDataType.appStore => 'تطبيق',
      QrDataType.googleReviews => item.data['placeId'] as String? ?? '',
      QrDataType.digitalMenu => item.data['url'] as String? ?? '',
      QrDataType.geoLocation => '${item.data['latitude']}, ${item.data['longitude']}',
      QrDataType.calendarEvent => item.data['title'] as String? ?? '',
      QrDataType.paymentLink => '${item.data['type']}: ${item.data['identifier']}',
      QrDataType.cryptoWallet => '${item.data['currency']}: ${item.data['address']?.substring(0, 10)}...',
      QrDataType.freeText => (item.data['text'] as String? ?? '').substring(0, 30),
      QrDataType.totp => item.data['account'] as String? ?? '',
      QrDataType.barcode => item.data['code'] as String? ?? '',
    };
  }
}
