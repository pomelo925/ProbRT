<div align="center">

# RTGen

<p align="center">
  <strong>Github Repository Template Generator</strong>
</p>


[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]


</div>

<div align="center">

</div>

RTGen is a fast and efficient repository template generator that helps developers quickly bootstrap projects with standardized configurations and structures. It provides pre-configured templates for Docker, GitHub workflows, licenses, and more.

<div align="center">

</br>

## Getting Started

</div>

### Prerequisites

Before using RTGen, ensure you have the following installed on your Linux system:

- **Bash/Fish Shell**: Required for running the generation scripts
- **Git**: For version control and repository management

</br>

### Installation & Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/pomelo925/rtgen.git
   cd rtgen
   ```

2. Run scripts to generate project:
   ```bash
   chmod +x gen.sh test.sh
   source ./gen.sh
   ```

<div align="center">

</br>

## Project Structure

</div>

```
rtgen/
├── gen.sh                      # Main generation script
├── test.sh                     # Testing script for generated projects
├── settings.yml                # Global project settings and feature toggles
├── config/                     # Task-oriented configuration files
│   ├── readme.yml              # README.md generation settings
│   ├── docker.yml              # Docker containerization settings
│   ├── license.yml             # License file configuration
│   └── github.yml              # GitHub workflows and repository settings
├── templates/                  # Template files for generation
│   ├── docker/                 # Docker templates (Dockerfile, compose)
│   ├── github/                 # GitHub workflow templates
│   ├── gitignore/              # Language-specific .gitignore files
│   ├── license/                # License templates (MIT, Apache, GPL)
│   └── readme/                 # README.md template
├── scripts/                    # Utility scripts
│   ├── docker_utils.sh         # Docker-related helper functions
│   ├── file_utils.sh           # File operation utilities
│   └── license_utils.sh        # License generation helpers
└── gen-test/                   # Example generated project for testing
```

<div align="center">

</br>

## License

</div>

Distributed under the MIT License. See `LICENSE` for more information.

</br>

<div align="center">

## Contributors

</div>

<a href="https://github.com/pomelo925/rtgen/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=pomelo925/rtgen" />
</a>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/pomelo925/rtgen.svg?style=for-the-badge
[contributors-url]: https://github.com/pomelo925/rtgen/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/pomelo925/rtgen.svg?style=for-the-badge
[forks-url]: https://github.com/pomelo925/rtgen/network/members
[stars-shield]: https://img.shields.io/github/stars/pomelo925/rtgen.svg?style=for-the-badge
[stars-url]: https://github.com/pomelo925/rtgen/stargazers
[issues-shield]: https://img.shields.io/github/issues/pomelo925/rtgen.svg?style=for-the-badge
[issues-url]: https://github.com/pomelo925/rtgen/issues
[license-shield]: https://img.shields.io/github/license/pomelo925/rtgen.svg?style=for-the-badge
[license-url]: https://github.com/pomelo925/rtgen/blob/main/LICENSE