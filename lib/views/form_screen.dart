import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/qr_type.dart';
import '../providers/qr_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dynamic_form.dart';
import '../widgets/qr_preview.dart';
import '../widgets/barcode_preview.dart';
import '../widgets/customization_panel.dart';
import '../widgets/export_options.dart';
import '../services/qr_export.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final Map<String, TextEditingController> _controllers = {};
  QrDataType? _currentType;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _initControllers());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initControllers() {
    if (!mounted) return;
    final provider = context.read<QrProvider>();
    final type = provider.selectedType;
    if (type == null) return;
    _currentType = type;
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    for (final k in _fieldKeys(type)) {
      final val = provider.formData[k] as String? ?? '';
      _controllers[k] = TextEditingController(text: val);
    }
    setState(() {});
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

  void _updateField(String key, String value) {
    context.read<QrProvider>().updateField(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<QrProvider>();
    if (provider.selectedType == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pop(context));
      return const SizedBox.shrink();
    }
    if (provider.selectedType != _currentType && _initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initControllers());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(provider.selectedType!.title),
        actions: [
          IconButton(icon: const Icon(Icons.home_outlined), tooltip: 'الرئيسية',
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst)),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () => _showInfo(context)),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 768;
          if (isWide) {
            return _buildWideLayout(provider);
          }
          return _buildNarrowLayout(provider);
        },
      ),
    );
  }

  Widget _buildWideLayout(QrProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildFormBody(provider),
        )),
        const SizedBox(width: 16),
        Expanded(flex: 4, child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
          child: SingleChildScrollView(
            child: Consumer<QrProvider>(
              builder: (ctx, p, _) => Column(children: [
                _buildPreview(p),
                const SizedBox(height: 16),
                const CustomizationPanel(),
                const SizedBox(height: 16),
                const ExportOptions(),
              ]),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildNarrowLayout(QrProvider provider) {
    return SingleChildScrollView(
      child: Column(children: [
        _buildFormBody(provider),
        const SizedBox(height: 16),
        Consumer<QrProvider>(
          builder: (ctx, p, _) => Column(children: [
            _buildCompactPreview(p),
            if (p.generatedData.isNotEmpty) ...[
              const SizedBox(height: 8),
              const CustomizationPanel(),
              const SizedBox(height: 8),
              const ExportOptions(),
            ],
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildPreview(QrProvider provider) {
    if (provider.selectedType == QrDataType.barcode) {
      final code = provider.formData['code'] as String? ?? '';
      final barcodeType = provider.formData['barcodeType'] as String? ?? 'UPC-A';
      return BarcodePreviewWidget(code: code, type: barcodeType, barColor: provider.qrColor, backgroundColor: provider.backgroundColor);
    }
    return QrPreviewWidget(
      data: provider.generatedData, qrColor: provider.qrColor, backgroundColor: provider.backgroundColor,
      size: provider.size, showLogo: provider.showLogo, logoBase64: provider.logoBase64,
    );
  }

  Widget _buildCompactPreview(QrProvider provider) {
    if (provider.generatedData.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2, size: 32, color: AppColors.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text('أدخل البيانات لمعاينة الباركود',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    if (provider.selectedType == QrDataType.barcode) {
      final code = provider.formData['code'] as String? ?? '';
      final barcodeType = provider.formData['barcodeType'] as String? ?? 'UPC-A';
      return BarcodePreviewWidget(code: code, type: barcodeType, barColor: provider.qrColor, backgroundColor: provider.backgroundColor);
    }
    return QrPreviewWidget(
      data: provider.generatedData, qrColor: provider.qrColor, backgroundColor: provider.backgroundColor,
      size: provider.size, showLogo: provider.showLogo, logoBase64: provider.logoBase64,
    );
  }

  Widget _buildFormBody(QrProvider provider) {
    final type = provider.selectedType!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark
            ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.primary.withValues(alpha: 0.04)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary)),
                    const SizedBox(height: 2),
                    Text(type.subtitle, style: TextStyle(fontSize: 12,
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                  ],
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: _buildFields(type, provider)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFields(QrDataType type, QrProvider provider) {
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

  Widget _buildTextField({
    required String label, required String key, required QrProvider provider,
    String? hint, TextInputType? keyboardType, int maxLines = 1,
    Widget? prefix, List<TextInputFormatter>? inputFormatters,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = _controllers[key] ?? TextEditingController();
    if (_controllers[key] == null) {
      _controllers[key] = controller;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label, hintText: hint, prefixIcon: prefix,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          filled: true,
          fillColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: isDark ? AppColors.textSecondary.withValues(alpha: 0.25) : AppColors.primary.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: isDark ? AppColors.textSecondary.withValues(alpha: 0.15) : Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          labelStyle: TextStyle(fontSize: 13,
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
        ),
        keyboardType: keyboardType, maxLines: maxLines,
        inputFormatters: inputFormatters,
        onChanged: (v) => _updateField(key, v),
        style: TextStyle(fontSize: 14,
          color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label, required String key, required QrProvider provider,
    required List<String> items, required String defaultValue,
    Map<String, String>? labels,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = _controllers.putIfAbsent(key, () => TextEditingController());
    final currentValue = controller.text.isNotEmpty ? controller.text : defaultValue;
    if (!items.contains(currentValue)) {
      controller.text = defaultValue;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _showDropdownPicker(context, label, key, provider, items, labels ?? {}),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark
                ? AppColors.textSecondary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12,
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                  const SizedBox(height: 3),
                  Text(labels?[currentValue] ?? currentValue, style: TextStyle(fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down_circle_outlined, size: 20, color: AppColors.primary),
          ]),
        ),
      ),
    );
  }

  void _showDropdownPicker(BuildContext context, String label, String key, QrProvider provider,
      List<String> items, Map<String, String> labels) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.primary.withValues(alpha: 0.04)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary)),
            ),
            SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: items.map((item) {
                  final selected = _controllers[key]?.text == item;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withValues(alpha: 0.1) : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade400, width: 2),
                        ),
                        child: selected
                            ? const Icon(Icons.check, size: 14, color: AppColors.primary)
                            : null,
                      ),
                      title: Text(labels[item] ?? item,
                        style: TextStyle(
                          color: selected ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 15,
                        )),
                      onTap: () {
                        final ctrl = _controllers.putIfAbsent(key, () => TextEditingController());
                        ctrl.text = item;
                        provider.updateField(key, item);
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('إلغاء', style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _vcardFields(QrProvider p) => [
    _buildTextField(label: 'الاسم الكامل', key: 'name', provider: p, hint: 'مثال: صالح الحودي', prefix: const Icon(Icons.person)),
    _buildTextField(label: 'رقم الهاتف', key: 'phone', provider: p, hint: 'مثال: 966501234567+', keyboardType: TextInputType.phone, prefix: const Icon(Icons.phone)),
    _buildTextField(label: 'البريد الإلكتروني', key: 'email', provider: p, keyboardType: TextInputType.emailAddress, prefix: const Icon(Icons.email)),
    _buildTextField(label: 'الشركة', key: 'company', provider: p, prefix: const Icon(Icons.business)),
    _buildTextField(label: 'المسمى الوظيفي', key: 'jobTitle', provider: p, prefix: const Icon(Icons.badge)),
    _buildTextField(label: 'الموقع الإلكتروني', key: 'website', provider: p, keyboardType: TextInputType.url, prefix: const Icon(Icons.language)),
    _buildTextField(label: 'العنوان', key: 'address', provider: p, prefix: const Icon(Icons.location_on)),
    _buildTextField(label: 'ملاحظات', key: 'note', provider: p, maxLines: 2, prefix: const Icon(Icons.notes)),
    _saveButton(p),
  ];

  List<Widget> _wifiFields(QrProvider p) => [
    _buildTextField(label: 'اسم الشبكة (SSID)', key: 'ssid', provider: p, hint: 'اسم شبكة WiFi', prefix: const Icon(Icons.wifi)),
    _buildTextField(label: 'كلمة السر', key: 'password', provider: p, hint: 'كلمة مرور الشبكة', prefix: const Icon(Icons.lock)),
    _buildDropdownField(label: 'نوع التشفير', key: 'encryption', provider: p, defaultValue: 'WPA',
      items: ['WPA', 'WEP', 'nopass'],
      labels: const {'WPA': 'WPA/WPA2', 'WEP': 'WEP', 'nopass': 'بدون كلمة سر'}),
    _saveButton(p),
  ];

  List<Widget> _whatsappFields(QrProvider p) => [
    _buildTextField(label: 'رقم الهاتف', key: 'phone', provider: p, hint: 'مثال: 966501234567+', keyboardType: TextInputType.phone, prefix: const Icon(Icons.phone)),
    _buildTextField(label: 'نص الرسالة', key: 'message', provider: p, maxLines: 3, hint: 'الرسالة التي ستظهر للمستخدم', prefix: const Icon(Icons.message)),
    _saveButton(p),
  ];

  List<Widget> _smsFields(QrProvider p) => [
    _buildTextField(label: 'رقم الهاتف', key: 'phone', provider: p, hint: 'مثال: 966501234567+', keyboardType: TextInputType.phone, prefix: const Icon(Icons.phone)),
    _buildTextField(label: 'نص الرسالة', key: 'message', provider: p, maxLines: 3, prefix: const Icon(Icons.sms)),
    _saveButton(p),
  ];

  List<Widget> _emailFields(QrProvider p) => [
    _buildTextField(label: 'البريد الإلكتروني', key: 'email', provider: p, keyboardType: TextInputType.emailAddress, prefix: const Icon(Icons.email)),
    _buildTextField(label: 'الموضوع', key: 'subject', provider: p, prefix: const Icon(Icons.subject)),
    _buildTextField(label: 'نص الرسالة', key: 'body', provider: p, maxLines: 4, prefix: const Icon(Icons.article)),
    _saveButton(p),
  ];

  List<Widget> _phoneFields(QrProvider p) => [
    _buildTextField(label: 'رقم الهاتف', key: 'phone', provider: p, hint: 'مثال: 966501234567+', keyboardType: TextInputType.phone, prefix: const Icon(Icons.phone)),
    _saveButton(p),
  ];

  List<Widget> _websiteFields(QrProvider p) => [
    _buildTextField(label: 'رابط الموقع', key: 'url', provider: p, hint: 'https://example.com', keyboardType: TextInputType.url, prefix: const Icon(Icons.language)),
    _saveButton(p),
  ];

  List<Widget> _socialMediaFields(QrProvider p) => [
    _buildDropdownField(label: 'المنصة', key: 'platform', provider: p, defaultValue: 'twitter',
      items: ['twitter', 'instagram', 'snapchat', 'linkedin', 'telegram', 'youtube', 'tiktok'],
      labels: const {'twitter': 'تويتر/X', 'instagram': 'انستغرام', 'snapchat': 'سناب شات', 'linkedin': 'لينكدإن', 'telegram': 'تيليجرام', 'youtube': 'يوتيوب', 'tiktok': 'تيك توك'}),
    _buildTextField(label: 'اسم المستخدم أو الرابط', key: 'username', provider: p, hint: '@username', prefix: const Icon(Icons.alternate_email)),
    _saveButton(p),
  ];

  List<Widget> _appStoreFields(QrProvider p) => [
    _buildTextField(label: 'رابط App Store (iOS)', key: 'iosUrl', provider: p, hint: 'https://apps.apple.com/app/id...', keyboardType: TextInputType.url, prefix: const Icon(Icons.apple)),
    _buildTextField(label: 'رابط Google Play (Android)', key: 'androidUrl', provider: p, hint: 'https://play.google.com/store/apps/details?id=...', keyboardType: TextInputType.url, prefix: const Icon(Icons.android)),
    _saveButton(p),
  ];

  List<Widget> _googleReviewsFields(QrProvider p) => [
    _buildTextField(label: 'معرف المكان (Place ID)', key: 'placeId', provider: p, hint: 'ChIJ...', prefix: const Icon(Icons.pin)),
    _buildTextField(label: 'الرابط المباشر (اختياري)', key: 'directUrl', provider: p, keyboardType: TextInputType.url, prefix: const Icon(Icons.link)),
    _saveButton(p),
  ];

  List<Widget> _digitalMenuFields(QrProvider p) => [
    _buildTextField(label: 'رابط القائمة', key: 'url', provider: p, hint: 'https://example.com/menu', keyboardType: TextInputType.url, prefix: const Icon(Icons.menu_book)),
    _saveButton(p),
  ];

  List<Widget> _geoFields(QrProvider p) => [
    _buildTextField(label: 'خط العرض (Latitude)', key: 'latitude', provider: p, keyboardType: const TextInputType.numberWithOptions(decimal: true), hint: '24.7136', prefix: const Icon(Icons.north_east)),
    _buildTextField(label: 'خط الطول (Longitude)', key: 'longitude', provider: p, keyboardType: const TextInputType.numberWithOptions(decimal: true), hint: '46.6753', prefix: const Icon(Icons.south_east)),
    _saveButton(p),
  ];

  List<Widget> _calendarFields(QrProvider p) => [
    _buildTextField(label: 'عنوان الفعالية', key: 'title', provider: p, prefix: const Icon(Icons.event)),
    _buildTextField(label: 'الموقع', key: 'location', provider: p, prefix: const Icon(Icons.location_on)),
    _buildTextField(label: 'التفاصيل', key: 'description', provider: p, maxLines: 3, prefix: const Icon(Icons.description)),
    _DateTimeField(label: 'تاريخ البداية', fieldKey: 'start', provider: p),
    _DateTimeField(label: 'تاريخ النهاية', fieldKey: 'end', provider: p),
    _saveButton(p),
  ];

  List<Widget> _paymentFields(QrProvider p) => [
    _buildDropdownField(label: 'نوع الدفع', key: 'type', provider: p, defaultValue: 'paypal',
      items: ['paypal', 'stcpay', 'mada', 'other'],
      labels: const {'paypal': 'PayPal', 'stcpay': 'STC Pay', 'mada': 'مدى', 'other': 'آخر'}),
    _buildTextField(label: 'المعرف', key: 'identifier', provider: p, hint: 'البريد أو الرابط', prefix: const Icon(Icons.payment)),
    _saveButton(p),
  ];

  List<Widget> _cryptoFields(QrProvider p) => [
    _buildDropdownField(label: 'العملة', key: 'currency', provider: p, defaultValue: 'bitcoin',
      items: ['bitcoin', 'ethereum', 'litecoin', 'dogecoin'],
      labels: const {'bitcoin': 'بيتكوين (BTC)', 'ethereum': 'إيثريوم (ETH)', 'litecoin': 'لايتكوين (LTC)', 'dogecoin': 'دوجكوين (DOGE)'}),
    _buildTextField(label: 'عنوان المحفظة', key: 'address', provider: p, hint: 'العنوان العام للمحفظة', prefix: const Icon(Icons.account_balance_wallet)),
    _buildTextField(label: 'المبلغ (اختياري)', key: 'amount', provider: p, keyboardType: TextInputType.number, prefix: const Icon(Icons.attach_money)),
    _saveButton(p),
  ];

  List<Widget> _freeTextFields(QrProvider p) => [
    _buildTextField(label: 'النص', key: 'text', provider: p, maxLines: 6, hint: 'أي نص تريد تحويله إلى رمز QR', prefix: const Icon(Icons.text_fields)),
    _saveButton(p),
  ];

  List<Widget> _totpFields(QrProvider p) => [
    _buildTextField(label: 'المفتاح السري (Secret)', key: 'secret', provider: p, hint: 'مفتاح Base32 من الخدمة', prefix: const Icon(Icons.key)),
    _buildTextField(label: 'اسم الحساب', key: 'account', provider: p, hint: 'مثال: user@example.com', prefix: const Icon(Icons.person)),
    _buildTextField(label: 'اسم الخدمة (Issuer)', key: 'issuer', provider: p, hint: 'مثال: Google, GitHub', prefix: const Icon(Icons.business)),
    _saveButton(p),
  ];

  List<Widget> _barcodeFields(QrProvider p) => [
    _buildDropdownField(label: 'نوع الباركود', key: 'barcodeType', provider: p, defaultValue: 'UPC-A', items: ['UPC-A', 'EAN-13']),
    _buildTextField(label: 'رمز المنتج', key: 'code', provider: p, hint: '12 رقم لـ UPC-A أو 13 لـ EAN-13', keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], prefix: const Icon(Icons.qr_code)),
    _saveButton(p),
  ];

  Widget _saveButton(QrProvider p) {
    final hasData = p.generatedData.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          onPressed: hasData ? () {
            QrExport.downloadWithWatermark(
              data: p.generatedData,
              qrColor: p.qrColor,
              backgroundColor: p.backgroundColor,
              size: p.size.toInt(),
              logoBase64: p.showLogo ? p.logoBase64 : null,
            );
            p.saveToHistory();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✓ تم التحميل والحفظ'), backgroundColor: AppColors.success),
            );
          } : null,
          icon: Icon(hasData ? Icons.download : Icons.edit_note, size: 18),
          label: Text(hasData ? 'تحميل الباركود' : 'أدخل البيانات أولاً',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: hasData ? AppColors.secondary : (isDark ? AppColors.darkCard : Colors.grey.shade300),
            foregroundColor: hasData ? Colors.white : (isDark ? AppColors.textSecondary : Colors.grey.shade600),
            disabledBackgroundColor: isDark ? AppColors.darkCard : Colors.grey.shade300,
            disabledForegroundColor: isDark ? AppColors.textSecondary : Colors.grey.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    final type = context.read<QrProvider>().selectedType;
    if (type == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(type.icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(type.title),
        ]),
        content: Text('عند مسح هذا الرمز، سيقوم الهاتف بالإجراء المناسب:\n\n${_actionDescription(type)}'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('فهمت'))],
      ),
    );
  }

  String _actionDescription(QrDataType type) {
    return switch (type) {
      QrDataType.vcard => 'حفظ جهة اتصال جديدة في الهاتف بالبيانات المدخلة.',
      QrDataType.wifi => 'الاتصال بشبكة WiFi مباشرة دون إدخال كلمة السر.',
      QrDataType.whatsapp => 'فتح واتساب مع رسالة جاهزة للرقم المحدد.',
      QrDataType.sms => 'فتح تطبيق الرسائل مع نص جاهز.',
      QrDataType.email => 'فتح تطبيق البريد مع موضوع ونص جاهزين.',
      QrDataType.phone => 'فتح تطبيق الاتصال لبدء مكالمة.',
      QrDataType.website => 'فتح الرابط في المتصفح.',
      QrDataType.socialMedia => 'فتح الحساب في التطبيق أو المتصفح.',
      QrDataType.appStore => 'التوجيه إلى المتجر المناسب حسب نظام التشغيل.',
      QrDataType.googleReviews => 'فتح صفحة تقييم النشاط التجاري.',
      QrDataType.digitalMenu => 'فتح رابط القائمة الرقمية.',
      QrDataType.geoLocation => 'فتح الموقع في تطبيق الخرائط.',
      QrDataType.calendarEvent => 'إضافة الحدث إلى تقويم الهاتف.',
      QrDataType.paymentLink => 'فتح رابط الدفع.',
      QrDataType.cryptoWallet => 'فتح المحفظة الرقمية لتحويل العملة.',
      QrDataType.freeText => 'عرض النص بعد المسح.',
      QrDataType.totp => 'إضافة رمز المصادقة إلى تطبيق التوثيق.',
      QrDataType.barcode => 'مسح الرقم التسلسلي للمنتج.',
    };
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final String fieldKey;
  final QrProvider provider;
  const _DateTimeField({required this.label, required this.fieldKey, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<QrProvider>(
      builder: (ctx, p, _) {
        final value = p.formData[fieldKey] as DateTime?;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context, initialDate: value ?? DateTime.now(),
                firstDate: DateTime(2020), lastDate: DateTime(2100),
              );
              if (date == null) return;
              final time = await showTimePicker(
                context: context, initialTime: value != null ? TimeOfDay.fromDateTime(value) : TimeOfDay.now(),
              );
              if (time == null) return;
              final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
              p.updateField(fieldKey, dt);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark
                    ? AppColors.textSecondary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
                      const SizedBox(height: 3),
                      Text(
                        value != null
                            ? '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')} - ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                            : 'اختر التاريخ والوقت',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: value != null
                            ? (isDark ? Colors.white : Colors.black87)
                            : AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 24, color: AppColors.primary),
              ]),
            ),
          ),
        );
      },
    );
  }
}
