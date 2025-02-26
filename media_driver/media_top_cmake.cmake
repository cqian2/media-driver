# Copyright (c) 2017-2022, Intel Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

project( media )

find_package(PkgConfig)
find_package(X11)
find_package(Backtrace)

# to get access to generated header files
include_directories(${CMAKE_BINARY_DIR})

bs_set_if_undefined(LIB_NAME iHD_drv_video)

option (MEDIA_RUN_TEST_SUITE "run google test module after install" ON) 
include(${MEDIA_DRIVER_CMAKE}/media_gen_flags.cmake)
include(${MEDIA_DRIVER_CMAKE}/media_feature_flags.cmake)


if(NOT DEFINED SKIP_GMM_CHECK)
    # checking dependencies
    pkg_check_modules(LIBGMM REQUIRED igdgmm>=12.0.0)

    if(LIBGMM_FOUND)
        include_directories(BEFORE ${LIBGMM_INCLUDE_DIRS})
        # link_directories() should appear before add_library and the like
        # otherwise it will not take effect
        link_directories(${LIBGMM_LIBRARY_DIRS})
    endif()
endif(NOT DEFINED SKIP_GMM_CHECK)

message("-- media -- PLATFORM = ${PLATFORM}")
message("-- media -- ARCH = ${ARCH}")
message("-- media -- CMAKE_CURRENT_LIST_DIR = ${CMAKE_CURRENT_LIST_DIR}")
message("-- media -- INCLUDED_LIBS = ${INCLUDED_LIBS}")
message("-- media -- LIB_NAME = ${LIB_NAME}")
message("-- media -- OUTPUT_NAME = ${OUTPUT_NAME}")
message("-- media -- BUILD_TYPE/UFO_BUILD_TYPE/CMAKE_BUILD_TYPE = ${BUILD_TYPE}/${UFO_BUILD_TYPE}/${CMAKE_BUILD_TYPE}")
message("-- media -- LIBVA_INSTALL_PATH = ${LIBVA_INSTALL_PATH}")
message("-- media -- MEDIA_VERSION = ${MEDIA_VERSION}")
if(X11_FOUND)
    message("-- media -- X11 Found")
    pkg_check_modules(LIBVAX11 libva-x11)
    if(LIBVAX11_FOUND)
        message("-- media -- LIBVAX11 Found")
    else()
        set(X11_FOUND FALSE)
    endif()
endif()

set(LIB_NAME_STATIC "${LIB_NAME}_STATIC")
set(SOURCES_ "")
set(COMMON_SOURCES_ "")
set(SOFTLET_COMMON_SOURCES_ "")
set(COMMON_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_COMMON_PRIVATE_INCLUDE_DIRS_ "")
set(VP_SOURCES_ "")
set(SOFTLET_VP_SOURCES_ "")       # softlet source group

set(VP_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_VP_PRIVATE_INCLUDE_DIRS_ "")
set(SHARED_SOURCES_ "")
set(UPDATED_SOURCES_ "")
set(SOFTLET_DDI_SOURCES_ "")
set(SOFTLET_DDI_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_DDI_PUBLIC_INCLUDE_DIRS_ "")

