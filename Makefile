#!/usr/bin/env make -s

include config.mk

all: config verify install install status uninstall ## Deploy, 'update' and destroy (integration test)

config: # Generate Sceptre's main configuration file
	# This target is intentionally PHONY
	$(info INFO: make $@ ...)
	echo "region: $(AWS_REGION)" > ./cfn/config/config.yaml
	echo "profile: $(AWS_PROFILE)" >> ./cfn/config/config.yaml
	echo "project_code: $(SCEPTRE_PROJECT_CODE)" >> ./cfn/config/config.yaml

verify: config ## Verify the CloudFormation templates and Locust test suite
	$(MAKE) -C ./cfn/ verify
	$(MAKE) -C ./eb/ verify

install: config ## Deploy/update the CloudFormation templates and Locust test suite
	$(MAKE) -C ./cfn/ install
	$(MAKE) -C ./eb/ install

uninstall: config ## Delete the CloudFormation Stacks and clean up
	$(MAKE) -C ./eb/ uninstall
	$(MAKE) -C ./cfn/ uninstall

status: config ## Show status of the CloudFormation Stacks and Locust deployment
	$(MAKE) -C ./cfn/ status
	$(MAKE) -C ./eb/ status

clean: config ## Delete virtual environments and temporary files
	$(MAKE) -C ./eb/ clean
	$(MAKE) -C ./cfn/ clean

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
.PHONY: all config verify install uninstall status clean help
