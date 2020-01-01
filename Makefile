.PHONY: install deploy uninstall help
.DEFAULT_GOAL := help

install: ## Create the Locust environment and deploy a test suite for blazedemo.com
	@$(MAKE) -C ./aws/ install
	@$(MAKE) -C ./app/ install

deploy: ## Deploy modifications to the Locust test suite and/or CloudFormation templates
	@$(MAKE) -C ./aws/ deploy
	@$(MAKE) -C ./app/ deploy

status: ## Show status of the CloudFormation Stacks and Locust deployment
	@$(MAKE) -C ./aws/ status
	@$(MAKE) -C ./app/ status

uninstall: ## Delete the Locust environment and clean up
	@$(MAKE) -C ./aws/ uninstall
	@$(MAKE) -C ./app/ uninstall

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
