.PHONY: install apply uninstall dependencies validate launch update delete status
.PHONY: list-outputs list-resources clean help
.DEFAULT_GOAL := help

# Load cluster stack name
stack := $(shell find ./config/ -mindepth 1 -maxdepth 1 -type d -printf '%f' | tr -d '/')

install: dependencies launch ## Create the Locust environment and deploy a test suite for blazedemo.com

apply: dependencies update ## Deploy modifications to the Locust test suite and/or CloudFormation templates

uninstall: dependencies delete clean ## Delete the Locust environment, local dependencies and temporary files

dependencies: # Install local dependencies in virtual environments (requires pipenv)
	$(call cyan, "make cfn/$@ ...")
	pipenv --bare install

validate: # Validate CloudFormation Template(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre validate $(stack)

launch: validate # Deploy CloudFormation Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre launch --yes $(stack)

update: validate # Update CloudFormation Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre update --yes $(stack)

delete: # Terminate CloudFormation Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre delete --yes $(stack)

status: ## Show deployment status of the CloudFormation Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre status $(stack)

list-outputs: # List CloudFormation Outputs of the Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre list outputs $(stack)

list-resources: # List CloudFormation Resources of the Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre list resources $(stack)

clean: # Delete virtual environment
	$(call cyan, "make cfn/$@ ...")
	pipenv --rm

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
