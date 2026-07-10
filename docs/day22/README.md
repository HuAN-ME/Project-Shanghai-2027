# Day22 - Container Volume 数据持久化

## 今日目标

- 理解为什么容器删除后数据会丢失
- 理解 Container Writable Layer（可写层）
- 学习 Volume（数据卷）的作用
- 掌握 Podman Bind Mount
- 学习 `-v` 参数
- 理解 Rocky Linux 下 SELinux 与 Volume 的关系

---

# 一、为什么容器数据会丢失？

之前运行 nginx：

```bash
podman run -d --name web nginx
```

进入容器：

```bash
podman exec -it web bash
```

修改 nginx 页面：

```bash
echo "Hello Project Shanghai" > /usr/share/nginx/html/index.html
```

此时访问：

```
localhost
```

可以看到修改后的内容。

---

但是删除容器：

```bash
podman rm -f web
```

重新创建：

```bash
podman run -d --name web nginx
```

发现：

之前修改的文件消失。

---

# 二、原因：Container Writable Layer

Container 并不是直接修改 Image。

结构：

```
Image

↓

Container Writable Layer

↓

Running Container
```

容器运行时：

- Image 提供基础文件
- Writable Layer 保存运行期间的修改


例如：

```
nginx Image

    |
    |
    ↓

Container

    |
    |
    ↓

Writable Layer

(index.html 修改)
```

---

当删除 Container：

```
Container 删除

↓

Writable Layer 删除

↓

数据丢失
```

所以：

> Container 适合运行应用，不适合保存重要数据。

---

# 三、什么是 Volume？

Volume 的核心思想：

> 将数据存储位置从 Container 内部移动到 Container 外部。


没有 Volume：

```
Container

↓

数据

↓

Container 删除

↓

数据消失
```

---

使用 Volume：

```
Host

↓

Volume

↓

Container
```

即：

```
宿主机文件

↓

挂载

↓

容器使用
```

---

# 四、Bind Mount（目录挂载）

Bind Mount：

直接将宿主机目录映射到容器目录。


格式：

```bash
-v HostPath:ContainerPath
```

例如：

```bash
-v ~/website:/usr/share/nginx/html
```

表示：

```
Rocky Linux

~/website

        ↓

nginx Container

/usr/share/nginx/html
```

---

# 五、创建网站目录

创建目录：

```bash
mkdir -p ~/website
```

创建首页：

```bash
echo "<h1>Project Shanghai Day22</h1>" > ~/website/index.html
```

查看：

```bash
cat ~/website/index.html
```

---

# 六、挂载 Volume 运行 nginx

启动：

```bash
podman run -d \
  --name web \
  -p 8080:80 \
  -v ~/website:/usr/share/nginx/html:Z \
  nginx
```

参数说明：

## -d

后台运行：

```
detach
```

---

## --name

指定容器名称：

```
web
```

---

## -p

端口映射：

```
8080:80
```

即：

```
Host 8080

↓

Container 80
```

---

## -v

Volume 挂载：

```
Host Directory

↓

Container Directory
```

---

## :Z

SELinux 标签调整。

Rocky Linux 默认开启 SELinux。

如果没有：

```
:Z
```

可能出现：

```
Permission denied
```

原因：

SELinux 阻止容器访问宿主机目录。


`:Z` 会自动修改 SELinux context：

```
Host Directory

↓

正确 SELinux Label

↓

Container Access
```

---

# 七、验证 Volume 是否生效

查看容器：

```bash
podman ps
```

查看网页：

```bash
curl localhost:8080
```

返回：

```html
<h1>Project Shanghai Day22</h1>
```

说明：

nginx 已经读取宿主机文件。

---

# 八、修改宿主机文件

修改：

```bash
echo "<h1>Hello Volume!</h1>" > ~/website/index.html
```

再次访问：

```bash
curl localhost:8080
```

页面立即变化。


原因：

```
Host

~/website/index.html

↓

Volume

↓

Container

/usr/share/nginx/html/index.html

↓

nginx
```

---

# 九、查看 Volume 挂载信息

查看：

```bash
podman inspect web
```

关注：

```
Mounts
```

可以看到：

```
Source:

/home/guoji/website


Destination:

/usr/share/nginx/html
```

表示：

宿主机目录已经成功挂载。

---

# 十、今日实验流程总结

完整流程：

```
创建 Host Directory

↓

创建 index.html

↓

启动 Container

↓

-v 挂载目录

↓

nginx读取Host文件

↓

修改Host文件

↓

Container内容同步变化
```

---

# 十一、今日踩坑记录

## 坑1：数据为什么消失？

错误理解：

```
Container = Storage
```

实际：

```
Container = Runtime Environment
```

删除 Container：

数据一起删除。

---

## 坑2：SELinux 权限问题

Rocky Linux:

```
SELinux Enabled
```

挂载目录：

可能出现：

```
Permission denied
```

解决：

添加：

```bash
:Z
```

例如：

```bash
-v ~/website:/usr/share/nginx/html:Z
```

---

# 十二、核心命令总结

|功能|命令|
|-|-|
|进入容器|`podman exec -it web bash`|
|删除容器|`podman rm -f web`|
|创建目录|`mkdir -p ~/website`|
|启动挂载容器|`podman run -v`|
|查看容器|`podman ps`|
|查看挂载|`podman inspect web`|
|测试服务|`curl localhost:8080`|

---

# 十三、今日知识总结

Day22 学习了容器数据持久化。

核心概念：

## Container

负责：

```
运行应用
```

---

## Volume

负责：

```
保存数据
```

---

关系：

```
Image

↓

Container

↓

Volume

↓

Persistent Data
```

---

# 今日记忆点

一句话：

> **容器负责运行，Volume 负责保存。**

生产环境中：

数据库：

- MySQL
- PostgreSQL

缓存：

- Redis

文件：

- 用户上传文件
- 日志

都不能依赖 Container Writable Layer。

必须使用：

- Volume
- Persistent Storage
- Kubernetes PVC

---

# Day22 完成 ✅

下一阶段：

Day23 将继续深入：

- Named Volume
- Volume 生命周期管理
- 容器数据备份与恢复
- 为后续 Docker Compose / Kubernetes Persistent Volume 做准备
