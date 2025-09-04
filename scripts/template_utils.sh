#!/bin/bash

#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# template_utils.sh - Template processing utilities for rtgen
#
# DESCRIPTION:
#   This script provides functions for processing templates with variable substitution.
#   It uses a Python script for complex template processing.
#
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

# Function to generate files from templates
# Usage: generate_from_template <template_name> <output_path>
generate_from_template() {
    local template_name="$1"
    local output_path="$2"
    
    local template_file="templates/$template_name"
    
    if [ -f "$template_file" ]; then
        python3 scripts/process_template.py "$template_file" "$output_path" --settings settings.yml
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Generated: ${WHITE}$output_path${NC}"
        else
            echo -e "${RED}❌ Failed to generate: ${WHITE}$output_path${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Template not found: ${WHITE}$template_file${NC}"
    fi
}
