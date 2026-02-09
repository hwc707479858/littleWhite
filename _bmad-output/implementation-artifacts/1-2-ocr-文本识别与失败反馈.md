# Story 1.2: OCR 文本识别与失败反馈

Status: done

## Story

As a 录入用户,
I want 对导入报告执行 OCR 并得到可读结果或失败反馈,
so that 我能快速判断是否可继续抽取。

## Acceptance Criteria

1. Given 用户进入 OCR 导入文件页面并选择合法报告文件，When 用户触发 OCR，Then 系统返回 OCR 文本并记录 OCR 完成状态，且 OCR 结果页展示原文文本区（可滚动）。
2. Given OCR 处理失败或超时，When 系统捕获异常，Then 在 1 秒内给出可读失败原因并显示重试按钮，且页面停留在 OCR 导入/结果流程中。
3. OCR 导入文件页面必须提供文件选择、已选文件摘要和“开始 OCR”按钮；未选择文件时按钮禁用。
4. OCR 结果页必须展示低置信文本片段标记（文本级），并可为后续结构化字段标记复用。
5. OCR 处理链路必须输出可追踪事件（开始/成功/失败、耗时、失败码）。
6. OCR 成功结果可进入下一故事（1.3）的云端抽取前置状态。

## Tasks / Subtasks

- [x] Task 1: 定义 OCR 领域模型与用例入口（AC: 1, 4）
- [x] Subtask 1.1: 在 Domain 层新增 `OCRTextResult`（rawText、confidenceSummary、sourceReportId、durationMs）。
- [x] Subtask 1.2: 定义 `OCRRepository` 协议与 `RunOCRUseCase`，保持 `Feature -> UseCase -> Repository` 单向调用。
- [x] Subtask 1.3: 明确 OCR 成功态 DTO，保证可直接作为 Story 1.3 抽取输入。

- [x] Task 2: 实现 Vision OCR 执行器（AC: 1）
- [x] Subtask 2.1: 在 Data/Infrastructure 实现 `VisionOCRService`（`VNRecognizeTextRequest`）。
- [x] Subtask 2.2: 默认开启语言纠错（`usesLanguageCorrection = true`），并支持中英文语言参数配置。
- [x] Subtask 2.3: 统一文本拼接策略（按 observation 顺序合并为多行文本），输出可读 raw text。

- [x] Task 3: 实现 OCR 失败处理与 3 秒内错误反馈（AC: 2）
- [x] Subtask 3.1: 增加 OCR 失败错误码映射（`OCR_TIMEOUT`、`OCR_NO_TEXT`、`OCR_ENGINE_ERROR`）。
- [x] Subtask 3.2: 在 ViewModel 暴露 `retryOCR()`，失败后 UI 可直接重试。
- [x] Subtask 3.3: 失败反馈文案统一走 `AppError.userFacing`，禁止暴露底层框架错误。

- [x] Task 4: 接入 OCR 导入页、结果页显示与可观测性（AC: 3, 4, 5, 6）
- [x] Subtask 4.1: 在 Import 流程后接入 OCR 触发状态：`idle -> recognizing -> recognized/failed`，并驱动 OCR 结果页显示。
- [x] Subtask 4.1a: 新增 `OCRImportView`，提供文件选择、文件摘要与“开始 OCR”按钮（无文件时禁用）。
- [x] Subtask 4.2: 打点 `ocr.request.started|succeeded|failed`，失败带 reason code，成功带 durationMs。
- [x] Subtask 4.3: OCR 成功后写入“待抽取上下文”（不入正式记录表）。

- [x] Subtask 4.4: OCR 结果页展示原文文本区、低置信标记和失败重试按钮。

- [x] Task 5: 测试覆盖与回归验证（AC: 1, 2, 3, 4, 5）
- [x] Subtask 5.1: 单元测试：成功识别、空文本、超时、引擎异常、重试成功。
- [x] Subtask 5.2: 流程测试：OCR 失败不进入抽取、OCR 成功进入待抽取态、OCR 导入页/结果页元素显示正确。
- [x] Subtask 5.3: 流程测试：OCR 导入页未选文件时“开始 OCR”按钮禁用。
- [x] Subtask 5.4: 性能断言：失败反馈路径在测试桩下 <= 3 秒。

## Dev Notes

- 本故事仅交付 OCR 与失败反馈，不实现云端抽取（Story 1.3 负责）。
- OCR 输出必须是“可读文本 + 可追踪状态”，且可无缝传递到下游抽取。
- 与 Story 1.1 的导入对象复用：`ImportedReport` 作为 OCR 输入边界。

