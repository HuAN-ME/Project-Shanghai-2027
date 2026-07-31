# Day43 Helm Chart 生命周期管理

## 一、学习目标

本日学习 Kubernetes Helm 包管理工具的核心使用流程：

* Helm Chart 创建
* Chart 目录结构理解
* values.yaml 配置管理
* helm install 部署应用
* helm upgrade 更新应用
* helm history 查看版本历史
* helm rollback 回滚版本

同时结合实际环境解决镜像仓库访问问题。

---

# 二、Helm 基础概念

Helm 是 Kubernetes 的包管理工具，可以将 Kubernetes YAML 资源进行模板化管理。

类似：

Linux:

```
yum install nginx
```

Kubernetes:

```
helm install nginx ./chart
```

Helm 核心组成：

```
Chart
 |
 |-- Chart.yaml
 |
 |-- values.yaml
 |
 |-- templates/
        |
        |-- deployment.yaml
        |-- service.yaml
```

关系：

```
values.yaml
      |
      ↓
templates模板渲染
      |
      ↓
Kubernetes YAML
      |
      ↓
Deployment / Service / Pod
```

---

# 三、创建 Helm Chart

创建 Chart：

```bash
helm create my-nginx
```

生成结构：

```
my-nginx/
├── Chart.yaml
├── values.yaml
├── charts/
└── templates/
```

说明：

| 文件          | 作用           |
| ----------- | ------------ |
| Chart.yaml  | Chart 元信息    |
| values.yaml | 默认配置         |
| templates   | Kubernetes模板 |
| charts      | 依赖Chart      |

---

# 四、首次 Helm 安装

尝试安装 Bitnami nginx：

```bash
helm install test-nginx bitnami/nginx
```

失败：

```
dial tcp registry-1.docker.io:443 timeout
```

原因：

默认镜像仓库：

```
docker.io
```

当前环境无法访问 Docker Hub。

---

# 五、使用本地 Chart 部署

进入 Chart 目录：

```bash
cd my-nginx
```

安装：

```bash
helm install my-nginx ./my-nginx
```

结果：

```
NAME: my-nginx
STATUS: deployed
REVISION: 1
```

说明：

Helm Release 创建成功。

---

# 六、Pod 镜像拉取失败

查看 Pod：

```bash
kubectl get pods
```

状态：

```
my-nginx-xxxx
Pending
```

查看事件：

```bash
kubectl describe pod my-nginx-xxxx
```

发现：

```
Failed to pull image "nginx:1.16.0"

registry-1.docker.io timeout
```

原因：

Chart 默认：

```yaml
image:
  repository: nginx
  tag: "1.16.0"
```

实际：

```
docker.io/library/nginx:1.16.0
```

---

# 七、修改 values.yaml

修改：

```yaml
image:
  repository: docker.m.daocloud.io/library/nginx
  pullPolicy: IfNotPresent
  tag: "1.16.0"
```

作用：

将镜像源切换到国内镜像代理。

---

# 八、Helm Upgrade 更新应用

Release 已存在：

```bash
helm list
```

不能重新 install。

使用：

```bash
helm upgrade my-nginx ./my-nginx
```

升级流程：

```
修改values.yaml

        ↓

helm upgrade

        ↓

创建新的ReplicaSet

        ↓

创建新Pod

        ↓

RollingUpdate
```

查看：

```bash
kubectl get pods -w
```

最终：

```
my-nginx-xxxxx   1/1 Running
```

---

# 九、验证新镜像

查看 Pod 使用镜像：

```bash
kubectl get pod my-nginx-xxxxx \
-o jsonpath='{.spec.containers[0].image}'
```

结果：

```
docker.m.daocloud.io/library/nginx:1.16.0
```

说明升级成功。

---

# 十、Helm Values 说明

执行：

```bash
helm get values my-nginx
```

显示：

```
USER-SUPPLIED VALUES:
null
```

原因：

安装时没有指定：

```bash
-f values.yaml
```

或者：

```bash
--set
```

Helm 区分：

## Chart 默认 Values

来自：

```
values.yaml
```

## 用户覆盖 Values

来自：

```
-f xxx.yaml
```

或者：

```
--set
```

最终：

```
默认values
      +
用户values
      |
      ↓
最终渲染配置
```

---

# 十一、Helm History

查看版本：

```bash
helm history my-nginx
```

Helm 保存每次操作：

```
Revision 1
安装


Revision 2
upgrade


Revision 3
rollback
```

---

# 十二、Helm Rollback

执行：

```bash
helm rollback my-nginx 1
```

结果：

```
Rollback was a success!
```

注意：

Rollback 不会删除历史。

实际：

```
Revision 1
    |
    |
upgrade
    ↓
Revision 2
    |
rollback
    ↓
Revision 3
```

Rollback 本质：

复制旧配置，生成新的 Revision。

---

# 十三、Rollback 后出现镜像问题

回滚后：

```
my-nginx-f48bcddd4
ImagePullBackOff
```

原因：

Revision 1 使用：

```yaml
image:
 repository: nginx
```

重新回到了：

```
docker.io/library/nginx
```

当前环境无法访问 Docker Hub。

说明：

Rollback 会恢复完整配置，包括：

* 镜像地址
* tag
* 环境变量
* 参数配置

---

# 十四、今日实验总结

完成：

✅ Helm Chart 创建

✅ Chart目录结构理解

✅ values.yaml配置

✅ helm install

✅ 镜像仓库切换

✅ helm upgrade

✅ Kubernetes RollingUpdate

✅ helm history

✅ helm rollback

---

# 十五、核心知识点

## Helm Release 生命周期

```
helm install

      ↓

Revision 1


helm upgrade

      ↓

Revision 2


helm rollback

      ↓

Revision 3
```

---

## 企业生产模式

实际项目：

```
values-dev.yaml

values-test.yaml

values-prod.yaml
```

部署：

```bash
helm upgrade app ./chart \
-f values-prod.yaml
```

通过不同 values 管理不同环境。

---

# Day43 完成状态

| 内容         | 状态 |
| ---------- | -- |
| Helm安装     | ✅  |
| Chart结构    | ✅  |
| values管理   | ✅  |
| Release部署  | ✅  |
| Upgrade更新  | ✅  |
| History查看  | ✅  |
| Rollback回滚 | ✅  |
| 镜像仓库问题处理   | ✅  |

Day43 完成。
