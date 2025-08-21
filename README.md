# application-application

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
