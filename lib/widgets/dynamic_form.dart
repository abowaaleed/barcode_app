import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/qr_type.dart';
import '../providers/qr_provider.dart';

class DynamicForm extends StatefulWidget {
  const DynamicForm({super.key});

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final Map<String, TextEditingController> _controllers = {};
  QrDataType? _lastType;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initControllers(QrProvider provider) {
    final type = provider.selectedType;
    if (type == null) return;
    if (type != _lastType) {
      _lastType = type;
      for (final c in _controllers.values) c.dispose();
      _controllers.clear();
      final keys = _fieldKeys(type);
      for (final k in keys) {
        final val = provider.formData[k] as String? ?? '';
        _controllers[k] = TextEditingController(text: val);
      }
      return;
    }
    for (final entry in _controllers.entries) {
      final val = provider.formData[entry.key];
      if (val is String && entry.value.text != val) {
        entry.value.text = val;
      }
    }
  }

  List<String> _fieldKeys(QrDataType type) {
    switch (type) {
      case QrDataType.vcard: return ['name', 'phone', 'email', 'company', 'jobTitle', 'website', 'address', 'note'];
      case QrDataType.wifi: return ['ssid', 'password', 'encryption'];
      case QrDataType.whatsapp: return ['phone', 'message'];
      case QrDataType.sms: return ['phone', 'message'];
      case QrDataType.email: return ['email', 'subject', 'body'];
      case QrDataType.phone: return ['phone'];
      case QrDataType.website: return ['url'];
      case QrDataType.socialMedia: return ['platform', 'username'];
      case QrDataType.appStore: return ['iosUrl', 'androidUrl'];
      case QrDataType.googleReviews: return ['placeId', 'directUrl'];
      case QrDataType.digitalMenu: return ['url'];
      case QrDataType.geoLocation: return ['latitude', 'longitude'];
      case QrDataType.calendarEvent: return ['title', 'location', 'description', 'start', 'end'];
      case QrDataType.paymentLink: return ['type', 'identifier'];
      case QrDataType.cryptoWallet: return ['currency', 'address', 'amount'];
      case QrDataType.freeText: return ['text'];
      case QrDataType.totp: return ['secret', 'account', 'issuer'];
      case QrDataType.barcode: return ['barcodeType', 'code'];
    }
  }

