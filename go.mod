module github.com/jb-dk/cert-manager-webhook-ibmcis

go 1.12

require (
	github.com/IBM-Cloud/bluemix-go v0.0.0-20201210085054-cdf09378fdd9
	github.com/ghodss/yaml v0.0.0-20180820084758-c7ce16629ff4 // indirect
	github.com/golang/snappy v0.0.0-20180518054509-2e65f85255db // indirect
	github.com/jarcoal/httpmock v1.0.4
	github.com/jetstack/cert-manager v0.12.0
	github.com/renier/xmlrpc v0.0.0-20191022213033-ce560eccbd00 // indirect
	github.com/sirupsen/logrus v1.4.2
	github.com/softlayer/softlayer-go v1.0.0
	github.com/stretchr/testify v1.4.0
	k8s.io/apiextensions-apiserver v0.0.0-20191114105449-027877536833
	k8s.io/apimachinery v0.0.0-20191028221656-72ed19daf4bb
	k8s.io/client-go v0.0.0-20191114101535-6c5935290e33
	k8s.io/klog v1.0.0
)

replace github.com/prometheus/client_golang => github.com/prometheus/client_golang v0.9.4
