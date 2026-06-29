# Project Shanghai 2027

## Day 09 - Git基础（Version Control）

**日期：2026-06-27**

---

# 今日目标

学习：

- Git配置
- Git仓库初始化
- Git版本管理
- Commit提交
- Git工作流程

---

# 一、Git配置

查看版本：

```bash
git --version
```

配置用户信息：

```bash
git config --global user.name "guoji"
git config --global user.email "your@email.com"
```

查看配置：

```bash
git config --global --list
```

---

# 二、初始化仓库

创建目录：

```bash
mkdir -p ~/lab-day9
cd ~/lab-day9
```

初始化：

```bash
git init
```

查看隐藏文件：

```bash
ls -la
```

生成：

```text
.git
```

说明当前目录已成为 Git Repository。

---

# 三、第一个版本

创建文件：

```bash
echo "# Project Shanghai" > README.md
```

查看状态：

```bash
git status
```

加入暂存区：

```bash
git add README.md
```

提交：

```bash
git commit -m "Initial commit"
```

---

# 四、修改并提交第二个版本

追加内容：

```bash
echo "Day9 Git learning" >> README.md
```

查看修改：

```bash
git diff
```

再次提交：

```bash
git add README.md
git commit -m "Update README"
```

查看历史：

```bash
git log --oneline
```

结果：

```text
Update README
Initial commit
```

---

# 五、Git工作流程

```text
Working Tree（工作区）
        │
    git add
        │
Stage（暂存区）
        │
  git commit
        │
Repository（本地仓库）
```

---

# 六、核心命令

查看状态：

```bash
git status
```

查看历史：

```bash
git log
```

简洁历史：

```bash
git log --oneline
```

查看修改：

```bash
git diff
```

---

# 七、实验结果

成功创建：

```text
lab-day9/
├── .git
└── README.md
```

完成：

- Git仓库初始化
- 两次Commit
- Git历史查看
- 工作区状态检查

README内容：

```text
# Project Shanghai
Day9 Git learning
```

---

# 核心知识点

Q：什么是 Repository？

A：

```text
Repository 是 Git 管理项目代码及其完整历史记录的仓库。
```

Q：为什么需要 git add？

A：

```text
git add 用于将修改加入暂存区，选择本次需要提交的内容，再通过 git commit 写入仓库，保证版本管理清晰、有序。
```

Q：Git 在 DevOps 中的作用？

A：

```text
Git 是版本控制工具，也是 DevOps 流水线的起点，为团队协作、CI/CD、代码回滚和自动化部署提供基础。
```

---

# Day09总结

已掌握：

- Git基础配置
- Repository
- Working Tree
- Stage
- Commit
- Git状态与历史查看

下一阶段：

Day10 - GitHub远程仓库

学习：

- SSH Key
- git clone
- git push
- git pull
- GitHub协作
