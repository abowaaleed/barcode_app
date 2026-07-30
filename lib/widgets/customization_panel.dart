import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qr_provider.dart';
import '../services/web_image_picker.dart';

class CustomizationPanel extends StatelessWidget {
  const CustomizationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QrProvider>();
    if (provider.generatedData.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تخصيص الرمز', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null)),
          const SizedBox(height: 16),
          _ColorPicker(label: 'لون الرمز', color: provider.qrColor, onChanged: provider.setQrColor),
          const SizedBox(height: 12),
          _ColorPicker(label: 'لون الخلفية', color: provider.backgroundColor, onChanged: provider.setBackgroundColor),
          const SizedBox(height: 12),
          Row(children: [
            const Text('إضافة شعار', style: TextStyle(fontSize: 14)),
            const Spacer(),
            Switch(value: provider.showLogo, onChanged: (_) => provider.toggleLogo()),
          ]),
          if (provider.showLogo) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final b64 = await pickImageAsBase64();
                        if (b64 != null) provider.setLogo(b64);
                      },
                      icon: const Icon(Icons.image, size: 18),
                      label: Text(provider.logoBase64 != null ? 'تغيير الشعار' : 'اختيار صورة'),
                    ),
                  ),
                ),
                if (provider.logoBase64 != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () => provider.setLogo(null),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  const _ColorPicker({required this.label, required this.color, required this.onChanged});

  static const _colors = [
    Colors.black, Colors.white, Colors.red, Colors.pink, Colors.purple,
    Colors.deepPurple, Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime, Colors.yellow,
    Colors.amber, Colors.orange, Colors.deepOrange, Colors.brown, Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6,
          children: _colors.map((c) => GestureDetector(
            onTap: () => onChanged(c),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(color: color == c ? Theme.of(context).colorScheme.primary : Colors.grey.withValues(alpha: 0.3), width: color == c ? 3 : 1),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
