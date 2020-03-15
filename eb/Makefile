#!/usr/bin/env make

.PHONY: verify install uninstall dependencies smoketest init deploy status open clean help
.DEFAULT_GOAL := help

include ../Makefile.cfg
include ../cfn/outputs.cfg

all: install uninstall ## Integration test

verify: dependencies smoketest ## Run a smoke test on the local Locust test suite

install: dependencies smoketest init deploy status open ## (Re)deploy the Locust test suite to Elastic Beanstalk

uninstall: clean ## Delete the local virtual environment and temporary files

dependencies: # Install local dependencies in a local virtual environment
	$(info make eb/$@ ...)
	pipenv install

smoketest: # Run a smoke test on the local Locust test suite
	$(info make eb/$@ ...)
	pipenv run locust --no-web --only-summary --locustfile=./locustfile.py \
		--clients=100 --hatch-rate=20 --run-time=10s

init: # (Re)initialize the EB CLI to target the Elastic Beanstalk environment
	$(info make eb/$@ ...)
	# (Re)initialize the EB CLI to target the Elastic Beanstalk environment
	rm -rf ./.elasticbeanstalk/
	pipenv run eb init --region $(AWS_REGION) --platform $(SCEPTRE_ElasticBeanstalkPlatform) \
		$(SCEPTRE_PROJECT_CODE)-$(SCEPTRE_STACK_NAME)-cluster

deploy: init # (Re)deploy the Locust application
	$(info make eb/$@ ...)
	pipenv run eb deploy --region $(AWS_REGION) --staged \
		$(SCEPTRE_PROJECT_CODE)-$(SCEPTRE_STACK_NAME)-cluster

status: init ## Show deployment status of the Locust application
	$(info make eb/$@ ...)
	pipenv run eb status --region $(AWS_REGION) \
		$(SCEPTRE_PROJECT_CODE)-$(SCEPTRE_STACK_NAME)-cluster

open: init # Open the Locust web GUI in a web browser
	$(info make eb/$@ ...)
	pipenv run eb open --region $(AWS_REGION) \
		$(SCEPTRE_PROJECT_CODE)-$(SCEPTRE_STACK_NAME)-cluster

clean: # Delete virtual environment and temporary files
	$(info make eb/$@ ...)
	pipenv --rm || true
	rm -vrf __pycache__/
	rm -vrf .elasticbeanstalk/

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)
