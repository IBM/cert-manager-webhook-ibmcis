package main

import (
	"os"
	"testing"
	"time"

	dns "github.com/cert-manager/cert-manager/test/acme"
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
		dns.SetResolvedZone(zone),
		dns.SetStrict(true),
		dns.SetPropagationLimit(time.Minute*10),
		dns.SetPollInterval(time.Second*15),
		dns.SetManifestPath("testdata/ibmcis"),
	)

	fixture.RunConformance(t)
}
