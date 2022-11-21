IMAGE_TAG=latest
PROJECT=dfpl-playground
REGISTRY=gcr.io/$(PROJECT)
WORKSPACE?=dev-testnet
CANTO_IMAGE_NAME=canto-validator-$(WORKSPACE)
CANTO_DOCKER_IMAGE=$(REGISTRY)/$(CANTO_IMAGE_NAME)
NGINX_IMAGE_NAME=nginx-reverse-proxy-$(WORKSPACE)
NGINX_DOCKER_IMAGE=$(REGISTRY)/$(NGINX_IMAGE_NAME)
ifndef CI
DOCKER_IT=-it
endif


docker/build/canto:
	cd docker/canto && docker build --tag=$(CANTO_DOCKER_IMAGE):$(IMAGE_TAG) .

docker/build/nginx:
	cd docker/nginx && docker build --tag=$(NGINX_DOCKER_IMAGE):$(IMAGE_TAG) .

docker/build: docker/build/canto docker/build/nginx

docker/login:
	gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://gcr.io

docker/push/canto:
	docker push $(CANTO_DOCKER_IMAGE):$(IMAGE_TAG)

docker/push/nginx:
	docker push $(NGINX_DOCKER_IMAGE):$(IMAGE_TAG)

docker/push: docker/push/canto docker/push/nginx

docker/run:
	docker run $(DOCKER_IT) --rm $(CANTO_DOCKER_IMAGE)

docker/run/sh:
	docker run $(DOCKER_IT) --entrypoint /bin/sh --rm $(CANTO_DOCKER_IMAGE)

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

devops/terraform/destroy/nodes: devops/terraform/destroy/node1 devops/terraform/destroy/node2

devops/terraform/destroy/validators: devops/terraform/destroy/validator1

devops/terraform/destroy/proxies: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform destroy -target=google_compute_instance.reverse_proxy -auto-approve

devops/terraform/redeploy/nodes: devops/terraform/select/$(WORKSPACE) devops/terraform/destroy/nodes
	make devops/terraform/apply

# redeploy the nodes & validators VM
devops/terraform/redeploy/all: devops/terraform/select/$(WORKSPACE) devops/terraform/destroy/validators devops/terraform/destroy/nodes
	make devops/terraform/apply

devops/terraform/output/google_compute_instance_ip: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform output google_compute_instance_ip
