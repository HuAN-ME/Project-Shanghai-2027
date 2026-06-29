# Project Shanghai 2027 - Day 07

## 网络基础（Networking Basics）

**日期：2026-06-24**

---

# 一、IP地址（ip a）

```bash
ip a

查看结果：

lo：本地回环地址（127.0.0.1）
ens160：物理/虚拟网卡
inet：IPv4地址（如 192.168.157.129）
概念

IP = 设备在网络中的唯一地址

用于：

标识主机
网络通信定位
二、网络连通性（ping）
ping 8.8.8.8
ping baidu.com

结果分析：

ping 8.8.8.8：测试公网连通性
ping 域名：测试DNS解析 + 网络连通性
失败原因：
网络断开
路由问题
DNS解析失败
物理网络问题
三、端口与服务（ss）
ss -tulnp

查看内容：

22：SSH服务
80：HTTP服务
631：打印服务（cups）
概念

端口 = 服务入口

IP + Port = 唯一服务地址

四、本地测试（curl）
curl localhost
curl localhost:8080

结果：

访问成功：服务正常
Connection refused：端口无服务监听
五、网络下载（wget / curl）
curl URL
wget URL

区别：

curl：请求/接口测试
wget：文件下载
六、网络结构理解
IP（主机）
  ↓
Port（服务）
  ↓
Socket（通信接口）
七、网络排障思路

标准排查流程：

1. ip a（检查IP）
2. ping 网关
3. ping 公网IP
4. ping 域名（DNS）
5. curl服务
6. ss检查端口
八、核心总结
IP = 主机地址
DNS = 域名解析
Port = 服务入口
socket = 通信机制
九、实践结果
IP配置正常
DNS解析正常
公网网络基本可用（有轻微丢包）
SSH服务正常监听
HTTP 80端口存在服务
8080未监听（正常）
