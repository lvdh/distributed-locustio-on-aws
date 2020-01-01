.PHONY: install deploy status uninstall help
.DEFAULT_GOAL := help

install: ## Create the Locust environment and deploy a test suite for blazedemo.com
	@$(MAKE) -s -C ./ops/ install
	@$(MAKE) -s -C ./dev/ install

deploy: ## Deploy modifications to the Locust test suite and/or CloudFormation templates
	@$(MAKE) -s -C ./ops/ deploy
	@$(MAKE) -s -C ./dev/ deploy

status: ## Show status of the CloudFormation Stacks and Locust deployment
	@$(MAKE) -s -C ./ops/ status
	@$(MAKE) -s -C ./dev/ status

uninstall: ## Delete the CloudFormation Stacks and clean up
	@$(MAKE) -s -C ./dev/ uninstall
	@$(MAKE) -s -C ./ops/ uninstall

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
