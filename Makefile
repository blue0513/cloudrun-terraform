.PHONY: init plan apply destroy

init:
	terraform init

plan: init
	terraform plan

apply: init
	terraform apply

destroy: init
	terraform destroy
