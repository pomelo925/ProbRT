<div align="center">

# ⚙️ Configuration Guide

</div>

<div align="center">

## 📖 Overview

</div>

This directory contains task-oriented configuration files that allow you to customize different aspects of your generated project. Each YAML file is focused on a specific task or component, making it easy to configure exactly what you need.

<div align="center">

## 📁 Configuration Files

</div>

### `readme.yml` - README Generation
Configure README.md generation with:
- **Project information**: GitHub username, repository name, tagline
- **Content blocks**: Description, prerequisites, installation instructions
- **Template options**: Badges, contributors section, license section

### `docker.yml` - Docker Configuration  
Configure Docker-related files with:
- **Image settings**: Base image, working directory, ports
- **Docker Compose**: Service configuration, volumes, environment variables
- **Build options**: Context, dockerfile, health checks

### `license.yml` - License Configuration
Configure LICENSE file generation with:
- **License type**: MIT, Apache-2.0, GPL-3.0, BSD-3-Clause, ISC
- **Copyright info**: Holder name, year, project details
- **Additional options**: Year ranges, notice files

### `github.yml` - GitHub Integration
Configure GitHub workflows and repository files with:
- **Workflows**: CI/CD, testing, security scans
- **Templates**: Issue and PR templates
- **Settings**: Pages, Dependabot, branch protection

<div align="center">

## 🚀 Usage

</div>

### 1. Task-Oriented Configuration

Each configuration file focuses on a specific task:

```bash
# Configure README generation
config/readme.yml

# Configure Docker setup  
config/docker.yml

# Configure licensing
config/license.yml

# Configure GitHub integration
config/github.yml
```

### 2. Customization Examples

**README Configuration (`readme.yml`)**:
```yaml
github_username: your-username
repo_name: awesome-project
project_tagline: "An awesome project description"

project_description: |
  Your detailed project description here.
  Supports multiple lines and Markdown formatting.
```

**Docker Configuration (`docker.yml`)**:
```yaml
base_image: node:18-alpine
ports:
  expose: [3000]
service_name: web-app
```

### 3. Template Variables

These variables are automatically replaced in templates:

**README Variables**:
- `<github_username>` → Your GitHub username
- `<repo_name>` → Repository name
- `<project_tagline>` → Project tagline
- `<project_description>` → Project description block

**Docker Variables**:
- `<base_image>` → Docker base image
- `<service_name>` → Service name
- `<ports>` → Port configuration

<div align="center">

## 💡 Tips

</div>

1. **Task-focused**: Each YAML file handles a specific aspect of project generation
2. **Modular configuration**: Enable/disable features independently in each file
3. **Environment-specific**: Create multiple config files for different environments (dev, prod)
4. **Version control**: Keep configurations in version control for team consistency
5. **Validation**: YAML syntax is validated during generation process

<div align="center">

## 📄 Example Workflow

</div>

1. **Configure README**: Edit `readme.yml` with your project details
2. **Setup Docker**: Configure `docker.yml` if using containerization  
3. **Choose License**: Set license type in `license.yml`
4. **GitHub Integration**: Configure workflows in `github.yml`
5. **Generate**: Run RTGen with your task-specific configurations

```bash
# Generate with specific configurations
./gen.sh --config-dir config/
```

This task-oriented approach makes it easy to maintain and update specific aspects of your project without affecting others.
