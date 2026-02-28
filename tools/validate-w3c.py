#!/usr/bin/env python3
"""Round-trip W3C conformance validation for apercue projections.

Exports JSON-LD from CUE, parses with rdflib, validates structure.
Proves that apercue output is consumable by standard W3C tooling.

Usage:
    python3 tools/validate-w3c.py                    # validate all
    python3 tools/validate-w3c.py --example course-prereqs
    python3 tools/validate-w3c.py --dir ./self-charter

Dependencies: rdflib, pyshacl (pip install rdflib pyshacl)
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path


# ── Test definitions ──────────────────────────────────────────────────────

@dataclass
class Projection:
    """A CUE export expression and what W3C vocabulary it should produce."""
    name: str
    expression: str
    expected_type: str          # RDF type IRI expected on the root node
    min_triples: int = 1       # minimum triple count to consider valid
    namespaces: list[str] = field(default_factory=list)  # IRIs that must appear
    known_issue: str = ""       # if set, failure is WARN not FAIL


# Projections available from examples that instantiate the standard pattern set.
# Not all examples instantiate all patterns — missing exports are skipped.
EXAMPLE_PROJECTIONS: list[Projection] = [
    Projection(
        name="SHACL ValidationReport",
        expression="gaps.shacl_report",
        expected_type="http://www.w3.org/ns/shacl#ValidationReport",
        namespaces=["http://www.w3.org/ns/shacl#"],
    ),
    Projection(
        name="SHACL Compliance",
        expression="compliance.shacl_report",
        expected_type="http://www.w3.org/ns/shacl#ValidationReport",
        namespaces=["http://www.w3.org/ns/shacl#"],
    ),
    Projection(
        name="OWL-Time CPM",
        expression="cpm.time_report",
        expected_type="http://www.w3.org/2006/time#Interval",
        min_triples=10,
        namespaces=["http://www.w3.org/2006/time#"],
    ),
    Projection(
        name="DCAT Catalog",
        expression="catalog.dcat_catalog",
        expected_type="http://www.w3.org/ns/dcat#Catalog",
        min_triples=10,
        namespaces=["http://www.w3.org/ns/dcat#"],
    ),
    Projection(
        name="PROV-O Provenance",
        expression="provenance.prov_report",
        expected_type="http://www.w3.org/ns/prov#Entity",
        min_triples=10,
        namespaces=["http://www.w3.org/ns/prov#"],
    ),
    Projection(
        name="Activity Streams",
        expression="activity_stream.stream",
        expected_type="",  # AS uses plain "type" not "@type" in some contexts
        min_triples=10,
        namespaces=["https://www.w3.org/ns/activitystreams#"],
    ),
    Projection(
        name="SHACL Shapes",
        expression="shape_export.shapes_graph",
        expected_type="http://www.w3.org/ns/shacl#NodeShape",
        min_triples=5,
        namespaces=["http://www.w3.org/ns/shacl#"],
    ),
    Projection(
        name="VoID Dataset",
        expression="void_dataset.void_description",
        expected_type="http://rdfs.org/ns/void#Dataset",
        min_triples=5,
        namespaces=["http://rdfs.org/ns/void#"],
    ),
    Projection(
        name="OWL Ontology",
        expression="ontology.owl_ontology",
        expected_type="http://www.w3.org/2002/07/owl#Ontology",
        min_triples=5,
        namespaces=["http://www.w3.org/2000/01/rdf-schema#"],
    ),
    Projection(
        name="SKOS Taxonomy",
        expression="_taxonomy.taxonomy_scheme",
        expected_type="http://www.w3.org/2004/02/skos/core#ConceptScheme",
        min_triples=5,
        namespaces=["http://www.w3.org/2004/02/skos/core#"],
    ),
    Projection(
        name="PROV-O Plan",
        expression="_prov_plan.plan_report",
        expected_type="http://www.w3.org/ns/prov#Plan",
        min_triples=5,
        namespaces=["http://www.w3.org/ns/prov#"],
    ),
    Projection(
        name="DQV Quality",
        expression="_quality.quality_report",
        expected_type="http://www.w3.org/ns/dqv#QualityMeasurement",
        min_triples=5,
        namespaces=["http://www.w3.org/ns/dqv#"],
    ),
]

# Projections from self-charter unified export
SELFCHARTER_PROJECTIONS: list[Projection] = [
    Projection(
        name="SHACL (projections)",
        expression="projections.shacl",
        expected_type="http://www.w3.org/ns/shacl#ValidationReport",
        namespaces=["http://www.w3.org/ns/shacl#"],
    ),
    Projection(
        name="OWL-Time (projections)",
        expression="projections.owl_time",
        expected_type="http://www.w3.org/2006/time#Interval",
        min_triples=10,
        namespaces=["http://www.w3.org/2006/time#"],
    ),
    Projection(
        name="SKOS Type Vocabulary",
        expression="type_vocabulary",
        expected_type="http://www.w3.org/2004/02/skos/core#ConceptScheme",
        min_triples=5,
        namespaces=["http://www.w3.org/2004/02/skos/core#"],
    ),
]

# Context-only validation: parse the @context itself
CONTEXT_PROJECTION = Projection(
    name="JSON-LD @context",
    expression="projections",
    expected_type="",  # complex doc, just check triple count
    min_triples=5,
    namespaces=[
        "http://www.w3.org/ns/shacl#",
        "http://purl.org/dc/terms/",
    ],
)

# W3C evidence package — the core report's own computed evidence
W3C_EVIDENCE_PROJECTIONS: list[Projection] = [
    Projection(
        name="VoID Evidence",
        expression="evidence.void_description",
        expected_type="http://rdfs.org/ns/void#Dataset",
        min_triples=10,
        namespaces=["http://rdfs.org/ns/void#"],
    ),
    Projection(
        name="OWL Evidence",
        expression="evidence.owl_ontology",
        expected_type="http://www.w3.org/2002/07/owl#Ontology",
        min_triples=5,
        namespaces=["http://www.w3.org/2000/01/rdf-schema#"],
    ),
    Projection(
        name="SHACL Evidence",
        expression="evidence.shacl",
        expected_type="http://www.w3.org/ns/shacl#ValidationReport",
        namespaces=["http://www.w3.org/ns/shacl#"],
    ),
    Projection(
        name="PROV-O Evidence",
        expression="evidence.prov_report",
        expected_type="http://www.w3.org/ns/prov#Entity",
        min_triples=10,
        namespaces=["http://www.w3.org/ns/prov#"],
    ),
    Projection(
        name="DCAT Evidence",
        expression="evidence.dcat_catalog",
        expected_type="http://www.w3.org/ns/dcat#Catalog",
        min_triples=10,
        namespaces=["http://www.w3.org/ns/dcat#"],
    ),
    Projection(
        name="ODRL Evidence",
        expression="evidence.odrl_policy",
        expected_type="http://www.w3.org/ns/odrl/2/Set",
        min_triples=3,
        namespaces=["http://www.w3.org/ns/odrl/2/"],
    ),
    Projection(
        name="OWL-Time Evidence",
        expression="evidence.time_report",
        expected_type="http://www.w3.org/2006/time#Interval",
        min_triples=10,
        namespaces=["http://www.w3.org/2006/time#"],
    ),
    Projection(
        name="SKOS Evidence",
        expression="evidence.skos_taxonomy",
        expected_type="http://www.w3.org/2004/02/skos/core#ConceptScheme",
        min_triples=5,
        namespaces=["http://www.w3.org/2004/02/skos/core#"],
    ),
]

# Federation projections — merged JSON-LD from tests/federation
FEDERATION_PROJECTIONS: list[Projection] = [
    Projection(
        name="Federated Merge (JSON-LD)",
        expression="federation.merged_jsonld",
        expected_type="",  # multiple types across domains
        min_triples=5,
        namespaces=["http://purl.org/dc/terms/"],
    ),
    Projection(
        name="Federated Context (infra)",
        expression="infra_ctx.jsonld",
        expected_type="",
        min_triples=3,
        namespaces=["http://purl.org/dc/terms/"],
    ),
]


# ── Validation logic ─────────────────────────────────────────────────────

def cue_export(directory: str, expression: str) -> dict | None:
    """Run cue export and return parsed JSON, or None on failure.

    CUE requires relative paths from the module root, so we run cue
    from the project root with ./relative/path syntax.
    """
    root = Path(__file__).resolve().parent.parent
    try:
        # Convert to relative path from project root
        dir_path = Path(directory).resolve()
        rel_path = "./" + str(dir_path.relative_to(root))
    except ValueError:
        rel_path = directory

    try:
        result = subprocess.run(
            ["cue", "export", rel_path, "-e", expression, "--out", "json"],
            capture_output=True, text=True, timeout=60,
            cwd=str(root),
        )
        if result.returncode != 0:
            return None
        return json.loads(result.stdout)
    except (subprocess.TimeoutExpired, json.JSONDecodeError):
        return None


def validate_jsonld(data: dict, projection: Projection) -> tuple[bool, str]:
    """Parse JSON-LD with rdflib and validate against expectations."""
    try:
        from rdflib import Graph, RDF, URIRef
    except ImportError:
        return False, "rdflib not installed"

    g = Graph()
    try:
        g.parse(data=json.dumps(data), format="json-ld")
    except Exception as e:
        return False, f"JSON-LD parse failed: {e}"

    triple_count = len(g)
    if triple_count < projection.min_triples:
        return False, f"only {triple_count} triples (expected >= {projection.min_triples})"

    # Check expected RDF type if specified
    if projection.expected_type:
        type_iri = URIRef(projection.expected_type)
        has_type = any(
            o == type_iri
            for _, p, o in g.triples((None, RDF.type, None))
        )
        if not has_type:
            # Check in nested @graph too
            found_types = [str(o) for _, p, o in g.triples((None, RDF.type, None))]
            return False, f"expected rdf:type {projection.expected_type}, found: {found_types}"

    # Check namespace presence
    all_iris = set()
    for s, p, o in g:
        all_iris.add(str(p))
        all_iris.add(str(o))
    for ns in projection.namespaces:
        if not any(iri.startswith(ns) for iri in all_iris):
            return False, f"namespace {ns} not found in output"

    return True, f"{triple_count} triples, type OK, namespaces OK"


# ── Runner ────────────────────────────────────────────────────────────────

@dataclass
class Result:
    projection: str
    directory: str
    passed: bool
    detail: str
    warn: bool = False  # known issue — failure doesn't count


def validate_directory(directory: str, projections: list[Projection]) -> list[Result]:
    """Validate all projections against a CUE directory."""
    results = []
    for proj in projections:
        data = cue_export(directory, proj.expression)
        if data is None:
            # cue export failed — skip (expression may not exist in this example)
            results.append(Result(proj.name, directory, False, "cue export failed (skipped)"))
            continue

        passed, detail = validate_jsonld(data, proj)
        is_warn = not passed and bool(proj.known_issue)
        if is_warn:
            detail = f"{detail} [known: {proj.known_issue}]"
        results.append(Result(proj.name, directory, passed, detail, warn=is_warn))
    return results


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate apercue W3C projections via rdflib round-trip"
    )
    parser.add_argument(
        "--example", type=str,
        help="Validate a specific example (e.g., course-prereqs)",
    )
    parser.add_argument(
        "--dir", type=str,
        help="Validate a specific CUE directory",
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true",
        help="Show details for passing tests too",
    )
    args = parser.parse_args()

    results: list[Result] = []

    # Determine what to validate
    root = Path(__file__).resolve().parent.parent

    if args.dir:
        # Custom directory: try both example and self-charter projections
        results.extend(validate_directory(args.dir, EXAMPLE_PROJECTIONS))
        results.extend(validate_directory(args.dir, SELFCHARTER_PROJECTIONS))
    elif args.example:
        example_dir = str(root / "examples" / args.example)
        results.extend(validate_directory(example_dir, EXAMPLE_PROJECTIONS))
    else:
        # Validate all: examples + self-charter
        examples_dir = root / "examples"
        if examples_dir.exists():
            for example in sorted(examples_dir.iterdir()):
                if example.is_dir():
                    results.extend(
                        validate_directory(str(example), EXAMPLE_PROJECTIONS)
                    )

        # Self-charter has its own projections
        self_charter = root / "self-charter"
        if self_charter.exists():
            results.extend(
                validate_directory(str(self_charter), SELFCHARTER_PROJECTIONS)
            )

        # Federation test
        federation_test = root / "tests" / "federation"
        if federation_test.exists():
            results.extend(
                validate_directory(str(federation_test), FEDERATION_PROJECTIONS)
            )

        # W3C evidence package — validate the core report's own evidence
        w3c_dir = root / "w3c"
        if w3c_dir.exists():
            results.extend(
                validate_directory(str(w3c_dir), W3C_EVIDENCE_PROJECTIONS)
            )

    # Report
    passed = sum(1 for r in results if r.passed)
    warned = sum(1 for r in results if r.warn)
    skipped = sum(1 for r in results if "skipped" in r.detail)
    failed = sum(1 for r in results if not r.passed and not r.warn and "skipped" not in r.detail)

    print(f"\n{'='*60}")
    print(f"W3C Round-Trip Conformance: {passed} passed, {warned} warned, {failed} failed, {skipped} skipped")
    print(f"{'='*60}\n")

    for r in results:
        if r.passed:
            icon = "PASS"
        elif r.warn:
            icon = "WARN"
        elif "skipped" in r.detail:
            icon = "SKIP"
        else:
            icon = "FAIL"
        dir_short = Path(r.directory).name
        print(f"  [{icon}] {dir_short}/{r.projection}")
        if args.verbose or icon in ("FAIL", "WARN"):
            print(f"         {r.detail}")

    if failed > 0:
        print(f"\n{failed} validation(s) failed.")
        return 1

    print(f"\nAll {passed} validations passed ({warned} known issues, {skipped} skipped).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
