```text
docs/day59.md
```

内容如下：

---

# Day59 - GitHub Actions CI 集成 Harbor 私有仓库

## 一、实验目标

完成从代码提交到镜像构建、推送 Harbor 的自动化 CI 流程。

目标链路：

```
Git Push
    |
    ↓
GitHub Actions
    |
    ↓
Self-hosted Runner (Rocky Linux)
    |
    ↓
Docker Build
    |
    ↓
Harbor Registry
    |
    ↓
Kubernetes 部署
```

---

# 二、实验环境

## 主机环境

| 组件         | 信息                                |
| ---------- | --------------------------------- |
| OS         | Rocky Linux 9.8                   |
| Docker     | 已安装                               |
| Harbor     | v2.13.2                           |
| Kubernetes | Minikube                          |
| Runner     | GitHub Actions Self-hosted Runner |
| Registry   | Harbor Private Registry           |

---

## Harbor 状态检查

启动 Harbor：

```bash
cd ~/Project-Shanghai-2027/k8s/labs/day47/harbor/harbor

docker compose up -d
```

检查：

```bash
docker compose ps
```

所有核心服务：

```
healthy
```

验证 Web：

```bash
curl -k https://localhost
```

登录成功。

---

# 三、Harbor 镜像推送验证

测试镜像：

```bash
docker pull nginx:latest
```

重新打标签：

```bash
docker tag nginx:latest harbor.local/library/nginx:test
```

登录 Harbor：

```bash
docker login harbor.local
```

推送：

```bash
docker push harbor.local/library/nginx:test
```

成功：

```
digest: sha256:xxxx
```

说明 Harbor Registry 工作正常。

---

# 四、GitHub Actions Runner 配置

## Runner 状态检查

进入：

```bash
cd ~/actions-runner
```

查看：

```bash
sudo ./svc.sh status
```

状态：

```
active (running)
```

Runner 已注册并作为 systemd 服务运行。

---

# 五、CI Workflow

## Pipeline 流程

```
Checkout Code

↓

Docker Login Harbor

↓

Docker Build Image

↓

Docker Tag

↓

Docker Push Harbor
```

---

核心步骤：

```yaml
- name: Login Harbor
  run: |
    docker login harbor.local \
      -u ${{ secrets.HARBOR_USER }} \
      -p ${{ secrets.HARBOR_PASSWORD }}

- name: Build Image
  run: |
    docker build \
      -t harbor.local/project/day59-demo .

- name: Push Image
  run: |
    docker push harbor.local/project/day59-demo
```

---

# 六、问题排查：Runner 无法访问 GitHub

## 问题现象

GitHub Actions:

```
Connection refused

Failed to connect to github.com port 443
```

---

## 排查过程

### 1. 检查 Rocky 网络

查看路由：

```bash
ip route
```

确认：

```
default via 192.168.157.2
```

网络正常。

---

### 2. 检查 Windows Host

Windows 代理监听：

```
TCP 192.168.157.1:7890 LISTENING
```

---

### 3. 测试端口连通性

Rocky:

```bash
nc -vz -w 3 192.168.157.1 7890
```

之前：

```
TIMEOUT
```

原因：

Windows 防火墙阻止局域网访问代理端口。

---

## 解决方案

开放 Windows 防火墙规则：

允许：

```
TCP 7890
```

重新测试：

```bash
nc -vz -w 3 192.168.157.1 7890
```

结果：

```
Connected
```

---

# 七、验证代理访问 GitHub

测试：

```bash
curl -x http://192.168.157.1:7890 https://github.com
```

返回：

```
HTTP 200
```

说明：

```
Rocky
 ↓
VMware NAT
 ↓
Windows Proxy
 ↓
GitHub
```

网络链路恢复。

---

# 八、Runner 注入代理环境变量

由于 Runner 由 systemd 管理，需要单独配置。

编辑：

```bash
sudo systemctl edit actions.runner.xxx.service
```

添加：

```ini
[Service]

Environment="HTTP_PROXY=http://192.168.157.1:7890"

Environment="HTTPS_PROXY=http://192.168.157.1:7890"

Environment="NO_PROXY=localhost,127.0.0.1,harbor.local"
```

重新加载：

```bash
sudo systemctl daemon-reload

sudo systemctl restart actions.runner.xxx.service
```

确认：

```bash
sudo systemctl show actions.runner.xxx.service | grep Environment
```

---

# 九、最终结果

GitHub Actions:

```
Checkout          ✅

Docker Login      ✅

Docker Build      ✅

Docker Push       ✅
```

CI Pipeline 全流程成功。

---

# 十、Day59 总结

## 学习成果

完成：

* GitHub Actions 自动化构建
* Self-hosted Runner 部署
* Harbor 私有镜像仓库集成
* Docker 镜像自动推送
* CI 网络问题排障

## 遇到的问题

### 1. Runner 无法访问 GitHub

原因：

* Windows Proxy 未允许 VMnet8 访问
* 防火墙阻止 7890 TCP

解决：

* 开放代理 LAN 访问
* 配置 Windows 防火墙
* systemd 注入代理变量

---

## 当前 DevOps 链路

```
Developer

↓

GitHub

↓

GitHub Actions

↓

Self-hosted Runner

↓

Docker Build

↓

Harbor

↓

Kubernetes
```

Day59 完成 CI 阶段闭环。
