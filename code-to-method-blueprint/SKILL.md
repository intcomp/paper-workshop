---
name: code-to-method-blueprint
description: Reconstructs research code into a detailed, code-grounded Markdown method blueprint covering tensor shapes, step-by-step computations, formulas, losses, training and inference procedures, Mermaid flowcharts, pseudocode, and file:line evidence. Use when a researcher wants to document what their implementation actually computes, reverse-engineer a method from a codebase, or prepare the technical basis for a paper's Method section.
---

# Code to Method Blueprint

Produce a Markdown specification of the method that a given experiment actually executes. A reader should be able to follow it from raw inputs to final outputs and reimplement the core algorithm without opening the code.

This is not a repository tour, a line-by-line code translation, or the paper itself. Organize the document around the real execution path, and expand core computations down to individual operations, dimensions, and element correspondences.

Write the document in the language the user requests, or otherwise in the language of their request. Keep code identifiers, paths, and config keys verbatim.

## Inputs

| Item | Handling |
|---|---|
| Code location | Required. Ask only if it is neither given nor identifiable from the workspace. |
| Research problem, modules of interest | Use if given; otherwise describe the computational task from the implementation alone. |
| Train / inference / evaluation entry points | Confirm through launch scripts and call graphs. |
| Run command, config, model version | Prefer actual experiment records (logs, saved configs, checkpoints). Defaults are not the experiment configuration. |
| Output path | Use the given path; otherwise write `method_blueprint.md` to a suitable location in the workspace. |

If several method versions could be the target, describe each candidate path separately and mark the target as pending confirmation. Never merge different implementations into one method.

By default, only read code and write the document: do not modify the algorithm, run full training, install dependencies, or download large weights unless the user authorizes it.

## Evidence Rules

Tag non-obvious statements with one of:

- **[Fact]** — supported by code, configuration, or runtime output you actually inspected.
- **[Inference]** — an interpretation or likely motivation; never present it as the authors' confirmed intent.
- **[Unconfirmed]** — the implementation, effective config, or records are missing, so it cannot be determined.

Rules:

- Cite `path/to/file.py:LINE` plus the class/function for every key operation, loss, branch, and parameter. Line numbers must come from this inspection, never from memory.
- The run command, config override order, and call graph determine the executed path. Comments, READMEs, and existing papers are supporting evidence only; when they conflict with the code, report the conflict and document the code's behavior.
- When an external library performs a core operation, read its source for the installed version if possible; otherwise state the interface, version, and what remains unknown.
- Never fill gaps with "common practice". Do not invent steps, results, performance claims, novelty, or theoretical guarantees. Record suspected bugs as implemented, with their effect, rather than silently substituting the intended algorithm.
- Use stable section numbers and equation/algorithm labels so the paper can reference them.

## Workflow

1. **Scope**: Identify entry points, configs, launch scripts, and experiment records. Note commit hash, uncommitted changes, key dependency versions, and where each important config value comes from.
2. **Trace**: Follow data loading → preprocessing → batching → model construction → forward → loss → update; then trace inference, post-processing, and evaluation separately. Keep running notes of symbols, shapes, branch conditions, parameter sharing, disabled modules, and evidence.
3. **Write**: Produce the sections below. Fully expand the core path. For structurally repeated modules, expand one instance and state the repeat count, sharing, and differences. Skip logging, error handling, and boilerplate.
4. **Verify and save**: See *Verification*.

## Document Structure

Sections may be merged when the method warrants it. If an item genuinely does not apply, say why in one line; if its code is missing, mark it [Unconfirmed].

### 1. Overview and Scope

Code location, version, entry points, run command, and analysis limitations. The computational problem, what one sample or request represents, inputs and final outputs, and the main stages. Separate implemented functionality from unconfirmed research motivation.

### 2. Notation

| Symbol | Code variable | Meaning | Shape | dtype | Evidence |
|---|---|---|---|---|---|

Define every dimension symbol once and use it consistently. Specify axis order, dynamic vs. fixed sizes, and non-tensor structures (lists, dicts, tuples, sparse formats). State value ranges, coordinate systems, units, padding, mask polarity, and valid-length conventions. Keep unknown sizes symbolic.

### 3. Data and Preprocessing

Loading, filtering, splitting, sampling, augmentation, normalization, tokenization, sorting, truncation, padding, label construction, and batch collation. List every field at the model input with its semantics, shape, and dtype. For operations that reorder elements or change coordinates, give the index mapping. Note train/val/test differences. For precomputed features, give their source, or state that the generation code is unavailable.

### 4. Forward Computation

For each method-relevant step, in execution order:

- **Purpose and evidence** — what is computed, and where.
- **Inputs** — variables, symbols, shapes, semantics.
- **Parameters and state** — learnable parameters with shapes, hyperparameters, buffers, caches, initialization, freezing, sharing.
- **Computation** — the operations in order, with formulas that match the implementation exactly; define every symbol and reduction axis.
- **Intermediate shapes** — every dimension change.
- **Output** — meaning and the step it feeds.
- **Conditions** — branches, loops, empty or variable-length inputs, numerical-stability terms.
- **Gradients** — `detach`, `no_grad`, non-differentiable selection, and the resulting gradient flow, where relevant.

