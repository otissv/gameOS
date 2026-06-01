// gameOS theme
// Copyright (C) 2026 Otis Virginie
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

import QtQuick 2.3
import "../Global"
import "../Lists"
import "../utils.js" as Utils

FocusScope {
id: root

    function currentList() {
        return genreList.currentIndex === 0 ? listAll : listGenre;
    }

    function gameActivated() {
        gameDetails(currentList().currentGame(gamegrid.currentIndex));
    }

    property int storedGenreIndex: 0
    property int storedGenreGameIndex: 0
    property int numColumns: settings.GridColumns ? settings.GridColumns : 6
    property int titleMargin: settings.AlwaysShowTitles === "Yes" ? vpx(30) : 0
    property real genreItemHeight: vpx(50)
    property var genreNames: ["All Games"].concat(Utils.uniqueGameValues('genreList', isKidsView))

    ListAllGames {
        id: listAll
        max: api.allGames.count
        kidsOnly: isKidsView
    }

    ListGenre {
        id: listGenre
        max: api.allGames.count
        genre: genreList.currentIndex > 0 ? genreNames[genreList.currentIndex] : ""
        kidsOnly: isKidsView
    }

    Rectangle {
    id: header

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: vpx(75)
        color: theme.main
        z: 5

        HeaderBar {
        id: headercontainer

            anchors.fill: parent
            titleText: genreNames[genreList.currentIndex]
        }
        Keys.onDownPressed: {
            sfxNav.play();
            genreList.focus = true;
        }
    }

    Item {
    id: genreContainer

        anchors {
            top: header.bottom; topMargin: globalMargin
            left: parent.left; leftMargin: globalMargin
            right: parent.right; rightMargin: globalMargin
            bottom: parent.bottom; bottomMargin: globalMargin
        }

        ListView {
        id: genreList

            clip: true
            spacing: 0
            orientation: ListView.Vertical
            model: genreNames
            currentIndex: storedGenreIndex

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: vpx(300)

            preferredHighlightBegin: height / 2 - genreItemHeight
            preferredHighlightEnd: height / 2
            highlightRangeMode: ListView.ApplyRange
            highlightMoveDuration: 100

            onCurrentIndexChanged: {
                storedGenreIndex = currentIndex;
                gamegrid.currentIndex = 0;
            }

            delegate: Item {
                width: ListView.view.width
                height: genreItemHeight
                property bool selected: ListView.isCurrentItem
                property bool highlighted: selected && genreList.focus

                Rectangle {
                    width: vpx(3)
                    anchors {
                        left: parent.left; leftMargin: vpx(11)
                        top: parent.top; topMargin: vpx(5)
                        bottom: parent.bottom; bottomMargin: vpx(5)
                    }
                    color: highlighted ? theme.accent : theme.text
                    visible: selected
                }

                Text {
                    text: modelData
                    height: parent.height
                    anchors {
                        left: parent.left; leftMargin: vpx(25)
                        right: parent.right; rightMargin: vpx(25)
                    }
                    color: highlighted ? theme.accent : theme.text
                    font.family: subtitleFont.name
                    font.pixelSize: vpx(20)
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    opacity: selected ? 1 : 0.2
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        sfxNav.play();
                        genreList.currentIndex = index;
                        if (selected)
                            gamegrid.focus = true;
                    }
                }
            }

            Keys.onUpPressed: {
                sfxNav.play();
                if (currentIndex === 0)
                    headercontainer.focus = true;
                else
                    decrementCurrentIndex();
            }
            Keys.onDownPressed: { sfxNav.play(); incrementCurrentIndex() }
            Keys.onRightPressed: {
                sfxNav.play();
                gamegrid.focus = true;
                gamegrid.currentIndex = 0;
            }
            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    sfxAccept.play();
                    gamegrid.focus = true;
                    gamegrid.currentIndex = 0;
                }
                if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    previousScreen();
                }
            }
        }

        Rectangle {
            anchors {
                left: genreList.right
                top: genreList.top
                bottom: genreList.bottom
            }
            width: vpx(1)
            color: theme.text
            opacity: 0.1
        }

        Item {
        id: gridContainer

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: genreList.right; leftMargin: globalMargin
                right: parent.right
            }

            GridView {
            id: gamegrid

                property real savedCellHeight: {
                    if (settings.GridThumbnail == "Tall") {
                        return cellWidth / settings.TallRatio;
                    } else if (settings.GridThumbnail == "Square") {
                        return cellWidth;
                    } else {
                        return cellWidth * settings.WideRatio;
                    }
                }

                Component.onCompleted: {
                    currentIndex = storedGenreGameIndex;
                    positionViewAtIndex(currentIndex, GridView.Visible);
                }

                anchors {
                    top: parent.top; left: parent.left; right: parent.right;
                    bottom: parent.bottom; bottomMargin: helpMargin + vpx(40)
                }
                cellWidth: width / numColumns
                cellHeight: savedCellHeight + titleMargin
                preferredHighlightBegin: vpx(0)
                preferredHighlightEnd: gamegrid.height - helpMargin - vpx(40)
                highlightRangeMode: GridView.ApplyRange
                highlightMoveDuration: 200
                highlight: highlightcomponent
                keyNavigationWraps: false
                displayMarginBeginning: cellHeight * 2
                displayMarginEnd: cellHeight * 2

                model: genreList.currentIndex === 0 ? listAll.games : listGenre.games
                delegate: dynamicDelegate

                Component {
                id: dynamicDelegate

                    DynamicGridItem {
                        selected: GridView.isCurrentItem && root.focus

                        width: GridView.view.cellWidth
                        height: GridView.view.cellHeight - titleMargin

                        onActivated: {
                            if (selected)
                                gameActivated();
                            else
                                gamegrid.currentIndex = index;
                        }
                        onHighlighted: {
                            gamegrid.currentIndex = index;
                        }
                        Keys.onPressed: {
                            if (api.keys.isDetails(event) && !event.isAutoRepeat) {
                                event.accepted = true;
                                sfxToggle.play();
                                modelData.favorite = !modelData.favorite;
                            }
                        }
                    }
                }

                Component {
                id: highlightcomponent

                    ItemHighlight {
                        width: gamegrid.cellWidth
                        height: gamegrid.cellHeight
                        game: currentList().currentGame(gamegrid.currentIndex)
                        selected: gamegrid.focus
                        boxArt: false
                    }
                }

                Keys.onUpPressed: {
                    sfxNav.play();
                    if (currentIndex < numColumns) {
                        genreList.focus = true;
                        gamegrid.currentIndex = -1;
                    } else {
                        moveCurrentIndexUp();
                    }
                }
                Keys.onDownPressed:     { sfxNav.play(); moveCurrentIndexDown() }
                Keys.onLeftPressed: {
                    sfxNav.play();
                    if (currentIndex % numColumns === 0) {
                        genreList.focus = true;
                        gamegrid.currentIndex = -1;
                    } else {
                        moveCurrentIndexLeft();
                    }
                }
                Keys.onRightPressed:    { sfxNav.play(); moveCurrentIndexRight() }
            }
        }
    }

    Keys.onPressed: {
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (gamegrid.focus) {
                gameActivated();
            } else if (genreList.focus) {
                sfxAccept.play();
                gamegrid.focus = true;
                gamegrid.currentIndex = 0;
            } else {
                genreList.focus = true;
            }
            return;
        }

        if (api.keys.isCancel(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (gamegrid.focus) {
                storedGenreGameIndex = gamegrid.currentIndex;
                genreList.focus = true;
            } else if (genreList.focus) {
                previousScreen();
            } else {
                genreList.focus = true;
            }
            return;
        }
    }

    ListModel {
        id: genreHelpModel

        ListElement { name: "Back"; button: "cancel" }
        ListElement { name: "Toggle favorite"; button: "details" }
        ListElement { name: "View details"; button: "accept" }
    }

    onFocusChanged: {
        if (focus) {
            currentHelpbarModel = genreHelpModel;
            if (!genreList.focus && !gamegrid.focus)
                genreList.focus = true;
        }
    }
}
