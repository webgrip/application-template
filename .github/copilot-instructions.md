# application-application AI directives

This repository contains the code and infrastructure for the application-application service. The following directives outline the key practices and standards for working with this codebase.

## Conventions
- Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.
- Use [Semantic Versioning](https://semver.org/) for versioning releases.
- Document all architectural decisions in ADRs.
- Maintain a high level of test coverage (aim for ≥90%).
- Test behavior, not implementation.
- Make atomic commits. Intent matters—each commit should represent a single logical change.

## Major thought influences
| Thinker              | Core Idea We Adopt                      |
| -------------------- | --------------------------------------- |
| **Kent Beck**        | Test‑Driven Development, Small Releases |
| **Robert C. Martin** | Clean Code & SOLID                      |
| **Sam Newman**       | Micro‑services, Continuous Delivery     |
| **Eric Evans**       | Domain‑Driven Design                    |

These thinkers influence our approach to software development, take their philosophies to heart, and apply them in our work.

## Repository Structure
- `docs/adrs`: Architectural Decision Records
- `docs/techdocs`: Custom mkdocs documentation, based on Spotify's techdocs
- `ops/docker`: Dockerfiles for different parts of the application live here
- `ops/helm`: Helm chart for deploying the application
- `ops/secrets`: Helm chart to deploy encrypted secrets for the application to use
- `src/`: This is where the main application code, or the main subject of the repository, resides
- `tests/unit`: Unit tests for the application (Test isolated units/classes/components/functions)
- `tests/integration`: Integration tests for the application (Test the integration of several components)
- `tests/functional`: Whereas integration tests test the integration of several components, functional tests focus on the functionality of the application as a whole. (Sending requests and asserting responses)
- `tests/contract`: Contract tests for the application (Test the functionality against the contract)
- `tests/e2e`: Use a simulated browser environment to interact with the application (Playwright)
- `tests/smoke`: Tests that verify the basic functionality of the application (eg. health checks, basic API endpoint checks)
- `tests/manual`: Manual tests for the application. (eg. .http files, Postman collections, OpenAPI specifications)
- `tests/performance`: Performance tests for the application (JMeter, k6)

## Code Standards
- Follow [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript) for JavaScript code.
- Use [Prettier](https://prettier.io/) for code formatting.
- Use [ESLint](https://eslint.org/) for linting JavaScript code.
- Write unit tests for all new features and bug fixes.
- Use descriptive names for variables, functions, and classes.
- Keep functions small and focused on a single task.

## Detailed information about uncommon patterns in this repository

#### Secrets & Encryption
- Encrypted secrets are managed with age/sops. Plaintext secrets live under `ops/secrets/*/values.dec.yaml` and are encrypted with `make encrypt-secrets` (see `README.md`).