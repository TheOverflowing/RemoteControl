import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import FluentUI
import "qrc:/FluentChat/ui/component/"


FluWindow {
    id: window_login
    title: "工业现场远程专家支持系统 - 登录"
    width: 450
    height: 650
    minimumWidth: 450
    minimumHeight: 650
    visible: true
    launchMode: FluWindowType.SingleTask

    property bool hasCookie: false
    property bool register: false
    property var loginUsername

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: FluTheme.primaryColor.lightest }
            GradientStop { position: 1.0; color: FluTheme.dark ? FluColors.Grey110 : FluColors.Grey90 }
        }
        
        Column {
        spacing: 10
        visible: hasCookie
        width: 200
        anchors.centerIn: parent

        FluText {
            text: "工业现场远程专家支持系统"
            font.pixelSize: 28
            color: FluTheme.primaryColor.normal
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.baseline
                anchors.verticalCenterOffset: height / 3
                color: FluTheme.primaryColor.normal
                opacity: 0.5
                width: parent.width
                height: 6
                radius: height / 2
                z: -1
            }
        }

        FluText {
            text: window_login.loginUsername + " 已登录系统"
            color: FluTheme.primaryColor.normal
            font.pixelSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
            anchors.topMargin: 20
        }

        FluComboBox {
            id: hasCookie_ip
            editable: false
            displayText: {
                if (currentIndex === -1) return "选择网络地址"
                return currentText
            }
            width: parent.width
            font.pixelSize: 14
            model: ListModel {
            }
            Component.onCompleted: {
                var ips = store.control.getIPs()
                for (var ip of ips) {
                    model.append({"text": ip})
                }
            }
        }

        FluFilledButton {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 45
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            text: "快速登录"
            font.pixelSize: 16
            font.bold: true
            onClicked: {
                if (hasCookie_ip.currentText === "") {
                    showError("请选择当前IP")
                    return
                }
                store.IP = hasCookie_ip.currentText
                store.control.init()
                timer.start()
            }
        }
        FluTextButton {
            id: delete_cookie_button
            width: parent.width
            text: "退出登录"
            font.pixelSize: 14
            onClicked: {
                store.setConfig("cookie", "")
                store.setConfig("loginUid", "")
                store.setConfig("loginUsername", "")
                window_login.hasCookie = false
            }
        }
    }

    Column {
        spacing: 10
        visible: !window_login.register && !hasCookie
        width: 200
        anchors.centerIn: parent

        // 工业主题图标
        Rectangle {
            width: 80
            height: 80
            radius: 40
            color: FluTheme.primaryColor.lightest
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
            
            FluText {
                text: "🏭"
                font.pixelSize: 40
                anchors.centerIn: parent
            }
        }
        
        FluText {
            id: login_title
            text: "工业现场远程专家支持系统"
            font.pixelSize: 24
            color: FluTheme.primaryColor.normal
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 10

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.baseline
                anchors.verticalCenterOffset: height / 3
                color: FluTheme.primaryColor.normal
                opacity: 0.3
                width: parent.width
                height: 4
                radius: height / 2
                z: -1
            }
        }
        
        FluText {
            text: "安全登录系统"
            font.pixelSize: 14
            color: FluTheme.dark ? FluColors.Grey120 : FluColors.Grey80
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
        }

        // 输入框容器
        Rectangle {
            width: parent.width
            height: 200
            color: "transparent"
            radius: 12
            border.color: FluTheme.primaryColor.normal
            border.width: 1
            opacity: 0.1
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                FluTextBox {
                    id: login_username
                    width: parent.width
                    placeholderText: "请输入用户名"
                    font.pixelSize: 14
                }
                
                FluPasswordBox {
                    id: login_password
                    width: parent.width
                    placeholderText: "请输入密码"
                    font.pixelSize: 14
                }
                
                FluComboBox {
                    id: login_ip
                    editable: false
                    displayText: {
                        if (currentIndex === -1) return "选择网络地址"
                        return currentText
                    }
                    width: parent.width
                    font.pixelSize: 14
                    model: ListModel {
                    }
                    Component.onCompleted: {
                        var ips = store.control.getIPs()
                        for (var ip of ips) {
                            model.append({"text": ip})
                        }
                    }
                }
            }
        }
        FluFilledButton {
            id: login_button
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 45
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            text: "安全登录"
            font.pixelSize: 16
            font.bold: true
            onClicked: {
                if (check()) {
                    var salt = "FluentChat"
                    var ori_password = login_password.text + salt
                    var hash = Qt.md5(ori_password)
                    store.IP = login_ip.currentText
                    store.control.login(login_username.text, hash)
                }
            }

            function check() {
                if (login_username.text.length === 0) {
                    showError("用户名不能为空")
                    return false
                }
                var regex = /^[a-zA-Z0-9]+$/
                if (!regex.test(login_username.text)) {
                    showError("用户名只能包含字母和数字")
                    return false
                }
                if (login_password.text.length === 0) {
                    showError("密码不能为空")
                    return false
                }
                if (login_ip.currentText === "") {
                    showError("请选择当前IP")
                    return false
                }
                return true
            }
        }
        FluTextButton {
            id: to_register_button
            width: parent.width
            text: "创建新账户"
            font.pixelSize: 14
            onClicked: {
                window_login.register = true
            }
        }
    }

    Column {
        spacing: 10
        visible: window_login.register
        width: 200
        anchors.centerIn: parent

        // 注册页面标题
        FluText {
            text: "用户注册"
            font.pixelSize: 24
            font.bold: true
            color: FluTheme.primaryColor.normal
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
        }
        
        ChatAvatar {
            id: avatar_preview
            bgColor: register_color.colorValue
            avatar: register_avatar.text
            online: true
            size: 50
            anchors.horizontalCenter: parent.horizontalCenter
        }

        FluTextBox {
            id: register_username
            width: parent.width
            placeholderText: "请输入用户名"
            font.pixelSize: 14
        }
        FluPasswordBox {
            id: regiter_password
            width: parent.width
            placeholderText: "请输入密码"
            font.pixelSize: 14
        }
        FluPasswordBox {
            id: regiter_password_confirm
            width: parent.width
            placeholderText: "请确认密码"
            font.pixelSize: 14
        }
        FluTextBox {
            id: register_nickname
            width: parent.width
            placeholderText: "请输入昵称"
            font.pixelSize: 14
        }
        FluTextBox {
            id: register_avatar
            width: parent.width
            placeholderText: "头像字（可为Emoji）"
            font.pixelSize: 14
        }
        FluTextBox {
            id: register_expert_code
            width: parent.width
            placeholderText: "专家验证码（仅专家用户需要填写）"
            visible: true
            font.pixelSize: 14
        }
        FluColorPicker {
            id: register_color
            width: parent.width

            FluText {
                text: "选择头像颜色"
                color: "white"
                font.pixelSize: 14
                anchors.centerIn: parent
            }

            Component.onCompleted: {
                register_color.colorValue = FluTheme.primaryColor.normal
            }
        }
        FluComboBox {
            id: register_ip
            editable: false
            displayText: {
                if (currentIndex === -1) return "选择网络地址"
                return currentText
            }
            width: parent.width
            font.pixelSize: 14
            model: ListModel {
            }
            Component.onCompleted: {
                var ips = store.control.getIPs()
                for (var ip of ips) {
                    model.append({"text": ip})
                }
            }
        }
        FluFilledButton {
            id: register_button
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 45
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            text: "创建账户"
            font.pixelSize: 16
            font.bold: true
            onClicked: {
                if (check()) {
                    var salt = "FluentChat"
                    var ori_password = regiter_password.text + salt
                    var hash = Qt.md5(ori_password)
                    store.IP = register_ip.currentText
                    store.control.registerUser(register_username.text, hash, register_nickname.text, register_color.colorValue, register_avatar.text, register_expert_code.text)
                }
            }

            function check() {
                if (register_username.text.length === 0) {
                    showError("用户名不能为空")
                    return false
                }
                var regex = /^[a-zA-Z0-9]+$/
                if (!regex.test(register_username.text)) {
                    showError("用户名只能包含字母和数字")
                    return false
                }
                if (regiter_password.text.length === 0) {
                    showError("密码不能为空")
                    return false
                }
                if (regiter_password.text !== regiter_password_confirm.text) {
                    showError("两次输入的密码不一致")
                    return false
                }
                if (register_nickname.text.length === 0) {
                    showError("昵称不能为空")
                    return false
                }
                if (register_avatar.text.length === 0) {
                    showError("头像字不能为空")
                    return false
                }
                if (register_ip.currentText === "") {
                    showError("请选择当前IP")
                    return false
                }
                return true
            }
        }
        FluTextButton {
            id: to_login_register_button
            width: parent.width
            text: "返回登录"
            font.pixelSize: 14
            onClicked: {
                window_login.register = false
            }
        }
    }

    Component.onCompleted: {
        if (store.getConfig("cookie") !== "") {
            window_login.hasCookie = true
            window_login.loginUsername = store.getConfig("loginUsername")
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

        function onIsLoginChanged() {
            if (store.isLogin) {
                timer.start()
            }
        }
    }

    Timer {
        id: timer
        interval: 424
        repeat: false
        onTriggered: {
            FluApp.navigate("/")
            window_login.close()
        }
    }

}

}
