@echo on
echo إعادة بناء AAB بعد إصلاح Android SDK...

REM إعداد متغيرات البيئة
set JAVA_HOME=C:\Program Files\Java\jdk-24
set FLUTTER_ROOT=C:\src\flutter
set PATH=%JAVA_HOME%\bin;%FLUTTER_ROOT%\bin;%PATH%

echo التحقق من إعدادات البيئة:
echo JAVA_HOME: %JAVA_HOME%
echo FLUTTER_ROOT: %FLUTTER_ROOT%

echo التحقق من Flutter doctor...
flutter doctor --android-licenses

echo تنظيف المشروع...
flutter clean

echo الحصول على التبعيات...
flutter pub get

echo بناء AAB باستخدام Flutter...
flutter build appbundle --release --verbose

echo التحقق من ملفات AAB المُنشأة...
if exist "build\app\outputs\bundle\release\*.aab" (
    echo تم العثور على ملفات AAB:
    dir build\app\outputs\bundle\release\*.aab
    echo نسخ ملفات AAB إلى المجلد الرئيسي...
    copy build\app\outputs\bundle\release\*.aab . /Y
    echo تم بناء AAB بنجاح! ✅
) else (
    echo لم يتم العثور على ملفات AAB، محاولة البناء باستخدام Gradle...
    cd android
    gradlew.bat bundleRelease --info --stacktrace
    cd ..
    
    if exist "android\app\build\outputs\bundle\release\*.aab" (
        echo تم العثور على ملفات AAB من Gradle:
        dir android\app\build\outputs\bundle\release\*.aab
        copy android\app\build\outputs\bundle\release\*.aab . /Y
        echo تم بناء AAB بنجاح باستخدام Gradle! ✅
    ) else (
        echo فشل في إنشاء ملف AAB ❌
    )
)

echo الملفات النهائية:
dir *.aab
dir *.apk

echo اكتمل! ✅
pause
