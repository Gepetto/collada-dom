cmake_minimum_required (VERSION 3.10)
project (collada-dom)
set( CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS TRUE )

# Define here the needed parameters
set (COLLADA_DOM_VERSION_MAJOR 2)
set (COLLADA_DOM_VERSION_MINOR 5)
set (COLLADA_DOM_VERSION_PATCH 4)
set (COLLADA_DOM_VERSION ${COLLADA_DOM_VERSION_MAJOR}.${COLLADA_DOM_VERSION_MINOR}.${COLLADA_DOM_VERSION_PATCH})
set (COLLADA_DOM_SOVERSION ${COLLADA_DOM_VERSION_MAJOR}.${COLLADA_DOM_VERSION_MINOR})

message(STATUS "Compiling Collada DOM Version ${COLLADA_DOM_VERSION}")
message(STATUS "Using cmake version ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" )

# Use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_SKIP_BUILD_RPATH  FALSE)

# When building, don't use the install RPATH already
# (but later on when installing)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

# The RPATH to be used when installing
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}")

# Add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

message(STATUS "installing to ${CMAKE_INSTALL_PREFIX}")

##############################################################################
# Custom CMake options
##############################################################################

option(OPT_COLLADA15 "Enable collada 1.5 compilation" ON)
option(OPT_COLLADA14 "Enable collada 1.4 compilation" ON)
option(OPT_COMPILE_VIEWER "Enable collada viewer compilation" OFF)
option(OPT_COMPILE_FX "Enable collada fx compilation" OFF)
option(OPT_COMPILE_RT "Enable collada rt compilation" OFF)
option(OPT_COMPILE_TESTS "Compile collada tests" OFF)
option(OPT_BUILD_PACKAGES "Set to ON to generate CPack configuration files and packaging targets" OFF)
option(OPT_BUILD_PACKAGE_DEFAULT "Set to ON to generate a default openrave package that creates symlinks" ON)
option(OPT_DOUBLE_PRECISION "Use double precision for everything (daeFloat included)" ON)

set(COLLADA_DOM_EXTERNAL_FLAGS)
if( OPT_COLLADA14 )
  set(COLLADA_DOM_EXTERNAL_FLAGS "${COLLADA_DOM_EXTERNAL_FLAGS} -DCOLLADA_DOM_SUPPORT141")
endif()
if( OPT_COLLADA15 )
  set(COLLADA_DOM_EXTERNAL_FLAGS "${COLLADA_DOM_EXTERNAL_FLAGS} -DCOLLADA_DOM_SUPPORT150")
endif()

set(CPACK_DEBIAN_PACKAGE_NAME collada-dom${COLLADA_DOM_SOVERSION})
if(OPT_DOUBLE_PRECISION)
  set(COLLADA_PRECISION "dp")
  set(CPACK_DEBIAN_PACKAGE_CONFLICTS "${CPACK_DEBIAN_PACKAGE_NAME}-sp")
  set(CPACK_DEBIAN_PACKAGE_NAME "${CPACK_DEBIAN_PACKAGE_NAME}-dp")
  set(COLLADA_DOM_EXTERNAL_FLAGS "${COLLADA_DOM_EXTERNAL_FLAGS} -DCOLLADA_DOM_DAEFLOAT_IS64") # daeFloat is 64 bit
  message(STATUS "compiling with double float precision")
else()
  set(COLLADA_PRECISION "sp")
  set(CPACK_DEBIAN_PACKAGE_CONFLICTS "${CPACK_DEBIAN_PACKAGE_NAME}-dp")
  set(CPACK_DEBIAN_PACKAGE_NAME "${CPACK_DEBIAN_PACKAGE_NAME}-sp")
  message(STATUS "compiling with single float precision")
endif()


if( OPT_COMPILE_VIEWER )
  message(WARNING "compiling collada viewer currently not supported")
endif()
if( OPT_COMPILE_FX )
  message(WARNING "compiling collada fx currently not supported")
endif()
if( OPT_COMPILE_RT )
  message(WARNING "compiling collada rt currently not supported")
endif()

