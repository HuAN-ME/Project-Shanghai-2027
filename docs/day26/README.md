# Day26 - GitHub Actions 自动构建镜像

## 今日目标

- 理解 CI（Continuous Integration）
- 学习 GitHub Actions 自动构建镜像
- 学习自动登录 GHCR
- 自动 Build Image
- 自动 Push Image
- 理解 Build Context

---

# 一、为什么需要 CI？

如果每次修改代码都需要：

```bash
podman build
podman tag
podman push
```

不仅效率低，而且容易出现：

- 忘记 Build
- Tag 写错
- Push 漏掉
- 本地环境与服务器环境不一致

企业通常采用：

```
Git Push

↓

GitHub Actions

↓

Build Image

↓

Push Registry
```

开发者只需要提交代码，其余流程全部自动完成。

---

# 二、Workflow 文件

本次创建：

```
.github/workflows/day26.yml
```

Workflow 在 push 到 master 分支后自动执行。

主要步骤：

```
Checkout Repository

↓

Login GHCR

↓

Build Image

↓

Push Image
```

---

# 三、Workflow 主要内容

学习了三个常用 Action：

## 1、Checkout

```yaml
uses: actions/checkout@v4
```

作用：

将 GitHub 仓库代码下载到 Runner。

---

## 2、Login GHCR

```yaml
uses: docker/login-action@v3
```

作用：

自动登录 GitHub Container Registry。

认证方式：

```
GITHUB_TOKEN
```

而不是手动输入 PAT。

---

## 3、Build Image

使用：

```bash
podman build
```

构建镜像。

指定 Build Context：

```
./containers/nginx
```

而不是：

```
.
```

---

## 4、Push Image

上传：

```bash
podman push
```

上传完成后：

GitHub Packages

即可看到新的镜像版本。

---

# 四、Build Context

今天最大的知识点：

```
podman build
```

最后一个参数：

```
.
```

并不是：

"当前命令"

而是：

```
Build Context
```

GitHub Runner：

会在指定目录寻找：

```
Containerfile

或

Dockerfile
```

如果找不到：

```
Exit Code 125
```

---

# 五、项目结构优化

为了便于后续维护，将容器项目整理到统一目录：

```
Project-Shanghai-2027/

├── containers/
│   └── nginx/
│       ├── Containerfile
│       └── index.html
│
├── .github/
│   └── workflows/
│       └── day26.yml
│
├── docs/
├── labs/
├── scripts/
└── README.md
```

以后所有容器项目统一放置：

```
containers/
```

便于：

- Docker Compose
- Kubernetes
- 多服务管理

---

# 六、GitHub Actions 工作流程

```
Git Push

↓

GitHub Runner

↓

Checkout

↓

Login GHCR

↓

Build Image

↓

Push Image

↓

GitHub Packages
```

整个流程无需人工干预。

---

# 七、今日踩坑记录

## 坑1：找不到 Containerfile

错误：

```
Error:
no Containerfile or Dockerfile specified
```

原因：

Workflow：

```
podman build .
```

默认在仓库根目录寻找：

```
Containerfile
```

仓库根目录不存在该文件。

解决：

修改 Build Context：

```bash
podman build ./containers/nginx
```

---

## 坑2：GHCR Repository 必须使用小写

之前上传时：

```
repository name must be lowercase
```

原因：

GHCR Repository 名称要求全部小写。

例如：

错误：

```
ghcr.io/HuAN-ME/project-shanghai
```

正确：

```
ghcr.io/huan-me/project-shanghai
```

这是 GHCR 的命名规范。

---

## 坑3：Node.js 20 Deprecated

Actions 日志提示：

```
Node.js 20 is deprecated
```

这是 GitHub Runner 的升级提醒。

属于 Warning。

不会影响 Workflow 执行。

可以忽略。

---

## 坑4：Exit Code 125

最初误以为：

```
Podman
```

没有安装。

实际上：

真正原因：

```
Build Context
```

指定错误。

说明：

CI 环境排查问题时，

应优先查看：

```
Build Step

完整日志
```

而不是只关注：

```
Exit Code
```

---

# 八、核心命令

Build：

```bash
podman build -t image-name ./containers/nginx
```

Push：

```bash
podman push ghcr.io/huan-me/project-shanghai:latest
```

查看镜像：

```bash
podman images
```

查看 Workflow：

GitHub

```
Actions
```

查看镜像：

GitHub

```
Packages
```

---

# 九、今日总结

Day26 学习了 GitHub Actions 自动构建镜像。

理解了：

```
Developer

↓

Git Push

↓

GitHub Actions

↓

Build Image

↓

Push GHCR

↓

Registry
```

同时理解：

Build Context

是容器构建过程中最重要的概念之一。

CI 不只是自动执行命令，

更重要的是保证：

统一环境、

统一流程、

统一产物。

---

# 今日记忆点

一句话：

> **CI 的目标不是替代开发者，而是让每一次代码提交都能够以相同流程、相同环境，自动构建出可交付的镜像。**

---

# Day26 完成 ✅

Project Shanghai 当前技术栈：

```
Linux

+

Git

+

GitHub

+

GitHub Actions

+

Podman

+

Container

+

Network

+

Volume

+

Image Build

+

GHCR

+

CI（GitHub Actions 自动构建）✅
```
