import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import FluentUI
import FluentChat.VideoMeeting 1.0

FluPage {
    id: videoMeetingPage
    
    property alias meetingManager: videoManager
    property bool inMeeting: videoManager.isInMeeting
    property bool cameraOn: videoManager.isCameraOn
    property bool audioOn: videoManager.isAudioOn
    property string currentMeetingId: ""
    property bool videoRecording: false
    property bool deviceRecording: false
    
    VideoMeetingManager {
        id: videoManager
        
        onMeetingJoined: {
            currentMeetingId = meetingId
            showSuccess("成功加入会议: " + meetingId)
        }
        
        onMeetingLeft: {
            currentMeetingId = ""
            showInfo("已离开会议")
        }
        
        onParticipantJoined: {
            showInfo("参与者加入: " + participantId)
        }
        
        onParticipantLeft: {
            showInfo("参与者离开: " + participantId)
        }
        
        onErrorOccurred: {
            showError("错误: " + error)
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // 顶部状态栏 - 工业主题
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            gradient: Gradient {
                GradientStop { position: 0.0; color: FluTheme.primaryColor.lightest }
                GradientStop { position: 1.0; color: FluTheme.dark ? FluColors.Grey100 : FluColors.Grey100 }
            }
            radius: 12
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                
                // 工业图标
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: FluTheme.primaryColor.normal
                    
                    FluText {
                        text: "📹"
                        font.pixelSize: 20
                        anchors.centerIn: parent
                    }
                }
                
                FluText {
                    id: meetingStatusText
                    text: inMeeting ? (currentMeetingId ? "远程会议中 - ID: " + currentMeetingId : "远程会议中") : "未在会议中"
                    font.pixelSize: 18
                    font.bold: true
                    color: FluTheme.dark ? FluColors.White : FluColors.Black
                }
                
                Item { Layout.fillWidth: true }
                
                // 状态指示器
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: inMeeting ? FluColors.Green : FluColors.Red
                    border.color: FluTheme.dark ? FluColors.White : FluColors.Black
                    border.width: 2
                }
                
                FluText {
                    text: inMeeting ? "在线" : "离线"
                    color: inMeeting ? FluColors.Green : FluColors.Red
                    font.pixelSize: 14
                    font.bold: true
                }
            }
        }
        
        // 视频显示区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: FluTheme.dark ? FluColors.Grey100 : FluColors.Grey100
            radius: 8
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                // 本地视频
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#2c2c2c"
                    radius: 8
                    border.color: cameraOn ? FluColors.Green : FluColors.Red
                    border.width: 2
                    
                    VideoOutput {
                        id: localVideoOutput
                        anchors.fill: parent
                        anchors.margins: 4
                        visible: cameraOn
                        fillMode: VideoOutput.PreserveAspectFit
                        
                        Component.onCompleted: {
                            // 将VideoOutput的videoSink连接到VideoMeetingManager
                            if (videoManager) {
                                videoManager.setLocalVideoSink(videoSink)
                            }
                        }
                    }
                    
                    FluText {
                        anchors.centerIn: parent
                        text: cameraOn ? (localVideoOutput.visible ? "" : "本地视频") : "摄像头已关闭"
                        color: "white"
                        font.pixelSize: 16
                        visible: !cameraOn || !localVideoOutput.visible
                    }
                }
                
                // 远程视频区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#2c2c2c"
                    radius: 8
                    border.color: FluTheme.dark ? FluColors.Grey120 : FluColors.Grey80
                    border.width: 1
                    
                    VideoOutput {
                        id: remoteVideoOutput
                        anchors.fill: parent
                        anchors.margins: 4
                        fillMode: VideoOutput.PreserveAspectFit
                        
                        Component.onCompleted: {
                            // 将远程VideoOutput的videoSink连接到VideoMeetingManager
                            if (videoManager) {
                                videoManager.setRemoteVideoSink(videoSink)
                            }
                        }
                    }
                    
                    FluText {
                        anchors.centerIn: parent
                        text: "远程视频"
                        color: "white"
                        font.pixelSize: 16
                        visible: !remoteVideoOutput.visible || remoteVideoOutput.videoSink === null
                    }
                }
            }
        }
        
        // 控制按钮区域 - 工业主题
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            gradient: Gradient {
                GradientStop { position: 0.0; color: FluTheme.primaryColor.lightest }
                GradientStop { position: 1.0; color: FluTheme.dark ? FluColors.Grey100 : FluColors.Grey100 }
            }
            radius: 12
            border.color: FluTheme.primaryColor.normal
            border.width: 1
            opacity: 0.9
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 20
                
                // 摄像头控制
                FluIconButton {
                    iconSource: cameraOn ? FluentIcons.VideoChat : FluentIcons.Cancel
                    iconSize: 20
                    text: cameraOn ? "关闭摄像头" : "开启摄像头"
                    disabled: !inMeeting
                    
                    onClicked: {
                        if (cameraOn) {
                            videoManager.stopCamera()
                        } else {
                            videoManager.startCamera()
                        }
                    }
                }
                
                // 麦克风控制
                FluIconButton {
                    iconSource: audioOn ? FluentIcons.AcceptMedium : FluentIcons.Cancel
                    iconSize: 20
                    text: audioOn ? "关闭麦克风" : "开启麦克风"
                    disabled: !inMeeting
                    
                    onClicked: {
                        if (audioOn) {
                            videoManager.stopAudio()
                        } else {
                            videoManager.startAudio()
                        }
                    }
                }
                
                // 视频录制控制
                FluIconButton {
                    iconSource: videoRecording ? FluentIcons.Stop : FluentIcons.Record2
                    iconSize: 20
                    text: videoRecording ? "关闭视频录制" : "开启视频录制"
                    disabled: !inMeeting
                    
                    onClicked: {
                        videoRecording = !videoRecording
                        if (videoRecording) {
                            showInfo("已开启视频录制")
                        } else {
                            showInfo("已关闭视频录制")
                        }
                    }
                }
                
                // 设备信息录制控制
                FluIconButton {
                    iconSource: deviceRecording ? FluentIcons.Stop : FluentIcons.Devices
                    iconSize: 20
                    text: deviceRecording ? "关闭设备信息录制" : "开启设备信息录制"
                    disabled: !inMeeting
                    
                    onClicked: {
                        deviceRecording = !deviceRecording
                        if (deviceRecording) {
                            showInfo("已开启设备信息录制")
                        } else {
                            showInfo("已关闭设备信息录制")
                        }
                    }
                }
                
                // 退出会议
                FluFilledButton {
                    text: "退出远程会议"
                    enabled: inMeeting
                    height: 40
                    font.pixelSize: 14
                    font.bold: true
                    
                    onClicked: {
                        videoManager.exitMeeting()
                    }
                }
            }
        }
        
        // 会议操作区域 - 工业主题
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            gradient: Gradient {
                GradientStop { position: 0.0; color: FluTheme.dark ? FluColors.Grey110 : FluColors.Grey90 }
                GradientStop { position: 1.0; color: FluTheme.dark ? FluColors.Grey100 : FluColors.Grey100 }
            }
            radius: 12
            border.color: FluTheme.primaryColor.normal
            border.width: 1
            opacity: 0.8
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                RowLayout {
                    spacing: 10
                    
                    Rectangle {
                        width: 30
                        height: 30
                        radius: 15
                        color: FluTheme.primaryColor.normal
                        
                        FluText {
                            text: "⚙️"
                            font.pixelSize: 16
                            anchors.centerIn: parent
                        }
                    }
                    
                    FluText {
                        text: "远程会议控制台"
                        font.pixelSize: 18
                        font.bold: true
                        color: FluTheme.primaryColor.normal
                    }
                }
                
                RowLayout {
                    spacing: 10
                    
                    FluTextBox {
                        id: serverInput
                        Layout.preferredWidth: 220
                        placeholderText: "远程服务器地址"
                        text: "127.0.0.1"
                        enabled: !inMeeting
                        font.pixelSize: 14
                    }
                    
                    FluTextBox {
                        id: portInput
                        Layout.preferredWidth: 120
                        placeholderText: "服务端口"
                        text: "8888"
                        enabled: !inMeeting
                        font.pixelSize: 14
                    }
                    
                    FluTextBox {
                        id: meetingIdInput
                        Layout.preferredWidth: 150
                        placeholderText: "会议ID（可选）"
                        enabled: !inMeeting
                        font.pixelSize: 14
                    }
                    
                    FluFilledButton {
                        text: "创建远程会议"
                        enabled: !inMeeting && serverInput.text !== ""
                        height: 35
                        font.pixelSize: 14
                        font.bold: true
                        
                        onClicked: {
                            videoManager.createMeeting(serverInput.text, parseInt(portInput.text))
                        }
                    }
                    
                    FluFilledButton {
                        text: "加入远程会议"
                        enabled: !inMeeting && serverInput.text !== "" && meetingIdInput.text !== ""
                        height: 35
                        font.pixelSize: 14
                        font.bold: true
                        
                        onClicked: {
                            videoManager.joinMeeting(serverInput.text, parseInt(portInput.text), meetingIdInput.text)
                        }
                    }
                }
            }
        }
    }
} 