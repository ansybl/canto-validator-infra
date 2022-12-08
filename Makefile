IMAGE_TAG=latest
PROJECT=dfpl-playground
REGISTRY=gcr.io/$(PROJECT)
WORKSPACE?=dev-testnet
CANTO_IMAGE_NAME=canto-validator-$(WORKSPACE)
CANTO_DOCKER_IMAGE=$(REGISTRY)/$(CANTO_IMAGE_NAME)
NGINX_IMAGE_NAME=nginx-reverse-proxy-$(WORKSPACE)
NGINX_DOCKER_IMAGE=$(REGISTRY)/$(NGINX_IMAGE_NAME)
DIAGRAMS_DIR=diagrams
VIRTUAL_ENV ?= $(DIAGRAMS_DIR)/venv
REQUIREMENTS=$(DIAGRAMS_DIR)/requirements.txt
PIP=$(VIRTUAL_ENV)/bin/pip
PYTHON=$(VIRTUAL_ENV)/bin/python
ISORT=$(VIRTUAL_ENV)/bin/isort
FLAKE8=$(VIRTUAL_ENV)/bin/flake8
BLACK=$(VIRTUAL_ENV)/bin/black
PYTHON_MAJOR_VERSION=3
PYTHON_MINOR_VERSION=10
PYTHON_VERSION=$(PYTHON_MAJOR_VERSION).$(PYTHON_MINOR_VERSION)
PYTHON_MAJOR_MINOR=$(PYTHON_MAJOR_VERSION)$(PYTHON_MINOR_VERSION)
PYTHON_WITH_VERSION=python$(PYTHON_VERSION)
SOURCES=diagrams/
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

devops/terraform/destroy/nodes: devops/terraform/destroy/node1

devops/terraform/destroy/validators: devops/terraform/destroy/validator1

devops/terraform/destroy/sentries: devops/terraform/destroy/sentry1 devops/terraform/destroy/sentry2

devops/terraform/destroy/proxies: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform destroy -target=google_compute_instance.reverse_proxy -auto-approve

# https://github.com/terraform-google-modules/terraform-google-lb-http/blob/v6.3.0/docs/upgrading-v2.0.0-v3.0.0.md#dealing-with-dependencies
devops/terraform/destroy/serverless_neg: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform destroy \
	-target=google_compute_region_network_endpoint_group.serverless_neg -auto-approve

devops/terraform/redeploy/nodes: devops/terraform/select/$(WORKSPACE) devops/terraform/destroy/nodes
	make devops/terraform/apply

devops/terraform/redeploy/sentries: devops/terraform/select/$(WORKSPACE) devops/terraform/destroy/sentries
	make devops/terraform/apply

devops/terraform/redeploy/validators: devops/terraform/select/$(WORKSPACE) devops/terraform/destroy/validators
	make devops/terraform/apply

# redeploy the nodes, sentries and validators VM
devops/terraform/redeploy/all: devops/terraform/select/$(WORKSPACE) devops/terraform/destroy/validators devops/terraform/destroy/nodes devops/terraform/destroy/sentries
	make devops/terraform/apply

devops/terraform/output: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform output

devops/terraform/output/google_compute_instance_name_ip_map: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform output google_compute_instance_name_ip_map

$(VIRTUAL_ENV):
	$(PYTHON_WITH_VERSION) -m venv $(VIRTUAL_ENV)
	$(PIP) install -r $(REQUIREMENTS)

virtualenv: $(VIRTUAL_ENV)

diagrams/run: $(VIRTUAL_ENV)
	cd $(DIAGRAMS_DIR) && ../$(PYTHON) diagram.py

diagrams/lint/isort: $(VIRTUAL_ENV)
	$(ISORT) --check-only --diff $(SOURCES)

diagrams/lint/flake8: $(VIRTUAL_ENV)
	$(FLAKE8) --config $(DIAGRAMS_DIR)/setup.cfg $(SOURCES)

diagrams/lint/black: $(VIRTUAL_ENV)
	$(BLACK) --check $(SOURCES)

diagrams/format/isort: $(VIRTUAL_ENV)
	$(ISORT) $(SOURCES)

diagrams/format/black: $(VIRTUAL_ENV)
	$(BLACK) --verbose $(SOURCES)

diagrams/lint: diagrams/lint/isort diagrams/lint/flake8 diagrams/lint/black

diagrams/format: diagrams/format/isort diagrams/format/black
