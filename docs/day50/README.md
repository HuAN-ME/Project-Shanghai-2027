```md
# Day50 GitHub Actions + Harbor CI Push

## 今日目标

完成 GitHub Actions 自动构建 Docker 镜像并推送 Harbor 私有仓库。

流程：

```

Git Push
↓
GitHub Actions
↓
Self-hosted Runner
↓
Docker Build
↓
Docker Login Harbor
↓
Docker Push

````

---

## 1. Self-hosted Runner

配置 GitHub Runner：

```bash
./config.sh \
--url https://github.com/HuAN-ME/Project-Shanghai-2027 \
--token <token>
````

启动：

```bash
./run.sh
```

状态：

```
Listening for Jobs
```

---

## 2. Workflow 配置

Workflow 放置：

```
.github/workflows/day50.yml
```

主要步骤：

* checkout 代码
* 登录 Harbor
* 构建镜像
* 推送镜像

示例：

```yaml
runs-on: self-hosted

steps:
- uses: actions/checkout@v4

- name: Login Harbor
  run: |
    docker login harbor.local

- name: Build Image
  run: |
    docker build \
    -t harbor.local/project-shanghai/day50-demo:v1 \
    ./k8s/labs/day50/github-actions-harbor-demo/app

- name: Push Image
  run: |
    docker push harbor.local/project-shanghai/day50-demo:v1
```

---

## 3. Harbor HTTPS 配置

Harbor 从 HTTP 切换到 HTTPS：

配置：

```yaml
https:
  port: 443
  certificate: /data/cert/harbor.local.crt
  private_key: /data/cert/harbor.local.key
```

重新生成配置：

```bash
./prepare
```

启动：

```bash
docker compose up -d
```

检查：

```bash
ss -lntp | grep 443
```

---

## 4. Docker 信任 Harbor CA

问题：

```
tls: failed to verify certificate:
x509: certificate signed by unknown authority
```

原因：

Docker 不信任自签 CA。

解决：

创建：

```bash
mkdir -p /etc/docker/certs.d/harbor.local
```

复制 CA：

```bash
cp /data/cert/harbor.local.crt \
/etc/docker/certs.d/harbor.local/ca.crt
```

重新登录：

```bash
docker logout harbor.local
docker login harbor.local
```

结果：

```
Login Succeeded
```

---

## 5. 镜像验证

构建：

```bash
docker build \
-t harbor.local/project-shanghai/day50-demo:v1 .
```

推送：

```bash
docker push \
harbor.local/project-shanghai/day50-demo:v1
```

Harbor:

```
project-shanghai
 └── day50-demo
      └── v1
```

出现镜像。

---

## 遇到问题

### workflow 无 Run workflow

原因：

workflow 不在根目录：

```
.github/workflows/
```

解决：

移动 workflow。

### Git add 权限错误

原因：

Harbor 生成文件属于容器 UID。

解决：

```bash
sudo chown -R guoji:guoji harbor/
```

并忽略：

```
common/
data/
```

运行数据不要提交。

### HTTPS unknown authority

原因：

Docker 未信任 Harbor CA。

解决：

```
/etc/docker/certs.d/harbor.local/ca.crt
```

加入证书。
