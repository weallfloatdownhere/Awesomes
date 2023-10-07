.PHONY: deploy check-env

.EXPORT_ALL_VARIABLES: apply

clean:
	- rm -rf ${PWD}/.terraform
	- rm -rf ${PWD}/.terraform/.terraform.lock
	- rm -rf ${PWD}/.terraform/.terraform.lock.hcl
	- rm -rf ${PWD}/.terraform/terraform.tfstate
	- rm -rf ${PWD}/.terraform/terraform.tfstate.backup

apply:
ifndef KUBECONFIG
	$(error KUBECONFIG is undefined)
endif
	terraform init
	terraform plan -var-file=${PWD}/values.tfvars -var="kubeconfig=$(KUBECONFIG)"
	terraform apply -var-file=${PWD}/values.tfvars -var="kubeconfig=$(KUBECONFIG)"