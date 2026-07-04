# Project Shanghai 2027

## Day 16 - GitHub Actions 多 Job CI Pipeline

**日期：2026-07-04**

---

# 今日目标

学习 GitHub Actions 中 **多 Job 流水线设计**，理解 CI Pipeline 的拆分方式以及 Job 依赖关系（`needs`）。

---

# 一、为什么要拆分 Job？

单 Job 流程的问题：

* 所有步骤混在一起
* 难以维护
* 不符合企业 CI 结构

---

# 二、CI Pipeline 标准结构

```text id="p1x9qk"
Build → Test → Report
```

拆分后结构：

```text id="m7q2pl"
Job A (Build)
Job B (Test)
Job C (Report)
```

---

# 三、Job 执行方式

## 1️⃣ 并行执行（默认）

```yaml id="k2x9pm"
jobs:
  job1:
  job2:
```

👉 同时执行

---

## 2️⃣ 顺序执行（needs）

```yaml id="n9x3pl"
jobs:
  job2:
    needs: job1
```

👉 job1 完成后才执行 job2

---

# 四、实验 CI Pipeline

结构如下：

```text id="c8m2qk"
build → test → report
```

---

## Build Job

* 创建 build 目录
* 生成模拟产物

```text id="b7p3xk"
build/app.txt
```

---

## Test Job

* 检查文件存在
* 模拟单元测试

---

## Report Job

* 输出 CI 成功结果

---

# 五、核心 YAML 结构

```yaml id="y2m8qk"
jobs:
  build:
    runs-on: ubuntu-latest

  test:
    needs: build

  report:
    needs: test
```

---

# 六、关键概念

## 1️⃣ Job

独立运行环境（独立 Runner）

---

## 2️⃣ needs

控制执行顺序：

```text id="d9x2pl"
A → B → C
```

---

## 3️⃣ Runner 隔离

每个 Job 都是独立机器：

* build 的文件不会自动传给 test
* job 之间默认隔离

---

## 4️⃣ CI Pipeline

完整自动化流程：

```text id="t8p2mk"
代码提交 → 自动构建 → 自动测试 → 自动报告
```

---

# 七、实验操作

```bash id="q8m2px"
git add .
git commit -m "Day16: Multi-job CI pipeline"
git push
```

---

# 八、企业级对应关系

你今天实现的：

```text id="v3m9qk"
build → test → report
```

在企业中对应：

```text id="a9x2pl"
compile → unit test → security scan → package → docker build → deploy
```

---

# 九、今日理解

CI 的核心不只是执行脚本，而是：

> **把流程拆解成多个独立 Job，并通过依赖关系串联起来形成流水线。**

---

# 十、今日总结

完成：

* 理解 Job 概念
* 学习 needs 依赖机制
* 构建多 Job CI Pipeline
* 理解 Runner 隔离机制
* 形成企业级 CI 流水线思维

---

# 📈 Project Shanghai 进度

```text id="p8x2qk"
Linux        ██████████ 100%
Git          ██████████ 100%
GitHub       ██████████ 100%
CI 基础       ██████████ 100%
CI 进阶       ███████░░░ 80%
Docker       ░░░░░░░░░░ 0%
Kubernetes   ░░░░░░░░░░ 0%
```

---

# 🚀 Day16 一句话总结

> CI 的进阶核心：不是写更多命令，而是设计更合理的流水线结构。

---

# 🔜 Day17 预告

下一节：

### 👉 GitHub Actions Artifact（构建产物）
