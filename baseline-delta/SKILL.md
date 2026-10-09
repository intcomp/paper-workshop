---
name: baseline-delta
description: Implements a research method as a clean, reviewable delta on a pinned, widely-used baseline. The baseline is a git submodule that is never edited in place; changes go in as hooks, or as saved patches when hooks cannot work. Every change is smoke-tested on real data, and a Makefile automates patching and testing. Use when implementing or modifying a method on top of an existing model or codebase.
---

# Baseline Delta

Implement the method as a small **delta** on a trusted baseline. The baseline stays identical to a pinned upstream commit; our hooks, patches, tests, and configs live in our own repo. This keeps the implementation clean, and reviewers (human or agent) review only the delta, never the battle-tested baseline.

## 1. Baseline

- Pick the official or most widely used implementation that many papers compare against, with released checkpoints and a compatible license. If the choice is unclear, present the candidates to the user.
- Pin a tag or commit as a git submodule.
- Reproduce one reported result (e.g. evaluate a released checkpoint) before changing anything.

```text
project/
├── third_party/<baseline>/   # submodule, pinned, never committed to
├── patches/<baseline>/       # 0001-<what>.patch, ... applied in order
├── src/<project>/hooks/      # our hooks, modules, losses, entry points
├── tests/smoke/
├── configs/
├── data/samples/             # small real subset, or fetch script with checksums
└── Makefile
```

## 2. Modification Ladder

Use the first level that works.

**Level 0: Extension points.** Configs, registries, subclassing, composition.

**Level 1: Hooks.** `torch.nn.utils.parametrize`, forward (pre-)hooks, module replacement via `setattr`, or wrapping a function at one explicit install point. Example: pruning by masking weights in forward:

```python
import torch.nn as nn
from torch.nn.utils import parametrize

class ApplyMask(nn.Module):
    def __init__(self, mask):
        super().__init__()
        self.register_buffer("mask", mask)

    def forward(self, w):
        return w * self.mask

def install_pruning(model, masks):  # {module_name: mask shaped like weight}
    modules = dict(model.named_modules())
    assert masks.keys() <= modules.keys(), f"missing: {masks.keys() - modules.keys()}"
    for name, mask in masks.items():
        parametrize.register_parametrization(modules[name], "weight", ApplyMask(mask))
```

- Install through an explicit `install_<feature>(model, cfg)`, never on import.
- Assert every target was found, so a typo or baseline upgrade cannot cause a silent no-op.
- Keep hooks idempotent and removable.

**Level 2: Patches,** only when a hook cannot express the change (e.g. control flow inside a function, data pipeline internals).

1. `make apply`: reset to the pinned baseline and re-apply existing patches as local commits, so new edits stack on them (`save-patches` re-exports everything after the pinned commit).
2. Edit in the submodule, with one local commit per concern.
3. `make save-patches`: export the commits to `patches/`.
4. `make test`: reset, re-apply all patches from scratch, and run smoke tests. This proves the patch files alone reproduce the change.
5. Commit the patches with their tests.

Keep patches minimal: no reformatting or drive-by edits. Move nontrivial logic to `src/` and make the patch a thin call into it. The submodule shows as modified in the top-level repo; stage its pointer only when upgrading the baseline.

## 3. Smoke Tests

Make one change, test it, commit it. Never build on an untested change; errors must not accumulate.

**Data:**
- Use real dataset samples and real pretrained weights.
- Use random or dummy inputs only when no real data exists, and state it in the test.

**For every modified module,** run the original and modified models on the same inputs, capturing intermediates with forward hooks:

| Test | Check |
|---|---|
| No-op equivalence | Delta neutralized (all-ones mask, flag off) → outputs match the baseline |
| Upstream unchanged | Activations before the modified module are identical |
| Local correctness | Modified output matches an independent reference computation |
| Downstream | Shapes, dtypes, finiteness, expected properties (e.g. sparsity) |
| Gradients | Flow and blocking are exactly as intended |
| End to end | Real samples run through; a tiny batch overfits; small-subset metric is plausible |

When comparing numbers, use `eval()`, fixed seeds, fp32, and deterministic ops. State each tolerance.

## 4. Makefile

```make
BASELINE  := third_party/baseline
PATCH_DIR := patches/baseline
# pinned commit recorded in the top-level repo
BASE      := $(shell git ls-tree HEAD $(BASELINE) | awk '{print $$3}')
PYTHON    ?= python
GIT_ID    := -c user.name=baseline-delta -c user.email=baseline-delta@localhost

.PHONY: init reset apply save-patches smoke test

init:
	git submodule update --init --recursive
	$(MAKE) apply

reset:         # discards uncommitted edits in the submodule
	git -C $(BASELINE) checkout -q --detach --force $(BASE)
	git -C $(BASELINE) clean -fd

apply: reset
	@for p in $(sort $(wildcard $(PATCH_DIR)/*.patch)); do \
	  git -C $(BASELINE) $(GIT_ID) am --quiet "$(CURDIR)/$$p" || exit 1; done

save-patches:
	@git -C $(BASELINE) diff --quiet HEAD || { echo "commit edits in $(BASELINE) first"; exit 1; }
	rm -f $(PATCH_DIR)/*.patch && mkdir -p $(PATCH_DIR)
	git -C $(BASELINE) format-patch --zero-commit --no-signature -o "$(CURDIR)/$(PATCH_DIR)" $(BASE)..HEAD

smoke:
	$(PYTHON) -m pytest tests/smoke -x -q

test: apply smoke
```

## 5. Rules

- **Review scope** is the top-level diff only: `src/`, `patches/`, `tests/`, `configs/`. Read baseline code only where a hook or patch touches it.
- **Each commit** holds one feature with its tests, and `make test` passes.
- **To upgrade the baseline,** bump the submodule in its own commit, then fix patch conflicts and hook assertions until `make test` passes.
- **Never:**
  - edit the baseline without saving a patch;
  - copy baseline code into `src/` to modify it;
  - commit untested changes.

**Final reply:** report the baseline and its pinned commit, each hook and patch in one line, the tests run with their results and data source (real or dummy), and anything left untested.
