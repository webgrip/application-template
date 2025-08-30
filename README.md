# application-application

[![Build Status](https://img.shields.io/github/actions/workflow/status/organisation/application-application/test.yml?style=for-the-badge)](https://github.com/organisation/application-application/actions)
[![License](https://img.shields.io/github/license/organisation/application-application?style=for-the-badge)](LICENSE)

---

## Description

...

## Template Synchronization

This repository serves as a template that can automatically sync certain files to application repositories. To enable template sync for your application repository, add the `application` topic to your repository.

**Synced Files Include:**
- GitHub workflow files (`.github/workflows/`)
- Configuration files (`.editorconfig`, `.gitignore`, `.releaserc.json`)
- Development tools configuration (`.vscode/settings.json`)

For detailed information, see the [Template Sync Documentation](docs/techdocs/template-sync.md).

## Getting Started

### Encrypted secrets

```bash
make init-encrypt
```

Creates:

* `age.agekey` → add to repo secret `SOPS_AGE_KEY`
* `age.pubkey` → used for encryption

Add plaintext secrets to:

```
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