Required depth by operation type:

| Operation | Must specify |
|---|---|
| Fusion | Add / concat / gate / weighted sum; dimensions; source of weights; normalization |
| Attention | Q/K/V sources and projections, head split, scaling, mask semantics, softmax axis, output projection |
| Pooling, normalization | Reduction axes, which elements count, denominator, epsilon, `keepdim` |
| Indexing, selection | Ranking criterion, top-k or threshold, tie handling (if determinable), how indices are applied to other tensors |
| reshape / permute / broadcast / einsum / gather / scatter | Element correspondence, broadcast axes, indexing rule — input and output shapes alone are insufficient |
| Iteration, recurrence | Update order, stopping condition, state and parameter sharing across steps |

Example of the expected precision: for `z = (h * m[..., None]).sum(1) / m.sum(1).clamp_min(1)[:, None]` with `h: [B, L, D]` and `m: [B, L]`, explain that `m` broadcasts over `D`, the sum runs over `L`, and the denominator (count of valid positions) is clamped to at least 1, giving `z: [B, D]`. Confirm from the code whether `m = 1` means valid or padded. "Masked mean pooling" alone is not enough.

### 5. Losses and Training

For each loss term: inputs, targets, exact formula, reduction, masking, weighting, and denominator; then how the terms combine. Describe gradient paths to each parameter group, frozen modules, training stages, and update order. Record the effective optimizer, learning-rate schedule, and any gradient accumulation, clipping, mixed precision, EMA, or alternating updates, keeping method-defining choices separate from experimental settings. If no training code exists, say so.

### 6. Inference and Evaluation

The full path from inputs to scores, probabilities, labels, coordinates, or sequences, including thresholds, ranking, decoding, sampling, NMS, aggregation, and output format. State every difference from training and how model outputs are converted into metric inputs. Flag any dependence on labels or train-only information as [Unconfirmed] for the user to check, without asserting leakage.

### 7. Shape Trace

| Stage | Variable / symbol | Operation | Input shape | Output shape | Semantics / constraints | Evidence |
|---|---|---|---|---|---|---|

Cover the core path without gaps. Then give one worked example with concrete sizes, preferring the experiment's real values. Label chosen values as illustrative, and do not present static derivation as measured output.

### 8. Diagrams

Mermaid diagrams: one end-to-end diagram, one per complex core module, and separate training and inference diagrams if they differ substantially. Label nodes with operations or modules and key edges with symbols and shapes. Show branches, fusion, loops, supervision, and losses, distinguishing data flow from supervision by edge style, and include a legend. Every module in a diagram must be explained in the text. State whether rendering was actually checked.

### 9. Pseudocode

Cover the core forward pass, one training iteration, and any inference procedure with distinct logic. Declare inputs, outputs, parameters, and state, use the notation of §2, annotate key shapes, and expand core branches and loops. Subroutines are allowed only if defined in the document; never hide core logic behind placeholders such as `fuse()` or `process()`. Omit framework boilerplate but keep everything that affects the math or update order. Map each block to its source location.

### 10. Configuration and Variants

| Config key | Effective value or [Unconfirmed] | Source and override chain | Affected step | Effect of changing it |
|---|---|---|---|---|

Separate the main method from ablations, optional paths, and legacy code. List required weights, vocabularies, external features, initialization, seeds, and input constraints. Give complexity only when it can be derived reliably, stating variables, assumptions, and the path it applies to.

### 11. Open Issues and Paper Mapping

| Issue | Evidence | Impact on method description | Needed to resolve |
|---|---|---|---|

Include doc–code conflicts, suspected bugs, shape inconsistencies, unused parameters, missing code, target-version ambiguity, and unconfirmed motivations. Prioritize issues that block an accurate method description, and ignore code style.

Then map method topics to the sections, equation/algorithm labels, and evidence above, for use when drafting the paper. Map only; do not write promotional claims or novelty statements.

## Verification

Before saving, re-check against the code that:

- the input-to-output path is continuous, the target version and config are evidenced, and optional branches are kept off the main path;
- every symbol is defined, and shapes agree with each broadcast, index, mask, and reduction;
- loss formulas, denominators, weights, gradient paths, and train/inference differences are exact;
- prose, formulas, shape tables, diagrams, and pseudocode agree with each other.

When the environment allows, confirm key computations with existing tests, minimal inputs, or lightweight shape tracing. A missing runtime is no reason to stop documenting what can be established statically.

End the document with three lists: **Static verification**, **Runtime verification** (only checks that actually ran successfully), and **Unverified items and limitations**.

## Final Reply

Give the file path, the execution path and configuration analyzed, the verification performed, and the most important [Unconfirmed] items.
