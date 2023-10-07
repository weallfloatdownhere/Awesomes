.PHONY: clean apply
.EXPORT_ALL_VARIABLES: apply

# Variable filepath
VARFILE:=${PWD}/samples.tfvars
# Target kubeconfig filepath
KUBECONFIG:=${HOME}/.kube/config

clean:
	- rm -rf ${PWD}/.terraform
	- rm -rf ${PWD}/.terraform/.terraform.lock
	- rm -rf ${PWD}/.terraform/.terraform.lock.hcl
	- rm -rf ${PWD}/.terraform/terraform.tfstate
	- rm -rf ${PWD}/.terraform/terraform.tfstate.backup

apply:
	terraform init
	terraform plan -var-file=${PWD}/samples.tfvars -var="kubeconfig=$(KUBECONFIG)"
	terraform apply -var-file=${PWD}/samples.tfvars -var="kubeconfig=$(KUBECONFIG)" -auto-approve