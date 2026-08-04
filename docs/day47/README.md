# Day47 - Harbor 私有镜像仓库部署与 Docker 集成

## 今日目标

- 部署 Harbor 私有镜像仓库
- 配置 Docker 与 Harbor Registry 集成
- 完成 Docker 镜像上传 Harbor
- 理解企业私有镜像仓库工作流程
- 解决 Rocky Linux 环境中的 Docker / Podman 冲突
- 学习 DevOps 项目中的 Git 文件管理规范


---

# 一、实验环境

## 系统

```
Rocky Linux 9.8
```

## Docker

```
Docker CE 29.7.1
```

## Harbor

```
Harbor v2.13.2
```

目录：

```
k8s/labs/day47/harbor/harbor
```


目录结构：

```
harbor/
├── harbor.yml
├── harbor.yml.tmpl
├── prepare
├── install.sh
└── LICENSE
```


---

# 二、Harbor 初始化配置


## 执行 prepare


```bash
./prepare
```


第一次执行遇到：

```
ERROR:
The protocol is https but attribute ssl_cert is not set
```


原因：

Harbor 默认开启 HTTPS，但是没有配置 SSL 证书。


修改：

```yaml
hostname: harbor.local

http:
  port: 80

# https:
#   port: 443
```


重新执行：

```bash
./prepare
```


成功生成：

```
docker-compose.yml
common/config
```


---

# 三、安装 Harbor


执行：

```bash
sudo ./install.sh
```


过程中：

Harbor 镜像下载较慢：

```
goharbor/harbor-core:v2.13.2
goharbor/harbor-db:v2.13.2
goharbor/registry-photon:v2.13.2
```


第一次拉取过程中：

```
connection reset by peer
```


原因：

Docker Hub 网络不稳定。


重新执行后：

```
----Harbor has been installed and started successfully.----
```


---

# 四、Harbor 服务检查


查看：

```bash
docker ps
```


运行组件：

```
harbor-core
harbor-db
harbor-portal
registry
redis
nginx
jobservice
registryctl
harbor-log
```


访问：

```
http://harbor.local
```


成功进入 Harbor Web 页面。


---

# 五、Docker 与 Podman 冲突处理


## 问题：docker 命令连接 Podman


执行：

```bash
docker info
```


出现：

```
failed to connect to the docker API at
unix:///run/user/1000/podman/podman.sock
```


原因：

系统存在：

```
podman-docker
```


docker 命令被 Podman 接管。


检查：

```bash
rpm -qf $(which docker)
```


确认：

```
docker-ce-cli
```


清理：

```bash
unset DOCKER_HOST
```


恢复：

```
docker CLI
      |
      ↓
/var/run/docker.sock
      |
      ↓
dockerd
```


---

# 六、Docker 权限问题


执行：

```bash
docker ps
```


出现：

```
permission denied while trying to connect to docker API
```


原因：

当前用户没有 docker socket 权限。


解决：

```bash
sudo usermod -aG docker guoji
```


重新登录。


验证：

```bash
docker ps
```


成功。


---

# 七、配置 Harbor HTTP Registry


## 问题


执行：

```bash
docker login harbor.local
```


出现：

```
Get "https://harbor.local/v2/":
connect: connection refused
```


原因：

Docker 默认使用 HTTPS。

当前 Harbor 使用 HTTP。


---

## 修改 Docker 配置


编辑：

```bash
sudo vim /etc/docker/daemon.json
```


加入：

```json
{
  "insecure-registries": [
    "harbor.local",
    "192.168.***.***"
  ]
}
```


重启：

```bash
sudo systemctl restart docker
```


检查：

```bash
docker info | grep -A5 Insecure
```


结果：

```
Insecure Registries:

harbor.local
192.168.***.***
```


---

# 八、配置 Harbor 域名解析


问题：

```
lookup harbor.local:
no such host
```


原因：

系统无法解析 Harbor 域名。


修改：

```bash
sudo vim /etc/hosts
```


添加：

```
192.168.157.129 harbor.local
```


验证：

```bash
getent hosts harbor.local
```


---

# 九、Docker 登录 Harbor


执行：

```bash
docker login harbor.local
```


输入：

```
Username:
admin

Password:
```


成功：

```
Login Succeeded
```


说明：

Docker 已经连接 Harbor Registry。


---

# 十、重新构建 Day46 镜像


## 问题


执行：

```bash
docker images | grep day46
```


没有结果。


