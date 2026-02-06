---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-03-success
  - step-04-journeys
  - step-05-domain
  - step-06-innovation
  - step-07-project-type
  - step-08-scoping
  - step-09-functional
  - step-10-nonfunctional
  - step-11-polish
  - step-12-complete
  - step-e-01-discovery
  - step-e-02-review
  - step-e-03-edit
inputDocuments: []
documentCounts:
  briefCount: 0
  researchCount: 0
  brainstormingCount: 0
  projectDocsCount: 0
classification:
  projectType: mobile_app
  domain: healthcare
  complexity: medium
  projectContext: greenfield
workflowType: 'prd'
workflow: 'edit'
date: '2026-02-06'
lastEdited: '2026-02-07 00:08:00 +0800'
editHistory:
  - date: '2026-02-07 00:08:00 +0800'
    changes: '补齐healthcare合规细则、强化NFR可测量性、补强留存追溯链'
---

# Product Requirements Document - littleWhite

**Author:** Hewenchao
**Date:** 2026-02-06 23:39:47 +0800

## Executive Summary

littleWhite 是一款 iOS 原生个人健康记录应用，目标用户为单一用户（你本人）。产品聚焦血常规报告录入效率与长期趋势可视化：支持图片/PDF 导入，经 OCR 与云端大模型抽取生成结构化数据，用户校正后本地保存并在列表与趋势图中查看。首版不做账号、推送与后端业务系统，优先达成 30 秒录入路径、99% 关键字段识别准确率和“已保存数据零丢失”。

## Success Criteria

### User Success

- 单次血常规录入（从打开识别到保存）目标在 30 秒内完成。
- OCR 后仅需 1-2 次手动修正即可达到可用状态。
- 支持 PDF 与图片两种输入，保证不同报告来源下都能完成录入。

### Business Success

- 你作为唯一核心用户，若能连续 12 个月持续使用并录入，即定义为产品成功。
- 连续使用定义：12 个月窗口内至少 10 个月发生有效录入（每月至少 1 条记录）。

### Technical Success

- 关键底线：零数据丢失（本地保存成功后可稳定读回、展示）。
- 识别准确率目标：99%（按血常规关键字段计算）。
- 图表展示与列表数据一致，避免记录存在但图表缺失或错位。

### Measurable Outcomes

- 录入时长：P90 <= 30 秒。
- 识别准确率：关键字段准确率 >= 99%。
- 修正成本：单次录入手动修正次数 <= 2 次（常态）。
- 可靠性：已保存记录数据丢失事件 = 0。
- 留存目标：12 个月内录入覆盖率 >= 10/12（月）。

## Product Scope

### MVP - Minimum Viable Product

- PDF/图片导入并识别血常规字段。
- 识别结果可手动校正并保存。
- 历史记录列表。
- 一段时间内的血常规趋势图。

### Growth Features (Post-MVP)

- 多份报告批量导入与自动去重。
- 指标异常高亮与变化提醒。
- 识别模板优化（不同医院/版式自适应）。

### Vision (Future)

- 跨设备同步与备份。
- 更完整的检验报告体系（不止血常规）。
- 长期健康趋势洞察与个性化总结。

## User Journeys

### 旅程 1：日常录入成功路径（Primary User - Success Path）

- 开场：拿到新的血常规报告（图片或 PDF），希望 30 秒内完成录入。
- 过程：打开 App -> 导入报告 -> 自动识别字段 -> 快速检查 -> 1-2 处修正 -> 保存。
- 价值峰值：保存成功并立即在列表中看到新记录。
- 结果：几乎不需要手打数据，录入负担显著降低。

### 旅程 2：识别不理想的纠错路径（Primary User - Edge Case）

- 开场：报告版式特殊或图片质量差，部分字段识别错误。
- 过程：系统高亮低置信字段 -> 逐项修正 -> 再次校验 -> 保存。
- 故障恢复：即使 OCR 失败，也可手动补全并完成入库。
- 结果：保证可完成性，不因识别失败中断记录习惯。

### 旅程 3：趋势复盘路径（Primary User - Review/Insight）

- 开场：你想看一段时间血常规变化，不只看单次结果。
- 过程：进入历史列表 -> 选择指标/时间范围 -> 查看趋势图 -> 对比异常波动。
- 价值峰值：快速发现变化趋势，形成后续观察重点。
- 结果：数据从存档变成可理解的长期趋势。

### 旅程 4：数据安全与找回路径（Support/Troubleshooting）

- 开场：担心历史数据丢失或误操作导致记录不可见。
- 过程：检查记录状态 -> 使用恢复机制（若需要）-> 确认图表与列表一致。
- 底线：已保存数据可稳定读回，数据丢失事件为 0。
- 结果：建立长期使用信心，满足核心技术成功标准。

### Journey Requirements Summary

