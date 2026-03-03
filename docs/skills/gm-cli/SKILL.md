---
name: gm-cli
description: Operates gm-cli (gm): auth/config/profile/project/task workflows, safe execution patterns, and troubleshooting. Use when the user mentions gm, gm-cli, Gradmotion, API key, base_url, profile, auth login/logout/whoami/status, project list/create/info, task create/edit/copy/list/info/run/restart/stop/delete/logs/resource/image/storage/data/hp/env/params/batch, or wants CLI automation.
---

# gm-cli

## 适用范围
用 `gm` 完成以下工作流：
- 认证：`gm auth login/logout/status/whoami`
- 配置与 profile：`gm config ...`
- 项目管理：`gm project ...`（list/create/info）
- 任务管理：`gm task ...`（create/edit/copy/list/info/run/stop/restart/delete/logs/resource/image/storage/data/hp/env/params/batch）

## 安全与约束
- 不要在对话输出中回显用户的 `api-key` 或完整密钥内容。
- 高风险操作（`task stop/delete`、`task batch stop/delete`）默认需要二次确认；只有用户明确要求无人值守时才加 `--yes`。
- 涉及文件路径一律使用相对路径（例如 `--file ./payload.json`）。

## 帮助与版本
- 总览：`gm --help`
- 子命令：`gm <command> --help`
- 版本：`gm version`（不使用 `gm --version`）

## 执行前快速探测（固定步骤）
在执行任何写操作前，先跑以下 3 条命令确认 CLI 能力与命令可用性：
1. `gm --help`
2. `gm task --help`
3. `gm project --help`

建议：
- 若任一命令报错，先不要继续执行创建/编辑/删除类操作。
- 若子命令缺失，优先按当前 CLI 版本能力降级执行或提示用户升级。

## 配置优先级
按优先级覆盖：`CLI flags > 环境变量 > 配置文件`。

常用环境变量：
- `GM_PROFILE`
- `GM_BASE_URL` / `GM_API_KEY` / `GM_TIMEOUT` / `GM_RETRY` / `GM_CONCURRENCY`

说明：
- 默认：CLI 请求 `base_url + /api + endpoint`。
- 绝对路径模式：个别命令（如 `gm task storage list`）会直接请求 `base_url + endpoint`（不自动拼 `/api`）。

## 首次上手（推荐步骤）
1. 设置 base_url（落到当前 profile）：
   - `gm config set base_url "https://YOUR-HOST/prod-api"`
2. 登录保存 API Key（优先 Keychain，失败回落 config）：
   - `gm auth login --api-key "<YOUR_KEY>"`
3. 验证：
   - `gm auth status`（本地）
   - `gm auth whoami`（请求服务端）

如需临时覆盖且不落盘：
- `gm --base-url "https://..." --api-key "<KEY>" auth whoami`

## Profile（多环境）
- 列表：`gm config profile list`
- 创建/更新：
  - `gm config profile set dev --base-url "https://..." --timeout 30s --retry 3 --concurrency 4`
- 切换：`gm config profile use dev`
- 临时指定：`gm --profile dev task list` 或 `GM_PROFILE=dev gm task list`

## Task 常用操作
- 列表：`gm task list --page 1 --limit 50`
- 详情：`gm task info --task-id "task_xxx"`
- 复制：`gm task copy --file ./copy.json`
- 运行：`gm task run --task-id "task_xxx"`
- 重启：`gm task restart --task-id "task_xxx"`
- 停止：`gm task stop --task-id "task_xxx"`（会二次确认）
- 删除：`gm task delete --task-id "task_xxx"`（会二次确认）

日志：
- 单次：`gm task logs --task-id "task_xxx"`
- 追踪：`gm task logs --task-id "task_xxx" --follow --interval 2s --timeout 1m`

资源/镜像/存储：
- 资源列表：`gm task resource list --goods-back-category 3 --page-num 1 --page-size 10`
- 官方镜像：`gm task image official`
- 个人镜像：`gm task image personal --version-status 1 --page-num 1 --page-size 50`
- 镜像版本：`gm task image versions --image-id "img_xxx"`
- 个人存储：`gm task storage list --folder-path "personal/"`

