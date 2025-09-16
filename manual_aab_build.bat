@echo off
echo ========================================
echo Manual AAB Build for ReagentKit v1.0.0+25
echo ========================================

REM Set environment
set JAVA_HOME=C:\Program Files\Java\jdk-24
set ANDROID_HOME=C:\Users\يوسف\AppData\Local\Android\sdk
set PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%PATH%

echo Step 1: Verify keystore exists...
if exist "C:\keys\upload.jks" (
    echo ✅ Keystore found: C:\keys\upload.jks
) else (
    echo ❌ Keystore not found. Please ensure keystore exists.
    pause
    exit /b 1
)

echo.
echo Step 2: Create AAB using existing APK...
echo Using bundletool to create AAB from APK...

if exist "reagentKit-arm64-new.apk" (
    echo Converting reagentKit-arm64-new.apk to AAB...
    java -jar bundletool.jar build-bundle --modules=reagentKit-arm64-new.apk --output=reagentKit-v1.0.0+25.aab
    if exist "reagentKit-v1.0.0+25.aab" (
        echo ✅ AAB created successfully!
        goto :success
    )
)

if exist "reagentKit-new.apk" (
    echo Converting reagentKit-new.apk to AAB...
    java -jar bundletool.jar build-bundle --modules=reagentKit-new.apk --output=reagentKit-v1.0.0+25.aab
    if exist "reagentKit-v1.0.0+25.aab" (
        echo ✅ AAB created successfully!
        goto :success
    )
)

if exist "reagentKit.apk" (
    echo Converting reagentKit.apk to AAB...
    java -jar bundletool.jar build-bundle --modules=reagentKit.apk --output=reagentKit-v1.0.0+25.aab
    if exist "reagentKit-v1.0.0+25.aab" (
        echo ✅ AAB created successfully!
        goto :success
    )
)

echo ❌ Failed to create AAB from existing APKs
goto :end

:success
echo.
echo ========================================
echo 🎉 AAB CREATION SUCCESSFUL! 🎉
echo ========================================
echo.
echo File details:
dir reagentKit-v1.0.0+25.aab
echo.
echo This AAB file is ready for upload to Google Play Console!
echo.

:end
pause
