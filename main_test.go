package main

import (
	"os"
	"testing"

	"github.com/cert-manager/cert-manager/test/acme/dns"
)

var (
	zone = os.Getenv("TEST_ZONE_NAME")
)

func TestRunsSuite(t *testing.T) {
	// The manifest path should contain a file named config.json that is a
	// snippet of valid configuration that should be included on the
	// ChallengeRequest passed as part of the test cases.

	solver := &ibmcisDNSProviderSolver{}
	fixture := dns.NewFixture(solver,
		dns.SetBinariesPath("__main__/hack/bin"),
		dns.SetResolvedZone(zone),
		dns.SetManifestPath("testdata/ibmcis"),
	)

	fixture.RunConformance(t)
}