图表/超参/环境：
- 图表 keys：`gm task data keys --task-id "task_xxx"`
- 图表数据：`gm task data get --task-id "task_xxx" --data-key "train/loss"`
- 图表下载：`gm task data download --task-id "task_xxx"`
- 超参读取：`gm task hp get --task-id "task_xxx"`
- 运行环境：`gm task env get --task-id "task_xxx"`

## Project 常用操作
- 列表：`gm project list --page 1 --limit 50`
- 创建：`gm project create --file ./project-create.json`
- 详情：`gm project info --project-id "proj_xxx"`

## create/edit/params 的请求体输入（JSON）
这些命令通过 `--data` 或 `--file` 提供 JSON（两者二选一）。
- `gm task create --data '{"...":"..."}'`
- `gm task create --file ./create.json`
- `gm task edit --file ./edit.json`

超参：
- `gm task params submit --task-id "task_xxx" --file ./params.json`
- `gm task params update --task-id "task_xxx" --data '{"...":"..."}'`

## 最小可运行 JSON 模版（训练任务）
下面是一个“可创建并可运行”的最小模板（请替换示例值）：

```json
{
  "taskBaseInfo": {
    "projectId": "proj_xxx",
    "taskType": "1",
    "trainType": "1",
    "taskName": "mvp-train-task",
    "taskDescription": "created by gm-cli",
    "taskTag": [],
    "goodsId": "goods_xxx",
    "imageId": "img_xxx",
    "imageVersion": "ver_xxx",
    "personalDataPath": "/personal"
  },
  "taskCodeInfo": {
    "codeType": "2",
    "codeUrl": "[{\"codeUrl\":\"https://github.com/your-org/your-repo.git\",\"versionType\":\"1\",\"versionName\":\"main\"}]",
    "mainCodeUri": "train.py",
    "hparamsPath": "configs/train.yaml",
    "startScript": "gm-run train.py --headless",
    "isOpen": "1"
  },
  "runtimeReminderConfig": {
    "enableRuntimeReminder": false,
    "reminderDurations": []
  }
}
```

建议创建与运行步骤：
- `gm task create --file ./create-train.json`
- 从返回结果取 `taskId`，执行 `gm task run --task-id "task_xxx"`
- `gm task logs --task-id "task_xxx" --follow`

### 本地 zip/对象存储代码模版（`codeType=1`）
当代码以 zip 包形式提供时，可使用下面模板（请替换示例值）：

```json
{
  "taskBaseInfo": {
    "projectId": "proj_xxx",
    "taskType": "1",
    "trainType": "1",
    "taskName": "mvp-train-task-zip",
    "taskDescription": "created by gm-cli with zip code",
    "taskTag": [],
    "goodsId": "goods_xxx",
    "imageId": "img_xxx",
    "imageVersion": "ver_xxx",
    "personalDataPath": "/personal"
  },
  "taskCodeInfo": {
    "codeType": "1",
    "codeUrl": "[{\"codeUrl\":\"oss://bucket/path/train-code.zip\"}]",
    "mainCodeUri": "train.py",
    "hparamsPath": "configs/train.yaml",
    "startScript": "gm-run train.py --headless",
    "isOpen": "1"
  },
  "runtimeReminderConfig": {
    "enableRuntimeReminder": false,
    "reminderDurations": []
  }
}
```

建议创建与运行步骤：
- `gm task create --file ./create-train-zip.json`
- 从返回结果取 `taskId`，执行 `gm task run --task-id "task_xxx"`
- `gm task logs --task-id "task_xxx" --follow`

## Task 参数软限制
说明：
- 这是 **skill 软限制**（执行前检查并提示），不是后端强校验的替代。
- 字段命名优先使用后端 alias（小驼峰），如 `taskBaseInfo`/`taskCodeInfo`/`taskId`。
- 后端在 task 流程中并未统一显式调用 `validate_fields()`；因此本节采用：
  - `STRICT`：强烈建议拦截（明显会失败或风险极高）
  - `WARN`：仅提示（业务建议或 Agent 侧保护）

### 1) `gm task create` -> `POST /api/task/create` -> `TaskCreateModel`
`STRICT`：
- 顶层必须有：`taskBaseInfo`（object）、`taskCodeInfo`（object）
- `taskBaseInfo.projectId`：必填，长度 `1..20`
- `taskBaseInfo.taskName`：必填，长度 `1..100`
- `taskCodeInfo.codeType`：必填，长度 `1..2`