set(PACKAGE_VERSION "0" CACHE STRING "the package-specific version used for uploading the sources")

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules")
set(COMPONENT_PREFIX "${CPACK_DEBIAN_PACKAGE_NAME}")
string(TOUPPER ${COMPONENT_PREFIX} COMPONENT_PREFIX_UPPER)
set(CPACK_COMPONENTS_ALL ${COMPONENT_PREFIX}-base ${COMPONENT_PREFIX}-dev)

if( MSVC )
  if( MSVC70 OR MSVC71 )
    set(MSVC_PREFIX "vc70")
  elseif( MSVC80 )
    set(MSVC_PREFIX "vc80")
  elseif( MSVC90 )
    set(MSVC_PREFIX "vc90")
  else()
    set(MSVC_PREFIX "vc100")
  endif()
  set(COLLADA_DOM_LIBRARY_SUFFIX "${COLLADA_DOM_SOVERSION}-${COLLADA_PRECISION}-${MSVC_PREFIX}-mt")
else()
  set(COLLADA_DOM_LIBRARY_SUFFIX "${COLLADA_DOM_SOVERSION}-${COLLADA_PRECISION}")
endif()

include(CheckIncludeFile)
include(CheckIncludeFileCXX)
include(CheckLibraryExists)
include(CheckFunctionExists)
include(CheckCXXSourceCompiles)
#include(CheckCXXSourceRuns)
#include(CheckCXXCompilerFlag)
include(CheckTypeSize)
find_package(PkgConfig)

if( CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX )
  add_definitions("-fno-strict-aliasing -Wall")
endif()

if( CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX )
  set(CMAKE_CXX_FLAGS_RELEASE "-O2")# -DNDEBUG -DBOOST_DISABLE_ASSERTS -D_SECURE_SCL=0") # this practically removes all checks making it a very dangerous options to play with
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g")
  set(CMAKE_CXX_FLAGS_DEBUG "-g -D_DEBUG")
endif()

if( UNIX OR CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX )
  set(STDC_LIBRARY stdc++)
else()
  set(STDC_LIBRARY)
endif()

if( APPLE OR ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  # apple doesn't have 64bit versions of file opening functions, so add them
  add_definitions("-Dfopen64=fopen")
  add_definitions("-Dfseeko64=fseeko")
  add_definitions("-Dfseek64=fseek")
  add_definitions("-Dftell64=ftell")
  add_definitions("-Dftello64=ftello")
endif()

set(COLLADA_DOM_INCLUDE_INSTALL_DIR "include/collada-dom${COLLADA_DOM_SOVERSION}")

set(COLLADA_DOM_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/dom/include)
set(COLLADA_DOM_LINK_DIRS "")

if( MSVC )
  # force multi-threaded DLL boost
  set(Boost_USE_MULTITHREAD ON)
  set(Boost_USE_STATIC_LIBS OFF)
  set(Boost_USE_STATIC_RUNTIME OFF)
  set(Boost_CFLAGS "-DBOOST_ALL_DYN_LINK -DBOOST_ALL_NO_LIB")
endif()

find_package(Boost COMPONENTS filesystem REQUIRED CONFIG)

message(STATUS "found boost version: ${Boost_VERSION}")

if( Boost_FOUND )
  include_directories(${Boost_INCLUDE_DIRS})
  set(COLLADA_DOM_LINK_DIRS ${COLLADA_DOM_LINK_DIRS} ${Boost_LIBRARY_DIRS})
elseif(Boost_VERSION AND NOT "${Boost_VERSION}" STREQUAL "0")
  include_directories(${Boost_INCLUDE_DIRS})
  set(COLLADA_DOM_LINK_DIRS ${COLLADA_DOM_LINK_DIRS} ${Boost_LIBRARY_DIRS})
else()
  message(FATAL_ERROR "Could not find boost libraries!")
endif()

set(COLLADA_DOM_BOOST_INCLUDE_DIRS)
foreach(idir ${Boost_INCLUDE_DIRS})
  set(COLLADA_DOM_BOOST_INCLUDE_DIRS "${COLLADA_DOM_BOOST_INCLUDE_DIRS} -I${idir}")
endforeach()

set(COLLADA_DOM_BOOST_LIB_DIRS)
foreach(ldir ${Boost_LIBRARY_DIRS})
  set(COLLADA_DOM_BOOST_LIB_DIRS "${COLLADA_DOM_BOOST_LIB_DIRS} -L${ldir}")
endforeach()

set(COMPILER_IS_CLANG FALSE)
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(COMPILER_IS_CLANG TRUE)
endif()

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR COMPILER_IS_CLANG)
  set(EXTRA_COMPILE_FLAGS "${COLLADA_DOM_EXTERNAL_FLAGS} -DCOLLADA_DOM_NAMESPACE -fPIC")
