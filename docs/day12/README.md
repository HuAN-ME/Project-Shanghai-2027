# Project Shanghai 2027

## Day 12 - Git Merge Conflict（合并冲突）

**日期：2026-06-30**

---

# 今日目标

学习 Git Merge Conflict（合并冲突）的产生原因，并掌握冲突的查看、解决以及合并流程，理解 Git 在团队协作中的工作机制。

---

# 一、什么是 Merge Conflict？

Merge Conflict（合并冲突）是指两个分支同时修改了同一个文件的同一部分内容，Git 无法自动判断应该保留哪一份修改，因此需要开发者手动处理。

Git 不会擅自替开发者做决定，而是将冲突位置标记出来，由开发者确认最终内容。

---

# 二、实验流程

## 创建功能分支

```bash
git switch -c feature-a
```

修改 README.md 后提交：

```bash
git add README.md
git commit -m "Feature A"
```

返回主分支，再创建第二个分支：

```bash
git switch master
git switch -c feature-b
```

同样修改 README.md，并提交：

```bash
git add README.md
git commit -m "Feature B"
```

---

## 合并分支

首先合并第一个分支：

```bash
git switch master
git merge feature-a
```

随后继续合并：

```bash
git merge feature-b
```

Git 检测到两个分支修改了同一位置，产生 Merge Conflict。

---

# 三、冲突文件

发生冲突后，README.md 会出现类似内容：

```text
<<<<<<< HEAD
Feature A
=======
Feature B
>>>>>>> feature-b
```

含义如下：

* `<<<<<<< HEAD`：当前分支内容
* `=======`：分隔线
* `>>>>>>> feature-b`：待合并分支内容

开发者需要根据实际需求保留正确内容，并删除这些冲突标记。

---

# 四、解决冲突

编辑完成后：

```bash
git add README.md
git commit
```

Git 会自动生成 Merge Commit，表示冲突已经解决。

---

# 五、查看提交历史

使用：

```bash
git log --oneline --graph --all
```

查看分支结构：

```text
*   Merge branch 'feature-b'
|\
| * Feature B
* | Feature A
|/
*
```

可以直观地看到两个功能分支最终合并回主分支的过程。

---

# 六、核心知识点

## Merge Conflict

本质：

Git 无法自动判断多个开发者修改同一位置时应该保留哪份内容，因此交由开发者处理。

---

## Merge Commit

作用：

记录一次分支合并操作，并保存两个分支的历史关系。

---

## Git Graph

通过图形化提交历史，可以清晰了解：

* 分支创建
* 分支开发
* Merge 合并
* 项目演进过程

---

# 七、今日理解

今天最大的收获是理解了 **Merge Conflict 并不是 Git 出错，而是 Git 的保护机制**。

Git 能够自动合并绝大多数修改，但对于同一位置的冲突，它不会擅自覆盖，而是交由开发者决定最终结果。

在团队协作开发中，Merge Conflict 是一种非常常见的现象，解决冲突也是开发者需要掌握的基本能力。

---

# 八、常用命令汇总

```bash
# 创建并切换分支
git switch -c feature-a

# 切换分支
git switch master

# 合并分支
git merge feature-a

# 查看状态
git status

# 查看提交历史
git log --oneline --graph --all

# 标记冲突已解决
git add README.md

# 完成 Merge Commit
git commit
```

---

# 今日总结

完成：

* 理解 Merge Conflict 产生原因
* 创建多个功能分支
* 模拟多人开发场景
* 手动解决冲突
* 完成 Merge Commit
* 学会使用 Git Graph 查看提交历史

---

# 今日收获

Merge Conflict 是团队协作开发中的正常现象，而不是 Git 的错误。

Git 的设计理念是保护代码安全，在无法确定最终结果时，由开发者进行人工确认。

掌握分支管理与冲突解决后，已经具备了 Git 团队协作的基础能力，这也是后续学习 GitHub Pull Request、Code Review、CI/CD 流程的重要前提。

---

# Day12 完成 ✅

**下一阶段：Day13 —— GitHub Pull Request（PR）与团队协作开发流程**

