# Project Shanghai 2027

## Day 17 - GitHub Actions Artifact 与 CI 数据流

**日期：2026-07-05**

---

# 今日目标

深入理解 GitHub Actions 中 **Artifact（构建产物）机制**，并掌握：

* Job 之间的隔离机制
* Artifact 上传与下载
* CI 中的数据流转方式
* 企业级 CI Pipeline 的完整执行过程

---

# 一、核心问题：为什么需要 Artifact？

在 GitHub Actions 中：

```text id="a1"
每个 Job = 独立 Runner（独立虚拟机）
```

因此：

```text id="a2"
build 产生的文件
❌ 不会自动传给 test
```

示例：

```text id="a3"
build/
 └── app.txt
```

在 build Job 结束后：

👉 Runner 会被销毁
👉 文件全部消失

---

# 二、Artifact 是什么？

Artifact 是：

> GitHub Actions 用来在 Job 之间传递文件的机制

---

# 三、CI 数据流（核心理解）

```text id="a4"
Build Job
   │
   ▼
生成 build/app.txt
   │
   ▼
Upload Artifact
   │
   ▼
GitHub Artifact Storage
   │
   ▼
Download Artifact
   │
   ▼
Test Job
   │
   ▼
使用文件
```

---

# 四、Workflow 三阶段结构

## 1️⃣ Build Job

职责：

* 创建构建目录
* 生成产物
* 上传 Artifact

```text id="b1"
build/app.txt
```

---

## 2️⃣ Test Job

职责：

* 下载 Artifact
* 验证文件
* 模拟测试逻辑

---

## 3️⃣ Report Job

职责：

* 汇总结果
* 输出 CI 成功状态

---

# 五、关键 YAML 结构

```yaml id="y1"
jobs:
  build:
  test:
    needs: build
  report:
    needs: test
```

---

# 六、核心机制解析

## 1️⃣ Runner 隔离

```text id="c1"
每个 Job = 一台全新 Ubuntu VM
```

特点：

* 不共享文件
* 不共享内存
* 不共享环境

---

## 2️⃣ Artifact 作用

```text id="c2"
连接不同 Job 的唯一方式
```

---

## 3️⃣ 数据流模型

```text id="c3"
代码 → build → artifact → test → report
```

---

# 七、企业级 CI 对应关系

```text id="d1"
Build        → 编译
Test         → 单元测试
Artifact     → 构建产物存储
Deploy       → 发布
```

---

# 八、执行流程总结

```text id="e1"
Git Push
  ↓
GitHub Actions
  ↓
Build Runner
  ↓
Upload Artifact
  ↓
Test Runner
  ↓
Download Artifact
  ↓
Report Runner
  ↓
CI Success ✔
```

---

# 九、今日核心概念

| 概念       | 含义          |
| -------- | ----------- |
| Job      | 独立执行单元      |
| Runner   | 执行 Job 的虚拟机 |
| Artifact | Job 之间传递文件  |
| Upload   | 上传构建产物      |
| Download | 下载构建产物      |
| needs    | 控制执行顺序      |

---

# 十、今日理解总结

GitHub Actions 的本质不是执行命令，而是：

> **通过多个独立环境（Runner）执行分阶段任务，并通过 Artifact 完成数据传递的流水线系统。**

---

# 📈 Project Shanghai 进度

```text
Linux        ██████████ 100%
Git          ██████████ 100%
GitHub       ██████████ 100%

CI 基础       ██████████ 100%
CI 进阶       ██████████ 100%

Docker       ░░░░░░░░░░ 0%
Kubernetes   ░░░░░░░░░░ 0%
```

---

# 🚀 Day17 一句话总结

> Artifact 的本质是：让“不同机器之间的 CI 流程”能够传递数据。
