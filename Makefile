.PHONY: all configure test install update show uninstall help
.DEFAULT_GOAL := help

include Makefile.cfg

all: configure test install update status uninstall ## Run integration test

configure: ## Generate Sceptre's main configuration file
	# This target is intentionally PHONY
	$(call cyan, "make $@ ...")
	echo "region: $(AWS_REGION)" > ./cfn/config/config.yaml
	echo "profile: $(AWS_PROFILE)" >> ./cfn/config/config.yaml
	echo "project_code: $(PROJECT_CODE)" >> ./cfn/config/config.yaml

test: configure ## Verify the CloudFormation templates and Locust test suite
	@$(MAKE) -s -C ./cfn/ validate
	@$(MAKE) -s -C ./eb/ test

install: configure ## Create the CloudFormation templates and deploy the Locust test suite
	@$(MAKE) -s -C ./cfn/ install
	@$(MAKE) -s -C ./eb/ install

apply: configure ## Deploy modifications to the Locust test suite and/or CloudFormation templates
	@$(MAKE) -s -C ./cfn/ apply
	@$(MAKE) -s -C ./eb/ apply

status: configure ## Show status of the CloudFormation Stacks and Locust deployment
	@$(MAKE) -s -C ./cfn/ status
	@$(MAKE) -s -C ./eb/ status

uninstall: configure ## Delete the CloudFormation Stacks and clean up
	@$(MAKE) -s -C ./eb/ uninstall
	@$(MAKE) -s -C ./cfn/ uninstall

sort:
	@$(MAKE) -s -C ./eb/ sort
	@$(MAKE) -s -C ./cfn/ sort

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
