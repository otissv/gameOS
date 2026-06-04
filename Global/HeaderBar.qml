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

import QtQuick 2.12
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.12
import QtQml.Models 2.1
import "../utils.js" as Utils

FocusScope {
id: root

    property bool searchActive
    property string titleText: ""

    onFocusChanged: buttonbar.currentIndex = 0;

    function toggleSearch() {
        searchActive = !searchActive;
    }

    Rectangle {
    id: headerContainer

        anchors {
            top:    parent.top
            left:   parent.left
            right:  parent.right
        }
        height: vpx(70)
        color: "transparent"

       
    

        LinearGradient {
            id: headerScrim

            anchors.fill: parent
            z: 0
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: '#110e11' }
                GradientStop { position: 1.0; color: "#00242629" }
            }
        }  

        Item {
        id: headerContent

            anchors.fill: parent
            z: 1

            // Platform title
            Text {
            id: softwareplatformtitle
                
                text: titleText !== "" ? titleText : currentCollection.name
                
                anchors {
                    top:    parent.top;
                    left:   parent.left;    leftMargin: globalMargin
                    right:  parent.right
                    bottom: parent.bottom
                }
                
                color: theme.text
                font.family: fonts.title.family.name
                font.pixelSize: fonts.title.pixelSize
                font.bold: fonts.title.bold
                horizontalAlignment: Text.AlignHLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                visible: titleText !== "" || platformlogo.status == Image.Error

                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: previousScreen();
                }
            }

            ObjectModel {
            id: headermodel



                // Search bar
                Item {
                id: searchbar
                    
                    property bool selected: ListView.isCurrentItem && root.focus
                    property bool mouseHovered: false
                    property bool highlighted: selected || mouseHovered
                    onSelectedChanged: if (!selected && searchActive) toggleSearch();

                    width: (searchActive || searchTerm != "") ? vpx(250) : height
                    height: vpx(40)

                    Behavior on width {
                        PropertyAnimation { duration: 200; easing.type: Easing.OutQuart; easing.amplitude: 2.0; easing.period: 1.5 }
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: parent.height
                        color: searchbar.highlighted && !searchActive ? theme.accent : "white"
                        radius: height/2
                        opacity: searchbar.highlighted && !searchActive ? 1 : searchActive ? 0.4 : 0.2

                    }

                    Image {
                    id: searchicon

                        width: height
                        height: vpx(18)
                        anchors { 
                            left: parent.left; leftMargin: vpx(11)
                            top: parent.top; topMargin: vpx(10)
                        }
                        source: "../assets/images/searchicon.svg"
                        opacity: searchbar.highlighted && !searchActive ? 1 : searchActive ? 0.8 : 0.5
                        asynchronous: true
                    }

                    TextInput {
                    id: searchInput
                        
                        anchors { 
                            left: searchicon.right; leftMargin: vpx(10)
                            top: parent.top; bottom: parent.bottom
                            right: parent.right; rightMargin: vpx(15)
                        }
                        verticalAlignment: Text.AlignVCenter
                        color: theme.text
                        focus: searchbar.selected && searchActive
                        font.family: fonts.subtitle.family.name
                        font.pixelSize: fonts.subtitle.pixelSize
                        clip: true
                        text: searchTerm
                        onTextEdited: {
                            searchTerm = searchInput.text
                        }
                    }

                    // Mouse/touch functionality
                    MouseArea {
                        anchors.fill: parent
                        enabled: !searchActive
                        hoverEnabled: true
                        onEntered: searchbar.mouseHovered = true
                        onExited: searchbar.mouseHovered = false
                        onClicked: {
                            if (!searchActive)
                            {
                                toggleSearch();
                                searchInput.selectAll();
                            }
                        }
                    }

                    Keys.onPressed: {
                        // Accept
                        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                            event.accepted = true;
                            if (!searchActive) {
                                toggleSearch();
                                searchInput.selectAll();
                            } else {
                                searchInput.selectAll();
                            }
                        }
                    }
                }

                // Ascending/descending
                Item {
                id: directionbutton

                    property bool selected: ListView.isCurrentItem && root.focus
                    property bool mouseHovered: false
                    property bool highlighted: selected || mouseHovered
                    width: directiontitle.contentWidth + vpx(30)
                    height: searchbar.height

                    Rectangle
                    { 
                        anchors.fill: parent
                        radius: height/2
                        color: theme.accent
                        visible: directionbutton.highlighted
                    }

                    Text {
                    id: directiontitle
                        
                        text: (orderBy === Qt.AscendingOrder) ? "Ascending" : "Descending"
                                        
                        color: theme.text
                        font.family: fonts.subtitle.family.name
                        font.pixelSize: fonts.subtitle.pixelSize
                        anchors.centerIn: parent
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: directionbutton.mouseHovered = true
                        onExited: directionbutton.mouseHovered = false
                        onClicked: toggleOrderBy();
                    }

                    Keys.onPressed: {
                        // Accept
                        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                            event.accepted = true;
                            toggleOrderBy();
                        }
                    }
                }

                // Order by title
                Item {
                id: titlebutton

                    property bool selected: ListView.isCurrentItem && root.focus
                    property bool mouseHovered: false
                    property bool highlighted: selected || mouseHovered
                    width: ordertitle.contentWidth + vpx(30)
                    height: searchbar.height

                    Rectangle
                    { 
                        anchors.fill: parent
                        radius: height/2
                        color: theme.accent
                        visible: titlebutton.highlighted
                    }

                    Text {
                    id: ordertitle
                        
                        text: "By " + sortByDisplay[sortByIndex]
                                        
                        color: theme.text
                        font.family: fonts.subtitle.family.name
                        font.pixelSize: fonts.subtitle.pixelSize
                        anchors.centerIn: parent
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: titlebutton.mouseHovered = true
                        onExited: titlebutton.mouseHovered = false
                        onClicked: cycleSort();
                    }

                    Keys.onPressed: {
                        // Accept
                        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                            event.accepted = true;
                            cycleSort();
                        }
                    }
                }
                
                // Filters menu
                Item {
                id: filterbutton

                    property bool selected: ListView.isCurrentItem && root.focus
                    property bool mouseHovered: false
                    property bool highlighted: selected || mouseHovered
                    width: filtertitle.contentWidth + vpx(30)
                    height: searchbar.height

                    Rectangle
                    { 
                        anchors.fill: parent
                        radius: height/2
                        color: theme.accent
                        visible: filterbutton.highlighted
                    }
                    
                    // Filter title
                    Text {
                    id: filtertitle
                        
                        text: (showFavs) ? "Favorites" : "All games"
                                        
                        color: theme.text
                        font.family: fonts.subtitle.family.name
                        font.pixelSize: fonts.subtitle.pixelSize
                        anchors.centerIn: parent
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: filterbutton.mouseHovered = true
                        onExited: filterbutton.mouseHovered = false
                        onClicked: toggleFavs();
                    }

                    Keys.onPressed: {
                        // Accept
                        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                            event.accepted = true;
                            toggleFavs();
                        }
                    }
                }
            }

            // Buttons
            ListView {
            id: buttonbar

                focus: true
                model: headermodel
                spacing: vpx(10)
                orientation: ListView.Horizontal
                layoutDirection: Qt.RightToLeft
                anchors {
                    right: parent.right; rightMargin: globalMargin
                    left: parent.left; top: parent.top; topMargin: vpx(15)
                }
                
            }
            
        }
    
    }

}
