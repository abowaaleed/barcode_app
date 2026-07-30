import 'package:flutter/material.dart';

enum QrCategory {
  personal,
  links,
  locationEvents,
  financial,
  textsBasics;

  String get title {
    switch (this) {
      case QrCategory.personal: return 'التواصل الشخصي';
      case QrCategory.links: return 'الروابط والروابط الذكية';
      case QrCategory.locationEvents: return 'الموقع والفعاليات';
      case QrCategory.financial: return 'المعاملات المالية';
      case QrCategory.textsBasics: return 'النصوص والأساسيات';
    }
  }

  String get subtitle {
    switch (this) {
      case QrCategory.personal: return 'جهات اتصال، واتساب، بريد إلكتروني';
      case QrCategory.links: return 'مواقع، تواصل اجتماعي، متاجر';
      case QrCategory.locationEvents: return 'موقع جغرافي، حدث تقويم';
      case QrCategory.financial: return 'روابط دفع، محافظ رقمية';
      case QrCategory.textsBasics: return 'نصوص، باركود، توثيق';
    }
  }

  IconData get icon {
    switch (this) {
      case QrCategory.personal: return Icons.contacts;
      case QrCategory.links: return Icons.link;
      case QrCategory.locationEvents: return Icons.location_on;
      case QrCategory.financial: return Icons.account_balance;
      case QrCategory.textsBasics: return Icons.text_fields;
    }
  }
}

enum QrDataType {
  vcard,
  wifi,
  whatsapp,
  sms,
  email,
  phone,
  // Links
  website,
  socialMedia,
  appStore,
  googleReviews,
  digitalMenu,
  // Location & Events
  geoLocation,
  calendarEvent,
  // Financial
  paymentLink,
  cryptoWallet,
  // Texts & Basics
  freeText,
  totp,
  barcode;

  QrCategory get category {
    switch (this) {
      case QrDataType.vcard:
      case QrDataType.wifi:
      case QrDataType.whatsapp:
      case QrDataType.sms:
      case QrDataType.email:
      case QrDataType.phone:
        return QrCategory.personal;
      case QrDataType.website:
      case QrDataType.socialMedia:
      case QrDataType.appStore:
      case QrDataType.googleReviews:
      case QrDataType.digitalMenu:
        return QrCategory.links;
      case QrDataType.geoLocation:
      case QrDataType.calendarEvent:
        return QrCategory.locationEvents;
      case QrDataType.paymentLink:
      case QrDataType.cryptoWallet:
        return QrCategory.financial;
      case QrDataType.freeText:
      case QrDataType.totp:
      case QrDataType.barcode:
        return QrCategory.textsBasics;
    }
  }

  String get title {
    switch (this) {
      case QrDataType.vcard: return 'بطاقة العمل (vCard)';
      case QrDataType.wifi: return 'شبكة WiFi';
      case QrDataType.whatsapp: return 'رسالة واتساب';
      case QrDataType.sms: return 'رسالة SMS';
      case QrDataType.email: return 'بريد إلكتروني';
      case QrDataType.phone: return 'مكالمة هاتفية';
      case QrDataType.website: return 'رابط موقع';
      case QrDataType.socialMedia: return 'حساب تواصل اجتماعي';
      case QrDataType.appStore: return 'رابط متجر تطبيقات';
      case QrDataType.googleReviews: return 'تقييم قوقل';
      case QrDataType.digitalMenu: return 'قائمة طعام رقمية';
      case QrDataType.geoLocation: return 'موقع جغرافي';
      case QrDataType.calendarEvent: return 'حدث تقويم';
      case QrDataType.paymentLink: return 'رابط دفع';
      case QrDataType.cryptoWallet: return 'محفظة رقمية';
      case QrDataType.freeText: return 'نص حر';
      case QrDataType.totp: return 'رمز توثيق (TOTP)';
      case QrDataType.barcode: return 'باركود منتج (UPC/EAN)';
    }
  }

  IconData get icon {
    switch (this) {
      case QrDataType.vcard: return Icons.contact_page;
      case QrDataType.wifi: return Icons.wifi;
      case QrDataType.whatsapp: return Icons.chat;
      case QrDataType.sms: return Icons.sms;
      case QrDataType.email: return Icons.email;
      case QrDataType.phone: return Icons.phone;
      case QrDataType.website: return Icons.language;
      case QrDataType.socialMedia: return Icons.share;
      case QrDataType.appStore: return Icons.store;
      case QrDataType.googleReviews: return Icons.star;
      case QrDataType.digitalMenu: return Icons.menu_book;
      case QrDataType.geoLocation: return Icons.pin_drop;
      case QrDataType.calendarEvent: return Icons.calendar_month;
      case QrDataType.paymentLink: return Icons.payment;
      case QrDataType.cryptoWallet: return Icons.currency_bitcoin;
      case QrDataType.freeText: return Icons.text_fields;
      case QrDataType.totp: return Icons.security;
      case QrDataType.barcode: return Icons.qr_code_scanner;
    }
  }

  String get subtitle {
    switch (this) {
      case QrDataType.vcard: return 'الاسم، رقم الهاتف، البريد، الشركة';
      case QrDataType.wifi: return 'اسم الشبكة وكلمة السر';
      case QrDataType.whatsapp: return 'إرسال رسالة عبر واتساب';
      case QrDataType.sms: return 'رسالة نصية مباشرة';
      case QrDataType.email: return 'بريد إلكتروني مع موضوع';
      case QrDataType.phone: return 'رقم هاتف للاتصال';
      case QrDataType.website: return 'رابط موقع إلكتروني';
      case QrDataType.socialMedia: return 'تويتر، انستغرام، سناب شات';
      case QrDataType.appStore: return 'iOS و Android مع توجيه ذكي';
      case QrDataType.googleReviews: return 'رابط تقييم نشاط تجاري';
      case QrDataType.digitalMenu: return 'رابط قائمة طعام PDF';
      case QrDataType.geoLocation: return 'إحداثيات GPS';
      case QrDataType.calendarEvent: return 'حدث مع تاريخ ووقت';
      case QrDataType.paymentLink: return 'مدى، STC Pay، PayPal';
      case QrDataType.cryptoWallet: return 'بيتكوين، إيثريوم';
      case QrDataType.freeText: return 'نص متعدد الأسطر';
      case QrDataType.totp: return 'رمز للمصادقة الثنائية';
      case QrDataType.barcode: return 'باركود خطي تقليدي';
    }
  }
}
