# Project Shanghai 2027

## Day 05 - Linux 进程与服务管理

**日期：2026-06-22**

---

# 今日目标

理解 Linux 中：

* Process（进程）
* Service（服务）
* PID（进程ID）
* systemd（服务管理器）
* journalctl（日志系统）

掌握：

```bash
ps
top
htop
kill
systemctl
journalctl
```

---

# 一、什么是进程（Process）

Linux 中：

> 所有正在运行的程序都是进程。

例如：

* sshd
* nginx
* docker
* mysql
* kubelet

本质上都是进程。

查看当前进程：

```bash
ps
```

查看所有进程：

```bash
ps -ef
```

查看部分内容：

```bash
ps -ef | head
```

---

# 二、PID（Process ID）

每个进程都有唯一编号：

```text
PID = Process ID
```

例如：

```text
PID 3989 → sshd
PID 4305 → sleep
PID 1 → systemd
```

系统通过 PID 管理进程。

未来排障时经常需要：

```bash
kill PID
```

---

# 三、systemd

查看进程树：

```bash
pstree
```

输出类似：

```text
systemd
├─NetworkManager
├─sshd
├─crond
└─...
```

Linux启动流程：

```text
BIOS/UEFI
↓
GRUB
↓
Kernel
↓
systemd(PID=1)
↓
其它所有进程
```

因此：

> Linux 所有用户态进程最终都来源于 systemd。

---

# 四、top

查看实时系统资源：

```bash
top
```

主要观察：

* CPU
* Memory
* Load Average
* Running Tasks

退出：

```bash
q
```

---

# 五、htop

安装：

```bash
sudo dnf install -y htop
```

启动：

```bash
htop
```

特点：

* 图形化显示
* 操作更直观
* 更适合日常运维

退出：

```text
F10
```

---

# 六、systemctl

systemd 服务管理工具。

查看状态：

```bash
systemctl status sshd
```

启动：

```bash
sudo systemctl start sshd
```

停止：

```bash
sudo systemctl stop sshd
```

重启：

```bash
sudo systemctl restart sshd
```

开机启动：

```bash
sudo systemctl enable sshd
```

检查是否开机启动：

```bash
systemctl is-enabled sshd
```

输出：

```text
enabled
```

表示已启用。

---

# 七、实验：查看SSH服务

执行：

```bash
systemctl status sshd
```

结果：

```text
Active: active (running)
```

说明：

SSH服务正常运行。

---

# 八、journalctl 日志系统

查看日志：

```bash
journalctl
```

查看最近20条：

```bash
journalctl -n 20
```

查看SSH日志：

```bash
journalctl -u sshd
```

查看最近5条SSH日志：

```bash
journalctl -u sshd -n 5
```

实时追踪：

```bash
journalctl -u sshd -f
```

退出：

```text
Ctrl + C
```

---

# 九、实验：创建并终止进程

创建测试进程：

```bash
sleep 300
```

新开终端：

```bash
ps -ef | grep sleep
```

结果：

```text
PID 4305 sleep 300
```

终止：

```bash
kill 4305
```

进程结束。

---

# 十、kill 与 kill -9

普通结束：

```bash
kill PID
```

实际发送：

```text
SIGTERM (15)
```

含义：

```text
请正常退出
```

程序有机会：

* 保存数据
* 关闭连接
* 释放资源

---

强制结束：

```bash
kill -9 PID
```

实际发送：

```text
SIGKILL (9)
```

含义：

```text
立即终止
```

程序没有机会执行清理动作。

---

# 运维原则

优先：

```bash
kill PID
```

无效时：

```bash
kill -9 PID
```

不要直接使用 -9。

---

# 今日知识树

```text
Linux

├── Process
│   ├── ps
│   ├── PID
│   └── kill
│
├── Service
│   ├── systemctl
│   └── systemd
│
├── Monitoring
│   ├── top
│   └── htop
│
└── Logging
    └── journalctl
```

---

# 面试知识点

Q：PID是什么？

A：

```text
Process ID

Linux 为每个进程分配的唯一标识符。
```

---

Q：为什么所有进程最终来自 systemd？

A：

```text
systemd 是 PID 1。

Linux 启动后由 systemd 管理和派生所有用户态服务与进程。
```

---

Q：kill 与 kill -9 的区别？

A：

```text
kill
发送 SIGTERM(15)

kill -9
发送 SIGKILL(9)
```

SIGTERM 为优雅退出。

SIGKILL 为强制退出。

---

# Day05总结

已掌握：

* 进程管理
* PID概念
* 服务管理
* SSH服务状态检查
* systemd基础
* 日志查看
* 进程终止

下一阶段：

Day06 软件包管理（dnf / rpm）

即将进入：

* Git
* Docker
* Nginx
* Jenkins
* Kubernetes

正式开始 DevOps 工程化实践。

