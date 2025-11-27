# Contributing to Magento Docker FrankenPHP

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone. Please be considerate of others and avoid any form of harassment or discrimination.

## Getting Started

### Prerequisites

Before contributing, ensure you have the following installed:

- Docker >= 24.0
- Docker Compose >= 2.20
- Git
- A text editor or IDE
- [hadolint](https://github.com/hadolint/hadolint) (optional, for Dockerfile linting)
- [shellcheck](https://www.shellcheck.net/) (optional, for shell script linting)

### Setting Up the Development Environment

1. Fork the repository on GitHub
2. Clone your fork locally:

   ```bash
   git clone https://github.com/YOUR_USERNAME/magento-docker-frankenphp.git
   cd magento-docker-frankenphp
   ```

3. Add the upstream remote:

   ```bash
   git remote add upstream https://github.com/CleatSquad/magento-docker-frankenphp.git
   ```

4. Run the setup script:

   ```bash
   ./bin/setup
   ```

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

- **Bug fixes**: Fix issues identified in the GitHub issue tracker
- **New features**: Add new functionality or improve existing features
- **Documentation**: Improve or add documentation
- **Testing**: Add or improve tests
- **Code quality**: Refactor code, improve performance, or fix linting issues

### Contribution Process

1. Check the [issue tracker](https://github.com/CleatSquad/magento-docker-frankenphp/issues) for existing issues
2. If you want to work on something new, create an issue first to discuss it
3. Assign yourself to the issue you want to work on
4. Create a feature branch from `main`
5. Make your changes following the coding standards
6. Test your changes thoroughly
7. Submit a pull request

## Development Workflow

### Branching Strategy

- `main`: Production-ready code
- Feature branches: `feature/description` or `feat/description`
- Bug fix branches: `fix/description` or `bugfix/description`
- Documentation branches: `docs/description`

### Making Changes

1. Create a new branch from `main`:

   ```bash
   git checkout main
   git pull upstream main
   git checkout -b feature/your-feature-name
   ```

2. Make your changes

3. Commit your changes with meaningful commit messages:

   ```bash
   git add .
   git commit -m "feat: add support for PHP 8.5"
   ```

   We follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `chore:` for maintenance tasks
   - `refactor:` for code refactoring
   - `test:` for adding or updating tests

4. Push your branch:

   ```bash
   git push origin feature/your-feature-name
   ```

## Coding Standards

### Dockerfiles

- Follow [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- Use multi-stage builds when appropriate
- Minimize the number of layers
- Use specific version tags for base images
- Include `LABEL maintainer` information
- Clean up apt cache and temporary files in the same `RUN` instruction
- Run `hadolint` to check for issues:

  ```bash
  hadolint images/php/8.4/base/Dockerfile
  ```

### Shell Scripts

- Use `#!/bin/bash` as the shebang
- Include `set -e` to exit on errors
- Add meaningful comments for complex logic
- Use double quotes around variables: `"${variable}"`
- Use lowercase for local variables, UPPERCASE for environment variables
- Run `shellcheck` to check for issues:

  ```bash
  shellcheck bin/setup
  ```

### YAML Files

- Use 2-space indentation
- Include comments for complex configurations
- Validate syntax before committing

### General Guidelines

- Keep lines under 100 characters when possible
- Use meaningful variable and function names
- Avoid hardcoding values; use environment variables where appropriate
- Document any non-obvious code

## Testing

### Manual Testing

Before submitting a pull request, manually test your changes:

1. Build the Docker images:

   ```bash
   docker compose build
   ```

2. Start the services:

   ```bash
   docker compose up -d
   ```

3. Verify the services are running:

   ```bash
   docker compose ps
   docker compose logs
   ```

4. Test the specific functionality you modified

### Automated Tests

The project uses GitHub Actions for CI/CD. When you submit a pull request, the following checks run automatically:

- Dockerfile linting with hadolint
- Shell script linting with shellcheck
- YAML validation
- Docker image build verification

## Submitting Changes

### Pull Request Process

1. Update documentation if your changes affect usage
2. Update the CHANGELOG.md with your changes under `[Unreleased]`
3. Ensure all CI checks pass
4. Request a review from maintainers
5. Address any feedback from reviewers
6. Once approved, your PR will be merged

### Pull Request Guidelines

- Use a clear and descriptive title
- Include a detailed description of your changes
- Reference any related issues using `Fixes #123` or `Closes #123`
- Keep PRs focused on a single change
- Include screenshots for UI-related changes

### Pull Request Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Other (please describe)

## Testing

Describe how you tested your changes

## Checklist

- [ ] My code follows the project's coding standards
- [ ] I have updated the documentation accordingly
- [ ] I have added entries to CHANGELOG.md
- [ ] All CI checks pass
```

## Reporting Issues

### Bug Reports

When reporting a bug, include:

- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Environment details (OS, Docker version, etc.)
- Relevant logs or error messages
- Screenshots if applicable

### Feature Requests

When requesting a feature, include:

- A clear and descriptive title
- Detailed description of the proposed feature
- Use case or problem it solves
- Any alternative solutions you've considered

## Questions?

If you have questions about contributing, feel free to:

- Open a discussion on GitHub
- Create an issue with the `question` label
- Contact the maintainer at contact@cleatsquad.dev

Thank you for contributing! 🎉
