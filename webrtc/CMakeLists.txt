cmake_minimum_required(VERSION 3.7)

set(CWD ${CMAKE_CURRENT_LIST_DIR})

if (${WEBRTC_BUILD_SIMPLIFY} STREQUAL "true")
set(WEBRTC_REPO ${CWD}/${WEBRTC_REPO_RELATIVE})
endif()

set(TEST_CC_FILTER ".*gunit.cc|.*/mock/.*|.*mock_.*|.*/mocks/.*|.*fake.*|.*/test/.*|.*/tests/.*|.*_test_.*|.*unittest.*|.*/end_to_end_tests/.*|.*_test.cc|.*_tests.cc|.*_integrationtest.cc|.*_perftest.cc|.*test_utils.cc|.*testutils.cc|.*testclient.cc|.*test.c")
set(OTHER_PLATFORM_CC_FILTER ".*_chromeos.cc|.*_freebsd.cc|.*_fuchsia.cc|.*/fuchsia/.*|.*_ios.cc|.*_ios.mm|.*/ios/.*|.*_mac.cc|.*_mac.mm|.*/mac/.*|.*_openbsd.cc|.*_win.cc|.*/win/.*|.*win32.*|.*/windows/.*|.*sse.cc|.*sse2.cc|.*_mips.cc|.*_mips.c")

enable_language(ASM)
set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})

# add at first, avoid header search path, definition chaos

if (!${WEBRTC_BUILD_SIMPLIFY} STREQUAL "true")
add_subdirectory(third_party)
endif()

add_definitions(-DWEBRTC_POSIX=1, -DWEBRTC_LINUX=1, -DWEBRTC_ANDROID=1)
add_definitions(-DWEBRTC_USE_H264=1)
add_definitions(-DWEBRTC_ENABLE_PROTOBUF=1)
add_definitions(-DWEBRTC_INCLUDE_INTERNAL_AUDIO_DEVICE)
add_definitions(-DHAVE_PTHREAD -DHAVE_SCTP -DHAVE_WEBRTC_VIDEO -DHAVE_WEBRTC_VOICE)
add_definitions(-DUSE_BUILTIN_SW_CODECS)
add_definitions(-DENABLE_RTC_EVENT_LOG)
add_definitions(-DWEBRTC_NON_STATIC_TRACE_EVENT_HANDLERS=0)

if (${ANDROID_ABI} STREQUAL "armeabi-v7a")
    add_definitions(-DWEBRTC_USE_BUILTIN_ISAC_FIX=1 -DWEBRTC_USE_BUILTIN_ISAC_FLOAT=0)
else()
    add_definitions(-DWEBRTC_USE_BUILTIN_ISAC_FIX=0 -DWEBRTC_USE_BUILTIN_ISAC_FLOAT=1)
endif()

add_definitions(-DWEBRTC_OPUS_VARIABLE_COMPLEXITY=0)

add_definitions(-DNO_TCMALLOC=1)

if (${ANDROID_ABI} STREQUAL "arm64-v8a")
    add_definitions(-DWEBRTC_ARCH_ARM64 -DWEBRTC_HAS_NEON)
elseif (${ANDROID_ABI} STREQUAL "armeabi-v7a")
    add_definitions(-DWEBRTC_ARCH_ARM -DWEBRTC_ARCH_ARM_V7)
endif()

add_definitions(-DWEBRTC_CODEC_ILBC -DWEBRTC_CODEC_OPUS -DWEBRTC_OPUS_SUPPORT_120MS_PTIME=1 -DWEBRTC_CODEC_ISAC -DWEBRTC_CODEC_RED)

add_definitions(-DWEBRTC_INTELLIGIBILITY_ENHANCER=0 -DWEBRTC_NS_FIXED)

add_definitions(-DWEBRTC_APM_DEBUG_DUMP=0)

add_definitions(-DHAVE_NETINET_IN_H)

