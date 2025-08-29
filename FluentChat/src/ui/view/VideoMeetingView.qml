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
        
        // 顶部状态栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: FluTheme.dark ? FluColors.Grey100 : FluColors.Grey100
            radius: 8
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                
                FluText {
                    id: meetingStatusText
                    text: inMeeting ? (currentMeetingId ? "会议中 - ID: " + currentMeetingId : "会议中") : "未在会议中"
                    font.pixelSize: 16
                    color: FluTheme.dark ? FluColors.White : FluColors.Black
                }
                
                Item { Layout.fillWidth: true }
                
                FluText {
                    text: inMeeting ? "在线" : "离线"
                    color: inMeeting ? FluColors.Green : FluColors.Red
                    font.pixelSize: 14
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
        
        // 控制按钮区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: FluTheme.dark ? FluColors.Grey100 : FluColors.Grey100
            radius: 8
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 15
                
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
                
                // 退出会议
                FluFilledButton {
                    text: "退出会议"
                    enabled: inMeeting
                    
                    onClicked: {
                        videoManager.exitMeeting()
                    }
                }
            }
        }
        
        // 会议操作区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: FluTheme.dark ? FluColors.Grey100 : FluColors.Grey100
            radius: 8
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                FluText {
                    text: "会议操作"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                RowLayout {
                    spacing: 10
                    
                    FluTextBox {
                        id: serverInput
                        Layout.preferredWidth: 200
                        placeholderText: "服务器地址"
                        text: "127.0.0.1"
                        enabled: !inMeeting
                    }
                    
                    FluTextBox {
                        id: portInput
                        Layout.preferredWidth: 100
                        placeholderText: "端口"
                        text: "8888"
                        enabled: !inMeeting
                    }
                    
                    FluTextBox {
                        id: meetingIdInput
                        Layout.preferredWidth: 150
                        placeholderText: "会议ID（可选）"
                        enabled: !inMeeting
                    }
                    
                    FluButton {
                        text: "创建会议"
                        enabled: !inMeeting && serverInput.text !== ""
                        
                        onClicked: {
                            videoManager.createMeeting(serverInput.text, parseInt(portInput.text))
                        }
                    }
                    
                    FluButton {
                        text: "加入会议"
                        enabled: !inMeeting && serverInput.text !== "" && meetingIdInput.text !== ""
                        
                        onClicked: {
                            videoManager.joinMeeting(serverInput.text, parseInt(portInput.text), meetingIdInput.text)
                        }
                    }
                }
            }
        }
    }
} 