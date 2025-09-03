# application-application

## Badges

[![Template Sync](https://img.shields.io/github/actions/workflow/status/webgrip/application-template/sync-template-files.yml?label=template%20sync&style=flat-square)](https://github.com/webgrip/application-template/actions/workflows/sync-template-files.yml)
[![License](https://img.shields.io/github/license/webgrip/application-template?style=flat-square)](LICENSE)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-orange.svg?style=flat-square)](https://www.conventionalcommits.org)
[![SemVer](https://img.shields.io/badge/semver-2.0.0-blue?style=flat-square)](https://semver.org)
[![Dockerized](https://img.shields.io/badge/containerized-docker-2496ED?logo=docker&logoColor=white&style=flat-square)](https://www.docker.com/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](https://github.com/webgrip/application-template/issues)

> Opinionated application template focused on repeatable quality: tested workflows, semantic releases, and automatic template drift correction.

---

## At a Glance

| Aspect | What You Get |
| ------ | ------------- |
| CI/CD  | GitHub Actions pipelines & template sync |
| Consistency | Automatic sync of core config & workflow files to app repos (opt‑in via topic) |
| Quality | Conventional Commits + Semantic Versioning scaffolding |
| Documentation | TechDocs-ready structure for internal/platform portals |
| Security | Encrypted secrets handling via SOPS + age |
| Developer UX | Pre-configured editor & workflow automation |

## Features

- Automated template file synchronization (opt‑in per repo by GitHub topic)
- Semantic release readiness (`.releaserc.json` included)
- Encrypted secrets workflow (age / SOPS)
- Curated GitHub workflow set (docs changes, source changes)
- Opinionated baseline configs: EditorConfig, VSCode settings, .gitignore
- Structured test categories (unit, integration, functional, contract, e2e, smoke, performance, behavioral)

## Description

Foundation repository for bootstrapping internal / external application services with consistent engineering guardrails. Replace the placeholder service specifics with your domain logic while retaining the shared operational workflows.

## Template Synchronization

This repository serves as a template that can automatically sync certain files to application repositories. To enable template sync for your application repository, add the `application` topic to your repository.

**Synced Files Include:**

| Category | Files |
| -------- | ----- |
| Workflows | `.github/workflows/*.yml` (selected core automation) |
| Config | `.editorconfig`, `.gitignore`, `.releaserc.json` |
| Dev UX | `.vscode/settings.json` |

These represent the "source of truth"; local divergent changes in target repos will be overwritten (review PRs carefully).

For detailed information, see the [Template Sync Documentation](docs/techdocs/template-sync.md).


## Getting Started

### Encrypted secrets

```bash
make init-encrypt
```

Creates:

- `age.agekey` → add to repo secret `SOPS_AGE_KEY`
- `age.pubkey` → used for encryption

Add plaintext secrets to:

```bash
ops/secrets/application-application-secrets/values.dec.yaml
```

Encrypt them:

```bash
make encrypt-secrets SECRETS_DIR=./ops/secrets/application-application-secrets
```

This produces `values.sops.yaml` (commit this).

---

### Docker

```bash
docker compose up --build
docker compose down --remove-orphans --volumes
```

---

## Contributing

Contributions welcome! Please:

1. Open an issue describing the change
2. Use Conventional Commits for branch + commit messages
3. Add / adjust tests where behavior changes
4. Update docs (README / TechDocs / ADRs) when altering architecture

## Roadmap (Excerpt)

- [ ] Add coverage reporting & badge
- [ ] Introduce example service code scaffolding
- [ ] Provide k6 performance test harness
- [ ] Optional Terraform module integration

## License

Distributed under the terms of the MIT license. See `LICENSE` for details.
