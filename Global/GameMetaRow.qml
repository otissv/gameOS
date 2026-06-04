import QtQuick 2.8
import "../utils.js" as Utils

Item {
id: root

    property var gameData: currentGame
    property bool showGenre: true
    property bool showTitle: false
    property real dividerSpacing: vpx(25)
    readonly property real ratingPercent: gameData ? gameData.rating * 100 : 0
    readonly property bool hasGenre: gameData && Utils.formatGenres(gameData).length > 0
    readonly property real contentWidth: showGenre && hasGenre
        ? genretext.x + genretext.implicitWidth
        : playersCount.x + playersCount.width

    implicitWidth: contentWidth
    implicitHeight: vpx(50)
    height: implicitHeight


    Text {
    id: titletext
    
        anchors {
            left: parent.left; 
            bottom: gameMetaInfo.top
            bottomMargin: vpx(25)

        }

        text: root.gameData ? root.gameData.title : ""
        font.pixelSize: fonts.subtitle.pixelSize
        font.family: fonts.subtitle.family.name
        font.bold: fonts.subtitle.bold
        color: theme.text
        visible: root.showTitle
    }

    Rectangle {
    id: gameMetaInfo 

        anchors {
            // top: titletext.top; 
            left: parent.left; 
            verticalCenter: parent.verticalCenter
        }
        width: vpx(2)
        color: "transparent"


         // Rating box
        Item {
            id: ratingtext

            width: ratingStars.width
            height: parent.height
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

            StarRating {
                id: ratingStars
                anchors.verticalCenter: parent.verticalCenter
                ratingPercent: root.ratingPercent
                starCount: 5
                starSize: vpx(16)
                starSpacing: vpx(2)
                fullColor: "orange"
                emptyColor: Qt.rgba(1, 1, 1, 0.35)
                starFontFamily: fonts.subtitle.family.name
            }
        }

        // Players box
        PlayerCount {
            id: playersCount

            gameData: root.gameData
            anchors {
                left: ratingtext.right; 
                leftMargin: root.dividerSpacing
                verticalCenter: parent.verticalCenter
            }
        }

        // Age box
        AgeRatingBadge {
            id: agetext

            gameData: root.gameData
            anchors {
                left: playersCount.right;
                leftMargin: root.dividerSpacing
                verticalCenter: parent.verticalCenter
            }
        } 

        Text {
            id: genretext

            anchors {
                left: agetext.right
                leftMargin: root.dividerSpacing
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }

            verticalAlignment: Text.AlignVCenter
            text: root.gameData ? Utils.formatGenres(root.gameData) : ""
            font.pixelSize: fonts.body.pixelSize
            font.family: fonts.body.family.name
            elide: Text.ElideRight
            color: theme.text
            visible: root.showGenre && root.hasGenre
        }

        
    }

   
}
