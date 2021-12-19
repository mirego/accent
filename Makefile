# Configuration
# -------------
APP_VERSION ?= `grep -E '@version "([0-9\.]*)"' mix.exs | cut -d '"' -f2`
DOCKER_IMAGE_TAG ?= latest
GIT_REVISION ?= `git rev-parse HEAD`

# Introspection targets
# ---------------------

.PHONY: help
help: header targets

.PHONY: header
header:
	@echo "\033[34mEnvironment\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@printf "\033[33m%-23s\033[0m" "APP_VERSION"
	@printf "\033[35m%s\033[0m" $(APP_VERSION)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "GIT_REVISION"
	@printf "\033[35m%s\033[0m" $(GIT_REVISION)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "DOCKER_IMAGE_TAG"
	@printf "\033[35m%s\033[0m" $(DOCKER_IMAGE_TAG)
	@echo "\n"

.PHONY: targets
targets:
	@echo "\033[34mTargets\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# Build targets
# -------------

.PHONY: dependencies
dependencies: dependencies-mix dependencies-npm ## Install dependencies required by the application

.PHONY: dependencies-mix
dependencies-mix:
	mix deps.get --force

.PHONY: dependencies-npm
dependencies-npm: dependencies-npm-root dependencies-npm-webapp dependencies-npm-cli dependencies-npm-jipt

.PHONY: dependencies-npm-root
dependencies-npm-root:
	npm install

.PHONY: dependencies-npm-webapp
dependencies-npm-webapp:
	npm install --prefix webapp

.PHONY: dependencies-npm-cli
dependencies-npm-cli:
	npm install --prefix cli

.PHONY: dependencies-npm-jipt
dependencies-npm-jipt:
	npm install --prefix jipt

.PHONY: build
build: ## Build the Docker image for the OTP release
	docker build --rm --tag accent:$(DOCKER_IMAGE_TAG) .

.PHONY: compose-build
compose-build: ## Build the Docker image from the docker-compose.yml file
	docker-compose build

# CI targets
# ----------

.PHONY: lint
lint: lint-compile lint-format lint-credo lint-eslint lint-prettier lint-template-hbs ## Run lint tools on the code

.PHONY: lint-compile
lint-compile:
	mix compile --warnings-as-errors --force

.PHONY: lint-format
lint-format:
	mix format --dry-run --check-formatted

.PHONY: lint-credo
lint-credo:
	mix credo --strict

.PHONY: lint-eslint
lint-eslint:
	npx eslint --ext .js,.ts ./webapp/app ./cli ./jipt

.PHONY: lint-prettier
lint-prettier:
	npx prettier --check './{webapp,jipt,cli}/!(node_modules)/**/*.{js,ts,json,svg,scss,md}' '*.md'

.PHONY: lint-template-hbs
lint-template-hbs:
	npx ember-template-lint './webapp/app/**/*.hbs' --config-path './webapp/.template-lintrc'

.PHONY: type-check
type-check: ## Type-check typescript files
	cd webapp && npx tsc
	cd jipt && npx tsc

.PHONY: test
test: test-api test-webapp

.PHONY: test-api
test-api: ## Run the backend test suite
	mix test

.PHONY: test-webapp
test-webapp: ## Run the frontend test suite
	cd webapp && npx ember exam --reporter dot

.PHONY: test-coverage
test-coverage: ## Generate the code coverage report
	mix coveralls

.PHONY: format
format: format-elixir format-prettier ## Run formatting tools on the code

.PHONY: format-elixir
format-elixir:
	mix format

.PHONY: format-prettier
format-prettier:
	npx prettier --write --single-quote --no-bracket-spacing './{webapp,jipt,cli}/!(node_modules)/**/*.{js,ts,json,svg,scss,md}' '*.md'

# Development targets
# -------------------

.PHONY: dev-start-postgresql
dev-start-postgresql: ## Run a PostgreSQL server inside of a Docker Compose environment
	docker-compose up --detach postgresql

.PHONY: dev-start-application
dev-start-application: ## Run the OTP release inside of a Docker Compose environment
	docker-compose up application

.PHONY: dev-start
dev-start: ## Start every service of in the Docker Compose environment
	docker-compose up

.PHONY: dev-stop
dev-stop: ## Stop every service of in the Docker Compose environment
	docker-compose down
