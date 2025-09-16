@echo off
echo Building AAB using Gradle directly...

REM Set environment
set JAVA_HOME=C:\Program Files\Java\jdk-24
set ANDROID_HOME=C:\Users\يوسف\AppData\Local\Android\sdk
set PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%PATH%

echo Environment set. Building AAB...

cd android
echo Running Gradle bundleRelease...
gradlew.bat bundleRelease --info --stacktrace
cd ..

echo Checking for AAB...
if exist "android\app\build\outputs\bundle\release\app-release.aab" (
    echo SUCCESS! AAB found.
    copy "android\app\build\outputs\bundle\release\app-release.aab" "reagentKit-v1.0.0+25.aab"
    echo AAB copied to: reagentKit-v1.0.0+25.aab
    
    echo Validating AAB with bundletool...
    java -jar bundletool.jar validate --bundle=reagentKit-v1.0.0+25.aab
    
    if %ERRORLEVEL% EQU 0 (
        echo ✅ AAB is VALID and ready for Play Console!
    ) else (
        echo ❌ AAB validation failed
    )
) else (
    echo ❌ No AAB file found
    echo Checking build directory...
    if exist android\app\build dir android\app\build /s
)

pause
