#!/bin/bash

#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# test.sh - Testing script for dockerT repository scaffold generator
#
# DESCRIPTION:
#   This script tests the dockerT generator by using the configuration settings
#   and running the generation process. It always generates to gen-test/ directory
#   relative to FastRT root folder for testing purposes.
#
# FEATURES:
#   - Uses settings from settings.yml directly
#   - Always generates to gen-test/ directory for testing
#   - Automatic cleanup of previous test results
#   - Validates generated files
#
# USAGE:
#   ./test.sh                   # Run test using current settings.yml
#
# OUTPUT:
#   - Generated repository in gen-test/ directory
#   - Test results and validation messages
#
# DEPENDENCIES:
#   - gen.sh generator script
#   - settings.yml configuration file
#   - All template files and utility scripts
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Read configuration from settings.yml
project_name=$(grep '^project_name:' settings.yml | sed 's/^project_name: *//' | sed 's/ *#.*//')
license_type=$(grep '^license:' settings.yml | awk '{print $2}')

# Set defaults and test output directory
project_name=${project_name:-"My New Project"}
license_type=${license_type:-"MIT"}
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # FastRT root directory
test_output_dir="$script_dir/gen-test"  # Always use gen-test for testing

# Function to clean up test directory
cleanup_test() {
    if [ -d "$test_output_dir" ]; then
        rm -rf "$test_output_dir"
        echo -e "${YELLOW}🧹 Cleaned ${WHITE}$(realpath "$test_output_dir" 2>/dev/null || echo "gen-test")${NC}"
    fi
}

# Function to run the test
run_test() {
    echo -e "${BLUE}🧪 Testing FastRT Generator${NC}"
    echo -e "${CYAN}📦 Project: ${WHITE}$project_name${NC}"
    echo -e "${CYAN}📁 Test dir: ${WHITE}$(realpath "$test_output_dir")${NC}"
    echo ""
    
    cleanup_test
    
    # Run generator with custom output directory for testing
    ./gen.sh --output gen-test
    
    echo ""
    # Check if test output directory was created 
    if [ -d "$test_output_dir" ]; then
        local file_count=$(find "$test_output_dir" -type f | wc -l)
        echo -e "${GREEN}✅ Test completed!${NC} Generated ${WHITE}$file_count files${NC}"
    else
        echo -e "${RED}✗ Test directory not created${NC}"
    fi
    
    echo -e "${PURPLE}📋 Full path: ${WHITE}$(realpath "$test_output_dir" 2>/dev/null || echo "$test_output_dir")${NC}"
}

# Run the test
run_test