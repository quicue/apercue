# Course Prerequisites

University degree requirements as a typed dependency graph. 12 courses across
4 types (CoreCourse, Elective, LabCourse, Seminar) with prerequisite edges and
a 3-gate charter tracking degree completion.

## Run

```bash
cue eval ./examples/course-prereqs/ -e summary
cue eval ./examples/course-prereqs/ -e gaps.complete
cue eval ./examples/course-prereqs/ -e cpm.summary
cue export ./examples/course-prereqs/ -e gaps.shacl_report --out json
cue export ./examples/course-prereqs/ -e cpm.time_report --out json
```

## What it demonstrates

- Charter with 3 gates (first-year, second-year, graduation)
- SHACL gap analysis -- which courses are missing for each gate
- OWL-Time scheduling -- critical path through the prerequisite chain
- Domain-agnostic proof: courses are just resources with `depends_on`
