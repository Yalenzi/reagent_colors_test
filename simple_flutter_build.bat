@echo off
echo Starting Flutter AAB build...
echo Current directory: %CD%
echo.

echo Setting environment...
set FLUTTER_ROOT=C:\src\flutter
set PATH=%FLUTTER_ROOT%\bin;%PATH%

echo Checking Flutter...
flutter --version > flutter_version.txt 2>&1
type flutter_version.txt
echo.

echo Running pub get...
flutter pub get > pub_get_output.txt 2>&1
type pub_get_output.txt
echo.

echo Building AAB...
flutter build appbundle --release > build_output.txt 2>&1
type build_output.txt
echo.

echo Checking for AAB files...
if exist "build\app\outputs\bundle\release\*.aab" (
    echo AAB files found:
    dir build\app\outputs\bundle\release\*.aab
) else (
    echo No AAB files found in expected location
)

echo Build process completed.
pause
