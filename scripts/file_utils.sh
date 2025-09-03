#!/bin/bash
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# file_utils.sh - File generation utility module from templates
#
# DESCRIPTION:
#   This module provides functions to generate various project files from templates.
#   It handles README.md, .gitignore, and GitHub workflow generation.
#
# FUNCTIONS:
#   generate_readme <output_dir> <repo_name> <license_name> <service_name>
#     - Generates README.md from template with variable substitution
#   
#   generate_gitignore <output_dir>
#     - Copies .gitignore template to output directory
#   
#   generate_github_workflow <output_dir> <service_name>
#     - Generates GitHub Actions workflow from template
#
# USAGE EXAMPLES:
#   source ./scripts/file_utils.sh
#   generate_readme "./output" "my-app" "MIT" "app"
#   generate_gitignore "./output"
#   generate_github_workflow "./output" "app"
#
# DEPENDENCIES:
#   - Template files in templates/ directory
#   - sed command for text replacement
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

function generate_readme() {
    local output_dir="$1"
    local repo_name="${2:-my-new-repo}"
    local license_name="${3:-MIT}"
    local service_name="${4:-app}"
    
    # Determine the correct path to templates
    local template_path
    if [ -f "templates/readme/README.md" ]; then
        template_path="templates/readme/README.md"
    elif [ -f "../templates/readme/README.md" ]; then
        template_path="../templates/readme/README.md"
    else
        echo "Error: README template not found"
        return 1
    fi
    
    cat "$template_path" | \
        sed "s/<repo_name>/$repo_name/g; s/<license_name>/$license_name/g; s/<service_name>/$service_name/g" \
        > "$output_dir/README.md"
    
    echo "✓ README.md generated"
}

function generate_gitignore() {
    local output_dir="$1"
    
    # Determine the correct path to templates
    local template_path
    if [ -f "templates/gitignore/.gitignore" ]; then
        template_path="templates/gitignore/.gitignore"
    elif [ -f "../templates/gitignore/.gitignore" ]; then
        template_path="../templates/gitignore/.gitignore"
    else
        echo "Error: .gitignore template not found"
        return 1
    fi
    
    cp "$template_path" "$output_dir/.gitignore"
    
    echo "✓ .gitignore generated"
}

function generate_github_workflow() {
    local output_dir="$1"
    local service_name="${2:-app}"
    
    mkdir -p "$output_dir/.github/workflows"
    
    # Determine the correct path to templates
    local template_path
    if [ -f "templates/github/workflow.yml" ]; then
        template_path="templates/github/workflow.yml"
    elif [ -f "../templates/github/workflow.yml" ]; then
        template_path="../templates/github/workflow.yml"
    else
        echo "Error: GitHub workflow template not found"
        return 1
    fi
    
    cat "$template_path" | \
        sed "s/<service_name>/$service_name/g" \
        > "$output_dir/.github/workflows/docker.$service_name.yml"
    
    echo "✓ GitHub workflow generated: .github/workflows/docker.$service_name.yml"
}
