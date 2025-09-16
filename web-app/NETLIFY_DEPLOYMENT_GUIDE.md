# 🚀 دليل النشر على Netlify - ColorTests

## 📋 نظرة عامة

هذا الدليل يوضح كيفية نشر تطبيق ColorTests على منصة Netlify مع جميع الإعدادات والتكوينات المطلوبة.

---

## 🔧 الإعداد الأولي

### 1. إنشاء حساب Netlify
1. زيارة [Netlify](https://app.netlify.com/)
2. إنشاء حساب جديد أو تسجيل الدخول
3. ربط الحساب بـ GitHub

### 2. ربط المستودع
1. النقر على **"New site from Git"**
2. اختيار **GitHub** كمصدر
3. تحديد مستودع `colorstest/web-app`
4. منح الصلاحيات المطلوبة

---

## ⚙️ إعدادات البناء

### 🏗️ أوامر البناء
```toml
[build]
  publish = "out"
  command = "npm run build && npm run export"

[build.environment]
  NODE_VERSION = "18"
  NPM_VERSION = "9"
```

### 📝 إعدادات الموقع
- **Site name**: `colorstest-web-app`
- **Custom domain**: `colorstest.com`
- **Branch to deploy**: `main`
- **Build command**: `npm run build && npm run export`
- **Publish directory**: `out`

---

## 🔐 متغيرات البيئة

### 🌐 متغيرات Firebase العامة
```env
NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyC...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=flutter-reagent-test.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=flutter-reagent-test
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=flutter-reagent-test.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789
NEXT_PUBLIC_FIREBASE_APP_ID=1:123456789:web:abcdef
NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID=G-ABCDEFGHIJ
```

### 🔒 متغيرات Firebase الخادم
```env
FIREBASE_PROJECT_ID=flutter-reagent-test
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-...@flutter-reagent-test.iam.gserviceaccount.com
```

### 📧 متغيرات البريد الإلكتروني (اختيارية)
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=noreply@colorstest.com
SMTP_PASS=your_app_password
```

---

## 🔄 إعدادات إعادة التوجيه

### 📍 قواعد إعادة التوجيه
```toml
# SPA redirects
[[redirects]]
  from = "/admin/*"
  to = "/admin/index.html"
  status = 200

[[redirects]]
  from = "/ar/*"
  to = "/ar/index.html"
  status = 200

[[redirects]]
  from = "/en/*"
  to = "/en/index.html"
  status = 200

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

# API redirects
[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/:splat"
  status = 200
```

---

## 🛡️ إعدادات الأمان

### 🔒 رؤوس الأمان
```toml
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Permissions-Policy = "camera=(), microphone=(), geolocation=()"
    Strict-Transport-Security = "max-age=31536000; includeSubDomains"
```

### 📦 إعدادات التخزين المؤقت
```toml
# Static assets caching
[[headers]]
  for = "/static/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/_next/static/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

# API no-cache
[[headers]]
  for = "/api/*"
  [headers.values]
    Cache-Control = "no-cache"
```

---

## 🌐 إعداد النطاق المخصص

### 1. إضافة النطاق
1. الذهاب إلى **Site settings → Domain management**
2. النقر على **"Add custom domain"**
3. إدخال `colorstest.com`
4. تأكيد الملكية

### 2. إعداد DNS
```dns
# A Records
@    A    75.2.60.5
www  CNAME  colorstest-web-app.netlify.app

# CNAME for subdomains
admin  CNAME  colorstest-web-app.netlify.app
api    CNAME  colorstest-web-app.netlify.app
```

### 3. تفعيل SSL
1. الانتظار حتى انتشار DNS
2. تفعيل **"Force HTTPS"**
3. التحقق من شهادة SSL

---

## 🔧 إعدادات متقدمة

### 📊 تحليلات الموقع
```toml
# Analytics
[[headers]]
  for = "/*"
  [headers.values]
    X-Robots-Tag = "index, follow"
```

### 🚀 تحسين الأداء
```toml
# Preload critical resources
[[headers]]
  for = "/"
  [headers.values]
    Link = "</fonts/inter.woff2>; rel=preload; as=font; type=font/woff2; crossorigin"
```

### 🔄 إعدادات البناء المتقدمة
```toml
[build.processing]
  skip_processing = false

[build.processing.css]
  bundle = true
  minify = true

[build.processing.js]
  bundle = true
  minify = true

[build.processing.html]
  pretty_urls = true
```

---

## 🚀 خطوات النشر

### 1. التحضير للنشر
```bash
# تحديث التبعيات
npm install

# فحص الأخطاء
npm run lint

# تشغيل الاختبارات
npm test

# بناء المشروع محلياً للتأكد
npm run build
```

### 2. رفع الكود
```bash
git add .
git commit -m "feat: ready for production deployment"
git push origin main
```

### 3. مراقبة النشر
1. زيارة Netlify Dashboard
2. مراقبة سجل البناء
3. التحقق من نجاح النشر
4. اختبار الموقع

---

## 🔍 استكشاف الأخطاء

### ❌ أخطاء شائعة وحلولها

#### 1. خطأ في بناء Next.js
```bash
# الحل: التأكد من إعدادات next.config.js
output: 'export',
trailingSlash: true,
images: {
  unoptimized: true
}
```

#### 2. خطأ في متغيرات البيئة
```bash
# التحقق من وجود جميع المتغيرات المطلوبة
# في Netlify Dashboard → Site settings → Environment variables
```

#### 3. خطأ في إعادة التوجيه
```bash
# التأكد من وجود ملف netlify.toml في الجذر
# مع قواعد إعادة التوجيه الصحيحة
```

#### 4. خطأ في Firebase
```bash
# التحقق من صحة مفاتيح Firebase
# والتأكد من تفعيل الخدمات المطلوبة
```

### 🔧 أدوات التشخيص
```bash
# فحص الموقع محلياً
npm run build && npm run start

# فحص الروابط
npm run build && npx serve out

# فحص الأداء
npm run build && npx lighthouse http://localhost:3000
```

---

## 📊 مراقبة الأداء

### 📈 مؤشرات الأداء المهمة
- **First Contentful Paint (FCP)**: < 1.5s
- **Largest Contentful Paint (LCP)**: < 2.5s
- **Cumulative Layout Shift (CLS)**: < 0.1
- **First Input Delay (FID)**: < 100ms

### 🔍 أدوات المراقبة
- **Netlify Analytics**: مدمج في لوحة التحكم
- **Google Analytics**: للتحليلات المفصلة
- **Firebase Performance**: لمراقبة الأداء
- **Lighthouse**: لتقييم الأداء

---

## 🔄 التحديثات التلقائية

### 🤖 إعداد CI/CD
```yaml
# .github/workflows/deploy.yml
name: Deploy to Netlify
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '18'
      - run: npm install
      - run: npm run build
      - run: npm run export
```

### 🔔 إشعارات النشر
- **Slack Integration**: إشعارات في Slack
- **Email Notifications**: إشعارات بالبريد الإلكتروني
- **Webhook**: إشعارات مخصصة

---

## 📞 الدعم والمساعدة

### 🆘 في حالة المشاكل
1. **مراجعة سجلات البناء** في Netlify
2. **فحص متغيرات البيئة**
3. **التحقق من إعدادات DNS**
4. **مراجعة قواعد إعادة التوجيه**

### 📚 موارد مفيدة
- [Netlify Documentation](https://docs.netlify.com/)
- [Next.js Deployment Guide](https://nextjs.org/docs/deployment)
- [Firebase Hosting Guide](https://firebase.google.com/docs/hosting)

---

## ✅ قائمة التحقق النهائية

- [ ] ربط المستودع بـ Netlify
- [ ] إعداد أوامر البناء
- [ ] تكوين متغيرات البيئة
- [ ] إضافة قواعد إعادة التوجيه
- [ ] تكوين رؤوس الأمان
- [ ] إعداد النطاق المخصص
- [ ] تفعيل SSL
- [ ] اختبار جميع الصفحات
- [ ] مراقبة الأداء
- [ ] إعداد التحديثات التلقائية

---

**🎉 تهانينا! تم نشر ColorTests بنجاح على Netlify**

*الموقع متاح الآن على: https://colorstest.com/*
