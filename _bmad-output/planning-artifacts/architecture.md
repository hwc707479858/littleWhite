---
stepsCompleted:
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
inputDocuments:
  - /Users/hewenchao/Documents/ios/littleWhite/_bmad-output/planning-artifacts/prd.md
  - /Users/hewenchao/Documents/ios/littleWhite/_bmad-output/planning-artifacts/validation-report-2026-02-06.md
workflowType: 'architecture'
project_name: 'littleWhite'
user_name: 'Hewenchao'
date: '2026-02-07 00:12:00 +0800'
lastStep: 8
status: 'complete'
completedAt: '2026-02-07 00:23:00 +0800'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
当前有 31 条 FR，核心覆盖导入与处理（图片/PDF -> OCR -> 云端 LLM 抽取）、字段校正与保存、历史记录与趋势分析、可靠性恢复、隐私透明提示与留存覆盖率查看。架构上需要导入层、处理编排层、本地持久化层、查询与可视化层、审计与事件层的协同。

**Non-Functional Requirements:**
性能（P90 时延目标）、可靠性（保存成功率与恢复一致性）、隐私（云端请求边界与确认门禁）、集成（输入格式与错误转译覆盖率）、可用性（低置信识别与首轮完成时间）将直接驱动架构设计与验收策略。

**Scale & Complexity:**
项目复杂度为 medium。
- Primary domain: mobile + on-device pipeline + cloud AI API
- Complexity level: medium
- Estimated architectural components: 6-8

### Technical Constraints & Dependencies

- iOS 原生首版，单用户、无账号、单机数据闭环。
- 云端 LLM API 为结构化抽取必需依赖；离线场景不执行抽取但允许浏览历史。
- 输入格式需兼容 JPG/PNG/PDF。
- 数据一致性与可追溯（原始值/修正值/时间戳）为强约束。

### Cross-Cutting Concerns Identified

- 数据一致性与崩溃恢复
- 云端调用治理（确认门禁、错误转译、超时重试）
- 审计与可观测性（性能、抽取质量、入库校验、外发审计）
- healthcare 语境下的隐私边界与合规可解释性
- 可测试性与验收口径落地

## Starter Template Evaluation

### Primary Technology Domain

iOS native app（Swift + SwiftUI + 本地数据库 + 云端 AI API）

### Starter Options Considered

1. Apple Xcode iOS App Template（推荐）
- 优点：最少外部依赖、与 Apple 官方工程结构一致、后续演进稳定。
- 代价：模块化与工程自动化能力需要后续自行补充。

2. XcodeGen（2.44.1）
- 优点：工程文件可代码化，减少 .xcodeproj 冲突。
- 代价：引入额外生成流程，不符合当前“纯 Xcode 模板”偏好。

3. Tuist
- 优点：工程治理能力强，适合大型模块化项目。
- 代价：工具链复杂度较高，当前阶段偏重。

### Selected Starter: Apple Xcode iOS App Template

**Rationale for Selection:**
- 与当前技术偏好完全一致：原生 MVVM、SQLite/GRDB、纯 Xcode 模板。
- 当前核心挑战在数据可靠性与合规边界，不在工程生成工具。
- 可后续按需引入 XcodeGen/Tuist，不影响当前架构推进。

**Initialization Command:**

```bash
mkdir littleWhite && cd littleWhite && open -a Xcode .
```

**Architectural Decisions Provided by Starter:**

**Language & Runtime:**
- Swift（Xcode 主线工具链）

**Styling Solution:**
- SwiftUI 原生组件体系

**Build Tooling:**
- Xcode 原生构建系统与 Scheme 管理

**Testing Framework:**
- XCTest（可选叠加 Swift Testing）

**Code Organization:**
- 单 Target 起步，按 MVVM 分层：App / Features / Domain / Data / Infrastructure

**Development Experience:**
- 原生调试、预览、签名与发布流程直接且稳定

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- 应用架构：Apple 原生 MVVM
- 本地数据：SQLite + GRDB
- 云端抽取接入：App 直连第三方 LLM API
- 最低系统版本：iOS 26+
- 导航组织：按功能模块拆分导航

