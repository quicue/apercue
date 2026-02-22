# GC LLM Governance Dashboard — Full W3C Projection Viewer

**Date:** 2026-02-21
**Status:** Approved
**Audience:** All (TBS/OCIO auditors, internal team, demo/showcase)

## Problem

gc-governance.html visualizes 1 of 8 available W3C projections. The dependency graph is shown, but ODRL policies, PROV-O provenance chains, DCAT catalog entries, VC credentials, SKOS vocabulary, OWL-Time scheduling, and SHACL compliance data are exported but invisible. Policy facts and authoritative sources have no visual representation at all.

## Design

### Layout

Three-column, tabbed right panel:

```
┌─────────┬──────────────────────────┬───────────┐
│ sidebar │     D3 graph (always)    │ tab panel │
│ 280px   │     flex                 │ 340px     │
│         │                          │ collapsible│
│ gates   │     52 nodes             │ [Comply]  │
│ metrics │     59 edges             │ [Schedule]│
│ legend  │                          │ [Policies]│
│         │                          │ [Prov]    │
│         │                          │ [Facts]   │
│         │                          │ [Catalog] │
│         │                          │ [Vocab]   │
└─────────┴──────────────────────────┴───────────┘
```

- Graph always visible, never replaced
- Tab panel collapses via toggle button (graph gets full width)
- URL hash routing: `#compliance`, `#schedule`, etc.

### Data Sources

- `data/gc-llm-governance.json` — graph viz (existing, already loaded)
- `data/gc-llm-governance-projections.json` — all 7 W3C projections (existing, already exported)

No new CUE exports needed.

### Tab 1: Compliance (SHACL + VC 2.0)

- Pass/fail badge: green checkmark or red X
- `sh:conforms` status line
- 6 compliance rules listed with pass/fail dot indicators
- VC credential card: issuer, validFrom, subject, violation count
- Expandable violation detail rows if any exist

Data: `projections.shacl` + `projections.vc`

### Tab 2: Schedule (OWL-Time + CPM)

- 4 metrics: total duration (10 days), critical nodes (14), max slack (7), SPOF (17)
- Mini Gantt chart: horizontal bars per resource, phase-colored, critical path green
- Slack histogram: bar chart of float distribution
- Scrollable, sorted by earliest start

Data: `projections.owl_time` + `projections.scheduling`

### Tab 3: Policies (ODRL 2.2)

- 3-column comparison matrix:

| | Unclassified | Protected A | Protected B |
|---|---|---|---|
| Permitted | Commercial LLMs | GC-controlled | GC cloud + PII block |
| Prohibited | Protected data | Commercial LLMs | Commercial LLMs |
| Obligations | Audit | Audit + review | Audit + review + gate |
| Deadline | 2026-06-24 | 2026-06-24 | 2026-06-24 |

- Click cell to expand raw ODRL JSON-LD

Data: `projections.odrl`

### Tab 4: Provenance (PROV-O)

- Chain diagram: Sources (8) → Activity → Facts (12)
- Click fact to see source, citation, confidence
- Agents at top (governance-framework, TBS)
- Vertical chain with connectors (not full D3 force graph)

Data: `projections.prov`

### Tab 5: Knowledge (Policy Facts + Sources)

- Two sub-sections with toggle:
  - Facts (12 rows): claim, source ref, citation, confidence badge, lang
  - Sources (8 rows): title (linked URL), publisher, format, lang, dates

Data: `projections.prov` (entities contain derivation + attribution data)

### Tab 6: Catalog (DCAT 3)

- 3 deployment cards:
  - Procurement Assistant: keywords, conformance refs
  - HR Assistant: keywords, conformance refs
  - Internal Knowledge Search: keywords, conformance refs
- Each card shows which Directive/Act it conforms to

Data: `projections.dcat`

### Tab 7: Vocabulary (SKOS)

- 25 type definitions as compact glossary
- Grouped by the 8 legend categories
- Type name, definition, concept URI
- Replaces static color legend with live taxonomy

Data: `projections.skos`

### Interactions

- **Graph → Tab**: clicking a graph node opens the relevant tab and highlights the corresponding row/card
- **Tab → Graph**: hovering a tab item highlights the graph node with a pulse ring
- **Tab collapse**: toggle button hides panel, graph fills width
- **URL hash**: `#compliance`, `#schedule`, `#policies`, `#provenance`, `#knowledge`, `#catalog`, `#vocabulary`

### Metric Tiles (sidebar additions)

Add to existing 4 metrics:
- Compliance: 6/6 (with pass/fail color)
- SPOF: 17 (with warning color if >0)
- Work Days: 10
- Max Slack: 7

### Style

- Same dark theme, Atkinson Hyperlegible fonts
- Tab buttons: pill-shaped, phase-colored active indicator
- Tables: compact mono, alternating row shading
- Cards: bordered, type-colored left accent
- Gantt bars: phase-colored, critical path animated pulse
- All consistent with existing site pages

## Implementation Notes

- Single HTML file modification (gc-governance.html)
- No new CUE code, no new exports
- Second fetch for projections JSON on page load
- D3 for Gantt chart and provenance chain; plain DOM for tables/cards
- Progressive: tabs render on first click (lazy), not all at load time