- 导入与解析：支持 PDF/图片，OCR + 低置信提示。
- 可编辑录入：字段级手动修正与保存前校验。
- 历史与趋势：记录列表、指标筛选、时间区间图表。
- 稳定性：保存原子性、读取一致性、异常恢复机制。
- 体验目标：30 秒内完成主路径录入。

## Domain-Specific Requirements

### Compliance & Regulatory

- 当前定位为个人健康管理工具，不是医疗诊断系统。
- 产品与文案明确：仅用于记录与趋势查看，不提供诊断结论。
- 若未来引入云同步/多用户，再评估隐私法规与同意机制。

#### Regulatory Applicability Matrix

| Requirement | Applicability | Current Decision | Notes |
|-------------|---------------|------------------|-------|
| FDA 医疗器械软件监管 | Conditional | Out of scope for MVP | 当前不提供诊断/治疗建议，仅做个人记录与趋势展示 |
| HIPAA 约束 | Conditional | Not claimed for MVP | 当前为个人单机使用；若引入云端账户/共享则需重新评估 |
| 第三方模型服务数据处理约束 | Applicable | In scope | 需明确发送数据范围、保留策略与删除路径 |

#### Data Governance Policy

- 数据最小化：仅发送结构化抽取所需文本，不发送无关元数据。
- 保留策略：本地结构化结果长期保留；云端请求日志默认不保留业务正文（若服务商策略不同需显式披露）。
- 删除策略：用户删除记录后，本地结构化数据与关联源文件均应同步删除。
- 第三方责任边界：模型服务仅用于抽取处理，不作为长期存储与二次用途系统。

#### Safety & Misuse Controls

- 风险分级：识别低置信字段标记为高风险输入，必须人工确认后保存。
- 误用防护：在结果页与设置页持续提示“非诊断工具”。
- 回溯能力：保留原始值、修正值与时间戳，支持事后核对与纠正。

### Technical Constraints

- 数据可靠性：保存事务化，异常退出不应导致部分写入。
- 可追溯：保留“原始识别值 + 手动修正值 + 时间戳”。
- 精度要求：关键字段识别准确率目标 99%，低置信字段高亮提示。

### Integration Requirements

- MVP 阶段无外部系统强依赖（本地闭环）。
- 输入源支持相册图片与 PDF 文件导入。
- 后续可扩展导出（CSV/PDF）与备份能力。

### Risk Mitigations

- OCR 误识别导致趋势误判：低置信提示 + 保存前确认。
- 数据丢失：持久化校验与崩溃恢复。
- 报告版式差异大：模板化解析 + 手动录入兜底。

## Mobile App Specific Requirements

### Project-Type Overview

- iOS 原生 App，首版单用户。
- 客户端本地完成导入与展示；结构化抽取依赖云端模型 API。

### Technical Architecture Considerations

- 数据流程：图片/PDF 导入 -> OCR 文本 -> 云端 LLM 抽取 -> 结构化结果回填 -> 手动校正 -> 本地保存 -> 列表/图表展示。
- 抽取输出需符合固定 schema：项目名、结果值、单位、参考区间、检测时间。
- 失败兜底：API 失败或结果低置信时，允许手动录入完成闭环。

### Platform Requirements

- 仅 iOS 原生，不做跨平台。
- 首版不做账号系统，数据单机存储。

### Device Permissions & Input

- 不需要相机拍摄。
- 支持从相册导入图片。
- 支持从文件系统导入 PDF。

### Network & Offline Strategy

- 核心浏览功能（列表/图表/历史查看）离线可用。
- 识别流程需要联网调用云端模型 API（离线时不可执行抽取）。
- 无后端业务系统，但需要模型 API 接入与密钥管理策略。

### Notifications

- 首版不做推送通知。

### Store Compliance & Privacy

- 明确告知：识别文本将发送至云端模型服务进行结构化处理。
- 本地保留最终结构化结果与修正记录。

### Implementation Considerations

- 优先保证：抽取准确率、低置信高亮、保存可靠性（零数据丢失）。
- 延后能力：账号体系、同步备份、推送通知。

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** 问题解决型 MVP（先解决“血常规难录入”单点痛点）。  
**Resource Requirements:** 1 人可启动（iOS + OCR/LLM 集成），后续按需要补测试支持。

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**
- 日常录入成功路径
- 识别失败纠错路径
- 趋势复盘路径

**Must-Have Capabilities:**
- 相册/PDF 导入
- OCR + 云端 LLM 结构化抽取
- 低置信高亮与手动校正
- 本地保存与历史列表
- 指标趋势图
- 基础异常恢复（避免数据丢失）

### Post-MVP Features

**Phase 2 (Post-MVP):**
- 多报告批量导入
- 指标异常提醒
- 版式自适应增强
- 数据导出（CSV/PDF）

**Phase 3 (Expansion):**
- 账号体系
- 云同步与备份
- 更多检验项目支持与长期洞察

