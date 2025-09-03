#!/bin/bash
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# docker_utils.sh - Docker template generation utility module
#
# DESCRIPTION:
#   This module provides functions to generate Docker-related files from templates.
#   It creates Dockerfile and docker-compose.yml files based on configuration.
#
# FUNCTIONS:
#   generate_dockerfile <output_dir> <base_image> <ports>
#     - Generates Dockerfile from template
#     - Replaces template variables with actual values
#   
#   generate_compose <output_dir> <service_name> <ports>
#     - Generates docker-compose.yml from template
#     - Configures service name and port mappings
#
# USAGE EXAMPLES:
#   source ./scripts/docker_utils.sh
#   generate_dockerfile "./output" "python:3.10" "8000"
#   generate_compose "./output" "my-app" "8000:8000"
#
# DEPENDENCIES:
#   - Template files in ../templates/docker/ directory
#   - sed command for text replacement
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

function generate_dockerfile() {
    local output_dir="$1"
    local base_image="${2:-python:3.10}"
    local ports="${3:-8000}"
    local app_name="${4:-app}"
    
    mkdir -p "$output_dir/docker"
    
    # Determine the correct path to templates
    local template_path
    if [ -f "templates/docker/dockerfile.base" ]; then
        template_path="templates/docker/dockerfile.base"
    elif [ -f "../templates/docker/dockerfile.base" ]; then
        template_path="../templates/docker/dockerfile.base"
    else
        echo "Error: Dockerfile template not found"
        return 1
    fi
    
    cat "$template_path" | \
        sed "s/<base_image>/$base_image/g; s/<ports>/$ports/g; s/<entrypoint>/\"$app_name\"/g" \
        > "$output_dir/docker/Dockerfile.$app_name"
    
    echo "Dockerfile generated: docker/Dockerfile.$app_name"
}

function generate_compose() {
    local output_dir="$1"
    local service_name="${2:-app}"
    local host_port="${3:-8000}"
    local container_port="${4:-8000}"
    local image_name="${5:-my-app}"
    
    mkdir -p "$output_dir/docker"
    
    # Determine the correct path to templates
    local template_path
    if [ -f "templates/docker/compose.base.yml" ]; then
        template_path="templates/docker/compose.base.yml"
    elif [ -f "../templates/docker/compose.base.yml" ]; then
        template_path="../templates/docker/compose.base.yml"
    else
        echo "Error: Docker Compose template not found"
        return 1
    fi
    
    cat "$template_path" | \
        sed "s/<image_name>/$image_name/g; s/<host_port>/$host_port/g; s/<container_port>/$container_port/g" \
        > "$output_dir/docker/compose.$service_name.yml"
    
    echo "Docker Compose generated: docker/compose.$service_name.yml"
}

function generate_github_workflow() {
    local output_dir="$1"
    local app_name="${2:-app}"
    
    mkdir -p "$output_dir/.github/workflows"
    
    cat > "$output_dir/.github/workflows/docker.$app_name.yml" << EOF
name: Docker Build and Deploy

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: docker build -f docker/Dockerfile.$app_name -t $app_name:latest .
    
    - name: Run tests
      run: docker run --rm $app_name:latest echo "Tests would run here"
EOF
    
    echo "GitHub workflow generated: .github/workflows/docker.$app_name.yml"
}
