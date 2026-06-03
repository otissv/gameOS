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
        font.pixelSize: vpx(16)
        font.family: subtitleFont.name
        font.bold: true
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
                fullColor: theme.text
                emptyColor: Qt.rgba(1, 1, 1, 0.35)
                starFontFamily: subtitleFont.name
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

        // Genre box
        Text {
            id: genretitle

            width: contentWidth
            height: parent.height
            anchors {
                left: agetext.right
                leftMargin: root.dividerSpacing
                top: parent.top; topMargin: vpx(10)
                bottom: parent.bottom; bottomMargin: vpx(10)
            }
            verticalAlignment: Text.AlignVCenter
            text: "Genre: "
            font.pixelSize: vpx(16)
            font.family: subtitleFont.name
            font.bold: true
            color: theme.text
            visible: root.showGenre && root.hasGenre
        }

        Text {
            id: genretext

            anchors {
                left: genretitle.right
                leftMargin: vpx(5)
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }

            verticalAlignment: Text.AlignVCenter
            text: root.gameData ? Utils.formatGenres(root.gameData) : ""
            font.pixelSize: vpx(16)
            font.family: subtitleFont.name
            elide: Text.ElideRight
            color: theme.text
            visible: root.showGenre && root.hasGenre
        }

        
    }

   
}
