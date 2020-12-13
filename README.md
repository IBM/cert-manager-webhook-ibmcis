# IBM Cloud Internet Service Webhook for Cert Manager

This is a webhook solver for [IBM Cloud Internet Service](https://cloud.ibm.com/catalog/services/internet-services#about).

[![Docker Repository on Quay](https://quay.io/repository/borup.work/cert-manager-webhook-ibmcis/status "Docker Repository on Quay")](https://quay.io/repository/borup.work/cert-manager-webhook-ibmcis)

## Prerequisites

* [cert-manager](https://github.com/jetstack/cert-manager): *tested with 1.1.0*
    - [Installing on Kubernetes](https://cert-manager.io/next-docs/installation/kubernetes/)

## Installation

```bash
helm install --name cert-manager-webhook-ibmcis ./deploy/cert-manager-webhook-cis
```

## Issuer

1. Generate API-KEY from IBM Cloud 
2. Create secret to store the API Token
```bash
kubectl --namespace cert-manager create secret generic \
    softlayer-credentials --from-literal=api-token='<SOFTLAYER_API_TOKEN>'
```

3. Grant permission for service-account to get the secret
```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    name: cert-manager-webhook-softlayer:secret-reader
  rules:
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["softlayer-credentials"]
    verbs: ["get", "watch"]
  ---
  apiVersion: rbac.authorization.k8s.io/v1beta1
  kind: RoleBinding
  metadata:
    name: cert-manager-webhook-softlayer:secret-reader
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: cert-manager-webhook-softlayer:secret-reader
  subjects:
    - apiGroup: ""
      kind: ServiceAccount
      name: cert-manager-webhook-softlayer
```

4. Create a staging issuer *Optional*
```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # The ACME server URL
    server: https://acme-staging-v02.api.letsencrypt.org/directory

    # Email address used for ACME registration
    email: user@example.com # REPLACE THIS WITH YOUR EMAIL!!!

    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-staging

    solvers:
    - dns01:
        webhook:
          groupName: acme.borup.work
          solverName: ibmcis
          config:
            cisCRN: "crn:v1:bluemix:public:internet-svcs:global:***::"
      selector:
        dnsZones:
        - 'borup.work'

```

5. Create a production issuer
```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory

    # Email address used for ACME registration
    email: user@example.com # REPLACE THIS WITH YOUR EMAIL!!!

    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod

    solvers:
    - dns01:
        webhook:
          groupName: acme.borup.work
          solverName: ibmcis
          config:
            cisCRN: "crn:v1:bluemix:public:internet-svcs:global:***::"
      selector:
        dnsZones:
        - 'borup.work'
```

## Certificate

1. Issue a certificate
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-com
spec:
  commonName: example-com
  dnsNames:
  - example-com
  issuerRef:
    name: letsencrypt-staging
  secretName: example-com-tls
```

### Automatically creating Certificates for Ingress resources

See [this](https://docs.cert-manager.io/en/latest/tasks/issuing-certificates/ingress-shim.html).

## Development

All DNS providers **must** run the DNS01 provider conformance testing suite,
else they will have undetermined behaviour when used with cert-manager.

**It is essential that you configure and run the test suite when creating a
DNS01 webhook.**

An example Go test file has been provided in [main_test.go]().

Before you can run the test suite, you need to download the test binaries:

```bash
mkdir -p __main__/hack
wget -O- https://storage.googleapis.com/kubebuilder-tools/kubebuilder-tools-1.14.1-linux-amd64.tar.gz | tar xz --strip-components=1 -C __main__/hack
```

Then modify `testdata/ibmcis/config.json` to setup the configs.

Now you can run the test suite with:

```bash
TEST_ZONE_NAME=example.com. go test .
```
### Test via Docker (Mac test binaries not described in above section)

```bash
#CRN to be used in config.json as cisCRN
#ic resource service-instance borup.work-is -g default --output json | jq .[0].crn
ibmcloud resource service-instance <CIS INSTANCE NAME> -g <RESOURCE GROJO> --output json | jq .[0].crn 
docker run -it -v${PWD}:/workspace -w /workspace golang:1.12 /bin/bash
apt update
apt upgrade -y
apt-get install -y bzr 
#TEST_ZONE_NAME=example.com. go test .
cat > testdata/softlayer/config.json <<EOF
{
    "cisCRN": "crn:v1:bluemix:public:internet-svcs:global:xxxxxxxx::"
}
EOF

export IC_API_KEY=xxxxx

TEST_ZONE_NAME=borup.work. go test .

```

## Push image to quay.io

docker login quay.io
