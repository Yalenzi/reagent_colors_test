@echo on
echo Direct build using existing configuration...

REM Set environment variables
set JAVA_HOME=C:\Program Files\Java\jdk-24
set FLUTTER_ROOT=C:\src\flutter
set ANDROID_HOME=C:\Users\Administrator\AppData\Local\Android\sdk
set PATH=%JAVA_HOME%\bin;%FLUTTER_ROOT%\bin;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%PATH%

echo Environment set up
echo JAVA_HOME: %JAVA_HOME%
echo FLUTTER_ROOT: %FLUTTER_ROOT%
echo ANDROID_HOME: %ANDROID_HOME%

echo Building APK using Gradle directly...
cd android
gradlew.bat assembleRelease --info --stacktrace
cd ..

echo Checking for APK files...
if exist "android\app\build\outputs\apk\release\*.apk" (
    echo APK files found:
    dir android\app\build\outputs\apk\release\*.apk
    echo Copying APK files to root directory...
    copy android\app\build\outputs\apk\release\*.apk .
) else (
    echo No APK files found in expected location
)

echo Building AAB using Gradle directly...
cd android
gradlew.bat bundleRelease --info --stacktrace
cd ..

echo Checking for AAB files...
if exist "android\app\build\outputs\bundle\release\*.aab" (
    echo AAB files found:
    dir android\app\build\outputs\bundle\release\*.aab
    echo Copying AAB files to root directory...
    copy android\app\build\outputs\bundle\release\*.aab .
) else (
    echo No AAB files found in expected location
)

echo Build process completed!
pause
