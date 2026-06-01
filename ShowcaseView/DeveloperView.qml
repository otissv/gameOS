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
        return developerList.currentIndex === 0 ? listAll : listDeveloper;
    }

    function gameActivated() {
        gameDetails(currentList().currentGame(gamegrid.currentIndex));
    }

    property var sortedGames;
    property var sortOrderWatcher: orderBy
    property var sortFieldWatcher: sortByIndex
    onSortOrderWatcherChanged: sortedGames = null
    onSortFieldWatcherChanged: sortedGames = null
    property bool isLeftTriggerPressed: false;
    property bool isRightTriggerPressed: false;

    Timer {
        id: letterScrollRepeatTimer
        interval: 300
        repeat: true
        property int scrollDirection: 0
        onTriggered: navigateToNextLetter(scrollDirection)
    }

    function beginTriggerLetterScroll(direction) {
        if (developerList.activeFocus) {
            return;
        }

        if (direction > 0) {
            if (isRightTriggerPressed) {
                return;
            }
            isRightTriggerPressed = true;
        } else {
            if (isLeftTriggerPressed) {
                return;
            }
            isLeftTriggerPressed = true;
        }

        letterScrollRepeatTimer.scrollDirection = direction;
        navigateToNextLetter(direction);
        letterScrollRepeatTimer.start();
    }

    function endTriggerLetterScroll(direction) {
        if (direction > 0) {
            isRightTriggerPressed = false;
        } else {
            isLeftTriggerPressed = false;
        }

        if (!isRightTriggerPressed && !isLeftTriggerPressed) {
            letterScrollRepeatTimer.stop();
        }
    }

    function nextChar(c, modifier) {
        const firstAlpha = 97;
        const lastAlpha = 122;

        var charCode = c.charCodeAt(0) + modifier;

        if (modifier > 0) {
            if (charCode < firstAlpha || isNaN(charCode)) {
                return 'a';
            }
            if (charCode > lastAlpha) {
                return '';
            }
        } else {
            if (charCode == firstAlpha - 1) {
                return '';
            }
            if (charCode < firstAlpha || charCode > lastAlpha || isNaN(charCode)) {
                return 'z';
            }
        }

        return String.fromCharCode(charCode);
    }

    function refreshSortedGames() {
        var list = currentList();
        var count = list.games.count;
        var titles = [];
        for (var i = 0; i < count; i++) {
            var game = list.currentGame(i);
            titles.push((game.sortBy || game.title || "").toLowerCase());
        }
        sortedGames = titles;
    }

    function navigateToNextLetter(modifier) {
        if (sortByFilter[sortByIndex] !== "sortBy") {
            endTriggerLetterScroll(modifier);
            return false;
        }

        if (developerList.activeFocus) {
            return false;
        }

        var currentIndex = gamegrid.currentIndex;
        if (currentIndex == -1) {
            gamegrid.currentIndex = 0;
        }
        else {
            if (sortedGames == null) {
                refreshSortedGames();
            }

            var currentGameTitle = sortedGames[currentIndex];
            var currentLetter = currentGameTitle.toLowerCase().charAt(0);

            const firstAlpha = 97;
            const lastAlpha = 122;

            if (currentLetter.charCodeAt(0) < firstAlpha || currentLetter.charCodeAt(0) > lastAlpha) {
                currentLetter = '';
            }

            var nextIndex = currentIndex;
            var nextLetter = currentLetter;

            do {
                do {
                    nextLetter = nextChar(nextLetter, modifier);

                    if (currentLetter == nextLetter) {
                        break;
                    }

                    if (nextLetter == '') {
                        if (sortedGames.some(g => g.toLowerCase().charCodeAt(0) < firstAlpha || g.toLowerCase().charCodeAt(0) > lastAlpha)) {
                            break;
                        }
                    }
                    else if (sortedGames.some(g => g.charAt(0) == nextLetter)) {
                        break;
                    }
                } while (true)

                nextIndex = sortedGames.findIndex(g => g.toLowerCase().localeCompare(nextLetter) >= 0);
            } while(nextIndex === -1)

            gamegrid.currentIndex = nextIndex;

            nextLetter = sortedGames[nextIndex].toLowerCase().charAt(0);
            var nextLetterCharCode = nextLetter.charCodeAt(0);
            if (nextLetterCharCode < firstAlpha || nextLetterCharCode > lastAlpha) {
                nextLetter = '#';
            }

            navigationLetterOpacityAnimator.running = false
            navigationLetter.text = nextLetter.toUpperCase();
            navigationOverlay.opacity = 0.8;
            navigationLetterOpacityAnimator.running = true
        }

        gamegrid.forceActiveFocus();
        sfxToggle.play();

        return true;
    }

    property int storedDeveloperIndex: 0
    property int storedDeveloperGameIndex: 0
    property int numColumns: settings.GridColumns ? settings.GridColumns : 6
    property int titleMargin: settings.AlwaysShowTitles === "Yes" ? vpx(30) : 0
    property real developerItemHeight: vpx(50)
    property var developerNames: ["All Games"].concat(Utils.uniqueGameValues('developerList', isKidsView))

    ListAllGames {
        id: listAll
        max: api.allGames.count
        kidsOnly: isKidsView
    }

    ListDeveloper {
        id: listDeveloper
        max: api.allGames.count
        developer: developerList.currentIndex > 0 ? developerNames[developerList.currentIndex] : ""
        kidsOnly: isKidsView
    }

    Rectangle {
    id: navigationOverlay
        anchors.fill: parent;
        color: theme.main
        opacity: 0
        z: 10

        Text {
        id: navigationLetter
            antialiasing: true
            renderType: Text.NativeRendering
            font.hintingPreference: Font.PreferNoHinting
            font.family: titleFont.name
            font.capitalization: Font.AllUppercase
            font.pixelSize: vpx(200)
            color: "white"
            anchors.centerIn: parent
        }

        SequentialAnimation {
        id: navigationLetterOpacityAnimator
            PauseAnimation { duration: 500 }
            OpacityAnimator {
                target: navigationOverlay
                from: navigationOverlay.opacity
                to: 0;
                duration: 500
            }
        }
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
            titleText: developerNames[developerList.currentIndex]
        }
        Keys.onDownPressed: {
            sfxNav.play();
            developerList.focus = true;
        }
    }

    Item {
    id: developerContainer

        anchors {
            top: header.bottom; topMargin: globalMargin
            left: parent.left; leftMargin: globalMargin
            right: parent.right; rightMargin: globalMargin
            bottom: parent.bottom; bottomMargin: globalMargin
        }

        ListView {
        id: developerList

            clip: true
            spacing: 0
            orientation: ListView.Vertical
            model: developerNames
            currentIndex: storedDeveloperIndex

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: vpx(300)

            preferredHighlightBegin: height / 2 - developerItemHeight
            preferredHighlightEnd: height / 2
            highlightRangeMode: ListView.ApplyRange
            highlightMoveDuration: 100

            onCurrentIndexChanged: {
                storedDeveloperIndex = currentIndex;
                gamegrid.currentIndex = 0;
                sortedGames = null;
            }

            delegate: Item {
                width: ListView.view.width
                height: developerItemHeight
                property bool selected: ListView.isCurrentItem
                property bool highlighted: selected && developerList.focus

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
                        developerList.currentIndex = index;
                        if (selected)
                            gamegrid.forceActiveFocus();
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
                gamegrid.forceActiveFocus();
                gamegrid.currentIndex = 0;
            }
            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    sfxAccept.play();
                    gamegrid.forceActiveFocus();
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
                left: developerList.right
                top: developerList.top
                bottom: developerList.bottom
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
                left: developerList.right; leftMargin: globalMargin
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
                    currentIndex = storedDeveloperGameIndex;
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

                model: developerList.currentIndex === 0 ? listAll.games : listDeveloper.games
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
                            gamegrid.forceActiveFocus();
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
                        developerList.focus = true;
                        gamegrid.currentIndex = -1;
                    } else {
                        moveCurrentIndexUp();
                    }
                }
                Keys.onDownPressed:     { sfxNav.play(); moveCurrentIndexDown() }
                Keys.onLeftPressed: {
                    sfxNav.play();
                    if (currentIndex % numColumns === 0) {
                        developerList.focus = true;
                        gamegrid.currentIndex = -1;
                    } else {
                        moveCurrentIndexLeft();
                    }
                }
                Keys.onRightPressed:    { sfxNav.play(); moveCurrentIndexRight() }
            }
        }
    }

    Keys.onReleased: {
        if (api.keys.isPageDown(event) && !event.isAutoRepeat) {
            event.accepted = true;
            endTriggerLetterScroll(+1);
            return;
        }

        if (api.keys.isPageUp(event) && !event.isAutoRepeat) {
            event.accepted = true;
            endTriggerLetterScroll(-1);
            return;
        }
    }

    Keys.onPressed: {
        if (api.keys.isPageDown(event) && !event.isAutoRepeat) {
            event.accepted = true;
            beginTriggerLetterScroll(+1);
            return;
        }

        if (api.keys.isPageUp(event) && !event.isAutoRepeat) {
            event.accepted = true;
            beginTriggerLetterScroll(-1);
            return;
        }

        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (gamegrid.activeFocus) {
                gameActivated();
            } else if (developerList.focus) {
                sfxAccept.play();
                gamegrid.forceActiveFocus();
                gamegrid.currentIndex = 0;
            } else {
                developerList.focus = true;
            }
            return;
        }

        if (api.keys.isCancel(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (gamegrid.activeFocus) {
                storedDeveloperGameIndex = gamegrid.currentIndex;
                developerList.focus = true;
            } else if (developerList.focus) {
                previousScreen();
            } else {
                developerList.focus = true;
            }
            return;
        }
    }

    ListModel {
        id: developerHelpModel

        ListElement { name: "Back"; button: "cancel" }
        ListElement { name: "Toggle favorite"; button: "details" }
        ListElement { name: "View details"; button: "accept" }
    }

    onFocusChanged: {
        if (focus) {
            currentHelpbarModel = developerHelpModel;
            if (!developerList.focus && !gamegrid.focus)
                developerList.focus = true;
        }
    }
}
