# Day18 - GitHub Actions Secrets & Workflow Debugging

## 今日目标

- 学习 GitHub Secrets 的使用
- 学习 Environment Variables（环境变量）
- 使用 `workflow_dispatch` 手动触发 Workflow
- 掌握 GitHub Actions Workflow 调试方法
- 学会排查 YAML 语法错误

---

## 今日知识点

### 1. GitHub Secrets

用于安全保存敏感信息，例如：

- Token
- Password
- API Key
- SSH Private Key

仓库路径：

```
Settings
→ Secrets and variables
→ Actions
```

引用方式：

```yaml
${{ secrets.MY_NAME }}
```

GitHub 会自动隐藏 Secrets 输出：

```
Hello ***
```

而不会直接显示真实内容。

---

### 2. Environment Variables

Workflow 中可以定义公共变量：

```yaml
env:
  PROJECT: "Project Shanghai"
```

Shell 中直接引用：

```bash
echo "$PROJECT"
```

也可以在 Job 或 Step 中单独定义 env。

---

### 3. workflow_dispatch

允许手动运行 Workflow：

```yaml
on:
  workflow_dispatch:
```

运行方式：

```
Actions
→ 选择 Workflow
→ Run workflow
```

适用于：

- 手动部署
- 发布版本
- 调试 Workflow

---

### 4. 推荐的 run 写法

推荐：

```yaml
run: |
  echo "Hello"
  pwd
  ls -la
```

而不是：

```yaml
run: echo "Hello"
```

企业 CI/CD 中几乎全部采用多行脚本格式，可读性更高，也避免 YAML 解析问题。

---

# 今日踩坑记录

## 坑一：ED25519 无法生成

错误：

```
ED25519 keys are not allowed in FIPS mode
```

原因：

Rocky Linux 开启 FIPS 模式，不允许使用 ED25519。

解决：

改用 RSA：

```bash
ssh-keygen -t rsa -b 4096
```

---

## 坑二：GitHub SSH 登录失败

错误：

```
Permission denied (publickey)
```

原因：

GitHub 未添加 SSH Public Key。

解决：

复制：

```bash
cat ~/.ssh/id_rsa.pub
```

添加到：

```
GitHub
Settings
SSH and GPG Keys
```

---

## 坑三：Workflow 不执行

GitHub 一直提示：

```
Invalid workflow file
```

并提示：

```
Line 15
```

最初怀疑：

- 缩进错误
- Secret 配置错误
- ASCII/BOM
- Tab
- Git 提交异常

经过逐项排查全部排除。

---

## 坑四：真正的问题

YAML Lint 最终提示：

```
Nested mappings are not allowed
```

问题代码：

```yaml
run: echo "Project: $PROJECT"
```

由于字符串中包含：

```
Project:
```

YAML 将 `:` 误解析为 Mapping。

最终改为：

```yaml
run: |
  echo "Project: $PROJECT"
```

问题解决。

---

## Debug 思路总结

今天完整经历了一次企业级 Workflow 排查流程：

① 查看 GitHub 报错

↓

② 检查 YAML 缩进

↓

③ 检查 ASCII / UTF-8

↓

④ 检查 BOM

↓

⑤ 检查 Tab

↓

⑥ 检查 Git Push 是否成功

↓

⑦ 检查 Workflow 是否真正运行

↓

⑧ 使用 YAML Lint 定位语法错误

↓

⑨ 修正 Workflow

↓

⑩ Workflow 成功运行

---

## 今日收获

掌握了：

- GitHub Secrets
- Environment Variables
- workflow_dispatch
- GitHub Actions Debug
- YAML 调试方法
- 企业 Workflow 编写规范

相比编写 Workflow，本次最大的收获是：

> **学习了 GitHub Actions 的排错思路。**

---

## 企业经验

CI/CD 工作中：

- 30% 编写 Pipeline
- 70% 排查 Pipeline

真正的 DevOps 工程师更重要的是：

- 看日志
- 找原因
- 排查问题
- 修复流程

而不是单纯会写 YAML。

---

## Day18 总结

今天完成了 Project Shanghai GitHub Actions 的安全配置学习。

实现了：

- GitHub Secrets 管理
- Environment Variables 使用
- 手动触发 Workflow
- Workflow Debug
- YAML 语法排查

完成了第一次完整的 GitHub Actions 故障排查实践，为后续学习 Docker CI、自动测试、自动部署奠定基础。