include_directories(
    ${WEBRTC_REPO}

    ${WEBRTC_REPO}/${WEBRTC_BUILD_DIR}/gen

    ${ANDROID_SYSROOT}/usr/include/aarch64-linux-android
    ${WEBRTC_REPO}/third_party/android_ndk/sources/android/cpufeatures

    ${WEBRTC_REPO}/third_party/abseil-cpp
    ${WEBRTC_REPO}/third_party/boringssl/src/include
    ${WEBRTC_REPO}/third_party/icu/source/common
    ${WEBRTC_REPO}/third_party/ffmpeg
    ${WEBRTC_REPO}/third_party/ffmpeg/chromium/config/Chrome/android/arm64
    ${WEBRTC_REPO}/third_party/jsoncpp/source/include
    ${WEBRTC_REPO}/third_party/libsrtp/config
    ${WEBRTC_REPO}/third_party/libsrtp/crypto/include
    ${WEBRTC_REPO}/third_party/libsrtp/include
    ${WEBRTC_REPO}/third_party/libyuv/include
    ${WEBRTC_REPO}/third_party/libvpx/source/libvpx
    ${WEBRTC_REPO}/third_party/opus/src/include
    ${WEBRTC_REPO}/third_party/protobuf/src
    ${WEBRTC_REPO}/third_party/usrsctp/usrsctplib
)

file(GLOB_RECURSE ndk_api
    ${WEBRTC_REPO}/third_party/android_ndk/sources/android/cpufeatures/cpu-features.c
)

file(GLOB_RECURSE src_api
    ${WEBRTC_REPO}/api/*.cc
)
list(FILTER src_api EXCLUDE REGEX ${TEST_CC_FILTER})
list(FILTER src_api EXCLUDE REGEX
    ".*echo_canceller3_config_json.cc|.*default_task_queue_factory_gcd.cc|.*default_task_queue_factory_stdlib.cc|.*default_task_queue_factory_win.cc|.*video_stream_decoder_create.cc"
)

file(GLOB_RECURSE src_audio
    ${WEBRTC_REPO}/audio/*.cc
)
list(FILTER src_audio EXCLUDE REGEX ${TEST_CC_FILTER})

file(GLOB_RECURSE src_call
    ${WEBRTC_REPO}/call/*.cc
)
list(FILTER src_call EXCLUDE REGEX ${TEST_CC_FILTER})
list(APPEND src_call ${WEBRTC_REPO}/call/fake_network_pipe.cc)

file(GLOB_RECURSE src_common_audio
    ${WEBRTC_REPO}/common_audio/*.c
    ${WEBRTC_REPO}/common_audio/*.cc
)
list(FILTER src_common_audio EXCLUDE REGEX ${TEST_CC_FILTER})
list(FILTER src_common_audio EXCLUDE REGEX ${OTHER_PLATFORM_CC_FILTER})

file(GLOB_RECURSE src_common_video
    ${WEBRTC_REPO}/common_video/*.cc
)
list(FILTER src_common_video EXCLUDE REGEX ${TEST_CC_FILTER})

file(GLOB_RECURSE src_logging
    ${WEBRTC_REPO}/logging/rtc_event_log/encoder/*.cc
    ${WEBRTC_REPO}/logging/rtc_event_log/events/*.cc
    ${WEBRTC_REPO}/logging/rtc_event_log/output/*.cc
    ${WEBRTC_REPO}/logging/rtc_event_log/ice_logger.cc
    ${WEBRTC_REPO}/logging/rtc_event_log/rtc_event_log.cc
    ${WEBRTC_REPO}/logging/rtc_event_log/rtc_event_log_factory.cc
    ${WEBRTC_REPO}/logging/rtc_event_log/rtc_event_log_impl.cc
    ${WEBRTC_REPO}/logging/rtc_event_log/rtc_stream_config.cc
    ${WEBRTC_REPO}/${WEBRTC_BUILD_DIR}/gen/logging/*.cc
)
list(FILTER src_logging EXCLUDE REGEX ${TEST_CC_FILTER})

file(GLOB_RECURSE src_media
    ${WEBRTC_REPO}/media/*.cc
)
list(FILTER src_media EXCLUDE REGEX ${TEST_CC_FILTER})
list(FILTER src_media EXCLUDE REGEX ".*fakertp.cc")

file(GLOB_RECURSE src_modules
    ${WEBRTC_REPO}/modules/*.c
    ${WEBRTC_REPO}/modules/*.cc
    ${WEBRTC_REPO}/${WEBRTC_BUILD_DIR}/gen/modules/*.cc
)
list(FILTER src_modules EXCLUDE REGEX ${TEST_CC_FILTER})
list(FILTER src_modules EXCLUDE REGEX ${OTHER_PLATFORM_CC_FILTER})
list(FILTER src_modules EXCLUDE REGEX 
    #".*/desktop_capture/.|.*/linux/.*|.*include/audio_device_factory.cc|.*bwe_simulations.cc|.*/audio_coding/neteq/tools/.*|.*/remote_bitrate_estimator/tools/.*|.*rnn_vad_tool.cc|.*null_aec_dump_factory.cc|.*h264_color_space.cc|.*vp9_noop.cc|.*h264_decoder_impl.cc|.*h264_encoder_impl.cc|.*/android/aaudio_.*|.*ensure_initialized.cc|.*fixed_gain_controller.cc|.*click_annotate.cc"
    ".*/desktop_capture/.|.*/linux/.*|.*include/audio_device_factory.cc|.*bwe_simulations.cc|.*/audio_coding/neteq/tools/.*|.*/remote_bitrate_estimator/tools/.*|.*rnn_vad_tool.cc|.*null_aec_dump_factory.cc|.*vp9_noop.cc|.*/android/aaudio_.*|.*ensure_initialized.cc|.*fixed_gain_controller.cc|.*click_annotate.cc"
)

