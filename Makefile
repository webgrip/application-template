# =============================================================================
# Application Makefile
# -----------------------------------------------------------------------------
# Usage: make <target>
# Run `make help` to see all available targets.
# =============================================================================

# --- Core config --------------------------------------------------------------

SHELL := /usr/bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

# Tools (override if needed, e.g., COMPOSE="docker-compose")
COMPOSE ?= docker compose

# Services / paths
APP_SERVICE ?= application-application.application
ENV_FILE    ?= .env

# Helm / SOPS / AGE defaults (override at call time if you want)
HELM_CHART_DIR ?=
SECRETS_DIR    ?= ./secrets
AGE_KEY        ?= ./age.agekey
AGE_PUB        ?= ./age.pubkey
SOPS_FILE      ?= values.sops.yaml
DECRYPT_FILE   ?= values.dec.yaml

# Colors for nicer output
C_RESET := \033[0m
C_OK    := \033[32m
C_WARN  := \033[33m
C_ERR   := \033[31m
C_INFO  := \033[36m

# --- Helpers -----------------------------------------------------------------

define _req_cmd
	@if ! command -v $(1) >/dev/null 2>&1; then \
		printf "$(C_ERR)Missing dependency: $(1)$(C_RESET)\n"; \
		exit 1; \
	fi
endef

define _req_file
	@if [ ! -f "$(1)" ]; then \
		printf "$(C_ERR)Missing required file: $(1)$(C_RESET)\n"; \
		exit 1; \
	fi
endef

## Print a variable: make print-VAR VAR=NAME
print-VAR:
	@printf "$(C_INFO)%s=$(C_RESET)%s\n" "$(VAR)" "$($(VAR))"

# --- Top-level UX -------------------------------------------------------------

## Show available commands (this help)
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nCommands:\n"} \
	/^[a-zA-Z0-9_.-]+:.*##/ { printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2 } \
	END {print ""}' $(MAKEFILE_LIST)

# --- Docker lifecycle ---------------------------------------------------------

## Start containers in background
start:
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	$(COMPOSE) up -d
	@printf "$(C_OK)Started containers.$(C_RESET)\n"

## Stop and remove containers
stop:
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	$(COMPOSE) down
	@printf "$(C_OK)Stopped containers.$(C_RESET)\n"

## Follow logs (all services or SERVICE=name)
logs:
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@if [ -n "$$SERVICE" ]; then \
		printf "$(C_INFO)Following logs for %s...$(C_RESET)\n" "$$SERVICE"; \
		$(COMPOSE) logs -f $$SERVICE; \
	else \
		printf "$(C_INFO)Following logs (all services)...$(C_RESET)\n"; \
		$(COMPOSE) logs -f; \
	fi

## Exec into the app container (CMD=/bin/sh or e.g. CMD="/bin/bash -lc 'env | sort'")
enter:
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	: $${CMD:=/bin/sh}
	$(COMPOSE) exec $(APP_SERVICE) $$CMD

## Run an arbitrary command in a one-off app container: e.g. make run CMD="php -v"
run:
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@test -n "$$CMD" || { printf "$(C_ERR)Usage: make run CMD=\"...\"$(C_RESET)\n"; exit 1; }
	$(COMPOSE) run --rm $(APP_SERVICE) $$CMD

# --- Kubernetes commands ---------------------------------------------------

## Port forward application service
expose: ## Expose application service
	@$(call _req_cmd,kubectl)
	kubectl -n application-application port-forward service/application-application 8080:8080
	@printf "$(C_OK)Port forwarded to http://localhost:8080$(C_RESET)\n"

# --- Helm workflow ------------------------------------------------------------

## Initialize helm chart: update deps & lint (HELM_CHART_DIR=./charts/app)
init-helm:  ## Initialize Helm chart (deps + lint)
	@$(call _req_cmd,helm)
	@test -n "$(HELM_CHART_DIR)" || { \
		printf "$(C_ERR)HELM_CHART_DIR is not set. Usage: make init-helm HELM_CHART_DIR=./path/to/chart$(C_RESET)\n"; \
		exit 1; }
	@printf "$(C_INFO)Initializing Helm chart in %s...$(C_RESET)\n" "$(HELM_CHART_DIR)"
	helm dependency update "$(HELM_CHART_DIR)"
	helm lint "$(HELM_CHART_DIR)"
	@printf "$(C_OK)Helm chart initialized.$(C_RESET)\n"

# --- Secrets encryption (SOPS + age) -----------------------------------------

## Generate age keypair (writes $(AGE_KEY) and $(AGE_PUB))
init-encrypt:  ## Generate age keypair for SOPS
	@$(call _req_cmd,age-keygen)
	age-keygen > "$(AGE_KEY)"
	@printf "$(C_OK)Generated age key: %s$(C_RESET)\n" "$(AGE_KEY)"
	# Extract public key line to $(AGE_PUB)
	sed -n 's/^# public key:[[:space:]]*//p' "$(AGE_KEY)" > "$(AGE_PUB)"
	@printf "$(C_OK)Public key written to: %s$(C_RESET)\n" "$(AGE_PUB)"

## Encrypt secrets: $(SECRETS_DIR)/$(DECRYPT_FILE) -> $(SECRETS_DIR)/$(SOPS_FILE)
encrypt-secrets:  ## Encrypt secrets with SOPS (requires $(AGE_PUB))
	@$(call _req_cmd,sops)
	@$(call _req_file,$(AGE_PUB))
	@test -n "$(SECRETS_DIR)" || { \
		printf "$(C_ERR)SECRETS_DIR is not set. Usage: make encrypt-secrets SECRETS_DIR=./path/to/secrets$(C_RESET)\n"; \
		exit 1; }
	@$(call _req_file,$(SECRETS_DIR)/$(DECRYPT_FILE))
	PUB="$$(cat "$(AGE_PUB)")"
	sops --encrypt --age "$$PUB" \
		"$(SECRETS_DIR)/$(DECRYPT_FILE)" > "$(SECRETS_DIR)/$(SOPS_FILE)"
	@printf "$(C_OK)Encrypted: %s -> %s$(C_RESET)\n" \
		"$(SECRETS_DIR)/$(DECRYPT_FILE)" "$(SECRETS_DIR)/$(SOPS_FILE)"

## Decrypt secrets: $(SECRETS_DIR)/$(SOPS_FILE) -> $(SECRETS_DIR)/$(DECRYPT_FILE)
decrypt-secrets:  ## Decrypt secrets with SOPS (requires $(AGE_KEY))
	@$(call _req_cmd,sops)
	@$(call _req_file,$(AGE_KEY))
	@test -n "$(SECRETS_DIR)" || { \
		printf "$(C_ERR)SECRETS_DIR is not set. Usage: make decrypt-secrets SECRETS_DIR=./path/to/secrets$(C_RESET)\n"; \
		exit 1; }
	@$(call _req_file,$(SECRETS_DIR)/$(SOPS_FILE))
	printf "$(C_INFO)Decrypting secrets...$(C_RESET)\n"
	SOPS_AGE_KEY="$$(cat "$(AGE_KEY)")" \
		sops --decrypt "$(SECRETS_DIR)/$(SOPS_FILE)" > "$(SECRETS_DIR)/$(DECRYPT_FILE)"
	@printf "$(C_OK)Decrypted -> %s$(C_RESET)\n" "$(SECRETS_DIR)/$(DECRYPT_FILE)"

# --- Extras -------------------------------------------------------------------

## Quick health probe (customize to your app): URL=http://localhost:8080/health
wait-ready:  ## Poll a URL until HTTP 200 (URL=...)
	@$(call _req_cmd,curl)
	@test -n "$$URL" || { printf "$(C_ERR)Set URL=<probe url>$(C_RESET)\n"; exit 1; }
	@printf "$(C_INFO)Waiting for %s ...$(C_RESET)\n" "$$URL"
	for i in $$(seq 1 60); do \
		code=$$(curl -sk -o /dev/null -w '%{http_code}' "$$URL"); \
		if [ "$$code" = "200" ]; then printf "$(C_OK)Ready!$(C_RESET)\n"; exit 0; fi; \
		sleep 2; \
	done; \
	printf "$(C_ERR)Timeout waiting for %s$(C_RESET)\n" "$$URL"; exit 1


# --- Phony list ---------------------------------------------------------------

.PHONY: \
  help start stop logs enter run \
  create-user init-helm init-encrypt encrypt-secrets decrypt-secrets \
	wait-ready print-VAR expose


