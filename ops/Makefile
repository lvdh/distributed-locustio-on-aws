.PHONY: install deploy uninstall deps cfn-validate cfn-launch cfn-update cfn-delete cfn-status
.PHONY: cfn-list-outputs cfn-list-resources clean help
.DEFAULT_GOAL := help

# Load cluster stack name
stack := $(shell find ./config/ -mindepth 1 -maxdepth 1 -type d -printf '%f' | tr -d '/')

install: deps cfn-launch ## Create the Locust environment and deploy a test suite for blazedemo.com

deploy: deps cfn-update ## Deploy modifications to the Locust test suite and/or CloudFormation templates

status: deps cfn-status ## Show deployment status of the CloudFormation Stack(s)

uninstall: deps cfn-delete clean ## Delete the Locust environment, local dependencies and temporary files

deps: # Install local dependencies in virtual environments (requires pipenv)
	$(call cyan, "make ops/$@ ...")
	pipenv --bare install

cfn-validate: # Validate CloudFormation Template(s)
	$(call cyan, "make ops/$@ ...")
	pipenv run sceptre validate $(stack)

cfn-launch: cfn-validate # Deploy CloudFormation Stack(s)
	$(call cyan, "make ops/$@ ...")
	pipenv run sceptre launch --yes $(stack)

cfn-update: cfn-validate # Update CloudFormation Stack(s)
	$(call cyan, "make ops/$@ ...")
	pipenv run sceptre update --yes $(stack)

cfn-delete: # Terminate CloudFormation Stack(s)
	$(call cyan, "make ops/$@ ...")
	pipenv run sceptre delete --yes $(stack)

cfn-status: # Show deployment status of the CloudFormation Stack(s)
	$(call cyan, "make ops/$@ ...")
	pipenv run sceptre status $(stack)

cfn-list-outputs: # List CloudFormation Outputs of the Stack(s)
	$(call cyan, "make ops/$@ ...")
	pipenv run sceptre list outputs $(stack)

cfn-list-resources: # List CloudFormation Resources of the Stack(s)
	$(call cyan, "make ops/$@ ...")
	pipenv run sceptre list resources $(stack)

clean: # Delete virtual environment
	$(call cyan, "make ops/$@ ...")
	pipenv --rm

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
