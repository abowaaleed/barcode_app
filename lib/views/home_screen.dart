import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../models/qr_type.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import 'type_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _categories = QrCategory.values;

  static const _colors = [
    Color(0xFF6C63FF),
    Color(0xFF00D9A6),
    Color(0xFFFF6B6B),
    Color(0xFFFFB347),
    Color(0xFF4FC3F7),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('مولّد الباركود الذكي'),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? AppColors.warning : AppColors.lightTextSecondary),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحباً بك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
            const SizedBox(height: 4),
            Text('اختر نوع البيانات التي تريد تحويلها إلى رمز', style: TextStyle(fontSize: 14, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
            const SizedBox(height: 24),
            ...List.generate(_categories.length, (i) {
              final cat = _categories[i];
              final types = QrDataType.values.where((t) => t.category == cat).toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CategoryCard(
                  icon: cat.icon,
                  title: cat.title,
                  subtitle: '${types.length} أنواع • ${cat.subtitle}',
                  color: _colors[i % _colors.length],
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => TypeSelectionScreen(category: cat),
                  )),
                ),
              );
            }),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'مولّد الباركود الذكي $appVersion',
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
