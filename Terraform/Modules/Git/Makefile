.EXPORT_ALL_VARIABLES: mini_start mini_stop

TERRAFORM_BASEDIR:=${PWD}/src
VARFILE:=${PWD}/test.tfvars

repo_start:
	terraform -chdir=$(TERRAFORM_BASEDIR) init -compact-warnings
	terraform -chdir=$(TERRAFORM_BASEDIR) plan -var-file=$(VARFILE) -compact-warnings
	terraform -chdir=$(TERRAFORM_BASEDIR) apply -var-file=$(VARFILE) -compact-warnings -auto-approve

repo_stop:
	- terraform -chdir=$(TERRAFORM_BASEDIR) destroy -var-file=$(VARFILE) -compact-warnings -auto-approve
	- rm -rf $(TERRAFORM_BASEDIR)/.terraform
	- rm -rf $(TERRAFORM_BASEDIR)/.terraform.lock
	- rm -rf $(TERRAFORM_BASEDIR)/.terraform.lock.hcl
	- rm -rf $(TERRAFORM_BASEDIR)/terraform.tfstate
	- rm -rf $(TERRAFORM_BASEDIR)/terraform.tfstate.backup
	- rm -rf ${PWD}/*.tmp
	- rm -rf ${PWD}/argorepo



# temp for testing
MINIKUBE_NAME := cluster
MINIKUBE_RAM := 3096
MINIKUBE_CPUS := 2
KUBECONFIG := ${PWD}/${MINIKUBE_NAME}.kubeconfig

mini_start:
	export KUBECONFIG=$(KUBECONFIG).tmp
	minikube start -p $(MINIKUBE_NAME) --cpus $(MINIKUBE_CPUS) --memory $(MINIKUBE_RAM) --network bridge
	kubectl config view --context $(MINIKUBE_NAME) --flatten --minify > $(KUBECONFIG).tmp
	mv $(KUBECONFIG).tmp $(KUBECONFIG)
	export KUBECONFIG=$(KUBECONFIG)

mini_stop:
	export KUBECONFIG=$(KUBECONFIG)
	minikube delete -p $(MINIKUBE_NAME)
	rm -rf $(KUBECONFIG)