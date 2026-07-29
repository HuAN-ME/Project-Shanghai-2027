下面是精简版 Day41.md，保持你之前 Project-Shanghai-2027 的实验记录风格，重点记录**目标、过程、问题、总结**。

```markdown
# Day41 Kubernetes Ingress 实战

## 实验目标

部署 Kubernetes Ingress Controller，并通过 Ingress 规则实现外部 HTTP 请求访问集群内部 Service。

---

# 一、Ingress 基础概念

Kubernetes Service 主要解决：

```

Pod
↓
Service

```

集群内部访问问题。

Ingress 进一步解决：

```

用户请求
↓
Ingress Controller
↓
Ingress Rule
↓
Service
↓
Pod

````

实现基于 HTTP/HTTPS 的七层流量转发。

---

# 二、部署 Ingress Controller

## 1. Minikube Ingress Addon尝试

执行：

```bash
minikube addons enable ingress
````

失败：

```
ImagePullBackOff
```

原因：

默认镜像地址无法正常拉取。

---

## 2. 使用 Helm 部署 ingress-nginx

添加仓库：

```bash
helm repo add ingress-nginx \
https://kubernetes.github.io/ingress-nginx

helm repo update
```

查看 Chart：

```bash
helm search repo ingress-nginx
```

安装：

```bash
helm install ingress-nginx ingress-nginx/ingress-nginx \
-n ingress-nginx \
--create-namespace \
-f ingress-values.yaml
```

---

# 三、镜像源问题排查

## 问题1：DaoCloud镜像不存在

错误：

```
docker.m.daocloud.io/ingress-nginx/controller
```

原因：

DaoCloud公共镜像并不是所有 Kubernetes 官方镜像都存在。

---

## 问题2：digest导致manifest错误

错误：

```
manifest unknown
```

原因：

官方镜像：

```
image:v1.15.1@sha256:xxxx
```

迁移到国内仓库后：

```
tag相同
digest不同
```

解决：

清空 digest：

```yaml
digest: ""
```

---

## 最终 controller 配置：

```yaml
controller:
  image:
    registry: registry.cn-hangzhou.aliyuncs.com/google_containers
    image: nginx-ingress-controller
    tag: v1.15.1
    digest: ""
```

Webhook：

```yaml
admissionWebhooks:
  patch:
    image:
      registry: registry.cn-hangzhou.aliyuncs.com/google_containers
      image: kube-webhook-certgen
      tag: v1.6.9
      digest: ""
```

---

# 四、验证 Ingress Controller

查看 Pod：

```bash
kubectl get pods -n ingress-nginx
```

结果：

```
ingress-nginx-controller   1/1 Running
```

查看 Service：

```bash
kubectl get svc -n ingress-nginx
```

结果：

```
ingress-nginx-controller

TYPE:
LoadBalancer
```

说明 Ingress Controller 已运行。

---

# 五、创建测试应用

目录：

```
day41
└── ingress-test
    ├── nginx-deployment.yaml
    ├── nginx-service.yaml
    └── nginx-ingress.yaml
```

---

# 六、创建 Deployment

nginx Deployment：

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: ingress-demo-nginx

spec:
  replicas: 2

  selector:
    matchLabels:
      app: ingress-demo-nginx

  template:
    metadata:
      labels:
        app: ingress-demo-nginx

    spec:
      containers:
      - name: nginx
        image: docker.m.daocloud.io/library/nginx:latest
        ports:
        - containerPort: 80
```

---

# 七、创建 Service

Ingress 后端使用 ClusterIP：

```yaml
apiVersion: v1
kind: Service

metadata:
  name: ingress-demo-service

spec:
  selector:
    app: ingress-demo-nginx

  ports:
  - port: 80
    targetPort: 80
```

访问链路：

```
Ingress
 |
Service(ClusterIP)
 |
Pod
```

---

# 八、创建 Ingress Rule

配置：

```yaml
apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:
  name: ingress-demo

spec:

  ingressClassName: nginx

  rules:

  - host: nginx.local

    http:

      paths:

      - path: /

        pathType: Prefix

        backend:

          service:

            name: ingress-demo-service

            port:

              number: 80
```

---

# 九、访问测试

获取 Controller 地址：

```bash
kubectl get svc -n ingress-nginx
```

测试：

```bash
curl \
-H "Host: nginx.local" \
http://EXTERNAL-IP
```

返回：

```
Welcome to nginx!
```

实验成功。

---

# 十、遇到的问题总结

## 1. Helm deployed 不代表应用成功

Helm：

```
STATUS: deployed
```

只代表资源创建成功。

仍需要确认：

```bash
kubectl get pods
```

是否：

```
Running
```

---

## 2. 镜像替换注意事项

更换镜像仓库需要同时确认：

* registry
* image/repository
* tag
* digest

不能只修改 registry。

---

## 3. Ingress标准访问模型

推荐：

```
External Request
        |
        ↓
Ingress Controller
        |
        ↓
Ingress Rule
        |
        ↓
ClusterIP Service
        |
        ↓
Pod
```

---

# 十一、Day41总结

完成：

✅ Helm 部署 ingress-nginx
✅ 国内镜像适配
✅ ImagePullBackOff 排障
✅ Ingress Controller运行
✅ 创建 Deployment
✅ 创建 ClusterIP Service
✅ 创建 Ingress Rule
✅ 外部 HTTP 请求访问 Pod

掌握 Kubernetes 七层流量入口基础。
