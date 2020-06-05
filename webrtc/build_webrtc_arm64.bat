@echo off
Rem build for webrtc_arm64

set PRJ_NAME="webrtc_arm64"
set CFLAGS="-Os -w -pipe -fPIC -std=c++14 -fexceptions"
::set CFLAGS="-std=c++14"
::-DCMAKE_C_FLAGS=%CFLAGS%
set ANDROID_EABI=arm64-v8a

call build_project.bat %ANDROID_EABI%

pause