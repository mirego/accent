# Configuration
# -------------

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
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
	@printf "\033[33m%-23s\033[0m" "APP_NAME"
	@printf "\033[35m%s\033[0m" $(APP_NAME)
	@echo ""
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
	docker build --build-arg APP_NAME=$(APP_NAME) --build-arg APP_VERSION=$(APP_VERSION) --rm --tag $(APP_NAME):$(DOCKER_IMAGE_TAG) .

# CI targets
# ----------

.PHONY: lint
lint: lint-compile lint-format lint-credo lint-eslint lint-prettier lint-tslint ## Run lint tools on the code

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
	./node_modules/.bin/eslint webapp/. cli/. jipt/.

.PHONY: lint-tslint
lint-tslint:
	./node_modules/.bin/tslint -c tslint.json '{cli,jipt}/src/**/*.{js,ts,json}'

.PHONY: lint-prettier
lint-prettier:
	./node_modules/.bin/prettier --check --single-quote --no-bracket-spacing '{webapp,jipt,cli}/*.{js,json}' 'webapp/{app,config}/**/*.{js,ts,json,gql}' 'jipt/src/**/*.{js,ts,json,gql}' 'cli/{examples,src}/**/*.{js,ts,json,gql}'

.PHONY: test
test: ## Run the test suite
	mix test

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
	./node_modules/.bin/prettier --write --single-quote --no-bracket-spacing '{webapp,jipt,cli}/*.{js,json}' 'webapp/{app,config}/**/*.{js,ts,json,gql}' 'jipt/src/**/*.{js,ts,json,gql}' 'cli/{examples,src}/**/*.{js,ts,json,gql}'

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
