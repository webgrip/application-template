# =============================================================================
# Application Makefile
# -----------------------------------------------------------------------------
# Usage: make <target>
# Run `make help` to see all available targets.
# =============================================================================
# Core make settings
SHELL := /usr/bin/bash
.ONESHELL:
.DEFAULT_GOAL := help
#   make expose NAMESPACE=invoiceninja-application SERVICE_NAME=invoiceninja-application REMOTE_PORT=80
APP_NAME      ?= invoiceninja-application
NAMESPACE     ?= $(APP_NAME)
SERVICE_NAME  ?= $(APP_NAME)
APP_SERVICE   ?= $(APP_NAME).application
ENV_FILE      ?= .env
COMPOSE       ?= docker compose
HELMFILE      ?= helmfile
HELMFILE_FILE ?= helmfile.yaml
HELMFILE_ENV  ?=

# Secrets management
AGE_KEY       ?= age.agekey
AGE_PUB       ?= age.pubkey
DECRYPT_FILE  ?= values.dec.yaml
SOPS_FILE     ?= values.sops.yaml

# Helm configuration
HELM_CHART_DIR ?= ops/helm/$(APP_NAME)
RELEASE       ?= $(APP_NAME)
HELM_VALUES   ?=

# Kubernetes port forwarding
LOCAL_PORT    ?= 8080
REMOTE_PORT   ?= 80

