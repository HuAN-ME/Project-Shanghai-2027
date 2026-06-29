# Project Shanghai 2027

## Day 08 - Shell脚本与自动化入门

**日期：2026-06-25**

---

# 今日目标

学习：

* Shell脚本
* 变量
* 用户输入
* 条件判断
* 循环
* 自动化思想

---

# 一、第一个Shell脚本

创建：

```bash
vim hello.sh
```

内容：

```bash
#!/bin/bash

echo "Hello Project Shanghai"
```

执行：

```bash
chmod +x hello.sh
./hello.sh
```

---

# 二、变量

示例：

```bash
#!/bin/bash

NAME="guoji"

echo $NAME
```

注意：

```text
变量赋值时等号两边不能有空格
```

---

# 三、获取系统信息

示例：

```bash
#!/bin/bash

echo "User: $(whoami)"
echo "Host: $(hostname)"
echo "Date: $(date)"
hostname -I
```

用途：

* 获取用户名
* 获取主机名
* 获取时间
* 获取IP地址

---

# 四、用户输入

示例：

```bash
read -p "请输入名字: " NAME

echo "你好 $NAME"
```

---

# 五、条件判断

示例：

```bash
if [ -f /etc/passwd ]
then
    echo "文件存在"
else
    echo "文件不存在"
fi
```

用途：

* 检查文件
* 检查服务
* 检查软件

---

# 六、for循环

示例：

```bash
for i in 1 2 3 4 5
do
    echo $i
done
```

批量创建文件：

```bash
for i in 1 2 3 4 5
do
    touch file$i.txt
done
```

---

# 七、自动化思想

传统方式：

```text
人工执行命令
↓
获得结果
```

自动化方式：

```text
编写脚本
↓
脚本执行命令
↓
获得结果
```

---

# 八、实验结果

成功创建：

```text
hello.sh
variable.sh
info.sh
input.sh
check.sh
loop.sh
create_files.sh
daily_check.sh
```

成功生成：

```text
file1.txt
file2.txt
file3.txt
file4.txt
file5.txt
```

系统信息输出正常：

```text
User: guoji
Host: rocky-devops
IP: 192.168.157.129
```

---

# 核心知识点

Q：什么是Shell脚本？

A：

```text
按照顺序执行的一组Shell命令集合。
```

Q：变量有什么作用？

A：

```text
提高脚本复用性，避免重复修改内容。
```

Q：for循环常用于什么？

A：

```text
批量执行重复任务。
```

---

# Day08总结

已掌握：

* Shell脚本创建
* 变量使用
* 用户输入
* if判断
* for循环
* 自动化思想

下一阶段：

Day09 - Git基础

学习：

* git init
* git add
* git commit
* git log
* git status

正式进入 DevOps 工具链学习。