else()
  set(EXTRA_COMPILE_FLAGS "${COLLADA_DOM_EXTERNAL_FLAGS} -DCOLLADA_DOM_NAMESPACE")
endif()

find_package(ZLIB REQUIRED)
find_package(LibXml2 REQUIRED)
include_directories(SYSTEM ${LIBXML2_INCLUDE_DIR})
add_definitions(${LIBXML2_DEFINITIONS} -DDOM_INCLUDE_LIBXML)

pkg_check_modules(minizip REQUIRED minizip)
set(MINIZIP_INCLUDE_DIR ${minizip_INCLUDE_DIRS})
pkg_check_modules(liburiparser REQUIRED liburiparser)
set(liburiparser_CFLAGS_OTHERS "-DUSE_URIPARSER")
# declare minizip/zlib before libxml2! (for some reason the precompiled libxml2 libraries have zlib.h/zconf.h)
include_directories(BEFORE SYSTEM ${MINIZIP_INCLUDE_DIR})

set(COLLADA_DOM_LINK_DIRS ${COLLADA_DOM_LINK_DIRS})
link_directories(${COLLADA_DOM_LINK_DIRS})

if( OPT_COMPILE_TESTS )
  enable_testing()
endif()

add_subdirectory(dom)

if(UNIX)
  configure_file("${CMAKE_CURRENT_SOURCE_DIR}/collada-dom.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/collada-dom.pc" @ONLY IMMEDIATE)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/collada-dom.pc DESTINATION lib${LIB_SUFFIX}/pkgconfig COMPONENT ${COMPONENT_PREFIX}-dev)
endif()

if( OPT_COLLADA15 )
  if(UNIX)
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/collada-dom-150.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/collada-dom-150.pc" @ONLY IMMEDIATE)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/collada-dom-150.pc DESTINATION lib${LIB_SUFFIX}/pkgconfig COMPONENT ${COMPONENT_PREFIX}-dev)
  endif()
endif()

if( OPT_COLLADA14 )
  if(UNIX)
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/collada-dom-141.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/collada-dom-141.pc" @ONLY IMMEDIATE)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/collada-dom-141.pc DESTINATION lib${LIB_SUFFIX}/pkgconfig COMPONENT ${COMPONENT_PREFIX}-dev)
  endif()
endif()

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/collada_dom-config.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/collada_dom-config.cmake" @ONLY IMMEDIATE)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/collada_dom-config-version.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/collada_dom-config-version.cmake" @ONLY IMMEDIATE)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/collada_dom-config.cmake" "${CMAKE_CURRENT_BINARY_DIR}/collada_dom-config-version.cmake" DESTINATION "lib${LIB_SUFFIX}/cmake/collada_dom-${COLLADA_DOM_SOVERSION}" COMPONENT ${COMPONENT_PREFIX}-dev)

# add make uninstall capability
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules/cmake_uninstall.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" IMMEDIATE @ONLY)

add_custom_target(uninstall "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")