file(GLOB_RECURSE src_ortc
    ${WEBRTC_REPO}/ortc/*.cc
)
list(FILTER src_ortc EXCLUDE REGEX ${TEST_CC_FILTER})

file(GLOB_RECURSE src_p2p
    ${WEBRTC_REPO}/p2p/*.cc
)
list(FILTER src_p2p EXCLUDE REGEX ${TEST_CC_FILTER})

file(GLOB_RECURSE src_pc
    ${WEBRTC_REPO}/pc/*.cc
)
list(FILTER src_pc EXCLUDE REGEX ${TEST_CC_FILTER})
list(FILTER src_pc EXCLUDE REGEX 
    ".*peer_connection_wrapper.cc"
)

file(GLOB_RECURSE src_rtc_base
    ${WEBRTC_REPO}/rtc_base/*.cc
)
list(FILTER src_rtc_base EXCLUDE REGEX ${TEST_CC_FILTER})
list(FILTER src_rtc_base EXCLUDE REGEX ${OTHER_PLATFORM_CC_FILTER})
list(FILTER src_rtc_base EXCLUDE REGEX 
    ".*mac_utils.cc|.*mac_ifaddrs_converter.cc|.*test_echo_server.cc|.*task_queue_gcd.cc|.*task_queue_stdlib.cc|.*task_queue_for_test.cc|.*virtual_socket_server.cc|.*nat_socket_factory.cc|.*nat_server.cc|.*strings/json.cc"
)

file(GLOB_RECURSE src_sdk
    ${WEBRTC_REPO}/sdk/android/*.cc
    ${WEBRTC_REPO}/sdk/media_constraints.cc
)
list(FILTER src_sdk EXCLUDE REGEX ${TEST_CC_FILTER})
list(FILTER src_sdk EXCLUDE REGEX 
    ".*null_audio.cc|.*null_media.cc|.*null_video.cc|.*/audio_device/aaudio_.*"
)

