@echo off
echo ========================================
echo Creating PROPER AAB for ReagentKit v1.0.0+25
echo ========================================

REM Set environment variables with proper paths
set JAVA_HOME=C:\Program Files\Java\jdk-24
set FLUTTER_ROOT=C:\src\flutter
set ANDROID_HOME=C:\Users\يوسف\AppData\Local\Android\sdk
set ANDROID_SDK_ROOT=%ANDROID_HOME%
set PATH=%JAVA_HOME%\bin;%FLUTTER_ROOT%\bin;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin;%PATH%

echo Environment setup:
echo JAVA_HOME: %JAVA_HOME%
echo FLUTTER_ROOT: %FLUTTER_ROOT%
echo ANDROID_HOME: %ANDROID_HOME%
echo.

echo Step 1: Verify Java and Flutter...
java -version
echo.
flutter --version
echo.

echo Step 2: Clean project thoroughly...
if exist build rmdir /s /q build
if exist android\build rmdir /s /q android\build
flutter clean
echo Project cleaned.
echo.

echo Step 3: Get dependencies...
flutter pub get
echo Dependencies updated.
echo.

echo Step 4: Build AAB with verbose output...
echo This may take several minutes...
flutter build appbundle --release --verbose
echo.

echo Step 5: Verify AAB creation...
if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo ✅ SUCCESS! Proper AAB created
    echo Copying to root with version name...
    copy "build\app\outputs\bundle\release\app-release.aab" "reagentKit-v1.0.0+25.aab"
    echo.
    echo ✅ Final AAB: reagentKit-v1.0.0+25.aab
    echo File details:
    dir reagentKit-v1.0.0+25.aab
    echo.
    echo Verifying AAB structure with bundletool...
    java -jar bundletool.jar validate --bundle=reagentKit-v1.0.0+25.aab
    echo.
    echo ========================================
    echo 🎉 VALID AAB READY FOR PLAY CONSOLE! 🎉
    echo ========================================
) else (
    echo ❌ AAB creation failed
    echo Checking build outputs...
    if exist build dir build /s
    if exist android\app\build dir android\app\build /s
    echo.
    echo Trying alternative Gradle build...
    cd android
    gradlew.bat bundleRelease --info --stacktrace
    cd ..
    if exist "android\app\build\outputs\bundle\release\app-release.aab" (
        echo ✅ Gradle AAB build successful!
        copy "android\app\build\outputs\bundle\release\app-release.aab" "reagentKit-v1.0.0+25.aab"
        echo ✅ AAB copied: reagentKit-v1.0.0+25.aab
    )
)

echo.
echo Final check - All AAB files:
dir *.aab 2>nul
echo.
pause
