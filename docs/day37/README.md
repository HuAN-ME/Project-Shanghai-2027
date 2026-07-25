````markdown id="58291"
# Day37 - Kubernetes Secret 与 ConfigMap 综合应用

## 一、今日目标

学习 Kubernetes 中配置管理机制：

- ConfigMap：管理普通配置
- Secret：管理敏感数据
- Volume 挂载配置文件
- Secret 与 Pod 的关联方式

---

# 二、ConfigMap 配置管理

ConfigMap 用于存储非敏感配置，例如：

- 应用参数
- 配置文件
- 环境配置


示例：

```yaml
apiVersion: v1
kind: ConfigMap

metadata:
  name: app-config

data:
  app.conf: |
    server {
        port=8080
        environment=production
        debug=false
    }
````

创建：

```bash
kubectl apply -f configmap.yaml
```

查看：

```bash
kubectl get configmap
```

---

# 三、Secret 管理敏感数据

Secret 用于保存：

* 用户密码
* Token
* TLS证书
* 密钥

示例：

```yaml
apiVersion: v1
kind: Secret

metadata:
  name: app-secret

type: Opaque

stringData:
  username: "admin"
  password: "123456"
```

注意：

YAML 会自动识别数字类型，因此密码等字段建议加引号。

错误：

```yaml
password: 123456
```

推荐：

```yaml
password: "123456"
```

---

# 四、Secret Volume 挂载

Secret 可以通过 Volume 挂载到容器文件系统。

结构：

```
Secret对象

    ↓

Volume

    ↓

Container文件系统
```

示例：

```yaml
volumes:

- name: secret-volume

  secret:
    secretName: app-secret
```

注意：

`secretName` 用于引用 Kubernetes Secret 对象。

---

# 五、Deployment 综合实验

实现：

```
Deployment

    |
    |
    +--- ConfigMap
    |
    |
    +--- Secret
```

Pod启动后：

ConfigMap:

```
/etc/app/app.conf
```

Secret:

```
/etc/password/password
```

进入容器验证：

```bash
kubectl exec -it <pod-name> -- bash
```

查看配置：

```bash
cat /etc/app/app.conf
```

查看密码：

```bash
cat /etc/password/password
```

实验成功。

---

# 六、Secret 使用方式比较

## 1. 环境变量方式

示例：

```yaml
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

优点：

* 简单
* 应用读取方便

缺点：

* Secret 更新后不会自动刷新
* 需要重启 Pod

---

## 2. Volume 挂载方式

```
Secret

 ↓

Volume

 ↓

文件
```

优点：

* 更适合配置文件
* 支持动态更新
* 常用于证书、密钥

生产环境更常见。

---

# 七、今日总结

Day37 完成 Kubernetes 配置管理学习：

✅ ConfigMap 创建与挂载
✅ Secret 创建与挂载
✅ Volume 使用 Secret
✅ Deployment 综合配置
✅ 理解 env 与 volume 的区别

当前 Kubernetes 基础能力：

```
Pod
 |
Deployment
 |
ReplicaSet
 |
Service
 |
ConfigMap
 |
Secret
```
