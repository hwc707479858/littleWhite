# littleWhite

littleWhite 是一个 iOS 健康记录应用实现仓库，当前已完成 Story 1.1 与 Story 1.2，并可在 iOS 模拟器直接运行演示界面。

## 当前实现范围

- 导入模块基础架构（`App / Features / Domain / Data / Infrastructure`）
- 图片导入处理骨架（PhotosUI 适配接口与单张选择约束）
- PDF 导入处理骨架（Document Picker 适配接口）
- 导入格式白名单校验（JPG/JPEG/PNG/PDF）
- 导入错误映射（`AppError` + reason code）
- 导入流程事件追踪（`import.request.started|succeeded|failed`）
- OCR 领域模型、用例与仓储实现（Vision OCR 接入）
- OCR 导入页/结果页（原文展示、低置信标记、失败重试）
- 自动化测试（31 tests，单元 + 流程 + 渲染）

## 技术栈

- Swift 6.2
- Swift Package Manager
- XcodeGen（生成 `littleWhiteApp.xcodeproj`）
- 测试框架：`swift-testing`

> 说明：仓库同时包含 Swift Package（核心逻辑/测试）和一个可运行的 iOS App target（演示壳层）。

## 快速开始

### 1) 环境要求

- macOS + Xcode 26.2+
- Swift 6.2+
- `xcodegen`（`brew install xcodegen`）

### 2) 运行测试

```bash
swift test
```

### 3) 生成并打开 iOS 工程

```bash
xcodegen generate
open littleWhiteApp.xcodeproj
```

### 4) 在模拟器运行

- Xcode Scheme 选择：`littleWhiteApp`
- 目标设备选择：iOS 模拟器（例如 `iPhone 17`）
- 运行：`Cmd + R`

### 5) 命令行构建（可选）

```bash
xcodebuild -project littleWhiteApp.xcodeproj \
  -scheme littleWhiteApp \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=26.2" \
  build
```

## 目录结构

```text
littleWhite/
├── project.yml
├── littleWhiteApp.xcodeproj/
├── App/littleWhiteApp/
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
- Story 1.2：`_bmad-output/implementation-artifacts/1-2-ocr-文本识别与失败反馈.md`

## 当前状态

- Story 1.1：`done`
- Story 1.2：`done`
- Sprint 跟踪已同步到 `sprint-status.yaml`

## 下一步建议

- 开始 Story 1.3：云端发送前确认门禁与结构化抽取
- 将演示用 OCR 仓储替换为真实文件导入 + OCR 流程
- 增加针对 iOS App target 的 UI 自动化测试
