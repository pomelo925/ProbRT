#!/usr/bin/env python3
"""
Template processor for rtgen - Repository Template Generator

This script processes template files with variable substitution using YAML configuration.
Supports Jinja2-like syntax for variables, conditionals, and loops.
"""

import os
import re
import sys
import yaml
import argparse
from pathlib import Path


def load_yaml_config(config_file):
    """Load YAML configuration file."""
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Error loading {config_file}: {e}", file=sys.stderr)
        return {}


def flatten_dict(d, parent_key='', sep='.'):
    """Flatten nested dictionary with dot notation."""
    items = []
    for k, v in d.items():
        new_key = f'{parent_key}{sep}{k}' if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten_dict(v, new_key, sep=sep).items())
        elif isinstance(v, list):
            # Convert lists to comma-separated strings for simple templating
            if all(isinstance(item, (str, int, float, bool, type(None))) for item in v):
                items.append((new_key, v))
            else:
                items.append((new_key, v))
        else:
            items.append((new_key, v))
    return dict(items)


def get_nested_value(data, key_path):
    """Get value from nested dictionary using dot notation."""
    keys = key_path.split('.')
    value = data
    try:
        for key in keys:
            if isinstance(value, dict):
                value = value[key]
            else:
                return None
        return value
    except (KeyError, TypeError):
        return None


def process_template(template_content, config_data):
    """Process template content with variable substitution."""
    
    def replace_variable(match):
        var_name = match.group(1).strip()
        
        # Handle filters like | add_prefix('- ')
        if '|' in var_name:
            parts = var_name.split('|')
            var_name = parts[0].strip()
            filter_expr = parts[1].strip()
            
            value = get_nested_value(config_data, var_name)
            if value is None:
                return match.group(0)
            
            # Process filters
            if filter_expr.startswith('add_prefix('):
                prefix = filter_expr[11:-1].strip('\'"')
                if isinstance(value, list):
                    return '\n      '.join([f"{prefix}{item}" for item in value])
                else:
                    return f"{prefix}{value}"
            elif filter_expr.startswith('join('):
                separator = filter_expr[5:-1].strip('\'"')
                if isinstance(value, list):
                    return separator.join(map(str, value))
                else:
                    return str(value)
        else:
            value = get_nested_value(config_data, var_name)
            
        if value is None:
            return match.group(0)  # Keep original if not found
        
        if isinstance(value, list):
            if var_name.endswith('branches'):
                # Special handling for GitHub branches
                return '[ ' + ', '.join([f'"{branch}"' for branch in value]) + ' ]'
            else:
                return ', '.join(map(str, value))
        elif isinstance(value, bool):
            return 'true' if value else 'false'
        else:
            return str(value)
    
    # Replace {{ variable }} patterns
    content = re.sub(r'\{\{\s*([^}]+)\s*\}\}', replace_variable, template_content)
    
    # Handle conditional blocks {% if condition %}...{% endif %}
    def process_conditional(match):
        condition = match.group(1).strip()
        content_block = match.group(2)
        
        # Evaluate condition
        value = get_nested_value(config_data, condition)
        if value is None:
            return ''
        
        # Check if condition is true
        if isinstance(value, bool):
            return content_block if value else ''
        elif isinstance(value, str):
            return content_block if value.lower() in ['true', '1', 'yes', 'on'] else ''
        elif isinstance(value, (int, float)):
            return content_block if value != 0 else ''
        else:
            return content_block if value else ''
    
    content = re.sub(r'\{\%\s*if\s+([^%]+)\s*\%\}(.*?)\{\%\s*endif\s*\%\}', 
                     process_conditional, content, flags=re.DOTALL)
    
    # Handle for loops {% for item in list %}...{% endfor %}
    def process_loop(match):
        var_name = match.group(1).strip()
        list_var = match.group(2).strip()
        loop_content = match.group(3)
        
        # Get list data
        list_data = get_nested_value(config_data, list_var)
        if not isinstance(list_data, list):
            return ''
        
        result = []
        for item in list_data:
            item_content = loop_content.replace(f'{{{ var_name }}}', str(item))
            item_content = item_content.replace(f'{{{{ {var_name} }}}}', str(item))
            result.append(item_content)
        
        return ''.join(result)
    
    content = re.sub(r'\{\%\s*for\s+(\w+)\s+in\s+([^%]+)\s*\%\}(.*?)\{\%\s*endfor\s*\%\}', 
                     process_loop, content, flags=re.DOTALL)
    
    return content


def load_all_configs(settings_file):
    """Load main settings and all feature-specific config files."""
    settings = load_yaml_config(settings_file)
    all_config = settings.copy()
    
    # Load feature-specific configs and merge them (don't overwrite if already exists)
    config_files = settings.get('config_files', {})
    for feature, config_path in config_files.items():
        if os.path.exists(config_path):
            feature_config = load_yaml_config(config_path)
            # Only load if not already defined in settings
            if feature not in all_config:
                all_config[feature] = feature_config
            else:
                # Merge configurations, giving priority to settings.yml
                for key, value in feature_config.items():
                    if key not in all_config[feature]:
                        all_config[feature][key] = value
    
    return all_config


def main():
    parser = argparse.ArgumentParser(description='Process rtgen templates')
    parser.add_argument('template', help='Template file to process')
    parser.add_argument('output', help='Output file path')
    parser.add_argument('--settings', default='settings.yml', help='Settings YAML file')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.template):
        print(f"Error: Template file {args.template} not found", file=sys.stderr)
        sys.exit(1)
    
    if not os.path.exists(args.settings):
        print(f"Error: Settings file {args.settings} not found", file=sys.stderr)
        sys.exit(1)
    
    # Load all configurations
    config_data = load_all_configs(args.settings)
    
    # Read template
    try:
        with open(args.template, 'r', encoding='utf-8') as f:
            template_content = f.read()
    except Exception as e:
        print(f"Error reading template: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Process template
    processed_content = process_template(template_content, config_data)
    
    # Write output
    try:
        os.makedirs(os.path.dirname(args.output), exist_ok=True)
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(processed_content)
        print(f"Generated: {args.output}")
    except Exception as e:
        print(f"Error writing output: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