`WARN`：
- `taskBaseInfo.taskDescription`：可选，最大 `1000`
- `taskBaseInfo.goodsId`：建议必填，最大 `20`（业务侧常见硬依赖）
- `taskBaseInfo.userId`：可选；服务端会按当前登录用户覆盖，不建议依赖请求体值
- `taskCodeInfo.codeUrl`：可选，最大 `1000`
- `taskCodeInfo.mainCodeUri`：可选，最大 `255`
- `taskCodeInfo.runParams`：可选，最大 `255`
- `taskCodeInfo.urdfPath` / `hparamsPath`：可选，最大 `255`
- `taskCodeInfo.checkPointFilePath`：可选，最大 `1000`；若传入建议先确认对象存在

### 2) `gm task edit` -> `POST /api/task/edit` -> `TaskEditModel`
`STRICT`（在 create 基础上追加）：
- `taskBaseInfo.taskId`：必填，长度 `1..20`

`WARN`：
- `taskCodeInfo.isCopyHparams`：可选，建议 `1/2`

### 3) `gm task list` -> `POST /api/task/list` -> `TaskPageQueryModel`
`STRICT`：
- 无必须拦截项（可空请求体，CLI 会补 page）

`WARN`：
- `pageNum`：建议 `>=1`
- `pageSize`：建议 `1..200`（Agent 侧保护阈值，非后端硬限制）
- 若带过滤字段，建议遵循：`projectId <= 20`、`taskName <= 100`、`taskDescription <= 1000`

### 4) `gm task info` -> `GET /api/task/info/{task_id}`
`STRICT`：
- `task-id`：必填，长度 `1..20`

### 5) `gm task run` -> `POST /api/task/run` -> `TaskOperation`
`STRICT`：
- 请求体 `task_id`：必填，长度 `1..20`

`WARN`（执行前建议先 `task info` 预检）：
- 任务状态应为草稿态（后端要求 `task_status == "0"`）
- 任务应已绑定可用资源（如 `goodsId/imageId/goodsBackId` 完整）

### 6) `gm task stop` -> `POST /api/task/stop` -> `TaskOperation`
`STRICT`：
- 请求体 `task_id`：必填，长度 `1..20`

`WARN`（执行前建议先 `task info` 预检）：
- 后端不允许停止状态 `0/5/6` 的任务

### 7) `gm task restart` -> `POST /api/task/restart` -> `TaskOperation`
`STRICT`：
- 请求体 `task_id`：必填，长度 `1..20`

`WARN`（执行前建议先 `task info` 预检）：
- 后端仅允许状态 `4`（暂停态）重启

### 8) `gm task delete` -> `POST /api/task/del` -> `TaskDelModel`
`STRICT`：
- 请求体 `task_id`：必填，长度 `1..20`

`WARN`（执行前建议先 `task info` 预检）：
- 后端仅允许状态集合 `{0,1,2,5,6}` 删除

### 9) `gm task logs` -> `POST /api/task/console/log` -> `ConsoleLogUp`
`STRICT`：
- 请求体 `task_id`：必填，长度 `1..20`

### 10) `gm task params submit` -> `POST /api/task/hp/up` -> `TaskHpModel`
`STRICT`：
- `task_id`：必填，长度 `1..20`

`WARN`：
- `hp_file_name`：建议提供，最大 `1000`
- `hp_file_uri`：建议提供，最大 `1000`
- `hp_save_file_uri`：建议提供，最大 `1000`

### 11) `gm task params update` -> `POST /api/task/hp/edit` -> `EditTaskHpModel`
`STRICT`：
- `task_id`：必填，长度 `1..20`

`WARN`：
- `hp_file_content`：建议必填，最大 `20000`

### 12) `gm task batch stop` -> `POST /api/task/batch/stop` -> `BatchTaskOperation`
`STRICT`：
- `task_ids`：必填，非空数组

`WARN`：
- 每个 `task_id` 建议长度 `1..20`

### 13) `gm task batch delete` -> `POST /api/task/batch/delete` -> `BatchTaskDelete`
`STRICT`：
- `task_ids`：必填，非空数组

