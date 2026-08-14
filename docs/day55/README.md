````md
# Day55 Helm 多环境管理

## 今日目标

学习 Helm 多环境配置管理，通过不同 values 文件实现 dev / staging / prod 环境差异化部署。


## 目录结构

```text
day55-demo
├── environments
│   ├── dev
│   │   └── values.yaml
│   ├── staging
│   │   └── values.yaml
│   └── prod
│       └── values.yaml
````

## 核心实践

使用同一个 Helm Chart，通过不同 values 文件控制环境配置：

```bash
helm template . -f environments/dev/values.yaml

helm template . -f environments/prod/values.yaml
```

验证：

* dev replicas: 1
* prod replicas: 5

## 部署测试

完成：

* dev 环境 Helm 部署
* staging 环境 Helm 部署
* prod 环境 Helm 部署

## 问题记录

### 1. values.yaml YAML 格式错误

现象：

```text
yaml: line 121: did not find expected key
```

原因：

resources 配置缩进错误。

修复后：

```bash
helm lint .
```

验证通过。

### 2. Deployment 引用不存在的 ServiceAccount

现象：

```text
serviceaccount "day55-demo-dev" not found
```

原因：

旧 Deployment 保留了不存在的 serviceAccount 配置。

处理：

删除旧 Deployment 后重新 Helm upgrade。

### 3. ImagePullBackOff

现象：

```text
Failed to pull image
harbor.local/project-shanghai/day50-demo:dev
```

排查发现 Harbor 服务异常。

### 4. Harbor 恢复

发现 Harbor 仅剩日志容器运行：

```text
harbor-log
```

重新生成配置：

```bash
sudo ./prepare
```

修复权限：

```bash
sudo chown -R guoji:guoji common
```

启动：

```bash
docker compose up -d
```

## 今日总结

完成 Helm 多环境管理实践：

* 使用 environments 管理不同环境 values
* 掌握 Helm template 验证渲染结果
* 掌握 Helm lint 排错
* 学习 Helm upgrade 生命周期问题排查
* 完成 Kubernetes 镜像拉取失败链路排查

