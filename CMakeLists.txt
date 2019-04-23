cmake_minimum_required (VERSION 3.7)
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
find_package(PythonInterp)

execute_process(COMMAND ${PYTHON_EXECUTABLE} -c
                "from distutils.sysconfig import *; print(get_config_var('LDLIBRARY'))"
                OUTPUT_VARIABLE PYTHON_LIBRARY_NAME OUTPUT_STRIP_TRAILING_WHITESPACE)
find_library(PYTHON_LIBRARIES ${PYTHON_LIBRARY_NAME})


execute_process(COMMAND ${PYTHON_EXECUTABLE} -c
                "from distutils.sysconfig import *; print(get_python_inc())"
                OUTPUT_VARIABLE PYTHON_INCLUDE OUTPUT_STRIP_TRAILING_WHITESPACE)

SET(PYTHON_INCLUDE_PATH ${PYTHON_INCLUDE}
    CACHE PATH "Path to Python include files"
    FORCE)

message("Using ${PYTHON_EXECUTABLE}")
message("Using ${PYTHON_LIBRARIES}")

include_directories(${PYTHON_INCLUDE_PATH})

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
find_package(Boost 1.64 REQUIRED)
IF(Boost_FOUND)
    IF(Boost_USE_MULTITHREADED)
        # define names for thread-safe library variants
        SET(BOOST_PYTHON_NAMES
                boost_python-py${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}-mt
                boost_python-${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}-mt
                boost_python${PYTHON_VERSION_MAJOR}-mt
                boost_python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}-mt
                boost_python-mt)
    ENDIF()

    IF(Boost_LIB_SUFFIX)
        SET(BOOST_PYTHON_NAMES ${BOOST_PYTHON_NAMES}
            # Windows with mangled library names
            boost_python${PYTHON_VERSION_MAJOR}${Boost_LIB_SUFFIX}
            boost_python${Boost_LIB_SUFFIX})
    ENDIF()

    # define names for boost_python library variants
    # (may or may not be thread-safe)
    SET(BOOST_PYTHON_NAMES ${BOOST_PYTHON_NAMES}
                # Linux with multiple Python versions
                boost_python-py${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}
                # Gentoo
                boost_python-${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}
                # Mac with Python 3
                boost_python${PYTHON_VERSION_MAJOR}
                # conda-forge
                boost_python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}
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
target_link_libraries( testboost ${Boost_PYTHON_LIBRARY} ${PYTHON_LIBRARIES} )
set_target_properties(testboost PROPERTIES PREFIX  ""
                                           SUFFIX ".so"
                                           DEBUG_POSTFIX "" )
