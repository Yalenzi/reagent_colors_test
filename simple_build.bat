@echo on
echo Simple build approach...

REM Set basic environment
set JAVA_HOME=C:\Program Files\Java\jdk-24
set PATH=%JAVA_HOME%\bin;C:\src\flutter\bin;%PATH%

echo Checking current directory contents...
dir *.apk
dir *.aab

echo Attempting to build new APK...
C:\src\flutter\bin\flutter.bat build apk --release --verbose > build_output.log 2>&1

echo Build command executed. Checking log...
type build_output.log

echo Checking for new build outputs...
dir build\app\outputs\flutter-apk\*.apk 2>nul
dir build\app\outputs\bundle\release\*.aab 2>nul

echo Attempting to build AAB...
C:\src\flutter\bin\flutter.bat build appbundle --release --verbose >> build_output.log 2>&1

echo AAB build command executed. Checking updated log...
type build_output.log

echo Final check for all build outputs...
if exist "build\app\outputs\flutter-apk\*.apk" (
    echo New APK files found:
    dir build\app\outputs\flutter-apk\*.apk
    copy build\app\outputs\flutter-apk\*.apk . /Y
)

if exist "build\app\outputs\bundle\release\*.aab" (
    echo New AAB files found:
    dir build\app\outputs\bundle\release\*.aab
    copy build\app\outputs\bundle\release\*.aab . /Y
)

echo Process completed!
pause
