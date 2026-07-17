# Day29 - Compose 三层应用架构（Nginx + App + PostgreSQL）

## 今日目标

- 理解企业常见三层架构
- 学习多服务 Compose 编排
- 理解 Service Name 通信
- 学习 Environment Variables
- 学习 PostgreSQL 数据持久化
- 理解 Volume 在数据库中的作用
- 排查容器运行正常但应用异常的问题

---

# 一、从单容器到完整应用

之前：

```
Container

↓

Application
```

例如：

```
nginx
```

但是企业应用通常不是单个容器。

真实架构：

```
              Browser

                 |

                 ↓

              Nginx

          (Web Gateway)

                 |

                 ↓

             Backend

          (Application)

                 |

                 ↓

            PostgreSQL

             (Database)
```

这就是：

三层架构。

---

# 二、三层架构理解

## 1. Presentation Layer

表现层：

负责用户访问。

例如：

```
Nginx
```

作用：

- 接收 HTTP 请求
- 提供静态页面
- 反向代理


---

## 2. Application Layer

业务层：

例如：

```
Flask
Spring Boot
Node.js
```

负责：

- 业务逻辑
- API
- 数据处理


---

## 3. Data Layer

数据层：

例如：

```
PostgreSQL
MySQL
Redis
```

负责：

- 数据存储
- 查询
- 持久化

---

# 三、今日项目结构

创建：

```
containers/day29/

├── compose.yaml

├── nginx/

│   └── index.html

└── backend/

    ├── Containerfile

    ├── app.py

    └── requirements.txt
```

---

# 四、Backend 服务

使用：

```
Python Flask
```

创建 API。

app.py：

功能：

返回：

```
Project Shanghai Day29
```

并读取：

```
DB_HOST
```

环境变量。

---

# 五、Backend Containerfile

内容：

```Dockerfile
FROM python:3.12

WORKDIR /app

COPY app/ .

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python","app.py"]
```

作用：

构建 Flask 镜像。

---

# 六、Compose 三服务结构

目标：

```
services:

    nginx

    app

    postgres
```

三个 Service：

对应三个 Container。

---

# 七、Service Name 通信

今天学习重要概念：

容器之间：

不使用 IP。

错误：

```
192.168.x.x
```

正确：

```
postgres
```

例如：

App：

连接数据库：

```
DB_HOST=postgres
```

原因：

Compose 会自动创建 Network。

并提供：

Service Discovery。

---

# 八、Environment Variables

数据库配置：

例如：

```
POSTGRES_DB=project

POSTGRES_USER=admin

POSTGRES_PASSWORD=password
```

通过：

环境变量

传递给 Container。

优点：

- 配置与代码分离
- 修改方便
- 符合企业实践

---

# 九、Volume 数据持久化

数据库：

不能只存在 Container 内。

原因：

Container 删除后：

数据可能丢失。

因此：

使用：

```
Volume
```

保存：

```
PostgreSQL Data
```

结构：

```
Container

    |

    ↓

Volume

    |

    ↓

Persistent Data
```

---

# 十、今日遇到的问题

## 问题：

访问：

```
http://localhost:8080
```

显示：

```
Welcome to nginx!
```

而不是：

```
Project Shanghai Day29
```

---

# 十一、问题分析

原因：

compose.yaml：

使用：

```yaml
nginx:

    image: nginx
```

这代表：

直接使用官方 nginx 镜像。


官方镜像默认包含：

```
/usr/share/nginx/html/index.html
```

内容：

```
Welcome to nginx!
```

---

但是：

自己创建的：

```
nginx/index.html
```

没有进入 Container。

所以：

显示官方默认页面。

---

# 十二、解决方案

## 方法1：自定义 Nginx Image（推荐）

创建：

```
nginx/Containerfile
```

内容：

```Dockerfile
FROM nginx

COPY index.html /usr/share/nginx/html/

EXPOSE 80
```

然后：

修改：

compose.yaml：

```yaml
nginx:

    build:
      context: ./nginx
```

重新：

```bash
podman compose down

podman compose up --build
```

---

## 方法2：Volume 挂载

开发环境：

可以：

```yaml
volumes:

- ./nginx/index.html:/usr/share/nginx/html/index.html
```

优点：

修改立即生效。

缺点：

生产环境较少使用。

---

# 十三、今天的重要认知

## 容器启动成功 ≠ 应用部署成功

例如：

今天：

```
nginx container

Running
```

但是：

应用：

错误。

原因：

镜像内容不是自己想象的内容。

所以排查需要：

```
Container

↓

Image

↓

Volume

↓

Network

↓

Application
```

完整检查。

---

# 十四、今日排查命令

查看运行容器：

```bash
podman ps
```

查看日志：

```bash
podman logs container_name
```

进入容器：

```bash
podman exec -it container_name bash
```

查看 Network：

```bash
podman network ls
```

查看 Volume：

```bash
podman volume ls
```

---

# 十五、今日实验流程

完成：

```
创建项目目录

↓

创建 Flask Backend

↓

创建 PostgreSQL

↓

创建 Compose

↓

启动多个 Container

↓

验证服务

↓

发现 Nginx 默认页面问题

↓

定位原因

↓

理解 Image 内容
```

---

# 十六、今日踩坑总结

## 坑1：

以为：

```
创建 index.html

↓

Nginx 自动使用
```

错误。

Container 内文件：

不会自动同步。

必须：

COPY

或者：

Volume Mount。


---

## 坑2：

官方 Image 与自己的文件混淆。

例如：

```
image: nginx
```

代表：

官方镜像。

不是：

自己的 nginx 项目。


---

## 坑3：

看到 Container Running 就认为成功。

实际上：

需要验证：

```
访问链路
```

---

# 十七、核心命令

启动：

```bash
podman compose up --build
```

停止：

```bash
podman compose down
```

查看：

```bash
podman ps
```

日志：

```bash
podman compose logs
```

重新构建：

```bash
podman compose build
```

---

# 十八、今日总结

Day29 学习：

```
多容器应用架构
```

理解：

```
Browser

↓

Nginx

↓

Application

↓

Database

↓

Volume
```

同时掌握：

- Compose 多服务
- Service Discovery
- Environment Variables
- Database Volume
- Container 排障方法


---

# 今日记忆点

一句话：

> **容器部署的核心不是启动 Container，而是保证整个 Application Flow 正常工作。**

---

# Day29 完成 ✅

Project Shanghai 当前技术栈：

```
Linux

+

Git/GitHub

+

GitHub Actions

+

Podman

+

Container

+

Image

+

Registry

+

Compose

+

Multi-service Application

+

Network

+

Volume

+

Database Persistence ✅
```
