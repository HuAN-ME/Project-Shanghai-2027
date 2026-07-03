# Project Shanghai 2027

## Day 15 - GitHub Actions 实战：第一个 CI Workflow

**日期：2026-07-03**

---

# 今日目标

编写并运行第一个 GitHub Actions Workflow，理解 GitHub Actions 的基本组成以及自动化流水线（Pipeline）的执行过程。

---

# 一、GitHub Actions 工作流程

当代码执行 `git push` 后，GitHub 会自动检测仓库中的 Workflow，并启动 Runner 执行自动化任务。

执行流程如下：

```text
Git Push
    │
    ▼
读取 Workflow
    │
    ▼
启动 GitHub Runner
    │
    ▼
执行 Job
    │
    ▼
执行 Step
    │
    ▼
输出执行日志
    │
    ▼
Workflow Success / Failed
```

---

# 二、Workflow 文件结构

GitHub Actions 的 Workflow 必须放置在固定目录：

```text
.github/
└── workflows/
    └── hello.yml
```

本次创建的 Workflow：

```yaml
name: Project Shanghai CI

on:
  push:
    branches:
      - master

jobs:
  hello-job:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Show System Information
        run: |
          echo "Project Shanghai 2027"
          pwd
          ls -la

      - name: Print Current Time
        run: date

      - name: Print Success Message
        run: echo "GitHub Actions is running successfully!"
```

---

# 三、Workflow 核心组成

| 字段        | 作用             |
| --------- | -------------- |
| `name`    | Workflow 名称    |
| `on`      | 定义触发条件         |
| `jobs`    | 定义任务集合         |
| `runs-on` | 指定 Runner 系统环境 |
| `steps`   | Job 中的执行步骤     |
| `uses`    | 调用现成的 Action   |
| `run`     | 执行 Shell 命令    |

---

# 四、实验结果

完成以下操作：

```bash
git add .
git commit -m "Day15: Add GitHub Actions workflow"
git push
```

GitHub 自动检测到 Push 事件，并成功执行 Workflow。

Actions 页面显示：

* Workflow 成功运行
* 连续多次 Push 均自动触发执行
* 每次运行耗时约 6～9 秒
* 状态全部为 **Success（✔）**

说明 GitHub Actions 已成功配置完成。

---

# 五、Runner 的作用

`runs-on: ubuntu-latest`

表示 GitHub 会临时创建一台 Ubuntu Runner 来执行 Workflow。

需要注意：

* Workflow 并不是在自己的 Rocky Linux 虚拟机中运行；
* 所有 `run` 命令都在 GitHub 提供的 Runner 上执行；
* Workflow 结束后，Runner 会自动销毁。

---

# 六、Action 的作用

本次使用了 GitHub 官方 Action：

```yaml
uses: actions/checkout@v4
```

作用：

* 自动拉取当前仓库代码；
* 将代码下载到 Runner；
* 后续所有命令均基于仓库内容执行。

没有 Checkout，Runner 默认不会拥有仓库代码。

---

# 七、CI Pipeline 初体验

目前已经具备一个最基础的自动化流水线：

```text
修改代码
    │
    ▼
git add
    │
    ▼
git commit
    │
    ▼
git push
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Actions
    │
    ▼
Ubuntu Runner
    │
    ▼
Checkout Repository
    │
    ▼
执行 Workflow
    │
    ▼
Success ✔
```

虽然目前 Workflow 仅执行简单命令，但整体流程已经与企业 CI 流水线一致。

---

# 八、今日理解

今天最大的收获是理解了 **GitHub Actions 的运行机制**。

GitHub Repository 用于托管代码，而 GitHub Actions 则负责自动执行 Workflow。当代码 Push 到仓库后，GitHub 会启动临时 Runner，根据 Workflow 配置依次执行各个 Step，并生成完整的运行日志。

现代软件开发中的自动化测试、自动构建、Docker 镜像生成以及自动部署，都是在这一流程基础上逐步扩展而来。

---

# 九、常用命令

```bash
# 查看 Git 状态
git status

# 提交修改
git add .
git commit -m "Day15: Add GitHub Actions workflow"

# 推送到远程仓库
git push
```

---

# 今日总结

完成：

* 学习 GitHub Actions Workflow 结构
* 编写第一个 Workflow
* 理解 Job、Step、Runner 的作用
* 使用 `actions/checkout` 拉取仓库代码
* 成功触发 GitHub Actions 自动执行
* 查看 Workflow 运行日志
* 初步搭建 CI Pipeline

---

# 今日收获

GitHub Actions 是 GitHub 内置的 CI/CD 平台，通过 Workflow 可以实现代码提交后的自动化任务执行。今天不仅成功编写并运行了第一个 Workflow，也理解了 Runner、Action 和 Pipeline 的基本概念，为后续学习 Docker 自动构建、镜像发布以及 Kubernetes 自动部署奠定了基础。

---

# Day15 完成 ✅

**下一阶段：Day16 —— GitHub Actions 进阶：多 Job 流水线与企业级 CI Pipeline**
