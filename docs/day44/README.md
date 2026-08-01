# Day44 - Helm Chart 模板化应用管理实战

日期：2026-07-31

---

# 一、今日目标

Day43 学习了 Helm 基础使用：

- 创建 Chart
- install 部署
- upgrade 更新
- rollback 回滚


Day44 进一步学习 Helm 的核心价值：

> 使用模板化方式管理 Kubernetes 应用，实现参数化部署和多环境交付。


今日重点：

- Helm Chart 结构理解
- values.yaml 参数管理
- helm template 渲染
- Helm Release 管理
- 多副本扩容
- 多环境 values 文件设计


---

# 二、Helm 的核心定位

## Kubernetes 原始部署方式

之前：

```
deployment.yaml
service.yaml
configmap.yaml
secret.yaml
ingress.yaml

        |

kubectl apply -f
```

问题：

- YAML 文件数量快速增加
- 环境变化需要修改大量文件
- 多服务维护困难
- 缺少版本管理


---

# 三、Helm解决的问题


Helm 引入：

```
模板 Template

        +

参数 Values

        |

        ↓

生成 Kubernetes YAML

        |

        ↓

部署应用
```


例如：

模板：

```yaml
replicas: {{ .Values.replicaCount }}
```


values.yaml：

```yaml
replicaCount: 3
```


渲染后：

```yaml
replicas: 3
```


---

# 四、创建 Helm Chart


创建实验 Chart：

```bash
helm create web-app
```


目录：

```
web-app

├── Chart.yaml
├── values.yaml
├── charts
└── templates
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    └── _helpers.tpl
```


说明：

|目录|作用|
|-|-|
|Chart.yaml|Chart 元信息|
|values.yaml|参数配置|
|templates|Kubernetes模板|
|charts|依赖Chart|
|_helpers.tpl|模板辅助函数|


---

# 五、helm template 渲染


Helm不会直接运行模板。


执行：

```bash
helm template web-app .
```


作用：

将：

```
模板文件

+

values.yaml

↓

生成最终 Kubernetes YAML
```


用于：

- 查看结果
- 调试错误
- 部署前检查


---

# 六、values.yaml 参数控制


修改：

```yaml
replicaCount: 3
```


模板：

```yaml
replicas:
{{ .Values.replicaCount }}
```


生成：

```yaml
replicas: 3
```


说明：

Helm通过values实现配置和代码分离。


---

# 七、镜像源修改


由于环境无法稳定访问 Docker Hub。


修改：

values.yaml


```yaml
image:
  repository: docker.m.daocloud.io/library/nginx
  tag: "1.25"
```


渲染确认：

```bash
helm template web-app .
```


最终：

```yaml
image:
 docker.m.daocloud.io/library/nginx:1.25
```


---

# 八、Helm安装应用


安装：

```bash
helm install web-app ./web-app
```


查看：

```bash
kubectl get pods
```


状态：

```
Running
```


查看Release：

```bash
helm list
```


输出：

```
NAME
web-app

STATUS
deployed
```


---

# 九、Helm扩容测试


修改：

values.yaml


```yaml
replicaCount: 5
```


执行：

```bash
helm upgrade web-app ./web-app
```


查看：

```bash
kubectl get pods
```


结果：

```
web-app-xxx
web-app-xxx
web-app-xxx
web-app-xxx
web-app-xxx
```


扩容成功。


---

# 十、Helm Release机制


Helm管理：

```
Release v1

        |

升级

        ↓

Release v2

        |

发现问题

        ↓

Rollback

        |

恢复旧版本
```


查看历史：

```bash
helm history web-app
```


回滚：

```bash
helm rollback web-app 1
```


---

# 十一、企业环境中的Values设计


真实项目通常：

```
chart/

├── templates/

├── values.yaml

├── values-dev.yaml

├── values-test.yaml

└── values-prod.yaml
```


不同环境：

开发：

```yaml
replicaCount: 1
```


生产：

```yaml
replicaCount: 10
```


部署：

```bash
helm upgrade app ./chart \
-f values-prod.yaml
```


实现：

```
同一套模板

不同环境配置

快速发布
```


---

# 十二、Helm 与 Kubernetes关系


重要理解：

Helm：

负责：

- 模板管理
- 应用打包
- 发布升级
- 版本管理


Kubernetes：

负责：

- Pod调度
- 服务发现
- 状态维护


关系：

```
Helm

  |

生成资源

  |

Kubernetes API

  |

Controller

  |

Pod运行
```


Helm不会直接创建Pod。

---

# 十三、今日总结


今天完成：

- [x] 创建 Helm Chart
- [x] 理解 Chart 目录结构
- [x] 学习 Template 渲染机制
- [x] values.yaml 参数化配置
- [x] 修改镜像源
- [x] Helm install部署
- [x] Helm upgrade升级
- [x] 多副本扩容
- [x] Release版本管理


---

# 十四、核心认知


之前：

> 手动编写 Kubernetes YAML，让应用运行。


现在：

> 使用 Helm 将 Kubernetes 应用包装成标准化、可复用、可版本控制的软件包。


一句话总结：

**Kubernetes负责运行应用，Helm负责交付应用。**

Helm 是 Kubernetes 从资源管理进入应用管理的重要工具。

---

# Day44 End
