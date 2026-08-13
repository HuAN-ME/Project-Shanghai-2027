````md
# Day53 Kubernetes Ingress 实战与故障排查

## 今日目标

为 ArgoCD 管理的 day51-demo 应用增加 Kubernetes Ingress 访问能力，实现：

GitHub → Actions → Harbor → ArgoCD → Kubernetes → Ingress → 用户访问

完整 DevOps 发布链路。

---

# 一、部署 Ingress Controller

## 1. 尝试启用 Minikube Ingress

执行：

```bash
minikube addons enable ingress
````

失败：

```
ImagePullBackOff
nginx-ingress-controller:v1.14.3
```

原因：

* 官方镜像源无法访问
* 国内环境无法正常拉取镜像

---

## 2. Helm 部署尝试

执行：

```bash
helm install ingress-nginx ingress-nginx/ingress-nginx \
-n ingress-nginx \
--create-namespace
```

失败：

```
manifest unknown
```

原因：

镜像 digest 与国内镜像仓库不匹配。

---

# 二、手动部署 ingress-nginx

创建：

```
day53/manifests/
├── ingress-controller.yaml
└── ingress-service.yaml
```

部署：

```bash
kubectl apply -f ingress-controller.yaml

kubectl apply -f ingress-service.yaml
```

---

## 遇到问题：Ingress Controller CrashLoopBackOff

日志：

```
the cluster seems to be running with a restrictive Authorization mode
and the Ingress controller does not have the required permissions
```

原因：

Deployment 使用：

```yaml
serviceAccountName: default
```

默认 ServiceAccount 没有 Kubernetes API 权限。

解决：

增加：

* ServiceAccount
* ClusterRole
* ClusterRoleBinding

最终：

```bash
kubectl get pods -n ingress-nginx
```

结果：

```
ingress-nginx-controller   1/1 Running
```

---

# 三、创建应用 Ingress Rule

## 1. 确认 day51-demo Service

创建：

```yaml
service.yaml
```

内容：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: day51-demo
  namespace: harbor-demo

spec:
  selector:
    app: day51-demo

  ports:
  - port: 80
    targetPort: 80
```

应用：

```bash
kubectl apply -f service.yaml
```

检查：

```bash
kubectl get svc -n harbor-demo
```

结果：

```
day51-demo   ClusterIP   80/TCP
```

---

## 2. 创建 Ingress

配置：

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: day51-demo-ingress
  namespace: harbor-demo

spec:
  ingressClassName: nginx

  rules:
  - host: day51.local

    http:
      paths:

      - path: /
        pathType: Prefix

        backend:
          service:
            name: day51-demo
            port:
              number: 80
```

应用：

```bash
kubectl apply -f ingress.yaml
```

检查：

```bash
kubectl get ingress -n harbor-demo
```

结果：

```
NAME                 CLASS   HOSTS
day51-demo-ingress   nginx   day51.local
```

---

# 四、Ingress 503 故障排查

访问：

```bash
curl http://day51.local:31080
```

出现：

```
503 Service Temporarily Unavailable
```

开始逐层排查。

---

## 1. 检查 Ingress

```bash
kubectl describe ingress day51-demo-ingress \
-n harbor-demo
```

确认：

```
Backend:
day51-demo:80
```

正常。

---

## 2. 检查 Service Endpoint

```bash
kubectl get endpoints \
-n harbor-demo
```

结果：

```
day51-demo

10.244.2.233:80
10.244.2.244:80
```

Service 有后端。

---

## 3. 检查 Pod

```bash
kubectl get pods \
-n harbor-demo \
-o wide
```

结果：

```
day51-demo
Running
READY 1/1
```

Pod 正常。

---

## 4. 检查容器内部服务

进入 Pod：

```bash
kubectl exec -it \
-n harbor-demo \
day51-demo-xxx \
-- sh
```

测试：

```bash
curl localhost
```

返回：

```html
<h1>
Day50 GitHub Actions CI Demo
</h1>

Day51 Version
```

确认：

* nginx 正常
* 页面正常
* 镜像正常

---

# 五、最终问题定位

发现：

直接访问：

```bash
curl 10.244.x.x
```

失败。

原因：

Pod IP 属于 Kubernetes Pod Network。

宿主机不能直接访问 Pod CIDR。

正确路径：

```
Ingress Controller
        |
        |
     Service
        |
        |
       Pod
```

最终：

```bash
curl http://day51.local:31080
```

成功。

返回：

```html
Day50 GitHub Actions CI Demo

Day51 Version
```

---

# 六、今日架构

最终架构：

```
GitHub
  |
  |
GitHub Actions
  |
  |
Harbor Registry
  |
  |
ArgoCD
  |
  |
Deployment
  |
  |
Pod
(day50-demo:v2)
  |
  |
Service
(day51-demo)
  |
  |
Ingress
(day51.local)
  |
  |
Ingress Controller
  |
  |
NodePort 31080
  |
  |
User
```

---

# 七、今日收获

## Kubernetes

* Ingress Controller 部署
* Ingress Rule 配置
* Service 与 Endpoint 关系
* Pod Network 理解

## 排障能力

掌握 503 排查顺序：

```
1. Ingress Controller 是否正常

2. Ingress Rule 是否匹配

3. Service 是否存在

4. Endpoint 是否生成

5. Pod 是否 Running

6. Container 是否监听端口

7. 应用是否返回正常内容
```

---

# 八、Day53 总结

Day53 完成 Kubernetes 应用外部访问能力建设。

实现：

✅ ingress-nginx 部署
✅ RBAC 权限配置
✅ NodePort 暴露
✅ Ingress Rule 创建
✅ ArgoCD 应用接入 Ingress
✅ 域名访问验证
