import QtQuick
import QtQuick.Window
import FluentUI
import "qrc:/FluentChat/ui/view"
import "qrc:/FluentChat/ui/window"


FluWindow {
    id: page_front
    title: "工业现场远程专家支持系统"
    width: 1200
    height: 700
    minimumWidth: 800
    minimumHeight: 600
    visible: true
    launchMode: FluWindowType.SingleTask

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: FluTheme.dark ? FluColors.Grey110 : FluColors.Grey90 }
            GradientStop { position: 1.0; color: FluTheme.dark ? FluColors.Grey100 : FluColors.Grey100 }
        }
        
        Item {
            anchors.fill: parent
        ChatListView {
            id: nav_view
            z: 999
            height: parent.height
            width: 320
            chatList: store.groupList
            footerItems: FluObject {

                property var navigationView

                id: footer_items

                FluPaneItem {
                    title: "远程视频会议"
                    icon: FluentIcons.VideoChat
                    onTap: {
                        loader_content.sourceComponent = Qt.createComponent("qrc:/FluentChat/ui/view/VideoMeetingView.qml")
                    }
                }

                FluPaneItem {
                    title: "系统设置"
                    icon: FluentIcons.Settings
                    onTap: {
                        loader_content.sourceComponent = Qt.createComponent("qrc:/FluentChat/ui/view/ConfigView.qml")
                    }
                }

                FluPaneItem {
                    title: "用户信息"
                    icon: FluentIcons.Contact
                    onTap: {
                        loader_content.sourceComponent = Qt.createComponent("qrc:/FluentChat/ui/view/ProfileView.qml")
                    }
                }

                // 专家功能按钮 - 仅专家用户可见
                FluPaneItem {
                    title: "专家控制台"
                    icon: FluentIcons.DeveloperTools
                    onTap: {
                        loader_content.sourceComponent = Qt.createComponent("../view/ExpertPanel.qml")
                    }
                }
            }
        }

        Loader {
            id: loader_content
            anchors {
                left: nav_view.right
                top: parent.top
                right: parent.right
                bottom: parent.bottom
                leftMargin: 2
                topMargin: 2
                rightMargin: 2
                bottomMargin: 2
            }
            // 默认不加载任何页面，保持空白
        }



        Connections {
            target: store
            property bool lastIsChatView : false

            function onCurrentGroupChanged() {
                if (store.currentGroup !== null) {
                    if(!lastIsChatView){
                        lastIsChatView = true
                        loader_content.sourceComponent = Qt.createComponent("qrc:/FluentChat/ui/view/ChatView.qml")
                    }

                } else {
                    lastIsChatView = false
                }

            }
        }
    }


    Connections {
        target: store

        function onErrorMsgChanged() {
            showError(store.errorMsg)
        }

        function onSuccessMsgChanged() {
            showSuccess(store.successMsg)
        }
    }
}

}
