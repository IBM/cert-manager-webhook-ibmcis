IMAGE_NAME := "quay.io/ibm/cert-manager-webhook-ibmcis"
IMAGE_TAG := "latest"
PLATFORM := "linux/amd64"

OUT := $(shell pwd)/_out

$(shell mkdir -p "$(OUT)")

verify:
	go test -v .

build:
	podman build --platform $(PLATFORM) -t "$(IMAGE_NAME):$(IMAGE_TAG)_$(subst linux/,,$(PLATFORM))" .

build-multi:
	podman manifest rm "$(IMAGE_NAME):$(IMAGE_TAG)" || true
	podman build --platform linux/amd64  -t "$(IMAGE_NAME):$(IMAGE_TAG)_amd64" .
	podman build --platform linux/ppc64le  -t "$(IMAGE_NAME):$(IMAGE_TAG)_ppc64le" .
	podman build --platform linux/s390x  -t "$(IMAGE_NAME):$(IMAGE_TAG)_s390x" .
	podman manifest create "$(IMAGE_NAME):$(IMAGE_TAG)"
	podman manifest add "$(IMAGE_NAME):$(IMAGE_TAG)" "$(IMAGE_NAME):$(IMAGE_TAG)_amd64"
	podman manifest add "$(IMAGE_NAME):$(IMAGE_TAG)" "$(IMAGE_NAME):$(IMAGE_TAG)_ppc64le"
	podman manifest add "$(IMAGE_NAME):$(IMAGE_TAG)" "$(IMAGE_NAME):$(IMAGE_TAG)_s390x"


.PHONY: rendered-manifest.yaml
rendered-manifest.yaml:
	helm template \
	    --name-template=cert-manager-webhook-ibmcis \
        --set image.repository=$(IMAGE_NAME) \
        --set image.tag=$(IMAGE_TAG) \
        deploy/cert-manager-webhook-ibmcis > "$(OUT)/rendered-manifest.yaml"
