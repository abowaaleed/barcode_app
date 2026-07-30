import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qr_type.dart';
import '../providers/qr_provider.dart';
import '../theme/app_theme.dart';
import 'form_screen.dart';

class TypeSelectionScreen extends StatelessWidget {
  final QrCategory category;

  const TypeSelectionScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final types = QrDataType.values.where((t) => t.category == category).toList();
    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: types.length,
        itemBuilder: (_, i) {
          final type = types[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _colorFor(i, isDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: Colors.white, size: 22),
              ),
              title: Text(type.title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
              subtitle: Text(type.subtitle, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
              onTap: () {
                context.read<QrProvider>().selectType(type);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FormScreen()));
              },
            ),
          );
        },
      ),
    );
  }

  Color _colorFor(int i, bool isDark) {
    const colors = [0xFF6C63FF, 0xFF00D9A6, 0xFFFF6B6B, 0xFFFFB347, 0xFF4FC3F7, 0xFFE040FB];
    return Color(colors[i % colors.length]);
  }
}
