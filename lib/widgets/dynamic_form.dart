import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qr_type.dart';
import '../providers/qr_provider.dart';
import '../theme/app_theme.dart';

class DynamicForm extends StatelessWidget {
  const DynamicForm({super.key});

  @override
  Widget build(BuildContext context) {
    final type = context.watch<QrProvider>().selectedType;
    if (type == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code, size: 64, color: AppColors.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('اختر نوع البيانات من القائمة',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.05)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(type.icon, size: 24, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.lightTextPrimary)),
                  const SizedBox(height: 2),
                  Text(type.subtitle,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
