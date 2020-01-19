.PHONY: test install apply show uninstall dependencies smoketest init deploy status open clean help
.DEFAULT_GOAL := help

export PROJECT_CODE
export STACK_NAME

$(eval VARS := $(shell $(MAKE) -s -C ../cfn/ export-outputs))
$(foreach v,$(VARS),$(eval $(shell echo export $(v))))

sort:
	env | sort

test: dependencies smoketest ## Run a smoke test on the local Locust test suite

install: dependencies smoketest init deploy status open ## Initialize Elastic Beanstalk and deploy the Locust test suite

apply: dependencies deploy status open ## Deploy an updated Locust test suite to Elastic Beanstalk

uninstall: clean ## Delete the local virtual environment and temporary files

dependencies: # Install local dependencies in a local virtual environment
	$(call cyan, "make eb/$@ ...")
	pipenv --bare install

smoketest: # Run a smoke test on the local Locust test suite
	$(call cyan, "make eb/$@ ...")
	pipenv run locust --no-web --only-summary --locustfile=./locustfile.py \
		--clients=100 --hatch-rate=20 --run-time=10s

init: # (Re)initialize the EB CLI to target the Elastic Beanstalk environment
	$(call cyan, "make eb/$@ ...")
	# (Re)initialize the EB CLI to target the Elastic Beanstalk environment
	rm -vrf ./.elasticbeanstalk/
	env | grep SCEPTRE
	# cd ../cfn/ && pipenv run sceptre --ignore-dependencies list outputs locust --export=envvar
	# $(MAKE) -s -C ../cfn/ export-outputs | eval && env | grep SCEP
	# cd ../cfn/ && pipenv run sceptre --ignore-dependencies list outputs locust --export=envvar
	# eval `$(MAKE) -s -C ../cfn/ export-outputs` && env | grep SCEPTRE
	pipenv run eb init --platform $(CLUSTER_EB_SOLUTION_STACK_NAME) $(PROJECT_CODE)-$(STACK_NAME)-cluster

deploy: init # (Re)deploy the Locust application
	$(call cyan, "make eb/$@ ...")
	pipenv run eb deploy --staged $(PROJECT_CODE)-$(STACK_NAME)-cluster

status: init ## Show deployment status of the Locust application
	$(call cyan, "make eb/$@ ...")
	pipenv run eb status $(PROJECT_CODE)-$(STACK_NAME)-cluster

open: init # Open the Locust web GUI in a web browser
	$(call cyan, "make eb/$@ ...")
	$(call cyan, "Opening Locust UI in a web browser ...")
	pipenv run eb open $(PROJECT_CODE)-$(STACK_NAME)-cluster

clean: # Delete virtual environment and temporary files
	$(call cyan, "make eb/$@ ...")
	pipenv --rm || true
	rm -vrf __pycache__/
	rm -vrf .elasticbeanstalk/

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
