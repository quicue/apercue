# Project Tracker

Software release tracked as a typed dependency graph. 10 tasks with status
tracking via `schema:actionStatus` and milestone evaluation via charter gates.

## Run

```bash
cue eval ./examples/project-tracker/ -e summary
cue eval ./examples/project-tracker/ -e gaps.summary
cue eval ./examples/project-tracker/ -e cpm.summary
cue export ./examples/project-tracker/ -e gaps --out json
```

## What it demonstrates

- Status tracking -- tasks have `status: "done"` or `status: "active"`
- Charter gap analysis -- which tasks remain for each milestone
- Self-hosting pattern: track project work using the same charter
  pattern the project implements
