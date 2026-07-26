```markdown
# Day38 - Kubernetes Deployment 滚动更新（Rolling Update）

## 一、今日目标

学习 Kubernetes 应用升级机制：

- Deployment 滚动更新
- ReplicaSet 版本管理
- 镜像更新
- 更新过程观察
- 回滚机制基础

---

# 二、Deployment 更新机制

传统部署：

```

停止旧版本
↓
删除服务
↓
启动新版本

```

问题：

- 服务中断
- 用户请求失败


Kubernetes：

```

旧 Pod

Pod v1
Pod v1
Pod v1

```
  ↓ 滚动替换
```

Pod v1
Pod v1
Pod v2

```
  ↓
```

Pod v2
Pod v2
Pod v2

```

这种方式称为：

```

Rolling Update
滚动更新

````

---

# 三、创建 Deployment

示例：

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: nginx-update-demo

spec:

  replicas: 3

  strategy:

    type: RollingUpdate

    rollingUpdate:

      maxSurge: 1

      maxUnavailable: 1
````

---

## maxSurge

允许升级过程中额外创建 Pod。

例如：

```
replicas: 3

maxSurge: 1
```

升级时：

```
最多存在 4 个 Pod
```

---

## maxUnavailable

允许暂时不可用的 Pod 数量。

例如：

```
maxUnavailable: 1
```

表示：

```
最多允许 1 个 Pod 不可用
```

保证升级过程中服务持续运行。

---

# 四、ReplicaSet 与版本管理

Deployment 不直接管理 Pod。

关系：

```
Deployment

    |
    |
    +----- ReplicaSet v1
    |             |
    |             Pod
    |
    |
    +----- ReplicaSet v2
                  |
                  Pod
```

每次 Deployment 更新：

都会生成新的 ReplicaSet。

查看：

```bash
kubectl get rs
```

示例：

```
nginx-update-demo-6559559688
nginx-update-demo-55c579799f
```

其中：

* 新版本 ReplicaSet：运行新 Pod
* 旧版本 ReplicaSet：保留历史

---

# 五、执行镜像更新

命令：

```bash
kubectl set image deployment/nginx-update-demo \
nginx=docker.m.daocloud.io/library/nginx:latest
```

作用：

修改 Deployment 中 Container 镜像。

Kubernetes 自动：

```
修改 Deployment

        ↓

创建新的 ReplicaSet

        ↓

启动新 Pod

        ↓

删除旧 Pod
```

---

# 六、实验过程中遇到的问题

## ImagePullBackOff

错误：

```
Failed to pull image "nginx"
```

原因：

默认镜像：

```
docker.io/library/nginx
```

当前环境无法访问 Docker Hub。

解决：

使用国内镜像源：

```
docker.m.daocloud.io/library/nginx
```

重新更新：

```bash
kubectl set image ...
```

---

# 七、观察滚动更新

查看 Pod：

```bash
kubectl get pods
```

更新过程中：

可能看到：

```
ContainerCreating

Running

Terminating
```

说明：

* 新 Pod 正在创建
* 旧 Pod 正在退出

查看更新状态：

```bash
kubectl rollout status deployment/nginx-update-demo
```

---

# 八、查看历史版本

```bash
kubectl rollout history deployment/nginx-update-demo
```

查看：

```
REVISION 1
REVISION 2
```

---

# 九、回滚

如果新版本出现问题：

```bash
kubectl rollout undo deployment/nginx-update-demo

恢复上一版本。

---

# 十、今日总结

Day38 完成 Kubernetes 发布能力学习：

✅ 理解 Deployment 滚动更新
✅ 理解 ReplicaSet 版本机制
✅ 使用 kubectl set image 更新应用
✅ 观察 Pod 替换过程
✅ 理解 maxSurge 与 maxUnavailable
✅ 掌握基础回滚方法
✅ 解决镜像拉取失败问题
