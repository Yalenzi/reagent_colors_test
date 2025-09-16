@echo on
echo Building Flutter APK and AAB using Flutter SDK...

REM Set Flutter path
set FLUTTER_ROOT=C:\src\flutter
set PATH=%FLUTTER_ROOT%\bin;%PATH%

REM Set Java path
set JAVA_HOME=C:\Program Files\Java\jdk-24
set PATH=%JAVA_HOME%\bin;%PATH%

echo Flutter version:
flutter --version

echo Java version:
java -version

echo Cleaning Flutter project...
flutter clean

echo Getting dependencies...
flutter pub get

echo Building APK (release)...
flutter build apk --release

echo Building APK (split per ABI)...
flutter build apk --split-per-abi --release

echo Building AAB (Android App Bundle)...
flutter build appbundle --release

echo Build completed!
echo.
echo APK files should be in: build\app\outputs\flutter-apk\
echo AAB file should be in: build\app\outputs\bundle\release\

echo Listing build outputs:
dir build\app\outputs\flutter-apk\*.apk
dir build\app\outputs\bundle\release\*.aab

pause
