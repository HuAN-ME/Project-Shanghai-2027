# Day25 - Container Registry（镜像仓库）

## 今日目标

- 理解 Container Registry 的作用
- 学习 Image Tag
- 学习 GitHub Container Registry（GHCR）
- 登录 Registry
- Push 自定义 Image
- 理解企业镜像发布流程

---

# 一、为什么需要 Registry？

之前构建的 Image：

```
day24-nginx
```

仅存在于本地 Rocky Linux。

如果更换服务器：

```bash
podman run day24-nginx
```

将无法启动，因为目标服务器没有该镜像。

因此需要：

```
Container Registry
```

用于统一存储和分发 Image。

---

# 二、什么是 Registry？

可以理解为：

```
GitHub

↓

源码仓库
```

对应：

```
Container Registry

↓

镜像仓库
```

常见 Registry：

- Docker Hub
- GitHub Container Registry（GHCR）
- Harbor
- Quay.io

---

# 三、Image 生命周期

企业流程：

```
Developer

↓

Git Push

↓

GitHub Actions

↓

Build Image

↓

Push Registry

↓

Server Pull Image

↓

Run Container
```

目前已经完成：

✅ Build Image

今天新增：

✅ Push Registry

---

# 四、Image Tag

查看本地镜像：

```bash
podman images
```

镜像真正的格式：

```
Repository:Tag
```

例如：

```
nginx:latest
```

自己构建的镜像重新打 Tag：

```bash
podman tag day24-nginx ghcr.io/huan-me/day24-nginx:v1
```

说明：

```
Repository：

ghcr.io/huan-me/day24-nginx

Tag：

v1
```

---

# 五、登录 GHCR

登录：

```bash
podman login ghcr.io
```

用户名：

```
GitHub Username
```

密码：

```
GitHub Personal Access Token（PAT）
```

PAT 至少需要权限：

- write:packages
- read:packages

---

# 六、Push Image

上传：

```bash
podman push ghcr.io/huan-me/day24-nginx:v1
```

流程：

```
Local Image

↓

Compress Layers

↓

Upload Layers

↓

GHCR
```

上传成功后：

任何服务器：

```bash
podman pull ghcr.io/huan-me/day24-nginx:v1
```

即可获取镜像。

---

# 七、GHCR 页面验证

Push 成功后：

GitHub：

```
Profile

↓

Packages

↓

day24-nginx
```

可以看到：

- Image 名称
- Tag
- Push 时间
- Pull 地址

说明镜像已经上传成功。

---

# 八、企业中的 Registry

企业不会手工执行：

```bash
podman build
podman push
```

通常流程：

```
Git Push

↓

CI Pipeline

↓

Build Image

↓

Push Registry

↓

Deploy
```

Registry 是 DevOps 流水线的重要组成部分。

---

# 九、今日踩坑记录

## 坑1：GHCR Repository 必须使用小写

第一次 Push 时出现错误：

```
repository name must be lowercase
```

原因：

GitHub Container Registry 对 Repository 名称有严格要求：

```
全部必须使用 lowercase
```

例如：

错误：

```
ghcr.io/HuAN-ME/day24-nginx:v1
```

正确：

```
ghcr.io/huan-me/day24-nginx:v1
```

这是 GHCR 的命名规范，与 GitHub 用户名是否包含大写无关。

---

## 坑2：PAT 不能使用 GitHub 登录密码

登录 GHCR：

```
podman login ghcr.io
```

Password：

不能输入 GitHub 登录密码。

必须使用：

```
Personal Access Token (PAT)
```

否则认证失败。

---

## 坑3：Image Tag 并不会复制镜像

执行：

```bash
podman tag day24-nginx ghcr.io/huan-me/day24-nginx:v1
```

不会生成新的 Image。

只是：

```
一个 Image

↓

多个 Tag
```

可以通过：

```bash
podman images
```

观察：

两个 Repository

对应：

同一个 IMAGE ID。

---

# 十、核心命令总结

查看镜像：

```bash
podman images
```

打 Tag：

```bash
podman tag local-image ghcr.io/username/image:v1
```

登录：

```bash
podman login ghcr.io
```

上传：

```bash
podman push ghcr.io/username/image:v1
```

拉取：

```bash
podman pull ghcr.io/username/image:v1
```

查看 Image 信息：

```bash
podman inspect image-name
```

---

# 十一、今日知识总结

Day25 学习了 Image Registry。

完整生命周期：

```
Containerfile

↓

Build

↓

Image

↓

Tag

↓

Registry

↓

Pull

↓

Container
```

Registry 相当于：

```
GitHub

↓

源码

Registry

↓

镜像
```

企业通过 Registry 完成镜像分发和版本管理。

---

# 今日记忆点

一句话：

> **Image 可以在本地构建，但真正的企业交付一定依赖 Registry。**

---

# Day25 完成 ✅

当前 Project Shanghai 技术栈：

```
Linux

+

Git / GitHub

+

GitHub Actions

+

Podman

+

Network

+

Volume

+

Image Build

+

Container Registry（GHCR） ✅
```

下一阶段：

Day26：

## GitHub Actions 自动构建镜像

学习：

- Git Push
- 自动 Build Image
- 自动 Push GHCR
- 自动生成最新版本镜像

正式完成 DevOps 自动化镜像发布流程。
