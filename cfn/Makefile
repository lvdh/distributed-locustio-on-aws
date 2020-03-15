#!/usr/bin/env make

.PHONY: all verify install uninstall env validate launch delete status
.PHONY: list-outputs list-resources export-outputs clean help
.DEFAULT_GOAL := help

include ../Makefile.cfg

all: install uninstall ## Integration test

verify: env lint validate ## Validate CloudFormation Template(s)

install: env lint validate launch export-outputs status ## Deploy CloudFormation Stack(s)

uninstall: env delete clean ## Terminate CloudFormation Stack(s) and clean up local files

env: # Install local env in a local virtual environment
	$(info make cfn/$@ ...)
	pipenv sync

lint: ## Run linter on CloudFormation templates
	pipenv run cfn-lint --info **/templates/**/**/*.yaml

validate: # Validate CloudFormation Template(s)
	$(info make cfn/$@ ...)
	pipenv run sceptre validate $(SCEPTRE_STACK_NAME)

launch: # Deploy CloudFormation Stack(s)
	$(info make cfn/$@ ...)
	pipenv run sceptre launch --yes $(SCEPTRE_STACK_NAME)

delete: # Terminate CloudFormation Stack(s)
	$(info make cfn/$@ ...)
	pipenv run sceptre delete --yes $(SCEPTRE_STACK_NAME)

status: env ## Show deployment status of the CloudFormation Stack(s)
	$(info make cfn/$@ ...)
	pipenv run sceptre status $(SCEPTRE_STACK_NAME)

list-outputs: # List CloudFormation Outputs of the Stack(s)
	pipenv run sceptre list outputs $(SCEPTRE_STACK_NAME)

list-resources: # List CloudFormation Resources of the Stack(s)
	$(info make cfn/$@ ...)
	pipenv run sceptre list resources $(SCEPTRE_STACK_NAME)

export-outputs: # Generate export commands for CloudFormation Stack Outputs
	# This target is intentionally PHONY
	$(info make cfn/$@ ...)
	pipenv run sceptre --ignore-env list outputs $(SCEPTRE_STACK_NAME) --export=envvar > outputs.cfg

clean: # Delete virtual environment
	$(info make cfn/$@ ...)
	pipenv --rm || true

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)
