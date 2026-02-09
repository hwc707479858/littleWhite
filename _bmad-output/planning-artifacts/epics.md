---
stepsCompleted:
  - 1
  - 2
inputDocuments:
  - /Users/hewenchao/Documents/ios/littleWhite/_bmad-output/planning-artifacts/prd.md
  - /Users/hewenchao/Documents/ios/littleWhite/_bmad-output/planning-artifacts/architecture.md
  - /Users/hewenchao/Documents/ios/littleWhite/_bmad-output/planning-artifacts/validation-report-2026-02-06.md
---


# littleWhite - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for littleWhite, decomposing requirements from PRD and Architecture into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: 用户可以从相册导入单张检验报告图片。
FR2: 用户可以从文件系统导入单份 PDF 检验报告。
FR3: 用户可以发起对已导入报告的 OCR 文本识别。
FR4: 用户可以发起基于 OCR 文本的结构化抽取任务。
FR5: 系统可以按预定义血常规字段 schema 输出结构化结果。
FR6: 系统可以标记抽取结果中的低置信字段。
FR7: 系统可以在抽取失败时提供可继续录入的兜底路径。
FR8: 用户可以查看单次报告的完整结构化字段结果。
FR9: 用户可以逐字段修改识别/抽取结果。
FR10: 用户可以清空单字段值并重新输入。
FR11: 系统可以在保存前校验必填字段完整性。
FR12: 用户可以在保存前取消本次录入且不影响已存数据。
FR13: 用户可以保存一条完成校正的血常规记录。
FR14: 系统可以为每条记录保留原始值、修正值与修正时间。
FR15: 用户可以查看按时间排序的历史血常规记录列表。
FR16: 用户可以查看单条历史记录详情。
FR17: 用户可以删除单条历史记录。
FR18: 系统可以在记录保存后立即出现在历史列表中。
FR19: 系统可以在应用重启后恢复并展示已保存记录。
FR20: 用户可以按指标查看一段时间内的趋势图。
FR21: 用户可以选择趋势图时间范围。
FR22: 用户可以在趋势图中查看某个时间点对应的记录值。
FR23: 系统可以保证趋势图数据与记录列表数据一致。
FR24: 系统可以在异常中断后保持已完成保存记录不丢失。
FR25: 系统可以在恢复后继续未完成的录入流程或允许重新开始。
FR26: 用户可以在识别流程失败后继续通过手动方式完成录入。
FR27: 系统可以记录关键处理状态（导入、识别、抽取、保存）供问题排查。
FR28: 系统可以在识别流程前提示将文本发送至云端模型服务。
FR29: 用户可以查看并确认该次云端处理后再继续。
FR30: 系统可以在本地保存最终结构化结果与修正历史。
FR31: 用户可以查看近 12 个月录入覆盖率（每月是否至少 1 次）以评估持续使用情况。

### NonFunctional Requirements

- NFR1: 在网络正常情况下，单份报告从发起抽取到返回结构化结果的 P90 时长 <= 10 秒；按最近 100 次有效请求滚动统计，每周复盘一次。
- NFR2: 已保存历史记录列表打开时间 P90 <= 1 秒；按真机埋点统计，每个版本发布前验证。
- NFR3: 趋势图在常用时间范围内首次渲染时间 P90 <= 2 秒；按本地性能埋点统计并在回归测试中校验。
- NFR4: 已确认保存的数据持久化成功率为 100%（不接受已保存后丢失）。
- NFR5: 应用异常退出后，已保存记录可完整恢复，数据一致性错误率为 0。
- NFR6: 当云端抽取不可用时，系统应在 3 秒内给出失败反馈并提供手动录入路径。
- NFR7: 云端请求中与抽取无关字段占比必须为 0%；通过请求负载审计抽样（每版本 >= 30 次）验证。
- NFR8: 云端处理前用户确认完成率必须为 100%；任何未确认请求不得发出，通过事件日志校验。
- NFR9: 应用不得存在自动对外共享路径，自动外发事件数必须为 0；通过静态配置检查与运行期日志验证。
- NFR10: 输入兼容格式限定为 JPG、PNG、PDF；格式识别误判率 < 1%，通过导入回归集（>= 200 文件）验证。
- NFR11: 云端异常响应转译为可读错误提示的覆盖率需达到 100%，且错误提示渲染时间 <= 1 秒。
- NFR12: 抽取结果字段映射校验通过率需达到 100%；非法字段入库事件必须为 0，通过入库审计日志验证。
- NFR13: 首次使用用户可在 3 分钟内完成一次完整录入（导入-抽取-修正-保存）。
- NFR14: 低置信字段识别正确率（用户可准确识别需复核字段）>= 95%；通过可用性测试（>= 20 次任务）验证。

