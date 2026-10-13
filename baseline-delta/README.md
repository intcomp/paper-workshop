# Baseline Delta

Implement a research method as a clean, reviewable **delta** on top of a pinned, widely-used baseline, instead of editing someone else's code in place.

- **Baseline untouched**: the baseline is a git submodule pinned to an upstream commit and never edited in place.
- **Hooks first, patches second**: changes go in as runtime hooks (e.g. a pruning mask via `parametrize`), or as saved `.patch` files when hooks cannot express them.
- **Tested step by step**: every modified module is smoke-tested against the original model, on real data whenever possible, so errors never accumulate.
- **Automated**: `make test` resets the baseline, re-applies all patches from scratch, and runs the smoke tests.

The result is a clean, professional implementation, and reviewers (human or agent) only need to read the delta (`src/`, `patches/`, `tests/`), not the battle-tested baseline.

## Usage

Tell the agent what method to implement, which baseline to build on (or ask it to propose candidates), and what data is available for testing.

### English example

```text
/baseline-delta

Method: structured pruning of attention heads in ViT-B/16
Baseline: timm (pin a release tag)
Test data: a few real samples from ImageNet val at /data/imagenet/val
Project directory: /path/to/project
```

### 中文示例

```text
/baseline-delta

方法：对 ViT-B/16 的注意力头做结构化剪枝
Baseline：timm（固定到某个 release tag）
测试数据：ImageNet val 中的少量真实样本，路径 /data/imagenet/val
项目目录：/path/to/project
```

### If you don't know which baseline to use

```text
Propose 2–3 widely-used baselines for this task with their trade-offs, and let me choose before implementing.
```

```text
请先为这个任务推荐 2–3 个被广泛使用的 baseline 并说明各自优缺点，等我选定后再开始实现。
```

In Codex, invoke the skill with `$baseline-delta`.
