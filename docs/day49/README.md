```md
# Day49: Helm Parameterization and Kubernetes ConfigMap

## 今日目标

在 Day48 完成 Harbor 私有镜像仓库接入 Kubernetes 后，进一步优化 Helm 部署方式。

目标：

- Helm Chart 参数化
- 镜像配置与应用配置分离
- 引入 ConfigMap 管理环境变量
- 支持不同环境 values 配置
- 为后续 CI/CD 自动部署做准备


---

# 1. 项目结构

最终结构：

```

day49
└── helm-config-demo
├── helm
│   └── demo-chart
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-dev.yaml
│       ├── values-prod.yaml
│       └── templates
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── configmap.yaml
│           └── _helpers.tpl
│
├── manifests
│
└── README.md

````


说明：

- helm:
  Kubernetes 应用模板

- values:
  不同环境参数

- templates:
  Kubernetes 资源模板


---

# 2. 创建 Helm Chart


创建：

```bash
helm create helm/demo-chart
````

清理默认测试模板：

```bash
rm -rf helm/demo-chart/templates/tests
```

---

# 3. Helm Values 参数化

## values.yaml

统一管理应用参数：

```yaml
replicaCount: 1


image:
  repository: harbor.local/project-shanghai/day46-demo
  tag: v2
  pullPolicy: IfNotPresent


imagePullSecrets:
  - name: harbor-secret


service:
  type: ClusterIP
  port: 80


env:
  APP_ENV: dev
  APP_NAME: day49-demo
```

作用：

* 镜像地址不再硬编码
* 镜像版本可快速切换
* 环境变量独立管理

---

# 4. 创建 ConfigMap

文件：

```
templates/configmap.yaml
```

内容：

```yaml
apiVersion: v1
kind: ConfigMap

metadata:
  name: {{ include "demo-chart.fullname" . }}-config


data:

  APP_ENV: "{{ .Values.env.APP_ENV }}"

  APP_NAME: "{{ .Values.env.APP_NAME }}"
```

作用：

将应用配置从 Docker 镜像中剥离。

---

# 5. Deployment 引入 ConfigMap

修改：

```
templates/deployment.yaml
```

增加：

```yaml
envFrom:

  - configMapRef:

      name: {{ include "demo-chart.fullname" . }}-config
```

最终效果：

```
Pod

 |
 |
 ConfigMap

 |
 |
 Environment Variables
```

---

# 6. 多环境 Values

## 开发环境

文件：

```
values-dev.yaml
```

内容：

```yaml
replicaCount: 1

env:
  APP_ENV: dev
```

---

## 生产环境

文件：

```
values-prod.yaml
```

内容：

```yaml
replicaCount: 3

env:
  APP_ENV: production
```

实现：

同一个 Helm Chart

不同环境参数。

---

# 7. Helm 渲染测试

执行：

```bash
helm template demo helm/demo-chart
```

检查生成资源：

```yaml
kind: ConfigMap
```

以及：

```yaml
envFrom:
  - configMapRef:
```

确认模板渲染正常。

---

# 8. Kubernetes 部署测试

开发环境部署：

```bash
helm upgrade --install \
day49-demo \
./helm/demo-chart \
-f ./helm/demo-chart/values-dev.yaml
```

查看 Pod：

```bash
kubectl get pods
```

结果：

```
NAME                          READY   STATUS

day49-demo-xxxx               1/1     Running
```

查看 ConfigMap：

```bash
kubectl get configmap
```

结果：

```
day49-demo-config
```

---

# 9. Day49 遇到的问题

## 问题：配置写死在 Deployment

旧方式：

```yaml
image:
  harbor.local/project-shanghai/day46-demo:v2
```

问题：

* 修改版本需要改 YAML
* 多环境维护困难

解决：

使用：

```yaml
values.yaml
```

实现：

```
开发环境
      |
values-dev.yaml

生产环境
      |
values-prod.yaml
```

---

# 10. Day49 知识总结

## Helm 三层结构

```
Chart

 |
 |
 values.yaml

 |
 |
 templates

 |
 |
 Kubernetes Manifest

 |
 |
 Pod
```

---

## 配置管理演进

Day48:

```
Deployment
    |
    |
环境配置
```

Day49:

```
Deployment

    |
    |
ConfigMap

    |
    |
Environment
```

更加符合生产实践。

---

# Day49 完成状态

| 项目                     | 状态 |
| ---------------------- | -- |
| Helm Chart 创建          | ✅  |
| values 参数化             | ✅  |
| 镜像配置分离                 | ✅  |
| ConfigMap              | ✅  |
| 多环境 values             | ✅  |
| Helm 部署测试              | ✅  |
| Kubernetes Pod Running | ✅  |

---
