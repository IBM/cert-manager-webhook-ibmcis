# Softlayer Webhook for Cert Manager

This is a webhook solver for [Softlayer](http://www.softlayer.com).

[![Docker Repository on Quay](https://quay.io/repository/cgroschupp/cert-manager-webhook-softlayer/status "Docker Repository on Quay")](https://quay.io/repository/cgroschupp/cert-manager-webhook-softlayer)

## Prerequisites

* [cert-manager](https://github.com/jetstack/cert-manager): *tested with 0.8.0*
    - [Installing on Kubernetes](https://docs.cert-manager.io/en/release-0.8/getting-started/install/kubernetes.html)

## Installation

```bash
helm install --name cert-manager-webhook-softlayer ./deploy/cert-manager-webhook-softlayer
```

## Issuer

1. Generate Username and API Token from Softlayer
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
apiVersion: certmanager.k8s.io/v1alpha1
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
          groupName: acme.groschupp.org
          solverName: softlayer
          config:
            username: 12345 # REPLACE WITH USERNAME FROM SOFTLAYER!!!
            apiKeySecretRef:
              key: api-token
              name: softlayer-credentials
```

5. Create a production issuer
```yaml
apiVersion: certmanager.k8s.io/v1alpha1
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
          groupName: acme.groschupp.org
          solverName: softlayer
          config:
            username: 12345 # REPLACE WITH USERNAME FROM SOFTLAYER!!!
            apiKeySecretRef:
              key: api-token
              name: softlayer-credentials
```

## Certificate

1. Issue a certificate
```yaml
apiVersion: certmanager.k8s.io/v1alpha1
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

Then modify `testdata/softlayer-solver/config.json` to setup the configs.

Now you can run the test suite with:

```bash
TEST_ZONE_NAME=example.com. go test .
```
