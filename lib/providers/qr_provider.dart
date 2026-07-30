import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/qr_type.dart';
import '../models/qr_history_item.dart';
import '../services/qr_data_builder.dart';
import '../services/validators.dart';
import '../services/local_storage.dart';

class QrProvider extends ChangeNotifier {
  QrDataType? _selectedType;
  Map<String, dynamic> _formData = {};
  String _generatedData = '';
  List<QrHistoryItem> _history = [];

  // Customization
  Color _qrColor = Colors.black;
  Color _backgroundColor = Colors.white;
  double _size = 200;
  bool _showLogo = false;
  String? _logoBase64;

  QrProvider() {
    _loadHistory();
  }

  void _loadHistory() {
    final items = LocalStorage.loadHistory();
    _history = items.map((j) => QrHistoryItem.fromJson(j)).toList();
  }

  void _persistHistory() {
    LocalStorage.saveHistory(_history.map((h) => h.toJson()).toList());
  }

  QrDataType? get selectedType => _selectedType;
  Map<String, dynamic> get formData => _formData;
  String get generatedData => _generatedData;
  List<QrHistoryItem> get history => _history;
  Color get qrColor => _qrColor;
  Color get backgroundColor => _backgroundColor;
  double get size => _size;
  bool get showLogo => _showLogo;
  String? get logoBase64 => _logoBase64;

  void selectType(QrDataType type) {
    _selectedType = type;
    _formData = {};
    _generatedData = '';
    _qrColor = Colors.black;
    _backgroundColor = Colors.white;
    _showLogo = false;
    _logoBase64 = null;
    notifyListeners();
  }

  void updateFormData(Map<String, dynamic> data) {
    _formData = data;
    _generate();
  }

  void updateField(String key, dynamic value) {
    _formData[key] = value;
    _generate();
  }

  String? validate() {
    if (_selectedType == null) return 'الرجاء اختيار نوع البيانات';
    return _validateForType();
  }

  String? _validateForType() {
    switch (_selectedType!) {
      case QrDataType.vcard:
        if ((_formData['name'] as String? ?? '').trim().isEmpty) return 'الاسم مطلوب';
        if ((_formData['phone'] as String? ?? '').trim().isEmpty) return 'رقم الهاتف مطلوب';
        final phoneV = Validators.validatePhone(_formData['phone'] as String? ?? '');
        if (!phoneV.isValid) return phoneV.error;
        return null;
      case QrDataType.wifi:
        if ((_formData['ssid'] as String? ?? '').trim().isEmpty) return 'اسم الشبكة (SSID) مطلوب';
        return null;
      case QrDataType.whatsapp:
        if ((_formData['phone'] as String? ?? '').trim().isEmpty) return 'رقم الهاتف مطلوب';
        final phoneV = Validators.validatePhone(_formData['phone'] as String? ?? '');
        if (!phoneV.isValid) return phoneV.error;
        return null;
      case QrDataType.sms:
        if ((_formData['phone'] as String? ?? '').trim().isEmpty) return 'رقم الهاتف مطلوب';
        return null;
      case QrDataType.email:
        if ((_formData['email'] as String? ?? '').trim().isEmpty) return 'البريد الإلكتروني مطلوب';
        final emailV = Validators.validateEmail(_formData['email'] as String? ?? '');
        if (!emailV.isValid) return emailV.error;
        return null;
      case QrDataType.phone:
        if ((_formData['phone'] as String? ?? '').trim().isEmpty) return 'رقم الهاتف مطلوب';
        return null;
      case QrDataType.website:
        if ((_formData['url'] as String? ?? '').trim().isEmpty) return 'الرابط مطلوب';
        return null;
      case QrDataType.socialMedia:
        if ((_formData['platform'] as String? ?? '').isEmpty) return 'المنصة مطلوبة';
        if ((_formData['username'] as String? ?? '').trim().isEmpty) return 'اسم المستخدم مطلوب';
        return null;
      case QrDataType.appStore:
        if ((_formData['iosUrl'] as String? ?? '').trim().isEmpty && (_formData['androidUrl'] as String? ?? '').trim().isEmpty) return 'رابط واحد على الأقل مطلوب';
        return null;
      case QrDataType.googleReviews:
        if ((_formData['placeId'] as String? ?? '').trim().isEmpty) return 'معرف المكان مطلوب';
        return null;
      case QrDataType.digitalMenu:
        if ((_formData['url'] as String? ?? '').trim().isEmpty) return 'الرابط مطلوب';
        return null;
      case QrDataType.geoLocation:
        final lat = _formData['latitude'];
        final lng = _formData['longitude'];
        if (lat == null || lng == null) return 'الإحداثيات مطلوبة';
        return null;
      case QrDataType.calendarEvent:
        if ((_formData['title'] as String? ?? '').trim().isEmpty) return 'عنوان الفعالية مطلوب';
        if (_formData['start'] == null) return 'تاريخ البداية مطلوب';
        if (_formData['end'] == null) return 'تاريخ النهاية مطلوب';
        return null;
      case QrDataType.paymentLink:
        if ((_formData['type'] as String? ?? '').isEmpty) return 'نوع الدفع مطلوب';
        if ((_formData['identifier'] as String? ?? '').trim().isEmpty) return 'المعرف مطلوب';
        return null;
      case QrDataType.cryptoWallet:
        if ((_formData['currency'] as String? ?? '').isEmpty) return 'العملة مطلوبة';
        if ((_formData['address'] as String? ?? '').trim().isEmpty) return 'عنوان المحفظة مطلوب';
        return null;
      case QrDataType.freeText:
        if ((_formData['text'] as String? ?? '').trim().isEmpty) return 'النص مطلوب';
        return null;
      case QrDataType.totp:
        if ((_formData['secret'] as String? ?? '').trim().isEmpty) return 'المفتاح السري مطلوب';
        return null;
      case QrDataType.barcode:
        if ((_formData['code'] as String? ?? '').trim().isEmpty) return 'رمز المنتج مطلوب';
        return null;
    }
  }

