import QtQuick 2.8
import "../utils.js" as Utils



Rectangle {
id: root

    property var gameData

    property string ageRatingText: Utils.ageRatingText(gameData)

    function ageCategoryByAgeRatingText() {
        return Utils.ageCategory(ageRatingText);
    }

    function colorByAgeRating(rating) {
        return Utils.ageRatingColor(rating);
    }

    visible: ageRatingText !== ""
    z: 1
    color: colorByAgeRating(ageRatingText)
    width: vpx(50)
    height: vpx(25)
    radius: vpx(10)
    opacity: 0.5

    Text {
        text: parent.ageCategoryByAgeRatingText()
        anchors.fill: parent
        anchors.margins: vpx(1)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "white"
        font.pixelSize: vpx(16)
        font.family: subtitleFont.name
    }
}
