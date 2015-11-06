# Guard against multiple inclusions
if(__CrayPrgEnv)
  return()
endif()
set(__CrayPrgEnv 1)

if(NOT __CrayLinuxEnvironment)
  message(FATAL_ERROR "The CrayPrgEnv tolchain file must not be used on its own and is intented to be included by the CrayLinuxEnvironment platform file")
endif()

set(CMAKE_SYSTEM_NAME CrayLinuxEnvironment)

# Make sure we have the appropriate environment loaded
if(DEFINED ENV{CRAYPE_DIR})
  set(_CRAYPE_ROOT "$ENV{CRAYPE_DIR}")
elseif(DEFINED ENV{ASYNCPE_DIR})
  set(_CRAYPE_ROOT "$ENV{ASYNCPE_DIR}")
else()
  message(FATAL_ERROR "Neither the ASYNCPE_DIR or CRAYPE_DIR environment variable are defined but the CrayPrgEnv toolchain module requires one.  This usually means that the necessary PrgEnv-* module is not loaded")
endif()

# Explicitly use the cray compiler wrappers from the PrgEnv-* module
set(CMAKE_C_COMPILER       "${_CRAYPE_ROOT}/bin/cc")
set(CMAKE_CXX_COMPILER     "${_CRAYPE_ROOT}/bin/CC")
set(CMAKE_Fortran_COMPILER "${_CRAYPE_ROOT}/bin/ftn")

# Flags for the Cray wrappers
foreach(_lang C CXX Fortran)
  set(CMAKE_STATIC_LIBRARY_LINK_${_lang}_FLAGS "-static")
  set(CMAKE_SHARED_LIBRARY_${_lang}_FLAGS "")
  set(CMAKE_SHARED_LIBRARY_CREATE_${_lang}_FLAGS "-shared")
  set(CMAKE_SHARED_LIBRARY_LINK_${_lang}_FLAGS "-dynamic")
endforeach()

# If the link type is not explicitly specified in the environment then we'll
# assume that the code will be built staticly
# can be mixed
if("$ENV{CRAYPE_LINK_TYPE}" STREQUAL "dynamic")
  set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS TRUE)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ".so" ".a")
  set(BUILD_SHARED_LIBS TRUE CACHE BOOL "")
else() # Explicit or implicit static
  set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)
  set(BUILD_SHARED_LIBS FALSE CACHE BOOL "")
  set(CMAKE_FIND_LIBRARY_SUFFIXES ".a"
  set(CMAKE_LINK_SEARCH_START_STATIC TRUE)
endif()