  void _generate() {
    if (_selectedType == null) {
      _generatedData = '';
      notifyListeners();
      return;
    }
    try {
      _generatedData = _buildData();
    } catch (_) {
      _generatedData = '';
    }
    notifyListeners();
  }

  String _buildData() {
    switch (_selectedType!) {
      case QrDataType.vcard:
        return QrDataBuilder.buildVcard(
          name: _formData['name'] as String? ?? '',
          phone: _formData['phone'] as String? ?? '',
          email: _formData['email'] as String? ?? '',
          company: _formData['company'] as String? ?? '',
          title: _formData['jobTitle'] as String? ?? '',
          website: _formData['website'] as String? ?? '',
          address: _formData['address'] as String? ?? '',
          note: _formData['note'] as String? ?? '',
        );
      case QrDataType.wifi:
        return QrDataBuilder.buildWifi(
          ssid: _formData['ssid'] as String? ?? '',
          password: _formData['password'] as String? ?? '',
          encryption: _formData['encryption'] as String? ?? 'WPA',
        );
      case QrDataType.whatsapp:
        return QrDataBuilder.buildWhatsapp(
          phone: _formData['phone'] as String? ?? '',
          message: _formData['message'] as String? ?? '',
        );
      case QrDataType.sms:
        return QrDataBuilder.buildSms(
          phone: _formData['phone'] as String? ?? '',
          message: _formData['message'] as String? ?? '',
        );
      case QrDataType.email:
        return QrDataBuilder.buildEmail(
          email: _formData['email'] as String? ?? '',
          subject: _formData['subject'] as String? ?? '',
          body: _formData['body'] as String? ?? '',
        );
      case QrDataType.phone:
        return QrDataBuilder.buildPhone(phone: _formData['phone'] as String? ?? '');
      case QrDataType.website:
        return QrDataBuilder.buildWebsite(url: _formData['url'] as String? ?? '');
      case QrDataType.socialMedia:
        return QrDataBuilder.buildSocialMedia(
          platform: _formData['platform'] as String? ?? '',
          username: _formData['username'] as String? ?? '',
        );
      case QrDataType.appStore:
        return QrDataBuilder.buildAppStore(
          iosUrl: _formData['iosUrl'] as String? ?? '',
          androidUrl: _formData['androidUrl'] as String? ?? '',
        );
      case QrDataType.googleReviews:
        return QrDataBuilder.buildGoogleReviews(
          placeId: _formData['placeId'] as String? ?? '',
          directUrl: _formData['directUrl'] as String?,
        );
      case QrDataType.digitalMenu:
        return QrDataBuilder.buildDigitalMenu(url: _formData['url'] as String? ?? '');
      case QrDataType.geoLocation:
        return QrDataBuilder.buildGeoLocation(
          latitude: (_formData['latitude'] as num?)?.toDouble() ?? 0,
          longitude: (_formData['longitude'] as num?)?.toDouble() ?? 0,
        );
      case QrDataType.calendarEvent:
        return QrDataBuilder.buildCalendarEvent(
          title: _formData['title'] as String? ?? '',
          start: _formData['start'] as DateTime? ?? DateTime.now(),
          end: _formData['end'] as DateTime? ?? DateTime.now().add(const Duration(hours: 1)),
          description: _formData['description'] as String? ?? '',
          location: _formData['location'] as String? ?? '',
        );
      case QrDataType.paymentLink:
        return QrDataBuilder.buildPaymentLink(
          type: _formData['type'] as String? ?? '',
          identifier: _formData['identifier'] as String? ?? '',
        );
      case QrDataType.cryptoWallet:
        return QrDataBuilder.buildCryptoWallet(
          currency: _formData['currency'] as String? ?? '',
          address: _formData['address'] as String? ?? '',
          amount: _formData['amount'] as String?,
        );
      case QrDataType.freeText:
        return QrDataBuilder.buildFreeText(text: _formData['text'] as String? ?? '');
      case QrDataType.totp:
        return QrDataBuilder.buildTotp(
          secret: _formData['secret'] as String? ?? '',
          account: _formData['account'] as String? ?? '',
          issuer: _formData['issuer'] as String? ?? '',
        );
      case QrDataType.barcode:
        return QrDataBuilder.buildBarcode(code: _formData['code'] as String? ?? '');
    }
  }

  void saveToHistory() {
    if (_generatedData.isEmpty) return;
    _history.insert(0, QrHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType!,
      data: Map.from(_formData),
      generatedData: _generatedData,
      createdAt: DateTime.now(),
    ));
    if (_history.length > 50) _history = _history.sublist(0, 50);
    _persistHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    LocalStorage.clearHistory();
    notifyListeners();
  }

  void removeFromHistory(int index) {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);
      _persistHistory();
      notifyListeners();
    }
  }

  void restoreFromHistory(QrHistoryItem item) {
    _selectedType = item.type;
    _formData = Map.from(item.data);
    _generatedData = item.generatedData;
    notifyListeners();
  }

  // Customization
  void setQrColor(Color color) { _qrColor = color; notifyListeners(); }
  void setBackgroundColor(Color color) { _backgroundColor = color; notifyListeners(); }
  void setSize(double size) { _size = size; notifyListeners(); }
  void toggleLogo() { _showLogo = !_showLogo; notifyListeners(); }
  void setLogo(String? base64) { _logoBase64 = base64; _showLogo = base64 != null; notifyListeners(); }
}
