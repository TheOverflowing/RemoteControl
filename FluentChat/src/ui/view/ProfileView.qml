import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia
import FluentUI
import "qrc:/FluentChat/ui/component/"

FluPage {
    id: profileView
    
    // 编辑状态
    property bool isEditing: false
    property bool isChangingPassword: false
    
    // 临时存储编辑的数据
    property string tempNickname: ""
    property string tempAvatar: ""
    property string tempUsername: ""
    
    // 密码修改相关
    property string oldPassword: ""
    property string newPassword: ""
    property string confirmPassword: ""
    
    // 初始化临时数据
    Component.onCompleted: {
        if (store.currentUser) {
            tempNickname = store.currentUser.nickname
            tempAvatar = store.currentUser.avatar
            tempUsername = store.currentUser.username
        }
    }
    
    // 当用户信息变化时更新临时数据
    Connections {
        target: store.currentUser
        function onNicknameChanged() {
            if (store.currentUser) {
                tempNickname = store.currentUser.nickname
            }
        }
        function onAvatarChanged() {
            if (store.currentUser) {
                tempAvatar = store.currentUser.avatar
            }
        }
        function onUsernameChanged() {
            if (store.currentUser) {
                tempUsername = store.currentUser.username
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        
        ColumnLayout {
            width: Math.max(parent.width - 40, 400)  // 设置最小宽度并减去边距
            spacing: 20
            anchors.margins: 20
        
            // 标题
            FluText {
                text: "个人信息"
                font.pixelSize: 24
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            // 头像区域
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                
                ChatAvatar {
                    id: profileAvatar
                    bgColor: FluTheme.primaryColor.lightest
                    avatar: store.currentUser ? store.currentUser.avatar : "👤"
                    online: store.currentUser ? store.currentUser.online : false
                    size: 120
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // 头像编辑
                FluButton {
                    text: "更换头像"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        avatarDialog.open()
                    }
                }
            }
            
            // 用户信息表单
            FluArea {
                Layout.fillWidth: true
                Layout.minimumHeight: 250
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    // 用户名
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        FluIcon {
                            iconSource: FluentIcons.Contact
                            iconSize: 20
                        }
                        
                        FluText {
                            text: "用户名："
                            font.pixelSize: 14
                            Layout.preferredWidth: 80
                        }
                        
                        FluTextBox {
                            id: usernameInput
                            text: tempUsername
                            placeholderText: "请输入用户名"
                            enabled: isEditing
                            Layout.fillWidth: true
                        }
                    }
                    
                    // 昵称
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        FluIcon {
                            iconSource: FluentIcons.Edit
                            iconSize: 20
                        }
                        
                        FluText {
                            text: "昵称："
                            font.pixelSize: 14
                            Layout.preferredWidth: 80
                        }
                        
                        FluTextBox {
                            id: nicknameInput
                            text: tempNickname
                            placeholderText: "请输入昵称"
                            enabled: isEditing
                            Layout.fillWidth: true
                        }
                    }
                    
                    // 用户类型
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        FluIcon {
                            iconSource: FluentIcons.Contact
                            iconSize: 20
                        }
                        
                        FluText {
                            text: "用户类型："
                            font.pixelSize: 14
                            Layout.preferredWidth: 80
                        }
                        
                        FluText {
                            text: store.currentUser ? (store.currentUser.userType === "expert" ? "专家用户" : "普通用户") : "未知"
                            font.pixelSize: 14
                            color: store.currentUser && store.currentUser.userType === "expert" ? FluTheme.primaryColor : FluTheme.textColor
                        }
                    }
                    
                    // 在线状态
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        FluIcon {
                            iconSource: FluentIcons.CircleFill
                            iconSize: 20
                            color: store.currentUser && store.currentUser.online ? "#4CAF50" : FluTheme.textColor
                        }
                        
                        FluText {
                            text: "在线状态："
                            font.pixelSize: 14
                            Layout.preferredWidth: 80
                        }
                        
                        FluText {
                            text: store.currentUser && store.currentUser.online ? "在线" : "离线"
                            font.pixelSize: 14
                            color: store.currentUser && store.currentUser.online ? "#4CAF50" : FluTheme.textColor
                        }
                    }
                    
                    // 编辑/保存按钮
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        spacing: 10
                        
                        FluButton {
                            text: isEditing ? "保存" : "编辑"
                            onClicked: {
                                if (isEditing) {
                                    // 保存更改
                                    if (nicknameInput.text.trim() === "") {
                                        showError("昵称不能为空")
                                        return
                                    }
                                    if (usernameInput.text.trim() === "") {
                                        showError("用户名不能为空")
                                        return
                                    }
                                    
                                    // 更新用户信息
                                    if (store.currentUser) {
                                        store.currentUser.nickname = nicknameInput.text
                                        store.currentUser.username = usernameInput.text
                                        store.currentUser.avatar = tempAvatar
                                    }
                                    
                                    tempNickname = nicknameInput.text
                                    tempUsername = usernameInput.text
                                    isEditing = false
                                    showSuccess("个人信息更新成功")
                                } else {
                                    isEditing = true
                                }
                            }
                        }
                        
                        FluButton {
                            text: "取消"
                            visible: isEditing
                            onClicked: {
                                // 恢复原始数据
                                nicknameInput.text = store.currentUser ? store.currentUser.nickname : ""
                                usernameInput.text = store.currentUser ? store.currentUser.username : ""
                                tempAvatar = store.currentUser ? store.currentUser.avatar : ""
                                profileAvatar.avatar = store.currentUser ? store.currentUser.avatar : "👤"
                                isEditing = false
                            }
                        }
                    }
                }
            }
            
            // 密码修改区域
            FluArea {
                Layout.fillWidth: true
                Layout.minimumHeight: 200
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    FluText {
                        text: "修改密码"
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // 旧密码
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        FluIcon {
                            iconSource: FluentIcons.Lock
                            iconSize: 20
                        }
                        
                        FluText {
                            text: "旧密码："
                            font.pixelSize: 14
                            Layout.preferredWidth: 80
                        }
                        
                        FluTextBox {
                            id: oldPasswordInput
                            placeholderText: "请输入旧密码"
                            echoMode: TextInput.Password
                            enabled: isChangingPassword
                            Layout.fillWidth: true
                        }
                    }
                    
                    // 新密码
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        FluIcon {
                            iconSource: FluentIcons.Lock
                            iconSize: 20
                        }
                        
                        FluText {
                            text: "新密码："
                            font.pixelSize: 14
                            Layout.preferredWidth: 80
                        }
                        
                        FluTextBox {
                            id: newPasswordInput
                            placeholderText: "请输入新密码"
                            echoMode: TextInput.Password
                            enabled: isChangingPassword
                            Layout.fillWidth: true
                        }
                    }
                    
                    // 确认密码
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        FluIcon {
                            iconSource: FluentIcons.Lock
                            iconSize: 20
                        }
                        
                        FluText {
                            text: "确认密码："
                            font.pixelSize: 14
                            Layout.preferredWidth: 80
                        }
                        
                        FluTextBox {
                            id: confirmPasswordInput
                            placeholderText: "请再次输入新密码"
                            echoMode: TextInput.Password
                            enabled: isChangingPassword
                            Layout.fillWidth: true
                        }
                    }
                    
                    // 密码修改按钮
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        spacing: 10
                        
                        FluButton {
                            text: isChangingPassword ? "确认修改" : "修改密码"
                            onClicked: {
                                if (isChangingPassword) {
                                    // 验证密码
                                    if (oldPasswordInput.text.trim() === "") {
                                        showError("请输入旧密码")
                                        return
                                    }
                                    if (newPasswordInput.text.trim() === "") {
                                        showError("请输入新密码")
                                        return
                                    }
                                    if (confirmPasswordInput.text.trim() === "") {
                                        showError("请确认新密码")
                                        return
                                    }
                                    if (newPasswordInput.text !== confirmPasswordInput.text) {
                                        showError("两次输入的密码不一致")
                                        return
                                    }
                                    
                                    // 调用后端API修改密码
                                    store.control.changePassword(oldPasswordInput.text, newPasswordInput.text)
                                    
                                    oldPasswordInput.text = ""
                                    newPasswordInput.text = ""
                                    confirmPasswordInput.text = ""
                                    isChangingPassword = false
                                } else {
                                    isChangingPassword = true
                                }
                            }
                        }
                        
                        FluButton {
                            text: "取消"
                            visible: isChangingPassword
                            onClicked: {
                                oldPasswordInput.text = ""
                                newPasswordInput.text = ""
                                confirmPasswordInput.text = ""
                                isChangingPassword = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 头像选择对话框
    FluContentDialog {
        id: avatarDialog
        title: ""
        message: ""
        
        GridView {
            id: avatarGrid
            width: 300
            height: 200
            cellWidth: 50
            cellHeight: 50
            
            model: ListModel {
                ListElement { avatar: "😀" }
                ListElement { avatar: "😃" }
                ListElement { avatar: "😄" }
                ListElement { avatar: "😁" }
                ListElement { avatar: "😆" }
                ListElement { avatar: "😅" }
                ListElement { avatar: "😂" }
                ListElement { avatar: "🤣" }
                ListElement { avatar: "😊" }
                ListElement { avatar: "😇" }
                ListElement { avatar: "🙂" }
                ListElement { avatar: "🙃" }
                ListElement { avatar: "😉" }
                ListElement { avatar: "😌" }
                ListElement { avatar: "😍" }
                ListElement { avatar: "🥰" }
                ListElement { avatar: "😘" }
                ListElement { avatar: "😗" }
                ListElement { avatar: "😙" }
                ListElement { avatar: "😚" }
                ListElement { avatar: "😋" }
                ListElement { avatar: "😛" }
                ListElement { avatar: "😝" }
                ListElement { avatar: "😜" }
                ListElement { avatar: "🤪" }
                ListElement { avatar: "🤨" }
                ListElement { avatar: "🧐" }
                ListElement { avatar: "🤓" }
                ListElement { avatar: "😎" }
                ListElement { avatar: "🤩" }
                ListElement { avatar: "🥳" }
                ListElement { avatar: "😏" }
                ListElement { avatar: "😒" }
                ListElement { avatar: "😞" }
                ListElement { avatar: "😔" }
                ListElement { avatar: "😟" }
                ListElement { avatar: "😕" }
                ListElement { avatar: "🙁" }
                ListElement { avatar: "☹️" }
                ListElement { avatar: "😣" }
                ListElement { avatar: "😖" }
                ListElement { avatar: "😫" }
                ListElement { avatar: "😩" }
                ListElement { avatar: "🥺" }
                ListElement { avatar: "😢" }
                ListElement { avatar: "😭" }
                ListElement { avatar: "😤" }
                ListElement { avatar: "😠" }
                ListElement { avatar: "😡" }
                ListElement { avatar: "🤬" }
                ListElement { avatar: "🤯" }
                ListElement { avatar: "😳" }
                ListElement { avatar: "🥵" }
                ListElement { avatar: "🥶" }
                ListElement { avatar: "😱" }
                ListElement { avatar: "😨" }
                ListElement { avatar: "😰" }
                ListElement { avatar: "😥" }
                ListElement { avatar: "😓" }
                ListElement { avatar: "🤗" }
                ListElement { avatar: "🤔" }
                ListElement { avatar: "🤭" }
                ListElement { avatar: "🤫" }
                ListElement { avatar: "🤥" }
                ListElement { avatar: "😶" }
                ListElement { avatar: "😐" }
                ListElement { avatar: "😑" }
                ListElement { avatar: "😯" }
                ListElement { avatar: "😦" }
                ListElement { avatar: "😧" }
                ListElement { avatar: "😮" }
                ListElement { avatar: "😲" }
                ListElement { avatar: "🥱" }
                ListElement { avatar: "😴" }
                ListElement { avatar: "🤤" }
                ListElement { avatar: "😪" }
                ListElement { avatar: "😵" }
                ListElement { avatar: "🤐" }
                ListElement { avatar: "🥴" }
                ListElement { avatar: "🤢" }
                ListElement { avatar: "🤮" }
                ListElement { avatar: "🤧" }
                ListElement { avatar: "😷" }
                ListElement { avatar: "🤒" }
                ListElement { avatar: "🤕" }
                ListElement { avatar: "🤑" }
                ListElement { avatar: "🤠" }
                ListElement { avatar: "👻" }
                ListElement { avatar: "👽" }
                ListElement { avatar: "🤖" }
                ListElement { avatar: "😺" }
                ListElement { avatar: "😸" }
                ListElement { avatar: "😹" }
                ListElement { avatar: "😻" }
                ListElement { avatar: "😼" }
                ListElement { avatar: "😽" }
                ListElement { avatar: "🙀" }
                ListElement { avatar: "😿" }
                ListElement { avatar: "😾" }
            }
            
            delegate: Rectangle {
                width: avatarGrid.cellWidth
                height: avatarGrid.cellHeight
                color: "transparent"
                radius: 5
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        tempAvatar = model.avatar
                        profileAvatar.avatar = model.avatar
                        avatarDialog.close()
                    }
                    onEntered: {
                        parent.color = FluTheme.primaryColor.opacity(0.1)
                    }
                    onExited: {
                        parent.color = "transparent"
                    }
                }
                
                FluText {
                    text: model.avatar
                    font.pixelSize: 30
                    anchors.centerIn: parent
                }
            }
        }
        
        buttonFlags: FluContentDialogType.NegativeButton
        negativeText: "取消"
    }
} 