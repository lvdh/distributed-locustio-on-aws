# -- Load Configuration

# Make Sceptre deployment configuration avaliable in this Makefile (used by awsebcli)
VARS:=$(shell grep -E "profile|region|project_code" ./aws/config/config.yaml | sed -e 's/: /=/g')
$(foreach v,$(VARS),$(eval $(shell echo export $(v))))

# Make Sceptre's generated stack name available in this Makefile. It is based on:
#  * The project code
#  * The locust/stack/ path (in ./aws/config/)
CFN_STACK_NAME:=$(project_code)-locust-stack

# -- Getters

GET_EB_SOLUTION_STACK_NAME_CMD = $(shell aws --profile $(profile) --region $(region) \
		cloudformation list-exports \
		--query "Exports[?Name==\`$(CFN_STACK_NAME)-SolutionStackName\`].Value" \
		--output text)

# -- Targets

.PHONY: install
install: dependencies aws-init locust-smoketest locust-deploy ## Deploy Locust on AWS

.PHONY: uninstall
uninstall: dependencies aws-terminate ## Terminate all AWS resources related to this stack

.PHONY: update
update: dependencies aws-update locust-smoketest locust-deploy ## Deploy local changes (ie. load test suite and/or AWS resources)

.PHONY: reinstall
reinstall: dependencies uninstall install ## Redeploy all Locust AWS resources

.ONESHELL: dependencies
.PHONY: dependencies
dependencies: ## Install or upgrade local dependencies
	$(call cyan, "make $@ ...")
	python3 -m venv env
	. ./env/bin/activate
	pip install --upgrade pip
	pip install --upgrade -r requirements.txt --no-cache-dir

.ONESHELL: aws-init
.PHONY: aws-init
aws-init: ## Deploy AWS resources for Locust
	$(call cyan, "make $@ ... (Patience is a virtue. Have some tea or coffee.)")
	. ./env/bin/activate
	cd ./aws/
	sceptre create --yes locust/stack.yaml

.ONESHELL: aws-update
.PHONY: aws-update
aws-update: ## Update AWS resources for Locust
	$(call cyan, "make $@ ... (Patience is a virtue. Have some tea or coffee.)")
	. ./env/bin/activate
	cd ./aws/
	sceptre update --yes locust/stack.yaml

.ONESHELL: aws-terminate
.PHONY: aws-terminate
aws-terminate: ## Terminate all AWS resources related to this stack
	$(call cyan, "make $@ ...")
	. ./env/bin/activate
	cd ./aws/
	sceptre delete --yes locust/stack.yaml

.ONESHELL: locust-smoketest
.PHONY: locust-smoketest
locust-smoketest: ## Run a short load test to validate the local load test suite
	$(call cyan, "make $@ ...")
	. ./env/bin/activate
	locust --no-web --only-summary --locustfile=aws/app/locustfile.py \
			--clients=100 --hatch-rate=20 --run-time=10s

.ONESHELL: locust-deploy
.PHONY: locust-deploy
locust-deploy: ## (Re)deploy the Locust application
	$(call cyan, "make $@ ...")
	. ./env/bin/activate
	$(call cyan, "(!) Applying workaround; awsebcli still depends on PyYAML==3.13 (CVE-2017-18342)")
	pip install PyYAML==3.13
	cd ./aws/app/
	rm -rf ./.elasticbeanstalk/
	$(eval EB_SOLUTION_STACK_NAME=$(GET_EB_SOLUTION_STACK_NAME_CMD))
	# Configure the EB CLI to target the Elastic Beanstalk environment
	eb init --profile $(profile) --region $(region) --platform "$(EB_SOLUTION_STACK_NAME)" $(CFN_STACK_NAME)
	# Deploy Locust to the Elastic Beanstalk environment
	eb deploy --profile $(profile) --region $(region) --staged $(CFN_STACK_NAME)
	# Print out the status of the Elastic Beanstalk deployment
	eb status --profile $(profile) --region $(region) $(CFN_STACK_NAME)
	# Open a browser window for the Elastic Beanstalk environment's endpoint
	eb open --profile $(profile) --region $(region) $(CFN_STACK_NAME)

.ONESHELL: locust-open
.PHONY: locust-open
locust-open: ## Open the Locust web UI
	$(call cyan, "make $@ ...")
	. ./env/bin/activate
	$(call cyan, "(!) Applying workaround; awsebcli still depends on PyYAML==3.13 (CVE-2017-18342)")
	pip install PyYAML==3.13
	cd ./aws/app/
	rm -rf ./.elasticbeanstalk/
	pip install texttable==0.9.1 # Workaround for dependency mismatch between awsebcli and formica-cli
	$(eval EB_SOLUTION_STACK_NAME=$(GET_EB_SOLUTION_STACK_NAME_CMD))
	# Configure the EB CLI to target the Elastic Beanstalk environment
	eb init --profile $(profile) --region $(region) --platform "$(EB_SOLUTION_STACK_NAME)" $(CFN_STACK_NAME)
	# Open a browser window for the Elastic Beanstalk environment's endpoint
	eb open --profile $(profile) --region $(region) $(CFN_STACK_NAME)

# -- Help

.DEFAULT_GOAL := help

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# -- Functions

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
