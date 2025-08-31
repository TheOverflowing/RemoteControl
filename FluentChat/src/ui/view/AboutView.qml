import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia
import FluentUI
import "qrc:/FluentChat/ui/component/"


FluPage {

    Column {
        anchors.centerIn: parent
        spacing: 20
        
        // 工业主题图标
        Rectangle {
            width: 120
            height: 120
            radius: 60
            gradient: Gradient {
                GradientStop { position: 0.0; color: FluTheme.primaryColor.lightest }
                GradientStop { position: 1.0; color: FluTheme.primaryColor.normal }
            }
            anchors.horizontalCenter: parent.horizontalCenter
            
            FluText {
                text: "🏭"
                font.pixelSize: 60
                anchors.centerIn: parent
            }
        }
        
        FluText {
            text: "工业现场远程专家支持系统"
            font.pixelSize: 28
            font.bold: true
            color: FluTheme.primaryColor.normal
        }
        
        FluText {
            text: "Industrial Remote Expert Support System"
            font.pixelSize: 16
            color: FluTheme.dark ? FluColors.Grey120 : FluColors.Grey80
        }
        
        Rectangle {
            width: 100
            height: 2
            color: FluTheme.primaryColor.normal
            opacity: 0.3
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        FluText {
            text: "版本 1.0.0"
            font.pixelSize: 14
            color: FluTheme.dark ? FluColors.Grey120 : FluColors.Grey80
        }

        // FluText {
        //     text: "<a href='http://bit101.cn'>点我</a>"
        //     textFormat: Text.RichText
        //     onLinkActivated: {
        //         Qt.openUrlExternally("http://bit101.cn")
        //     }
        // }
    }
}
