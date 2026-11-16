// Correct precompute: cue vet must pass.
package test

import "apercue.ca/patterns@v0"

g: patterns.#GraphLite & {
	Input: {
	 "a0": {
	  "name": "a0",
	  "@type": {
	   "Step": true
	  }
	 },
	 "b0": {
	  "name": "b0",
	  "@type": {
	   "Step": true
	  }
	 },
	 "a1": {
	  "name": "a1",
	  "@type": {
	   "Step": true
	  },
	  "depends_on": {
	   "a0": true,
	   "b0": true
	  }
	 },
	 "b1": {
	  "name": "b1",
	  "@type": {
	   "Step": true
	  },
	  "depends_on": {
	   "a0": true,
	   "b0": true
	  }
	 },
	 "a2": {
	  "name": "a2",
	  "@type": {
	   "Step": true
	  },
	  "depends_on": {
	   "a1": true,
	   "b1": true
	  }
	 },
	 "b2": {
	  "name": "b2",
	  "@type": {
	   "Step": true
	  },
	  "depends_on": {
	   "a1": true,
	   "b1": true
	  }
	 },
	 "a3": {
	  "name": "a3",
	  "@type": {
	   "Step": true
	  },
	  "depends_on": {
	   "a2": true,
	   "b2": true
	  }
	 },
	 "b3": {
	  "name": "b3",
	  "@type": {
	   "Step": true
	  },
	  "depends_on": {
	   "a2": true,
	   "b2": true
	  }
	 },
	 "a4": {
	  "name": "a4",
	  "@type": {
	   "Step": true
	  },
	  "depends_on": {
	   "a3": true,
	   "b3": true
	  }
	 },
	 "b4": {
	  "name": "b4",
	  "@type": {
	   "Step": true
	  },
	  "depends_on": {
	   "a3": true,
	   "b3": true
	  }
	 },
	 "a5": {
	  "name": "a5",
	  "@type": {
	   "Step": true
	  },
	  "depends_on": {
	   "a4": true,
	   "b4": true
	  }
	 },
	 "b5": {
	  "name": "b5",
	  "@type": {
	   "Step": true
	  },
	  "depends_on": {
	   "a4": true,
	   "b4": true
	  }
	 }
	}
	Precomputed: {
	 "depth": {
	  "a0": 0,
	  "b0": 0,
	  "a1": 1,
	  "b1": 1,
	  "a2": 2,
	  "b2": 2,
	  "a3": 3,
	  "b3": 3,
	  "a4": 4,
	  "b4": 4,
	  "a5": 5,
	  "b5": 5
	 },
	 "ancestors": {
	  "a0": {},
	  "b0": {},
	  "a1": {
	   "a0": true,
	   "b0": true
	  },
	  "b1": {
	   "a0": true,
	   "b0": true
	  },
	  "a2": {
	   "a1": true,
	   "a0": true,
	   "b0": true,
	   "b1": true
	  },
	  "b2": {
	   "a1": true,
	   "a0": true,
	   "b0": true,
	   "b1": true
	  },
	  "a3": {
	   "a2": true,
	   "a1": true,
	   "a0": true,
	   "b0": true,
	   "b1": true,
	   "b2": true
	  },
	  "b3": {
	   "a2": true,
	   "a1": true,
	   "a0": true,
	   "b0": true,
	   "b1": true,
	   "b2": true
	  },
	  "a4": {
	   "a3": true,
	   "a2": true,
	   "a1": true,
	   "a0": true,
	   "b0": true,
	   "b1": true,
	   "b2": true,
	   "b3": true
	  },
	  "b4": {
	   "a3": true,
	   "a2": true,
	   "a1": true,
	   "a0": true,
	   "b0": true,
	   "b1": true,
	   "b2": true,
	   "b3": true
	  },
	  "a5": {
	   "a4": true,
	   "a3": true,
	   "a2": true,
	   "a1": true,
	   "a0": true,
	   "b0": true,
	   "b1": true,
	   "b2": true,
	   "b3": true,
	   "b4": true
	  },
	  "b5": {
	   "a4": true,
	   "a3": true,
	   "a2": true,
	   "a1": true,
	   "a0": true,
	   "b0": true,
	   "b1": true,
	   "b2": true,
	   "b3": true,
	   "b4": true
	  }
	 },
	 "dependents": {
	  "a0": {
	   "a1": true,
	   "b1": true,
	   "a2": true,
	   "b2": true,
	   "a3": true,
	   "b3": true,
	   "a4": true,
	   "b4": true,
	   "a5": true,
	   "b5": true
	  },
	  "b0": {
	   "a1": true,
	   "b1": true,
	   "a2": true,
	   "b2": true,
	   "a3": true,
	   "b3": true,
	   "a4": true,
	   "b4": true,
	   "a5": true,
	   "b5": true
	  },
	  "a1": {
	   "a2": true,
	   "b2": true,
	   "a3": true,
	   "b3": true,
	   "a4": true,
	   "b4": true,
	   "a5": true,
	   "b5": true
	  },
	  "b1": {
	   "a2": true,
	   "b2": true,
	   "a3": true,
	   "b3": true,
	   "a4": true,
	   "b4": true,
	   "a5": true,
	   "b5": true
	  },
	  "a2": {
	   "a3": true,
	   "b3": true,
	   "a4": true,
	   "b4": true,
	   "a5": true,
	   "b5": true
	  },
	  "b2": {
	   "a3": true,
	   "b3": true,
	   "a4": true,
	   "b4": true,
	   "a5": true,
	   "b5": true
	  },
	  "a3": {
	   "a4": true,
	   "b4": true,
	   "a5": true,
	   "b5": true
	  },
	  "b3": {
	   "a4": true,
	   "b4": true,
	   "a5": true,
	   "b5": true
	  },
	  "a4": {
	   "a5": true,
	   "b5": true
	  },
	  "b4": {
	   "a5": true,
	   "b5": true
	  },
	  "a5": {},
	  "b5": {}
	 }
	}
}
