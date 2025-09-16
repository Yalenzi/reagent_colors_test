@echo on
echo Final comprehensive build attempt...

REM Set all necessary environment variables
set JAVA_HOME=C:\Program Files\Java\jdk-24
set FLUTTER_ROOT=C:\src\flutter
set ANDROID_HOME=C:\Users\يوسف\AppData\Local\Android\sdk
set ANDROID_SDK_ROOT=%ANDROID_HOME%
set PATH=%JAVA_HOME%\bin;%FLUTTER_ROOT%\bin;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%PATH%

echo Environment variables set:
echo JAVA_HOME: %JAVA_HOME%
echo FLUTTER_ROOT: %FLUTTER_ROOT%
echo ANDROID_HOME: %ANDROID_HOME%

echo Current APK files:
dir *.apk

echo Attempting Flutter clean and pub get...
flutter clean
flutter pub get

echo Attempting direct Gradle build for APK...
cd android
gradlew.bat clean
gradlew.bat assembleRelease --debug --stacktrace > ..\gradle_apk_log.txt 2>&1
cd ..

echo Checking Gradle APK build log...
if exist gradle_apk_log.txt (
    echo Last 20 lines of APK build log:
    powershell -Command "Get-Content gradle_apk_log.txt | Select-Object -Last 20"
)

echo Attempting direct Gradle build for AAB...
cd android
gradlew.bat bundleRelease --debug --stacktrace > ..\gradle_aab_log.txt 2>&1
cd ..

echo Checking Gradle AAB build log...
if exist gradle_aab_log.txt (
    echo Last 20 lines of AAB build log:
    powershell -Command "Get-Content gradle_aab_log.txt | Select-Object -Last 20"
)

echo Checking for build outputs...
if exist "android\app\build\outputs\apk\release\*.apk" (
    echo APK files found in Gradle output:
    dir android\app\build\outputs\apk\release\*.apk
    copy android\app\build\outputs\apk\release\*.apk . /Y
)

if exist "android\app\build\outputs\bundle\release\*.aab" (
    echo AAB files found in Gradle output:
    dir android\app\build\outputs\bundle\release\*.aab
    copy android\app\build\outputs\bundle\release\*.aab . /Y
)

echo Final directory listing:
dir *.apk
dir *.aab

echo Build process completed!
pause
