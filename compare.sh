#!/bin/bash

##
## Try building and testing this repo using packages
## from the old conda-forge label (cf201901)
## and the new one (main)
##

PACKAGES="clangxx_osx-64 cmake boost=1.68 python=3.6"

##
## OLD BUILD
##
# Create environment
echo "Creating old-build environment"
conda create -y -n old-build -c conda-forge/label/cf201901 ${PACKAGES}


# Build
echo "Building with OLD packages"
conda activate old-build
mkdir build-old
cd build-old
cmake ..
make

echo "Testing with OLD packages"
PYTHONPATH=. python -c 'from testboost import greet; print(greet())'; echo $?

cd ..


##
## NEW BUILD
##
# Create environment
echo "Creating new-build environment"
conda create -y -n new-build -c conda-forge ${PACKAGES}


# Build
echo "Building with NEW packages"
conda activate new-build
mkdir build-new
cd build-new
cmake ..
make

echo "Testing with NEW packages"
PYTHONPATH=. python -c 'from testboost import greet; print(greet())'; echo $?

cd ..


##
## (For reference: Alternative build commands, without cmake)
##
#
## Python 3.6:
#${CXX} \
#  -I${CONDA_PREFIX}/include \
#  -I${CONDA_PREFIX}/include/python3.6m \
#  -L${CONDA_PREFIX}/lib \
#  -lpython3.6m \
#  -lboost_python3 \
#  -shared \
#  -o testboost.so \
#  src/testboost.cpp
#
## Python 3.7:
#${CXX} \
#  -I${CONDA_PREFIX}/include \
#  -I${CONDA_PREFIX}/include/python3.7m \
#  -L${CONDA_PREFIX}/lib \
#  -lpython3.7m \
#  -lboost_python37 \
#  -shared \
#  -o testboost.so \
#  src/testboost.cpp