# Colors for nicer output
C_RESET := \033[0m
C_OK    := \033[32m
C_WARN  := \033[33m
C_ERR   := \033[31m
C_INFO  := \033[36m
# Extra styling
C_BOLD  := \033[1m
C_DIM   := \033[2m
C_UL    := \033[4m
C_MAG   := \033[35m
C_BLUE  := \033[34m
C_GRN   := \033[32m
C_YEL   := \033[33m
C_RED   := \033[31m

# Project version (auto from package.json if present). Avoid single-quote parsing pitfalls.
VERSION ?= $(shell awk -F '"' '/"version"[[:space:]]*:/ {print $$4; exit}' package.json 2>/dev/null)
ifeq ($(strip $(VERSION)),)
VERSION := 0.0.0-dev
endif

# Show group pseudo-targets in main help (0=hide, 1=show dimmed)
HELP_SHOW_GROUPS ?= 0

# --- Embedded scripts (self-contained Makefile) --------------------------------

# Dynamic help AWK program (embedded). Escaped $$ for AWK variables.
define HELP_SCRIPT
BEGIN {
	print "\n" C_BOLD C_INFO "Application Template" C_RESET "  " C_DIM "v" VERSION C_RESET;
	pending_desc="";
	if (INCATS!="") {
		n=split(INCATS,cc,/,/);
		for(i=1;i<=n;i++){gsub(/^[[:space:]]+|[[:space:]]+$$/,"",cc[i]); if(cc[i]!="") allowed[cc[i]]=1}
		if (n>0) filterCats=1;
	}
}
/^##[ ]/ { pending_desc=$$0; sub(/^##[ ]*/,"",pending_desc); next }
/^[^#\t].*:/ {
	line=$$0; nameEnd=0; prev="";
	for(i=1;i<=length(line);i++){ c=substr(line,i,1); if(c==":" && prev!="\\"){ nameEnd=i-1; break } prev=c }
	if(!nameEnd) next;
	names=substr(line,1,nameEnd);
	nextChar=substr(line,nameEnd+2,1); if(nextChar=="=") next;
	n=split(names,arr,/ +/);
	for(j=1;j<=n;j++){
		raw=arr[j]; if(raw==""|| raw ~ /[^A-Za-z0-9_.\\:-]/) continue;
		disp=raw; gsub(/\\:/,":",disp);
		if (is_ignored(disp)) continue;
		if (index(line,"##")>0){ desc=line; sub(/^.*##/,"",desc) } else if(pending_desc!="") { desc=pending_desc } else desc="";
		if(!(disp in added_targets)){ record(disp,desc); added_targets[disp]=1 }
	}
	pending_desc=""; next;
}
function record(tgt,desc,cat,color,icon,fmt_target){
	cat=category(tgt); if(!(cat in seen_cat)){ order[++oc]=cat; seen_cat[cat]=1 }
	group_line=is_group(tgt); if(group_line && SHOW_GROUPS==0) return;
	if(cat=="Secrets") color=C_MAG; else if(cat=="App Keys") color=C_GRN; else if(cat=="Users") color=C_YEL; else if(cat=="Kubernetes") color=C_INFO; else if(cat=="ACT / Workflows") color=C_BLUE; else if(cat=="Helm") color=C_BLUE; else if(cat=="Helmfile") color=C_BLUE; else if(cat=="Scanning") color=C_ERR; else color=C_BLUE;
	if(group_line) color=C_DIM;
	icon=cat_icon(cat); fmt_target=sprintf("%s %s",icon,tgt);
	lines[cat]=lines[cat] sprintf("  %s%-30s%s %s%s%s\n",color,fmt_target,C_RESET,(desc!=""?C_DIM:""),desc,(desc!=""?C_RESET:""));
}
function is_ignored(t){ if(t ~ /^\./) return 1; if(t ~ /^[A-Z0-9_]+$$/) return 1; if(t=="SHELL") return 1; if(t=="sed"||t=="-n") return 1; if(t=="awk"||t=="-F"||t=="function"||t=="return"||t=="in"||t=="printf") return 1; return 0 }
function is_group(t){ return (t=="help"||t=="completion"||t=="helm"||t=="app"||t=="app:key"||t=="k8s"||t=="scan"||t=="helmfile"||t=="secrets") }
function category(t){
	if(t=="start"||t=="stop"||t=="logs"||t=="run"||t=="enter"||t=="wait-ready"||t=="print-VAR"||t=="init-helm") return "Core & Utility";
	if(substr(t,1,5)=="helm:") return "Helm"; if(substr(t,1,9)=="helmfile:") return "Helmfile"; if(substr(t,1,5)=="scan:") return "Scanning";
	if(t=="secrets"||substr(t,1,8)=="secrets:") return "Secrets"; if(substr(t,1,8)=="app:key:") return "App Keys"; if(t=="user:create") return "Users";
	if(substr(t,1,4)=="k8s:"){ if(t=="k8s:expose"||t=="k8s:resource-capacity") return "Kubernetes" }
	return "Misc" }
function cat_icon(c){ if(c=="Core & Utility") return "⚒️"; if(c=="Helm") return "⛵"; if(c=="Helmfile") return "📜"; if(c=="Secrets") return "🔐"; if(c=="App Keys") return "🔑"; if(c=="Kubernetes") return "☸️"; if(c=="Scanning") return "🔍"; if(c=="Users") return "👤"; if(c=="Misc") return "📦"; return "•" }
END { for(i=1;i<=oc;i++){ c=order[i]; if(filterCats && !(c in allowed)) continue; printf "\n%s== %s %s ==%s\n",C_DIM,cat_icon(c),c,C_RESET; printf "%s",lines[c] } printf "\n" C_BOLD "Tip:" C_RESET " Prefix groups: secrets:  app:key:  k8s:  user:  (tab completion)\n" }
endef
export HELP_SCRIPT

# AWK argument bundle for help (kept separate to avoid long wrapped recipe lines)
AWK_ARGS = -v VERSION="$(VERSION)" -v INCATS="$(HELP_CATEGORIES)" -v SHOW_GROUPS="$(HELP_SHOW_GROUPS)" \
	-v C_RESET="$(C_RESET)" -v C_BOLD="$(C_BOLD)" -v C_DIM="$(C_DIM)" -v C_BLUE="$(C_BLUE)" -v C_MAG="$(C_MAG)" \
	-v C_GRN="$(C_GRN)" -v C_YEL="$(C_YEL)" -v C_INFO="$(C_INFO)" -v C_ERR="$(C_ERR)" -v C_OK="$(C_OK)"

# --- Helpers -----------------------------------------------------------------

define _req_cmd
	@if ! command -v $(1) >/dev/null 2>&1; then \
		printf "$(C_ERR)Missing dependency: $(1)$(C_RESET)\n"; \
		exit 1; \
	fi
endef

define _req_file
	@if [ ! -f $(1) ]; then \
		printf "$(C_ERR)Missing file: $(1)$(C_RESET)\n"; \
		exit 1; \
	fi
endef

help: ## Show this help
	@printf '%s\n' "$$HELP_SCRIPT" | awk $(AWK_ARGS) -f - $(MAKEFILE_LIST)

## Generate shell completion script (bash/zsh) for project make targets
completion: ## Generate shell completion script (bash/zsh) for project make targets
	@{ \
	  echo '# ---- Generated make target completion (application-template) ----'; \
	  echo '# Source this file or use: source <(make completion)'; \
	  echo; \
	  echo '_make_project_targets() {'; \
	  echo '  local _orig_wb="$$COMP_WORDBREAKS"'; \
	  echo '  COMP_WORDBREAKS="$${COMP_WORDBREAKS//:/}"'; \
	  echo '  local cur'; \
	  echo '  COMPREPLY=()'; \
	  echo '  cur="$${COMP_WORDS[COMP_CWORD]}"'; \
	  echo '  local opts="'"$$(awk '/^[^#\t].*:/ { line=$$0; nameEnd=0; prev=""; for(i=1;i<=length(line);i++){ c=substr(line,i,1); if(c==":" && prev!="\\"){ nameEnd=i-1; break } prev=c } if(!nameEnd) next; names=substr(line,1,nameEnd); if(substr(line,nameEnd+2,1)=="=") next; n=split(names,arr,/ +/); for(j=1;j<=n;j++){ raw=arr[j]; if(raw==""|| raw ~ /[^A-Za-z0-9_.\\:-]/) continue; disp=raw; gsub(/\\:/,":",disp); if(disp ~ /^\./) continue; if(disp ~ /^[A-Z0-9_]+$$/) continue; if(disp=="awk"||disp=="-F"||disp=="function"||disp=="return"||disp=="in"||disp=="printf") continue; print disp }}' $(MAKEFILE_LIST) | sort -u | tr '\n' ' ')"'"'; \
	  echo '  COMPREPLY=( $$(compgen -W "$$opts" -- "$$cur") )'; \
	  echo '  COMP_WORDBREAKS="$$_orig_wb"'; \
	  echo '  return 0'; \
	  echo '}'; \
	  echo; \
	  echo 'if [ -n "$$BASH_VERSION" ]; then'; \
	  echo '  complete -F _make_project_targets make 2>/dev/null || true'; \
	  echo 'fi'; \
	  echo 'if [ -n "$$ZSH_VERSION" ]; then'; \
	  echo '  autoload -U +X bashcompinit 2>/dev/null || true'; \
	  echo '  bashcompinit 2>/dev/null || true'; \
	  echo '  complete -F _make_project_targets make 2>/dev/null || true'; \
	  echo 'fi'; \
	  echo '# ---- End completion script ----'; \
	}

# --- Namespaced command groups (canonical targets) ---------------------------

secrets: ## Show secrets command group help
	@$(MAKE) --no-print-directory help HELP_CATEGORIES="Secrets" HELP_SHOW_GROUPS=1

helm: ## Show helm & helmfile command group help
	@$(MAKE) --no-print-directory help HELP_CATEGORIES="Helm,Helmfile" HELP_SHOW_GROUPS=1

app: ## Show application (app:key) command group help
	@$(MAKE) --no-print-directory help HELP_CATEGORIES="App Keys" HELP_SHOW_GROUPS=1

app\:key: ## Show app:key command group help
	@$(MAKE) --no-print-directory help HELP_CATEGORIES="App Keys" HELP_SHOW_GROUPS=1

k8s: ## Show Kubernetes command group help
	@$(MAKE) --no-print-directory help HELP_CATEGORIES="Kubernetes" HELP_SHOW_GROUPS=1

scan: ## Show scanning (static analysis) command group help
	@$(MAKE) --no-print-directory help HELP_CATEGORIES="Scanning" HELP_SHOW_GROUPS=1

helmfile: ## Show helmfile command group help
	@$(MAKE) --no-print-directory help HELP_CATEGORIES="Helmfile" HELP_SHOW_GROUPS=1

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

## Port forward service (override NAMESPACE, SERVICE_NAME, LOCAL_PORT, REMOTE_PORT)
k8s\:expose: ## Expose k8s service (LOCAL_PORT:REMOTE_PORT) for $(SERVICE_NAME) in $(NAMESPACE)
	@$(call _req_cmd,kubectl)
	@printf "$(C_INFO)Port-forwarding %s/%s %s -> %s ...$(C_RESET)\n" "$(NAMESPACE)" "$(SERVICE_NAME)" "$(LOCAL_PORT)" "$(REMOTE_PORT)"
	kubectl -n $(NAMESPACE) port-forward service/$(SERVICE_NAME) $(LOCAL_PORT):$(REMOTE_PORT)
	@printf "$(C_OK)Port forwarded: http://localhost:%s -> %s/%s:%s$(C_RESET)\n" "$(LOCAL_PORT)" "$(NAMESPACE)" "$(SERVICE_NAME)" "$(REMOTE_PORT)"

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

## Render templates locally (HELM_CHART_DIR=./charts/app HELM_VALUES=values.yaml)
helm\:template: ## Helm: render templates (dry render)
	@$(call _req_cmd,helm)
	@test -n "$(HELM_CHART_DIR)" || { printf "$(C_ERR)Set HELM_CHART_DIR=...$(C_RESET)\n"; exit 1; }
	VALUES_ARG=""; [ -n "$(HELM_VALUES)" ] && VALUES_ARG="-f $(HELM_VALUES)"; \
	helm template $(RELEASE) "$(HELM_CHART_DIR)" -n $(NAMESPACE) $$VALUES_ARG | sed -e '1,20s/^/./'

## Diff upgrade (requires helm diff plugin) (HELM_VALUES=values.yaml)
helm\:diff: ## Helm: diff prospective upgrade
	@$(call _req_cmd,helm)
	@if ! helm plugin list 2>/dev/null | grep -q '^diff'; then printf "$(C_WARN)helm diff plugin not installed. Install with: helm plugin install https://github.com/databus23/helm-diff$(C_RESET)\n"; exit 0; fi
	VALUES_ARG=""; [ -n "$(HELM_VALUES)" ] && VALUES_ARG="-f $(HELM_VALUES)"; \
	helm diff upgrade --allow-unreleased $(RELEASE) "$(HELM_CHART_DIR)" -n $(NAMESPACE) $$VALUES_ARG || true

## Package chart into ./dist (HELM_CHART_DIR=./charts/app)
helm\:package: ## Helm: package chart to dist/
	@$(call _req_cmd,helm)
	@test -n "$(HELM_CHART_DIR)" || { printf "$(C_ERR)Set HELM_CHART_DIR=...$(C_RESET)\n"; exit 1; }
	mkdir -p dist
	helm package "$(HELM_CHART_DIR)" -d dist

# --- Helmfile (read-only / diff) --------------------------------------------

## Helmfile: list releases (HELMFILE_FILE=helmfile.yaml HELMFILE_ENV=)
helmfile\:list: ## Helmfile: list releases
	@$(call _req_cmd,$(HELMFILE))
	@if [ -f "$(HELMFILE_FILE)" ]; then \
	  $(HELMFILE) -f $(HELMFILE_FILE) $(if $(HELMFILE_ENV),-e $(HELMFILE_ENV),) list; \
	else \
	  printf "$(C_WARN)Warning: $(HELMFILE_FILE) not found. Listing without explicit file.$(C_RESET)\n"; \
	  $(HELMFILE) list || true; \
	fi

## Helmfile: lint all charts
helmfile\:lint: ## Helmfile: lint releases
	@$(call _req_cmd,$(HELMFILE))
	@if [ -f "$(HELMFILE_FILE)" ]; then \
	  $(HELMFILE) -f $(HELMFILE_FILE) $(if $(HELMFILE_ENV),-e $(HELMFILE_ENV),) lint; \
	else \
	  printf "$(C_WARN)Warning: $(HELMFILE_FILE) not found. Nothing to lint.$(C_RESET)\n"; \
	fi

## Helmfile: diff pending changes (requires helm-diff plugin)
helmfile\:diff: ## Helmfile: diff changes (requires diff plugin)
	@$(call _req_cmd,$(HELMFILE))
	@if ! helm plugin list 2>/dev/null | grep -q '^diff'; then printf "$(C_WARN)helm diff plugin not installed$(C_RESET)\n"; exit 0; fi
	@if [ -f "$(HELMFILE_FILE)" ]; then \
	  $(HELMFILE) -f $(HELMFILE_FILE) $(if $(HELMFILE_ENV),-e $(HELMFILE_ENV),) diff || true; \
	else \
	  printf "$(C_WARN)Warning: $(HELMFILE_FILE) not found. Nothing to diff.$(C_RESET)\n"; \
	fi

## Helmfile: render combined manifest (no apply)
helmfile\:template: ## Helmfile: render manifests
	@$(call _req_cmd,$(HELMFILE))
	@if [ -f "$(HELMFILE_FILE)" ]; then \
	  $(HELMFILE) -f $(HELMFILE_FILE) $(if $(HELMFILE_ENV),-e $(HELMFILE_ENV),) template > /dev/stdout; \
	else \
	  printf "$(C_WARN)Warning: $(HELMFILE_FILE) not found. Cannot template.$(C_RESET)\n"; \
	fi

# --- Manifest static analysis ------------------------------------------------

## Scan (helm template -> kube-score) (HELM_CHART_DIR required)
scan\:kube-score: ## Scan: kube-score static analysis
	@$(call _req_cmd,helm)
	@$(call _req_cmd,kube-score)
	@test -n "$(HELM_CHART_DIR)" || { printf "$(C_ERR)Set HELM_CHART_DIR=...$(C_RESET)\n"; exit 1; }
	VALUES_ARG=""; [ -n "$(HELM_VALUES)" ] && VALUES_ARG="-f $(HELM_VALUES)"; \
	helm template $(RELEASE) "$(HELM_CHART_DIR)" -n $(NAMESPACE) $$VALUES_ARG | kube-score score -

## Scan (helm template -> kube-linter)
scan\:kube-linter: ## Scan: kube-linter policy checks
	@$(call _req_cmd,helm)
	@$(call _req_cmd,kube-linter)
	@test -n "$(HELM_CHART_DIR)" || { printf "$(C_ERR)Set HELM_CHART_DIR=...$(C_RESET)\n"; exit 1; }
	TMP=$$(mktemp -d); VALUES_ARG=""; [ -n "$(HELM_VALUES)" ] && VALUES_ARG="-f $(HELM_VALUES)"; \
	helm template $(RELEASE) "$(HELM_CHART_DIR)" -n $(NAMESPACE) $$VALUES_ARG > $$TMP/rendered.yaml; \
	kube-linter lint $$TMP || STATUS=$$?; rm -rf $$TMP; exit $${STATUS:-0}

## Scan (helm template -> kubesec)
scan\:kubesec: ## Scan: kubesec security score
	@$(call _req_cmd,helm)
	@$(call _req_cmd,kubesec)
	@test -n "$(HELM_CHART_DIR)" || { printf "$(C_ERR)Set HELM_CHART_DIR=...$(C_RESET)\n"; exit 1; }
	TMP=$$(mktemp -d); VALUES_ARG=""; [ -n "$(HELM_VALUES)" ] && VALUES_ARG="-f $(HELM_VALUES)"; \
	helm template $(RELEASE) "$(HELM_CHART_DIR)" -n $(NAMESPACE) $$VALUES_ARG > $$TMP/rendered.yaml; \
	kubesec scan $$TMP/rendered.yaml || STATUS=$$?; rm -rf $$TMP; exit $${STATUS:-0}

## Aggregate scan (kube-score + kube-linter + kubesec) fail on first non-zero
scan\:all: ## Scan: run all static analyzers
	@$(MAKE) scan:kube-score
	@$(MAKE) scan:kube-linter
	@$(MAKE) scan:kubesec

# --- Cluster capacity --------------------------------------------------------

## Show namespace resource capacity (kubectl resource-capacity plugin)
k8s\:resource-capacity: ## K8s: resource capacity & utilization
	@$(call _req_cmd,kubectl)
	@if ! kubectl resource-capacity --help >/dev/null 2>&1; then printf "$(C_WARN)kubectl resource-capacity plugin missing (install via krew)$(C_RESET)\n"; exit 1; fi
	kubectl resource-capacity -n $(NAMESPACE) --sort cpu.request --util --pods || true

# --- Secrets encryption (SOPS + age) -----------------------------------------

## Generate age keypair (writes $(AGE_KEY) and $(AGE_PUB))
secrets\:init:  ## Generate age keypair for SOPS
	@$(call _req_cmd,age-keygen)
	age-keygen > "$(AGE_KEY)"
	@printf "$(C_OK)Generated age key: %s$(C_RESET)\n" "$(AGE_KEY)"
	# Extract public key line to $(AGE_PUB)
	sed -n 's/^# public key:[[:space:]]*//p' "$(AGE_KEY)" > "$(AGE_PUB)"
	@printf "$(C_OK)Public key written to: %s$(C_RESET)\n" "$(AGE_PUB)"

## Encrypt secrets: $(SECRETS_DIR)/$(DECRYPT_FILE) -> $(SECRETS_DIR)/$(SOPS_FILE)
secrets\:encrypt:  ## Encrypt secrets with SOPS (requires $(AGE_PUB))
	@$(call _req_cmd,sops)
	@$(call _req_file,$(AGE_PUB))
	@test -n "$(SECRETS_DIR)" || { \
		printf "$(C_ERR)SECRETS_DIR is not set. Usage: make secrets:encrypt SECRETS_DIR=./path/to/secrets$(C_RESET)\n"; \
		exit 1; }
	@$(call _req_file,$(SECRETS_DIR)/$(DECRYPT_FILE))
	PUB="$$(cat "$(AGE_PUB)")"
	sops --encrypt --age "$$PUB" \
		"$(SECRETS_DIR)/$(DECRYPT_FILE)" > "$(SECRETS_DIR)/$(SOPS_FILE)"
	@printf "$(C_OK)Encrypted: %s -> %s$(C_RESET)\n" \
		"$(SECRETS_DIR)/$(DECRYPT_FILE)" "$(SECRETS_DIR)/$(SOPS_FILE)"

## Decrypt secrets: $(SECRETS_DIR)/$(SOPS_FILE) -> $(SECRETS_DIR)/$(DECRYPT_FILE)
secrets\:decrypt:  ## Decrypt secrets with SOPS (requires $(AGE_KEY))
	@$(call _req_cmd,sops)
	@$(call _req_file,$(AGE_KEY))
	@test -n "$(SECRETS_DIR)" || { \
		printf "$(C_ERR)SECRETS_DIR is not set. Usage: make secrets:decrypt SECRETS_DIR=./path/to/secrets$(C_RESET)\n"; \
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
		sleep 1; \
	done; \
	printf "$(C_ERR)Timeout waiting for %s$(C_RESET)\n" "$$URL"; exit 1

# --- App bootstrap -----------------------------------------------------------

## Create an admin user (EMAIL, PASS envs optional; customize command for your app)
user\:create: ## Create user (override EMAIL=user@example.com PASS=pass)
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	: $${EMAIL:=admin@example.com}; \
	: $${PASS:=password}; \
	printf "$(C_INFO)Creating user %s...$(C_RESET)\n" "$$EMAIL"; \
	$(COMPOSE) exec $(APP_SERVICE) php artisan ninja:create-account --email="$$EMAIL" --password="$$PASS"; \
	printf "$(C_OK)User creation complete.$(C_RESET)\n"

# --- Phony list ---------------------------------------------------------------

