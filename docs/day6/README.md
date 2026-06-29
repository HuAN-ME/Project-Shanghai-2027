# Project Shanghai 2027

## Day 06 - 软件包管理（DNF / RPM）

**日期：2026-06-23**

---

# 今日目标

掌握 Rocky Linux 软件管理体系：

* dnf
* rpm
* repository（软件仓库）

理解：

* 软件安装
* 软件查询
* 软件升级
* 软件卸载
* 软件依赖

---

# 一、软件仓库（Repository）

查看仓库：

```bash
dnf repolist
```

当前仓库：

```text
appstream
baseos
epel
epel-cisco-openh264
extras
```

说明：

* BaseOS：系统基础软件
* AppStream：应用软件
* Extras：额外组件
* EPEL：企业级扩展软件仓库

---

# 二、DNF

DNF 是 Rocky Linux 默认的软件包管理工具。

作用：

* 搜索软件
* 安装软件
* 升级软件
* 卸载软件
* 自动解决依赖

搜索软件：

```bash
dnf search git
```

查看软件信息：

```bash
dnf info git
```

安装软件：

```bash
sudo dnf install -y git
```

升级软件：

```bash
sudo dnf upgrade -y
```

卸载软件：

```bash
sudo dnf remove git
```

---

# 三、RPM

RPM（Red Hat Package Manager）是底层包管理系统。

查看已安装软件：

```bash
rpm -qa
```

查看指定软件：

```bash
rpm -qa | grep git
```

查看软件详细信息：

```bash
rpm -qi git
```

查看软件安装文件：

```bash
rpm -ql git
```

---

# 四、软件依赖

安装 Git 时：

```bash
sudo dnf install git
```

实际上会自动安装多个依赖包。

这称为：

```text
Dependency（依赖）
```

DNF 会自动处理依赖关系。

这是企业环境优先使用 DNF 的原因之一。

---

# 五、定位软件来源

查看命令路径：

```bash
which sshd
```

结果：

```text
/usr/sbin/sshd
```

查看所属软件包：

```bash
rpm -qf $(which sshd)
```

结果：

```text
openssh-server
```

说明：

```text
sshd 命令来自 openssh-server 软件包
```

---

# 今日实验结果

查看仓库：

```bash
dnf repolist
```

结果正常：

```text
appstream
baseos
epel
extras
```

Git安装成功：

```bash
git --version
```

结果：

```text
git version 2.52.0
```

SSH服务所属软件包：

```bash
rpm -qf $(which sshd)
```

结果：

```text
openssh-server
```

---

# 面试知识点

Q：DNF 与 RPM 的关系？

A：

```text
RPM 是底层包管理系统。

DNF 是基于 RPM 的高级包管理工具。
```

---

Q：为什么企业更喜欢 DNF？

A：

```text
自动解决依赖关系。

支持仓库管理。

支持软件升级与维护。
```

---

Q：rpm -ql 有什么作用？

A：

```text
查看软件包安装的所有文件。
```

常用于定位：

* 配置文件
* 二进制程序
* 服务文件

---

# Day06总结

已掌握：

* 软件仓库
* DNF安装与卸载
* RPM查询
* 软件依赖
* 软件包定位

下一阶段：

Day07 网络基础

学习：

* ip
* ping
* curl
* wget
* ss

开始接触真正的服务器网络管理。
