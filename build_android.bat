@echo on
echo Setting up environment...

REM Try different Java locations
if exist "C:\Program Files\Java\jdk-17" (
    set JAVA_HOME=C:\Program Files\Java\jdk-17
    echo Using JDK 17
) else if exist "C:\Program Files\Java\jdk-11" (
    set JAVA_HOME=C:\Program Files\Java\jdk-11
    echo Using JDK 11
) else if exist "C:\Program Files\Android\Android Studio\jbr" (
    set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
    echo Using Android Studio JBR
) else (
    set JAVA_HOME=C:\Program Files\Java\jdk-24
    echo Using JDK 24
)

set PATH=%JAVA_HOME%\bin;%PATH%
echo JAVA_HOME set to: %JAVA_HOME%

java -version

echo Building APK only first...
cd android
gradlew.bat assembleRelease --info > ..\build_log.txt 2>&1
cd ..

echo Build completed! Check build_log.txt for details
type build_log.txt
