<div align="center">

# ProbRT

<p align="center">
  <strong>Project-based Repository Template</strong>
</p>


[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]


</div>

<div align="center" style="max-width: 80%; margin: 0 auto;">

ProbRT is a project-based repository template that provides a complete development environment with Docker containerization, GitHub workflows, and standardized project structures. It offers both CPU and GPU support with multi-stage builds and CI/CD pipelines.

</div>

<div align="center">

</br>

## Getting Started

</div>

### Prerequisites

Before using ProbRT, ensure you have the following installed on your Linux system:

- **Docker & Docker Compose**: Required for containerized development
- **Git**: For version control and submodule management
- **NVIDIA Docker Runtime**: Required for GPU support (optional)

</br>

### Installation & Usage

1. Clone the repository with submodules:
   ```bash
   git clone --recursive https://github.com/pomelo925/ProbRT.git
   cd ProbRT
   ```

2. Run the development environment:
   ```bash
   ./run.sh <device> <service>
   ```

   <details>
   <summary><strong>Examples</strong></summary>
   
   ```bash
   ./run.sh cpu dev       # Start CPU development environment
   ./run.sh gpu deploy    # Start GPU deployment service
   ```
   </details>

3. Configure GitHub Actions secrets for CI/CD workflows:
   - Go to your repository **Settings** → **Secrets and variables** → **Actions**
   - Add the following repository secrets:
     - `DOCKERHUB_USERNAME`: Your Docker Hub username
     - `DOCKERHUB_TOKEN`: Your Docker Hub access token
   - These secrets enable automatic Docker image building and pushing via GitHub Actions

<div align="center">

</br>

## Project Structure

</div>

```
ProbRT/
├── run.sh                      # Main execution script for Docker services
├── docker/                     # Docker configuration files
│   ├── dockerfile.cpu              # CPU-only multi-stage Dockerfile
│   ├── dockerfile.gpu              # GPU-enabled multi-stage Dockerfile
│   ├── compose.cpu.yml             # CPU Docker Compose configuration
│   └── compose.gpu.yml             # GPU Docker Compose configuration
├── .github/                    # GitHub workflows and CI/CD
│   └── workflows/
│       ├── docker.cpu.yml          # CPU Docker build and push workflow
│       └── docker.gpu.yml          # GPU Docker build and push workflow
├── workspace/                  # Development workspace (mounted as volume)
└── README.md                   # Project documentation
```

<div align="center">

</br>

## Docker Services

</div>

### CPU Services
- **dev**: Development environment with interactive shell access
- **deploy**: Deployment service for production applications

### GPU Services  
- **dev**: GPU-enabled development environment with NVIDIA runtime
- **deploy**: GPU-accelerated deployment service

All services include:
- Health checks for application monitoring
- Volume mounts for development workspace
- X11 forwarding for GUI applications
- Multi-stage builds for optimized container size

<div align="center">

</br>

## License

</div>

Distributed under the MIT License. See `LICENSE` for more information.

</br>

<div align="center">

## Contributors

</div>

<a href="https://github.com/pomelo925/ProbRT/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=pomelo925/ProbRT" />
</a>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/pomelo925/ProbRT.svg?style=for-the-badge
[contributors-url]: https://github.com/pomelo925/ProbRT/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/pomelo925/ProbRT.svg?style=for-the-badge
[forks-url]: https://github.com/pomelo925/ProbRT/network/members
[stars-shield]: https://img.shields.io/github/stars/pomelo925/ProbRT.svg?style=for-the-badge
[stars-url]: https://github.com/pomelo925/ProbRT/stargazers
[issues-shield]: https://img.shields.io/github/issues/pomelo925/ProbRT.svg?style=for-the-badge
[issues-url]: https://github.com/pomelo925/ProbRT/issues
[license-shield]: https://img.shields.io/github/license/pomelo925/ProbRT.svg?style=for-the-badge
[license-url]: https://github.com/pomelo925/ProbRT/blob/main/LICENSE