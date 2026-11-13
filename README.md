# iterative-refinement

一个指导 AI 智能体（Agent）以**闭环方式**完成多步骤任务的 Skill：定目标 → 做计划 → 分步执行并逐步检查 → 整体反驳 → 迭代优化，直到达到验收标准。

An agent Skill that closes the loop: measurable goals → planned steps → execute-and-verify each step → adversarial review → iterate until acceptance criteria are met.

## 设计依据

- 工作流模式：plan-and-execute with verification + evaluator-optimizer（Anthropic《Building effective agents》）
- 反思机制：Reflexion（Shinn et al. 2023），并吸收自我纠错文献的修正性证据——**外部可验证信号优先于自我反思**（Kamoi et al. TACL 2024；Huang et al. 2023；memory confabulation, Dixit 2026）
- 独立批判者：Cross-Refine / self-bias 研究表明，独立上下文的批判者优于自我批判

## 核心机制

| 机制 | 说明 |
|------|------|
| 可判定验收标准 | 任务开始前与用户确认可执行的验证标准，杜绝"看起来完成了" |
| 验证分级 A/B/C | 实测运行 > 静态核对 > 人工审读；无法实测必须声明"未经实测" |
| 验证重试优先于反思 | 修复后先重跑验证器，反思只用于验证输出不足以定位问题时 |
| 信号先于诊断 | 反驳意见必须锚定原始验证输出，防止虚构归因（memory confabulation） |
| 独立批判者 | 子智能体以全新上下文做四段式结构化审查（结论→定位→分析→修复） |
| 回归验证 | 每处修改后重验受影响步骤，防止迭代震荡 |
| 反驳收敛 | 连续两轮无新增有效批评即收敛，不空转 |

## 实测基线（v4.1）

用预埋缺陷的基准任务盲测（每任务 5 个预埋缺陷，2 次运行）：

- **批判召回率 95%**（19/20，硬缺陷 16/16 全部命中）
- **精确率 ≈100%**（无任何虚假/凑数批评）

基准任务与评分协议见 `iterative-refinement/assets/benchmarks/`。

## 目录结构

```
iterative-refinement/
├── SKILL.md                      # 主指令（五阶段闭环）
├── assets/
│   ├── plan-template.md          # 计划追踪模板
│   └── benchmarks/               # 自检基准（预埋缺陷任务 + 答案 + 评分协议）
├── references/
│   └── critique-angles.md        # 分领域对抗性审查清单（通用/科研写作/数据分析/编程）
└── scripts/
    └── sync-check.ps1            # 维护工具：多副本哈希一致性检查
```

## 安装

将 `iterative-refinement/` 目录复制到你的 Agent 技能扫描目录，例如：

- Claude Code / SciMaster：`~/.claude/skills/` 或对应的 skills 目录
- Codex CLI：`.codex/skills/`

新会话中即可通过自然语言触发，例如："用迭代求精的方式帮我完成 XX，做完再自己检查几遍"。

## 许可证

MIT