### Additional Requirements

- 技术栈固定为 iOS 原生 MVVM，最低系统版本 iOS 26+。
- 数据存储采用 SQLite + GRDB，且使用 DatabaseMigrator 做版本化迁移。
- 处理链路固定为：导入 -> OCR -> LLM 抽取 -> 映射校验 -> 入库。
- 云端抽取采用直连第三方 LLM API，调用前必须经过用户确认门禁。
- Features 层禁止直接访问网络和数据库，只能通过 UseCase/Repository 协议。
- 错误统一映射为 AppError，上层 UI 不直接消费原始网络错误。
- 外部响应必须经过 Mapper + Validator 才能入库，非法字段入库事件必须为 0。
- 数据模型必须包含可追溯信息：原始值、修正值、时间戳。
- 目录结构按 App / Features / Domain / Data / Infrastructure 分层。
- 观测要求：导入、OCR、抽取、校正、保存、失败原因必须可打点追踪。
- 一致性规则：命名、状态流、错误处理、加载状态按架构文档规范执行。
- 重要改进项：补充直连密钥轮换/吊销/泄漏响应 runbook，并在故事中落地。

### FR Coverage Map

FR1: Epic 1 - 相册导入
FR2: Epic 1 - PDF 导入
FR3: Epic 1 - OCR 识别
FR4: Epic 1 - 结构化抽取
FR5: Epic 1 - schema 输出
FR6: Epic 1 - 低置信标记
FR7: Epic 1 - 抽取失败兜底
FR8: Epic 1 - 结果查看
FR9: Epic 1 - 字段编辑
FR10: Epic 1 - 字段重填
FR11: Epic 1 - 保存前校验
FR12: Epic 1 - 取消录入
FR13: Epic 1 - 保存记录
FR14: Epic 1 - 原始/修正追溯
FR15: Epic 2 - 历史列表
FR16: Epic 2 - 记录详情
FR17: Epic 4 - 删除记录与数据治理
FR18: Epic 2 - 保存后可见
FR19: Epic 2 - 重启后可见
FR20: Epic 2 - 趋势图查看
FR21: Epic 2 - 时间范围选择
FR22: Epic 2 - 点位查看
FR23: Epic 2 - 图表列表一致
FR24: Epic 3 - 异常后不丢数据
FR25: Epic 3 - 恢复未完成流程
FR26: Epic 3 - 失败手动完成
FR27: Epic 3 - 关键状态审计
FR28: Epic 1 - 云端发送提示
FR29: Epic 1 - 发送前确认
FR30: Epic 3 - 本地结果与修正历史保存
FR31: Epic 2 - 12个月覆盖率查看


## Epic List

### Epic 1: 报告导入与可保存记录闭环
用户可以完成“导入 -> OCR -> 抽取 -> 手动校正 -> 保存”的最小可用闭环。
**FRs covered:** FR1, FR2, FR3, FR4, FR5, FR6, FR7, FR8, FR9, FR10, FR11, FR12, FR13, FR14, FR28, FR29

### Epic 2: 历史记录与趋势洞察
用户可以查看历史记录、趋势图和长期录入覆盖率，形成持续追踪能力。
**FRs covered:** FR15, FR16, FR18, FR19, FR20, FR21, FR22, FR23, FR31

