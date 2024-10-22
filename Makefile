.PHONY: init plan apply destroy lint-fix lint

init:
	terraform init

plan: init
	terraform plan

apply: init
	terraform apply

destroy: init
	terraform destroy

lint-fix:
	terraform fmt --recursive

lint:
	terraform fmt --recursive --check
	terraform validate
