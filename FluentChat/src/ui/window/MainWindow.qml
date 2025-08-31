import QtQuick
import QtQuick.Window
import FluentUI
import "qrc:/FluentChat/ui/view"
import "qrc:/FluentChat/ui/window"


FluWindow {
    id: page_front
    title: "FluentChat"
    width: 1000
    height: 618
    minimumWidth: 666
    minimumHeight: 424
    visible: true
    launchMode: FluWindowType.SingleTask

    Item {
        anchors.fill: parent
        ChatListView {
            id: nav_view
            z: 999
            height: parent.height
            width: 300
            chatList: store.groupList
            footerItems: FluObject {

                property var navigationView

                id: footer_items

                FluPaneItem {
                    title: "视频会议"
                    icon: FluentIcons.VideoChat
                    onTap: {
                        loader_content.sourceComponent = Qt.createComponent("qrc:/FluentChat/ui/view/VideoMeetingView.qml")
                    }
                }

                FluPaneItem {
                    title: "设置"
                    icon: FluentIcons.Settings
                    onTap: {
                        loader_content.sourceComponent = Qt.createComponent("qrc:/FluentChat/ui/view/ConfigView.qml")
                    }
                }

                FluPaneItem {
                    title: "个人信息"
                    icon: FluentIcons.Contact
                    onTap: {
                        loader_content.sourceComponent = Qt.createComponent("qrc:/FluentChat/ui/view/ProfileView.qml")
                    }
                }

                // 专家功能按钮 - 仅专家用户可见
                FluPaneItem {
                    title: "专家功能"
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

