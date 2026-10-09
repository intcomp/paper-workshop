# Code to Method Blueprint

Turn research code into a detailed, code-grounded Markdown method blueprint: the technical basis for writing a paper's Method section.

The blueprint covers inputs and outputs, tensor shapes, step-by-step computations, formulas, losses, training and inference procedures, Mermaid flowcharts, pseudocode, and `file:line` evidence for every key step. Statements are tagged as **[Fact]**, **[Inference]**, or **[Unconfirmed]**.

The document is written in the language you request, so you can ask for English or Chinese output.

## Installation

Copy this folder into your agent's skills directory, for example `~/.claude/skills/code-to-method-blueprint/` for Claude Code (user-level) or `.claude/skills/` inside a project.

Then invoke it by name (`/code-to-method-blueprint` in Claude Code, `$code-to-method-blueprint` in Codex), or simply describe the task and let the agent pick the skill.

## Usage

Giving the entry points, config, and actual launch command helps the agent identify the exact method version that ran.

### English example

```text
/code-to-method-blueprint

Code location: /path/to/your/code
Research area: Multimodal learning
Research problem: Image-text classification
Module of interest: CrossModalFusion

Training entry point: train.py
Inference entry point: evaluate.py
Experiment config: configs/experiment.yaml
Actual launch command:
python train.py --config configs/experiment.yaml

Generate a detailed method blueprint based on the code this experiment actually executes.
Output file: /path/to/your/method_blueprint.md
```

### 中文示例

```text
/code-to-method-blueprint

代码位置：/path/to/your/code
研究领域：多模态学习
研究问题：基于图像和文本的分类
关注模块：CrossModalFusion

训练入口：train.py
推理入口：evaluate.py
实验配置：configs/experiment.yaml
实际启动命令：
python train.py --config configs/experiment.yaml

请根据本次实验实际执行的代码，用中文生成一份详细的方法蓝图。
输出文件：/path/to/your/method_blueprint.md
```

### If you don't know the entry points or config

```text
Locate the entry points and config yourself. If there are multiple possible method versions,
list the candidates for me to confirm; do not merge different versions into one description.
```

```text
请自行定位入口和配置。如果存在多个可能的方法版本，请先列出候选版本供我确认，不要把不同版本合并成一个描述。
```

## Use Without Installation

Ask the agent to read the skill file directly:

```text
Read and follow /full/path/to/code-to-method-blueprint/SKILL.md.

Code to analyze: /path/to/your/code
Output file: /path/to/your/method_blueprint.md
```

```text
请阅读并遵循 /full/path/to/code-to-method-blueprint/SKILL.md。

待分析代码：/path/to/your/code
输出文件：/path/to/your/method_blueprint.md
```

## Notes

- By default the skill only reads code and writes the document. It does not modify code, run full training, install dependencies, or download large weights unless you ask it to.
- Review every **[Unconfirmed]** item before using the blueprint in a paper.
