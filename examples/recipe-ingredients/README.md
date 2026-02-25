# Recipe Ingredients

Beef bourguignon as a typed dependency graph. 17 steps across ingredient prep,
cooking stages, and assembly. Dependencies encode what must happen before what.

## Run

```bash
cue eval ./examples/recipe-ingredients/ -e gap_summary
cue eval ./examples/recipe-ingredients/ -e cpm.summary
cue eval ./examples/recipe-ingredients/ -e cpm.critical_sequence
```

## What it demonstrates

- Critical path analysis -- which steps determine total cooking time
- Topological layering -- parallel prep steps vs sequential cooking
- The same `#CriticalPath` pattern used for infrastructure scheduling works
  for recipe execution order