  void _onFieldChanged(String key, String value, QrProvider provider) {
    provider.updateField(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QrProvider>();
    final type = provider.selectedType;
    if (type == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('اختر نوع البيانات من القائمة', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }
    _initControllers(provider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(type.icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(type.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null)),
          ]),
          const SizedBox(height: 8),
          Text(type.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 20),
          ..._buildFields(context, type, provider),
        ],
      ),
    );
  }

  List<Widget> _buildFields(BuildContext context, QrDataType type, QrProvider provider) {
    switch (type) {
      case QrDataType.vcard: return _vcardFields(provider);
      case QrDataType.wifi: return _wifiFields(provider);
      case QrDataType.whatsapp: return _whatsappFields(provider);
      case QrDataType.sms: return _smsFields(provider);
      case QrDataType.email: return _emailFields(provider);
      case QrDataType.phone: return _phoneFields(provider);
      case QrDataType.website: return _websiteFields(provider);
      case QrDataType.socialMedia: return _socialMediaFields(provider);
      case QrDataType.appStore: return _appStoreFields(provider);
      case QrDataType.googleReviews: return _googleReviewsFields(provider);
      case QrDataType.digitalMenu: return _digitalMenuFields(provider);
      case QrDataType.geoLocation: return _geoFields(provider);
      case QrDataType.calendarEvent: return _calendarFields(provider);
      case QrDataType.paymentLink: return _paymentFields(provider);
      case QrDataType.cryptoWallet: return _cryptoFields(provider);
      case QrDataType.freeText: return _freeTextFields(provider);
      case QrDataType.totp: return _totpFields(provider);
      case QrDataType.barcode: return _barcodeFields(provider);
    }
  }

  Widget _buildField({
    required String label,
    required String key,
    required QrProvider provider,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? prefix,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefix,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        onChanged: (v) => _onFieldChanged(key, v, provider),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String key,
    required QrProvider provider,
    required List<String> items,
    required String defaultValue,
    Map<String, String>? labels,
  }) {
    final currentValue = _controllers[key]?.text ?? defaultValue;
    if (!items.contains(currentValue)) {
      _controllers[key]?.text = defaultValue;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDropdownMenu(context, label, key, provider, items, labels ?? {}),
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.arrow_drop_down, size: 24),
          ),
          child: Text(
            labels?[currentValue] ?? currentValue,
            style: TextStyle(fontSize: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }

  void _showDropdownMenu(BuildContext context, String label, String key, QrProvider provider, List<String> items, Map<String, String> labels) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                ...items.map((item) => ListTile(
                  leading: Icon(
                    _controllers[key]?.text == item ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _controllers[key]?.text == item ? Theme.of(context).colorScheme.primary : null,
                  ),
                  title: Text(labels[item] ?? item, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  onTap: () {
                    _controllers[key]?.text = item;
                    provider.updateField(key, item);
                    Navigator.pop(ctx);
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _vcardFields(QrProvider p) => [
    _buildField(label: 'الاسم الكامل', key: 'name', provider: p, hint: 'مثال: صالح الحودي'),
    _buildField(label: 'رقم الهاتف', key: 'phone', provider: p, hint: 'مثال: 966501234567+', keyboardType: TextInputType.phone),
    _buildField(label: 'البريد الإلكتروني', key: 'email', provider: p, keyboardType: TextInputType.emailAddress),
    _buildField(label: 'الشركة', key: 'company', provider: p),
    _buildField(label: 'المسمى الوظيفي', key: 'jobTitle', provider: p),
    _buildField(label: 'الموقع الإلكتروني', key: 'website', provider: p, keyboardType: TextInputType.url),
    _buildField(label: 'العنوان', key: 'address', provider: p),
    _buildField(label: 'ملاحظات', key: 'note', provider: p, maxLines: 2),
  ];

  List<Widget> _wifiFields(QrProvider p) => [
    _buildField(label: 'اسم الشبكة (SSID)', key: 'ssid', provider: p, hint: 'اسم شبكة WiFi'),
    _buildField(label: 'كلمة السر', key: 'password', provider: p, hint: 'كلمة مرور الشبكة'),
    _buildDropdownField(label: 'نوع التشفير', key: 'encryption', provider: p, defaultValue: 'WPA', items: ['WPA', 'WEP', 'nopass'], labels: const {'WPA': 'WPA/WPA2', 'WEP': 'WEP', 'nopass': 'بدون كلمة سر'}),
  ];

  List<Widget> _whatsappFields(QrProvider p) => [
    _buildField(label: 'رقم الهاتف', key: 'phone', provider: p, hint: 'مثال: 966501234567+', keyboardType: TextInputType.phone),
    _buildField(label: 'نص الرسالة', key: 'message', provider: p, maxLines: 3, hint: 'الرسالة التي ستظهر للمستخدم'),
  ];

  List<Widget> _smsFields(QrProvider p) => [
    _buildField(label: 'رقم الهاتف', key: 'phone', provider: p, hint: 'مثال: 966501234567+', keyboardType: TextInputType.phone),
    _buildField(label: 'نص الرسالة', key: 'message', provider: p, maxLines: 3),
  ];

  List<Widget> _emailFields(QrProvider p) => [
    _buildField(label: 'البريد الإلكتروني', key: 'email', provider: p, keyboardType: TextInputType.emailAddress),
    _buildField(label: 'الموضوع', key: 'subject', provider: p),
    _buildField(label: 'نص الرسالة', key: 'body', provider: p, maxLines: 4),
  ];

  List<Widget> _phoneFields(QrProvider p) => [
    _buildField(label: 'رقم الهاتف', key: 'phone', provider: p, hint: 'مثال: 966501234567+', keyboardType: TextInputType.phone),
  ];

  List<Widget> _websiteFields(QrProvider p) => [
    _buildField(label: 'رابط الموقع', key: 'url', provider: p, hint: 'https://example.com', keyboardType: TextInputType.url),
  ];

  List<Widget> _socialMediaFields(QrProvider p) => [
    _buildDropdownField(label: 'المنصة', key: 'platform', provider: p, defaultValue: 'twitter', items: ['twitter', 'instagram', 'snapchat', 'linkedin', 'telegram', 'youtube', 'tiktok'],
      labels: const {'twitter': 'تويتر/X', 'instagram': 'انستغرام', 'snapchat': 'سناب شات', 'linkedin': 'لينكدإن', 'telegram': 'تيليجرام', 'youtube': 'يوتيوب', 'tiktok': 'تيك توك'},
    ),
    _buildField(label: 'اسم المستخدم أو الرابط', key: 'username', provider: p, hint: '@username'),
  ];

  List<Widget> _appStoreFields(QrProvider p) => [
    _buildField(label: 'رابط App Store (iOS)', key: 'iosUrl', provider: p, hint: 'https://apps.apple.com/app/id...', keyboardType: TextInputType.url),
    _buildField(label: 'رابط Google Play (Android)', key: 'androidUrl', provider: p, hint: 'https://play.google.com/store/apps/details?id=...', keyboardType: TextInputType.url),
  ];

  List<Widget> _googleReviewsFields(QrProvider p) => [
    _buildField(label: 'معرف المكان (Place ID)', key: 'placeId', provider: p, hint: 'ChIJ...'),
    _buildField(label: 'الرابط المباشر (اختياري)', key: 'directUrl', provider: p, keyboardType: TextInputType.url),
  ];

  List<Widget> _digitalMenuFields(QrProvider p) => [
    _buildField(label: 'رابط القائمة', key: 'url', provider: p, hint: 'https://example.com/menu', keyboardType: TextInputType.url),
  ];

  List<Widget> _geoFields(QrProvider p) => [
    _buildField(label: 'خط العرض (Latitude)', key: 'latitude', provider: p, keyboardType: const TextInputType.numberWithOptions(decimal: true), hint: '24.7136'),
    _buildField(label: 'خط الطول (Longitude)', key: 'longitude', provider: p, keyboardType: const TextInputType.numberWithOptions(decimal: true), hint: '46.6753'),
  ];

  List<Widget> _calendarFields(QrProvider p) => [
    _buildField(label: 'عنوان الفعالية', key: 'title', provider: p),
    _buildField(label: 'الموقع', key: 'location', provider: p),
    _buildField(label: 'التفاصيل', key: 'description', provider: p, maxLines: 3),
    _DateTimeField(label: 'تاريخ البداية', fieldKey: 'start', provider: p),
    _DateTimeField(label: 'تاريخ النهاية', fieldKey: 'end', provider: p),
  ];

  List<Widget> _paymentFields(QrProvider p) => [
    _buildDropdownField(label: 'نوع الدفع', key: 'type', provider: p, defaultValue: 'paypal', items: ['paypal', 'stcpay', 'mada', 'other'],
      labels: const {'paypal': 'PayPal', 'stcpay': 'STC Pay', 'mada': 'مدى', 'other': 'آخر'}),
    _buildField(label: 'المعرف', key: 'identifier', provider: p, hint: 'البريد أو الرابط'),
  ];

  List<Widget> _cryptoFields(QrProvider p) => [
    _buildDropdownField(label: 'العملة', key: 'currency', provider: p, defaultValue: 'bitcoin', items: ['bitcoin', 'ethereum', 'litecoin', 'dogecoin'],
      labels: const {'bitcoin': 'بيتكوين (BTC)', 'ethereum': 'إيثريوم (ETH)', 'litecoin': 'لايتكوين (LTC)', 'dogecoin': 'دوجكوين (DOGE)'}),
    _buildField(label: 'عنوان المحفظة', key: 'address', provider: p, hint: 'العنوان العام للمحفظة'),
    _buildField(label: 'المبلغ (اختياري)', key: 'amount', provider: p, keyboardType: TextInputType.number),
  ];

  List<Widget> _freeTextFields(QrProvider p) => [
    _buildField(label: 'النص', key: 'text', provider: p, maxLines: 6, hint: 'أي نص تريد تحويله إلى رمز QR'),
  ];

  List<Widget> _totpFields(QrProvider p) => [
    _buildField(label: 'المفتاح السري (Secret)', key: 'secret', provider: p, hint: 'مفتاح Base32 من الخدمة'),
    _buildField(label: 'اسم الحساب', key: 'account', provider: p, hint: 'مثال: user@example.com'),
    _buildField(label: 'اسم الخدمة (Issuer)', key: 'issuer', provider: p, hint: 'مثال: Google, GitHub'),
  ];

  List<Widget> _barcodeFields(QrProvider p) => [
    _buildDropdownField(label: 'نوع الباركود', key: 'barcodeType', provider: p, defaultValue: 'UPC-A', items: ['UPC-A', 'EAN-13']),
    _buildField(label: 'رمز المنتج', key: 'code', provider: p, hint: '12 رقم لـ UPC-A أو 13 لـ EAN-13', keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
  ];
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final String fieldKey;
  final QrProvider provider;

  const _DateTimeField({super.key, required this.label, required this.fieldKey, required this.provider});

  @override
  Widget build(BuildContext context) {
    final value = provider.formData[fieldKey] as DateTime?;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (date == null) return;
          final time = await showTimePicker(
            context: context,
            initialTime: value != null ? TimeOfDay.fromDateTime(value) : TimeOfDay.now(),
          );
          if (time == null) return;
          final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          provider.updateField(fieldKey, dt);
        },
        child: InputDecorator(
          decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today)),
          child: Text(
            value != null
                ? '${value.year}/${value.month}/${value.day} - ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                : 'اختر التاريخ والوقت',
            style: TextStyle(color: value != null ? null : Colors.grey),
          ),
        ),
      ),
    );
  }
}
