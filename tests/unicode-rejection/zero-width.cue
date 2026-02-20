// Test: Zero-width space (U+200B) in resource name must be rejected.
// Expected: cue vet fails with regex mismatch on #SafeID.
//
// Run:
//   cue vet ./tests/unicode-rejection/zero_width_test.cue  # Should FAIL

package main

import "apercue.ca/vocab@v0"

_resources: {
	// The resource name contains an invisible U+200B (zero-width space)
	// between "dns" and "server". Looks like "dnsserver" but isn't.
	"dns​server": vocab.#Resource & {
		name:    "dns​server"
		"@type": {Service: true}
	}
}
