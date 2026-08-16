# Day57 Harbor 集成 Kubernetes 私有镜像仓库实践

## 实验目标

完成 Harbor 私有镜像仓库与 Kubernetes 集群集成，实现：

* Docker 镜像推送到 Harbor
* Kubernetes 使用 Harbor 私有镜像
* 配置 imagePullSecrets 完成认证
* Deployment 拉取私有镜像并运行

---

# 一、Harbor 环境验证

## Harbor 服务状态

Harbor 已部署完成：

```text
Harbor Version:
v2.13.2

访问地址:
https://harbor.local
```

验证：

```bash
curl -k https://localhost
```

返回 Harbor Web 页面资源，说明 nginx HTTPS 服务正常。

---

# 二、Docker 登录 Harbor

配置 hosts：

```bash
cat /etc/hosts | grep harbor
```

结果：

```text
192.168.157.129 harbor.local
```

登录：

```bash
docker login harbor.local
```

认证成功。

Docker 凭证保存：

```bash
cat ~/.docker/config.json
```

---

# 三、镜像推送测试

拉取测试镜像：

```bash
docker pull nginx:latest
```

重新标记：

```bash
docker tag nginx:latest \
harbor.local/library/nginx:test
```

推送：

```bash
docker push harbor.local/library/nginx:test
```

推送成功：

```text
test: digest:
sha256:963cfe6e75d1c292f66589d7e190b137cf89310414c0c1c5b476dfc61a4fcd0d
```

说明：

* Harbor Registry 正常
* Docker 客户端认证正常
* 镜像上传成功

---

# 四、Kubernetes 配置 Harbor 认证

## 创建测试命名空间

```bash
kubectl create namespace harbor-test
```

---

## 创建镜像拉取 Secret

```bash
kubectl create secret docker-registry harbor-secret \
-n harbor-test \
--docker-server=harbor.local \
--docker-username=xxxxxx \
--docker-password=xxxxxx
```

检查：

```bash
kubectl get secret -n harbor-test
```

结果：

```text
harbor-secret
```

---

# 五、Deployment 使用 Harbor 私有镜像

创建 Deployment：

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: nginx-harbor
  namespace: harbor-test

spec:
  replicas: 3

  selector:
    matchLabels:
      app: nginx-harbor

  template:
    metadata:
      labels:
        app: nginx-harbor

    spec:
      containers:
      - name: nginx
        image: harbor.local/library/nginx:test
        ports:
        - containerPort: 80

      imagePullSecrets:
      - name: harbor-secret
```

部署：

```bash
kubectl apply -f nginx-harbor.yaml
```

---

# 六、验证私有镜像拉取

查看 Pod：

```bash
kubectl get pods -n harbor-test
```

结果：

```text
NAME                           READY   STATUS
nginx-harbor-d7958b484-qc2fn   1/1     Running
nginx-harbor-d7958b484-rmrpk   1/1     Running
nginx-harbor-d7958b484-xkmxv   1/1     Running
```

验证：

* Kubernetes 成功访问 Harbor
* imagePullSecrets 生效
* 私有镜像拉取成功
* Deployment 三副本运行正常

---

# 七、问题排查记录

## 1. Docker context 指向错误

问题：

```text
DOCKER_HOST=tcp://192.168.49.2:2376
```

导致 Docker CLI 操作错误 daemon。

解决：

恢复 Docker context：

```bash
docker context ls
```

切换：

```text
unix:///var/run/docker.sock
```

---

## 2. Harbor 配置权限问题

问题：

```text
permission denied
common/config/*
```

原因：

Harbor 生成配置文件权限异常。

解决：

```bash
sudo chown -R guoji:guoji common/config
```

---

## 3. harbor-log rsyslog 2103

问题：

```text
rsyslogd:
run failed with error -2103
```

导致：

```text
dial tcp [::1]:1514:
connect: connection refused
```

原因：

harbor-log 未正常启动，Docker logging driver 无法连接。

解决：

修复配置权限并重新启动：

```bash
docker compose down

docker compose up -d
```

最终：

```text
harbor-log     healthy
nginx          healthy
harbor-core    started
```

---

# 八、实验成果总结

本次实验完成：

✅ Harbor 私有镜像仓库部署
✅ HTTPS 访问 Harbor
✅ Docker 登录 Harbor
✅ 镜像 push 到 Harbor
✅ Kubernetes 创建 registry secret
✅ Deployment 使用 Harbor 私有镜像
✅ 多副本 Pod 正常运行

最终架构：

```
Developer
    |
    | docker push
    ↓
Harbor Registry
harbor.local/library/nginx:test
    |
    | imagePullSecrets
    ↓
Kubernetes
    |
    ↓
Deployment
    |
    ↓
Pod Running
```