file(GLOB_RECURSE src_stats
    ${WEBRTC_REPO}/stats/*.cc
)
list(FILTER src_stats EXCLUDE REGEX ${TEST_CC_FILTER})

file(GLOB_RECURSE src_system_wrappers
    ${WEBRTC_REPO}/system_wrappers/*.cc
)
list(FILTER src_system_wrappers EXCLUDE REGEX ${TEST_CC_FILTER})
list(FILTER src_system_wrappers EXCLUDE REGEX ${OTHER_PLATFORM_CC_FILTER})

file(GLOB_RECURSE src_video
    ${WEBRTC_REPO}/video/*.cc
)
list(FILTER src_video EXCLUDE REGEX ${TEST_CC_FILTER})
list(FILTER src_video EXCLUDE REGEX 
    ".*_loopback.cc|.*replay.cc|.*video_analyzer.cc|.*video_loopback_main.cc|.*video_stream_decoder_impl.cc"
)

add_library(jingle_peerconnection_so SHARED
    ${ndk_api}
    ${src_api}
    ${src_audio}
    ${src_call}
    ${src_common_audio}
    ${src_common_video}
    ${src_logging}
    ${src_media}
    ${src_modules}
    ${src_ortc}
    ${src_p2p}
    ${src_pc}
    ${src_rtc_base}
    ${src_sdk}
    ${src_stats}
    ${src_system_wrappers}
    ${src_video}
)

if (${WEBRTC_BUILD_SIMPLIFY} STREQUAL "true")
    target_link_libraries(jingle_peerconnection_so
        #absl::optional
        #absl::variant
        ${WEBRTC_REPO}/out/libs_third_party/libabsl_absl_base.a
        ${WEBRTC_REPO}/out/libs_third_party/libabsl_absl_throw_delegate.a
        ${WEBRTC_REPO}/out/libs_third_party/libabsl_absl_int128.a
        ${WEBRTC_REPO}/out/libs_third_party/libabsl_absl_spinlock_wait.a
        ${WEBRTC_REPO}/out/libs_third_party/libabsl_absl_bad_optional_access.a
        ${WEBRTC_REPO}/out/libs_third_party/libabsl_absl_bad_variant_access.a
        ${WEBRTC_REPO}/out/libs_third_party/libabsl_absl_spinlock_wait.a
        #absl::strings
        ${WEBRTC_REPO}/out/libs_third_party/libabsl_absl_strings_internal.a
        ${WEBRTC_REPO}/out/libs_third_party/libabsl_absl_strings.a
        #crypto
        ${WEBRTC_REPO}/out/libs_third_party/libdecrepit.a
        ${WEBRTC_REPO}/out/libs_third_party/libcrypto.a
        ${WEBRTC_REPO}/out/libs_third_party/libboringssl_gtest.a
        ${WEBRTC_REPO}/out/libs_third_party/libtest_support_lib.a
        #event
        ${WEBRTC_REPO}/out/libs_third_party/libevent.a
        #json
        #opus
        ${WEBRTC_REPO}/out/libs_third_party/libopus.a
        #pffft
        ${WEBRTC_REPO}/out/libs_third_party/libpffft.a
        #protobuf_lite
        ${WEBRTC_REPO}/out/libs_third_party/libprotobuf_lite.a
        #rnnoise
        ${WEBRTC_REPO}/out/libs_third_party/librnnoise.a
        #srtp
        ${WEBRTC_REPO}/out/libs_third_party/libsrtp.a
        #ssl
        ${WEBRTC_REPO}/out/libs_third_party/libssl.a
        #usrsctp
        ${WEBRTC_REPO}/out/libs_third_party/libusrsctp.a
        #vpx
        ${WEBRTC_REPO}/out/libs_third_party/libvpx.a
        #openh264
        ${WEBRTC_REPO}/out/libs_third_party/libopenh264.a
        #ffmpeg
        ${WEBRTC_REPO}/out/libs_third_party/libffmpeg.a
        #yuv
        ${WEBRTC_REPO}/out/libs_third_party/libyuv.a

        android
        log
        GLESv2
        OpenSLES
    )
else()
    target_link_libraries(jingle_peerconnection_so
        absl::optional
        absl::variant
        absl::strings
        crypto
        event
        #json
        opus
        pffft
        protobuf_lite
        rnnoise
        srtp
        ssl
        usrsctp
        vpx
        openh264
        ffmpeg
        yuv

        android
        log
        GLESv2
        OpenSLES
    )
endif()