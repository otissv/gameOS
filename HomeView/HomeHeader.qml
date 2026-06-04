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

import QtQuick 2.3

Item {
id: root

    property bool kidsOnly: false
    property bool ftueVisible: false
    property bool anyButtonActiveFocus: kidsbutton.activeFocus || homebutton.activeFocus

    signal kidsRequested
    signal homeRequested
    signal mainListFocusRequested
    signal mainListIndexRequested(int index)

    function focusNavigationButton() {
        if (kidsOnly)
            homebutton.forceActiveFocus();
        else
            kidsbutton.forceActiveFocus();
    }

    width: parent.width
    height: vpx(70)
    z: 10

    Rectangle {
        id: navigationButtonContainer

            anchors {
                top: parent.top
                topMargin: vpx(10)
                right: parent.right
                rightMargin: globalMargin

            }
            width: vpx(80)
            height: vpx(40)
            color: "transparent"
       
       Rectangle {
        id: kidsbutton

            visible: !root.kidsOnly
            width: vpx(80)
            height: vpx(40)
            anchors.fill: parent
            color: focus ? theme.accent : "transparent"
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            onFocusChanged: {
                sfxNav.play()
                root.mainListIndexRequested(focus ? -1 : 0)
            }

            Text {
                anchors.centerIn: parent
                text: "Maxx"
                color: focus ? theme.accent : theme.text
                font.family: fonts.subtitle.family.name
                font.pixelSize: fonts.subtitle.pixelSize
                font.bold: fonts.subtitle.bold
            }

            Keys.onDownPressed: root.mainListFocusRequested()
            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true
                    root.kidsRequested()
                }
                if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                    event.accepted = true
                    root.mainListFocusRequested()
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: settings.MouseHover == "Yes"
                onEntered: kidsbutton.forceActiveFocus()
                onExited: kidsbutton.focus = false
                onClicked: root.kidsRequested()
            }
        }

        Rectangle {
        id: homebutton

            visible: root.kidsOnly
            anchors.fill: parent
            color: focus ? theme.accent : "transparent"
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            onFocusChanged: {
                sfxNav.play()
                root.mainListIndexRequested(focus ? -1 : 0)
            }

            Text {
                anchors.centerIn: parent
                text: "Maxx Kids"
                color: focus ? theme.accent : theme.text
                font.family: fonts.subtitle.family.name
                font.pixelSize: fonts.subtitle.pixelSize
                font.bold: fonts.subtitle.bold
            }

            Keys.onDownPressed: root.mainListFocusRequested()
            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true
                    root.homeRequested()
                }
                if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                    event.accepted = true
                    root.mainListFocusRequested()
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: settings.MouseHover == "Yes"
                onEntered: homebutton.forceActiveFocus()
                onExited: homebutton.focus = false
                onClicked: root.homeRequested()
            }
        }
    }

    
}
