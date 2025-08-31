import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

ScrollView {
    contentWidth: availableWidth
    contentHeight: contentLayout.height
    
    property var device: null
    
    // 模拟数据
    property var pressureData: [120, 135, 128, 142, 138, 145, 132, 148, 140, 155, 150, 158, 145, 162, 155, 168, 160, 175, 165, 180]
    property var temperatureData: [45, 48, 46, 50, 49, 52, 47, 54, 51, 56, 53, 58, 55, 60, 57, 62, 59, 64, 61, 66]
    
    // 模拟日志数据
    property var logData: [
        { time: "2024-01-15 14:30:25", level: "信息", message: "设备启动完成，所有系统正常" },
        { time: "2024-01-15 14:35:12", level: "警告", message: "温度传感器读数偏高，建议检查冷却系统" },
        { time: "2024-01-15 14:40:08", level: "信息", message: "压力值在正常范围内波动" },
        { time: "2024-01-15 14:45:33", level: "错误", message: "传感器S-001连接异常，正在尝试重连" },
        { time: "2024-01-15 14:50:17", level: "信息", message: "传感器S-001重连成功" },
        { time: "2024-01-15 14:55:42", level: "警告", message: "油压略低于标准值，建议检查油路" },
        { time: "2024-01-15 15:00:15", level: "信息", message: "例行数据备份完成" },
        { time: "2024-01-15 15:05:28", level: "信息", message: "设备运行状态良好，效率达到95%" }
    ]
    
    // 模拟故障数据
    property var faultData: [
        { id: "F001", time: "2024-01-15 14:45:33", type: "传感器故障", description: "压力传感器S-001连接中断", status: "已解决", priority: "中等" },
        { id: "F002", time: "2024-01-15 13:20:15", type: "温度异常", description: "冷却系统温度过高", status: "处理中", priority: "高" },
        { id: "F003", time: "2024-01-15 12:10:42", type: "机械故障", description: "传送带张力不足", status: "已解决", priority: "低" },
        { id: "F004", time: "2024-01-15 11:30:18", type: "电气故障", description: "电机过载保护触发", status: "待处理", priority: "高" }
    ]
    
    ColumnLayout {
        id: contentLayout
        width: parent.width
        spacing: 20
        
        // 设备基本信息卡片
        FluRectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            radius: [8, 8, 8, 8]
            color: FluTheme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.02)
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                // 设备图标
                FluRectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    radius: [8, 8, 8, 8]
                    color: FluTheme.primaryColor.normal
                    
                    FluIcon {
                        anchors.centerIn: parent
                        iconSource: FluentIcons.Computer
                        iconSize: 40
                        color: "white"
                    }
                }
                
                // 基本信息
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        FluText {
                            text: device ? device.name : "智能生产线A"
                            font: FluTextStyle.Title
                            color: FluTheme.primaryColor.normal
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        FluRectangle {
                            width: 80
                            height: 28
                            radius: [14, 14, 14, 14]
                            color: device && device.status === "运行中" ? "#107c10" : 
                                   device && device.status === "待机中" ? "#ffaa44" : "#d13438"
                            
                            FluText {
                                anchors.centerIn: parent
                                text: device ? device.status : "运行中"
                                color: "white"
                                font: FluTextStyle.Caption
                            }
                        }
                    }
                    
                    FluText {
                        text: "设备ID: " + (device ? device.id : "DEV-001") + " | 类型: " + (device ? device.type : "自动化生产线")
                        font: FluTextStyle.Body
                    }
                    
                    FluText {
                        text: "位置: " + (device ? device.location : "车间1-区域A") + " | 制造商: " + (device ? device.manufacturer : "西门子")
                        font: FluTextStyle.Body
                    }
                    
                    FluText {
                        text: "型号: " + (device ? device.model : "SIMATIC S7-1500") + " | 安装日期: " + (device ? device.installDate : "2023-03-15")
                        font: FluTextStyle.Body
                    }
                }
            }
        }
        
        // 压力温度曲线图
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
                        text: "压力温度实时曲线"
                        font: FluTextStyle.Subtitle
                        color: FluTheme.primaryColor.normal
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // 图例
                    RowLayout {
                        spacing: 16
                        
                        RowLayout {
                            spacing: 8
                            
                            FluRectangle {
                                width: 12
                                height: 12
                                radius: [2, 2, 2, 2]
                                color: "#0078d4"
                            }
                            
                            FluText {
                                text: "压力 (MPa)"
                                font: FluTextStyle.Caption
                            }
                        }
                        
                        RowLayout {
                            spacing: 8
                            
                            FluRectangle {
                                width: 12
                                height: 12
                                radius: [2, 2, 2, 2]
                                color: "#d13438"
                            }
                            
                            FluText {
                                text: "温度 (°C)"
                                font: FluTextStyle.Caption
                            }
                        }
                    }
                }
                
                // 图表区域
                FluRectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: [4, 4, 4, 4]
                    color: FluTheme.dark ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(0, 0, 0, 0.02)
                    
                    Canvas {
                        id: chartCanvas
                        anchors.fill: parent
                        anchors.margins: 8
                        
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            
                            var chartWidth = width - 60
                            var chartHeight = height - 40
                            var startX = 50
                            var startY = 20
                            
                            // 绘制背景网格
                            ctx.strokeStyle = FluTheme.dark ? "#333333" : "#e0e0e0"
                            ctx.lineWidth = 1
                            
                            // 垂直网格线
                            for (var i = 0; i <= 10; i++) {
                                var x = startX + chartWidth * i / 10
                                ctx.beginPath()
                                ctx.moveTo(x, startY)
                                ctx.lineTo(x, startY + chartHeight)
                                ctx.stroke()
                            }
                            
                            // 水平网格线
                            for (var j = 0; j <= 5; j++) {
                                var y = startY + chartHeight * j / 5
                                ctx.beginPath()
                                ctx.moveTo(startX, y)
                                ctx.lineTo(startX + chartWidth, y)
                                ctx.stroke()
                            }
                            
                            // 绘制Y轴标签
                            ctx.fillStyle = FluTheme.dark ? "#ffffff" : "#000000"
                            ctx.font = "12px sans-serif"
                            ctx.textAlign = "right"
                            
                            for (var k = 0; k <= 5; k++) {
                                var labelY = startY + chartHeight * k / 5
                                var pressureValue = 200 - k * 40
                                var tempValue = 80 - k * 16
                                
                                ctx.fillText(pressureValue.toString(), startX - 10, labelY + 4)
                                ctx.fillText(tempValue.toString(), startX - 10, labelY + 20)
                            }
                            
                            // 绘制压力曲线
                            ctx.strokeStyle = "#0078d4"
                            ctx.lineWidth = 2
                            ctx.beginPath()
                            
                            for (var l = 0; l < pressureData.length; l++) {
                                var pressureX = startX + chartWidth * l / (pressureData.length - 1)
                                var pressureY = startY + chartHeight * (1 - (pressureData[l] - 120) / 80)
                                
                                if (l === 0) {
                                    ctx.moveTo(pressureX, pressureY)
                                } else {
                                    ctx.lineTo(pressureX, pressureY)
                                }
                            }
                            ctx.stroke()
                            
                            // 绘制压力数据点
                            ctx.fillStyle = "#0078d4"
                            for (var m = 0; m < pressureData.length; m++) {
                                var pointX = startX + chartWidth * m / (pressureData.length - 1)
                                var pointY = startY + chartHeight * (1 - (pressureData[m] - 120) / 80)
                                
                                ctx.beginPath()
                                ctx.arc(pointX, pointY, 3, 0, 2 * Math.PI)
                                ctx.fill()
                            }
                            
                            // 绘制温度曲线
                            ctx.strokeStyle = "#d13438"
                            ctx.lineWidth = 2
                            ctx.beginPath()
                            
                            for (var n = 0; n < temperatureData.length; n++) {
                                var tempX = startX + chartWidth * n / (temperatureData.length - 1)
                                var tempY = startY + chartHeight * (1 - (temperatureData[n] - 40) / 40)
                                
                                if (n === 0) {
                                    ctx.moveTo(tempX, tempY)
                                } else {
                                    ctx.lineTo(tempX, tempY)
                                }
                            }
                            ctx.stroke()
                            
                            // 绘制温度数据点
                            ctx.fillStyle = "#d13438"
                            for (var o = 0; o < temperatureData.length; o++) {
                                var tempPointX = startX + chartWidth * o / (temperatureData.length - 1)
                                var tempPointY = startY + chartHeight * (1 - (temperatureData[o] - 40) / 40)
                                
                                ctx.beginPath()
                                ctx.arc(tempPointX, tempPointY, 3, 0, 2 * Math.PI)
                                ctx.fill()
                            }
                            
                            // 绘制X轴标签
                            ctx.fillStyle = FluTheme.dark ? "#ffffff" : "#000000"
                            ctx.font = "10px sans-serif"
                            ctx.textAlign = "center"
                            
                            for (var p = 0; p < 10; p++) {
                                var timeX = startX + chartWidth * p / 9
                                var timeLabel = (p * 2).toString().padStart(2, '0') + ":00"
                                ctx.fillText(timeLabel, timeX, startY + chartHeight + 15)
                            }
                        }
                    }
                }
            }
        }
        
        // 日志信息表格
        FluRectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            radius: [8, 8, 8, 8]
            color: FluTheme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.02)
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    FluText {
                        text: "系统日志"
                        font: FluTextStyle.Subtitle
                        color: FluTheme.primaryColor.normal
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    FluButton {
                        text: "刷新"
                        icon: FluentIcons.Refresh
                        onClicked: {
                            // 刷新日志数据
                        }
                    }
                }
                
                // 日志表格
                FluRectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: [4, 4, 4, 4]
                    color: FluTheme.dark ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(0, 0, 0, 0.02)
                    
                    ListView {
                        id: logListView
                        anchors.fill: parent
                        anchors.margins: 8
                        model: logData
                        clip: true
                        
                        delegate: FluRectangle {
                            width: logListView.width
                            height: 40
                            radius: [2, 2, 2, 2]
                            color: index % 2 === 0 ? (FluTheme.dark ? Qt.rgba(1, 1, 1, 0.02) : Qt.rgba(0, 0, 0, 0.01)) : "transparent"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 12
                                
                                FluText {
                                    text: modelData.time
                                    font: FluTextStyle.Caption
                                    color: FluTheme.dark ? "#cccccc" : "#666666"
                                    Layout.preferredWidth: 150
                                }
                                
                                FluRectangle {
                                    width: 50
                                    height: 20
                                    radius: [10, 10, 10, 10]
                                    color: modelData.level === "错误" ? "#d13438" : 
                                           modelData.level === "警告" ? "#ffaa44" : "#107c10"
                                    
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
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 故障信息表格
        FluRectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            radius: [8, 8, 8, 8]
            color: FluTheme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.02)
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    FluText {
                        text: "故障信息"
                        font: FluTextStyle.Subtitle
                        color: FluTheme.primaryColor.normal
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    FluButton {
                        text: "处理故障"
                        icon: FluentIcons.Tools
                        onClicked: {
                            // 处理故障逻辑
                        }
                    }
                }
                
                // 故障表格
                FluRectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: [4, 4, 4, 4]
                    color: FluTheme.dark ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(0, 0, 0, 0.02)
                    
                    ListView {
                        id: faultListView
                        anchors.fill: parent
                        anchors.margins: 8
                        model: faultData
                        clip: true
                        
                        delegate: FluRectangle {
                            width: faultListView.width
                            height: 50
                            radius: [2, 2, 2, 2]
                            color: index % 2 === 0 ? (FluTheme.dark ? Qt.rgba(1, 1, 1, 0.02) : Qt.rgba(0, 0, 0, 0.01)) : "transparent"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 12
                                
                                FluText {
                                    text: modelData.id
                                    font: FluTextStyle.Body
                                    color: FluTheme.primaryColor.normal
                                    Layout.preferredWidth: 60
                                }
                                
                                FluText {
                                    text: modelData.time
                                    font: FluTextStyle.Caption
                                    color: FluTheme.dark ? "#cccccc" : "#666666"
                                    Layout.preferredWidth: 150
                                }
                                
                                FluText {
                                    text: modelData.type
                                    font: FluTextStyle.Body
                                    Layout.preferredWidth: 100
                                }
                                
                                FluText {
                                    text: modelData.description
                                    font: FluTextStyle.Body
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                
                                FluRectangle {
                                    width: 60
                                    height: 20
                                    radius: [10, 10, 10, 10]
                                    color: modelData.status === "已解决" ? "#107c10" : 
                                           modelData.status === "处理中" ? "#ffaa44" : "#d13438"
                                    
                                    FluText {
                                        anchors.centerIn: parent
                                        text: modelData.status
                                        color: "white"
                                        font: FluTextStyle.Caption
                                    }
                                }
                                
                                FluRectangle {
                                    width: 40
                                    height: 20
                                    radius: [10, 10, 10, 10]
                                    color: modelData.priority === "高" ? "#d13438" : 
                                           modelData.priority === "中等" ? "#ffaa44" : "#107c10"
                                    
                                    FluText {
                                        anchors.centerIn: parent
                                        text: modelData.priority
                                        color: "white"
                                        font: FluTextStyle.Caption
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 维护信息
        FluRectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            radius: [8, 8, 8, 8]
            color: FluTheme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.02)
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                
                FluText {
                    text: "维护信息"
                    font: FluTextStyle.Subtitle
                    color: FluTheme.primaryColor.normal
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    
                    FluText {
                        text: "上次维护: " + (device ? device.lastMaintenance : "2024-01-10")
                        font: FluTextStyle.Body
                    }
                    
                    FluText {
                        text: "下次维护: " + (device ? device.nextMaintenance : "2024-04-10")
                        font: FluTextStyle.Body
                    }
                    
                    FluText {
                        text: "维护周期: 30天"
                        font: FluTextStyle.Body
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    FluButton {
                        text: "安排维护"
                        icon: FluentIcons.Calendar
                        onClicked: {
                            // 这里可以添加维护安排逻辑
                        }
                    }
                }
            }
        }
    }
} 