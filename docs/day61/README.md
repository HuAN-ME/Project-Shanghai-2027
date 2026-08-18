# Day61 — GitHub Actions CI 基础与 Build

## 1. 今日目标

建立第一个完整的 GitHub Actions CI 基础流程，理解 CI Pipeline 从代码提交到测试通过的基本执行过程。

今日重点：

* 理解 GitHub Actions Workflow
* 理解 `on` 触发器
* 使用 `actions/checkout`
* 使用 Runner 执行 Shell 命令
* 增加基础 Build 步骤
* 执行应用测试
* 验证完整 CI Pipeline

---

## 2. 实验环境

* OS: Rocky Linux 9.8
* Git: 2.52.0
* CI Platform: GitHub Actions
* Runner: `ubuntu-latest`
* Repository: `Project-Shanghai-2027`

---

## 3. Day61 项目结构

```text
day61/
├── .github/
│   └── workflows/
│       └── day61.yml
├── app/
│   └── health.txt
├── build/
│   └── health.txt
└── README.md
```

其中：

* `app/health.txt`：应用测试输入
* `build/health.txt`：Build 阶段生成的构建结果
* `.github/workflows/day61.yml`：GitHub Actions CI Workflow
* `README.md`：Day61 学习记录

---

## 4. CI Workflow

Day61 使用 GitHub Actions 创建基础 CI Pipeline。

核心结构：

```text
Git Push
    ↓
GitHub Actions
    ↓
Checkout Repository
    ↓
Show Environment
    ↓
Build Application
    ↓
Run Application Test
    ↓
CI PASS
```

Workflow：

```yaml
name: Day61 CI Basics

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  ci:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Show environment
        run: |
          echo "Project: Project Shanghai 2027"
          echo "Day: 61"
          echo "CI Pipeline is running."

      - name: Build application
        run: |
          echo "Building application..."
          mkdir -p build
          cp app/health.txt build/
          echo "Application build completed."

      - name: Run application test
        run: |
          echo "Running application test..."
          test "$(cat app/health.txt)" = "OK"
          echo "Application test passed."
```

---

## 5. Build 阶段

本次没有提前引入 Docker Build 或 Artifact Upload，而是使用最简单的文件构建过程理解 CI 中 Build 的概念。

Build 操作：

```bash
mkdir -p build
cp app/health.txt build/
```

构建前：

```text
app/
└── health.txt
```

构建后：

```text
app/
└── health.txt

build/
└── health.txt
```

通过这种方式理解：

```text
Source
  ↓
Build Process
  ↓
Build Output
```

后续学习 Docker CI/CD 时，可以将这里的 Build 替换为真正的容器镜像构建。

---

## 6. Test 阶段

测试逻辑：

```bash
test "$(cat app/health.txt)" = "OK"
```

当 `app/health.txt` 内容为：

```text
OK
```

测试通过：

```text
Application test passed.
```

如果文件内容不是 `OK`，`test` 命令返回非零状态，GitHub Actions Job 将失败。

因此 CI 不只是执行命令，而是可以根据命令的退出状态自动判断 Pipeline 是否成功。

---

## 7. GitHub Actions 执行结果

Day61 Workflow 在 GitHub Actions Runner 上实际执行成功。

最终状态：

```text
Checkout Repository     PASS
Show Environment        PASS
Build Application       PASS
Run Application Test    PASS
--------------------------------
CI Pipeline              🟢 PASS
```

这意味着整个 CI 流程已经完成真实验证，而不是只在本地执行。

---

## 8. Git 操作

完成 Build 后提交：

```bash
git add .
git commit -m "feat(day61): add application build step"
git push
```

Commit：

```text
495cf39 feat(day61): add application build step
```

Push 成功后，GitHub Actions 自动执行 Workflow，并最终通过。

---

## 9. 今日核心知识

### 9.1 Workflow

Workflow 是 GitHub Actions 自动化流程的定义文件。

位置：

```text
.github/workflows/day61.yml
```

---

### 9.2 Trigger

Workflow 可以由事件触发。

Day61 使用：

```yaml
on:
  push:
  workflow_dispatch:
```

其中：

* `push`：代码 Push 时触发
* `workflow_dispatch`：允许手动触发

---

### 9.3 Job

Day61 定义了一个 Job：

```yaml
jobs:
  ci:
```

并指定：

```yaml
runs-on: ubuntu-latest
```

表示该 Job 在 GitHub 提供的 Ubuntu Runner 上执行。

---

### 9.4 Step

一个 Job 可以包含多个 Step。

Day61：

```text
Checkout
Show Environment
Build
Test
```

每个 Step 按顺序执行。

---

### 9.5 CI 的基本思想

今天真正建立起来的概念：

```text
代码发生变化
      ↓
自动执行
      ↓
构建
      ↓
测试
      ↓
给出明确结果
```

这就是 Continuous Integration（持续集成）的基础。

---

## 10. 今日总结

Day61 完成了第一个最小可运行 CI Pipeline。

从最初只有：

```text
Checkout → Test
```

扩展到：

```text
Checkout
    ↓
Environment
    ↓
Build
    ↓
Test
    ↓
PASS
```

虽然当前 Build 仍然非常简单，但 Pipeline 的基本结构已经建立。

后续可以逐步将：

```text
简单文件 Build
```

升级为：

```text
Application Build
      ↓
Docker Image Build
      ↓
Registry Push
      ↓
Kubernetes Deployment
```

但这些内容留到后续阶段学习，Day61 保持 CI 基础边界。

---

## 11. Day61 完成状态

* [x] 创建 GitHub Actions Workflow
* [x] 配置 Workflow Trigger
* [x] 使用 Ubuntu Runner
* [x] Checkout Repository
* [x] 执行 Environment Step
* [x] 添加 Build Step
* [x] 添加 Application Test
* [x] Git Commit
* [x] Git Push
* [x] GitHub Actions 实际运行
* [x] CI Pipeline 通过
