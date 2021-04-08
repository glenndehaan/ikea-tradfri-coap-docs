@echo off
set LIBCOAP_URL=https://github.com/obgm/libcoap/archive/develop.zip
set OPENSSL_INSTALL_PATH=%ProgramFiles%\OpenSSL-Win64
set VISUAL_STUDIO_IDE_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\Common7\IDE

if not exist "%VISUAL_STUDIO_IDE_PATH%\devenv.exe" (
    echo Correct Visual Studio development environment not found.
    echo Install Visual Studio 2019 CE with workload "Desktop development with C++" first.
    pause
    goto :eof
)
if not exist "%OPENSSL_INSTALL_PATH%\include\openssl\ssl.h" (
    echo OpenSSL not found. Please install Win64 OpenSSL v1.1.1k including development files.
    pause
    goto :eof
)

echo Downloading and extracting lib-coap
mkdir downloads
if not exist downloads\libcoap.zip curl -L %LIBCOAP_URL% --output downloads\libcoap.zip
if not exist downloads\libcoap\win32\libcoap.sln (
    tar -xf downloads\libcoap.zip -C downloads
    move downloads\libcoap-* downloads\libcoap
    mkdir downloads\libcoap\win32\lib
    xcopy "%OPENSSL_INSTALL_PATH%\include" downloads\libcoap\include /s /y
    xcopy "%OPENSSL_INSTALL_PATH%\lib" downloads\libcoap\win32\lib /s /y
)

echo Building lib-coap for Windows
"%VISUAL_STUDIO_IDE_PATH%\devenv.exe" "downloads\libcoap\win32\libcoap.sln" /Build "Release DLL" /Project "libcoap" /Project "coap-client"
set LIBCOAP_BIN_PATH=%CD%\downloads\libcoap\win32\x64\Release DLL
if not exist "%LIBCOAP_BIN_PATH%\coap-client.exe" (
    echo Could not compile lib-coap.
    type "downloads\libcoap\win32\x64\Release DLL\libcoap.log"
    pause
    goto :eof
)

echo Copying release files and cleaning up
mkdir release_x64
if exist "%OPENSSL_INSTALL_PATH%\bin\libssl-1_1-x64.dll" xcopy "%OPENSSL_INSTALL_PATH%\bin" release_x64
xcopy /Y "%LIBCOAP_BIN_PATH%" release_x64

rem Remove some unused files
del release_x64\*.obj;release_x64\*.lib;release_x64\*.pdb;release_x64\*.pl;release_x64\*.txt;release_x64\*.recipe;release_x64\*.iobj;release_x64\*.def
