# FluentChat 视频会议功能集成指南

## 概述

本指南说明了如何在RemoteControl项目中集成视频会议功能。该功能基于原有的VideoMeeting项目进行改进，完全集成到了FluentChat客户端和IMback服务端中。

## 功能特性

### 客户端 (FluentChat)
- ✅ 创建视频会议
- ✅ 加入视频会议 
- ✅ 摄像头控制（开启/关闭）
- ✅ 麦克风控制（开启/关闭）
- ✅ 实时音视频传输
- ✅ 参与者管理
- ✅ 现代化FluentUI界面

### 服务端 (IMback)
- ✅ 会议房间管理
- ✅ 音视频数据转发
- ✅ 多客户端连接支持
- ✅ 自动房间清理
- ✅ 独立的TCP服务器（端口8888）

## 架构设计

### 客户端架构
```
VideoMeetingView.qml (UI层)
    ↓
VideoMeetingManager (业务逻辑层)
    ↓
VideoSocket + VideoSurface (网络&媒体层)
```

### 服务端架构
```
VideoMeetingService (主服务)
    ↓
Room Management (房间管理)
    ↓
TCP Server (网络通信)
```

## 使用方法

### 1. 启动服务端
启动IMback服务器，视频会议服务将自动在端口8888上启动：
```bash
cd RemoteControl/IMback
./IMback
```

### 2. 使用客户端
1. 启动FluentChat
2. 在左侧导航栏点击"视频会议"
3. 输入服务器地址（默认127.0.0.1）和端口（默认8888）
4. 点击"创建会议"或输入会议ID后点击"加入会议"
5. 使用控制按钮管理摄像头和麦克风

### 3. 会议控制
- **摄像头控制**: 点击摄像头图标开启/关闭视频
- **麦克风控制**: 点击麦克风图标开启/关闭音频
- **退出会议**: 点击"退出会议"按钮离开

## 技术实现

### 核心组件

#### 1. VideoMeetingManager
- 管理音视频设备
- 处理网络通信
- 协调各个组件

#### 2. VideoSocket
- TCP通信封装
- 消息协议处理
- 数据序列化

#### 3. VideoSurface
- 视频帧处理
- Qt Multimedia集成
- 显示渲染

#### 4. VideoMeetingService (服务端)
- 房间管理
- 消息转发
- 连接管理

### 消息协议

#### 客户端到服务端
- `VIDEO_CREATE_MEETING`: 创建会议
- `VIDEO_JOIN_MEETING`: 加入会议
- `VIDEO_EXIT_MEETING`: 退出会议
- `VIDEO_IMG_SEND`: 发送视频帧
- `VIDEO_AUDIO_SEND`: 发送音频数据

#### 服务端到客户端
- `VIDEO_CREATE_MEETING_RESPONSE`: 会议创建响应
- `VIDEO_JOIN_MEETING_RESPONSE`: 加入会议响应
- `VIDEO_PARTNER_JOIN`: 参与者加入通知
- `VIDEO_PARTNER_EXIT`: 参与者退出通知
- `VIDEO_IMG_RECV`: 接收视频帧
- `VIDEO_AUDIO_RECV`: 接收音频数据

## 文件结构

### 新增的FluentChat文件
```
src/data/videomeeting/
├── VideoMeetingHeader.h          # 协议定义
├── VideoSocket.h/.cpp            # 网络通信
├── VideoSurface.h/.cpp           # 视频surface
└── VideoMeetingManager.h/.cpp    # 主管理类

src/ui/view/
└── VideoMeetingView.qml          # UI界面
```

### 新增的IMback文件
```
service/
├── VideoMeetingService.h         # 服务端主类
└── VideoMeetingService.cpp
```

## 配置要求

### 客户端依赖
- Qt6 Core, Quick, Multimedia, MultimediaWidgets, Network
- 摄像头设备
- 麦克风设备

### 服务端依赖
- Qt6 Core, Network
- 端口8888可用

## 注意事项

1. **网络配置**: 确保防火墙允许端口8888的TCP连接
2. **设备权限**: 客户端需要摄像头和麦克风访问权限
3. **性能考虑**: 视频质量设置为70%压缩，音频采样率8000Hz
4. **房间清理**: 服务端会自动清理1小时内无活动的房间

## 故障排除

### 常见问题

1. **无法连接服务器**
   - 检查服务器地址和端口是否正确
   - 确认服务端已启动
   - 检查网络连接

2. **摄像头无法开启**
   - 检查设备权限
   - 确认摄像头未被其他应用占用
   - 查看控制台错误日志

3. **音频无声音**
   - 检查麦克风权限
   - 确认音频设备正常工作
   - 检查音量设置

### 日志查看
服务端和客户端都会输出详细的调试信息到控制台，可用于问题诊断。

## 扩展功能

该视频会议功能为基础实现，可以进一步扩展：

- 屏幕共享
- 文件传输
- 聊天文字
- 录制功能
- 更多视频编解码格式
- 美颜滤镜

## 开发者说明

本集成保持了原有FluentChat和IMback的所有功能不变，只是增加了新的视频会议模块。代码采用模块化设计，易于维护和扩展。 