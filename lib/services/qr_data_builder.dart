import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

class QrDataBuilder {
  static String buildVcard({
    required String name,
    required String phone,
    String email = '',
    String company = '',
    String title = '',
    String website = '',
    String address = '',
    String note = '',
  }) {
    final buf = StringBuffer();
    buf.writeln('BEGIN:VCARD');
    buf.writeln('VERSION:3.0');
    buf.writeln('FN;CHARSET=UTF-8:$name');
    if (phone.isNotEmpty) buf.writeln('TEL;TYPE=CELL:$phone');
    if (email.isNotEmpty) buf.writeln('EMAIL;CHARSET=UTF-8:$email');
    if (company.isNotEmpty) buf.writeln('ORG;CHARSET=UTF-8:$company');
    if (title.isNotEmpty) buf.writeln('TITLE;CHARSET=UTF-8:$title');
    if (website.isNotEmpty) buf.writeln('URL:$website');
    if (address.isNotEmpty) buf.writeln('ADR;CHARSET=UTF-8:;;$address');
    if (note.isNotEmpty) buf.writeln('NOTE;CHARSET=UTF-8:$note');
    buf.writeln('END:VCARD');
    return buf.toString();
  }

  static String buildWifi({
    required String ssid,
    required String password,
    required String encryption, // 'WPA', 'WEP', 'nopass'
  }) {
    final escPwd = password.replaceAll('\\', '\\\\').replaceAll(';', '\\;').replaceAll(',', '\\,').replaceAll(':', '\\:');
    return 'WIFI:S:$ssid;T:$encryption;P:$escPwd;;';
  }

  static String buildWhatsapp({required String phone, required String message}) {
    final text = Uri.encodeQueryComponent(message);
    return 'https://wa.me/$phone?text=$text';
  }

  static String buildSms({required String phone, required String message}) {
    final text = Uri.encodeQueryComponent(message);
    return 'smsto:$phone:$text';
  }

  static String buildEmail({required String email, required String subject, required String body}) {
    final params = <String, String>{};
    if (subject.isNotEmpty) params['subject'] = subject;
    if (body.isNotEmpty) params['body'] = body;
    final uri = Uri(scheme: 'mailto', path: email, queryParameters: params.isNotEmpty ? params : null);
    return uri.toString();
  }

  static String buildPhone({required String phone}) => 'tel:$phone';

  static String buildWebsite({required String url}) => url.startsWith('http') ? url : 'https://$url';

  static String buildSocialMedia({required String platform, required String username}) {
    switch (platform) {
      case 'twitter': return 'https://twitter.com/$username';
      case 'instagram': return 'https://instagram.com/$username';
      case 'snapchat': return 'https://snapchat.com/add/$username';
      case 'linkedin': return 'https://linkedin.com/in/$username';
      case 'telegram': return 'https://t.me/$username';
      case 'youtube': return 'https://youtube.com/@$username';
      case 'tiktok': return 'https://tiktok.com/@$username';
      default: return 'https://$username';
    }
  }

  static String buildAppStore({required String iosUrl, required String androidUrl}) {
    final html = '''
<!DOCTYPE html>
<html dir="rtl">
<head><meta charset="UTF-8"><title>توجيه المتجر</title>
<script>
(function(){
  var ua = navigator.userAgent;
  if (ua.indexOf("iPhone") !== -1 || ua.indexOf("iPad") !== -1 || ua.indexOf("iPod") !== -1) {
    window.location.href = "$iosUrl";
  } else if (ua.indexOf("Android") !== -1) {
    window.location.href = "$androidUrl";
  } else {
    window.location.href = "$iosUrl";
  }
})();
</script>
<style>body{font-family:sans-serif;text-align:center;padding:40px;background:#f5f7fa;color:#333;}
h2{margin-bottom:10px;}p{color:#666;}
a{color:#6C63FF;text-decoration:none;}</style>
</head>
<body>
<h2>جاري توجيهك إلى المتجر المناسب...</h2>
<p>إذا لم يتم التوجيه تلقائياً:
<a href="$iosUrl">App Store</a> | <a href="$androidUrl">Google Play</a></p>
</body>
</html>''';
    return 'data:text/html;charset=utf-8,${Uri.encodeComponent(html)}';
  }

  static String buildGoogleReviews({required String placeId, String? directUrl}) {
    if (directUrl != null && directUrl.isNotEmpty) return directUrl;
    return 'https://search.google.com/local/writereview?placeid=$placeId';
  }

  static String buildDigitalMenu({required String url}) => url;

  static String buildGeoLocation({required double latitude, required double longitude}) {
    return 'geo:$latitude,$longitude';
  }

  static String buildCalendarEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String description = '',
    String location = '',
  }) {
    final format = 'yyyyMMddTHHmmss';
    final f = _iCalFormatter;
    return 'BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\n'
        'SUMMARY:${_esc(title)}\n'
        'DTSTART:${f(start, format)}Z\n'
        'DTEND:${f(end, format)}Z\n'
        '${description.isNotEmpty ? "DESCRIPTION:${_esc(description)}\n" : ""}'
        '${location.isNotEmpty ? "LOCATION:${_esc(location)}\n" : ""}'
        'END:VEVENT\nEND:VCALENDAR';
  }

  static String _esc(String s) => s.replaceAll('\\', '\\\\').replaceAll(';', '\\;').replaceAll('\n', '\\n');

  static String _iCalFormatter(DateTime dt, String format) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y$mo${d}T$h$mi${s}';
  }

  static String buildPaymentLink({required String type, required String identifier}) {
    switch (type) {
      case 'paypal': return 'https://paypal.me/$identifier';
      case 'stcpay': return identifier; // stc pay link
      case 'mada': return identifier;
      default: return identifier;
    }
  }

  static String buildCryptoWallet({required String currency, required String address, String? amount}) {
    switch (currency) {
      case 'bitcoin':
        final uri = 'bitcoin:$address${amount != null && amount.isNotEmpty ? "?amount=$amount" : ""}';
        return uri;
      case 'ethereum':
        return 'ethereum:$address${amount != null && amount.isNotEmpty ? "?value=$amount" : ""}';
      case 'litecoin':
        return 'litecoin:$address${amount != null && amount.isNotEmpty ? "?amount=$amount" : ""}';
      case 'dogecoin':
        return 'dogecoin:$address${amount != null && amount.isNotEmpty ? "?amount=$amount" : ""}';
      default:
        return '$currency:$address';
    }
  }

  static String buildFreeText({required String text}) => text;

  static String buildTotp({required String secret, required String account, required String issuer}) {
    final encodedAccount = Uri.encodeQueryComponent(account);
    final encodedIssuer = Uri.encodeQueryComponent(issuer);
    final label = issuer.isNotEmpty ? '$encodedIssuer:$encodedAccount' : encodedAccount;
    final issuerParam = issuer.isNotEmpty ? '&issuer=${Uri.encodeComponent(issuer)}' : '';
    return 'otpauth://totp/$label?secret=$secret$issuerParam&algorithm=SHA1&digits=6&period=30';
  }

  static String buildBarcode({required String code}) => code;
}
