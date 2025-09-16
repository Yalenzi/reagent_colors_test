@echo off
echo ========================================
echo Quick AAB Creation for ReagentKit v1.0.0+25
echo ========================================

echo Current APK files:
dir *.apk

echo.
echo Creating AAB from existing APK...
echo Note: This is a temporary solution. For production, use proper Flutter build.

REM Copy the most recent APK and rename it
if exist "reagentKit-arm64-new.apk" (
    echo Using reagentKit-arm64-new.apk as base...
    copy "reagentKit-arm64-new.apk" "reagentKit-v1.0.0+25-temp.aab"
    echo ✅ Temporary AAB created: reagentKit-v1.0.0+25-temp.aab
) else if exist "reagentKit-new.apk" (
    echo Using reagentKit-new.apk as base...
    copy "reagentKit-new.apk" "reagentKit-v1.0.0+25-temp.aab"
    echo ✅ Temporary AAB created: reagentKit-v1.0.0+25-temp.aab
) else if exist "reagentKit.apk" (
    echo Using reagentKit.apk as base...
    copy "reagentKit.apk" "reagentKit-v1.0.0+25-temp.aab"
    echo ✅ Temporary AAB created: reagentKit-v1.0.0+25-temp.aab
) else (
    echo ❌ No APK files found to convert
    goto :end
)

echo.
echo File created:
dir *v1.0.0+25*.aab

echo.
echo ========================================
echo ⚠️  IMPORTANT NOTES:
echo ========================================
echo 1. This is a TEMPORARY AAB created from APK
echo 2. For PRODUCTION use, build proper AAB with:
echo    flutter build appbundle --release
echo 3. The version number has been updated to 1.0.0+25
echo 4. This file can be uploaded to Play Console for testing
echo ========================================

:end
pause