### Technical Requirements

- OCR 引擎：Vision `VNRecognizeTextRequest`。
- 结果对象至少包含：
  - `rawText`
  - `sourceReportId`（可关联导入记录）
  - `durationMs`
  - `recognizedAt`（UTC）
- 错误码最少覆盖：
  - `OCR_TIMEOUT`
  - `OCR_NO_TEXT`
  - `OCR_ENGINE_ERROR`
- 失败路径需在 3 秒内给出用户可读反馈（AC2）。

### Architecture Compliance

- `Features/Import` 仅通过 UseCase 触发 OCR，不直接访问 Vision API。
- Vision 具体调用放在 Data/Infrastructure 层。
- 所有错误统一映射 `AppError` 后再进入 UI。
- 事件命名遵循 `feature.action.outcome`。

### Library / Framework Requirements

- OCR：`Vision`（`VNRecognizeTextRequest`）。
- 可选导入扫描增强（非本故事必须）：`VisionKit`。
- 测试框架沿用当前项目：`swift-testing`。

### File Structure Requirements

- 建议新增/修改路径：
  - `Sources/littleWhite/Domain/Entities/OCRTextResult.swift`
  - `Sources/littleWhite/Domain/UseCases/RunOCRUseCase.swift`
  - `Sources/littleWhite/Domain/UseCases/OCRRepository.swift`
  - `Sources/littleWhite/Data/Repositories/OCRRepositoryImpl.swift`
  - `Sources/littleWhite/Infrastructure/OCR/VisionOCRService.swift`
  - `Sources/littleWhite/Features/Import/ImportViewModel.swift`
  - `Sources/littleWhite/Infrastructure/ErrorHandling/AppError.swift`
  - `Sources/littleWhite/Infrastructure/ErrorHandling/OCRErrorMapping.swift`
  - `Sources/littleWhite/Infrastructure/ErrorHandling/OCRTracking.swift`
  - `Tests/littleWhiteTests/Features/Import/OCRUseCaseTests.swift`
  - `Tests/littleWhiteTests/Features/Import/OCRFlowTests.swift`

### Testing Requirements

- 单元测试（必须）：
  - OCR 成功返回文本与状态。
  - OCR 空结果映射 `OCR_NO_TEXT`。
  - OCR 超时映射 `OCR_TIMEOUT`。
  - OCR 引擎异常映射 `OCR_ENGINE_ERROR`。
  - `retryOCR()` 可从 failed 回到 recognizing 并成功。
- 流程测试（必须）：
  - OCR 失败不触发后续抽取状态。
  - OCR 成功进入“待抽取上下文”。
- 性能测试（轻量）：
  - 失败反馈路径在桩环境下 < 3 秒。

### Previous Story Intelligence

- Story 1.1 已交付并完成 code-review 修复，当前可复用：
  - `ImportedReport`（导入输出模型）
  - `ImportFlowOrchestrator`（流程编排入口）
  - `ImportEventTracker`（事件追踪模式）
  - `AppError` + reason code 机制（统一错误翻译）
- 延续策略：OCR 事件命名与导入事件保持同样结构，避免跨模块日志口径不一致。

### Git Intelligence Summary

- 当前主开发变更集中在 `Sources/littleWhite/Features/Import` 与 `Infrastructure/ErrorHandling`。
- 推荐在同样路径内演进 OCR，避免新建并行“第二套流程”。
- Story 1.1 已包含 “失败不进入下游流程” 的测试思路，OCR 故事应复用该守卫模式。

### Latest Tech Information

