FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------
# Fix Ubuntu mirrors (required for 20.04)
# -----------------------------------------------------
RUN sed -i 's|archive.ubuntu.com|us.archive.ubuntu.com|g' /etc/apt/sources.list && \
    sed -i 's|security.ubuntu.com|us.archive.ubuntu.com|g' /etc/apt/sources.list

# -----------------------------------------------------
# Install essentials
# -----------------------------------------------------
RUN apt update && apt install -y \
    sudo curl wget git gnupg2 lsb-release \
    nano build-essential cmake \
    python3 python3-dev python3-pip \
    locales

RUN locale-gen en_US.UTF-8

# -----------------------------------------------------
# Install ROS Noetic Desktop-Full
# -----------------------------------------------------
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" \
    > /etc/apt/sources.list.d/ros-latest.list'

RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt update && apt install -y ros-noetic-desktop-full

# Auto-source ROS in every shell
RUN echo "source /opt/ros/noetic/setup.bash" >> /etc/bash.bashrc

# -----------------------------------------------------
# ROS build tools
# -----------------------------------------------------
RUN apt install -y \
    python3-rosdep python3-rosinstall python3-rosinstall-generator \
    python3-wstool python3-catkin-tools python3-colcon-common-extensions

RUN rosdep init || true
RUN rosdep update

RUN apt install -y libcgal-dev libcgal-qt5-dev
RUN apt-get install -y ros-noetic-cv-bridge ros-noetic-pcl-conversions

RUN apt-get install -y pcl-tools meshlab

RUN apt-get install -y ros-noetic-realsense2-camera ros-noetic-realsense2-description
    
# -----------------------------------------------------
# Create developer user
# -----------------------------------------------------
RUN useradd -ms /bin/bash dev && echo "dev:dev" | chpasswd && adduser dev sudo

USER dev
WORKDIR /home/dev

# -----------------------------------------------------
# Create workspace directory (your host folder will mount here)
# -----------------------------------------------------
RUN mkdir -p /home/dev/ros1_ws/src

CMD ["/bin/bash"]
