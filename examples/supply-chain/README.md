# Supply Chain Example: Multi-Tier Dependency Graph

This example demonstrates how **supply chains are dependency graphs**. A laptop manufacturing pipeline models the complete lifecycle from raw materials through finished products, using the apercue patterns library.

## The Model

The supply chain consists of **14 resources** across **5 tiers**:

```
Tier 0 (Roots):         5 raw materials (silicon, copper, lithium, glass, aluminum)
  ↓
Tier 1:                 5 components (CPU, memory, battery, display, chassis)
  ↓
Tier 2:                 2 sub-assemblies (motherboard, display assembly)
  ↓
Tier 3:                 1 final assembly (laptop)
  ↓
Tier 4 (Leaf):          1 finished product (tested, packaged laptop)
```

Each resource has:
- **name**: unique identifier
- **@type**: semantic type (RawMaterial, Component, SubAssembly, Assembly, Finished)
- **depends_on**: set membership of dependencies
- **lead_days**: manufacturing lead time (for critical path analysis)
- **description**: what it is
- **supplier**: (for raw materials) where it comes from

## Key Insights

1. **Dependency Graph Properties**
   - Graph is a DAG (directed acyclic graph)
   - Depth = longest chain of dependencies (here: 4 levels)
   - Critical path = longest lead time path (56 days total)

2. **Bill of Materials (BOM) Completeness**
   - Charter gates enforce structured phase checkpoints
   - Phase 1: Raw materials sourced
   - Phase 2: Components manufactured
   - Phase 3: Assemblies complete
   - Phase 4: Ship ready

3. **Supply Chain Risks**
   - Single points of failure (SPOF): `laptop-assy` is a critical chokepoint
   - If laptop-assy fails, the entire supply chain stalls
   - This is detected automatically by patterns.#SinglePointsOfFailure

4. **Critical Path Method (CPM)**
   - Computes earliest start time, latest start time, slack per resource
   - Resources with zero slack form the critical path (5 resources)
   - Any delay on these delays the whole project
   - Path: silicon-wafer → cpu-chip → motherboard-assy → laptop-assy → laptop-finished

## Running the Example

```bash
# Validate the schema
cue vet ./examples/supply-chain/

# View the summary
cue eval ./examples/supply-chain/ -e summary

# Check if all gates are satisfied
cue eval ./examples/supply-chain/ -e gaps.complete

# Get critical path details
cue eval ./examples/supply-chain/ -e cpm.summary
cue export ./examples/supply-chain/ -e cpm.critical_sequence --out json

# Analyze supply chain risks
cue eval ./examples/supply-chain/ -e spof.risks
cue eval ./examples/supply-chain/ -e spof.summary
```

## Output Example

```
$ cue eval ./examples/supply-chain/ -e summary

product:       "laptop-bom"
total_parts:   14
supply_tiers:  5
graph_valid:   true
gap: {
    complete:  true         // All BOM gates satisfied
    missing:   0            // No missing resources
    next_gate: ""           // All phases complete
}
scheduling: {
    total_lead_days:     56 // Total project duration
    critical_path_parts: 5  // 5 resources on critical path
    max_slack:           37 // Longest delay buffer
}
supply_chain_risks: {
    spof_count:      1      // 1 single point of failure
    total_with_deps: 13     // 13 resources with dependents
}
compliance: {
    total:             3
    passed:            3    // All compliance rules satisfied
    failed:            0
    critical_failures: 0
}
```

## Enterprise Appeal

This example shows why apercue patterns matter for enterprise IT:

1. **Universality**: Supply chains, infrastructure, software architecture—all are dependency graphs. Same patterns work everywhere.

2. **Completeness as a Constraint**: The charter forces you to declare "done" upfront. Building incrementally means fewer surprises.

3. **Automated Risk Detection**: SPOF detection, blast radius, compliance rules—no manual review needed.

4. **Reproducible Governance**: Gates enforce phase ordering; compliance rules are declarative, not tribal knowledge.

5. **Scaling**: Works from 5 to thousands of resources (tested to 1000 nodes).

## File Structure

- `supply.cue` - Main example (package main)
  - `_parts` - Resource definitions
  - `graph` - Typed dependency graph
  - `cpm` - Critical path analysis
  - `spof` - Single points of failure detection
  - `_charter` - BOM phase gates
  - `gaps` - Gap analysis (what's missing vs. charter)
  - `compliance` - Domain-specific validation rules
  - `summary` - Executive summary

## Patterns Used

- `patterns.#Graph` - Core dependency graph
- `patterns.#CriticalPath` - CPM scheduling
- `patterns.#SinglePointsOfFailure` - Risk detection
- `patterns.#ComplianceCheck` - Rule validation
- `charter.#Charter` - Phase gate declarations
- `charter.#GapAnalysis` - Charter satisfaction analysis

## Extending the Example

To model a real supply chain:

1. Replace `_parts` with actual BOM data (from CSV, JSON, ERP export)
2. Add `supplier` metadata for sourcing analysis
3. Add `cost` field and compute total landed cost
4. Add `quality_rate` to compute defect impact
5. Compose with `patterns.#BlastRadius` for "what if supplier X fails?"
6. Export to JSON-LD for knowledge graph integration

See `/home/mthdn/apercue/patterns/` for the complete pattern library.
