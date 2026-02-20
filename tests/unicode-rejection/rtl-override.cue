// Test: RTL override character (U+202E) in depends_on key must be rejected.
// Expected: cue vet fails with regex mismatch on #SafeID.
//
// RTL override reverses text display direction, disguising dependency targets.
//
// Run:
//   cue vet ./tests/unicode-rejection/rtl_override_test.cue  # Should FAIL

package main

import "apercue.ca/vocab@v0"

_resources: {
	server: vocab.#Resource & {
		name:       "server"
		"@type":    {Service: true}
		depends_on: {"db‮evil": true}
	}
}