### Risk Mitigation Strategy

**Technical Risks:** LLM 抽取稳定性与字段准确率风险。  
缓解：字段 schema 约束、低置信提示、手动兜底。  
**Market Risks:** 单用户场景可能导致需求漂移。  
缓解：按月复盘“是否持续使用”和录入时长指标。  
**Resource Risks:** 单人开发周期拉长。  
缓解：严格锁定 Phase 1，不引入账号/推送/后端平台化工作。

## Functional Requirements

### Data Ingestion & Processing

- FR1: 用户可以从相册导入单张检验报告图片。
- FR2: 用户可以从文件系统导入单份 PDF 检验报告。
- FR3: 用户可以发起对已导入报告的 OCR 文本识别。
- FR4: 用户可以发起基于 OCR 文本的结构化抽取任务。
- FR5: 系统可以按预定义血常规字段 schema 输出结构化结果。
- FR6: 系统可以标记抽取结果中的低置信字段。
- FR7: 系统可以在抽取失败时提供可继续录入的兜底路径。

### Record Editing & Validation

- FR8: 用户可以查看单次报告的完整结构化字段结果。
- FR9: 用户可以逐字段修改识别/抽取结果。
- FR10: 用户可以清空单字段值并重新输入。
- FR11: 系统可以在保存前校验必填字段完整性。
- FR12: 用户可以在保存前取消本次录入且不影响已存数据。
- FR13: 用户可以保存一条完成校正的血常规记录。
- FR14: 系统可以为每条记录保留原始值、修正值与修正时间。

### Record Management

- FR15: 用户可以查看按时间排序的历史血常规记录列表。
- FR16: 用户可以查看单条历史记录详情。
- FR17: 用户可以删除单条历史记录。
- FR18: 系统可以在记录保存后立即出现在历史列表中。
- FR19: 系统可以在应用重启后恢复并展示已保存记录。

### Trend & Insight

- FR20: 用户可以按指标查看一段时间内的趋势图。
- FR21: 用户可以选择趋势图时间范围。
- FR22: 用户可以在趋势图中查看某个时间点对应的记录值。
- FR23: 系统可以保证趋势图数据与记录列表数据一致。
- FR31: 用户可以查看近 12 个月录入覆盖率（每月是否至少 1 次）以评估持续使用情况。

### Reliability & Recovery

- FR24: 系统可以在异常中断后保持已完成保存记录不丢失。
- FR25: 系统可以在恢复后继续未完成的录入流程或允许重新开始。
- FR26: 用户可以在识别流程失败后继续通过手动方式完成录入。
- FR27: 系统可以记录关键处理状态（导入、识别、抽取、保存）供问题排查。

### Privacy & Transparency

- FR28: 系统可以在识别流程前提示将文本发送至云端模型服务。
- FR29: 用户可以查看并确认该次云端处理后再继续。
- FR30: 系统可以在本地保存最终结构化结果与修正历史。

## Non-Functional Requirements

### Performance

- NFR1: 在网络正常情况下，单份报告从发起抽取到返回结构化结果的 P90 时长 <= 10 秒；按最近 100 次有效请求滚动统计，每周复盘一次。
- NFR2: 已保存历史记录列表打开时间 P90 <= 1 秒；按真机埋点统计，每个版本发布前验证。
- NFR3: 趋势图在常用时间范围内首次渲染时间 P90 <= 2 秒；按本地性能埋点统计并在回归测试中校验。

### Reliability

- NFR4: 已确认保存的数据持久化成功率为 100%（不接受已保存后丢失）。
- NFR5: 应用异常退出后，已保存记录可完整恢复，数据一致性错误率为 0。
- NFR6: 当云端抽取不可用时，系统应在 3 秒内给出失败反馈并提供手动录入路径。

### Security & Privacy

- NFR7: 云端请求中与抽取无关字段占比必须为 0%；通过请求负载审计抽样（每版本 >= 30 次）验证。
- NFR8: 云端处理前用户确认完成率必须为 100%；任何未确认请求不得发出，通过事件日志校验。
- NFR9: 应用不得存在自动对外共享路径，自动外发事件数必须为 0；通过静态配置检查与运行期日志验证。

### Integration

- NFR10: 输入兼容格式限定为 JPG、PNG、PDF；格式识别误判率 < 1%，通过导入回归集（>= 200 文件）验证。
- NFR11: 云端异常响应转译为可读错误提示的覆盖率需达到 100%，且错误提示渲染时间 <= 1 秒。
- NFR12: 抽取结果字段映射校验通过率需达到 100%；非法字段入库事件必须为 0，通过入库审计日志验证。

### Usability

- NFR13: 首次使用用户可在 3 分钟内完成一次完整录入（导入-抽取-修正-保存）。
- NFR14: 低置信字段识别正确率（用户可准确识别需复核字段）>= 95%；通过可用性测试（>= 20 次任务）验证。
