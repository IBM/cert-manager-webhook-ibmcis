package main

import (
	"net/http"
	"os"
	"testing"
	"time"

	"github.com/jarcoal/httpmock"
	cmapi "github.com/jetstack/cert-manager/pkg/apis/certmanager/v1alpha1"
	logf "github.com/jetstack/cert-manager/pkg/logs"
	"github.com/jetstack/cert-manager/test/acme/dns"
	testserver "github.com/jetstack/cert-manager/test/acme/dns/server"
	"github.com/softlayer/softlayer-go/session"
)

var (
	zone = os.Getenv("TEST_ZONE_NAME")

	rfc2136TestFqdn        = "_acme-challenge.example.com."
	rfc2136TestZone        = "example.com."
	rfc2136TestTsigKeyName = "example.com."
	rfc2136TestTsigSecret  = "IwBTJx9wrDp4Y1RyC3H0gA=="
)

func TestRunsSuite(t *testing.T) {
	// The manifest path should contain a file named config.json that is a
	// snippet of valid configuration that should be included on the
	// ChallengeRequest passed as part of the test cases.

	client := &http.Client{Transport: &http.Transport{TLSHandshakeTimeout: 60 * time.Second}}
	solver := &softlayerDNSProviderSolver{}
	s1 := session.New("unittest", "unittest-token")
	s1.HTTPClient = client
	solver.SetSession(s1)

	server := &testserver.BasicServer{
		Zones:         []string{rfc2136TestZone},
		EnableTSIG:    true,
		TSIGZone:      rfc2136TestZone,
		TSIGKeyName:   rfc2136TestTsigKeyName,
		TSIGKeySecret: rfc2136TestTsigSecret,
	}

	ctx := logf.NewContext(nil, nil, t.Name())
	if err := server.Run(ctx); err != nil {
		t.Fatalf("failed to start test server: %v", err)
	}
	defer server.Shutdown()

	var validConfig = cmapi.ACMEIssuerDNS01ProviderRFC2136{
		Nameserver: server.ListenAddr(),
	}

	fixture := dns.NewFixture(solver,
		dns.SetBinariesPath("/home/christian/.go/src/github.com/jetstack/cert-manager/bazel-genfiles/hack/bin"),
		dns.SetResolvedZone(zone),
		dns.SetResolvedFQDN(rfc2136TestFqdn),
		dns.SetDNSServer(server.ListenAddr()),
		dns.SetConfig(validConfig),
		dns.SetAllowAmbientCredentials(false),
		dns.SetManifestPath("testdata/my-custom-solver"),
		dns.SetUseAuthoritative(false),
	)

	httpmock.ActivateNonDefault(client)

	defer httpmock.DeactivateAndReset()

	registerMocks(t)

	fixture.RunConformance(t)
}
