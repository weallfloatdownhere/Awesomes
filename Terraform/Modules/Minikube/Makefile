.PHONY: clean apply
.EXPORT_ALL_VARIABLES: apply

# Variable filepath
VARFILE:=${PWD}/samples.tfvars
# Target kubeconfig filepath
KUBECONFIG:=${HOME}/.kube/config

clean:
	- terraform destroy -var-file=$(VARFILE) -var="kubeconfig=$(KUBECONFIG)" -auto-approve
	- rm -rf ${PWD}/.terraform
	- rm -rf ${PWD}/.terraform/.terraform.lock
	- rm -rf ${PWD}/.terraform/.terraform.lock.hcl
	- rm -rf ${PWD}/.terraform/terraform.tfstate
	- rm -rf ${PWD}/.terraform/terraform.tfstate.backup

apply:
	terraform init
	export KUBECONFIG=$(KUBECONFIG)
	terraform plan -var-file=$(VARFILE)
	terraform apply -var-file=$(VARFILE) -auto-approve