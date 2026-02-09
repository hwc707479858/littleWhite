# Sprint Change Proposal

- Date: 2026-02-09
- Trigger Story: 1.2 OCR 文本识别与失败反馈
- Requested By: Hewenchao
- Mode: Incremental

## 1) Issue Summary

在 Story 1.2 开发前，新增了明确的界面显示需求：
- OCR 结果页必须显示 OCR 原文
- OCR 结果页必须显示低置信标记
- OCR 失败时必须显示“重试”按钮
- 错误提示需要在 1 秒内出现

问题本质：现有规格对 OCR 结果页显示细节约束不足，可能导致实现与预期不一致。

## 2) Impact Analysis

### Epic Impact

- Epic 1 继续有效，无需新增 Epic。
- 受影响故事：
  - Story 1.2（直接受影响，新增 UI 显示 AC）
  - Story 1.4（需澄清“字段级低置信”与 1.2 的“文本级低置信”边界）

### Artifact Conflict

- PRD：无目标冲突，属于现有可用性目标细化。
- Architecture：无冲突，符合 MVVM + AppError + 状态流 + 事件追踪。
- UX：当前无独立 UX 文档，需在 stories 中补足 UI 行为约束。
- Testing：需增加 UI/流程层测试断言（原文展示、低置信标记、1 秒提示、重试可用）。

## 3) Recommended Approach

- Chosen Path: Option 1 - Direct Adjustment
- Effort: Low
- Risk: Low

Rationale:
1. 需求属于界面行为补充，不改变产品方向。
2. 通过更新 Story 1.2/1.4 验收标准即可闭环。
3. 无需回滚已完成 Story 1.1。

## 4) Detailed Change Proposals

### Proposal A (Approved)

Artifact: `implementation-artifacts/1-2-ocr-文本识别与失败反馈.md`

Changes:
- AC 增加：OCR 成功后结果页显示原文文本区。
- AC 增加：OCR 失败后 1 秒内显示可读错误提示，并显示重试按钮。
- AC 增加：OCR 阶段低置信片段可视化标记。
- Tasks 增加：`OCRResultView`、`lowConfidenceSpans`、`canRetry`、对应测试。

### Proposal B (Approved)

Artifact: `planning-artifacts/epics.md`

Changes:
- Story 1.2 增加 OCR 结果页显示条款（原文、低置信标记、失败重试与 1 秒提示）。
- Story 1.4 增加边界说明：仅负责“结构化字段级低置信标记”，避免与 1.2 语义重叠。

## 5) PRD / MVP Impact

- MVP 范围不变。
- 仅增加显示与交互细节，不增加后端、账号或新模块。

## 6) Implementation Handoff Plan

Scope Classification: Moderate

Handoff:
- SM: 负责回写 Story/epics 变更并保持状态一致。
- Dev: 按更新后的 Story 1.2 实现 OCR 结果页显示与失败重试。
- QA/Review: 验证 1 秒错误提示、低置信标记可见、重试路径可达。

Success Criteria:
1. Story 1.2 的 AC 明确覆盖新增显示需求。
2. Story 1.4 与 1.2 的低置信职责边界清晰。
3. DS 执行后测试可验证上述行为。

## 7) Next Actions

1. 更新 `epics.md` 的 Story 1.2/1.4 条款。
2. 更新 `1-2-ocr-文本识别与失败反馈.md` 的 AC/Tasks。
3. 维持 `sprint-status.yaml` 的 1.2 状态为 `ready-for-dev`。
4. 进入 Dev 执行 `DS`。


### Proposal C (Approved)

Artifact: `implementation-artifacts/1-2-ocr-文本识别与失败反馈.md` + `planning-artifacts/epics.md`

Changes:
- 新增 OCR 导入文件页面（OCRImportView）要求。
- 页面需具备：文件选择、已选文件摘要、开始 OCR 按钮（无文件禁用）。
- 失败时保留在 OCR 导入/结果流程，支持重试。
