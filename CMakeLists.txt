cmake_minimum_required (VERSION 3.12)
project (TESTBOOST)

#
# By default, use the currently active CONDA_PREFIX
#
if (NOT CMAKE_PREFIX_PATH})
    set(CMAKE_PREFIX_PATH $ENV{CONDA_PREFIX})
endif()

######################################################################
#
#  Find Python library and headers
#
######################################################################
set(Python3_USE_STATIC_LIBS TRUE)
find_package(Python REQUIRED COMPONENTS Interpreter Development)

message("Using ${Python_EXECUTABLE}")
message("Using ${Python_LIBRARIES}")

message("Python version: ${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}")

include_directories(${Python_INCLUDE_DIRS})

######################################################################
#
#  Find boost::python library and headers
#
#  (Copied from vigra/config/FindVIGRANUMPY_DEPENDENCIES.cmake)
#
# 'FIND_PACKAGE(Boost COMPONENTS python)' is unreliable because it often selects
# boost_python for the wrong Python version
#
######################################################################
set(BOOST_ROOT $ENV{CONDA_PREFIX} CACHE STRING "")
find_package(Boost 1.68 REQUIRED)
IF(Boost_FOUND)
    IF(Boost_USE_MULTITHREADED)
        # define names for thread-safe library variants
        SET(BOOST_PYTHON_NAMES
                boost_python-py${Python_VERSION_MAJOR}${Python_VERSION_MINOR}-mt
                boost_python-${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}-mt
                boost_python${Python_VERSION_MAJOR}-mt
                boost_python${Python_VERSION_MAJOR}${Python_VERSION_MINOR}-mt
                boost_python-mt)
    ENDIF()

    IF(Boost_LIB_SUFFIX)
        SET(BOOST_PYTHON_NAMES ${BOOST_PYTHON_NAMES}
            # Windows with mangled library names
            boost_python${Python_VERSION_MAJOR}${Boost_LIB_SUFFIX}
            boost_python${Boost_LIB_SUFFIX})
    ENDIF()

    # define names for boost_python library variants
    # (may or may not be thread-safe)
    SET(BOOST_PYTHON_NAMES ${BOOST_PYTHON_NAMES}
                # Linux with multiple Python versions
                boost_python-py${Python_VERSION_MAJOR}${Python_VERSION_MINOR}
                # Gentoo
                boost_python-${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}
                # Mac with Python 3
                boost_python${Python_VERSION_MAJOR}
                # conda-forge
                boost_python${Python_VERSION_MAJOR}${Python_VERSION_MINOR}
                # default
                boost_python)

    FIND_LIBRARY(Boost_PYTHON_LIBRARY
                 NAMES ${BOOST_PYTHON_NAMES}
                 NAMES_PER_DIR
                 HINTS "${Boost_LIBRARY_DIR}"
                 DOC "boost_python libraries")
ENDIF()

if(Boost_PYTHON_LIBRARY)
    MESSAGE(STATUS "Found boost_python library: ${Boost_PYTHON_LIBRARY}")
else()
    MESSAGE(FATAL_ERROR "Could NOT find boost_python library")
endif()

include_directories(${Boost_INCLUDE_DIRS})

add_library( testboost SHARED src/testboost.cpp )

#
# DO NOT LINK AGAINST libpython
# Instead, assume that bin/python has been statically linked and
# thus all needed symbols will be available during execution.
# Use -undefined dynamic_lookup to avoid linker errors at build time (and defer them to runtime).
# https://github.com/conda-forge/boost-feedstock/issues/70#issuecomment-486398688
# 
if (APPLE)
    set_property(TARGET testboost APPEND_STRING PROPERTY LINK_FLAGS "-undefined dynamic_lookup")
endif()

target_link_libraries( testboost ${Boost_PYTHON_LIBRARY})
set_target_properties(testboost PROPERTIES PREFIX  ""
                                           SUFFIX ".so"
                                           DEBUG_POSTFIX "" )
