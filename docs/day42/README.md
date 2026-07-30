```md
# Day42 - Kubernetes Ingress 高级路由与 TLS

## 今日目标

学习 Kubernetes Ingress 高级功能：

- Path 路由
- Host 路由
- rewrite-target
- TLS HTTPS Ingress
- 多 Pod 副本一致性问题


---

# 1. Ingress Path 路由

## 架构

```

Client
|
↓
Ingress Controller
|
+----------------+
|                |
↓                ↓
/web             /api
|                |
web-service     api-service
|                |
Pod             Pod

````


## Ingress 示例

```yaml
rules:
- host: app.local

  http:

    paths:

    - path: /web
      backend:
        service:
          name: web-service

    - path: /api
      backend:
        service:
          name: api-service
````

访问：

```bash
curl \
-H "Host: app.local" \
http://192.168.49.2:30350/api
```

---

# 2. rewrite-target 路径重写

问题：

访问：

```
/api
```

Ingress 默认转发：

```
GET /api
```

后端 nginx 不存在 `/api` 文件：

```
404 Not Found
```

解决：

增加 annotation：

```yaml
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
```

效果：

```
/api

↓

/
```

后端正常返回。

---

# 3. Host 路由

一个 Ingress 根据域名转发不同服务。

架构：

```
Ingress Controller


web.local
    |
    ↓
web-service


api.local
    |
    ↓
api-service
```

Ingress:

```yaml
rules:

- host: web.local

  http:
    paths:
    - path: /
      backend:
        service:
          name: web-service


- host: api.local

  http:
    paths:
    - path: /
      backend:
        service:
          name: api-service
```

测试：

```bash
curl \
-H "Host: web.local" \
http://192.168.49.2:30350


curl \
-H "Host: api.local" \
http://192.168.49.2:30350
```

结果：

```
This is WEB service

This is API service
```

---

# 4. TLS HTTPS Ingress

## HTTPS 流程

```
Client HTTPS

      |
      ↓

Ingress Controller

      |
 TLS Secret

      |
      ↓

HTTP

      |
      ↓

Service

      |
      ↓

Pod
```

Ingress Controller 负责 TLS 终止。

后端 Service 仍然使用 HTTP。

---

# 5. 创建 TLS Secret

生成证书：

```bash
openssl genrsa -out tls.key 2048


openssl req -x509 \
-nodes \
-days 365 \
-newkey rsa:2048 \
-keyout tls.key \
-out tls.crt \
-subj "/CN=app.local"
```

创建 Secret：

```bash
kubectl create secret tls app-tls \
--cert=tls.crt \
--key=tls.key
```

查看：

```bash
kubectl get secret
```

类型：

```
kubernetes.io/tls
```

---

# 6. HTTPS Ingress

配置：

```yaml
spec:

  tls:

  - hosts:
    - app.local

    secretName: app-tls


  rules:

  - host: app.local

    http:

      paths:

      - path: /

        backend:

          service:
            name: web-service
```

测试：

```bash
curl -k \
-H "Host: app.local" \
https://192.168.49.2:30600/
```

---

# 7. Troubleshooting：多 Pod 内容不一致

现象：

同一个地址访问：

一次：

```
Welcome to nginx
```

一次：

```
This is WEB service
```

原因：

Service 后端存在多个 Pod：

```
web-service

 |
 +--- Pod A
 |
 +--- Pod B
```

kubectl exec 修改：

```bash
echo xxx > /usr/share/nginx/html/index.html
```

只修改当前 Pod。

其他 Pod 仍保持旧内容。

---

# 8. 正确方式：ConfigMap 挂载

不要：

```
kubectl exec 修改 Pod
```

应该：

```
ConfigMap

    |
    ↓

Volume

    |
    ↓

Pod
```

Deployment 结构：

```
Deployment

└── spec

    └── template

        └── spec

            ├── containers
            │
            │   └── volumeMounts
            │
            └── volumes
```

示例：

```yaml
containers:

- name: nginx

  volumeMounts:

  - name: web-content

    mountPath: /usr/share/nginx/html/index.html

    subPath: index.html



volumes:

- name: web-content

  configMap:

    name: web-index
```

---

# 今日知识总结

完成：

* Ingress Path Routing ✅
* rewrite-target ✅
* Ingress Host Routing ✅
* TLS HTTPS Ingress ✅
* TLS Secret 创建 ✅
* Service 多 Pod 负载均衡理解 ✅
* ConfigMap + Volume 挂载理解 ✅

核心架构：

```
Ingress
   |
Service
   |
Deployment
   |
Pod
   |
Volume
   |
ConfigMap
```

## 今日踩坑记录

1. Ingress 返回结果不稳定

原因：

多个 Pod 内容不同。

2. exec 修改 Pod 文件不持久

原因：

Pod 是临时资源。

3. 生产环境应该使用：

* Docker Image
* ConfigMap
* Volume

管理应用内容。

```