### Epic 3: 可靠性、恢复与审计可追溯
用户在异常场景下仍可完成记录与恢复，系统具备关键链路可追溯能力。
**FRs covered:** FR24, FR25, FR26, FR27, FR30

### Epic 4: 隐私边界与运维安全治理
用户数据在云端调用与本地存储边界内被正确处理，并具备可治理能力。
**FRs covered:** FR17 + NFR7, NFR8, NFR9, NFR10, NFR11, NFR12, NFR13, NFR14

## Epic 1: 报告导入与可保存记录闭环

用户可以完成“导入 -> OCR -> 抽取 -> 手动校正 -> 保存”的最小可用闭环。

### Story 1.1: 报告导入（图片/PDF）与格式校验

As a 录入用户,
I want 从相册或文件导入检验报告并完成格式校验,
So that 我可以稳定进入识别流程并减少无效输入。

**Acceptance Criteria:**

**Given** 用户在导入入口选择图片或 PDF
**When** 文件为 JPG/PNG/PDF 且读取成功
**Then** 系统展示导入成功状态并进入待识别态
**And** 非支持格式在 1 秒内返回可读错误提示，不进入后续流程。

### Story 1.2: OCR 文本识别与失败反馈

As a 录入用户,
I want 对导入报告执行 OCR 并得到可读结果或失败反馈,
So that 我能快速判断是否可继续抽取。

**Acceptance Criteria:**

**Given** 用户已导入合法报告文件
**When** 用户触发 OCR
**Then** 系统返回 OCR 文本并记录 OCR 完成状态
**And** OCR 失败时在 3 秒内给出失败原因与重试入口。

### Story 1.3: 云端发送前确认门禁与结构化抽取

As a 录入用户,
I want 在发送 OCR 文本至云端前先确认，再执行 LLM 抽取,
So that 我明确知道数据将被云端处理并可自主决策。

**Acceptance Criteria:**

**Given** OCR 文本可用且用户进入抽取流程
**When** 用户尚未确认云端处理
**Then** 系统不得发出云端请求
**And** 用户确认后才发送请求并返回结构化字段结果。

### Story 1.4: 抽取结果映射校验与低置信标记

As a 录入用户,
I want 查看按血常规 schema 映射后的结果并识别低置信字段,
So that 我可以聚焦高风险字段做快速校正。

**Acceptance Criteria:**

**Given** 云端返回抽取结果
**When** 系统执行 Mapper + Validator
**Then** 仅合法字段可进入结果页且字段映射通过率为 100%
**And** 低置信字段被显式标记，非法字段入库事件为 0。

### Story 1.5: 逐字段编辑、必填校验与取消录入

As a 录入用户,
I want 手动修正字段并在保存前完成必填校验或取消本次录入,
So that 我能确保记录准确且不会污染历史数据。

**Acceptance Criteria:**

**Given** 用户处于结果校正页
**When** 用户编辑/清空字段并点击保存或取消
**Then** 保存前必须完成必填字段校验，缺失时阻止保存并提示
**And** 取消录入只丢弃当前未保存会话，不影响既有已保存数据。

### Story 1.6: 记录保存与修正链路追溯

As a 录入用户,
I want 保存最终记录并保留原始值与修正值追溯信息,
So that 我可以回看每次修改历史并支持后续问题排查。

**Acceptance Criteria:**

**Given** 用户已通过校验并触发保存
**When** 系统写入 SQLite/GRDB
**Then** 记录必须持久化成功且保存成功率为 100%
**And** 每个被修正字段保留原始值、修正值与修正时间戳。

## Epic 2: 历史记录与趋势洞察

用户可以查看历史记录、趋势图和长期录入覆盖率，形成持续追踪能力。

### Story 2.1: 历史列表展示与保存后即时可见

As a 录入用户,
I want 查看按时间排序的历史记录并在保存后立即看到新记录,
So that 我能确认本次录入已生效。

