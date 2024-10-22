.PHONY: setup init plan apply destroy output lint-fix lint

setup:
	@echo "This will overwrite your .tfvars file. Are you sure you want to continue? [y/N]" && read ans && [ $${ans:-N} = y ]
	cp terraform.tfvars.example terraform.tfvars
	@echo "Please fill in the terraform.tfvars file with your own values"

init:
	terraform init

plan: init
	terraform plan

apply: init
	terraform apply

destroy: init
	terraform destroy

output:
	terraform output

lint-fix:
	terraform fmt --recursive

lint:
	terraform fmt --recursive --check
	terraform validate
