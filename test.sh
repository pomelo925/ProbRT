#!/bin/bash
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# test.sh - Testing script for dockerT repository scaffold generator
#
# DESCRIPTION:
#   This script tests the dockerT generator by creating a test output directory
#   and running the generation process. It cleans up previous test results
#   before each run to ensure clean testing environment.
#
# FEATURES:
#   - Automatic cleanup of previous test results
#   - Creates isolated test environment in test-output/ directory
#   - Tests different license types
#   - Validates generated files
#
# USAGE:
#   ./test.sh                   # Run complete test suite
#   ./test.sh clean            # Only clean test output directory
#   ./test.sh mit              # Test only MIT license generation
#   ./test.sh apache           # Test only Apache-2.0 license generation
#   ./test.sh gpl              # Test only GPL-3.0 license generation
#
# OUTPUT:
#   - test-output/ directory with generated files
#   - Test results and validation messages
#
# DEPENDENCIES:
#   - gen.sh generator script
#   - settings.yml configuration file
#   - All template files and utility scripts
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#

# Function to clean up test directory
cleanup_test() {
    echo "Cleaning up generated repository..."
    if [ -d "generated-repo" ]; then
        rm -rf "generated-repo"
    fi
}

# Function to backup original settings
backup_settings() {
    if [ -f "settings.yml" ]; then
        cp settings.yml settings.yml.backup
    fi
}

# Function to restore original settings
restore_settings() {
    if [ -f "settings.yml.backup" ]; then
        mv settings.yml.backup settings.yml
    fi
}

# Function to test license generation
test_license() {
    local license_type="$1"
    echo "Testing $license_type license generation..."
    
    # Update settings.yml for this test
    sed -i "s/^license:.*/license: $license_type/" settings.yml
    
    # Run generator (it will create generated-repo in root directory)
    ./gen.sh
    
    # Check if generated-repo directory was created
    if [ -d "generated-repo" ]; then
        echo "✓ Generated repository directory created"
        
        # Validate generated files
        if [ -f "generated-repo/LICENSE" ]; then
            echo "✓ LICENSE file generated successfully"
            echo "First few lines of generated LICENSE:"
            head -3 generated-repo/LICENSE
            echo ""
        else
            echo "✗ LICENSE file not generated"
        fi
        
        if [ -f "generated-repo/README.md" ]; then
            echo "✓ README.md generated successfully"
        else
            echo "✗ README.md not generated"
        fi
        
        if [ -f "generated-repo/.gitignore" ]; then
            echo "✓ .gitignore generated successfully"
        else
            echo "✗ .gitignore not generated"
        fi
        
        if [ -f "generated-repo/docker/Dockerfile.app" ]; then
            echo "✓ Dockerfile generated successfully"
        else
            echo "✗ Dockerfile not generated"
        fi
        
        if [ -f "generated-repo/docker/compose.app.yml" ]; then
            echo "✓ Docker Compose file generated successfully"
        else
            echo "✗ Docker Compose file not generated"
        fi
        
        if [ -f "generated-repo/.github/workflows/docker.app.yml" ]; then
            echo "✓ GitHub workflow generated successfully"
        else
            echo "✗ GitHub workflow not generated"
        fi
        
        echo "Generated repository structure:"
        find generated-repo -type f | sort
        echo ""
        
    else
        echo "✗ Generated repository directory not created"
    fi
}

# Main test function
run_tests() {
    echo "Starting dockerT test suite..."
    echo "==============================="
    
    cleanup_test
    backup_settings
    
    # Test different license types
    test_license "MIT"
    test_license "Apache-2.0"
    test_license "GPL-3.0"
    
    restore_settings
    
    echo "==============================="
    echo "Test suite completed!"
    echo "Check generated-repo/ directory for generated files"
}

# Handle command line arguments
case "$1" in
    "clean")
        cleanup_test
        echo "Generated repository cleaned"
        ;;
    "mit")
        cleanup_test
        backup_settings
        test_license "MIT"
        restore_settings
        ;;
    "apache")
        cleanup_test
        backup_settings
        test_license "Apache-2.0"
        restore_settings
        ;;
    "gpl")
        cleanup_test
        backup_settings
        test_license "GPL-3.0"
        restore_settings
        ;;
    *)
        run_tests
        ;;
esac
