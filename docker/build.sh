#!/bin/bash

# -------------------------------
# CONFIGURATION
# -------------------------------
CONTAINER_NAME="r3live_dev"
IMAGE_NAME="ros1_noetic_dev"
DOCKERFILE_DIR="$(dirname "$0")"

# Host and container workspace paths
HOST_WS="/home/rey/ros1_ws/src"
CONTAINER_WS="/home/dev/ros1_ws/src"

# Default mode (safe for laptops): NO GPU
USE_GPU=true

# -------------------------------
# PARSE ARGUMENT
# -------------------------------
if [[ "$1" == "--gpu" ]]; then
    USE_GPU=true
    echo "[MODE] GPU mode enabled (NVIDIA runtime)"
elif [[ "$1" == "--nogpu" || "$1" == "" ]]; then
    USE_GPU=false
    echo "[MODE] CPU-only mode enabled"
else
    echo "Usage: ./build.sh [--gpu | --nogpu]"
    exit 1
fi

# -------------------------------
# Ensure host workspace exists
# -------------------------------
mkdir -p "$HOST_WS"

echo "---------------------------------------------"
echo "ROS1 Noetic Docker Environment"
echo "Container: $CONTAINER_NAME"
echo "Image: $IMAGE_NAME"
echo "Workspace: $HOST_WS -> $CONTAINER_WS"
echo "GPU Mode: $USE_GPU"
echo "---------------------------------------------"

# -------------------------------
# Build Docker image
# -------------------------------
echo "[INFO] Building Docker image..."
docker build -t $IMAGE_NAME $DOCKERFILE_DIR
if [ $? -ne 0 ]; then
    echo "[ERROR] Docker image build failed!"
    exit 1
fi

# -------------------------------
# If container exists -> START IT
# -------------------------------
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    echo "[INFO] Container exists. Starting..."
    docker start -ai $CONTAINER_NAME
    exit 0
fi

# -------------------------------
# Create new container
# -------------------------------
echo "[INFO] Creating container..."

if [ "$USE_GPU" = true ]; then
    # GPU-enabled version
    docker run -it \
        --name $CONTAINER_NAME \
        --runtime=nvidia \
        --gpus all \
        --env "NVIDIA_VISIBLE_DEVICES=all" \
        --env "NVIDIA_DRIVER_CAPABILITIES=all" \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        --net=host \
        --privileged \
        -v "$HOST_WS":"$CONTAINER_WS" \
        $IMAGE_NAME
else
    # CPU-only version (laptop-friendly)
    docker run -it \
        --name $CONTAINER_NAME \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        --net=host \
        --privileged \
        -v "$HOST_WS":"$CONTAINER_WS" \
        $IMAGE_NAME
fi