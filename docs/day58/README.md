# Day58 Helm 应用生命周期管理

## 一、实验目标

基于 Day57 已完成的 Harbor 私有镜像仓库与 Kubernetes 镜像拉取流程，引入 Helm 管理 Kubernetes 应用，实现：

* 使用 Helm Chart 部署应用
* 使用 values.yaml 管理配置
* 使用 helm upgrade 更新应用
* 使用 helm rollback 回滚版本
* 理解 Helm Release 生命周期

---

# 二、实验环境确认

## Harbor

虚拟机重启后验证 Harbor 服务：

```bash
docker compose ps
```

所有核心组件恢复正常：

* harbor-log
* registry
* registryctl
* harbor-core
* harbor-jobservice
* harbor-portal
* nginx
* harbor-db
* redis

状态均恢复 healthy。

验证 Harbor 登录：

```bash
docker login harbor.local
```

登录成功。

说明：

* Harbor 数据持久化正常
* Docker Registry 可用
* Kubernetes 可以继续使用 Harbor 镜像

---

# 三、Helm Chart 部署

## 创建 Helm Release

使用已有 Chart：

```bash
helm install nginx-demo ./nginx-harbor -n helm-test
```

部署成功：

```text
NAME: nginx-demo
STATUS: deployed
CHART: nginx-harbor-0.1.0
```

查看 Release：

```bash
helm list -n helm-test
```

查看 Pod：

```bash
kubectl get pods -n helm-test
```

应用正常运行。

---

# 四、Helm 配置管理

Helm 管理流程：

```
values.yaml
      |
      v
templates/deployment.yaml
      |
      v
helm install / upgrade
      |
      v
Kubernetes Deployment
      |
      v
Pod
```

不要直接修改 Kubernetes Deployment：

```bash
kubectl edit deployment
```

原因：

* 修改只存在于集群状态
* Helm Chart 中没有记录
* 后续 helm upgrade 会覆盖手工修改

正确方式：

修改：

```text
values.yaml
```

然后：

```bash
helm upgrade
```

---

# 五、Helm Upgrade 实验

修改 Chart 配置，例如：

```yaml
replicaCount: 3
```

执行：

```bash
helm upgrade nginx-demo ./nginx-harbor -n helm-test
```

查看更新：

```bash
kubectl get pods -n helm-test
```

Pod 数量按照新的 values.yaml 更新。

说明：

Helm 会重新渲染模板，并更新 Kubernetes 资源。

---

# 六、Helm History

查看 Release 历史：

```bash
helm history nginx-demo -n helm-test
```

Helm 会保存每一次变更：

```
Revision 1
    |
    upgrade
    |
Revision 2
    |
    rollback
    |
Revision 3
```

每次：

* install
* upgrade
* rollback

都会产生新的 revision。

---

# 七、Helm Rollback 实验

执行：

```bash
helm rollback nginx-demo <revision> -n helm-test
```

回滚成功。

验证：

```bash
kubectl get pods -n helm-test
```

应用恢复正常。

说明：

Helm 可以快速恢复历史版本。

---

# 八、核心知识总结

## Kubernetes 部署方式演进

### Day57

直接使用 Kubernetes YAML：

```
Deployment
    |
    v
Pod
```

---

### Day58

使用 Helm 管理：

```
Chart
 |
 | values.yaml
 |
 v
Templates
 |
 v
Release
 |
 v
Kubernetes
```

---

# 九、实验收获

本次实验完成：

✅ Harbor 私有镜像仓库集成
✅ Kubernetes 拉取 Harbor 镜像
✅ Helm Chart 部署应用
✅ Helm Upgrade 更新版本
✅ Helm History 查看发布记录
✅ Helm Rollback 回滚版本

掌握 Kubernetes 应用生命周期管理基础。

---

# 十、下一阶段方向

后续进入：

```
GitHub Actions
        |
        v
Docker Build
        |
        v
Push Harbor
        |
        v
Helm Upgrade
        |
        v
Kubernetes 自动发布
```

向完整 DevOps CI/CD 流程演进。
