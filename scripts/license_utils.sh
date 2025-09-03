#!/bin/bash
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# license_utils.sh - License template selection and content generation utility module
#
# DESCRIPTION:
#   This module provides functions to generate license content based on template files.
#   It automatically fills in current year and author information into license templates.
#
# FUNCTIONS:
#   get_license_content <license_name>
#     - Generates license content for specified license type
#     - Automatically replaces <year> with current year
#     - Automatically replaces <copyright holder> with current user
#     - Supported licenses: MIT, Apache-2.0, GPL-3.0
#
# USAGE EXAMPLES:
#   source ./scripts/license_utils.sh
#   get_license_content "MIT"           # Generate MIT license content
#   get_license_content "Apache-2.0"   # Generate Apache 2.0 license content
#   get_license_content "GPL-3.0"      # Generate GPL 3.0 license content
#
# DEPENDENCIES:
#   - Template files in ../templates/license/ directory
#   - sed command for text replacement
#   - date command for current year
#   - whoami command for current user
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

# Color definitions
RED='\033[0;31m'
NC='\033[0m' # No Color

function get_license_content() {
    local license_name="$1"
    local year=$(date +%Y)
    local author=$(whoami)
    
    # Determine the correct path to templates
    local template_path
    if [ -f "templates/license/$license_name.txt" ]; then
        template_path="templates/license/$license_name.txt"
    elif [ -f "../templates/license/$license_name.txt" ]; then
        template_path="../templates/license/$license_name.txt"
    else
        echo -e "${RED}Error: Template file not found for license: $license_name${NC}" >&2
        return 1
    fi
    
    case "$license_name" in
        'MIT')
            cat "$template_path" | sed "s/<year>/$year/; s/<copyright holder>/$author/"
            ;;
        'Apache-2.0')
            cat "$template_path" | sed "s/<year>/$year/; s/<copyright holder>/$author/"
            ;;
        'GPL-3.0')
            cat "$template_path" | sed "s/<year>/$year/; s/<copyright holder>/$author/"
            ;;
        *)
            echo -e "${RED}Unknown license: $license_name${NC}" >&2
            return 1
            ;;
    esac
}