`WARN`：
- 每个 `task_id` 建议长度 `1..20`

### 14) `gm task copy` -> `POST /api/task/copy` -> `CopyTaskModel`
`STRICT`：
- 建议请求体包含：`taskId`、`projectId`、`taskName`

`WARN`：
- `taskDescription`：可选，最大 `1000`

### 15) `gm task resource list` -> `GET /api/task/goods/list-by-category`
`STRICT`：
- `goods-back-category`：必填，建议值 `3`（训练）或 `4`（开发机）

`WARN`：
- `page-num >= 1`
- `page-size >= 1`

### 16) `gm task image official` -> `GET /api/images/official/list`
`STRICT`：
- 无必须参数

### 17) `gm task image personal` -> `GET /api/images/personal/list`
`STRICT`：
- 无必须参数

`WARN`：
- `version-status` 默认 `1`
- 分页建议：`page-num >=1`, `page-size >=1`

### 18) `gm task image versions` -> `GET /api/task/getImageVersion`
`STRICT`：
- `image-id`：必填

### 19) `gm task storage list` -> `GET /gm/storage/list`（绝对路径模式）
`STRICT`：
- 无必须参数

`WARN`：
- 查询参数使用 `folderPath`（CLI flag: `--folder-path`）

### 20) `gm task data keys` -> `GET /api/task/data/keys/{task_id}`
`STRICT`：
- `task-id`：必填，长度 `1..20`

### 21) `gm task data get` -> `POST /api/task/data/info` -> `GetDataInfoModel`
`STRICT`：
- `task_id`：必填，长度 `1..20`
- `data_key`：必填

`WARN`：
- `sampling_mode`：建议 `precise|accelerate`
- `max_data_points`：建议正整数

### 22) `gm task data download` -> `GET /api/task/data/download/{task_id}`
`STRICT`：
- `task-id`：必填，长度 `1..20`

### 23) `gm task hp get` -> `GET /api/task/hp/info/{task_id}`
`STRICT`：
- `task-id`：必填，长度 `1..20`

### 24) `gm task env get` -> `GET /api/task/run/env/{task_id}`
`STRICT`：
- `task-id`：必填，长度 `1..20`

### 25) `gm project list` -> `POST /api/project/list`
`STRICT`：
- 无必须拦截项（可空请求体，CLI 会补 page）

`WARN`：
- `pageNum >= 1`
- `pageSize >= 1`

### 26) `gm project create` -> `POST /api/project/create`
`STRICT`：
- 建议请求体至少包含：`projectName`

### 27) `gm project info` -> `GET /api/project/info/{project_id}`
`STRICT`：
- `project-id`：必填，长度建议 `1..20`

## 软限制执行规则（给 Agent）
- 先按 `STRICT` 做预检，不通过则先提示修复示例后再执行。
- `WARN` 只提醒，不阻塞；用户明确要求可带风险继续执行。
- 对 `create/edit` 优先建议 `--file ./payload.json`，避免 shell 转义造成 JSON 结构错误。
- 对 `project create/copy/data get` 同样优先建议 `--file ./payload.json`。
- 对 `run/stop/restart/delete` 优先建议先执行 `gm task info --task-id ...` 做状态预检。
- 默认不自动补全高风险业务字段（如 `goodsId`）；需向用户确认或回读既有任务信息后再填充。

## 批量操作（batch）
- `gm task batch stop --task-ids "t1,t2,t3"`（高风险，默认确认）
- `gm task batch delete --task-ids "t1,t2,t3"`（高风险，默认确认）

无人值守脚本（用户明确要求时才用）：
- `gm --yes task stop --task-id "task_xxx"`
- `gm --yes task delete --task-id "task_xxx"`
- `gm --yes task batch stop --task-ids "t1,t2"`

## 输出与调试
- 默认 stdout：JSON；`--human` 人类可读；`--quiet` 仅关键字段
- `--debug` 开启调试日志
- `--log-file ./gm.log` 将 stderr JSONL 写入文件

## 常见报错快速处理
- base_url 为空：先 `gm config set base_url "..."` 或设置 `GM_BASE_URL`
- api key 为空：先 `gm auth login --api-key ...` 或设置 `GM_API_KEY`
- 不确定参数：先跑 `gm <command> --help`
