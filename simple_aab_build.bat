@echo off
echo Building AAB for ReagentKit v1.0.0+25...

REM Set Flutter path
set FLUTTER_ROOT=C:\src\flutter
set PATH=%FLUTTER_ROOT%\bin;%PATH%

echo Step 1: Clean project...
flutter clean

echo Step 2: Get dependencies...
flutter pub get

echo Step 3: Build AAB...
flutter build appbundle --release

echo Step 4: Check result...
if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo SUCCESS! Copying AAB...
    copy "build\app\outputs\bundle\release\app-release.aab" "reagentKit-v1.0.0+25.aab"
    echo AAB created: reagentKit-v1.0.0+25.aab
) else (
    echo FAILED! No AAB found.
)

pause
