# Compute Node Linux doesn't quite work the same as native Linux so all of this
# needs to be custom.  We use the variables defined through Cray's environment
# modules to set up the right paths for things.

# Guard against multiple inclusions
if(__CrayLinuxEnviropnment)
  return()
endif()
set(__CrayLinuxEnviropnment 1)

set(UNIX 1)

if(CRAYXC)
  set(CMAKE_SYSTEM_VERSION "$ENV{CRAYOS_VERSION}")
elseif(CRAYXT)
  set(CMAKE_SYSTEM_VERSION "$ENV{XTOS_VERSION}")
else()
  message(FATAL_ERROR "Neither the CRAYXC or CRAYXT CMake variables are defined.  Thjis platform file should not be used directly but instead only from the CrayPrgEnv toolchain file")
endif()

# All cray systems are x86 CPUs and have been for quite some time
set(CMAKE_SYSTEM_PROCESSOR "x86_64")

set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
set(CMAKE_SHARED_LIBRARY_SUFFIX ".so")
set(CMAKE_STATIC_LIBRARY_PREFIX "lib")
set(CMAKE_STATIC_LIBRARY_SUFFIX ".a")

set(CMAKE_FIND_LIBRARY_PREFIXES "lib")

set(CMAKE_DL_LIBS dl)

# Make sure we have the appropriate environment loaded
if(NOT DEFINED ENV{SYSROOT_DIR})
  message(WARNING "SYSROOT_DIR environment varible is not found.  some libraries bay get found on the host node instead of the target node")
endif()

# Note: Much of this is pulled from UnixPaths.cmake but adjusted to teh Cray
# environment accordingly

# Get the install directory of the running cmake to the search directories
# CMAKE_ROOT is CMAKE_INSTALL_PREFIX/share/cmake, so we need to go two levels up
get_filename_component(_CMAKE_INSTALL_DIR "${CMAKE_ROOT}" PATH)
get_filename_component(_CMAKE_INSTALL_DIR "${_CMAKE_INSTALL_DIR}" PATH)

# List common installation prefixes.  These will be used for all
# search types.
list(APPEND CMAKE_SYSTEM_PREFIX_PATH
  # Standard
  $ENV{SYSROOT_DIR}/usr/local $ENV{SYSROOT_DIR}/usr $ENV{SYSROOT_DIR}/

  # CMake install location
  "${_CMAKE_INSTALL_DIR}"
  )
if (NOT CMAKE_FIND_NO_INSTALL_PREFIX)
  list(APPEND CMAKE_SYSTEM_PREFIX_PATH
    # Project install destination.
    "${CMAKE_INSTALL_PREFIX}"
  )
  if(CMAKE_STAGING_PREFIX)
    list(APPEND CMAKE_SYSTEM_PREFIX_PATH
      # User-supplied staging prefix.
      "${CMAKE_STAGING_PREFIX}"
    )
  endif()
endif()

# List common include file locations not under the common prefixes.
list(APPEND CMAKE_SYSTEM_INCLUDE_PATH
  # X11
  $ENV{SYSROOT_DIR}/usr/include/X11
)

list(APPEND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES
  $ENV{SYSROOT_DIR}/usr/local/lib64
  $ENV{SYSROOT_DIR}/usr/lib64
  $ENV{SYSROOT_DIR}/lib64
  )

list(APPEND CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES
  $ENV{SYSROOT_DIR}/usr/include
  )
list(APPEND CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES
  $ENV{SYSROOT_DIR}/usr/include
  )

# Enable use of lib64 search path variants by default.
set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS TRUE)

