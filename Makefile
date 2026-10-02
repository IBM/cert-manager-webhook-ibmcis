IMAGE_NAME := "quay.io/ibm/cert-manager-webhook-ibmcis"
IMAGE_TAG := "latest"
PLATFORM := "linux/amd64"
MULTIARCH := "linux/amd64,linux/ppc64le,linux/s390x"

OUT := $(shell pwd)/_out

$(shell mkdir -p "$(OUT)")

verify:
	go test -v .

build:
	podman build --platform $(PLATFORM) -t "$(IMAGE_NAME):$(IMAGE_TAG)_$(subst linux/,,$(PLATFORM))" .

build-multi:
	podman manifest rm "$(IMAGE_NAME):$(IMAGE_TAG)" || true
	podman build --platform $(MULTIARCH)  --manifest "$(IMAGE_NAME):$(IMAGE_TAG)" .

.PHONY: rendered-manifest.yaml
rendered-manifest.yaml:
	helm template \
	    --name-template=cert-manager-webhook-ibmcis \
        --set image.repository=$(IMAGE_NAME) \
        --set image.tag=$(IMAGE_TAG) \
        deploy/cert-manager-webhook-ibmcis > "$(OUT)/rendered-manifest.yaml"
