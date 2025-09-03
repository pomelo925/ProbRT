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
#   - project_name: Name used for README header and project references
#   - output_dir: Relative path from rtgen root where files will be generated
#   - license: License type (MIT, Apache-2.0, GPL-3.0)
#   - docker: Docker configuration (base_image, ports, service_name)
#   - features: List of features to include
#
# OUTPUT STRUCTURE:
#   <rtgen_root>/<output_dir>/
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

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Parse command line arguments
OUTPUT_DIR_OVERRIDE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT_DIR_OVERRIDE="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Read configuration from settings.yml
project_name=$(grep '^project_name:' settings.yml | sed 's/^project_name: *//' | sed 's/ *#.*//')
output_dir_relative=${OUTPUT_DIR_OVERRIDE:-$(grep '^output_dir:' settings.yml | awk '{print $2}')}
license_name=$(grep '^license:' settings.yml | awk '{print $2}')
base_image=$(grep -A 3 '^docker:' settings.yml | grep 'base_image:' | awk '{print $2}')
docker_ports=$(grep -A 3 '^docker:' settings.yml | grep 'ports:' | awk '{print $2}')
service_name=$(grep -A 3 '^docker:' settings.yml | grep 'service_name:' | awk '{print $2}')

# Set defaults and construct full output path
project_name=${project_name:-"My New Project"}
output_dir_relative=${output_dir_relative:-"../generated-repo"}
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # rtgen root directory
output_dir="$script_dir/$output_dir_relative"  # Full path to output directory
license_name=${license_name:-"MIT"}
base_image=${base_image:-"python:3.10"}
docker_ports=${docker_ports:-"8000"}
service_name=${service_name:-"app"}

echo -e "${BLUE}🚀 Generating ${WHITE}$project_name${BLUE} scaffold...${NC}"
echo -e "${CYAN}📁 Output: ${WHITE}$(realpath "$output_dir")${NC}"

# Create output directory if it doesn't exist
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

# Generate core development files
get_license_content "$license_name" > "$output_dir/LICENSE"

generate_readme "$output_dir" "$project_name" "$license_name" "$service_name"
generate_gitignore "$output_dir"

# Check features and generate accordingly
features=$(grep -A 10 '^features:' settings.yml | grep '^  -' | sed 's/^  - //')

while IFS= read -r feature; do
    case "$feature" in
        "docker")
            generate_dockerfile "$output_dir" "$base_image" "$docker_ports" "$service_name"
            generate_compose "$output_dir" "$service_name" "$docker_ports" "$docker_ports" "$project_name"
            ;;
        "github_workflows")
            generate_github_workflow "$output_dir" "$service_name"
            ;;
    esac
done <<< "$features"

echo ""
echo -e "${WHITE}📂 Scaffold structure:${NC}"
if [ -d "$output_dir" ]; then
    tree "$output_dir" -a --dirsfirst -I '.git'
else
    echo -e "${RED}  ✗ Directory not found${NC}"
fi
