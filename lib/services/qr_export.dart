import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' show Color;
import 'package:qr/qr.dart';

class QrExport {
  static void downloadPng({
    required String data,
    required Color qrColor,
    required Color backgroundColor,
    required int size,
    String? logoBase64,
  }) {
    final ecLevel = logoBase64 != null ? QrErrorCorrectLevel.H : QrErrorCorrectLevel.M;
    final qrCode = QrCode.fromData(data: data, errorCorrectLevel: ecLevel);
    final qrImage = QrImage(qrCode);
    final moduleCount = qrImage.moduleCount;
    final cellSize = (size / (moduleCount + 4)).floor();
    final padding = cellSize * 2;
    final canvasSize = moduleCount * cellSize + 2 * padding;

    final canvas = html.CanvasElement();
    canvas.width = canvasSize;
    canvas.height = canvasSize;
    final ctx = canvas.context2D;

    ctx.fillStyle = _colorToCss(backgroundColor);
    ctx.fillRect(0, 0, canvasSize, canvasSize);

    ctx.fillStyle = _colorToCss(qrColor);
    for (int y = 0; y < moduleCount; y++) {
      for (int x = 0; x < moduleCount; x++) {
        if (qrImage.isDark(y, x)) {
          ctx.fillRect(padding + x * cellSize, padding + y * cellSize, cellSize, cellSize);
        }
      }
    }

    if (logoBase64 != null) {
      final logoImg = html.ImageElement();
      logoImg.src = logoBase64;
      final logoSize = canvasSize ~/ 4;
      final logoX = (canvasSize - logoSize) ~/ 2;
      final logoY = (canvasSize - logoSize) ~/ 2;
      logoImg.onLoad.first.then((_) {
        ctx.drawImageScaled(logoImg, logoX, logoY, logoSize, logoSize);
        _triggerDownload(canvas, 'qr_code');
      });
      return;
    }

    _triggerDownload(canvas, 'qr_code');
  }

  static void downloadSvg({
    required String data,
    required Color qrColor,
    required Color backgroundColor,
    int size = 500,
  }) {
    final qrCode = QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.M);
    final qrImage = QrImage(qrCode);
    final moduleCount = qrImage.moduleCount;
    final cellSize = (size / (moduleCount + 4)).floor();
    final padding = cellSize * 2;
    final totalSize = moduleCount * cellSize + 2 * padding;

    final buf = StringBuffer();
    buf.writeln('<svg xmlns="http://www.w3.org/2000/svg" width="$totalSize" height="$totalSize" viewBox="0 0 $totalSize $totalSize">');
    buf.writeln('<rect width="$totalSize" height="$totalSize" fill="${_colorToHex(backgroundColor)}"/>');
    for (int y = 0; y < moduleCount; y++) {
      for (int x = 0; x < moduleCount; x++) {
        if (qrImage.isDark(y, x)) {
          buf.writeln('<rect x="${padding + x * cellSize}" y="${padding + y * cellSize}" width="$cellSize" height="$cellSize" fill="${_colorToHex(qrColor)}"/>');
        }
      }
    }
    buf.writeln('</svg>');

    final blob = html.Blob([buf.toString()], 'image/svg+xml');
    final url = html.Url.createObjectUrl(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..download = 'qr_code.svg'
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static void _triggerDownload(html.CanvasElement canvas, String filename) {
    final dataUrl = canvas.toDataUrl('image/png');
    final anchor = html.AnchorElement()
      ..href = dataUrl
      ..download = '$filename.png'
      ..click();
  }

  static String _colorToCss(Color c) => 'rgba(${c.r}, ${c.g}, ${c.b}, ${c.opacity})';

  static String _colorToHex(Color c) {
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }
}
