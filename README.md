# application-application

## Getting Started

### Setting up encrypted values

`make init-encrypt` will create 2 files: 

- `age.agekey` (Put this in this repository's `SOPS_AGE_KEY`)
- `age.pubkey`

Put your plaintext values for your k8s secrets in `ops/secrets/application-application-secrets/values.dec.yaml`. You can then use `make encrypt-secrets SECRETS_DIR=./ops/secrets/application-application-secrets` to encrypt the secrets into `values.sops.yaml`, which can be committed. The deployment process will decrypt these values with the aforementioned reporisory secret.

#### Useful commands

`docker compose up --build`

`docker compose down --remove-orphans --volumes`
