#!/usr/bin/env make

.PHONY: all verify install uninstall dependencies validate launch delete status
.PHONY: list-outputs list-resources export-outputs clean help
.DEFAULT_GOAL := help
MAKEFLAGS=s

include ../Makefile.cfg

all: install uninstall ## Integration test

verify: dependencies validate ## Validate CloudFormation Template(s)

install: dependencies launch export-outputs status ## Deploy CloudFormation Stack(s)

uninstall: dependencies delete clean ## Terminate CloudFormation Stack(s) and clean up local files

dependencies: # Install local dependencies in a local virtual environment
	$(call cyan, "make cfn/$@ ...")
	pipenv install

validate: # Validate CloudFormation Template(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre validate $(SCEPTRE_STACK_NAME)

launch: validate # Deploy CloudFormation Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre launch --yes $(SCEPTRE_STACK_NAME)

delete: # Terminate CloudFormation Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre delete --yes $(SCEPTRE_STACK_NAME)

status: dependencies ## Show deployment status of the CloudFormation Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre status $(SCEPTRE_STACK_NAME)

list-outputs: # List CloudFormation Outputs of the Stack(s)
	pipenv run sceptre list outputs $(SCEPTRE_STACK_NAME)

list-resources: # List CloudFormation Resources of the Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre list resources $(SCEPTRE_STACK_NAME)

export-outputs: # Generate export commands for CloudFormation Stack Outputs
	# This target is intentionally PHONY
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre --ignore-dependencies list outputs $(SCEPTRE_STACK_NAME) --export=envvar > outputs.cfg

clean: # Delete virtual environment
	$(call cyan, "make cfn/$@ ...")
	pipenv --rm || true

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
