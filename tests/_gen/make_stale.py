"""Generate tests/stale-precompute/<case>/ packages: a diamond-ladder graph
with a correct precompute from tools/toposort.py, then one corruption per
case. Every case must be rejected by cue vet. Also writes ok/ (must pass).

Run from the repo root: python3 tests/_gen/make_stale.py"""
import copy, json, os, sys
sys.path.insert(0, "tools")
from toposort import toposort, compute_ancestors, compute_dependents  # noqa

def ladder(n):
    # width-2 diamond ladder: a_i, b_i both depend on a_{i-1}, b_{i-1}
    res = {}
    for i in range(n):
        for s in "ab":
            name = f"{s}{i}"
            deps = {f"a{i-1}": True, f"b{i-1}": True} if i else {}
            res[name] = {"name": name, "@type": {"Step": True}, **({"depends_on": deps} if deps else {})}
    return res

def precompute(res):
    order, depth = toposort(res)
    anc = compute_ancestors(res, order)
    return {"depth": depth, "ancestors": anc, "dependents": compute_dependents(anc)}

def write(case, inp, pre, comment):
    d = os.path.join("tests", "stale-precompute", case)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "test.cue"), "w") as f:
        f.write(f"// {comment}\npackage test\n\nimport \"apercue.ca/patterns@v0\"\n\n")
        f.write("g: patterns.#GraphLite & {\n")
        f.write("\tInput: " + json.dumps(inp, indent=1).replace("\n", "\n\t") + "\n")
        f.write("\tPrecomputed: " + json.dumps(pre, indent=1).replace("\n", "\n\t") + "\n}\n")

inp = ladder(6)
good = precompute(inp)
write("ok", inp, good, "Correct precompute: cue vet must pass.")

m = copy.deepcopy(good)  # the todo repro: drop one node from every ancestor set
for k in m["ancestors"]:
    m["ancestors"][k].pop("a0", None)
write("ancestor-dropped", inp, m, "a0 removed from every ancestor set: must be rejected.")

m = copy.deepcopy(good)
m["ancestors"]["a5"]["zz"] = True
write("ancestor-extra", inp, m, "a5 claims a non-existent ancestor: must be rejected.")

m = copy.deepcopy(good)
m["depth"]["b3"] += 1
write("depth-wrong", inp, m, "b3 depth off by one: must be rejected.")

m = copy.deepcopy(good)
m["dependents"]["a0"].pop("b5")
write("dependents-not-inverse", inp, m, "dependents is not the inverse of ancestors: must be rejected.")

m = copy.deepcopy(good)
del m["ancestors"]["b2"]
write("ancestor-missing-node", inp, m, "b2 has no ancestor entry: must be rejected.")

i2 = copy.deepcopy(inp)
i2["b5"]["depends_on"]["a4"] = True  # edge added after the precompute ran
i2["a2"]["depends_on"] = {"a1": True}  # edge removed
write("stale-after-edit", i2, good, "Graph edited after precompute: must be rejected.")
