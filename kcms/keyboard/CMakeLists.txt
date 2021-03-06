add_definitions(-DTRANSLATION_DOMAIN=\"kcmkeyboard\")

option(HAVE_XINPUT "X11/XCB XInput" OFF)
option(HAVE_UDEV "UDev" OFF)
option(NEW_GEOMETRY "Keyboard geometry preview" OFF)

if (X11_Xinput_FOUND AND XCB_XINPUT_FOUND)
    set(HAVE_XINPUT ON)
elseif (UDEV_FOUND)
    set(HAVE_UDEV ON)
else()
    message(STATUS "X11/XCB XInput and UDev is not found, either is required to keep layouts with keyboard hotplugging")
endif()


### kded daemon ###

set( kded_keyboard_SRCS
    keyboard_daemon.cpp
    layout_memory.cpp
    layout_memory_persister.cpp
    udev_helper.cpp
    x11_helper.cpp
    xinput_helper.cpp
    xkb_helper.cpp
    keyboard_config.cpp
    keyboard_hardware.cpp
    bindings.cpp
# next are temporary for sys tray UI
    layout_tray_icon.cpp
    layouts_menu.cpp
    flags.cpp
    xkb_rules.cpp
)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
add_library(kded_keyboard MODULE ${kded_keyboard_SRCS})
set_target_properties(kded_keyboard PROPERTIES OUTPUT_NAME keyboard)
kcoreaddons_desktop_to_json(kded_keyboard keyboard.desktop)

target_link_libraries(kded_keyboard
    Qt5::Concurrent
    Qt5::Widgets
    Qt5::X11Extras
    Qt5::Xml
    KF5::ConfigCore
    KF5::CoreAddons
    KF5::DBusAddons
    KF5::GlobalAccel
    KF5::I18n
    KF5::Notifications
    KF5::Service
    KF5::WindowSystem
    KF5::Plasma
    KF5::XmlGui
    KF5::GuiAddons
    KF5::IconThemes
    XCB::XCB
    XCB::XKB
    ${X11_LIBRARIES}
    ${X11_Xkbfile_LIB}
 )

if (HAVE_XINPUT)
    target_link_libraries(kded_keyboard ${X11_Xinput_LIB})
endif()

if (HAVE_UDEV)
    target_link_libraries(kded_keyboard ${UDEV_LIBS})
endif()

install( TARGETS kded_keyboard DESTINATION ${PLUGIN_INSTALL_DIR}/kf5/kded )

### kcm keyboard ###
include_directories("preview")

find_package(Boost)

if(Boost_FOUND)
  set(NEW_GEOMETRY ON)

  set(preview_SRCS
    preview/geometry_components.cpp
    preview/geometry_parser.cpp
    preview/kbpreviewframe.cpp
    preview/keyboardlayout.cpp
    preview/symbol_parser.cpp
    preview/keyaliases.cpp
    preview/keyboardlayout.cpp
    preview/keyboardpainter.cpp
    preview/keysymhelper.cpp
    preview/keysym2ucs.cpp
    )

   set_source_files_properties(preview/geometry_parser.cpp preview/symbol_parser.cpp PROPERTIES COMPILE_FLAGS "-fexceptions")
   if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
      # the default maximum template expansion depth (256) is not enough
      set_property(SOURCE preview/geometry_parser.cpp APPEND_STRING PROPERTY COMPILE_FLAGS " -ftemplate-depth=512")
   endif()
else(Boost_FOUND)

  message("Boost not found, install Boost libraries to enable keyboard geometry preview")

endif(Boost_FOUND)


set(kcm_keyboard_PART_SRCS
  kcm_keyboard.cpp
  kcm_keyboard_widget.cpp
  kcm_view_models.cpp
  kcm_add_layout_dialog.cpp
  keyboard_config.cpp
  x11_helper.cpp
  xkb_helper.cpp
  xkb_rules.cpp
  flags.cpp
  iso_codes.cpp
  kcmmisc.cpp
  bindings.cpp
  ${preview_SRCS} )

ki18n_wrap_ui(kcm_keyboard_PART_SRCS kcm_keyboard.ui kcm_add_layout_dialog.ui kcmmiscwidget.ui)

add_library(kcm_keyboard MODULE ${kcm_keyboard_PART_SRCS})

target_link_libraries(kcm_keyboard
    Qt5::Concurrent
    Qt5::Widgets
    Qt5::X11Extras
    Qt5::Xml
    KF5::KCMUtils
    KF5::GlobalAccel
    KF5::I18n
    KF5::KIOCore
    KF5::KIOWidgets
    KF5::WindowSystem
    KF5::Plasma
    KF5::XmlGui
    KF5::GuiAddons
    KF5::IconThemes
    XCB::XCB
    XCB::XKB
    ${X11_Xkbfile_LIB}
    ${X11_LIBRARIES}
    ${text_paint_LIB}
)

install(TARGETS kcm_keyboard DESTINATION ${PLUGIN_INSTALL_DIR} )

install( FILES kcm_keyboard.desktop DESTINATION ${SERVICES_INSTALL_DIR} )

# Images

add_subdirectory( pics )

configure_file(config-keyboard.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-keyboard.h)

# Unit tests
if(BUILD_TESTING)
    find_package(Qt5Test ${QT_MIN_VERSION} CONFIG REQUIRED)
    add_subdirectory( tests )
endif()
