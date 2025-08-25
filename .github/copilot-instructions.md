These are short, actionable rules for an AI coding agent to be immediately productive in this repository.

1) Big picture
   - This repo builds the `firefly-application` service and supporting infra (see `ops/`, `docker-compose.yml`, `ops/docker/application/Dockerfile`).
   - Application artifacts are containerized and deployed via helm charts in `ops/helm/` (see `ops/helm/application-application/`).
   - ADRs live in `docs/adr/` and are authoritative for architectural intent — link any change to an ADR when structure is affected.

2) Where to look first (files that explain project flows)
   - `README.md` — high‑level getting started and secrets workflow.
   - `Makefile` — common developer commands (run `make` locally to discover targets).
   - `docker-compose.yml` — local dev runtime and service dependencies.
   - `ops/` — Dockerfiles, entrypoint scripts and helm charts; changes here affect CI/deploy pipelines.
   - `docs/techdocs/mkdocs.yml` — public tech docs navigation; update when adding pages.

3) Secrets & encryption
   - Encrypted secrets are managed with age/sops. Plaintext secrets live under `ops/secrets/*/values.dec.yaml` and are encrypted with `make encrypt-secrets` (see `README.md`).
   - Do not add secrets to the repo. If a code change needs access to secrets, reference the `values.dec.yaml` path and the encryption step.

4) Tests, builds and CI expectations
   - This project follows the rules in `AGENTS.md`: TDD-first, conventional commits, ADR for architectural changes, >=90% coverage per PR where applicable.
   - Local quick checks: use `docker compose up --build` for a local run; use `make init-encrypt` / `make encrypt-secrets` for secrets setup that gets deployed with helm to the cluster.
   - Prefer small, focused unit tests under `tests/unit` and contract/ integration tests under `tests/integration`.

5) Project conventions and patterns (specific)
   - Branches and commits use Conventional Commits and the branch naming conventions in `AGENTS.md` (e.g. `feat/<ticket>-slug`).
   - ADRs: add or update a file in `docs/adr/` for any cross‑service or deploy-affecting decisions. Use the repo template.
   - Docs: Add new tech docs to `docs/techdocs/` and update `mkdocs.yml` to expose them.
   - CI/Linting: expect pre‑commit and CI linters to run; run `make pre-commit` locally if present.

6) Integration points & external deps
   - Helm charts and `ops/docker/*` control runtime image layout and entrypoints (e.g. `ops/docker/application/scripts/docker-entrypoint.sh`).
   - The repo is configured for container builds and likely publishes images via the CI pipeline; avoid changing image tags without an ADR.

7) When making changes, be explicit
   - Update or reference ADRs for structural or infra changes.
   - Update `docs/techdocs` for user-facing changes.
   - Mention related `ops/` files (Dockerfile, helm values) in PR descriptions.

8) Useful search examples (quick patterns to use when exploring code)
   - Search for Docker entrypoints: `ops/docker/**/docker-entrypoint.sh` or `Dockerfile`.
   - Search for secrets: `ops/secrets/**/values.dec.yaml` and `values.sops.yaml`.
   - Search for ADRs: `docs/adr/*.md` and template at `docs/adr/template.md`.

9) What NOT to change without human review
   - `docs/techdocs` navigation, `ops/helm/*` charts, `ops/secrets/*` encrypted artifacts, and CI configuration files (they affect builds/releases).
