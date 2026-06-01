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

FocusScope {
id: root

    function gameActivated() {
        gameDetails(list.currentGame(gamegrid.currentIndex));
    }

    property int storedGenreGameIndex: 0
    property int numColumns: settings.GridColumns ? settings.GridColumns : 6
    property int titleMargin: settings.AlwaysShowTitles === "Yes" ? vpx(30) : 0

    ListAllGames {
        id: list
        max: api.allGames.count
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
            titleText: "Genre"
        }
        Keys.onDownPressed: {
            sfxNav.play();
            gamegrid.focus = true;
            gamegrid.currentIndex = 0;
        }
    }

    Item {
    id: gridContainer

        anchors {
            top: header.bottom; topMargin: globalMargin
            left: parent.left; leftMargin: globalMargin
            right: parent.right; rightMargin: globalMargin
            bottom: parent.bottom; bottomMargin: globalMargin
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

            model: list.games
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
                    game: list.currentGame(gamegrid.currentIndex)
                    selected: gamegrid.focus
                    boxArt: false
                }
            }

            Keys.onUpPressed: {
                sfxNav.play();
                if (currentIndex < numColumns) {
                    headercontainer.focus = true;
                    gamegrid.currentIndex = -1;
                } else {
                    moveCurrentIndexUp();
                }
            }
            Keys.onDownPressed:     { sfxNav.play(); moveCurrentIndexDown() }
            Keys.onLeftPressed:     { sfxNav.play(); moveCurrentIndexLeft() }
            Keys.onRightPressed:    { sfxNav.play(); moveCurrentIndexRight() }
        }
    }

    Keys.onPressed: {
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (gamegrid.focus) {
                gameActivated();
            } else {
                gamegrid.currentIndex = 0;
                gamegrid.focus = true;
            }
            return;
        }

        if (api.keys.isCancel(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (gamegrid.focus) {
                storedGenreGameIndex = gamegrid.currentIndex;
                previousScreen();
            } else {
                gamegrid.focus = true;
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
            gamegrid.focus = true;
        }
    }
}
