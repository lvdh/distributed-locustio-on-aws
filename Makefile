.PHONY: install uninstall update reinstall deps validate launch update delete relaunch 
.PHONY: status list-outputs list-resources locust-smoketest locust-deploy locust-open help
.ONESHELL: locust-smoketest locust-deploy locust-open
.DEFAULT_GOAL := help

stack := locust # Based on Sceptre stack name (aws/config/locust)

# Load Sceptre deployment configuration (used by awsebcli)
VARS:=$(shell grep -E "profile|region|project_code" ./aws/config/config.yaml | sed -e 's/: /=/g')
$(foreach v,$(VARS),$(eval $(shell echo export $(v))))

# Cluster stack name as generated by Sceptre (used by awsebcli)
CFN_CLUSTER_STACK_NAME:=$(project_code)-$(stack)-cluster

install: deps launch locust-smoketest locust-deploy ## Deploy Locust on AWS

uninstall: deps delete ## Terminate all AWS resources related to this Locust environment

update: deps update locust-smoketest locust-deploy ## Deploy local changes (ie. load test suite and/or AWS resources)

reinstall: deps uninstall install ## Redeploy all Locust AWS resources

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

relaunch: delete launch # Terminate and redeploy CloudFormation Stack(s)

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
		--locustfile=./aws/app/locustfile.py \
		--clients=100 --hatch-rate=20 --run-time=10s

locust-deploy: # (Re)deploy the Locust application
	$(call cyan, "make $@ ...")
	@cd ./aws/app/
	@rm -rf ./.elasticbeanstalk/
	# Configure EB CLI to target the Elastic Beanstalk environment
	@pipenv run eb init --profile $(profile) --region $(region) \
		--platform "$(shell pipenv run yq r ./aws/config/locust/cluster.yaml parameters.SolutionStackName)" \
		$(CFN_CLUSTER_STACK_NAME)
	# Deploy Locust to the Elastic Beanstalk environment
	@pipenv run eb deploy --profile $(profile) --region $(region) --staged $(CFN_CLUSTER_STACK_NAME)
	# Show the status of the Elastic Beanstalk deployment
	@pipenv run eb status --profile $(profile) --region $(region) $(CFN_CLUSTER_STACK_NAME)
	# Open the Locust web GUI in a browser window
	@pipenv run eb open --profile $(profile) --region $(region) $(CFN_CLUSTER_STACK_NAME)

locust-open: # Open the Locust web UI
	$(call cyan, "make $@ ...")
	@cd ./aws/app/
	@rm -rf ./.elasticbeanstalk/
	# Configure EB CLI to target the Elastic Beanstalk environment
	@pipenv run eb init --profile $(profile) --region $(region) \
		--platform "$(shell pipenv run yq r ./aws/config/locust/cluster.yaml parameters.SolutionStackName)" \
		$(CFN_CLUSTER_STACK_NAME)
	# Open the Locust web GUI in a browser window
	@pipenv run eb open --profile $(profile) --region $(region) $(CFN_CLUSTER_STACK_NAME)

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
