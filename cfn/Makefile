.PHONY: install apply show uninstall dependencies validate launch update delete status
.PHONY: list-outputs export-outputs list-resources clean help
.DEFAULT_GOAL := help

export STACK_NAME

install: dependencies launch ## Deploy CloudFormation Stack(s)

apply: dependencies update ## Update CloudFormation Stack(s)

uninstall: dependencies delete clean ## Terminate CloudFormation Stack(s) and clean up local files

dependencies: # Install local dependencies in a local virtual environment
	$(call cyan, "make cfn/$@ ...")
	pipenv --bare install

validate: # Validate CloudFormation Template(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre validate $(STACK_NAME)

launch: validate # Deploy CloudFormation Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre launch --yes $(STACK_NAME)

update: validate # Update CloudFormation Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre update --yes $(STACK_NAME)

delete: # Terminate CloudFormation Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre delete --yes $(STACK_NAME)

status: ## Show deployment status of the CloudFormation Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre status $(STACK_NAME)

list-outputs: # List CloudFormation Outputs of the Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre list outputs $(STACK_NAME)

export-outputs: # Generate export commands for CloudFormation Stack Outputs
	pipenv run sceptre --ignore-dependencies list outputs $(STACK_NAME) --export=envvar

list-resources: # List CloudFormation Resources of the Stack(s)
	$(call cyan, "make cfn/$@ ...")
	pipenv run sceptre list resources $(STACK_NAME)

clean: # Delete virtual environment
	$(call cyan, "make cfn/$@ ...")
	pipenv --rm || true

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

define cyan
	@tput setaf 6
	@echo $1
	@tput sgr0
endef