- Apple 文档：`usesLanguageCorrection` 为 `true` 时准确率更高，`false` 有性能收益但精度下降；医疗报告场景优先准确率。来源：
  - [usesLanguageCorrection](https://developer.apple.com/documentation/vision/vnrecognizetextrequest/useslanguagecorrection)
- Apple WWDC（Text Recognition in Vision）强调：
  - `accurate` vs `fast` 模式需按场景权衡；
  - 可通过 `minimumTextHeight` 优化性能；
  - 长时 OCR 应提供进度/取消与用户反馈。来源：
  - [WWDC19 Text Recognition in Vision Framework](https://developer.apple.com/videos/play/wwdc2019/234/)
- Swift Testing 官方页面说明并发测试与 `#expect` 适合当前 async 状态流测试。来源：
  - [Swift Testing](https://developer.apple.com/xcode/swift-testing/)

### Project Context Reference

- 本 story 对应 `epics.md` 中 `Story 1.2`，承接 `1.1` 导入结果，前置于 `1.3` 云端抽取。
- 当前仓库是 Swift Package 结构，OCR 先以可测试核心逻辑落地；真实 iOS UI 触发在后续 app target 接入。

### References

- `/Users/hewenchao/Documents/ios/littleWhite/_bmad-output/planning-artifacts/epics.md`
- `/Users/hewenchao/Documents/ios/littleWhite/_bmad-output/planning-artifacts/architecture.md`
- `/Users/hewenchao/Documents/ios/littleWhite/_bmad-output/planning-artifacts/prd.md`
- `/Users/hewenchao/Documents/ios/littleWhite/_bmad-output/implementation-artifacts/1-1-报告导入-图片-pdf-与格式校验.md`
- [Apple Vision usesLanguageCorrection](https://developer.apple.com/documentation/vision/vnrecognizetextrequest/useslanguagecorrection)
- [WWDC19 Text Recognition in Vision Framework](https://developer.apple.com/videos/play/wwdc2019/234/)
- [Swift Testing](https://developer.apple.com/xcode/swift-testing/)

## Dev Agent Record

### Agent Model Used

GPT-5 Codex

### Debug Log References

- Sprint status auto-discovery selected first backlog story: `1-2-ocr-文本识别与失败反馈`
- Previous story intelligence loaded from Story 1.1 (`done`)
- Architecture/PRD/Epics context loaded and reconciled for OCR-only scope
- `swift test` 执行通过（31 tests, 0 failures）

### Completion Notes List

- Implemented OCR 领域模型、用例和仓储协议/实现（`OCRTextResult`、`RunOCRUseCase`、`OCRRepositoryImpl`）。
- Implemented Vision OCR 服务（语言纠错开启、中英文配置、按 observation 顺序拼接原文、低置信摘要输出）。
- Implemented OCR 错误映射与失败重试流（`OCR_TIMEOUT`、`OCR_NO_TEXT`、`OCR_ENGINE_ERROR` + `retryOCR()`）。
- Implemented OCR 导入页与结果页（文件选择摘要、无文件禁用开始按钮、原文可见、低置信标记、失败重试按钮）。
- Implemented OCR 事件追踪与待抽取上下文写入（Story 1.3 前置态）。
- Added OCR 单元/集成/渲染测试并全部通过。
- Story status set to `review`

### File List

- `/Users/hewenchao/Documents/ios/littleWhite/_bmad-output/implementation-artifacts/1-2-ocr-文本识别与失败反馈.md`
- `/Users/hewenchao/Documents/ios/littleWhite/Sources/littleWhite/Domain/Entities/OCRTextResult.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Sources/littleWhite/Domain/Entities/PendingExtractionContext.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Sources/littleWhite/Domain/UseCases/OCRRepository.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Sources/littleWhite/Domain/UseCases/RunOCRUseCase.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Sources/littleWhite/Data/Repositories/OCRRepositoryImpl.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Sources/littleWhite/Infrastructure/OCR/VisionOCRService.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Sources/littleWhite/Infrastructure/ErrorHandling/OCRErrorMapping.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Sources/littleWhite/Infrastructure/ErrorHandling/OCRTracking.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Sources/littleWhite/Infrastructure/ErrorHandling/AppError.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Sources/littleWhite/Features/Import/OCRViewModel.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Sources/littleWhite/Features/Import/OCRViews.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Tests/littleWhiteTests/Features/Import/OCRUseCaseTests.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Tests/littleWhiteTests/Features/Import/VisionOCRServiceTests.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Tests/littleWhiteTests/Features/Import/OCRFlowTests.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Tests/littleWhiteTests/Features/Import/OCRIntegrationFlowTests.swift`
- `/Users/hewenchao/Documents/ios/littleWhite/Tests/littleWhiteTests/Features/Import/OCRViewRenderingTests.swift`

## Change Log

- 2026-02-09: CC 变更已纳入。新增 OCR 结果页显示需求（原文、低置信标记、失败重试按钮、1 秒内提示）。
- 2026-02-09: CC 追加变更。新增 OCR 导入文件页面需求（文件选择、摘要展示、开始按钮禁用态）。
- 2026-02-09: 完成 Story 1.2 实现与测试，状态更新为 `review`。
- 2026-02-09: CR 通过并完成修复（防并发触发、失败埋点补齐耗时、StateObject 生命周期稳定），状态更新为 `done`。
