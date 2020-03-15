#!/usr/bin/env make

.PHONY: verify install uninstall env smoketest init deploy status open clean help
.DEFAULT_GOAL := help

include ../Makefile.cfg
include ../cfn/outputs.cfg

all: install uninstall ## Integration test

verify: env smoketest ## Run a smoke test on the local Locust test suite

install: env smoketest init deploy status open ## (Re)deploy the Locust test suite to Elastic Beanstalk

uninstall: clean ## Delete the local virtual environment and temporary files

env: # Install local env in a local virtual environment
	$(info INFO: make eb/$@ ...)
	pipenv sync

lint: ## Run linter on the Locustfile
	pipenv run flake8 --ignore=E501 locustfile.py

smoketest: # Run a smoke test on the local Locust test suite
	$(info INFO: make eb/$@ ...)
	pipenv run locust --no-web --only-summary --locustfile=./locustfile.py --clients=100 --hatch-rate=20 --run-time=10s

init: # (Re)initialize the EB CLI to target the Elastic Beanstalk environment
	$(info INFO: make eb/$@ ...)
	rm -rf ./.elasticbeanstalk/
	pipenv run eb init --region $(SCEPTRE_Region) --platform $(SCEPTRE_ElasticBeanstalkPlatform) $(SCEPTRE_EbApplicationName)

deploy: init # (Re)deploy the Locust application
	$(info INFO: make eb/$@ ...)
	pipenv run eb deploy --region $(SCEPTRE_Region) --staged $(SCEPTRE_EbEnvironmentName)

status: init ## Show deployment status of the Locust application
	$(info INFO: make eb/$@ ...)
	pipenv run eb status --region $(SCEPTRE_Region) $(SCEPTRE_EbEnvironmentName)

open: init # Open the Locust web GUI in a web browser
	$(info INFO: make eb/$@ ...)
	pipenv run eb open --region $(SCEPTRE_Region) $(SCEPTRE_EbEnvironmentName)

clean: # Delete virtual environment and temporary files
	$(info INFO: make eb/$@ ...)
	pipenv --rm || true
	rm -vrf __pycache__/
	rm -vrf .elasticbeanstalk/

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)