if(CMAKE_CPACK_COMMAND AND UNIX AND OPT_BUILD_PACKAGES)
  # Packing information
  set(CPACK_PACKAGE_NAME collada-dom${COLLADA_DOM_SOVERSION})
  set(CPACK_PACKAGE_CONTACT "" CACHE STRING "Package maintainer and PGP signer.")
  set(CPACK_PACKAGE_VENDOR "http://sourceforge.net/projects/collada-dom")
  set(CPACK_PACKAGE_DISPLAY_NAME "collada-dom ${COLLADA_DOM_VERSION}")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY " - COLLADA")
  if( OPT_DOUBLE_PRECISION )
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${CPACK_PACKAGE_DESCRIPTION_SUMMARY} using double precision")
  else()
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${CPACK_PACKAGE_DESCRIPTION_SUMMARY} using single precision")
  endif()
  set(CPACK_PACKAGE_VERSION ${COLLADA_DOM_VERSION}.${PACKAGE_VERSION})
  set(CPACK_PACKAGE_VERSION_MAJOR ${COLLADA_DOM_VERSION_MAJOR})
  set(CPACK_PACKAGE_VERSION_MINOR ${COLLADA_DOM_VERSION_MINOR})
  set(CPACK_PACKAGE_VERSION_PATCH ${COLLADA_DOM_VERSION_PATCH})
  set(CPACK_PACKAGE_INSTALL_DIRECTORY "collada-dom${COLLADA_DOM_SOVERSION}")
  set(CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/description)
  set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/licenses/dom_license_e.txt)

  set(CPACK_COMPONENT_${COMPONENT_PREFIX_UPPER}-BASE_DISPLAY_NAME "core libraries")
  set(CPACK_COMPONENT_${COMPONENT_PREFIX_UPPER}-DEV_DISPLAY_NAME "C++ headers and build tools")
  set(CPACK_COMPONENT_${COMPONENT_PREFIX_UPPER}-DEV_DEPENDS ${COMPONENT_PREFIX}-base)

  set(CPACK_DEBIAN_BUILD_DEPENDS debhelper cmake libxml2-dev libboost-dev zlib1g-dev libboost-filesystem-dev libboost-system-dev pkg-config libtinyxml-dev liburiparser-dev CACHE STRING "Build dependency packages")

  # debian
  set(CPACK_DEBIAN_PACKAGE_PRIORITY optional)
  set(CPACK_DEBIAN_PACKAGE_SECTION libs)
  set(CPACK_DEBIAN_PACKAGE_DEPENDS ${CPACK_COMPONENTS_ALL})
  set(CPACK_DEBIAN_PACKAGE_SUGGESTS)
  set(CPACK_DEBIAN_CMAKE_OPTIONS "-DOPT_DOUBLE_PRECISION=${OPT_DOUBLE_PRECISION} -DOPT_BUILD_PACKAGE_DEFAULT=${OPT_BUILD_PACKAGE_DEFAULT}")
  set(CPACK_DEBIAN_PACKAGE_REMOVE_SOURCE_FILES )
  set(CPACK_DEBIAN_PACKAGE_SOURCE_COPY "${CMAKE_SOURCE_DIR}/release/copydebfiles.py")
  set(CPACK_DEBIAN_CHANGELOG)
  execute_process(COMMAND lsb_release -is
    OUTPUT_VARIABLE _lsb_distribution OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE _lsb_release_failed)
  set(CPACK_DEBIAN_DISTRIBUTION_NAME ${_lsb_distribution} CACHE STRING "Name of the distrubiton")
  string(TOLOWER ${CPACK_DEBIAN_DISTRIBUTION_NAME} CPACK_DEBIAN_DISTRIBUTION_NAME)
  if( ${CPACK_DEBIAN_DISTRIBUTION_NAME} STREQUAL "ubuntu" )
    set(CPACK_DEBIAN_DISTRIBUTION_RELEASES precise quantal raring saucy trusty utopic vivid CACHE STRING "Release code-names of the distrubiton release")
  endif()
  set(CPACK_COMPONENT_COLLADA-DOM_DEPENDS ${CPACK_COMPONENTS_ALL})

  if( OPT_BUILD_PACKAGE_DEFAULT )
    set(CPACK_COMPONENT_COLLADA-DOM-DEV_DEPENDS ${CPACK_DEBIAN_PACKAGE_NAME}-dev)
    set(CPACK_COMPONENT_COLLADA-DOM-DEV_DISPLAY_NAME ${CPACK_COMPONENT_${COMPONENT_PREFIX_UPPER}-DEV_DISPLAY_NAME})
    set(CPACK_COMPONENTS_ALL ${CPACK_COMPONENTS_ALL} collada-dom-dev)
  endif()

  set(DPUT_HOST "" CACHE STRING "PPA repository to upload the debian sources")
  include(CPack)
  include(DebSourcePPA)
endif()
