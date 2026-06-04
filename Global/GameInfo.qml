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

import QtQuick 2.0
import QtQuick.Layouts 1.11
import "qrc:/qmlutils" as PegasusUtils
import "../utils.js" as Utils

Item {
id: infocontainer

    property var gameData: currentGame
    property bool showTitle: true
    property bool showDescription: true
    property bool showGenre: true

    // Game title
    Text {
    id: gametitle

        visible: infocontainer.showTitle
        
        text: gameData ? gameData.title : ""
        
        anchors {
            top:    parent.top;
            left:   parent.left;
            right:  parent.right
        }
        
        color: theme.text
        font.family: fonts.title.family.name
        font.pixelSize: fonts.title.pixelSize
        font.bold: fonts.title.bold
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // Meta data
    GameMetaRow {
    id: metarow

        gameData: infocontainer.gameData
        showGenre: infocontainer.showGenre
        anchors {
            top: infocontainer.showTitle ? gametitle.bottom : parent.top
            left: parent.left
            right: parent.right
        }
    }

    // Description
    PegasusUtils.AutoScroll
    {
    id: gameDescription

        visible: infocontainer.showDescription
    
        anchors {
            left: parent.left; 
            right: parent.right;
            top: metarow.bottom
            bottom: parent.bottom;
        }

        Text {
            width: parent.width
            text: gameData && (gameData.summary || gameData.description) ? gameData.description || gameData.summary : "No description available"
            font.pixelSize: fonts.body.pixelSize
            font.family: fonts.body.family.name
            color: theme.text
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
        }
    }
    
}