原因：

Day46 使用：

```
podman build
```


构建镜像。


Podman 与 Docker 镜像存储隔离：

Podman:

```
~/.local/share/containers/storage
```


Docker:

```
/var/lib/docker
```


两者不会共享镜像。


---

## 使用 Docker 重新构建


进入：

```bash
cd k8s/labs/day46/helm-cicd-demo/app
```


构建：

```bash
docker build -t day46-demo:v2 .
```


检查：

```bash
docker images | grep day46
```


结果：

```
day46-demo:v2
```


---

# 十一、创建 Harbor 镜像 Tag


执行：

```bash
docker tag \
day46-demo:v2 \
harbor.local/project-shanghai/day46-demo:v2
```


查看：

```bash
docker images | grep day46
```


结果：

```
day46-demo:v2

harbor.local/project-shanghai/day46-demo:v2
```


两个 Tag：

```
IMAGE ID:

8824796bc836
```


说明：

两个镜像名称指向同一个镜像。


---

# 十二、Push 镜像到 Harbor


执行：

```bash
docker push harbor.local/project-shanghai/day46-demo:v2
```


上传成功：

```
The push refers to repository

44136fa355b3: Pushed
82454cdbf456: Pushed
062e450697fa: Pushed
223a653d5cce: Pushed
...

v2:
digest:
sha256:8824796bc83659108e38291288afb0afea0092056ee25fcdd9a01084ae333064
```


Harbor 镜像仓库已有：

```
project-shanghai/day46-demo:v2
```


---

# 十三、Git 提交 Harbor 项目


## Git add 权限问题


执行：

```bash
git add .
```


出现：

```
error:
open common/config/core/app.conf:
Permission denied
```


原因：

Harbor 通过：

```bash
sudo ./install.sh
```


生成文件属于：

```
root
```


当前用户无法读取。


---

# 十四、Harbor 文件 Git 管理规范


Harbor 自动生成：

```
common/
docker-compose.yml
data/
secret/
log/
```


特点：

- 自动生成
- 与服务器绑定
- 包含敏感配置
- 不适合提交 Git


---

## 应提交


```
harbor.yml

install.sh

prepare

README.md

部署脚本
```


---

## 不应提交


```
common/

docker-compose.yml

data/

secret/

log/
```


---

# 十五、配置 .gitignore


项目根目录：

```
Project-Shanghai-2027/.gitignore
```


加入：


```gitignore
# Harbor generated files

k8s/labs/day47/harbor/harbor/common/

k8s/labs/day47/harbor/harbor/docker-compose.yml


# Harbor runtime

k8s/labs/day47/harbor/harbor/data/

k8s/labs/day47/harbor/harbor/log/

k8s/labs/day47/harbor/harbor/secret/
```


---

# 十六、Git 权限污染


误执行：

```bash
sudo git add .
```


导致：

```
.git/objects
```

部分文件属于 root。


提交：

```bash
git commit
```


出现：

```
insufficient permission for adding an object
```


---

解决：

```bash
sudo chown -R guoji:guoji .git
```


恢复：

```
.git
├── objects
├── refs
├── index
└── logs
```


归属：

```
guoji:guoji
```


---

# 十七、DevOps Git 管理原则


## Git 保存


```
源码

Dockerfile

Helm Chart

Kubernetes YAML

部署脚本

配置模板

README
```


---

## Git 不保存


```
镜像 tar 文件

数据库

日志

Secret

运行缓存

自动生成配置
```


---

# 十八、今日完整 DevOps 流程


```
Developer

    ↓

Dockerfile

    ↓

docker build

    ↓

Docker Image

    ↓

Harbor Registry

    ↓

Kubernetes Pull

    ↓

Pod Running
```


---

# 十九、Day47 实验成果


完成：

✅ Harbor v2.13.2 部署

✅ Docker CE 配置

✅ Harbor HTTP Registry

✅ Docker 登录 Harbor

✅ Docker Build 镜像

✅ Harbor Tag

✅ Push 私有镜像

✅ Gitignore 优化

✅ Git 权限问题处理


最终镜像：

```
harbor.local/project-shanghai/day46-demo:v2
```


---

# 二十、下一阶段 Day48


目标：

Kubernetes 拉取 Harbor 私有镜像。


流程：

```
Kubernetes

    ↓

imagePullSecrets

    ↓

Harbor Registry

    ↓

Private Image

    ↓

Deployment

    ↓

Pod Running
```
