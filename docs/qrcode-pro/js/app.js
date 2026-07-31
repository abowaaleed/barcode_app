/* ====== مولد الباركود الاحترافي - منطق التطبيق ====== */
(function () {
  'use strict';

  var $ = function (id) { return document.getElementById(id); };

  // ---------- الحالة ----------
  var state = {
    type: 'text',
    logo: null,        // Image object
    logoDataUrl: null, // بيانات الشعار (لإعادة الرسم)
    lastQrData: '',
    lastSize: 512
  };

  // ---------- التبويبات ----------
  var tabs = document.querySelectorAll('.tab');
  var groupFields = {
    text: ['text'],
    url: ['url'],
    phone: ['phone'],
    sms: ['sms'],
    whatsapp: ['whatsapp'],
    email: ['email'],
    wifi: ['wifi']
  };

  function setActiveTab(type) {
    state.type = type;
    tabs.forEach(function (t) {
      var isActive = t.dataset.type === type;
      t.classList.toggle('active', isActive);
      t.setAttribute('aria-selected', isActive ? 'true' : 'false');
    });
    // أظهر حقول النوع المحدد فقط
    Object.keys(groupFields).forEach(function (key) {
      document.querySelectorAll('[data-fieldgroup]').forEach(function (el) {
        el.classList.toggle('hidden', el.dataset.fieldgroup !== key);
      });
    });
  }

  tabs.forEach(function (tab) {
    tab.addEventListener('click', function () { setActiveTab(tab.dataset.type); });
  });

  // ---------- عداد النص ----------
  var fText = $('f-text');
  fText.addEventListener('input', function () {
    $('text-count').textContent = fText.value.length;
  });

  // ---------- الشعار ----------
  var logoToggle = $('c-logo-toggle');
  var logoFile = $('c-logo-file');
  var logoSizeRow = $('logo-size-row');
  var logoPreviewWrap = $('logo-preview-wrap');

  function updateLogoUI() {
    var hasLogo = logoToggle.checked && state.logo;
    logoSizeRow.classList.toggle('hidden', !hasLogo);
    logoPreviewWrap.classList.toggle('hidden', !hasLogo);
  }

  logoToggle.addEventListener('change', updateLogoUI);

  logoFile.addEventListener('change', function () {
    var file = logoFile.files && logoFile.files[0];
    if (!file) return;
    if (file.size > 2 * 1024 * 1024) {
      showToast('حجم الشعار يتجاوز 2MB');
      logoFile.value = '';
      return;
    }
    if (!/^image\/(png|jpeg|webp)$/i.test(file.type)) {
      showToast('الرجاء اختيار صورة PNG أو JPG أو WEBP');
      logoFile.value = '';
      return;
    }
    var reader = new FileReader();
    reader.onload = function (e) {
      var img = new Image();
      img.onload = function () {
        state.logo = img;
        state.logoDataUrl = e.target.result;
        $('logo-preview').src = e.target.result;
        updateLogoUI();
      };
      img.onerror = function () { showToast('تعذر قراءة الصورة'); };
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  });

  $('logo-remove').addEventListener('click', function () {
    state.logo = null;
    state.logoDataUrl = null;
    logoFile.value = '';
    updateLogoUI();
  });

  $('c-logo-size').addEventListener('input', function () {
    $('logo-size-val').textContent = this.value + '%';
  });

  // ---------- بناء نص QR حسب النوع ----------
  function buildQrData() {
    var data = '';
    switch (state.type) {
      case 'text':
        data = fText.value.trim();
        break;
      case 'url': {
        var u = $('f-url').value.trim();
        if (u && !/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(u)) u = 'https://' + u;
        data = u;
        break;
      }
      case 'phone': {
        var code = $('f-phone-code').value.replace(/\D/g, '').trim();
        var num = $('f-phone-num').value.replace(/\D/g, '').trim();
        data = 'tel:+' + code + num;
        break;
      }
      case 'sms': {
        var p = $('f-sms-phone').value.replace(/\D/g, '').trim();
        var m = $('f-sms-msg').value.trim();
        data = 'SMSTO:' + p + ':' + m;
        break;
      }
      case 'whatsapp': {
        var wp = $('f-wa-phone').value.replace(/\D/g, '').trim();
        var wm = $('f-wa-msg').value.trim();
        data = 'https://wa.me/' + wp + (wm ? '?text=' + encodeURIComponent(wm) : '');
        break;
      }
      case 'email': {
        var to = $('f-email-to').value.trim();
        var subject = $('f-email-subject').value.trim();
        var body = $('f-email-body').value.trim();
        data = 'mailto:' + to;
        var qs = [];
        if (subject) qs.push('subject=' + encodeURIComponent(subject));
        if (body) qs.push('body=' + encodeURIComponent(body));
        if (qs.length) data += '?' + qs.join('&');
        break;
      }
      case 'wifi': {
        var ssid = $('f-wifi-ssid').value.trim();
        var sec = $('f-wifi-sec').value;
        var pass = $('f-wifi-pass').value;
        var hidden = $('f-wifi-hidden').checked;
        var parts = [];
        if (sec === 'nopass') {
          parts.push('WIFI:T:nopass;');
        } else {
          parts.push('WIFI:T:' + sec + ';');
        }
        // escape خاصة للمسافات
        parts.push('S:' + escapeWifi(ssid) + ';');
        if (sec !== 'nopass') parts.push('P:' + escapeWifi(pass) + ';');
        if (hidden) parts.push('H:true;');
        parts.push(';');
        data = parts.join('');
        break;
      }
    }
    return data.trim();
  }

  function escapeWifi(s) {
    return String(s).replace(/([\\;,":])/g, '\\$1');
  }

  // ---------- التحقق من اكتمال البيانات ----------
  function validate() {
    switch (state.type) {
      case 'text':
        return fText.value.trim() ? '' : 'اكتب النص المراد تحويله أولاً';
      case 'url':
        return $('f-url').value.trim() ? '' : 'أدخل رابط الموقع أو الصفحة';
      case 'phone':
        return $('f-phone-code').value.trim() && $('f-phone-num').value.trim() ? '' : 'أدخل مفتاح الدولة ورقم الهاتف';
      case 'sms':
        return $('f-sms-phone').value.trim() ? '' : 'أدخل رقم الهاتف';
      case 'whatsapp':
        return $('f-wa-phone').value.trim() ? '' : 'أدخل رقم واتساب بمفتاح الدولة';
      case 'email':
        return $('f-email-to').value.trim() ? '' : 'أدخل البريد الإلكتروني';
      case 'wifi':
        return $('f-wifi-ssid').value.trim() ? '' : 'أدخل اسم الشبكة (SSID)';
    }
    return '';
  }

  // ---------- الرسم على Canvas ----------
  function drawQr(canvas, qrData, size, fg, bg, logoImg, logoPct) {
    var qr = qrcode(0, 'H');
    qr.addData(qrData);
    qr.make();

    var cells = qr.getModuleCount();
    var ctx = canvas.getContext('2d');
    canvas.width = size;
    canvas.height = size;

    // خلفية
    ctx.fillStyle = bg;
    ctx.fillRect(0, 0, size, size);

    var quiet = Math.floor(cells * 0.06); // منطقة هادئة
    var total = cells + quiet * 2;
    var scale = size / total;
    var offset = quiet * scale;

    ctx.fillStyle = fg;
    for (var r = 0; r < cells; r++) {
      for (var c = 0; c < cells; c++) {
        if (qr.isDark(r, c)) {
          ctx.fillRect(offset + c * scale, offset + r * scale, Math.ceil(scale), Math.ceil(scale));
        }
      }
    }

    // الشعار في المنتصف
    if (logoImg) {
      var pct = logoPct / 100;
      var logoSize = size * pct;
      var x = (size - logoSize) / 2;
      var y = (size - logoSize) / 2;
      // خلفية بيضاء للشعار لضمان المسح
      var pad = logoSize * 0.08;
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(x - pad, y - pad, logoSize + pad * 2, logoSize + pad * 2);
      ctx.drawImage(logoImg, x, y, logoSize, logoSize);
    }
  }

  // ---------- الإنشاء ----------
  var form = $('qr-form');
  form.addEventListener('submit', function (e) {
    e.preventDefault();
    generate();
  });

  function generate() {
    var err = validate();
    if (err) { showToast(err); return; }

    var qrData = buildQrData();
    if (!qrData) { showToast('لم تكتمل البيانات المطلوبة'); return; }

    var size = parseInt($('c-size').value, 10);
    var fg = $('c-color').value;
    var bg = $('c-bg').value;
    var logoPct = parseInt($('c-logo-size').value, 10);
    var useLogo = logoToggle.checked ? state.logo : null;

    var canvas = document.createElement('canvas');
    drawQr(canvas, qrData, size, fg, bg, useLogo, logoPct);

    state.lastQrData = qrData;
    state.lastSize = size;

    // معاينة
    var img = $('qr-img');
    img.src = canvas.toDataURL('image/png');
    $('preview-placeholder').classList.add('hidden');
    $('preview-result').classList.remove('hidden');

    showToast('تم إنشاء QR Code بنجاح');
  }

  // ---------- التحميل ----------
  $('btn-download').addEventListener('click', function () {
    var img = $('qr-img');
    if (!img.src || img.src === window.location.href) { showToast('أنشئ الرمز أولاً'); return; }
    var a = document.createElement('a');
    a.href = img.src;
    a.download = 'qr-code-' + state.type + '-' + Date.now() + '.png';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    showToast('تم تنزيل الصورة');
  });

  // ---------- المشاركة ----------
  $('btn-share').addEventListener('click', function () {
    var img = $('qr-img');
    if (!img.src || img.src === window.location.href) { showToast('أنشئ الرمز أولاً'); return; }
    // تحويل dataURL إلى Blob للمشاركة عبر Web Share API
    var parts = img.src.split(',');
    var mime = parts[0].match(/:(.*?);/)[1];
    var bstr = atob(parts[1]);
    var n = bstr.length;
    var u8arr = new Uint8Array(n);
    for (var i = 0; i < n; i++) u8arr[i] = bstr.charCodeAt(i);
    var blob = new Blob([u8arr], { type: mime });
    var file = new File([blob], 'qr-code.png', { type: mime });

    if (navigator.share) {
      navigator.share({ files: [file], title: 'QR Code' }).catch(function () {});
    } else {
      var a = document.createElement('a');
      a.href = img.src;
      a.download = 'qr-code-' + state.type + '-' + Date.now() + '.png';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
    }
  });

  // ---------- Toast ----------
  function showToast(msg) {
    var t = $('toast');
    t.textContent = msg;
    t.classList.add('show');
    clearTimeout(showToast._timer);
    showToast._timer = setTimeout(function () { t.classList.remove('show'); }, 2600);
  }

  // ---------- السنة ----------
  $('year').textContent = new Date().getFullYear();

})();
