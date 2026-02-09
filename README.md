# littleWhite

littleWhite 是一个 iOS 健康记录应用的实现仓库，当前阶段完成了 Story 1.1（报告导入与格式校验）的可测试代码骨架。

## 当前实现范围

- 导入模块基础架构（`App / Features / Domain / Data / Infrastructure`）
- 图片导入处理骨架（PhotosUI 适配接口与单张选择约束）
- PDF 导入处理骨架（Document Picker 适配接口）
- 导入格式白名单校验（JPG/JPEG/PNG/PDF）
- 导入错误映射（`AppError` + reason code）
- 导入流程事件追踪（`import.request.started|succeeded|failed`）
- 自动化测试（单元测试 + UI 流程语义测试）

## 技术栈

- Swift 6.2
- Swift Package Manager
- 测试框架：`swift-testing`

> 说明：当前仓库以 Swift Package 形式承载核心领域逻辑与测试。真实 iOS App UI（Xcode target、真实 picker 展示、导航集成）可在后续 Story 中接入。

## 快速开始

### 1) 环境要求

- macOS + Xcode Command Line Tools
- Swift 6.2+

### 2) 运行测试

```bash
swift test
```

### 3) 查看当前变更状态

```bash
git status --short
```

## 目录结构

```text
littleWhite/
├── Package.swift
├── Sources/littleWhite/
│   ├── App/
│   ├── Features/Import/
│   ├── Domain/
│   ├── Data/
│   └── Infrastructure/
├── Tests/littleWhiteTests/
│   └── Features/Import/
└── _bmad-output/
    ├── planning-artifacts/
    └── implementation-artifacts/
```

## BMAD 交付物位置

- PRD：`_bmad-output/planning-artifacts/prd.md`
- Architecture：`_bmad-output/planning-artifacts/architecture.md`
- Epics：`_bmad-output/planning-artifacts/epics.md`
- Sprint 状态：`_bmad-output/implementation-artifacts/sprint-status.yaml`
- Story 1.1：`_bmad-output/implementation-artifacts/1-1-报告导入-图片-pdf-与格式校验.md`

## 当前状态

- Story 1.1：`done`
- Sprint 跟踪已同步到 `sprint-status.yaml`

## 下一步建议

- 继续 Story 1.2：OCR 文本识别与失败反馈
- 在 iOS App Target 中接入真实 picker 展示与导航流程
- 增加更贴近业务的端到端 UI 自动化测试
