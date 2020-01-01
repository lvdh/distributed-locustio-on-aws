.PHONY: install deploy status uninstall help
.DEFAULT_GOAL := help

install: ## Create the Locust environment and deploy a test suite for blazedemo.com
	@$(MAKE) -C ./ops/ install
	@$(MAKE) -C ./dev/ install

deploy: ## Deploy modifications to the Locust test suite and/or CloudFormation templates
	@$(MAKE) -C ./ops/ deploy
	@$(MAKE) -C ./dev/ deploy

status: ## Show status of the CloudFormation Stacks and Locust deployment
	@$(MAKE) -C ./ops/ status
	@$(MAKE) -C ./dev/ status

uninstall: ## Delete the CloudFormation Stacks and clean up
	@$(MAKE) -C ./dev/ uninstall
	@$(MAKE) -C ./ops/ uninstall

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