**Acceptance Criteria:**

**Given** 数据库中已存在至少一条记录
**When** 用户打开历史列表或刚完成一次保存
**Then** 列表按时间倒序展示并包含新保存记录
**And** 历史列表打开时间 P90 <= 1 秒。

### Story 2.2: 历史详情与重启恢复一致性

As a 录入用户,
I want 查看单条历史详情并在应用重启后保持可见,
So that 我能稳定回溯任意一次结果。

**Acceptance Criteria:**

**Given** 用户在历史列表点击任一记录
**When** 进入详情页并完成一次应用重启
**Then** 详情展示与列表数据一致，关键字段不缺失
**And** 重启后记录可完整恢复且数据一致性错误率为 0。

### Story 2.3: 趋势图指标选择与时间范围筛选

As a 录入用户,
I want 按指标查看趋势并切换时间范围,
So that 我能快速观察阶段性变化。

**Acceptance Criteria:**

**Given** 历史记录满足绘图最小数据量
**When** 用户选择指标并切换时间范围
**Then** 系统渲染对应趋势线与坐标刻度
**And** 常用时间范围首次渲染时间 P90 <= 2 秒。

### Story 2.4: 趋势点位回看与图表-列表联动

As a 录入用户,
I want 在趋势图点击点位并查看对应日期数值与记录入口,
So that 我能定位异常波动对应的原始记录。

**Acceptance Criteria:**

**Given** 趋势图已渲染且存在可交互点位
**When** 用户点击任一点位
**Then** 显示该时间点的指标值、日期及记录标识
**And** 从点位进入记录后，值与历史列表展示完全一致。

### Story 2.5: 列表与图表数据一致性校验

As a 录入用户,
I want 确认趋势图数据与历史列表来自同一真实来源,
So that 我可以信任可视化分析结果。

**Acceptance Criteria:**

**Given** 任意时间范围内有历史数据
**When** 系统生成趋势图数据集
**Then** 数据源必须来自同一 Repository 查询结果
**And** 图表值与列表详情逐条可对齐，无不一致样本。

### Story 2.6: 12 个月录入覆盖率展示

As a 录入用户,
I want 查看近 12 个月每月是否至少录入 1 次,
So that 我能评估长期持续录入完成度。

**Acceptance Criteria:**

**Given** 用户进入覆盖率视图
**When** 系统统计近 12 个月记录
**Then** 每个月清晰标识“已覆盖/未覆盖”
**And** 覆盖率计算规则固定为“当月至少 1 次保存记录即覆盖”。

## Epic 3: 可靠性、恢复与审计可追溯

用户在异常场景下仍可完成记录与恢复，系统具备关键链路可追溯能力。

### Story 3.1: 已保存记录的事务性持久化保护

As a 录入用户,
I want 在异常中断场景下仍保证已保存记录不丢失,
So that 我可以信任每次成功保存后的结果。

**Acceptance Criteria:**

**Given** 用户已完成一次保存并收到成功反馈
**When** 应用发生闪退、强退或系统重启
**Then** 已保存记录在恢复后必须完整存在
**And** 已确认保存数据持久化成功率为 100%。

### Story 3.2: 未完成录入会话恢复或安全重建

As a 录入用户,
I want 异常恢复后继续未完成流程或一键重新开始,
So that 我不会因中断被迫重复无关步骤。

**Acceptance Criteria:**

**Given** 用户在导入/OCR/抽取/校正任一中间态被中断
**When** 用户重新打开应用
**Then** 系统可恢复到最近可继续步骤或提供清晰“重新开始”入口
**And** 恢复行为不得污染已保存历史记录。

### Story 3.3: 识别/抽取失败后的手动录入兜底

As a 录入用户,
I want 在 OCR 或云端抽取失败时继续手动完成录入,
So that 我仍能完成当次数据沉淀。

**Acceptance Criteria:**

