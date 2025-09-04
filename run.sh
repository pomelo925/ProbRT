#!/bin/bash

# Usage function
usage() {
  echo "usage: $0 <device> <service>"
  echo "device:"
  echo "  cpu             Use CPU-only environment"
  echo "  gpu             Use GPU-accelerated environment"
  echo "service:"
  echo "  dev             Development service (interactive shell)"
  echo "  deploy          Deploy service (application runtime)"
  echo ""
  echo "Examples:"
  echo "  $0 cpu dev      # Start CPU development environment"
  echo "  $0 gpu deploy   # Start GPU deployment service"
  exit 1
}

# Check if exactly two arguments are provided
if [ $# -ne 2 ]; then
    echo "Error: Both device and service arguments are required."
    usage
fi

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
DEVICE=$1
SERVICE=$2

# Validate device
case "$DEVICE" in
    cpu)
        COMPOSE_FILE="$SCRIPT_DIR/docker/compose.cpu.yml"
        PROJECT_NAME="probrt-cpu"
        ;;
    gpu)
        COMPOSE_FILE="$SCRIPT_DIR/docker/compose.gpu.yml"
        PROJECT_NAME="probrt-gpu"
        ;;
    *)
        echo "Error: Invalid device '$DEVICE'. Must be 'cpu' or 'gpu'."
        usage
        ;;
esac

# Validate service name
case "$SERVICE" in
    dev|deploy)
        ;;
    *)
        echo "Error: Invalid service name '$SERVICE'. Must be 'dev' or 'deploy'."
        usage
        ;;
esac

# Set up X11 forwarding
echo "Setting up X11 forwarding..."

# Check if DISPLAY is set
if [ -z "$DISPLAY" ]; then
    echo "⚠️ WARNING: DISPLAY is not set. GUI apps may not work."
    echo "   Please set DISPLAY environment variable or enable X11 forwarding."
fi

# Set up XAUTHORITY if not already set
if [ -z "$XAUTHORITY" ]; then
    export XAUTHORITY=$HOME/.Xauthority
fi

# Create XAUTHORITY file if it doesn't exist
if [ ! -f "$XAUTHORITY" ]; then
    echo "Creating XAUTHORITY file: $XAUTHORITY"
    touch "$XAUTHORITY"
    if [ -n "$DISPLAY" ]; then
        xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f "$XAUTHORITY" nmerge - 2>/dev/null || true
    fi
else
    echo "Using existing XAUTHORITY file: $XAUTHORITY"
fi

# Allow Docker containers to access X11
xhost +local:docker > /dev/null 2>&1 || true

# Export environment variables
export DISPLAY
export XAUTHORITY

# Clean up any existing containers
echo "Cleaning up existing containers..."
docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" down --volumes --remove-orphans 2>/dev/null || true

# Start the specific service
echo "Starting $DEVICE $SERVICE service..."
docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" up -d $SERVICE

# Wait a moment for container to be ready
sleep 2

# Container name based on project and service
CONTAINER_NAME="${PROJECT_NAME}-${SERVICE}"

if [ "$SERVICE" = "dev" ]; then
    # Enter the container for dev service
    echo "Entering container..."
    docker exec -it "$CONTAINER_NAME" /bin/bash
elif [ "$SERVICE" = "deploy" ]; then
    # Show logs for deploy service
    echo "Deploy service started. Showing logs..."
    echo "Press Ctrl+C to stop the service."
    docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" logs -f "$SERVICE"
fi

echo "Service session ended."
echo "To stop the service, run: docker compose -p $PROJECT_NAME -f $COMPOSE_FILE down"