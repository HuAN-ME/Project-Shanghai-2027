# Project Shanghai 2027

## Day 10 - GitHub 远程仓库（Remote Repository）

**日期：2026-06-28**

---

# 今日目标

学习：

* GitHub 远程仓库
* SSH Key 认证
* Git Remote
* git push
* git pull

理解 Git 在团队协作中的作用。

---

# 一、GitHub 与 Git 的区别

Git：

```text
本地版本控制工具
```

GitHub：

```text
远程代码托管平台
```

Git 负责管理本地代码历史，GitHub 负责代码同步、团队协作和远程备份。

---

# 二、SSH Key

查看 SSH 目录：

```bash
ls ~/.ssh
```

生成密钥：

由于 Rocky Linux 开启 FIPS 模式，不支持 ED25519，因此使用 RSA：

```bash
ssh-keygen -t rsa -b 4096 -C "GitHub邮箱"
```

生成文件：

```text
~/.ssh/
├── id_rsa
├── id_rsa.pub
└── known_hosts
```

其中：

* `id_rsa`：私钥（严禁泄露）
* `id_rsa.pub`：公钥（上传 GitHub）

---

# 三、添加 SSH Key

GitHub：

```text
Settings
    ↓
SSH and GPG keys
    ↓
New SSH key
```

将 `id_rsa.pub` 全部内容复制到 GitHub。

---

# 四、测试连接

```bash
ssh -T git@github.com
```

首次连接：

```text
Are you sure you want to continue connecting?
```

输入：

```text
yes
```

成功后即可通过 SSH 与 GitHub 通信。

---

# 五、关联远程仓库

查看远程仓库：

```bash
git remote -v
```

结果：

```text
origin
git@github.com:HuAN-ME/Project-Shanghai-2027.git
```

说明：

本地仓库已经与 GitHub 建立连接。

---

# 六、查看分支

```bash
git branch
```

当前：

```text
master
```

表示当前工作分支为 master。

---

# 七、Push 与 Pull

首次推送：

```bash
git push -u origin master
```

之后：

```bash
git push
```

即可同步最新修改。

下载远程更新：

```bash
git pull
```

---

# 八、实验现象

执行：

```bash
git push
```

输出：

```text
Everything up-to-date
```

说明：

* 本地仓库与远程仓库完全一致
* 当前没有新的 Commit 需要上传

这是 Git 的正常状态。

---

# 九、Git 工作流程

```text
Working Tree
      │
git add
      │
Stage
      │
git commit
      │
Local Repository
      │
git push
      │
GitHub Repository
```

GitHub 成为了整个 DevOps 流程中的远程代码中心。

---

# 十、今日排障记录

### 问题一

```text
ED25519 keys are not allowed in FIPS mode
```

原因：

Rocky Linux 开启 FIPS 模式，不允许生成 ED25519 密钥。

解决方案：

```bash
ssh-keygen -t rsa -b 4096
```

---

### 问题二

```text
Permission denied (publickey)
```

排查过程：

1. 检查 SSH 密钥是否生成
2. 确认 SSH 已读取 RSA 私钥
3. 查看调试日志（ssh -vT）
4. 确认 GitHub 未添加公钥

最终原因：

GitHub 的 **SSH and GPG Keys** 中未添加 `id_rsa.pub`。

添加公钥后恢复正常。

---

# 十一、核心知识点

## Git 与 GitHub

```text
Git      = 本地版本控制
GitHub   = 云端代码托管
```

---

## SSH Key

```text
私钥（id_rsa）
        │
身份认证
        │
公钥（id_rsa.pub）
        │
上传 GitHub
```

SSH 利用公钥加密机制实现免密码登录，提高安全性。

---

## git push

作用：

```text
将本地 Repository 同步到远程 Repository。
```

---

## git pull

作用：

```text
获取远程最新代码并同步到本地。
```

---

## Git Remote

查看：

```bash
git remote -v
```

作用：

记录本地仓库对应的远程仓库地址。

---

# 今日总结

完成：

* GitHub 仓库创建
* SSH Key 配置
* Git Remote 配置
* Git Push
* Git Pull
* SSH 公钥认证
* GitHub 排障实践

---

# 今日收获

今天不仅完成了 GitHub 的配置，更重要的是经历了一次真实的企业级排障流程。

面对 `Permission denied (publickey)` 错误，没有盲目修改配置，而是通过查看 SSH 日志、验证密钥、检查 GitHub 配置，最终准确定位问题并解决。

这也是 DevOps 工程师日常工作的核心能力：

> **通过日志定位问题，通过证据分析问题，而不是依赖猜测。**

---

# Day10 完成 ✅

下一阶段：

**Day11 —— Git Branch（分支管理）与团队协作**
