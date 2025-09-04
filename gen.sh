#!/bin/bash

#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# gen.sh - Main generator script for rtgen repository scaffold
#
# DESCRIPTION:
#   This script generates a complete repository scaffold based on configuration in settings.yml.
#   It creates a clean development repository with only necessary project files.
#
# FEATURES:
#   - Template-based generation with variable substitution
#   - Modular configuration system (settings.yml + config files)
#   - Docker configuration (Dockerfile, docker-compose.yml) with CPU/GPU variants
#   - GitHub Actions workflows with customizable triggers
#   - Clean project structure without scaffold tools
#   - Support for multiple license types (MIT, Apache-2.0, GPL-3.0)
#   - Advanced Docker features (GUI support, device access, workspace volumes)
#
# USAGE:
#   ./gen.sh                    # Generate repository scaffold using default settings
#   ./gen.sh --output custom-dir # Generate to custom output directory
#   ./gen.sh -test              # Run in test mode (generates to gen-test/ directory)
#   ./gen.sh --test             # Same as -test
#
# CONFIGURATION:
#   Edit settings.yml to specify:
#   - project_name: Name used for README header and project references
#   - output_dir: Relative path from rtgen root where files will be generated
#   - docker: Docker-specific settings (image_name, image_tag, registry_username)
#   - github: GitHub-specific settings (username, branches)
#   - features: List of features to include
#
# OUTPUT STRUCTURE:
#   <rtgen_root>/<output_dir>/
#   ├─ README.md
#   ├─ .gitignore
#   ├─ LICENSE
#   ├─ docker/
#   │  ├─ dockerfile.cpu
#   │  ├─ dockerfile.gpu
#   │  ├─ compose.cpu.yml
#   │  └─ compose.gpu.yml
#   └─ .github/
#      └─ workflows/
#         ├─ docker.cpu.yml
#         └─ docker.gpu.yml
#
# DEPENDENCIES:
#   - settings.yml configuration file
#   - config/ directory with feature-specific configurations
#   - templates/ directory with all templates
#   - scripts/template_utils.sh for template processing
#   - Python 3 with PyYAML for configuration parsing
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

source ./scripts/license_utils.sh
source ./scripts/docker_utils.sh
source ./scripts/file_utils.sh
source ./scripts/template_utils.sh

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# TEST FUNCTIONS
# These functions handle the testing mode functionality (-test flag)
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

# Function to clean up test directory
cleanup_test() {
    local test_dir="$1"
    if [ -d "$test_dir" ]; then
        rm -rf "$test_dir"
        echo -e "${YELLOW}🧹 Cleaned ${WHITE}$(realpath "$test_dir" 2>/dev/null || echo "gen-test")${NC}"
    fi
}

# Function to initialize test mode
init_test_mode() {
    echo -e "${BLUE}🧪 Testing RTGen Generator${NC}"
    echo -e "${CYAN}📦 Project: ${WHITE}$project_name${NC}"
    echo -e "${CYAN}📁 Test dir: ${WHITE}$(realpath "$output_dir")${NC}"
    echo ""
    
    cleanup_test "$output_dir"
}

# Function to finalize test mode and show results
finalize_test_mode() {
    echo ""
    # Check if test output directory was created 
    if [ -d "$output_dir" ]; then
        local file_count=$(find "$output_dir" -type f | wc -l)
        echo -e "${GREEN}✅ Test completed!${NC} Generated ${WHITE}$file_count files${NC}"
    else
        echo -e "${RED}✗ Test directory not created${NC}"
    fi
    
    echo -e "${PURPLE}📋 Full path: ${WHITE}$(realpath "$output_dir" 2>/dev/null || echo "$output_dir")${NC}"
}

#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# MAIN GENERATION LOGIC
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

# Parse command line arguments
OUTPUT_DIR_OVERRIDE=""
TEST_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT_DIR_OVERRIDE="$2"
            shift 2
            ;;
        -test|--test)
            TEST_MODE=true
            OUTPUT_DIR_OVERRIDE="gen-test"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo -e "${CYAN}Usage: $0 [--output <dir>] [-test|--test]${NC}"
            exit 1
            ;;
    esac
