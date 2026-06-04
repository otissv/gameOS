// gameOS theme
// Copyright (C) 2026 Otis Virginie
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.8
import "../utils.js" as Utils



Rectangle {
id: root

    property var gameData
    property bool showBadge: true

    property string ageRatingText: Utils.ageRatingText(gameData)

   
    function ageCategoryByAgeRatingText() {
       let rating = Utils.ageCategory(ageRatingText);

       if (rating === "18+") {
        return "18";
       } else if (rating === "16+") {
        return "16";
       } else if (rating === "Kids") {
        return "PG";
       } else {
        return "";
       }
    }

    function colorByAgeRating(rating) {
        return Utils.ageRatingColor(rating);
    }

    visible: showBadge && ageRatingText !== ""
    z: 1
    color: colorByAgeRating(ageRatingText)
    width: vpx(30)
    height: vpx(30)
    radius: vpx(30)
    border.width: vpx(1)
    border.color: "white"
    // opacity: 0.5



    Text {
        text: parent.ageCategoryByAgeRatingText()
        anchors.fill: parent
        anchors.margins: vpx(1)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: theme.text
        font.pixelSize: fonts.body.pixelSize
        font.family: font.body.title.name
    }
}
