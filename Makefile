YQ:=$(shell which yq)
KUBECTL:=$(shell which kubectl)
DOCKER:=$(shell which docker)
MINIKUBE:=$(shell which minikube)

DEPLOY_PATH:=$(LAB)/k8s
INFO_FILE:="${DEPLOY_PATH}/info.yaml"

BASE_IMAGE:=$(shell ${YQ} e '.app.baseImage' ${INFO_FILE})
NAMESPACE:=$(shell ${YQ} e '.app.namespaces.${ENV}' ${INFO_FILE})
APP_NAME:=$(shell ${YQ} e '.app.name' ${INFO_FILE})
VERSION:=$(shell ${YQ} e '.app.version' ${INFO_FILE})
IMAGE_NAME_TAG:=$(APP_NAME):$(VERSION)
NAMESPACE:=$(shell ${YQ} e '.app.namespace' ${INFO_FILE})
ARTIFACT_REGISTRY:=$(shell echo "") # empty
FULLY_QUALIFIED_IMAGE_URL:=$(ARTIFACT_REGISTRY)$(IMAGE_NAME_TAG)

params-guard-%:
	@if [ "${${*}}" = "" ]; then \
			echo "[$*] not set"; \
			exit 1; \
	fi

wait_for_resources: check_compulsory_params
	$(KUBECTL) wait \
	--for=condition=Ready \
	--timeout=300s \
	pods --all \
	--namespace $(NAMESPACE)

check_compulsory_params: params-guard-LAB

minikube-start: check_compulsory_params
	$(MINIKUBE) start

create-namespace: check_compulsory_params
	$(KUBECTL) create namespace $(NAMESPACE) \
	--dry-run=client \
	-o yaml | \
	$(KUBECTL) apply -f -

delete-namespace: check_compulsory_params
	$(KUBECTL) delete namespace $(NAMESPACE)

name: check_compulsory_params
	echo $(APP_NAME)

version: check_compulsory_params
	echo $(VERSION)

print_mk_var: check_compulsory_params
	@echo "YQ: [$(YQ)]"
	@echo "KUBECTL: [$(KUBECTL)]"
	@echo "DOCKER: [$(DOCKER)]"
	@echo "MINIKUBE: [$(MINIKUBE)]"
	@echo "DEPLOY_PATH: [$(DEPLOY_PATH)]"
	@echo "INFO_FILE: [$(INFO_FILE)]"
	@echo "ARTIFACT_REGISTRY: [$(ARTIFACT_REGISTRY)]"
	@echo "BASE_IMAGE: [$(BASE_IMAGE)]"
	@echo "NAMESPACE: [$(NAMESPACE)]"
	@echo "APP_NAME: [$(APP_NAME)]"
	@echo "VERSION: [$(VERSION)]"
	@echo "IMAGE_NAME_TAG: [$(IMAGE_NAME_TAG)]"
	@echo "FULLY_QUALIFIED_IMAGE_URL: [$(FULLY_QUALIFIED_IMAGE_URL)]"

build: check_compulsory_params
	$(DOCKER) build \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg APP_NAME=$(APP_NAME) \
	-t $(IMAGE_NAME_TAG) \
	--pull \
	--no-cache \
	-f $(LAB)/Dockerfile \
	./$(LAB)

tag: check_compulsory_params 
	$(DOCKER) tag \
	$(IMAGE_NAME_TAG) \
	$(FULLY_QUALIFIED_IMAGE_URL)

load: check_compulsory_params print_mk_var
	$(MINIKUBE) image \
	load $(FULLY_QUALIFIED_IMAGE_URL)

kustomize: check_compulsory_params print_mk_var
	kustomize build $(DEPLOY_PATH)

apply: check_compulsory_params print_mk_var
	kustomize build $(DEPLOY_PATH) | \
	kubectl apply \
	-n $(NAMESPACE) \
	-f - 

destroy: check_compulsory_params print_mk_var
	kustomize build $(DEPLOY_PATH) | \
	kubectl delete \
	-n $(NAMESPACE) \
	-f - 

all: check_compulsory_params minikube-start create-namespace build load apply 

minikube-stop: check_compulsory_params
	$(MINIKUBE) stop

minikube-delete: check_compulsory_params
	$(MINIKUBE) delete

clean-up:  destroy minikube-stop minikube-delete
