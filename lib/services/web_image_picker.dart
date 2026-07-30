import 'dart:html' as html;
import 'dart:typed_data';

Future<String?> pickImageAsBase64() async {
  try {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    await input.onChange.first;
    if (input.files == null || input.files!.isEmpty) return null;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(input.files![0]);
    await reader.onLoad.first;
    final bytes = reader.result as Uint8List;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrl(blob);
    final img = html.ImageElement();
    img.src = url;
    await img.onLoad.first;
    html.Url.revokeObjectUrl(url);
    final w = (img.width ?? 0).clamp(1, 300);
    final h = (img.height ?? 0).clamp(1, 300);
    final canvas = html.CanvasElement();
    canvas.width = w;
    canvas.height = h;
    final ctx = canvas.context2D;
    ctx.drawImageScaled(img, 0, 0, w, h);
    return canvas.toDataUrl('image/png');
  } catch (_) {
    return null;
  }
}
