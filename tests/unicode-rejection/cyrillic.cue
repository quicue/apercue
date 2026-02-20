// Test: Cyrillic homoglyph in @type key must be rejected.
// Expected: cue vet fails with regex mismatch on #SafeLabel.
//
// The Cyrillic "а" (U+0430) looks identical to Latin "a" (U+0061)
// but creates a distinct CUE key. Provider matching would silently fail.
//
// Run:
//   cue vet ./tests/unicode-rejection/cyrillic_test.cue  # Should FAIL

package main

import "apercue.ca/vocab@v0"

_resources: {
	admin: vocab.#Resource & {
		name: "admin"
		// "Аdmin" starts with Cyrillic А (U+0410), not Latin A
		"@type": {"Аdmin": true}
	}
}
