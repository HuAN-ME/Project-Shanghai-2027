````markdown
# Day45 - Helm 企业化 Chart 实践

日期：2026-08-02

---

# 今日目标

从「会使用 Helm」进入「能够开发和维护企业级 Helm Chart」。

学习内容：

- Helm Chart 结构
- `_helpers.tpl` 模板复用
- Helm 内置对象
- Values 多环境管理
- Helm Dependency 依赖管理

---

# 一、创建 Helm Chart

创建实验目录：

```bash
mkdir day45
cd day45
````

创建 Chart：

```bash
helm create company-app
```

查看结构：

```bash
tree company-app -L 3
```

结构：

```
company-app
├── Chart.yaml
├── values.yaml
├── charts
└── templates
    ├── _helpers.tpl
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
```

---

# 二、理解 _helpers.tpl

查看：

```bash
cat templates/_helpers.tpl
```

`_helpers.tpl` 是 Helm 模板函数库。

作用：

* 统一资源名称
* 统一 Labels
* 减少重复配置

例如：

deployment、service、ingress 都需要：

```yaml
app.kubernetes.io/name
app.kubernetes.io/instance
```

可以通过：

```yaml
{{ include "company-app.labels" . }}
```

统一生成。

---

# 三、自定义 Labels

修改：

```
templates/_helpers.tpl
```

增加：

```yaml
app.kubernetes.io/part-of: project-shanghai
```

作用：

标识该应用属于：

```
Project-Shanghai
```

项目。

验证：

```bash
helm template company-app . | grep part-of
```

输出：

```yaml
app.kubernetes.io/part-of: project-shanghai
```

---

# 四、Helm 内置对象

Helm 模板最重要的三个对象：

```
.Values
.Chart
.Release
```

---

# 1. .Values

来源：

```
values.yaml
```

例如：

values.yaml：

```yaml
appOwner: devops-team
```

模板：

```yaml
owner: {{ .Values.appOwner }}
```

渲染：

```yaml
owner: devops-team
```

---

# 2. .Chart

来源：

```
Chart.yaml
```

模板：

```yaml
chart-name: {{ .Chart.Name }}
```

输出：

```yaml
chart-name: company-app
```

---

# 3. .Release

来源：

```
helm install NAME
```

模板：

```yaml
release-name: {{ .Release.Name }}
```

例如：

安装：

```bash
helm install shanghai-prod .
```

输出：

```yaml
release-name: shanghai-prod
```

---

# 五、Annotations 实验

deployment.yaml：

```yaml
annotations:
  owner: {{ .Values.appOwner }}
  chart-name: {{ .Chart.Name }}
  release-name: {{ .Release.Name }}
```

验证：

```bash
helm template company-app .
```

结果：

```yaml
annotations:
  owner: devops-team
  chart-name: company-app
  release-name: company-app
```

---

# 六、多环境 Values 管理

企业环境：

```
dev
test
prod
```

不会修改模板。

通过不同 values 文件控制。

---

创建：

```
values/prod.yaml
```

内容：

```yaml
replicaCount: 3

appOwner: devops-team

environment: prod
```

默认：

values.yaml：

```yaml
replicaCount: 1

environment: dev
```

---

结构：

```
company-app

├── values.yaml

└── values
    └── prod.yaml
```

---

开发环境：

```bash
helm template company-app .
```

结果：

```
environment: dev
replicaCount: 1
```

---

生产环境：

```bash
helm template company-prod . \
-f values/prod.yaml
```

结果：

```
environment: prod
replicaCount: 3
```

---

# 七、环境 Label

修改：

```
templates/_helpers.tpl
```

增加：

```yaml
app.kubernetes.io/environment: {{ .Values.environment }}
```

验证：

```bash
helm template company-app . | grep environment
```

输出：

```yaml
app.kubernetes.io/environment: dev
```

生产：

```bash
helm template company-prod . \
-f values/prod.yaml
```

输出：

```yaml
app.kubernetes.io/environment: prod
```

---

# 八、Helm Dependency 依赖管理

企业项目通常由多个组件组成：

```
shopping-platform

├── frontend
├── backend
├── mysql
├── redis
└── ingress
```

Helm 支持通过 Parent Chart 管理子 Chart。

---

修改：

```
Chart.yaml
```

增加：

```yaml
dependencies:
  - name: nginx
    version: 15.0.0
    repository: https://charts.bitnami.com/bitnami
```

---

执行：

```bash
helm dependency update
```

成功：

```
Saving 1 charts
```

查看：

```bash
ls charts/
```

结果：

```
nginx-15.0.0.tgz
```

---

查看依赖：

```bash
helm dependency list
```

显示：

```
NAME
nginx

VERSION
15.0.0
```

---

# 九、Day45 核心知识总结

## Helm 三大对象

| 对象       | 来源           | 作用      |
| -------- | ------------ | ------- |
| .Values  | values.yaml  | 用户配置    |
| .Chart   | Chart.yaml   | Chart信息 |
| .Release | helm install | 发布实例    |

---

## Helm 企业化模式

```
一个 Chart

      +

多个 values 文件

      ↓

dev/test/prod
```

---

## Chart 交付流程

```
Chart开发

    ↓

模板化

    ↓

values配置

    ↓

Helm Release

    ↓

Kubernetes部署
```

---

