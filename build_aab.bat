@echo off
echo ========================================
echo Building Android App Bundle (AAB) v1.0.0
echo ========================================

REM Set environment variables
set JAVA_HOME=C:\Program Files\Java\jdk-24
set FLUTTER_ROOT=C:\src\flutter
set ANDROID_HOME=C:\Users\يوسف\AppData\Local\Android\sdk
set ANDROID_SDK_ROOT=%ANDROID_HOME%
set PATH=%JAVA_HOME%\bin;%FLUTTER_ROOT%\bin;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%PATH%

echo Environment setup:
echo JAVA_HOME: %JAVA_HOME%
echo FLUTTER_ROOT: %FLUTTER_ROOT%
echo ANDROID_HOME: %ANDROID_HOME%
echo.

echo Checking Java version...
java -version
echo.

echo Step 1: Flutter clean and pub get...
C:\src\flutter\bin\flutter.bat clean
C:\src\flutter\bin\flutter.bat pub get
echo.

echo Step 2: Building AAB with Flutter...
C:\src\flutter\bin\flutter.bat build appbundle --release > aab_build_log.txt 2>&1

echo Step 3: Checking build results...
if exist "build\app\outputs\bundle\release\*.aab" (
    echo ✅ AAB build successful!
    dir build\app\outputs\bundle\release\*.aab
    copy build\app\outputs\bundle\release\*.aab . /Y
    echo ✅ AAB file copied to root directory
) else (
    echo ❌ AAB build failed. Check log below:
    type aab_build_log.txt
)
