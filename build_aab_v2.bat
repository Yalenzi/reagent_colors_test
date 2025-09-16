@echo off
echo ========================================
echo Building AAB for ReagentKit v1.0.0
echo ========================================

REM Set environment variables
set JAVA_HOME=C:\Program Files\Java\jdk-24
set FLUTTER_ROOT=C:\src\flutter
set ANDROID_HOME=C:\Users\يوسف\AppData\Local\Android\sdk
set ANDROID_SDK_ROOT=%ANDROID_HOME%
set PATH=%JAVA_HOME%\bin;%FLUTTER_ROOT%\bin;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%PATH%

echo Environment setup complete
echo JAVA_HOME: %JAVA_HOME%
echo FLUTTER_ROOT: %FLUTTER_ROOT%
echo ANDROID_HOME: %ANDROID_HOME%
echo.

echo Step 1: Checking Java version...
java -version
echo.

echo Step 2: Checking Flutter version...
flutter --version
echo.

echo Step 3: Cleaning project...
flutter clean
echo.

echo Step 4: Getting dependencies...
flutter pub get
echo.

echo Step 5: Building AAB...
flutter build appbundle --release --verbose
echo.

echo Step 6: Checking for AAB files...
if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo ✅ AAB build successful!
    echo Copying AAB to root directory...
    copy "build\app\outputs\bundle\release\app-release.aab" "reagentKit-v1.0.0.aab"
    echo ✅ AAB file created: reagentKit-v1.0.0.aab
    echo.
    echo File details:
    dir reagentKit-v1.0.0.aab
) else (
    echo ❌ AAB build failed. Trying alternative method...
    echo.
    echo Attempting Gradle build...
    cd android
    gradlew.bat bundleRelease --info
    cd ..
    
    if exist "android\app\build\outputs\bundle\release\app-release.aab" (
        echo ✅ Gradle AAB build successful!
        copy "android\app\build\outputs\bundle\release\app-release.aab" "reagentKit-v1.0.0.aab"
        echo ✅ AAB file created: reagentKit-v1.0.0.aab
    ) else (
        echo ❌ Both Flutter and Gradle builds failed
        echo Please check the error messages above
    )
)

echo.
echo ========================================
echo Build process completed!
echo ========================================
echo.
echo Final files in directory:
dir *.aab
dir *.apk
echo.
pause
