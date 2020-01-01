.PHONY: install deploy status uninstall help
.DEFAULT_GOAL := help

smoketest: ## Verify the local Locust test suite
	@$(MAKE) -s -C ./eb/ smoketest

install: ## Create the Locust environment and deploy a test suite for blazedemo.com
	@$(MAKE) -s -C ./cfn/ install
	@$(MAKE) -s -C ./eb/ install

apply: ## Deploy modifications to the Locust test suite and/or CloudFormation templates
	@$(MAKE) -s -C ./cfn/ apply
	@$(MAKE) -s -C ./eb/ apply

status: ## Show status of the CloudFormation Stacks and Locust deployment
	@$(MAKE) -s -C ./cfn/ status
	@$(MAKE) -s -C ./eb/ status

uninstall: ## Delete the CloudFormation Stacks and clean up
	@$(MAKE) -s -C ./eb/ uninstall
	@$(MAKE) -s -C ./cfn/ uninstall

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