################################################################################
# codec
################################################################################
set(CODEC_SOURCES_ "")                  # legacy source group
set(CODEC_HEADERS_ "")
set(CODEC_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_CODEC_SOURCES_ "")          # softlet source group
set(SOFTLET_CODEC_HEADERS_ "")
set(SOFTLET_CODEC_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_CODEC_COMMON_SOURCES_ "")   # softlet codec common source group
set(SOFTLET_CODEC_COMMON_HEADERS_ "")
set(SOFTLET_CODEC_COMMON_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_ENCODE_SOURCES_ "")          # softlet encode source group
set(SOFTLET_ENCODE_HEADERS_ "")
set(SOFTLET_ENCODE_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_ENCODE_COMMON_SOURCES_ "")
set(SOFTLET_ENCODE_COMMON_HEADERS_ "")
set(SOFTLET_ENCODE_COMMON_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_ENCODE_AV1_SOURCES_ "")
set(SOFTLET_ENCODE_AV1_HEADERS_ "")
set(SOFTLET_ENCODE_AV1_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_ENCODE_HEVC_SOURCES_ "")
set(SOFTLET_ENCODE_HEVC_HEADERS_ "")
set(SOFTLET_ENCODE_HEVC_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_ENCODE_AVC_SOURCES_ "")
set(SOFTLET_ENCODE_AVC_HEADERS_ "")
set(SOFTLET_ENCODE_AVC_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_ENCODE_VP9_SOURCES_ "")
set(SOFTLET_ENCODE_VP9_HEADERS_ "")
set(SOFTLET_ENCODE_VP9_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_ENCODE_JPEG_SOURCES_ "")
set(SOFTLET_ENCODE_JPEG_HEADERS_ "")
set(SOFTLET_ENCODE_JPEG_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_DECODE_SOURCES_ "")          # softlet decode source group
set(SOFTLET_DECODE_HEADERS_ "")
set(SOFTLET_DECODE_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_DECODE_COMMON_SOURCES_ "")
set(SOFTLET_DECODE_COMMON_HEADERS_ "")
set(SOFTLET_DECODE_COMMON_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_DECODE_AVC_SOURCES_ "")
set(SOFTLET_DECODE_AVC_HEADERS_ "")
set(SOFTLET_DECODE_AVC_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_DECODE_HEVC_SOURCES_ "")
set(SOFTLET_DECODE_HEVC_HEADERS_ "")
set(SOFTLET_DECODE_HEVC_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_DECODE_JPEG_SOURCES_ "")
set(SOFTLET_DECODE_JPEG_HEADERS_ "")
set(SOFTLET_DECODE_JPEG_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_DECODE_MPEG2_SOURCES_ "")
set(SOFTLET_DECODE_MPEG2_HEADERS_ "")
set(SOFTLET_DECODE_MPEG2_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_DECODE_VP9_SOURCES_ "")
set(SOFTLET_DECODE_VP9_HEADERS_ "")
set(SOFTLET_DECODE_VP9_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_DECODE_AV1_SOURCES_ "")
set(SOFTLET_DECODE_AV1_HEADERS_ "")
set(SOFTLET_DECODE_AV1_PRIVATE_INCLUDE_DIRS_ "")
set(SOFTLET_DECODE_VP8_SOURCES_ "")
set(SOFTLET_DECODE_VP8_HEADERS_ "")
set(SOFTLET_DECODE_VP8_PRIVATE_INCLUDE_DIRS_ "")

set(SOFTLET_CODEC_EXT_SOURCES_ "")
set(SOFTLET_CODEC_EXT_HEADERS_ "")
set(SOFTLET_CODEC_EXT_PRIVATE_INCLUDE_DIRS_ "")

######################################################
#MOS LIB
set (MOS_COMMON_SOURCES_ "")
set (MOS_COMMON_HEADERS_ "")
set (MOS_PRIVATE_SOURCES_ "")
set (MOS_PUBLIC_INCLUDE_DIRS_ "")
set (MOS_PRIVATE_INCLUDE_DIRS_ "")
set (MOS_PREPEND_INCLUDE_DIRS_ "")
set (MOS_EXT_INCLUDE_DIRS_ "")

set (SOFTLET_MOS_COMMON_SOURCES_ "")
set (SOFTLET_MOS_COMMON_HEADERS_ "")
set (SOFTLET_MOS_PRIVATE_SOURCES_ "")
set (SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_ "")
set (SOFTLET_MOS_PRIVATE_INCLUDE_DIRS_ "")
set (SOFTLET_MOS_PREPEND_INCLUDE_DIRS_ "")
set (SOFTLET_MOS_EXT_INCLUDE_DIRS_ "")
######################################################

######################################################
#CP LIB
set(CP_COMMON_HEADERS_ "")        # legacy source group
set(CP_COMMON_SOURCES_ "")
set(CP_COMMON_SHARED_HEADERS_ "") # legacy and softlet shared source group
set(CP_COMMON_SHARED_SOURCES_ "")
set(CP_COMMON_NEXT_HEADERS_ "")   # softlet source group
set(CP_COMMON_NEXT_SOURCES_ "")   
set(CP_SOURCES_ "")               # common + os part
######################################################

