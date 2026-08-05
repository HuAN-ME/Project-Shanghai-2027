```md
# Day48: Harbor + Kubernetes Private Registry Integration

## 今日目标

将 Kubernetes 集群接入 Harbor 私有镜像仓库，实现：

- Harbor HTTPS 化
- Docker 客户端信任 Harbor CA
- Minikube 节点访问 Harbor
- Kubernetes 使用 imagePullSecrets 拉取私有镜像
- Helm 部署应用并从 Harbor 拉取镜像


---

# 1. 项目结构整理

Day48 最终目录：

```

day48
└── harbor-k8s-demo
├── README.md
├── helm
│   └── harbor-demo-chart
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── ingress.yaml
│           └── ...
└── manifests

```

说明：

- helm:
  Kubernetes 应用部署模板

- manifests:
  保存 Kubernetes 原生资源文件


---

# 2. Harbor 镜像准备

Day46 镜像：

```

day46-demo:v2

````

重新 Tag：

```bash
docker tag \
day46-demo:v2 \
harbor.local/project-shanghai/day46-demo:v2
````

查看：

```bash
docker images | grep day46
```

结果：

```
day46-demo:v2

harbor.local/project-shanghai/day46-demo:v2
```

---

# 3. 推送镜像到 Harbor

登录：

```bash
docker login harbor.local
```

推送：

```bash
docker push harbor.local/project-shanghai/day46-demo:v2
```

成功：

```
v2: digest:
sha256:8824796bc836...
```

验证：

```bash
curl http://harbor.local/v2/
```

返回：

```json
{
 "errors":[
   {
    "code":"UNAUTHORIZED",
    "message":"unauthorized"
   }
 ]
}
```

说明 Harbor Registry API 正常。

---

# 4. Harbor HTTP 转 HTTPS

## 问题

最初 Harbor 使用 HTTP：

Kubernetes 拉取镜像：

```
Get https://harbor.local/v2/
connection refused
```

原因：

Kubernetes 默认使用 HTTPS 访问 Registry。

---

# 5. Harbor HTTPS 配置

修改：

```
harbor/harbor.yml
```

配置：

```yaml
https:
  port: 443
  certificate: /data/cert/harbor.local.crt
  private_key: /data/cert/harbor.local.key
```

生成证书目录：

```bash
sudo mkdir -p /data/cert
```

复制：

```bash
sudo cp data/cert/harbor.local.crt /data/cert/

sudo cp data/cert/harbor.local.key /data/cert/
```

重新生成配置：

```bash
./prepare
```

重新启动：

```bash
docker compose down

docker compose up -d
```

验证：

```bash
ss -lntp | grep 443
```

结果：

```
LISTEN 0 4096 0.0.0.0:443
```

测试：

```bash
curl -k https://harbor.local/v2/
```

返回：

```json
{
"errors":[
 {
  "code":"UNAUTHORIZED"
 }
]
}
```

HTTPS Harbor 正常。

---

# 6. Docker 信任 Harbor CA

问题：

```
x509:
certificate signed by unknown authority
```

解决：

创建：

```
/etc/docker/certs.d/harbor.local/
```

复制 CA：

```
ca.crt
```

目录：

```
/etc/docker/certs.d/
└── harbor.local
    └── ca.crt
```

测试：

```bash
docker login harbor.local
```

结果：

```
Login Succeeded
```

---

# 7. Minikube 配置 Harbor Trust

进入 Minikube：

```bash
minikube ssh
```

测试：

```bash
curl -k https://harbor.local/v2/
```

返回：

```json
{
"errors":[
 {
  "code":"UNAUTHORIZED"
 }
]
}
```

说明网络链路正常。

配置 Docker：

```
/etc/docker/certs.d/harbor.local/ca.crt
```

重新登录：

```bash
docker login harbor.local
```

成功：

```
Login Succeeded
```

---

# 8. Kubernetes 创建 Harbor Secret

创建：

```bash
kubectl create secret docker-registry harbor-secret \
--docker-server=harbor.local \
--docker-username=admin \
--docker-password=<password>
```

查看：

```bash
kubectl get secret
```

结果：

```
harbor-secret
```

---

# 9. Helm 配置 imagePullSecrets

deployment.yaml:

```yaml
spec:
  imagePullSecrets:
    - name: harbor-secret

  containers:
    - name: demo-chart
      image: harbor.local/project-shanghai/day46-demo:v2
```

最终：

```yaml
imagePullSecrets:
  - name: harbor-secret
```

用于 Kubernetes 拉取私有镜像。

---

# 10. 第一次部署失败

错误：

```
ErrImagePull

ImagePullBackOff
```

原因：

Kubernetes 节点不信任 Harbor HTTPS。

排查：

```bash
kubectl describe pod
```

发现：

```
Failed to pull image

connect: connection refused
```

---

# 11. Harbor HTTPS 链路修复

检查 Harbor：

```bash
docker compose up -d
```

确认：

```bash
ss -lntp | grep 443
```

结果：

```
443 LISTEN
```

测试：

```bash
curl -k https://harbor.local/v2/
```

成功。

---

# 12. Kubernetes 重新部署

重新安装 Helm：

```bash
helm upgrade --install \
harbor-demo \
./helm/harbor-demo-chart
```

删除旧 Pod：

```bash
kubectl delete pod <old-pod>
```

原因：

旧 Pod 保存 ImagePullBackOff 状态。

新的 Pod：

```bash
kubectl get pods
```

最终：

```
NAME                          READY   STATUS

harbor-demo-demo-chart-xxx    1/1     Running
```

---

# 13. 遇到的问题总结

## 问题1：Harbor 端口冲突

现象：

```
docker login harbor.local

404 Not Found
```

原因：

宿主机 nginx 占用了 80 端口。

解决：

```bash
systemctl stop nginx
```

让 Harbor 自带 nginx 接管。

---

## 问题2：Minikube Docker restart

执行：

```bash
systemctl restart docker
```

导致：

```
kubectl connection refused
```

原因：

Minikube 内 Docker 重启影响 Kubernetes 组件。

恢复：

```bash
minikube start
```

---

## 问题3：HTTPS 证书问题

错误：

```
x509:
certificate signed by unknown authority
```

解决：

添加 CA：

```
/etc/docker/certs.d/harbor.local/ca.crt
```

---

# 14. 今日知识点

## 私有 Registry 链路

```
Developer

    |
    |
 docker push

    ↓

Harbor Registry

    |
    |
 Kubernetes imagePull

    ↓

Minikube Node

    |
    |
 imagePullSecret + CA

    ↓

Pod Running
```

## DevOps 实际流程

```
Code

 ↓

Docker Build

 ↓

Private Registry

 ↓

Kubernetes Deployment

 ↓

Helm Release

 ↓

Application Running
```

---

# Day48 完成状态

| 项目                | 状态 |
| ----------------- | -- |
| Harbor 部署         | ✅  |
| Harbor HTTPS      | ✅  |
| CA 信任             | ✅  |
| Docker Login      | ✅  |
| Kubernetes Secret | ✅  |
| Helm 部署           | ✅  |
| 私有镜像拉取            | ✅  |
| Pod Running       | ✅  |

---

