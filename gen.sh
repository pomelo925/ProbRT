#!/bin/bash
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# gen.sh - Main generator script for dockerT repository scaffold
#
# DESCRIPTION:
#   This script generates a complete repository scaffold based on configuration in settings.yml.
#   It creates a clean development repository with only necessary project files.
#
# FEATURES:
#   - Generates complete project structure in separate output directory
#   - Automatic LICENSE file generation based on license type in settings.yml
#   - Docker configuration (Dockerfile, docker-compose.yml)
#   - GitHub Actions workflows
#   - Clean project structure without scaffold tools
#   - Support for multiple license types (MIT, Apache-2.0, GPL-3.0)
#   - Modular design with separate utility scripts
#   - Automatic date and author tracking
#
# USAGE:
#   ./gen.sh                    # Generate repository scaffold using default settings
#   ./gen.sh --output custom-dir # Generate to custom output directory
#
# CONFIGURATION:
#   Edit settings.yml to specify:
#   - repo_name: Name of the target repository
#   - output_dir: Directory where generated repo will be created
#   - license: License type (MIT, Apache-2.0, GPL-3.0)
#   - docker: Docker configuration (base_image, ports, service_name)
#   - features: List of features to include
#
# OUTPUT STRUCTURE:
#   <output_dir>/
#   ├─ README.md
#   ├─ .gitignore
#   ├─ LICENSE
#   ├─ docker/
#   │  ├─ Dockerfile.xxx
#   │  └─ compose.xxx.yml
#   └─ .github/
#      └─ workflows/
#         └─ docker.xxx.yml
#
# DEPENDENCIES:
#   - settings.yml configuration file
#   - scripts/license_utils.sh module
#   - scripts/docker_utils.sh module
#   - templates/ directory with all templates
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

source ./scripts/license_utils.sh
source ./scripts/docker_utils.sh
source ./scripts/file_utils.sh

# Parse command line arguments
OUTPUT_DIR=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Read configuration from settings.yml
repo_name=$(grep '^repo_name:' settings.yml | awk '{print $2}')
output_dir=${OUTPUT_DIR:-$(grep '^output_dir:' settings.yml | awk '{print $2}')}
license_name=$(grep '^license:' settings.yml | awk '{print $2}')
base_image=$(grep -A 3 '^docker:' settings.yml | grep 'base_image:' | awk '{print $2}')
docker_ports=$(grep -A 3 '^docker:' settings.yml | grep 'ports:' | awk '{print $2}')
service_name=$(grep -A 3 '^docker:' settings.yml | grep 'service_name:' | awk '{print $2}')

# Set defaults
repo_name=${repo_name:-"my-new-repo"}
output_dir=${output_dir:-"generated-repo"}
license_name=${license_name:-"MIT"}
base_image=${base_image:-"python:3.10"}
docker_ports=${docker_ports:-"8000"}
service_name=${service_name:-"app"}

echo "Generating repository scaffold..."
echo "Repository: $repo_name"
echo "Output directory: $output_dir"
echo "License: $license_name"

# Clean and create output directory
if [ -d "$output_dir" ]; then
    rm -rf "$output_dir"
fi
mkdir -p "$output_dir"

# Generate core development files
get_license_content "$license_name" > "$output_dir/LICENSE"
echo "✓ LICENSE generated with $license_name license"

generate_readme "$output_dir" "$repo_name" "$license_name" "$service_name"
generate_gitignore "$output_dir"

# Check features and generate accordingly
features=$(grep -A 10 '^features:' settings.yml | grep '^  -' | sed 's/^  - //')

while IFS= read -r feature; do
    case "$feature" in
        "docker")
            generate_dockerfile "$output_dir" "$base_image" "$docker_ports" "$service_name"
            generate_compose "$output_dir" "$service_name" "$docker_ports" "$docker_ports" "$repo_name"
            ;;
        "github_workflows")
            generate_github_workflow "$output_dir" "$service_name"
            ;;
    esac
done <<< "$features"

echo ""
echo "Repository scaffold generated successfully in: $output_dir"
echo "Generated structure:"
echo "├─ README.md"
echo "├─ .gitignore"
echo "├─ LICENSE"
if [[ "$features" == *"docker"* ]]; then
    echo "├─ docker/"
    echo "│  ├─ Dockerfile.$service_name"
    echo "│  └─ compose.$service_name.yml"
fi
if [[ "$features" == *"github_workflows"* ]]; then
    echo "└─ .github/"
    echo "   └─ workflows/"
    echo "      └─ docker.$service_name.yml"
fi
