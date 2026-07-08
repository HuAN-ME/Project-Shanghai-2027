# Day20 - Container 生命周期管理（Podman）

## 今日目标

- 理解 Container 生命周期
- 掌握镜像拉取与容器创建流程
- 学习容器启动、停止、删除
- 学习查看容器日志
- 学习进入运行中的容器
- 处理容器运行中的常见问题

---

# 一、容器生命周期

Container 并不是 Image 本身，而是 Image 创建出来的运行实例。

完整流程：

```
Registry

↓

Image

↓

Create Container

↓

Start Container

↓

Running

↓

Stop

↓

Remove
```

注意：

```
Container 停止 ≠ Container 删除
```

停止后的 Container 仍然存在：

```bash
podman ps -a
```

可以查看。

---

# 二、Docker Hub 网络问题排查

## 问题

执行：

```bash
podman run nginx
```

出现：

```
Failed to connect to registry-1.docker.io port 443
connection refused
```

---

## 排查过程

### 1. 确认 Podman 正常

```bash
podman version
```

结果正常。

说明：

Container Runtime 没有问题。

---

### 2. 测试 Registry 网络

```bash
curl -I https://registry-1.docker.io/v2/
```

返回：

```
connection refused
```

确认：

Docker Hub Registry HTTPS 访问失败。

---

## 解决方案

配置 Registry Mirror。

文件：

```bash
~/.config/containers/registries.conf
```

添加：

```toml
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.m.daocloud.io"
```

作用：

原流程：

```
Podman

↓

docker.io

↓

registry-1.docker.io
```

修改后：

```
Podman

↓

docker.io

↓

Mirror Registry

↓

Image
```

---

# 三、拉取 nginx 镜像

执行：

```bash
podman pull nginx
```

成功：

```
Trying to pull docker.io/library/nginx:latest
```

说明：

镜像仓库配置成功。

查看镜像：

```bash
podman images
```

Image 结构：

```
nginx Image

├── Layer 1
├── Layer 2
├── Layer 3
└── Config
```

重复下载时：

```
blob skipped: already exists
```

说明：

已有 Layer 被复用。

---

# 四、运行 nginx 容器

命令：

```bash
podman run -d --name web nginx
```

参数：

```
-d
后台运行

--name web
指定容器名称
```

---

# 五、容器名称冲突问题

错误：

```
container name "web" is already in use
```

原因：

已经存在：

```
Container:
web
```

Podman 不允许重复名称。

---

解决方式：

## 方法1：删除旧容器

查看：

```bash
podman ps -a
```

停止：

```bash
podman stop web
```

删除：

```bash
podman rm web
```

---

## 方法2：更换名称

例如：

```bash
podman run -d --name nginx-test nginx
```

---

## 方法3：自动替换

```bash
podman run -d --replace --name web nginx
```

---

# 六、查看运行状态

查看运行中的容器：

```bash
podman ps
```

示例：

```
IMAGE
nginx:latest

STATUS
Up

NAME
web
```

---

查看所有容器：

```bash
podman ps -a
```

包括：

- Running
- Exited
- Created

---

# 七、查看容器日志

命令：

```bash
podman logs web
```

输出：

```
Configuration complete; ready for start up
```

说明：

nginx 已完成初始化。

日志是生产环境排障的重要工具。

常见流程：

```
服务异常

↓

查看 logs

↓

定位错误
```

---

# 八、进入容器内部

命令：

```bash
podman exec -it web bash
```

参数：

```
exec
执行命令

-i
保持输入

-t
分配终端
```

进入：

```
root@container
```

查看：

```bash
ls
```

看到：

```
bin
etc
usr
var
docker-entrypoint.sh
```

说明：

进入的是 nginx 镜像自己的文件系统。

---

退出：

```bash
exit
```

---

# 九、停止和删除容器

停止：

```bash
podman stop web
```

删除：

```bash
podman rm web
```

生命周期：

```
Running

↓

Stopped

↓

Removed
```

---

# 十、今日踩坑记录

## 坑1：Docker Hub 无法访问

错误：

```
registry-1.docker.io:443 connection refused
```

原因：

网络无法访问 Docker Hub。

解决：

配置 Registry Mirror。

---

## 坑2：镜像名称拼写错误

错误：

```bash
podman run neginx
```

正确：

```bash
podman run nginx
```

原因：

不存在：

```
neginx
```

镜像。

---

## 坑3：容器名称冲突

错误：

```
container name already in use
```

原因：

已有同名 Container。

解决：

```bash
podman rm container_name
```

或者：

```bash
--replace
```

---

# 十一、今日核心命令

|功能|命令|
|-|-|
|拉取镜像|`podman pull nginx`|
|查看镜像|`podman images`|
|运行容器|`podman run`|
|后台运行|`podman run -d`|
|查看运行容器|`podman ps`|
|查看所有容器|`podman ps -a`|
|查看日志|`podman logs`|
|进入容器|`podman exec -it`|
|停止容器|`podman stop`|
|删除容器|`podman rm`|

---

# 十二、今日总结

Day20 正式完成 Container 生命周期学习。

今天掌握：

- Registry 到 Image 的关系
- Image 到 Container 的创建流程
- Container 生命周期管理
- 容器日志查看
- 容器内部环境访问
- Registry 网络问题排查

核心理解：

```
Image 是模板

Container 是运行实例

一个 Image 可以创建多个 Container
```

同时完成了一次真实 DevOps 排障：

```
Container Runtime

↓

Registry

↓

Network

↓

Mirror

↓

成功运行服务
```
