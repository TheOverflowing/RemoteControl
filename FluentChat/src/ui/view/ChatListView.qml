import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import FluentUI
import "qrc:/FluentChat/ui/global"
import "qrc:/FluentChat/ui/component"

Item {
    id: control
    property var chatList
    property FluObject footerItems
    property Component autoSuggestBox
    property double chat_item_height: 66
    property double footer_item_height: 42

    Component {
        id: chat_item
        Item {
            clip: true
            height: chat_item_height
            visible: true
            width: layout_list.width
            FluControl {
                id: item_control
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: 2
                    bottomMargin: 2
                    leftMargin: 6
                    rightMargin: 6
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: function (mouse) {
                        if (mouse.button === Qt.RightButton) {
                            if (model.menuDelegate) {
                                loader_item_menu.sourceComponent = model.menuDelegate
                                loader_item_menu.item.popup();
                            }
                        }
                    }
                    z: -100
                }
                onClicked: {
                    chat_list.currentIndex = _idx
                    store.control.openGroup(model)
                }
                Rectangle {
                    radius: 4
                    anchors.fill: parent
                    color: {
                        if (FluTheme.dark) {
                            if (chat_list.currentIndex === _idx) {
                                return Qt.rgba(1, 1, 1, 0.06)
                            }
                            if (item_control.hovered) {
                                return Qt.rgba(1, 1, 1, 0.03)
                            }
                            return Qt.rgba(0, 0, 0, 0)
                        } else {
                            if (chat_list.currentIndex === _idx) {
                                return Qt.rgba(0, 0, 0, 0.06)
                            }
                            if (item_control.hovered) {
                                return Qt.rgba(0, 0, 0, 0.03)
                            }
                            return Qt.rgba(0, 0, 0, 0)
                        }
                    }

                    ChatAvatar {
                        id: item_avatar
                        avatar: model.type === "twin" ? model.owner.avatar : model.avatar
                        bgColor: model.type === "twin" ? model.owner.color : model.color
                        online: model.type === "twin" ? model.owner.online : false
                        size: 42
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 10
                        }
                    }

                    FluText {
                        id: item_title
                        text: {
                            if (model.remark) return model.remark;
                            if (model.type === "twin") return model.owner.remark ? model.owner.remark : model.owner.nickname
                            return model.name
                        }
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        font.pixelSize: 16
                        color: {
                            if (item_control.pressed) {
                                return FluTheme.dark ? FluColors.Grey80 : FluColors.Grey120
                            }
                            return FluTheme.dark ? FluColors.White : FluColors.Grey220
                        }
                        anchors {
                            left: item_avatar.right
                            leftMargin: 10
                            right: time_text.left
                            rightMargin: 5
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: -10
                        }
                    }
                    FluText {
                        id: item_text
                        text: {
                            if (!model.last) return ""
                            let text = ""
                            if (model.type !== "twin") text = model.last.user.remark ? model.last.user.remark : model.last.user.nickname + "："
                            switch (model.last.type) {
                                case "text":
                                    text += model.last.content
                                    break
                                case "image":
                                    text += "[图片]"
                                    break
                                case "file":
                                    text += "[文件]"
                                    break
                                case "p2p_file":
                                    text += "[P2P文件]"
                                    break
                            }
                            return text
                        }
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        font.pixelSize: 12
                        color: {
                            if (item_control.pressed) {
                                return FluTheme.dark ? FluColors.Grey120 : FluColors.Grey80
                            }
                            return FluTheme.dark ? FluColors.Grey80 : FluColors.Grey120
                        }
                        anchors {
                            left: item_avatar.right
                            leftMargin: 10
                            right: unread_badge.left
                            rightMargin: 5
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: 10
                        }
                    }

                    FluText {
                        id: time_text
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: -10
                            rightMargin: 10
                        }
                        text: model.last ? GlobalTool.formatTime(model.last.time) : ""
                        font.pixelSize: 10
                        color: item_text.color
                    }

                    Rectangle {
                        id: unread_badge
                        color: Qt.rgba(255 / 255, 77 / 255, 79 / 255, 1)
                        width: {
                            if (model.unreadNum < 10) {
                                return 20
                            } else if (model.unreadNum < 100) {
                                return 30
                            }
                            return 35
                        }
                        height: 20
                        radius: 10
                        border.width: 0
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: 10
                            rightMargin: 10
                        }
                        visible: model.unreadNum !== 0
                        Text {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                                verticalCenterOffset: 1
                            }

                            color: Qt.rgba(1, 1, 1, 1)
                            text: {
                                if (model.unreadNum < 100)
                                    return model.unreadNum
                                return "99+"
                            }
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }
            }
        }
    }

    Component {
        id: footer_item
        Item {
            clip: true
            height: footer_item_height
            visible: true
            width: parent ? parent.width : layout_list.width
            FluControl {
                id: item_control
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: 2
                    bottomMargin: 2
                    leftMargin: 6
                    rightMargin: 6
                }
                onClicked: {
                    model.tap()
                    chat_list.currentIndex = -1
                    store.currentGroup = null
                }
                Rectangle {
                    radius: 4
                    anchors.fill: parent
                    color: {
                        if (FluTheme.dark) {
                            if (item_control.hovered) {
                                return Qt.rgba(1, 1, 1, 0.03)
                            }
                            return Qt.rgba(0, 0, 0, 0)
                        } else {
                            if (item_control.hovered) {
                                return Qt.rgba(0, 0, 0, 0.03)
                            }
                            return Qt.rgba(0, 0, 0, 0)
                        }
                    }

                    Item {
                        id: item_icon
                        width: 30
                        height: 30
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 3
                        }
                        FluIcon {
                            anchors.centerIn: parent
                            iconSource: {
                                if (model.icon) {
                                    return model.icon
                                }
                                return 0
                            }
                            iconSize: 15
                        }
                    }
                    FluText {
                        id: item_title
                        text: model.title
                        elide: Text.ElideRight
                        color: {
                            if (item_control.pressed) {
                                return FluTheme.dark ? FluColors.Grey80 : FluColors.Grey120
                            }
                            return FluTheme.dark ? FluColors.White : FluColors.Grey220
                        }
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: item_icon.right
                            right: parent.right
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: layout_list
        width: parent.width
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        color: FluTheme.dark ? Window.active ? Qt.rgba(38 / 255, 44 / 255, 54 / 255, 1) : Qt.rgba(39 / 255, 39 / 255, 39 / 255, 1) : Qt.rgba(251 / 255, 251 / 255, 253 / 255, 1)
        border.color: FluTheme.dark ? Qt.rgba(45 / 255, 45 / 255, 45 / 255, 1) : Qt.rgba(226 / 255, 230 / 255, 234 / 255, 1)
        border.width: 1

        // 发起预约工单按钮已移至底部网格布局中
        Item {
            id: layout_header
            width: layout_list.width
            height: 50
            FluAutoSuggestBox {
                anchors {
                    left: parent.left
                    leftMargin: 15
                    right: add_button.left
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                iconSource: FluentIcons.Search
                items: {
                    var groups = store.groupList.items
                    var result = []
                    for (var i = 0; i < groups.length; i++) {
                        var group = groups[i]
                        if (group.type === "twin") {
                            var user = group.owner
                            if (user.nickname.indexOf(text) !== -1 || user.remark.indexOf(text) !== -1 || user.username.indexOf(text) !== -1) {
                                result.push({title: user.remark ? user.remark : user.nickname, key: group.id})
                            }
                        } else {
                            if (group.name.indexOf(text) !== -1 || group.remark.indexOf(text) !== -1) {
                                result.push({title: group.remark ? user.remark : group.name, key: group.id})
                            }
                        }
                    }
                    return result
                }
                placeholderText: "搜索"
                onItemClicked: (data) => {
                    for (var i = 0; i < store.groupList.items.length; i++) {
                        if (store.groupList.items[i].id === data.key) {
                            chat_list.currentIndex = i
                            store.control.openGroup(store.groupList.items[i])
                            return
                        }
                    }
                }
            }
            FluIconButton {
                id: add_button
                anchors {
                    right: parent.right
                    rightMargin: 15
                    verticalCenter: parent.verticalCenter
                }
                iconSource: FluentIcons.AddBold
                iconColor: FluTheme.dark ? FluTheme.primaryColor.lighter : FluTheme.primaryColor.dark
                visible: store.currentUser !== null
                onClicked: {
                    add_popup.visible = true
                }
            }


            Popup {
                id: add_popup
                modal: true
                visible: false
                width: 150
                x: add_button.x - (add_popup.width - add_button.width) / 2
                y: add_button.y + add_button.height
                topInset: 5
                bottomInset: 5
                leftInset: 5
                rightInset: 5
                clip: true

                enter: Transition {
                    NumberAnimation {
                        property: "height"
                        from: 0
                        to: 155
                        duration: 233
                        easing.type: Easing.InOutExpo
                    }

                    NumberAnimation {
                        property:"opacity"
                        from:0
                        to: 1
                        duration: 233
                    }
                }
                exit: Transition {
                    NumberAnimation {
                        property: "height"
                        from: 155
                        to: 0
                        duration: 233
                        easing.type: Easing.InOutExpo
                    }

                    NumberAnimation {
                        property:"opacity"
                        from:1
                        to: 0
                        duration: 233
                    }
                }

                background: FluArea {
                    radius: 5
                    border.width: 0
                }


                Column {
                    id: add_popup_column
                    width: parent.width
                    spacing: 5

                    Repeater {
                        model: [
                            {
                                text: "添加好友", icon: FluentIcons.AddFriend, onClick: () => {
                                    add_user_dialog.visible = true
                                }
                            },
                            {
                                text: "加入工单", icon: FluentIcons.ChatBubbles, onClick: () => {
                                    add_group_dialog.visible = true
                                }
                            },
                            {
                                text: "创建工单", icon: FluentIcons.VideoChat, onClick: () => {
                                    create_group_dialog.visible = true
                                }
                            },
                            {
                                text: "预约工单", icon: FluentIcons.Calendar, onClick: () => {
                                    schedule_group_dialog.visible = true
                                }
                            },
                        ]

                        delegate: Item {
                            width: add_popup_column.width
                            height: 40
                            Rectangle {
                                id: add_popup_item
                                property bool hoverd: false
                                width: parent.width
                                height: parent.height
                                radius: 5
                                color: hoverd ? (FluTheme.dark ? "#11FFFFFF" : "#11000000") : "transparent"

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        add_popup.visible = false
                                        modelData.onClick()
                                    }
                                    onEntered: {
                                        add_popup_item.hoverd = true
                                    }
                                    onExited: {
                                        add_popup_item.hoverd = false
                                    }
                                }

                                FluIcon {
                                    id: add_popup_icon
                                    anchors {
                                        left: parent.left
                                        leftMargin: 10
                                        verticalCenter: parent.verticalCenter
                                    }
                                    iconSource: modelData.icon
                                    iconColor: FluTheme.primaryColor.normal
                                    iconSize: 20
                                }

                                FluText {
                                    id: add_popup_text
                                    text: modelData.text
                                    font.pixelSize: 14
                                    anchors {
                                        left: add_popup_icon.right
                                        leftMargin: 10
                                        verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }

        Item {
            id: highlight_clip
            anchors.fill: chat_list
            clip: true

            Rectangle {
                id: highlight_rectangle
                height: chat_item_height
                color: FluTheme.primaryColor.normal
                width: 4
                radius: width / 2
                anchors {
                    left: parent.left
                    leftMargin: 6
                }
                visible: store.groupList.length !== 0
                property bool enableAnimation: true

                Behavior on y {
                    enabled: highlight_rectangle.enableAnimation & FluTheme.enableAnimation
                    NumberAnimation {
                        easing.period: 0.75
                        easing.amplitude: 1
                        duration: 666
                        easing.type: Easing.OutElastic
                    }
                }

                Behavior on height {
                    enabled: highlight_rectangle.enableAnimation & FluTheme.enableAnimation
                    NumberAnimation {
                        easing.period: 0.75
                        easing.amplitude: 1
                        duration: 666
                        easing.type: Easing.OutElastic
                    }
                }
            }
        }


        ListView {
            id: chat_list
            clip: true
            anchors {
                top: layout_header.bottom
                left: parent.left
                right: parent.right
                bottom: layout_footer.top
            }
            model: chatList.items
            ScrollBar.vertical: FluScrollBar {
            }
            boundsBehavior: Flickable.DragOverBounds
            currentIndex: -1

            onCurrentIndexChanged: {
                if (chat_list.currentIndex !== -1) {
                    highlight_clip.clip = true
                    highlight_rectangle.height = chat_item_height * 0.5
                    highlight_rectangle.y = chat_list.currentItem.y - chat_list.contentY + (chat_item_height - chat_item_height * 0.5) / 2
                }
            }

            Connections {
                // 监听数据源变化
                target: chatList

                function onItemsChanged() {
                    updateList()
                }

                function updateList() {
                    for (var i = 0; i < chatList.items.length; i++) {
                        if (chatList.items[i] === chatList.currentItem) {
                            chat_list.currentIndex = i
                        }
                    }

                    // 防止列表更新时滚轮自动移动到选中项
                    chat_list.contentY = chat_list.lastContentY
                }
            }

            property var lastTopItem
            property double lastContentY: 0
            onContentYChanged: {
                var imm = (lastContentY - chat_list.contentY != 0.0) // 高亮是否关闭动画 用于滚动跟随
                if (chat_list.lastTopItem === chatList.items[0]) {
                    lastContentY = chat_list.contentY
                } else chat_list.lastTopItem = chatList.items[0]


                if (chat_list.currentIndex !== -1 && chat_list.currentItem) {
                    highlight_clip.clip = true
                    if (imm) highlight_rectangle.enableAnimation = false
                    highlight_rectangle.height = chat_item_height * 0.5
                    highlight_rectangle.y = chat_list.currentItem.y - chat_list.contentY + (chat_item_height - chat_item_height * 0.5) / 2
                    if (imm) highlight_rectangle.enableAnimation = true
                }
            }

            delegate: Loader {
                property var model: modelData
                property var _idx: index
                property int type: 0
                sourceComponent: chat_item
            }
        }

        // 顶部分割线
        Rectangle {
            color: FluTheme.dark ? Qt.rgba(80 / 255, 80 / 255, 80 / 255, 1) : Qt.rgba(210 / 255, 210 / 255, 210 / 255, 1)
            width: layout_list.width
            height: 1
            z: -1
            anchors.bottom: layout_footer.top
        }

        // 底部菜单 - 改为4行2列网格布局
        Grid {
            id: layout_footer
            width: parent.width
            columns: 2
            rowSpacing: 2
            columnSpacing: 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            height: footer_item_height * 3 + 4 // 3行按钮 + 间距

            // 空置按钮1
            Loader {
                property var model: QtObject {
                    property string title: "预留1"
                    property var icon: FluentIcons.Add
                    property var tap: function() {
                        // 空置，后续添加功能
                    }
                }
                property var _idx: 0
                property int type: 1
                sourceComponent: footer_item
                width: (layout_list.width - 6) / 2
                height: footer_item_height
                visible: false // 暂时隐藏
            }

            // 空置按钮2
            Loader {
                property var model: QtObject {
                    property string title: "预留2"
                    property var icon: FluentIcons.Add
                    property var tap: function() {
                        // 空置，后续添加功能
                    }
                }
                property var _idx: 1
                property int type: 1
                sourceComponent: footer_item
                width: (layout_list.width - 6) / 2
                height: footer_item_height
                visible: false // 暂时隐藏
            }

            // 数据库按钮
            Loader {
                property var model: QtObject {
                    property string title: "工单数据库"
                    property var icon: FluentIcons.ClipboardList
                    property var tap: function() {
                        workorder_database_dialog.visible = true
                    }
                }
                property var _idx: 2
                property int type: 1
                sourceComponent: footer_item
                width: (layout_list.width - 6) / 2
                height: footer_item_height
            }

            // 空置按钮4
            Loader {
                property var model: QtObject {
                    property string title: "预留4"
                    property var icon: FluentIcons.Add
                    property var tap: function() {
                        // 空置，后续添加功能
                    }
                }
                property var _idx: 3
                property int type: 1
                sourceComponent: footer_item
                width: (layout_list.width - 6) / 2
                height: footer_item_height
                visible: false // 暂时隐藏
            }

            // 发起预约工单按钮
            Loader {
                property var model: QtObject {
                    property string title: "发起预约工单"
                    property var icon: FluentIcons.Calendar
                    property var tap: function() {
                        schedule_group_dialog.visible = true
                    }
                }
                property var _idx: 4
                property int type: 1
                sourceComponent: footer_item
                width: (layout_list.width - 6) / 2
                height: footer_item_height
            }

            // 视频会议按钮
            Loader {
                property var model: QtObject {
                    property string title: "视频会议"
                    property var icon: FluentIcons.VideoChat
                    property var tap: function() {
                        if (footerItems && footerItems.children[0]) {
                            footerItems.children[0].tap()
                        }
                    }
                }
                property var _idx: 5
                property int type: 1
                sourceComponent: footer_item
                width: (layout_list.width - 6) / 2
                height: footer_item_height
            }

            // 设置按钮
            Loader {
                property var model: QtObject {
                    property string title: "设置"
                    property var icon: FluentIcons.Settings
                    property var tap: function() {
                        if (footerItems && footerItems.children[1]) {
                            footerItems.children[1].tap()
                        }
                    }
                }
                property var _idx: 6
                property int type: 1
                sourceComponent: footer_item
                width: (layout_list.width - 6) / 2
                height: footer_item_height
            }

            // 专家功能按钮 - 仅专家用户可见
            Loader {
                property var model: QtObject {
                    property string title: "专家功能"
                    property var icon: FluentIcons.DeveloperTools
                    property var tap: function() {
                        if (footerItems && footerItems.children[3]) {
                            footerItems.children[3].tap()
                        }
                    }
                }
                property var _idx: 7
                property int type: 1
                sourceComponent: footer_item
                width: (layout_list.width - 6) / 2
                height: footer_item_height
                visible: store.currentUser && store.currentUser.userType === "expert"
                // 添加调试信息
                Component.onCompleted: {
                    console.log("专家按钮加载完成")
                    console.log("当前用户:", store.currentUser ? store.currentUser.username : "null")
                    console.log("用户类型:", store.currentUser ? store.currentUser.userType : "null")
                }
            }

            // 关于按钮
            Loader {
                property var model: QtObject {
                    property string title: "关于"
                    property var icon: FluentIcons.Contact
                    property var tap: function() {
                        if (footerItems && footerItems.children[2]) {
                            footerItems.children[2].tap()
                        }
                    }
                }
                property var _idx: 8
                property int type: 1
                sourceComponent: footer_item
                width: (layout_list.width - 6) / 2
                height: footer_item_height
            }
        }
    }

    Popup {
        id: add_user_dialog
        modal: true
        width: 300
        height: 250
        visible: false
        opacity: 0
        anchors.centerIn: Overlay.overlay
        background: Rectangle {
            color: "transparent"
        }
        enter: Transition {
            NumberAnimation {
                property: "opacity";
                from: 0.0;
                to: 1.0
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity";
                from: 1.0;
                to: 0.0
            }
        }

        FluArea {
            anchors.fill: parent
            radius: 10

            Column {
                id: add_user_dialog_column
                spacing: 10
                anchors.centerIn: parent
                width: 200

                ChatAvatar {
                    id: add_user_avatar
                    bgColor: "#aef"
                    avatar: "🤗"
                    online: true
                    size: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                FluTextBox {
                    id: add_user_textbox
                    placeholderText: "用户名"
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }

                FluButton {
                    text: "添加好友"
                    width: parent.width
                    onClicked: {
                        if (add_user_textbox.text) {
                            store.control.requestUser(add_user_textbox.text)
                            add_user_dialog.visible = false
                        } else {
                            showError("用户名不能为空")
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: add_group_dialog
        modal: true
        width: 300
        height: 250
        visible: false
        opacity: 0
        anchors.centerIn: Overlay.overlay
        background: Rectangle {
            color: "transparent"
        }
        enter: Transition {
            NumberAnimation {
                property: "opacity";
                from: 0.0;
                to: 1.0
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity";
                from: 1.0;
                to: 0.0
            }
        }

        FluArea {
            anchors.fill: parent
            radius: 10

            Column {
                id: add_group_dialog_column
                spacing: 10
                anchors.centerIn: parent
                width: 200

                ChatAvatar {
                    id: add_group_avatar
                    bgColor: "#aef"
                    avatar: "🥳"
                    online: true
                    size: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                FluTextBox {
                    id: add_group_textbox
                    placeholderText: "群号"
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }

                FluButton {
                    text: "加入群组"
                    width: parent.width
                    onClicked: {
                        if (add_group_textbox.text && !isNaN(add_group_textbox.text)) {
                            store.control.requestGroup(add_group_textbox.text)
                            add_group_dialog.visible = false
                        } else {
                            showError("群号不对哦")
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: create_group_dialog
        modal: true
        width: 300
        height: 350
        visible: false
        opacity: 0
        anchors.centerIn: Overlay.overlay
        background: Rectangle {
            color: "transparent"
        }
        enter: Transition {
            NumberAnimation {
                property: "opacity";
                from: 0.0;
                to: 1.0
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity";
                from: 1.0;
                to: 0.0
            }
        }

        FluArea {
            anchors.fill: parent
            radius: 10

            Column {
                id: create_group_dialog_column
                spacing: 10
                anchors.centerIn: parent
                width: 200

                ChatAvatar {
                    bgColor: create_group_color.colorValue
                    avatar: create_group_avatar.text
                    online: true
                    size: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                FluTextBox {
                    id: create_group_name
                    width: parent.width
                    placeholderText: "群名"
                }

                FluTextBox {
                    id: create_group_avatar
                    width: parent.width
                    placeholderText: "头像字（可为Emoji）"
                }
                FluColorPicker {
                    id: create_group_color
                    width: parent.width

                    FluText {
                        text: "头像色"
                        color: "white"
                        anchors.centerIn: parent
                    }

                    Component.onCompleted: {
                        create_group_color.colorValue = FluTheme.primaryColor.normal
                    }
                }

                FluButton {
                    text: "创建群组"
                    width: parent.width
                    onClicked: {
                        if (create_group_name.text) {
                            store.control.createGroup(create_group_name.text, create_group_avatar.text, create_group_color.colorValue)
                            create_group_dialog.visible = false
                        } else {
                            showError("群名不能为空")
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: schedule_group_dialog
        modal: true
        width: 400
        height: 500
        visible: false
        opacity: 0
        anchors.centerIn: Overlay.overlay
        background: Rectangle {
            color: "transparent"
        }
        enter: Transition {
            NumberAnimation {
                property: "opacity";
                from: 0.0;
                to: 1.0
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity";
                from: 1.0;
                to: 0.0
            }
        }

        FluArea {
            anchors.fill: parent
            radius: 10

            Column {
                id: schedule_group_dialog_column
                spacing: 15
                anchors.centerIn: parent
                width: 300

                ChatAvatar {
                    bgColor: schedule_group_color.colorValue
                    avatar: schedule_group_avatar.text
                    online: true
                    size: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                FluTextBox {
                    id: schedule_group_name
                    width: parent.width
                    placeholderText: "工单名称"
                }

                FluTextBox {
                    id: schedule_group_avatar
                    width: parent.width
                    placeholderText: "头像字（可为Emoji）"
                }

                FluColorPicker {
                    id: schedule_group_color
                    width: parent.width

                    FluText {
                        text: "头像色"
                        color: "white"
                        anchors.centerIn: parent
                    }

                    Component.onCompleted: {
                        schedule_group_color.colorValue = FluTheme.primaryColor.normal
                    }
                }

                FluTextBox {
                    id: schedule_device_info
                    width: parent.width
                    placeholderText: "设备信息"
                }

                FluTextBox {
                    id: schedule_fault_desc
                    width: parent.width
                    placeholderText: "故障描述"
                }

                Row {
                    width: parent.width
                    spacing: 10

                    FluText {
                        text: "紧急程度："
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    FluComboBox {
                        id: schedule_urgency
                        width: 120
                        model: ["低", "中", "高"]
                        currentIndex: 1
                    }
                }

                Row {
                    width: parent.width
                    spacing: 10

                    FluText {
                        text: "预约时间："
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    FluDatePicker {
                        id: schedule_date
                        width: 120
                        current: new Date()
                    }

                    FluTimePicker {
                        id: schedule_time
                        width: 120
                        current: new Date()
                    }
                }

                FluButton {
                    text: "预约工单"
                    width: parent.width
                    onClicked: {
                        if (schedule_group_name.text && schedule_device_info.text && schedule_fault_desc.text) {
                            // 计算延迟时间（10分钟）
                            var delayMinutes = 10

                            // 获取选中的日期和时间
                            var scheduleDate = schedule_date.current
                            var scheduleTime = schedule_time.current

                            // 合并日期和时间
                            var scheduleDateTime = new Date(scheduleDate)
                            scheduleDateTime.setHours(scheduleTime.getHours(), scheduleTime.getMinutes(), 0, 0)

                            // 创建预约信息
                            var scheduleInfo = {
                                name: schedule_group_name.text,
                                avatar: schedule_group_avatar.text,
                                color: schedule_group_color.colorValue,
                                deviceInfo: schedule_device_info.text,
                                faultDesc: schedule_fault_desc.text,
                                urgency: schedule_urgency.currentText,
                                scheduleTime: scheduleDateTime.toISOString()
                            }

                            // 调用预约功能
                            store.control.scheduleGroup(scheduleInfo, delayMinutes)
                            schedule_group_dialog.visible = false
                            showSuccess("预约成功，将在审核通过后的预定时间创建工单")
                        } else {
                            showError("请填写完整信息")
                        }
                    }
                }
            }
        }
    }

    // 工单数据库对话框
    Popup {
        id: workorder_database_dialog
        modal: true
        width: 800
        height: 600
        visible: false
        opacity: 0
        anchors.centerIn: Overlay.overlay
        background: Rectangle {
            color: "transparent"
        }
        enter: Transition {
            NumberAnimation {
                property: "opacity";
                from: 0.0;
                to: 1.0
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity";
                from: 1.0;
                to: 0.0
            }
        }

        FluArea {
            anchors.fill: parent
            radius: 10

            Column {
                spacing: 15
                anchors.fill: parent
                anchors.margins: 20

                // 标题
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    
                    FluIcon {
                        iconSource: FluentIcons.ClipboardList
                        iconSize: 32
                        iconColor: FluTheme.primaryColor.normal
                    }
                    
                    FluText {
                        text: "工单数据库"
                        font: FluTextStyle.TitleLarge
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // 搜索筛选区域
                Row {
                    width: parent.width
                    spacing: 10

                    FluTextBox {
                        id: search_text
                        width: 200
                        placeholderText: "搜索工单编号或设备名称"
                        onTextChanged: {
                            filterWorkorders()
                        }
                    }

                    FluComboBox {
                        id: status_filter
                        width: 100
                        model: ["全部状态", "待处理", "处理中", "已完成", "已关闭"]
                        currentIndex: 0
                        onCurrentIndexChanged: {
                            filterWorkorders()
                        }
                    }

                    FluComboBox {
                        id: urgency_filter
                        width: 100
                        model: ["全部级别", "低", "中", "高"]
                        currentIndex: 0
                        onCurrentIndexChanged: {
                            filterWorkorders()
                        }
                    }

                    FluDatePicker {
                        id: date_filter
                        width: 150
                        onCurrentChanged: {
                            filterWorkorders()
                        }
                    }

                    FluButton {
                        text: "重置筛选"
                        onClicked: {
                            search_text.text = ""
                            status_filter.currentIndex = 0
                            urgency_filter.currentIndex = 0
                            date_filter.current = null
                            filterWorkorders()
                        }
                    }
                }

                // 工单列表 - 使用更简单的滚动方案
                FluArea {
                    width: parent.width
                    height: parent.height - 160
                    radius: 8

                    // 表格容器 - 支持滚动
                    ScrollView {
                        id: table_scroll_view
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        // 水平滚动条
                        ScrollBar.horizontal: FluScrollBar {
                            policy: ScrollBar.AsNeeded
                            visible: table_container.width > table_scroll_view.width
                        }
                        
                        // 垂直滚动条
                        ScrollBar.vertical: FluScrollBar {
                            policy: ScrollBar.AsNeeded
                            visible: table_container.height > table_scroll_view.height
                        }

                        // 表格内容
                        Item {
                            id: table_container
                            width: 750 // 缩短宽度，适应对话框宽度
                            height: 40 + workorder_list.count * 60 // 动态高度

                            // 表格头部
                            Row {
                                id: table_header
                                width: parent.width
                                height: 40
                                spacing: 15

                                // 工单编号
                                FluText {
                                    width: 90
                                    text: "工单编号"
                                    font: FluTextStyle.BodyStrong
                                    color: FluColors.Grey120
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // 设备信息
                                FluText {
                                    width: 130
                                    text: "设备信息"
                                    font: FluTextStyle.BodyStrong
                                    color: FluColors.Grey120
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // 故障描述
                                FluText {
                                    width: 180
                                    text: "故障描述"
                                    font: FluTextStyle.BodyStrong
                                    color: FluColors.Grey120
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // 状态
                                FluText {
                                    width: 70
                                    text: "状态"
                                    font: FluTextStyle.BodyStrong
                                    color: FluColors.Grey120
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // 紧急程度
                                FluText {
                                    width: 70
                                    text: "紧急程度"
                                    font: FluTextStyle.BodyStrong
                                    color: FluColors.Grey120
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // 创建时间
                                FluText {
                                    width: 100
                                    text: "创建时间"
                                    font: FluTextStyle.BodyStrong
                                    color: FluColors.Grey120
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // 解决时间
                                FluText {
                                    width: 110
                                    text: "解决时间"
                                    font: FluTextStyle.BodyStrong
                                    color: FluColors.Grey120
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            // 表格数据行
                            ListView {
                                id: workorder_list
                                width: parent.width
                                height: Math.max(300, count * 60) // 设置最小高度，确保需要滚动
                                anchors.top: table_header.bottom
                                model: ListModel {
                                    id: workorder_model
                                }

                                delegate: Item {
                                    width: workorder_list.width
                                    height: 60

                                    Row {
                                        width: parent.width
                                        height: parent.height
                                        spacing: 15

                                        // 工单编号
                                        FluText {
                                            width: 90
                                            text: model.workorderId
                                            font: FluTextStyle.Body
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }

                                        // 设备信息
                                        FluText {
                                            width: 130
                                            text: model.deviceInfo
                                            font: FluTextStyle.Body
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }

                                        // 故障描述
                                        FluText {
                                            width: 180
                                            text: model.faultDesc
                                            font: FluTextStyle.Body
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }

                                        // 状态
                                        FluText {
                                            width: 70
                                            text: model.status
                                            font: FluTextStyle.Body
                                            color: getStatusColor(model.status)
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        // 紧急程度
                                        FluText {
                                            width: 70
                                            text: model.urgency
                                            font: FluTextStyle.Body
                                            color: getUrgencyColor(model.urgency)
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        // 创建时间
                                        FluText {
                                            width: 100
                                            text: model.createTime
                                            font: FluTextStyle.Body
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        // 解决时间
                                        FluText {
                                            width: 110
                                            text: model.resolveTime || "未解决"
                                            font: FluTextStyle.Body
                                            color: model.resolveTime ? FluColors.Grey120 : FluColors.Red
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    // 分割线
                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: FluTheme.dark ? Qt.rgba(80/255, 80/255, 80/255, 1) : Qt.rgba(210/255, 210/255, 210/255, 1)
                                        anchors.bottom: parent.bottom
                                    }
                                }
                            }
                        }
                    }
                }

                // 统计信息
                Row {
                    width: parent.width
                    spacing: 15

                    FluText {
                        text: "总工单数: " + workorder_model.count
                        font: FluTextStyle.Body
                    }

                    FluText {
                        text: "待处理: " + getStatusCount("待处理")
                        font: FluTextStyle.Body
                        color: FluColors.Orange
                    }

                    FluText {
                        text: "处理中: " + getStatusCount("处理中")
                        font: FluTextStyle.Body
                        color: FluColors.Blue
                    }

                    FluText {
                        text: "已完成: " + getStatusCount("已完成")
                        font: FluTextStyle.Body
                        color: FluColors.Green
                    }
                }

                // 关闭按钮
                FluButton {
                    text: "关闭"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        workorder_database_dialog.visible = false
                    }
                }
            }
        }
    }

    // 模拟工单数据
    ListModel {
        id: original_workorder_data
        ListElement {
            workorderId: "WO-2024-001"
            deviceInfo: "生产线A-注塑机"
            faultDesc: "温度传感器异常，显示温度不准确"
            status: "已完成"
            urgency: "高"
            createTime: "2024-01-15 08:30"
            resolveTime: "2024-01-15 14:20"
        }
        ListElement {
            workorderId: "WO-2024-002"
            deviceInfo: "生产线B-包装机"
            faultDesc: "传送带卡顿，需要润滑"
            status: "处理中"
            urgency: "中"
            createTime: "2024-01-16 09:15"
            resolveTime: ""
        }
        ListElement {
            workorderId: "WO-2024-003"
            deviceInfo: "生产线C-检测设备"
            faultDesc: "检测精度偏差，需要校准"
            status: "待处理"
            urgency: "低"
            createTime: "2024-01-17 10:45"
            resolveTime: ""
        }
        ListElement {
            workorderId: "WO-2024-004"
            deviceInfo: "生产线A-冷却系统"
            faultDesc: "冷却水循环泵故障"
            status: "已完成"
            urgency: "高"
            createTime: "2024-01-18 11:20"
            resolveTime: "2024-01-18 16:30"
        }
        ListElement {
            workorderId: "WO-2024-005"
            deviceInfo: "生产线B-切割机"
            faultDesc: "切割精度不达标"
            status: "已关闭"
            urgency: "中"
            createTime: "2024-01-19 13:10"
            resolveTime: "2024-01-19 17:45"
        }
        ListElement {
            workorderId: "WO-2024-006"
            deviceInfo: "生产线C-加热炉"
            faultDesc: "加热温度不稳定"
            status: "待处理"
            urgency: "高"
            createTime: "2024-01-20 08:00"
            resolveTime: ""
        }
        ListElement {
            workorderId: "WO-2024-007"
            deviceInfo: "生产线A-机械臂"
            faultDesc: "动作不流畅，需要检修"
            status: "处理中"
            urgency: "中"
            createTime: "2024-01-21 14:30"
            resolveTime: ""
        }
        ListElement {
            workorderId: "WO-2024-008"
            deviceInfo: "生产线B-控制系统"
            faultDesc: "PLC程序异常，需要重启"
            status: "已完成"
            urgency: "高"
            createTime: "2024-01-22 16:20"
            resolveTime: "2024-01-22 18:10"
        }
    }

    // 筛选工单函数
    function filterWorkorders() {
        workorder_model.clear()
        
        for (var i = 0; i < original_workorder_data.count; i++) {
            var item = original_workorder_data.get(i)
            var shouldInclude = true
            
            // 文本搜索
            if (search_text.text) {
                var searchLower = search_text.text.toLowerCase()
                if (!item.workorderId.toLowerCase().includes(searchLower) && 
                    !item.deviceInfo.toLowerCase().includes(searchLower)) {
                    shouldInclude = false
                }
            }
            
            // 状态筛选
            if (status_filter.currentIndex > 0) {
                var statusText = status_filter.currentText
                if (item.status !== statusText) {
                    shouldInclude = false
                }
            }
            
            // 紧急程度筛选
            if (urgency_filter.currentIndex > 0) {
                var urgencyText = urgency_filter.currentText
                if (item.urgency !== urgencyText) {
                    shouldInclude = false
                }
            }
            
            // 日期筛选
            if (date_filter.current) {
                var filterDate = date_filter.current.toDateString()
                var itemDate = new Date(item.createTime).toDateString()
                if (filterDate !== itemDate) {
                    shouldInclude = false
                }
            }
            
            if (shouldInclude) {
                workorder_model.append(item)
            }
        }
    }

    // 获取状态颜色
    function getStatusColor(status) {
        switch (status) {
            case "待处理": return FluColors.Orange
            case "处理中": return FluColors.Blue
            case "已完成": return FluColors.Green
            case "已关闭": return FluColors.Grey120
            default: return FluColors.Grey120
        }
    }

    // 获取紧急程度颜色
    function getUrgencyColor(urgency) {
        switch (urgency) {
            case "高": return FluColors.Red
            case "中": return FluColors.Orange
            case "低": return FluColors.Green
            default: return FluColors.Grey120
        }
    }

    // 获取状态统计
    function getStatusCount(status) {
        var count = 0
        for (var i = 0; i < workorder_model.count; i++) {
            if (workorder_model.get(i).status === status) {
                count++
            }
        }
        return count
    }

    // 初始化工单数据
    Component.onCompleted: {
        filterWorkorders()
    }

}