**Important Decisions (Shape Architecture):**
- 数据访问模式：Repository + UseCase
- 可靠性策略：关键写入事务化、失败可恢复、状态可追踪
- 云端调用治理：统一错误模型、超时、有限重试、手动录入降级
- 合规边界：非诊断工具定位 + 数据最小化策略

**Deferred Decisions (Post-MVP):**
- 账号体系/云同步
- 推送通知
- 工程生成工具升级（XcodeGen/Tuist）

### Data Architecture

- 存储：SQLite（当前上游发布线 3.51.x）
- 数据访问：GRDB.swift（当前主仓库 7.x）
- 分层：Data/Repositories、Domain/UseCases、Features/*/ViewModel
- 迁移：DatabaseMigrator 版本化 schema
- 核心模型：LabRecord、LabItemValue、ExtractionAudit

### Authentication & Security

- MVP 无账号认证
- 云端调用前强制确认（NFR8）
- 不在后台自动外发数据（NFR9）
- 密钥策略：直连模式（客户端持钥，后续可迁移中继）

### API & Communication Patterns

- 通信模式：HTTPS JSON
- 调用链：OCR -> Prompt Builder -> LLM API -> Schema Mapper -> Validation -> Save
- 失败策略：网络/服务异常可读错误；抽取失败降级手动校正；映射失败拒绝入库
- 超时与重试：单次超时、有限重试、不做无限重试

### Frontend Architecture

- UI：SwiftUI
- 导航：按功能模块拆分（Import / ReviewAndCorrect / History / Trend / Settings）
- 状态管理：MVVM + ObservableObject/@StateObject
- 状态边界：模块间仅传递必要 DTO

### Infrastructure & Deployment

- 初始化：纯 Xcode iOS App Template
- 包管理：SPM
- 交付：TestFlight -> App Store
- 观测：本地结构化日志 + 抽取链路事件埋点 + 入库审计日志

### Decision Impact Analysis

**Implementation Sequence:**
1. 建立数据模型与迁移基线
2. 完成导入/OCR/抽取编排链路
3. 实现校正与保存事务
4. 接入历史与趋势查询
5. 补齐审计与 NFR 验收埋点

**Cross-Component Dependencies:**
- Schema 设计约束抽取映射与趋势图查询
- 错误模型影响 API 层、ViewModel 与 UX 提示一致性
- 直连密钥策略影响安全边界与后续演进成本

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:** 5（命名、结构、格式、通信、流程）

### Naming Patterns

**Database Naming Conventions:**
- 表名使用 snake_case 复数（如 lab_records）
- 列名使用 snake_case（如 record_id, created_at）
- 外键统一 <entity>_id
- 索引统一 idx_<table>_<column>

**API Naming Conventions:**
- App 内部服务接口方法名使用 camelCase
- 网络 DTO 字段在 Data 层统一完成 snake_case -> camelCase 映射
- 错误码使用 UPPER_SNAKE_CASE（如 EXTRACTION_TIMEOUT）

**Code Naming Conventions:**
- Swift 类型名：UpperCamelCase
- 方法与属性：lowerCamelCase
- 文件名与主类型同名（如 ExtractionService.swift）

### Structure Patterns

**Project Organization:**
- App/
- Features/Import
- Features/ReviewAndCorrect
- Features/History
- Features/Trend
- Features/Settings
- Domain/ (Entities, UseCases, Protocols)
- Data/ (Repositories, LocalDB, Remote, Mappers)
- Infrastructure/ (Logging, Metrics, ErrorHandling)

**Tests Organization:**
- 单元测试按源码镜像目录组织
- UI 测试放置在 UITests/

### Format Patterns

**API Response Formats:**
- 成功与失败统一通过 Result<Payload, AppError> 抽象表达
- UI 不直接消费原始网络错误，必须经过 AppError 映射

**Date/Data Formats:**
- 存储时间统一 UTC ISO8601
- UI 展示统一本地时区格式化
- 数值字段双轨存储：原始字符串 + 解析后的数值

### Communication Patterns

**Event / Logging:**
- 事件命名格式：feature.action.outcome（如 extraction.request.success）
- 关键链路必须打点：导入、OCR、抽取、校正、保存、失败原因

**State Management:**
- ViewModel 仅持有 UI State，不直接操作数据库
- 单向流：Action -> UseCase -> Repository -> State

### Process Patterns

**Error Handling:**
- 三层错误：UserFacing / Recoverable / System
- 可恢复错误必须提供下一步动作（重试/手动录入）

**Loading State:**
- 每个 Feature 独立 loading 状态
- 抽取流程需阶段性状态（上传中/抽取中/映射中）

### Enforcement Guidelines

**All AI Agents MUST:**
- 仅在 Data 层实现网络与数据库访问，Features 禁止直连
- 所有外部响应先经过 Mapper + Validator，成功后方可入库
- 所有错误统一映射到 AppError 再上抛 UI

## Project Structure & Boundaries

### Complete Project Directory Structure

```text
littleWhite/
├── littleWhite.xcodeproj
├── README.md
├── .gitignore
├── Config/
│   ├── AppConfig.swift
│   ├── Environment.swift
│   └── Secrets.example.xcconfig
├── App/
│   ├── LittleWhiteApp.swift
│   ├── AppRouter.swift
│   └── DependencyContainer.swift
├── Features/
│   ├── Import/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   ├── ReviewAndCorrect/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   ├── History/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   ├── Trend/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   └── Settings/
│       ├── Views/
│       └── ViewModels/
├── Domain/
│   ├── Entities/
│   │   ├── LabRecord.swift
│   │   ├── LabItemValue.swift
│   │   └── ExtractionAudit.swift
│   ├── UseCases/
│   │   ├── ImportReportUseCase.swift
│   │   ├── ExtractStructuredDataUseCase.swift
│   │   ├── ValidateAndSaveRecordUseCase.swift
│   │   └── ComputeTrendUseCase.swift
│   └── Repositories/
│       ├── LabRecordRepositoryProtocol.swift
│       └── AuditRepositoryProtocol.swift
├── Data/
│   ├── LocalDB/
│   │   ├── DatabaseManager.swift
│   │   ├── Migrations.swift
│   │   └── DAOs/
│   ├── Remote/
│   │   ├── LLMClient.swift
│   │   ├── DTOs/
│   │   └── RequestBuilder.swift
│   ├── Repositories/
│   │   ├── LabRecordRepository.swift
│   │   └── AuditRepository.swift
│   ├── Mappers/
│   │   ├── ExtractionMapper.swift
│   │   └── ValidationMapper.swift
│   └── Validators/
│       └── LabSchemaValidator.swift
├── Infrastructure/
│   ├── Logging/
│   │   └── EventLogger.swift
│   ├── ErrorHandling/
│   │   ├── AppError.swift
│   │   └── ErrorTranslator.swift
│   ├── Networking/
│   │   ├── HTTPClient.swift
│   │   └── RetryPolicy.swift
│   └── Metrics/
│       └── MetricsCollector.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── PrivacyInfo.xcprivacy
├── Tests/
│   ├── Unit/
│   │   ├── Domain/
│   │   ├── Data/
│   │   └── Features/
│   └── Integration/
│       ├── ExtractionPipelineTests.swift
│       └── PersistenceConsistencyTests.swift
└── UITests/
    ├── ImportFlowUITests.swift
    └── CorrectionAndSaveUITests.swift
```

### Architectural Boundaries

**API Boundaries:**
- App 仅通过 Data/Remote 下的 LLMClient 发起云端请求
- Features 层禁止直接发起网络调用
- 云端请求前必须经过用户确认门禁

**Component Boundaries:**
- Features 只依赖 Domain 协议与 UseCase
- Domain 不依赖 Data 与 Infrastructure 实现
- Data 通过 Repository 实现 Domain 协议

**Service Boundaries:**
- Extraction 链路服务化分解：OCR、Prompt、LLM 调用、映射、校验、入库
- 错误翻译统一由 Infrastructure/ErrorHandling 管理

**Data Boundaries:**
- 本地数据访问仅通过 Data/LocalDB
- 结构化入库前必须通过 Validators 校验
- 审计数据与业务数据分离存储

### Requirements to Structure Mapping

**Feature/FR Mapping:**
- Import/ReviewAndCorrect 对应 FR1-FR14
- History/Trend 对应 FR15-FR23、FR31
- Reliability/Privacy 对应 FR24-FR30 与 NFR 约束

**Cross-Cutting Concerns:**
- 日志与指标：Infrastructure/Logging + Infrastructure/Metrics
- 错误处理：Infrastructure/ErrorHandling
- 一致性与恢复：Data/LocalDB + Integration Tests

### Integration Points

**Internal Communication:**
- ViewModel -> UseCase -> Repository(Protocol) -> Data Implementation

**External Integrations:**
- LLM API（直连）
- 系统相册与文件导入接口

**Data Flow:**
- Import -> OCR -> LLM Extract -> Map/Validate -> Save -> Query/List/Trend

### File Organization Patterns

**Configuration Files:**
- Config 目录集中管理环境与运行参数

**Source Organization:**
- 按 App / Features / Domain / Data / Infrastructure 分层与分责

**Test Organization:**
- Unit/Integration/UITests 三层覆盖

**Asset Organization:**
- Resources 集中管理静态资源与隐私声明

### Development Workflow Integration

**Development Server Structure:**
- 本地 Xcode 运行与调试，Feature 模块可独立开发测试

**Build Process Structure:**
- Scheme 驱动构建，单元/集成/UI 测试分层执行

**Deployment Structure:**
- TestFlight 验证后发布 App Store

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:**
- MVVM + GRDB + 模块化导航 + 直连 LLM API 组合无结构性冲突。
- 关键技术选择与当前约束一致。

**Pattern Consistency:**
- 命名、分层、错误模型、数据流规则与核心决策一致。
- 多代理协作冲突点有明确约束。

**Structure Alignment:**
- 目录边界支撑 Feature / Domain / Data / Infrastructure 分责。
- 结构可承载导入、抽取、校正、保存、查询、趋势全链路。

### Requirements Coverage Validation ✅

**Feature Coverage:**
- FR1-FR31 均有对应架构承接点。

**Functional Requirements Coverage:**
- 导入、抽取、校正、留存、趋势、恢复、隐私提示均可落地。

**Non-Functional Requirements Coverage:**
- 性能、可靠性、隐私、集成、可用性在架构中均有对应机制。

### Implementation Readiness Validation ✅

**Decision Completeness:**
- 关键决策已固定（含最低 iOS 26+、直连策略、模块化导航）。

**Structure Completeness:**
- 工程树、边界、映射与集成点定义完整。

**Pattern Completeness:**
- 命名、格式、通信、错误与状态管理规范可直接约束实现。

### Gap Analysis Results

**Critical Gaps:** 0

**Important Gaps:**
- 直连密钥策略需补充密钥轮换/吊销/泄漏响应 runbook。

**Nice-to-Have Gaps:**
- 后续补充“中继网关迁移路径 ADR”。

### Validation Issues Addressed

- 已确认当前架构可支撑 PRD 目标并可直接进入实现准备阶段。

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed
- [x] Technical constraints identified
- [x] Cross-cutting concerns mapped

**✅ Architectural Decisions**
- [x] Critical decisions documented with versions/策略
- [x] Technology stack fully specified
- [x] Integration patterns defined
- [x] Performance considerations addressed

**✅ Implementation Patterns**
- [x] Naming conventions established
- [x] Structure patterns defined
- [x] Communication patterns specified
- [x] Process patterns documented

**✅ Project Structure**
- [x] Complete directory structure defined
- [x] Component boundaries established
- [x] Integration points mapped
- [x] Requirements to structure mapping complete

### Architecture Readiness Assessment

**Overall Status:** READY FOR IMPLEMENTATION

**Confidence Level:** High

**Key Strengths:**
- 架构决策闭环完整，覆盖 FR/NFR 与合规边界。
- 模块边界清晰，适合多 AI 代理并行实现。

**Areas for Future Enhancement:**
- 中继网关演进策略
- 更细粒度可观测性规范

### Implementation Handoff

**AI Agent Guidelines:**
- 严格遵循本文档中的架构决策与实现规范
- 所有实现必须遵守分层边界与一致性规则
- 发现冲突时以本文档决策为准并记录 ADR

**First Implementation Priority:**
- 用 Xcode 初始化 iOS 工程并建立基础目录骨架，随后实现导入与抽取主链路
