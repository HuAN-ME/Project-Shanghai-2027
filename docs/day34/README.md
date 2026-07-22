# Day34 Kubernetes Service：连接动态 Pod 与稳定服务入口

> Project Shanghai 2027  
> Kubernetes Learning Log

日期：2026-07-21

---

# 一、今日目标

Day33 学习 Deployment：

- 创建 Pod
- 管理 ReplicaSet
- 保持副本数量
- 自动恢复异常 Pod
- Rolling Update


但是产生新的问题：

> Pod 如何被访问？

因为 Kubernetes 中 Pod 具有动态特性：

- Pod 会被重新创建
- Pod IP 会变化
- Pod 生命周期不稳定


因此 Kubernetes 引入：

# Service

用于提供稳定访问入口。


---

# 二、为什么需要 Service


直接访问 Pod：


Client

|

Pod IP

10.244.0.5



存在问题：

如果 Pod 删除：


Pod

10.244.0.5

↓

删除

重新创建

新 Pod

10.244.0.8



IP 已经变化。


因此：

不能依赖 Pod IP。


---

# 三、Service 工作原理


Service 提供稳定入口：

         User

          |

      Service

    10.96.x.x

          |

   ----------------

   Pod     Pod     Pod


Service 负责：

- 固定访问地址
- 自动发现 Pod
- 流量转发
- 负载均衡


---

# 四、Day33 Deployment 环境确认


查看 Deployment：

```bash
kubectl get deployment

结果：

NAME               READY
nginx-deployment   3/3

查看 Pod：

kubectl get pods

确认：

多个 nginx Pod 正常运行。

五、创建 ClusterIP Service

创建：

nginx-service.yaml

内容：

apiVersion: v1
kind: Service

metadata:
  name: nginx-service


spec:

  selector:
    app: nginx


  ports:
  - protocol: TCP
    port: 80
    targetPort: 80


  type: ClusterIP
六、Service YAML 解析
selector
selector:
  app: nginx

Service 根据 Label 查找 Pod。

对应 Deployment：

labels:
  app: nginx

关系：

Service

selector:
 app=nginx


        |

        |

Pod

labels:
 app=nginx

port

Service 暴露端口：

port:80
targetPort

Pod 容器端口：

targetPort:80

流量：

Service:80

      |

      |

Container:80

七、创建 Service

执行：

kubectl apply -f nginx-service.yaml

查看：

kubectl get service

结果：

NAME             TYPE        CLUSTER-IP

nginx-service    ClusterIP   10.96.x.x
八、查看 Service 后端 Pod

执行：

kubectl describe service nginx-service

查看：

Endpoints:
10.244.x.x:80
10.244.x.x:80
10.244.x.x:80

说明：

Service 已经成功关联 Deployment 创建的 Pod。

九、理解 Endpoint

Service 本身不会运行容器。

它维护：

Service

     |

Endpoint列表

     |

Pod IP


当 Pod 变化：

例如：

旧 Pod:

10.244.0.5


删除


新 Pod:

10.244.0.9


Endpoint 会自动更新。

十、NodePort 服务暴露

ClusterIP 默认：

只能集群内部访问。

如果需要外部访问：

使用：

NodePort

示例：

apiVersion: v1
kind: Service

metadata:
  name: nginx-nodeport


spec:

  selector:
    app: nginx


  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080


  type: NodePort
十一、访问测试

查看 Service：

kubectl get svc

查看 minikube IP：

minikube ip

访问：

http://minikube-ip:30080

成功显示：

Welcome to nginx!

说明：

外部请求链路成功。

十二、Service 与 Deployment 完整关系

完整 Kubernetes 应用结构：

User

 |

NodePort

 |

Service

 |

Selector

 |

ReplicaSet

 |

Deployment

 |

Pod

 |

Container

十三、Day34 遇到的问题
问题：

Pod 可以运行，但是无法直接访问。

原因：

Pod IP 不稳定。

解决：

使用 Service 提供稳定入口。

十四、核心知识总结
Deployment

负责：

应用生命周期管理

包括：

创建 Pod
扩容
更新
回滚
Service

负责：

应用网络访问

包括：

服务发现
固定入口
负载均衡
ClusterIP

特点：

默认类型。

用途：

集群内部通信。

NodePort

特点：

开放节点端口。

用途：

外部访问测试。

十五、今日实践成果

完成：

✅ 创建 Kubernetes Service

✅ 理解 Label Selector

✅ 理解 Endpoint

✅ 理解 Pod IP 动态变化问题

✅ 使用 NodePort 暴露 nginx

✅ 建立 Deployment + Service 应用模型

十六、Day34 心得

Day33 解决：

如何保证应用一直存在？

Day34 解决：

如何让应用稳定被访问？

Kubernetes 的核心思想：

不是管理单个容器。

而是管理：

应用状态

+

网络关系

+

生命周期


今天之后：

Kubernetes 基础应用模型：

Deployment

        +

Service

        +

Pod


已经形成完整闭环。

今日关键词
Service

ClusterIP

NodePort

Endpoint

Selector

Label

Service Discovery

Load Balancing
