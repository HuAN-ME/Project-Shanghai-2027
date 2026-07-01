# Day13 - GitHub PR Learning

# Project Shanghai 2027

## Day 13 - GitHub Pull Request（PR）与团队协作

**日期：2026-07-01**

---

# 今日目标

学习 GitHub Pull Request（PR）的基本概念，掌握从功能分支开发到发起 PR、代码合并以及同步主分支的完整团队协作流程。

---

# 一、什么是 Pull Request（PR）？

Pull Request（PR）是 GitHub 提供的协作功能，用于**请求将一个分支的代码合并到目标分支**。

相比直接向主分支提交代码，PR 提供了代码审查（Code Review）、讨论以及合并记录等能力，是现代软件开发团队最常见的协作方式。

---

# 二、实验流程

## 创建功能分支

```bash
git switch -c feature-day13
```

---

## 编写功能内容

创建学习记录：

```bash
mkdir -p docs/Day13
echo "# Day13 - GitHub PR Learning" > docs/Day13/README.md
```

---

## 提交本地仓库

```bash
git add .
git commit -m "Day13: GitHub PR learning"
```

---

## 推送到远程仓库

首次推送分支：

```bash
git push --set-upstream origin feature-day13
```

后续更新：

```bash
git push
```

---

## 创建 Pull Request

在 GitHub 仓库页面：

* Compare：`feature-day13`
* Base：`master`

填写 PR 标题及说明，提交 Pull Request。

---

## 合并 PR

PR 审核完成后，点击 **Merge pull request**，确认合并。

随后同步本地主分支：

```bash
git switch master
git pull origin master
```

---

# 三、Git 提交历史

查看提交图：

```bash
git log --oneline --graph --all
```

实验结果：

```text
*   Merge pull request #1 from HuAN-ME/feature-day13
|\
| * Day13: GitHub PR learning
|/
* LICENSE Interlinked
* Try Conflict
* Day12 commit
```

可以清晰看到：

* 创建功能分支
* 提交开发内容
* Pull Request 合并
* Merge Commit 保留完整历史

---

# 四、核心知识点

## Git

负责本地版本控制。

主要功能：

* Commit
* Branch
* Merge
* Version Control

---

## GitHub

负责远程仓库托管与团队协作。

主要功能：

* Remote Repository
* Pull Request
* Code Review
* Issue 管理
* Release 发布

---

## Pull Request（PR）

作用：

* 请求代码合并
* 进行代码审查
* 记录开发过程
* 保证主分支稳定

---

## Merge Commit

PR 合并后，GitHub 会自动生成 Merge Commit，用于记录此次分支合并历史。

---

# 五、团队协作流程

```text
创建功能分支
        │
        ▼
功能开发
        │
        ▼
Commit
        │
        ▼
Push
        │
        ▼
Pull Request
        │
        ▼
Code Review
        │
        ▼
Merge
        │
        ▼
同步主分支
```

这是现代软件开发团队最常见的 Git 工作流程。

---

# 六、今日理解

今天最大的收获是理解了 **Git 与 GitHub 的职责区别**。

Git 负责本地版本管理，而 GitHub 提供远程仓库和团队协作平台。Pull Request 并不是提交代码，而是**请求将自己的开发成果合并到主分支**。

通过 PR，可以进行代码审查、讨论修改方案，并完整保留每次开发的历史记录，使团队协作更加规范、安全。

---

# 七、常用命令汇总

```bash
# 创建并切换分支
git switch -c feature-day13

# 查看状态
git status

# 提交修改
git add .
git commit -m "message"

# 推送分支
git push --set-upstream origin feature-day13

# 查看提交历史
git log --oneline --graph --all

# 切换主分支
git switch master

# 同步远程仓库
git pull origin master
```

---

# 今日总结

完成：

* 理解 Pull Request 工作机制
* 创建功能分支并开发
* 推送远程仓库
* 发起 Pull Request
* 完成 Merge
* 同步本地主分支
* 理解团队协作开发流程

---

# 今日收获

Pull Request 是现代软件开发的重要协作机制，它将功能开发、代码审查和版本管理整合到统一流程中。相比直接向主分支提交代码，PR 能够有效保证代码质量，并完整记录每次功能开发的历史。

通过 Day9 至 Day13 的学习，已经掌握了 Git 与 GitHub 的核心工作流程，为后续学习 CI/CD、GitHub Actions、Docker 和 Jenkins 奠定了坚实基础。

---

# Day13 完成 ✅

**下一阶段：Day14 —— CI/CD 基础概念与 GitHub Actions 入门**
