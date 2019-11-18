module github.com/cgroschupp/cert-manager-webhook-softlayer

go 1.12

require (
	github.com/dgrijalva/jwt-go v3.2.0+incompatible // indirect
	github.com/imdario/mergo v0.3.7 // indirect
	github.com/jarcoal/httpmock v1.0.4
	github.com/jetstack/cert-manager v0.10.1
	github.com/renier/xmlrpc v0.0.0-20170708154548-ce4a1a486c03 // indirect
	github.com/softlayer/softlayer-go v0.0.0-20190814165317-b9062a914a22
	github.com/stretchr/testify v1.3.0
	k8s.io/api v0.0.0-20190718183219-b59d8169aab5
	k8s.io/apiextensions-apiserver v0.0.0-20190718185103-d1ef975d28ce
	k8s.io/apimachinery v0.0.0-20190612205821-1799e75a0719
	k8s.io/client-go v11.0.1-0.20190409021438-1a26190bd76a+incompatible
	k8s.io/klog v0.3.1
)

replace k8s.io/client-go => k8s.io/client-go v0.0.0-20190413052642-108c485f896e

replace github.com/evanphx/json-patch => github.com/evanphx/json-patch v0.0.0-20190203023257-5858425f7550
