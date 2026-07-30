import 'dart:html' as html;
import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';

class BarcodePreviewWidget extends StatelessWidget {
  final String code;
  final String type;
  final Color barColor;
  final Color backgroundColor;
  final double width;
  final double height;

  const BarcodePreviewWidget({
    super.key,
    required this.code,
    required this.type,
    this.barColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.width = 280,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) return const SizedBox.shrink();
    return Container(
      width: width,
      height: height + 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width,
            height: height,
            child: CustomPaint(
              painter: _BarcodePainter(code: code, type: type, barColor: barColor),
            ),
          ),
          Text(code, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2)),
        ],
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  final String code;
  final String type;
  final Color barColor;

  _BarcodePainter({required this.code, required this.type, required this.barColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Barcode bc;
    if (type == 'UPC-A') {
      bc = Barcode.upcA();
    } else {
      bc = Barcode.ean13();
    }
    final svg = bc.toSvg(code, width: size.width, height: size.height);
    final paint = Paint()..color = barColor;
    // Parse SVG rect elements and draw them
    final reg = RegExp(r'<rect[^>]*x="(\d+)"[^>]*width="(\d+)"[^>]*height="(\d+)"[^>]*/>');
    final matches = reg.allMatches(svg);
    for (final m in matches) {
      final x = double.parse(m.group(1)!);
      final w = double.parse(m.group(2)!);
      final h = double.parse(m.group(3)!);
      canvas.drawRect(Rect.fromLTWH(x, 0, w, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter old) => code != old.code || type != old.type || barColor != old.barColor;
}

void downloadBarcodePng(String code, String type, Color barColor, Color bgColor) {
  final bc = type == 'UPC-A' ? Barcode.upcA() : Barcode.ean13();
  final svg = bc.toSvg(code, width: 400, height: 150);
  final canvas = html.CanvasElement()..width = 400..height = 150;
  final ctx = canvas.context2D;
  ctx.fillStyle = _colorToCss(bgColor);
  ctx.fillRect(0, 0, 400, 150);
  ctx.fillStyle = _colorToCss(barColor);
  final reg = RegExp(r'<rect[^>]*x="(\d+)"[^>]*width="(\d+)"[^>]*height="(\d+)"[^>]*/>');
  final matches = reg.allMatches(svg);
  for (final m in matches) {
    final x = double.parse(m.group(1)!);
    final w = double.parse(m.group(2)!);
    final h = double.parse(m.group(3)!);
    ctx.fillRect(x, 0, w, h);
  }
  final dataUrl = canvas.toDataUrl('image/png');
  final anchor = html.AnchorElement()
    ..href = dataUrl
    ..download = 'barcode.png'
    ..click();
}

String _colorToCss(Color c) => 'rgba(${c.r}, ${c.g}, ${c.b}, ${c.opacity})';
