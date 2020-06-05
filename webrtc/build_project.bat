@echo off

if "%1"=="" (
	echo "Do not execute build.bat directly, run build_xxx.bat instead!!!"
	pause
	exit
)

if not %PRJ_NAME%=="webrtc_arm64" (
	echo "Not supported project!!!"
	Rem exit /b
	pause
	exit
)

echo build for %PRJ_NAME%
set ANDROID_EABI=%1

set CURRENT_DIR=%~dp0
set PROJECT_DIR=%CURRENT_DIR%..
set OBJ_DIR=%CURRENT_DIR%obj

echo CURRENT_DIR=%CURRENT_DIR%
echo PROJECT_DIR=%PROJECT_DIR%
echo OBJ_DIR=%OBJ_DIR%
echo CFLAGS=%CFLAGS%

set ndk_path=C:\Users\Belieflong\Develop\Library\android-sdk\ndk-bundle
set build_type=Release
set gernerator=Ninja
set android_version=19

if not exist %OBJ_DIR%\%ANDROID_EABI% md %OBJ_DIR%\%ANDROID_EABI%
cd %OBJ_DIR%\%ANDROID_EABI%
cmake ../../ ^
	-DANDROID_NDK=%ndk_path% ^
	-DCMAKE_TOOLCHAIN_FILE=%ndk_path%\build\cmake\android.toolchain.cmake ^
	-DCMAKE_BUILD_TYPE=%build_type% ^
	-DANDROID_ABI=%ANDROID_EABI% ^
	-DANDROID_PLATFORM=android-%android_version% ^
	-DANDROID_TOOLCHAIN=clang ^
	-DCMAKE_CXX_FLAGS=%CFLAGS% ^
	-DANDROID_STL=c++_shared ^
	-DCMAKE_INSTALL_PREFIX=%OBJ_DIR%\%ANDROID_EABI% ^
	-DCMAKE_GENERATOR=%gernerator% ^
	-DWEBRTC_REPO_RELATIVE=../../.. ^
    -DWEBRTC_BUILD_DIR=out/android_studio ^
    -DWEBRTC_BUILD_SIMPLIFY=true
ninja