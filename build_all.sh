#!/bin/bash

# Livox SDK
cd Livox-SDK
mkdir build && cd build
cmake ..
make
sudo make install

# Build all packages in workspace
cd /home/dev/ros1_ws
catkin_make