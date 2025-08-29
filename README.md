# Qt6 Remote Control System

基于Qt6的工业远程控制系统，提供安全可靠的远程设备监控和控制功能。

## 部署方法

```
git clone --recursive https://github.com/TheOverflowing/RemoteControl.git
```
然后使用Qt Creator打开根目录下的CMakeList.txt即可。启动后程序运行目录下会有fluentchat.ini配置文件和fluentchat.db的sqlite数据库。

这里使用的版本是Qt 6.5.2的MinGW，安装时除了Android和WASM其他基本都选了。

然后服务端，启动！
## 项目结构

- **IMback/**: 后端服务，使用Qt6 C++实现
- **FluentChat/**: 前端界面，使用Qt6和FluentUI实现

## 功能特点

- 实时设备监控
- 远程控制操作
- 数据采集与分析
- 安全认证机制
- 现代化用户界面

## 技术栈

- **前端**: Qt6 + FluentUI
- **后端**: Qt6 C++
- **数据库**: SQLite
- **构建系统**: CMake

## 开发环境要求

- Qt 6.5-6.7,最好就是Qt6.5
- CMake 3.16+
- C++17 或更高版本
- Git

## 构建和运行

### 1. 克隆仓库
```bash
git clone <your-repository-url>
cd RemoteControl
```

### 2. 构建后端服务 (IMback)
```bash
cd IMback
mkdir build
cd build
cmake ..
make  # Linux/Mac
# 或在Windows上使用Visual Studio/Qt Creator构建
```

### 3. 构建前端界面 (FluentChat)
```bash
cd FluentChat
mkdir build
cd build
cmake ..
make  # Linux/Mac
# 或在Windows上使用Visual Studio/Qt Creator构建
```

## 开发指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/新功能`)
3. 提交更改 (`git commit -m '添加新功能'`)
4. 推送到分支 (`git push origin feature/新功能`)
5. 创建 Pull Request

## 许可证

[MIT](LICENSE) 
