.PHONY: install deploy uninstall deps validate launch update delete status
.PHONY: list-outputs list-resources locust-smoketest clean help
.DEFAULT_GOAL := help

install: deps launch ## Create the Locust environment and deploy a test suite for blazedemo.com
	@$(MAKE) -C ./aws/files/app/ deploy

deploy: deps update ## Deploy modifications to the Locust test suite and/or CloudFormation templates
	@$(MAKE) -C ./aws/files/app/ deploy

uninstall: deps delete clean ## Delete the Locust environment, local dependencies and temporary files
	@$(MAKE) -C ./aws/files/app/ clean

deps: # Install local dependencies in virtual environments (requires pipenv)
	$(call cyan, "make $@ ...")
	@pipenv --bare install

validate: # Validate CloudFormation Template(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws validate $(stack)

launch: validate # Deploy CloudFormation Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws launch --yes $(stack)

update: validate # Update CloudFormation Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws update --yes $(stack)

delete: # Terminate CloudFormation Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws delete --yes $(stack)

status: # Show deployment status of the CloudFormation Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws status $(stack)

list-outputs: # List CloudFormation Outputs of the Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws list outputs $(stack)

list-resources: # List CloudFormation Resources of the Stack(s)
	$(call cyan, "make $@ ...")
	@pipenv run sceptre --dir aws list resources $(stack)

locust-smoketest: # Smoke test the local Locust test suite
	$(call cyan, "make $@ ...")
	@pipenv run locust --no-web --only-summary \
		--locustfile=./aws/files/app/locustfile.py \
		--clients=100 --hatch-rate=20 --run-time=10s

clean: # Delete virtual environment
	$(call cyan, "make $@ ...")
	@pipenv --rm

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
