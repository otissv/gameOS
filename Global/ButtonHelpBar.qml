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

Item {
id: root


    property var layout1: {
        return {
            "accept": api.keys.accept,
            "cancel": api.keys.cancel,
            "details": api.keys.details,
            "filters": api.keys.filters,
            "nextPage": api.keys.nextPage,
            "pageDown": api.keys.pageDown,
            "pageUp": api.keys.pageUp,
            "prevPage": api.keys.prevPage,
        }
    }
    property var layout2: {
        return {
            "accept": api.keys.cancel,
            "cancel": api.keys.accept,
            "details": api.keys.filters,
            "filters": api.keys.details,
            "nextPage": api.keys.nextPage,
            "pageDown": api.keys.pageDown,
            "pageUp": api.keys.pageUp,
            "prevPage": api.keys.prevPage,
        }
    }

    property var layout: settings.ControlLayout === "Layout 1" ? layout1 : layout2;

    Component {
        id: buttonhelpDelegate
        Row {
            spacing: 10
            Image {
                source: "../assets/images/controller/" + processButtonArt(button) + ".png"
                width: vpx(30)
                height: vpx(30)
                asynchronous: true
            }
            Text { 
                text: name
                font.family: fonts.subtitle.family.name
                font.pixelSize: fonts.subtitle.pixelSize
                color: theme.text
                height: parent.height
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: currentHelpbarModel
        delegate: buttonhelpDelegate
        orientation: ListView.Horizontal
        layoutDirection: Qt.RightToLeft
        spacing: vpx(20)
    }

    visible: currentHelpbarModel ? true : false

    // Processes the button and will display the correct art based on the button mappings set in Pegasus
    // Necessary as we can't use script in the ListModel
    function processButtonArt(button) {
        var buttonModel;
        switch (button) {
            case "accept":
            buttonModel = layout.accept;
            break;
            case "cancel":
            buttonModel = layout.cancel;
            break;
            case "filters":
            buttonModel = layout.filters;
            break;
            case "details":
            buttonModel = layout.details;
            break;
            case "nextPage":
            buttonModel = layout.nextPage;
            break;
            case "prevPage":
            buttonModel = layout.prevPage;
            break;
            case "pageUp":
            buttonModel = layout.pageUp;
            break;
            case "pageDown":
                buttonModel = layout.pageDown;
                break;
            default:
            buttonModel = layout.accept;
        }

        var i;
        for (i = 0; buttonModel.length; i++) {
            if (buttonModel[i].name().includes("Gamepad")) {
            var buttonValue = buttonModel[i].key.toString(16)
            return buttonValue.substring(buttonValue.length-1, buttonValue.length);
            }
        }
    }
    
}