**Given** OCR 或抽取流程返回失败
**When** 用户选择继续录入
**Then** 系统在 3 秒内给出可操作的手动录入界面
**And** 用户可完成必填字段并执行保存闭环。

### Story 3.4: 关键处理状态审计日志

As a 排查问题的维护者,
I want 查看导入、OCR、抽取、保存等关键状态日志,
So that 我能快速定位失败阶段与原因。

**Acceptance Criteria:**

**Given** 任一次录入会话被执行
**When** 流程经过关键节点（导入、识别、抽取、保存、失败）
**Then** 系统记录结构化事件（状态、时间、结果、错误码）
**And** 日志可用于问题复盘且不包含与业务无关敏感数据。

### Story 3.5: 结构化结果与修正历史可追溯存档

As a 录入用户,
I want 每条记录都保留最终值与修正轨迹,
So that 我可以回看每次变更并验证趋势可信性。

**Acceptance Criteria:**

**Given** 一条记录经过抽取与人工修正后保存
**When** 用户查看历史详情
**Then** 可见最终结构化结果与字段级修正历史
**And** 每条修正包含原始值、修正值与时间戳且可稳定查询。

## Epic 4: 隐私边界与运维安全治理

用户数据在云端调用与本地存储边界内被正确处理，并具备可治理能力。

### Story 4.1: 单条记录删除能力与一致性清理

As a 录入用户,
I want 删除单条历史记录并确保关联视图同步更新,
So that 我可以移除错误或不再需要的数据。

**Acceptance Criteria:**

**Given** 用户在历史列表或详情页选择删除一条记录
**When** 用户确认删除
**Then** 该记录从本地存储移除且列表与趋势图同步更新
**And** 删除后不存在悬挂引用或“幽灵数据”。

### Story 4.2: 云端最小化负载与字段白名单控制

As a 隐私敏感用户,
I want 仅将抽取必需文本发送到云端,
So that 数据暴露范围被控制在最小边界。

**Acceptance Criteria:**

**Given** 用户已确认云端处理并触发请求
**When** 系统构建请求负载
**Then** 仅包含抽取所需字段且无无关数据
**And** 与抽取无关字段占比必须为 0%。

### Story 4.3: 云端确认门禁与禁止未授权发送

As a 隐私敏感用户,
I want 所有云端调用都经过显式确认,
So that 我可以确保无未经授权的数据外发。

**Acceptance Criteria:**

**Given** 任一会话进入云端抽取阶段
**When** 用户未完成确认
**Then** 系统禁止发起请求并提示确认必要性
**And** 未确认请求发出事件数必须为 0。

### Story 4.4: 输入兼容与错误转译治理

As a 录入用户,
I want 非法文件和云端错误都能得到可读提示,
So that 我能快速纠正问题而不是卡在技术细节里。

**Acceptance Criteria:**

**Given** 用户导入不支持格式或云端返回异常
**When** 系统处理输入或响应
**Then** 在 1 秒内展示可读错误信息与下一步建议
**And** 错误转译覆盖率达到 100%，格式误判率 < 1%。

### Story 4.5: 入库前字段校验与非法数据阻断

As a 录入用户,
I want 入库前完成 schema 校验并阻断非法字段,
So that 历史数据长期保持可分析一致性。

**Acceptance Criteria:**

**Given** 抽取结果准备写入本地数据库
**When** 系统执行字段映射和校验
**Then** 仅合法字段可写入
**And** 非法字段入库事件必须为 0。

### Story 4.6: 密钥治理与泄漏响应 Runbook

As a 维护者,
I want 具备 API 密钥轮换/吊销/泄漏应急机制,
So that 在密钥风险事件发生时可以快速止损。

**Acceptance Criteria:**

**Given** 项目使用直连第三方云端 API
**When** 发生密钥轮换、吊销或泄漏告警
**Then** 有可执行 runbook 覆盖检测、替换、验证与回滚步骤
**And** 新旧密钥切换过程不影响核心录入闭环可用性。
