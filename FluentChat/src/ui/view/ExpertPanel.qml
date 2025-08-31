import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluContentPage {
    id: expertPanel
    title: "专家功能面板"
    
    Component.onCompleted: {
        console.log("专家面板加载完成")
        console.log("当前用户:", store.currentUser ? store.currentUser.username : "无")
        console.log("用户类型:", store.currentUser ? store.currentUser.userType : "无")
    }
    
    // 模拟数据
    property var systemStatus: {
        "cpu": 45,
        "memory": 68,
        "disk": 32,
        "network": 78
    }
    
    property var recentLogs: [
        {"level": "INFO", "message": "系统运行正常", "time": "2024-01-15 14:30:22"},
        {"level": "WARN", "message": "内存使用率较高", "time": "2024-01-15 14:25:15"},
        {"level": "ERROR", "message": "数据库连接超时", "time": "2024-01-15 14:20:08"},
        {"level": "INFO", "message": "用户登录成功", "time": "2024-01-15 14:15:33"}
    ]
    
    property var workOrders: [
        {"id": "WO-001", "title": "系统性能优化", "client": "张三", "status": "pending", "priority": "high", "time": "2024-01-15 15:00"},
        {"id": "WO-002", "title": "数据库维护", "client": "李四", "status": "accepted", "priority": "medium", "time": "2024-01-15 16:30"},
        {"id": "WO-003", "title": "网络安全检查", "client": "王五", "status": "rejected", "priority": "low", "time": "2024-01-15 17:00"},
        {"id": "WO-004", "title": "服务器升级", "client": "赵六", "status": "pending", "priority": "high", "time": "2024-01-15 18:00"}
    ]
    
    property var performanceData: [
        {"name": "响应时间", "value": 120, "unit": "ms", "trend": "up"},
        {"name": "并发用户", "value": 156, "unit": "", "trend": "up"},
        {"name": "错误率", "value": 0.5, "unit": "%", "trend": "down"},
        {"name": "吞吐量", "value": 2.3, "unit": "MB/s", "trend": "up"}
    ]

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: contentLayout.height

        ColumnLayout {
            id: contentLayout
            width: parent.width
            spacing: 20

            // 系统状态卡片
            FluRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                radius: [8, 8, 8, 8]
                color: FluTheme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.02)
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    
                    FluText {
                        text: "系统状态监控"
                        font: FluTextStyle.Subtitle
                        color: FluTheme.primaryColor.normal
                    }
                    
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 4
                        rowSpacing: 8
                        columnSpacing: 12
                        
                        // CPU使用率
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4
                            
                            FluText {
                                text: "CPU"
                                font: FluTextStyle.Caption
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            FluProgressRing {
                                Layout.alignment: Qt.AlignHCenter
                                value: systemStatus.cpu / 100
                                strokeWidth: 6
                                width: 50
                                height: 50
                                color: systemStatus.cpu > 80 ? "#d13438" : systemStatus.cpu > 60 ? "#ffaa44" : "#107c10"
                                
                                FluText {
                                    anchors.centerIn: parent
                                    text: systemStatus.cpu + "%"
                                    font: FluTextStyle.Caption
                                }
                            }
                        }
                        
                        // 内存使用率
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4
                            
                            FluText {
                                text: "内存"
                                font: FluTextStyle.Caption
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            FluProgressRing {
                                Layout.alignment: Qt.AlignHCenter
                                value: systemStatus.memory / 100
                                strokeWidth: 6
                                width: 50
                                height: 50
                                color: systemStatus.memory > 80 ? "#d13438" : systemStatus.memory > 60 ? "#ffaa44" : "#107c10"
                                
                                FluText {
                                    anchors.centerIn: parent
                                    text: systemStatus.memory + "%"
                                    font: FluTextStyle.Caption
                                }
                            }
                        }
                        
                        // 磁盘使用率
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4
                            
                            FluText {
                                text: "磁盘"
                                font: FluTextStyle.Caption
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            FluProgressRing {
                                Layout.alignment: Qt.AlignHCenter
                                value: systemStatus.disk / 100
                                strokeWidth: 6
                                width: 50
                                height: 50
                                color: systemStatus.disk > 80 ? "#d13438" : systemStatus.disk > 60 ? "#ffaa44" : "#107c10"
                                
                                FluText {
                                    anchors.centerIn: parent
                                    text: systemStatus.disk + "%"
                                    font: FluTextStyle.Caption
                                }
                            }
                        }
                        
                        // 网络使用率
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4
                            
                            FluText {
                                text: "网络"
                                font: FluTextStyle.Caption
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            FluProgressRing {
                                Layout.alignment: Qt.AlignHCenter
                                value: systemStatus.network / 100
                                strokeWidth: 6
                                width: 50
                                height: 50
                                color: systemStatus.network > 80 ? "#d13438" : systemStatus.network > 60 ? "#ffaa44" : "#107c10"
                                
                                FluText {
                                    anchors.centerIn: parent
                                    text: systemStatus.network + "%"
                                    font: FluTextStyle.Caption
                                }
                            }
                        }
                    }
                }
            }

            // 性能指标卡片
            FluRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                radius: [8, 8, 8, 8]
                color: FluTheme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.02)
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    
                    FluText {
                        text: "性能指标"
                        font: FluTextStyle.Subtitle
                        color: FluTheme.primaryColor.normal
                    }
                    
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 4
                        rowSpacing: 8
                        columnSpacing: 12
                        
                        Repeater {
                            model: performanceData
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 4
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    FluText {
                                        text: modelData.name
                                        font: FluTextStyle.Caption
                                        Layout.fillWidth: true
                                    }
                                    
                                    FluIcon {
                                        iconSource: modelData.trend === "up" ? FluentIcons.CaretUpSolid8 : FluentIcons.CaretDownSolid8
                                        color: modelData.trend === "up" ? "#107c10" : "#d13438"
                                        iconSize: 10
                                    }
                                }
                                
                                FluText {
                                    text: modelData.value + (modelData.unit ? " " + modelData.unit : "")
                                    font: FluTextStyle.BodyStrong
                                    color: FluTheme.primaryColor.normal
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }

            // 预约工单管理卡片
            FluRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                radius: [8, 8, 8, 8]
                color: FluTheme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.02)
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        FluText {
                            text: "预约工单管理"
                            font: FluTextStyle.Title
                            color: FluTheme.primaryColor.normal
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        FluButton {
                            text: "刷新"
                            icon: FluentIcons.Refresh
                            onClicked: {
                                // 模拟刷新数据
                                showSuccess("工单数据已刷新")
                            }
                        }
                    }
                    
                    // 工单列表
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8
                        clip: true
                        
                        model: workOrders
                        
                        delegate: FluRectangle {
                            width: parent.width
                            height: 80
                            radius: [6, 6, 6, 6]
                            color: FluTheme.dark ? Qt.rgba(1, 1, 1, 0.03) : Qt.rgba(0, 0, 0, 0.01)
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12
                                
                                // 工单ID和标题
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 4
                                    
                                    FluText {
                                        text: modelData.id + " - " + modelData.title
                                        font: FluTextStyle.BodyStrong
                                    }
                                    
                                    FluText {
                                        text: "客户: " + modelData.client + " | 时间: " + modelData.time
                                        font: FluTextStyle.Caption
                                        color: FluTheme.textColor.secondary
                                    }
                                }
                                
                                // 优先级标签
                                FluRectangle {
                                    width: 40
                                    height: 20
                                    radius: [10, 10, 10, 10]
                                    color: modelData.priority === "high" ? "#d13438" : modelData.priority === "medium" ? "#ffaa44" : "#107c10"
                                    
                                    FluText {
                                        anchors.centerIn: parent
                                        text: modelData.priority === "high" ? "高" : modelData.priority === "medium" ? "中" : "低"
                                        color: "white"
                                        font: FluTextStyle.Caption
                                    }
                                }
                                
                                // 状态标签
                                FluRectangle {
                                    width: 50
                                    height: 20
                                    radius: [10, 10, 10, 10]
                                    color: modelData.status === "pending" ? "#ffaa44" : modelData.status === "accepted" ? "#107c10" : "#d13438"
                                    
                                    FluText {
                                        anchors.centerIn: parent
                                        text: modelData.status === "pending" ? "待处理" : modelData.status === "accepted" ? "已接受" : "已拒绝"
                                        color: "white"
                                        font: FluTextStyle.Caption
                                    }
                                }
                                
                                // 操作按钮
                                RowLayout {
                                    spacing: 8
                                    visible: modelData.status === "pending"
                                    
                                    FluButton {
                                        text: "接受"
                                        icon: FluentIcons.AcceptMedium
                                        onClicked: {
                                            // 模拟接受工单
                                            workOrders[index].status = "accepted"
                                            showSuccess("工单 " + modelData.id + " 已接受")
                                        }
                                    }
                                    
                                    FluButton {
                                        text: "拒绝"
                                        icon: FluentIcons.ChromeClose
                                        onClicked: {
                                            // 模拟拒绝工单
                                            workOrders[index].status = "rejected"
                                            showError("工单 " + modelData.id + " 已拒绝")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 系统日志卡片
            FluRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                radius: [8, 8, 8, 8]
                color: FluTheme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.02)
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    
                    FluText {
                        text: "系统日志"
                        font: FluTextStyle.Title
                        color: FluTheme.primaryColor.normal
                    }
                    
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4
                        clip: true
                        
                        model: recentLogs
                        
                        delegate: RowLayout {
                            width: parent.width
                            height: 30
                            spacing: 8
                            
                            FluRectangle {
                                width: 50
                                height: 20
                                radius: [10, 10, 10, 10]
                                color: modelData.level === "ERROR" ? "#d13438" : modelData.level === "WARN" ? "#ffaa44" : "#107c10"
                                
                                FluText {
                                    anchors.centerIn: parent
                                    text: modelData.level
                                    color: "white"
                                    font: FluTextStyle.Caption
                                }
                            }
                            
                            FluText {
                                text: modelData.message
                                font: FluTextStyle.Body
                                Layout.fillWidth: true
                            }
                            
                            FluText {
                                text: modelData.time
                                font: FluTextStyle.Caption
                                color: FluTheme.textColor.secondary
                            }
                        }
                    }
                }
            }

            // 快速操作卡片
            FluRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                radius: [8, 8, 8, 8]
                color: FluTheme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.02)
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    
                    FluText {
                        text: "快速操作"
                        font: FluTextStyle.Title
                        color: FluTheme.primaryColor.normal
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 16
                        
                        FluButton {
                            text: "系统重启"
                            icon: FluentIcons.Refresh
                            onClicked: {
                                showInfo("系统重启功能（模拟）")
                            }
                        }
                        
                        FluButton {
                            text: "备份数据"
                            icon: FluentIcons.Document
                            onClicked: {
                                showSuccess("数据备份完成（模拟）")
                            }
                        }
                        
                        FluButton {
                            text: "清理缓存"
                            icon: FluentIcons.Delete
                            onClicked: {
                                showSuccess("缓存清理完成（模拟）")
                            }
                        }
                        
                        FluButton {
                            text: "查看报告"
                            icon: FluentIcons.Info
                            onClicked: {
                                showInfo("生成系统报告（模拟）")
                            }
                        }
                    }
                }
            }
        }
    }
} 