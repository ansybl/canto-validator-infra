IMAGE_TAG=latest
PROJECT=dfpl-playground
REGISTRY=gcr.io/$(PROJECT)
WORKSPACE?=dev-testnet
IMAGE_NAME=canto-validator-$(WORKSPACE)
DOCKER_IMAGE=$(REGISTRY)/$(IMAGE_NAME)
ifndef CI
DOCKER_IT=-it
endif


docker/build:
	docker build --tag=$(DOCKER_IMAGE):$(IMAGE_TAG) .

docker/login:
	gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://gcr.io

docker/push:
	docker push $(DOCKER_IMAGE):$(IMAGE_TAG)

docker/run:
	docker run $(DOCKER_IT) --rm $(DOCKER_IMAGE)

docker/run/sh:
	docker run $(DOCKER_IT) --entrypoint /bin/sh --rm $(DOCKER_IMAGE)

devops/terraform/select/%:
	terraform -chdir=terraform workspace select $* || terraform -chdir=terraform workspace new $*

devops/terraform/fmt:
	terraform -chdir=terraform fmt

devops/terraform/init:
	terraform -chdir=terraform init -reconfigure

devops/terraform/plan: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform plan

devops/terraform/apply: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform apply -auto-approve

devops/terraform/destroy/all: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform destroy

# only destroy the VM
devops/terraform/destroy/%: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform destroy -target=module.gce_worker_container[\"$*\"].google_compute_instance.this -auto-approve

# only redeploy the VM
devops/terraform/redeploy/all: devops/terraform/select/$(WORKSPACE) devops/terraform/destroy/validator1 devops/terraform/destroy/customer2
	make devops/terraform/apply

devops/terraform/output/google_compute_instance_ip: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform output google_compute_instance_ip