# add source
# first
media_include_subdirectory(../media_common/agnostic)
media_include_subdirectory(../media_common/linux)

# second
media_include_subdirectory(agnostic)
media_include_subdirectory(linux)
media_include_subdirectory(media_softlet)
media_include_subdirectory(media_interface)
media_include_subdirectory(../media_softlet/agnostic)
media_include_subdirectory(../media_softlet/linux)
media_include_subdirectory(../media_softlet/media_interface)

include(${MEDIA_EXT}/media_srcs_ext.cmake OPTIONAL)
include(${MEDIA_COMMON_EXT}/media_srcs_ext.cmake OPTIONAL)
include(${MEDIA_SOFTLET_EXT}/media_srcs_ext.cmake OPTIONAL)

include(${MEDIA_DRIVER_CMAKE}/media_include_paths.cmake)

include(${MEDIA_DRIVER_CMAKE}/media_compile_flags.cmake)

#
# set platform specific defines
#
bs_set_defines()

set_source_files_properties(${SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${COMMON_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${SOFTLET_COMMON_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${CODEC_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${SOFTLET_CODEC_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${SOFTLET_ENCODE_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${SOFTLET_DECODE_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${VP_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${SOFTLET_VP_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${CP_COMMON_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${CP_COMMON_SHARED_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${CP_COMMON_NEXT_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${CP_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${SOFTLET_DDI_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${SOURCES_SSE2} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${SOURCES_SSE4} PROPERTIES LANGUAGE "CXX")

#CODEC SETTINGS
set(SOFTLET_ENCODE_SOURCES_
${SOFTLET_ENCODE_SOURCES_}
${SOFTLET_ENCODE_COMMON_SOURCES_}
${SOFTLET_ENCODE_AV1_SOURCES_}
${SOFTLET_ENCODE_HEVC_SOURCES_}
${SOFTLET_ENCODE_AVC_SOURCES_}
${SOFTLET_ENCODE_VP9_SOURCES_}
${SOFTLET_ENCODE_JPEG_SOURCES_}
)

set(SOFTLET_DECODE_SOURCES_
${SOFTLET_DECODE_SOURCES_}
${SOFTLET_DECODE_COMMON_SOURCES_}
${SOFTLET_DECODE_AVC_SOURCES_}
${SOFTLET_DECODE_HEVC_SOURCES_}
${SOFTLET_DECODE_JPEG_SOURCES_}
${SOFTLET_DECODE_MPEG2_SOURCES_}
${SOFTLET_DECODE_VP9_SOURCES_}
${SOFTLET_DECODE_AV1_SOURCES_}
${SOFTLET_DECODE_VP8_SOURCES_}
)

set(SOFTLET_CODEC_SOURCES_
${SOFTLET_CODEC_SOURCES_}
${SOFTLET_CODEC_COMMON_SOURCES_}
${SOFTLET_ENCODE_SOURCES_}
${SOFTLET_DECODE_SOURCES_}
${SOFTLET_CODEC_EXT_SOURCES_}
)

set(SOFTLET_ENCODE_HEADERS_
${SOFTLET_ENCODE_HEADERS_}
${SOFTLET_ENCODE_COMMON_HEADERS_}
${SOFTLET_ENCODE_AV1_HEADERS_}
${SOFTLET_ENCODE_HEVC_HEADERS_}
${SOFTLET_ENCODE_AVC_HEADERS_}
${SOFTLET_ENCODE_VP9_HEADERS_}
${SOFTLET_ENCODE_JPEG_HEADERS_}
)

set(SOFTLET_DECODE_HEADERS_
${SOFTLET_DECODE_HEADERS_}
${SOFTLET_DECODE_COMMON_HEADERS_}
${SOFTLET_DECODE_AVC_HEADERS_}
${SOFTLET_DECODE_HEVC_HEADERS_}
${SOFTLET_DECODE_JPEG_HEADERS_}
${SOFTLET_DECODE_MPEG2_HEADERS_}
${SOFTLET_DECODE_VP9_HEADERS_}
${SOFTLET_DECODE_AV1_HEADERS_}
${SOFTLET_DECODE_VP8_HEADERS_}
)

set(SOFTLET_CODEC_HEADERS_
${SOFTLET_CODEC_HEADERS_}
${SOFTLET_CODEC_COMMON_HEADERS_}
${SOFTLET_ENCODE_HEADERS_}
${SOFTLET_DECODE_HEADERS_}
${SOFTLET_CODEC_EXT_HEADERS_}
)

set(SOFTLET_ENCODE_PRIVATE_INCLUDE_DIRS_
${SOFTLET_ENCODE_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_ENCODE_COMMON_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_ENCODE_AV1_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_ENCODE_HEVC_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_ENCODE_AVC_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_ENCODE_VP9_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_ENCODE_JPEG_PRIVATE_INCLUDE_DIRS_}
)

set(SOFTLET_DECODE_PRIVATE_INCLUDE_DIRS_
${SOFTLET_DECODE_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_DECODE_COMMON_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_DECODE_AVC_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_DECODE_HEVC_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_DECODE_JPEG_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_DECODE_MPEG2_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_DECODE_VP9_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_DECODE_AV1_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_DECODE_VP8_PRIVATE_INCLUDE_DIRS_}
)

set(SOFTLET_CODEC_PRIVATE_INCLUDE_DIRS_
${SOFTLET_CODEC_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_CODEC_COMMON_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_ENCODE_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_DECODE_PRIVATE_INCLUDE_DIRS_}
${SOFTLET_CODEC_EXT_PRIVATE_INCLUDE_DIRS_}
)

set (CODEC_SOURCES_
    ${CODEC_SOURCES_}
    ${SOFTLET_CODEC_SOURCES_})

set (CP_SOURCES_
    ${CP_SOURCES_}
    ${CP_COMMON_SOURCES_}
    ${CP_COMMON_SHARED_SOURCES_}
    ${CP_COMMON_NEXT_SOURCES_})

set (SHARED_SOURCES_
    ${SHARED_SOURCES_}
    ${COMMON_SOURCES_}
    ${CODEC_SOURCES_}
    ${VP_SOURCES_}
    ${CP_SOURCES_})

FOREACH(SRC1 ${SOURCES_})
    set (FOUND 0)
    FOREACH(SRC2 ${SHARED_SOURCES_})
        if (${SRC1} STREQUAL ${SRC2})
            set (FOUND 1)
            break()
        endif()
    ENDFOREACH()
    if (NOT ${FOUND} EQUAL 1)
        set (UPDATED_SOURCES_
            ${UPDATED_SOURCES_}
            ${SRC1})
    endif()
ENDFOREACH()

set (COMMON_SOURCES_
    ${COMMON_SOURCES_}
    ${UPDATED_SOURCES_}
    ${SOFTLET_DDI_SOURCES_})

set(COMMON_PRIVATE_INCLUDE_DIRS_
    ${COMMON_PRIVATE_INCLUDE_DIRS_}
    ${SOFTLET_COMMON_PRIVATE_INCLUDE_DIRS_})

set (VP_PRIVATE_INCLUDE_DIRS_
    ${VP_PRIVATE_INCLUDE_DIRS_}
    ${SOFTLET_VP_PRIVATE_INCLUDE_DIRS_})

add_library(${LIB_NAME}_SSE2 OBJECT ${SOURCES_SSE2})
target_compile_options(${LIB_NAME}_SSE2 PRIVATE -msse2)
target_include_directories(${LIB_NAME}_SSE2 BEFORE PRIVATE ${SOFTLET_MOS_PREPEND_INCLUDE_DIRS_} ${MOS_PUBLIC_INCLUDE_DIRS_} ${SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_} ${COMMON_PRIVATE_INCLUDE_DIRS_} ${SOFTLET_DDI_PUBLIC_INCLUDE_DIRS_})

add_library(${LIB_NAME}_SSE4 OBJECT ${SOURCES_SSE4})
target_compile_options(${LIB_NAME}_SSE4 PRIVATE -msse4.1)
target_include_directories(${LIB_NAME}_SSE4 BEFORE PRIVATE ${SOFTLET_MOS_PREPEND_INCLUDE_DIRS_} ${MOS_PUBLIC_INCLUDE_DIRS_} ${SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_} ${COMMON_PRIVATE_INCLUDE_DIRS_} ${SOFTLET_DDI_PUBLIC_INCLUDE_DIRS_})

add_library(${LIB_NAME}_COMMON OBJECT ${COMMON_SOURCES_})
set_property(TARGET ${LIB_NAME}_COMMON PROPERTY POSITION_INDEPENDENT_CODE 1)
MediaAddCommonTargetDefines(${LIB_NAME}_COMMON)
target_include_directories(${LIB_NAME}_COMMON  BEFORE PRIVATE ${SOFTLET_MOS_PREPEND_INCLUDE_DIRS_} ${MOS_PUBLIC_INCLUDE_DIRS_} ${SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_}  ${COMMON_PRIVATE_INCLUDE_DIRS_} ${SOFTLET_CODEC_PRIVATE_INCLUDE_DIRS_} ${VP_PRIVATE_INCLUDE_DIRS_} ${COMMON_CP_DIRECTORIES_} ${SOFTLET_DDI_PUBLIC_INCLUDE_DIRS_})

add_library(${LIB_NAME}_SOFTLET_COMMON OBJECT ${SOFTLET_COMMON_SOURCES_})
set_property(TARGET ${LIB_NAME}_SOFTLET_COMMON PROPERTY POSITION_INDEPENDENT_CODE 1)
MediaAddCommonTargetDefines(${LIB_NAME}_SOFTLET_COMMON)
target_include_directories(${LIB_NAME}_SOFTLET_COMMON BEFORE PRIVATE
    ${SOFTLET_MOS_PREPEND_INCLUDE_DIRS_}
    ${SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_}
    ${SOFTLET_COMMON_PRIVATE_INCLUDE_DIRS_}
    ${SOFTLET_CODEC_PRIVATE_INCLUDE_DIRS_}
    ${SOFTLET_VP_PRIVATE_INCLUDE_DIRS_}
    ${SOFTLET_DDI_PUBLIC_INCLUDE_DIRS_}
    ${CP_INTERFACE_DIRECTORIES_}
)

add_library(${LIB_NAME}_CODEC OBJECT ${CODEC_SOURCES_})
set_property(TARGET ${LIB_NAME}_CODEC PROPERTY POSITION_INDEPENDENT_CODE 1)
MediaAddCommonTargetDefines(${LIB_NAME}_CODEC)
target_include_directories(${LIB_NAME}_CODEC BEFORE PRIVATE ${SOFTLET_MOS_PREPEND_INCLUDE_DIRS_} ${MOS_PUBLIC_INCLUDE_DIRS_} ${SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_} ${COMMON_PRIVATE_INCLUDE_DIRS_} ${SOFTLET_CODEC_PRIVATE_INCLUDE_DIRS_} ${VP_PRIVATE_INCLUDE_DIRS_} ${COMMON_CP_DIRECTORIES_} ${SOFTLET_DDI_PUBLIC_INCLUDE_DIRS_})

add_library(${LIB_NAME}_VP OBJECT ${VP_SOURCES_})
set_property(TARGET ${LIB_NAME}_VP PROPERTY POSITION_INDEPENDENT_CODE 1)
MediaAddCommonTargetDefines(${LIB_NAME}_VP)
target_include_directories(${LIB_NAME}_VP BEFORE PRIVATE ${SOFTLET_MOS_PREPEND_INCLUDE_DIRS_} ${MOS_PUBLIC_INCLUDE_DIRS_} ${SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_} ${COMMON_PRIVATE_INCLUDE_DIRS_} ${VP_PRIVATE_INCLUDE_DIRS_} ${COMMON_CP_DIRECTORIES_} ${SOFTLET_DDI_PUBLIC_INCLUDE_DIRS_} ${SOFTLET_CODEC_PRIVATE_INCLUDE_DIRS_})

add_library(${LIB_NAME}_SOFTLET_VP OBJECT ${SOFTLET_VP_SOURCES_})
set_property(TARGET ${LIB_NAME}_SOFTLET_VP PROPERTY POSITION_INDEPENDENT_CODE 1)
MediaAddCommonTargetDefines(${LIB_NAME}_SOFTLET_VP)
target_include_directories(${LIB_NAME}_SOFTLET_VP BEFORE PRIVATE
    ${SOFTLET_MOS_PREPEND_INCLUDE_DIRS_}
    ${SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_}
    ${SOFTLET_COMMON_PRIVATE_INCLUDE_DIRS_}
    ${SOFTLET_VP_PRIVATE_INCLUDE_DIRS_}
    ${SOFTLET_DDI_PUBLIC_INCLUDE_DIRS_}
    ${SOFTLET_CODEC_PRIVATE_INCLUDE_DIRS_}
    ${CP_INTERFACE_DIRECTORIES_}
)

add_library(${LIB_NAME}_CP OBJECT ${CP_SOURCES_})
set_property(TARGET ${LIB_NAME}_CP PROPERTY POSITION_INDEPENDENT_CODE 1)
MediaAddCommonTargetDefines(${LIB_NAME}_CP)
target_include_directories(${LIB_NAME}_CP BEFORE PRIVATE ${SOFTLET_MOS_PREPEND_INCLUDE_DIRS_} ${MOS_PUBLIC_INCLUDE_DIRS_} ${SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_} ${COMMON_PRIVATE_INCLUDE_DIRS_} ${SOFTLET_CODEC_PRIVATE_INCLUDE_DIRS_} ${VP_PRIVATE_INCLUDE_DIRS_} ${COMMON_CP_DIRECTORIES_} ${SOFTLET_DDI_PUBLIC_INCLUDE_DIRS_})

#DDI LIB
if(NOT "${SOFTLET_DDI_SOURCES_}" STREQUAL "")
    add_library(${LIB_NAME}_SOFTLET_DDI OBJECT ${SOFTLET_DDI_SOURCES_})
    set_property(TARGET ${LIB_NAME}_SOFTLET_DDI PROPERTY POSITION_INDEPENDENT_CODE 1)
    set_property(TARGET ${LIB_NAME}_SOFTLET_DDI APPEND PROPERTY COMPILE_DEFINITIONS MEDIA_SOFTLET)
    MediaAddCommonTargetDefines(${LIB_NAME}_SOFTLET_DDI)
    target_include_directories(${LIB_NAME}_SOFTLET_DDI BEFORE PRIVATE ${SOFTLET_MOS_PREPEND_INCLUDE_DIRS_} ${MOS_PUBLIC_INCLUDE_DIRS_} ${SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_} ${COMMON_PRIVATE_INCLUDE_DIRS_} ${VP_PRIVATE_INCLUDE_DIRS_} ${COMMON_CP_DIRECTORIES_} ${SOFTLET_DDI_PUBLIC_INCLUDE_DIRS_} ${SOFTLET_DDI_PRIVATE_INCLUDE_DIRS_} ${SOFTLET_CODEC_PRIVATE_INCLUDE_DIRS_})
endif()

######################################################
#MOS LIB
############## MOS ########################################
set_source_files_properties(${MOS_COMMON_SOURCES_} PROPERTIES LANGUAGE "CXX")
set_source_files_properties(${SOFTLET_MOS_COMMON_SOURCES_} PROPERTIES LANGUAGE "CXX")

#1 non softlet mos lib

set (MOS_EXT_INCLUDE_DIRS_
${BS_DIR_MEDIA}/cmrtlib/linux/hardware  # This is to include drm_device.h in cmrtlib, no cpp file needed.
)

add_library(${LIB_NAME}_mos OBJECT ${MOS_COMMON_SOURCES_} ${SOFTLET_MOS_COMMON_SOURCES_})
set_property(TARGET ${LIB_NAME}_mos PROPERTY POSITION_INDEPENDENT_CODE 1)
MediaAddCommonTargetDefines(${LIB_NAME}_mos)
target_include_directories(${LIB_NAME}_mos BEFORE PRIVATE
    ${SOFTLET_MOS_PREPEND_INCLUDE_DIRS_}
    ${SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_}
    ${MOS_PUBLIC_INCLUDE_DIRS_}
    ${MOS_EXT_INCLUDE_DIRS_}
    ${COMMON_PRIVATE_INCLUDE_DIRS_}
    ${VP_PRIVATE_INCLUDE_DIRS_}
    ${SOFTLET_DDI_PUBLIC_INCLUDE_DIRS_}
)

#2 softlet mos lib

set (SOFTLET_MOS_EXT_INCLUDE_DIRS_
${SOFTLET_MOS_EXT_INCLUDE_DIRS_}
${BS_DIR_MEDIA}/cmrtlib/linux/hardware # This is to include drm_device.h in cmrtlib, no cpp file needed.
${MEDIA_COMMON}/agnostic/common/media_interfaces
${MEDIA_COMMON}/agnostic/common/shared
${MEDIA_COMMON}/agnostic/common/shared/user_setting
${MEDIA_COMMON}/linux/common/cp/os
${MEDIA_SOFTLET}/agnostic/common/media_interfaces
${MEDIA_SOFTLET}/agnostic/common/shared
${MEDIA_SOFTLET}/agnostic/common/shared/mediacopy
${MEDIA_SOFTLET}/linux/common/ddi
)

add_library(${LIB_NAME}_mos_softlet OBJECT ${SOFTLET_MOS_COMMON_SOURCES_} ${SOFTLET_MOS_PRIVATE_SOURCES_})
set_property(TARGET ${LIB_NAME}_mos_softlet PROPERTY POSITION_INDEPENDENT_CODE 1)
MediaAddCommonTargetDefines(${LIB_NAME}_mos_softlet)
target_include_directories(${LIB_NAME}_mos_softlet BEFORE PRIVATE
    ${SOFTLET_MOS_PREPEND_INCLUDE_DIRS_}
    ${SOFTLET_MOS_PUBLIC_INCLUDE_DIRS_}
    ${SOFTLET_MOS_EXT_INCLUDE_DIRS_}
)
############## MOS LIB END ########################################

############## Media Driver Static and Shared Lib #################
add_library(${LIB_NAME} SHARED
    $<TARGET_OBJECTS:${LIB_NAME}_mos>
    $<TARGET_OBJECTS:${LIB_NAME}_COMMON>
    $<TARGET_OBJECTS:${LIB_NAME}_CODEC>
    $<TARGET_OBJECTS:${LIB_NAME}_VP>
    $<TARGET_OBJECTS:${LIB_NAME}_CP>
    $<TARGET_OBJECTS:${LIB_NAME}_SSE2>
    $<TARGET_OBJECTS:${LIB_NAME}_SSE4>
    $<TARGET_OBJECTS:${LIB_NAME}_SOFTLET_VP>
    $<TARGET_OBJECTS:${LIB_NAME}_SOFTLET_COMMON>)


add_library(${LIB_NAME_STATIC} STATIC
    $<TARGET_OBJECTS:${LIB_NAME}_mos>
    $<TARGET_OBJECTS:${LIB_NAME}_COMMON>
    $<TARGET_OBJECTS:${LIB_NAME}_CODEC>
    $<TARGET_OBJECTS:${LIB_NAME}_VP>
    $<TARGET_OBJECTS:${LIB_NAME}_CP>
    $<TARGET_OBJECTS:${LIB_NAME}_SSE2>
    $<TARGET_OBJECTS:${LIB_NAME}_SSE4>
    $<TARGET_OBJECTS:${LIB_NAME}_SOFTLET_VP>
    $<TARGET_OBJECTS:${LIB_NAME}_SOFTLET_COMMON>)

set_target_properties(${LIB_NAME_STATIC} PROPERTIES OUTPUT_NAME ${LIB_NAME})

option(MEDIA_BUILD_FATAL_WARNINGS "Turn compiler warnings into fatal errors" ON)
if(MEDIA_BUILD_FATAL_WARNINGS)
    set_target_properties(${LIB_NAME}_COMMON PROPERTIES COMPILE_FLAGS "-Werror")
    set_target_properties(${LIB_NAME}_CODEC PROPERTIES COMPILE_FLAGS "-Werror")
    set_target_properties(${LIB_NAME}_VP PROPERTIES COMPILE_FLAGS "-Werror")
    set_target_properties(${LIB_NAME}_CP PROPERTIES COMPILE_FLAGS "-Werror")
    set_target_properties(${LIB_NAME}_mos PROPERTIES COMPILE_FLAGS "-Werror")
    set_target_properties(${LIB_NAME}_SOFTLET_VP PROPERTIES COMPILE_FLAGS "-Werror")
    set_target_properties(${LIB_NAME}_SOFTLET_COMMON PROPERTIES COMPILE_FLAGS "-Werror")
endif()

set(MEDIA_LINK_FLAGS "-Wl,--no-as-needed -Wl,--gc-sections -z relro -z now -fPIC")
option(MEDIA_BUILD_HARDENING "Enable hardening (stack-protector, fortify source)" ON)
if(MEDIA_BUILD_HARDENING)
    set(MEDIA_LINK_FLAGS "${MEDIA_LINK_FLAGS} -fstack-protector")
endif()
set_target_properties(${LIB_NAME} PROPERTIES LINK_FLAGS ${MEDIA_LINK_FLAGS})

set_target_properties(${LIB_NAME}        PROPERTIES PREFIX "")
set_target_properties(${LIB_NAME_STATIC} PROPERTIES PREFIX "")

set(MEDIA_LINK_EXTERNAL_LIBS "${PKG_PCIACCESS_LIBRARIES} m pthread dl")
if(Backtrace_FOUND)
    set(MEDIA_LINK_EXTERNAL_LIBS "${MEDIA_LINK_EXTERNAL_LIBS} ${Backtrace_LIBRARY}")
endif()

bs_ufo_link_libraries_noBsymbolic(
    ${LIB_NAME}
    "${INCLUDED_LIBS}"
    "${MEDIA_LINK_EXTERNAL_LIBS}"
)

if (NOT DEFINED INCLUDED_LIBS OR "${INCLUDED_LIBS}" STREQUAL "")
    # dep libs (gmmlib for now) can be passed through INCLUDED_LIBS, but if not, we need try to setup dep through including dep projects
    if(NOT LIBGMM_FOUND)
        # If we failed to setup dependency from gmmlib via pkg-config we will try to
        # add gmmlib as a target from sources. We need to do this here, after
        # add_library() for iHD driver since gmmlib needs this information.
        if (NOT TARGET igfx_gmmumd_dll)
            add_subdirectory("${BS_DIR_GMMLIB}" "${CMAKE_BINARY_DIR}/gmmlib")
        endif()
        if (NOT TARGET igfx_gmmumd_dll)
            message(FATAL_ERROR "gmm library not found on the system")
        endif()
        set(LIBGMM_CFLAGS_OTHER -DGMM_LIB_DLL)
        set(LIBGMM_LIBRARIES igfx_gmmumd_dll)
    endif()

    target_compile_options( ${LIB_NAME} PUBLIC ${LIBGMM_CFLAGS_OTHER})
    target_link_libraries ( ${LIB_NAME} ${LIBGMM_LIBRARIES})

    include(${MEDIA_EXT_CMAKE}/ext/media_feature_include_ext.cmake OPTIONAL)

endif(NOT DEFINED INCLUDED_LIBS OR "${INCLUDED_LIBS}" STREQUAL "")

############## Media Driver Static and Shared Lib ##################

# post target attributes
bs_set_post_target()

if(MEDIA_RUN_TEST_SUITE AND ENABLE_KERNELS AND ENABLE_NONFREE_KERNELS AND "${CMAKE_BUILD_TYPE}" STREQUAL "ReleaseInternal")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/linux/ult)
    include(${MEDIA_EXT}/media_softlet/ult/ult_top_cmake.cmake OPTIONAL)
endif()
