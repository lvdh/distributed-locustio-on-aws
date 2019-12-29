.PHONY: install deploy uninstall reinstall deps validate launch update delete relaunch status
.PHONY: list-outputs list-resources locust-smoketest locust-deploy locust-open help
.ONESHELL: locust-deploy locust-open
.DEFAULT_GOAL := help

# Load Sceptre deployment configuration (used by awsebcli)
VARS := $(shell grep -E "profile|region|project_code" ./aws/config/config.yaml | sed -e 's/: /=/g')
$(foreach v,$(VARS),$(eval $(shell echo export $(v))))

# Load Elastic Beanstalk "Solution Stack Name" (used by awsebcli)
EB_SOLUTION_STACK_NAME := $(shell sed -n -e 's/^.*SolutionStackName: //p' ./aws/config/locust/cluster.yaml)

# Cluster stack name as generated by Sceptre, based on aws/config/ contents (used by awsebcli)
stack := $(shell find ./aws/config/ -mindepth 1 -maxdepth 1 -type d -printf '%f' | tr -d '/')
CFN_CLUSTER_STACK_NAME := $(project_code)-$(stack)-cluster

install: deps launch locust-smoketest locust-deploy ## Create the Locust environment, deploy demo test suite

deploy: deps update locust-smoketest locust-deploy ## Deploy updated CloudFormation templates and Locust test suite

uninstall: deps delete ## Delete the Locust environment

reinstall: uninstall install ## Recreate the Locust environment from scratch

deps: # Install local dependencies (requires pipenv)
	$(call cyan, "make $@ ...")
	@pipenv install --deploy

validate: deps # Validate CloudFormation Template(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws validate $(stack)

launch: deps validate # Deploy CloudFormation Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws launch --yes $(stack)

update: deps validate # Update CloudFormation Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws update --yes $(stack)

delete: deps # Terminate CloudFormation Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws delete --yes $(stack)

status: deps # Show deployment status of the CloudFormation Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws status $(stack)

list-outputs: deps # List CloudFormation Outputs of the Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws list outputs $(stack)

list-resources: deps # List CloudFormation Resources of the Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws list resources $(stack)

locust-smoketest: # Smoke test the local Locust test suite
	$(call cyan, "make $@ ...")
	@pipenv run locust --no-web --only-summary \
		--locustfile=./aws/files/app/locustfile.py \
		--clients=100 --hatch-rate=20 --run-time=10s

locust-deploy: # (Re)deploy the Locust application
	$(call cyan, "make $@ ...")
	@cd ./aws/files/app/
	@rm -rf ./.elasticbeanstalk/
	# Configure EB CLI to target the Elastic Beanstalk environment
	@pipenv run eb init --profile $(profile) --region $(region) --platform $(EB_SOLUTION_STACK_NAME) $(CFN_CLUSTER_STACK_NAME)
	# Deploy Locust to the Elastic Beanstalk environment
	@pipenv run eb deploy --profile $(profile) --region $(region) --staged $(CFN_CLUSTER_STACK_NAME)
	# Show the status of the Elastic Beanstalk deployment
	@pipenv run eb status --profile $(profile) --region $(region) $(CFN_CLUSTER_STACK_NAME)
	# Open the Locust web GUI in a browser window
	@pipenv run eb open --profile $(profile) --region $(region) $(CFN_CLUSTER_STACK_NAME)

locust-open: # Open the Locust web UI
	$(call cyan, "make $@ ...")
	@cd ./aws/files/app/
	@rm -rf ./.elasticbeanstalk/
	# Configure EB CLI to target the Elastic Beanstalk environment
	@pipenv run eb init --profile $(profile) --region $(region) --platform $(EB_SOLUTION_STACK_NAME) $(CFN_CLUSTER_STACK_NAME)
	# Open the Locust web GUI in a browser window
	@pipenv run eb open --profile $(profile) --region $(region) $(CFN_CLUSTER_STACK_NAME)

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
