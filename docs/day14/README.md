# Project Shanghai 2027

## Day 14 - CI/CD 基础与 GitHub Actions 入门

**日期：2026-07-02**

---

# 今日目标

学习 CI/CD（持续集成 / 持续交付）的基本概念，理解现代软件开发中的自动化交付流程，并初步认识 GitHub Actions 的工作机制。

---

# 一、什么是 CI/CD？

CI/CD 是 DevOps 的核心实践之一，用于将代码开发、测试、构建和部署等流程自动化，提高软件交付效率和代码质量。

传统开发流程：

```text
编写代码
    │
    ▼
手动测试
    │
    ▼
手动打包
    │
    ▼
手动部署
```

CI/CD 自动化流程：

```text
Git Push
    │
    ▼
自动测试
    │
    ▼
自动构建
    │
    ▼
生成镜像
    │
    ▼
自动部署
```

---

# 二、CI（Continuous Integration）

CI（持续集成）是指开发者频繁提交代码，并由系统自动执行一系列检查，例如：

* 拉取最新代码
* 编译项目
* 运行自动化测试
* 检查代码规范
* 生成构建结果

这样能够尽早发现问题，避免错误积累到项目后期。

---

# 三、CD（Continuous Delivery / Continuous Deployment）

CD 有两种常见含义：

### Continuous Delivery（持续交付）

自动完成代码构建、测试和打包，最终由开发者确认是否发布到生产环境。

### Continuous Deployment（持续部署）

在持续交付基础上进一步实现自动发布，代码通过测试后可直接部署到目标环境，无需人工操作。

---

# 四、CI/CD 工作流程

```text
Developer
    │
    ▼
Git Commit
    │
    ▼
Git Push
    │
    ▼
GitHub
    │
    ▼
GitHub Actions / Jenkins
    │
    ▼
Build
    │
    ▼
Test
    │
    ▼
Docker Image
    │
    ▼
Deploy
```

CI/CD 将开发、测试、构建和部署连接成一条自动化流水线（Pipeline）。

---

# 五、GitHub Actions

GitHub Actions 是 GitHub 提供的自动化平台，可以根据指定事件自动执行任务。

例如：

* Push
* Pull Request
* Release
* 定时任务（Schedule）

当事件发生时，GitHub 会自动启动 Runner 执行 Workflow。

---

# 六、Workflow

Workflow 是 GitHub Actions 的配置文件，采用 YAML 格式编写。

默认存放路径：

```text
.github/
└── workflows/
    └── hello.yml
```

示例：

```yaml
name: Hello CI

on:
  push:

jobs:
  hello:
    runs-on: ubuntu-latest

    steps:
      - name: Say Hello
        run: echo "Hello Project Shanghai!"
```

当执行 `git push` 后，GitHub 会自动读取 Workflow，并在 Runner 上执行定义的任务。

---

# 七、核心概念

## Pipeline（流水线）

将代码开发、测试、构建和部署连接成自动执行的完整流程。

---

## Workflow

定义自动化任务执行规则。

---

## Runner

负责执行 Workflow 的运行环境，可以由 GitHub 提供，也可以使用企业自建 Runner。

---

## Trigger（触发器）

决定 Workflow 什么时候执行，例如：

* push
* pull_request
* release
* schedule

---

# 八、今日理解

今天最大的收获是理解了 **CI/CD 的真正意义**。

CI/CD 并不是某个软件，而是一种自动化软件交付思想。GitHub Actions、Jenkins、GitLab CI 等工具，都是实现 CI/CD 的平台。

Git 负责代码管理，GitHub 提供协作平台，而 GitHub Actions 则负责在代码发生变化时自动执行测试、构建和部署任务，实现开发流程自动化。

---

# 九、常用命令

```bash
# 创建 Workflow 目录
mkdir -p .github/workflows

# 查看 Git 状态
git status

# 提交修改
git add .
git commit -m "Day14: Add GitHub Actions workflow"

# 推送远程仓库
git push
```

---

# 今日总结

完成：

* 理解 CI/CD 基本概念
* 理解持续集成与持续交付区别
* 学习 Pipeline 思想
* 认识 GitHub Actions
* 理解 Workflow、Runner、Trigger 等核心概念

---

# 今日收获

CI/CD 是现代 DevOps 的核心实践，它通过自动化流水线将代码开发、测试、构建和部署连接起来，大幅提升软件交付效率和稳定性。

GitHub Actions 作为 GitHub 内置的自动化平台，使开发者能够通过简单的 Workflow 配置，在代码 Push、Pull Request 等事件发生时自动执行任务，为后续学习 Docker、Jenkins、Kubernetes 持续部署奠定基础。

---

# Day14 完成 ✅

**下一阶段：Day15 —— GitHub Actions 实战与自动化流水线（Pipeline）**
