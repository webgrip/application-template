# application-application

[![Build Status](https://img.shields.io/github/actions/workflow/status/organisation/application-application/test.yml?style=for-the-badge)](https://github.com/organisation/application-application/actions)
[![License](https://img.shields.io/github/license/organisation/application-application?style=for-the-badge)](LICENSE)

---

## Description

...

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
