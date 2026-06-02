import QtQuick 2.0

Item {
id: root

    property real ratingPercent: 0
    property int starCount: 5
    property real starSize: 16
    property real starSpacing: 3
    property color fullColor: "#FFD700"
    property color emptyColor: "#6A6A6A"
    property string starFontFamily: ""

    readonly property real clampedPercent: Math.max(0, Math.min(100, ratingPercent))
    readonly property real roundedStarValue: Math.round((clampedPercent / 100 * starCount) * 2) / 2

    width: starsRow.implicitWidth
    height: starsRow.implicitHeight

    Row {
    id: starsRow

        spacing: root.starSpacing

        Repeater {
            model: root.starCount

            delegate: Item {
                width: root.starSize
                height: root.starSize

                readonly property real starIndex: index + 1
                readonly property string starType: {
                    if (root.roundedStarValue >= starIndex)
                        return "full";
                    if (root.roundedStarValue >= starIndex - 0.5)
                        return "half";
                    return "empty";
                }

                Loader {
                    anchors.fill: parent
                    sourceComponent: starType === "full"
                        ? fullStarComponent
                        : (starType === "half" ? halfStarComponent : emptyStarComponent)
                }
            }
        }
    }

    Component {
    id: emptyStarComponent

        Text {
            anchors.centerIn: parent
            text: "\u2606"
            color: root.emptyColor
            font.pixelSize: root.starSize
            font.family: root.starFontFamily
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Component {
    id: fullStarComponent

        Text {
            anchors.centerIn: parent
            text: "\u2605"
            color: root.fullColor
            font.pixelSize: root.starSize
            font.family: root.starFontFamily
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Component {
    id: halfStarComponent

        Item {
            anchors.fill: parent

            Text {
                anchors.centerIn: parent
                text: "\u2606"
                color: root.emptyColor
                font.pixelSize: root.starSize
                font.family: root.starFontFamily
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width / 2
                clip: true

                Item {
                    width: parent.parent.width
                    height: parent.parent.height

                    Text {
                        anchors.centerIn: parent
                        text: "\u2605"
                        color: root.fullColor
                        font.pixelSize: root.starSize
                        font.family: root.starFontFamily
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
