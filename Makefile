IMAGE_NAME := "quay.io/borup.work/cert-manager-webhook-ibmcis"
IMAGE_TAG := "latest"

OUT := $(shell pwd)/_out

$(shell mkdir -p "$(OUT)")

verify:
	go test -v .

build:
	docker build -t "$(IMAGE_NAME):$(IMAGE_TAG)" .

.PHONY: rendered-manifest.yaml
rendered-manifest.yaml:
	helm template \
	    --name-template=cert-manager-webhook-ibmcis \
        --set image.repository=$(IMAGE_NAME) \
        --set image.tag=$(IMAGE_TAG) \
        deploy/cert-manager-webhook-ibmcis > "$(OUT)/rendered-manifest.yaml"