done

# Check for Python and PyYAML dependency
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is required but not installed.${NC}"
    exit 1
fi

if ! python3 -c "import yaml" &> /dev/null; then
    echo -e "${YELLOW}Installing PyYAML...${NC}"
    pip3 install PyYAML || {
        echo -e "${RED}Error: Failed to install PyYAML. Please install it manually: pip3 install PyYAML${NC}"
        exit 1
    }
fi

# Read basic configuration from settings.yml
project_name=$(python3 -c "
import yaml
with open('settings.yml', 'r') as f:
    data = yaml.safe_load(f)
print(data.get('project_name', 'My New Project'))
")

output_dir_relative=${OUTPUT_DIR_OVERRIDE:-$(python3 -c "
import yaml
with open('settings.yml', 'r') as f:
    data = yaml.safe_load(f)
print(data.get('output_dir', '../generated-repo'))
")}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
output_dir="$script_dir/$output_dir_relative"

# Initialize test mode if enabled
if [ "$TEST_MODE" = true ]; then
    init_test_mode
else
    echo -e "${BLUE}🚀 Generating ${WHITE}$project_name${BLUE} scaffold...${NC}"
    echo -e "${CYAN}📁 Output: ${WHITE}$(realpath "$output_dir")${NC}"
fi

# Create output directory
mkdir -p "$output_dir"

# Generate files based on enabled features
features=$(python3 -c "
import yaml
with open('settings.yml', 'r') as f:
    data = yaml.safe_load(f)
features = data.get('features', ['readme', 'license', 'docker', 'github'])
print('\n'.join(features))
")

while IFS= read -r feature; do
    feature=$(echo "$feature" | xargs)  # Trim whitespace
    case "$feature" in
        "readme")
            # Get license type for README generation
            license_type=$(python3 -c "
import yaml
try:
    with open('config/license.yml', 'r') as f:
        data = yaml.safe_load(f)
    print(data.get('license', 'MIT'))
except:
    print('MIT')
")
            # Get service name for README generation  
            service_name=$(python3 -c "
import yaml
try:
    with open('config/docker.yml', 'r') as f:
        data = yaml.safe_load(f)
    print(data.get('service_name', 'app'))
except:
    print('app')
")
            generate_readme "$output_dir" "$project_name" "$license_type" "$service_name"
            ;;
        "license")
            # Get license type
            license_type=$(python3 -c "
import yaml
try:
    with open('config/license.yml', 'r') as f:
        data = yaml.safe_load(f)
    print(data.get('license', 'MIT'))
except:
    print('MIT')
")
            get_license_content "$license_type" > "$output_dir/LICENSE"
            echo -e "${GREEN}✅ Generated: ${WHITE}LICENSE${NC}"
            ;;
        "docker")
            # Generate Docker files
            generate_from_template "docker/dockerfile.cpu" "$output_dir/docker/dockerfile.cpu"
            generate_from_template "docker/dockerfile.gpu" "$output_dir/docker/dockerfile.gpu"
            generate_from_template "docker/compose.cpu.yml" "$output_dir/docker/compose.cpu.yml"
            generate_from_template "docker/compose.gpu.yml" "$output_dir/docker/compose.gpu.yml"
            ;;
        "github")
            # Generate GitHub workflow files
            generate_from_template "github/docker.cpu.yml" "$output_dir/.github/workflows/docker.cpu.yml"
            generate_from_template "github/docker.gpu.yml" "$output_dir/.github/workflows/docker.gpu.yml"
            ;;
    esac
done <<< "$features"

# Generate .gitignore
generate_gitignore "$output_dir"

# Handle test mode finalization or normal mode output
if [ "$TEST_MODE" = true ]; then
    finalize_test_mode
else
    echo ""
    echo -e "${WHITE}📂 Scaffold structure:${NC}"
    if [ -d "$output_dir" ]; then
        tree "$output_dir" -a --dirsfirst -I '.git'
    else
        echo -e "${RED}  ✗ Directory not found${NC}"
    fi
fi
