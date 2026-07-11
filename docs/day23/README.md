# Day23 - Named Volume 与 Volume 生命周期管理

## 今日目标

- 理解 Bind Mount 与 Named Volume 区别
- 学习 Podman Volume 管理
- 创建 Named Volume
- 使用 Named Volume 持久化 nginx 数据
- 理解 Volume 与 Container 生命周期关系
- 掌握 Volume 查看、删除操作

---

# 一、回顾 Day22：Bind Mount

Day22 使用：

```bash
-v ~/website:/usr/share/nginx/html:Z
```

结构：

```
Rocky Linux Host

/home/guoji/website

        ↓

nginx Container

/usr/share/nginx/html
```

这种方式叫：

```
Bind Mount
```

---

## Bind Mount 特点

优点：

- 直观
- 宿主机可以直接修改文件
- 开发环境方便


缺点：

- 依赖宿主机目录结构
- 迁移困难
- 管理复杂


例如：

服务器 A：

```
/home/user/project
```

服务器 B：

```
/data/project
```

路径不同。

---

# 二、什么是 Named Volume？

Named Volume：

由 Podman 自己创建和管理的数据卷。


结构：

```
Host

↓

Podman Volume

↓

Container
```

用户不需要关心真实存储路径。


例如：

创建：

```bash
podman volume create nginx-data
```

Podman 自动管理：

```
nginx-data
```

---

# 三、创建 Named Volume

创建：

```bash
podman volume create nginx-data
```

查看：

```bash
podman volume ls
```

结果：

```
DRIVER
local

NAME
nginx-data
```

说明 Volume 创建成功。

---

# 四、使用 Named Volume 部署 nginx


删除旧容器：

```bash
podman rm -f web
```


启动：

```bash
podman run -d \
--name web \
-p 8080:80 \
-v nginx-data:/usr/share/nginx/html:Z \
nginx
```

---

参数解释：

## -d

后台运行：

```
detach
```


## --name

指定容器名称：

```
web
```


## -p

端口映射：

```
8080:80
```

关系：

```
Host 8080

↓

Container 80
```


## -v

Volume 挂载：

```
nginx-data

↓

/usr/share/nginx/html
```


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

SELinux 阻止 Container 访问 Host 文件。

---

# 五、进入容器写入数据


进入：

```bash
podman exec -it web bash
```


进入 nginx 网站目录：

```bash
cd /usr/share/nginx/html
```


创建首页：

```bash
echo "<h1>Day23 Named Volume</h1>" > index.html
```


退出：

```bash
exit
```

---

# 六、测试 Volume 数据

访问：

```bash
curl localhost:8080
```

返回：

```html
<h1>Day23 Named Volume</h1>
```

说明：

nginx 正在读取 Volume 中的数据。

---

# 七、验证 Volume 持久化

停止容器：

```bash
podman stop web
```

删除 Container：

```bash
podman rm web
```

查看 Volume：

```bash
podman volume ls
```

结果：

```
nginx-data
```

仍然存在。


说明：

```
Container 删除

↓

Volume 保留

↓

数据继续存在
```

---

重新创建：

```bash
podman run -d \
--name web \
-p 8080:80 \
-v nginx-data:/usr/share/nginx/html:Z \
nginx
```


测试：

```bash
curl localhost:8080
```

仍然可以看到：

```
Day23 Named Volume
```

---

# 八、Volume 生命周期


完整流程：

```
Create Volume

↓

Attach Container

↓

Write Data

↓

Remove Container

↓

Volume Exists

↓

Attach New Container

↓

Recover Data
```

---

# 九、查看 Volume 详情


命令：

```bash
podman volume inspect nginx-data
```


可以看到：

```json
[
 {
   "Name": "nginx-data",
   "Mountpoint":
   "/home/guoji/.local/share/containers/storage/volumes/nginx-data"
 }
]
```

说明：

Volume 实际存储位置由 Podman 管理。

---

# 十、删除 Volume


查看：

```bash
podman volume ls
```


删除：

```bash
podman volume rm nginx-data
```


如果 Volume 正被使用：

会失败。


需要：

先删除 Container：

```bash
podman rm -f web
```


再：

```bash
podman volume rm nginx-data
```

---

# 十一、Bind Mount vs Named Volume


| |Bind Mount|Named Volume|
|-|-|-|
|管理者|用户|Podman|
|路径|明确|Podman管理|
|迁移|困难|方便|
|开发环境|常用|一般|
|生产环境|较少|推荐|
|备份|手动|统一管理|

---

# 十二、核心命令总结


## 创建 Volume

```bash
podman volume create nginx-data
```


## 查看 Volume

```bash
podman volume ls
```


## 查看 Volume 详情

```bash
podman volume inspect nginx-data
```


## 删除 Volume

```bash
podman volume rm nginx-data
```


## 使用 Volume

```bash
podman run \
-v nginx-data:/path \
image
```

---

# 十三、今日实验流程


完整流程：

```
创建 Volume

↓

启动 Container

↓

挂载 Volume

↓

写入数据

↓

删除 Container

↓

重新创建 Container

↓

数据恢复
```

---

# 十四、今日踩坑记录


## 坑1：认为删除 Container 会删除数据


错误理解：

```
Container = Storage
```


实际：

```
Container = Runtime
Volume = Storage
```


---

## 坑2：SELinux 权限问题


Rocky Linux:

```
SELinux Enabled
```


挂载：

```bash
-v volume:path:Z
```


解决：

```
添加 :Z
```

---

# 十五、今日知识总结


Day23 学习了 Named Volume。

核心思想：

```
Container

负责运行应用


Volume

负责保存数据
```


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

> **Container 可以随时删除，但 Volume 中的数据应该长期存在。**

---

# Day23 完成 ✅


今天完成从：

```
运行容器
```

到：

```
管理容器数据
```

的重要转变。


后续：

Day24 将进入：

## Container Image Build

学习：

- Dockerfile / Containerfile
- 自定义镜像
- Image Layer
- Build Process

正式进入 DevOps 镜像工程流程。
