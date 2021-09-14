cmake_minimum_required (VERSION 2.6)
SET(CMAKE_COLOR_MAKEFILE ON)
SET(CMAKE_VERBOSE_MAKEFILE OFF)
project (slingscold)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../cmake/vala )

find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED gtk+-3.0 gee-0.8 gio-unix-2.0 gio-2.0 libpeas-gtk-1.0 budgie-1.0 gobject-2.0 )

add_definitions(${DEPS_CFLAGS})

link_libraries(${DEPS_LIBRARIES})

link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.14.0" MINIMUM)

include(ValaPrecompile)
vala_precompile(VALA_C
    Slingscold.vala
PACKAGES
    gtk+-3.0
    gee-0.8
    gio-unix-2.0
    gio-2.0
    libpeas-gtk-1.0
    gobject-2.0
    budgie-1.0
OPTIONS
)

add_definitions(${CFLAGS} -Wall -Winit-self -Wwrite-strings -Wunreachable-code
                          -Wstrict-prototypes -DGMENU_I_KNOW_THIS_IS_UNSTABLE)
add_library(slingscold SHARED ${VALA_C})
target_link_libraries(slingscold m)

install(TARGETS slingscold DESTINATION /usr/lib/budgie-desktop/plugins/slingscold-launcher)
install(FILES Slingscold.plugin DESTINATION /usr/lib/budgie-desktop/plugins/slingscold-launcher)
