"# Day11 Git Branch"

# Project Shanghai 2027

## Day 11 - Git Branch（分支管理）

**日期：2026-06-29**

---

# 今日目标

学习 Git 分支（Branch）的基本概念及使用方法，理解分支在团队协作中的作用，并掌握创建、切换、合并分支的基本流程。

---

# 一、什么是 Git Branch？

Git Branch（分支）可以理解为一条独立的开发线路。

主分支通常保存稳定版本，而新功能、Bug 修复或实验功能都可以在新的分支中完成，互不影响。

例如：

```text
master
│
├── feature-login
├── feature-docker
├── bugfix-network
└── experiment
```

---

# 二、常用命令

查看当前分支：

```bash
git branch
```

创建分支：

```bash
git branch day11
```

切换分支（推荐）：

```bash
git switch day11
```

也可以使用：

```bash
git checkout day11
```

---

# 三、Merge（分支合并）

开发完成后，将分支内容合并到主分支：

```bash
git switch master
git merge day11
```

Merge 完成后，day11 分支中的修改会同步到 master。

---

# 四、删除分支

确认功能已经合并后，可以删除开发分支：

```bash
git branch -d day11
```

---

# 五、Git Branch 工作流程

```text
master（稳定版本）
        │
        ├──────────────┐
        │              │
 feature/day11     feature/docker
        │              │
        └──── Merge ───┘
               │
            master
```

实际企业开发中，每位开发人员通常都会在自己的功能分支完成开发，再通过 Merge 合并到主分支。

---

# 六、核心知识点

## Branch（分支）

作用：

* 隔离开发环境
* 避免影响主分支
* 支持多人协作
* 支持功能并行开发

---

## Switch

作用：

切换当前工作分支。

推荐使用：

```bash
git switch
```

代替旧命令：

```bash
git checkout
```

---

## Merge

作用：

将一个分支的修改整合到另一个分支。

这是团队协作中最常见的操作之一。

---

# 七、实验现象

在 day11 分支创建文件并提交后，切换回 master，新的文件不会立即显示。

原因：

Git 的每个分支拥有各自独立的工作空间，只有执行 Merge 后，修改才会同步到目标分支。

---

# 八、今日理解

今天最大的收获不是学会几个 Git 命令，而是理解了 **Git 分支存在的意义**。

在企业开发中，主分支负责保存稳定版本，而开发工作通常都在独立分支完成。这样既保证了项目稳定性，也方便多人协同开发。

分支并不是复制一份项目，而是在当前提交记录基础上创建一条新的开发路线，开发完成后再通过 Merge 合并回主分支。

---

# 九、常用命令汇总

```bash
# 查看分支
git branch

# 创建分支
git branch day11

# 切换分支
git switch day11

# 合并分支
git merge day11

# 删除分支
git branch -d day11

# 查看分支图
git log --oneline --graph --all
```

---

# 今日总结

完成：

* Git Branch 基础学习
* 创建与切换分支
* Merge 合并流程
* 理解团队协作开发模式
* 初步掌握 Git 分支管理思想

---

# 今日收获

Git Branch 是 Git 最重要的功能之一，也是现代软件开发团队协作的基础。

通过分支机制，不同开发人员可以在各自独立的环境中开发新功能，而不会影响主分支。当功能验证完成后，再通过 Merge 将修改合并到稳定版本。

这种工作模式也是后续学习 GitHub Flow、CI/CD、Jenkins 自动部署以及 Kubernetes 持续交付的重要基础。

---

# Day11 完成 ✅

**下一阶段：Day12 —— Git Merge Conflict（合并冲突）与多人协作模拟**
