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

    property var metadataTypes: [
        { label: "GenreList", metadataKey: "genreList", listType: "genre" },
        { label: "DeveloperList", metadataKey: "developerList", listType: "developer" }
    ]
    property int metadataTypeIndex: 0
    property string metadataKey: "genreList"
    property string listType: "genre"

    function currentList() {
        return categoryList.currentIndex === 0 ? listAll : listFiltered;
    }

    function gameActivated() {
        gameDetails(currentList().currentGame(gamegrid.currentIndex));
    }

    function metadataTypeIndexFor(metadataKeyValue, listTypeValue) {
        for (var i = 0; i < metadataTypes.length; i++) {
            if (metadataTypes[i].metadataKey === metadataKeyValue || metadataTypes[i].listType === listTypeValue) {
                return i;
            }
        }

        return 0;
    }

    function currentMetadataType() {
        return metadataTypes[metadataTypeIndex] || metadataTypes[0];
    }

    function applyMetadataType(index) {
        if (metadataTypes.length === 0) {
            return;
        }

        metadataTypeIndex = (index + metadataTypes.length) % metadataTypes.length;
        metadataKey = currentMetadataType().metadataKey;
        listType = currentMetadataType().listType;
        storedCategoryIndex = 0;
        storedCategoryGameIndex = 0;
        categoryList.currentIndex = 0;
        gamegrid.currentIndex = 0;
        sortedGames = null;
    }

    function cycleMetadataType() {
        sfxToggle.play();
        applyMetadataType(metadataTypeIndex + 1);
    }

    property var sortedGames;
    property var sortOrderWatcher: orderBy
    property var sortFieldWatcher: sortByIndex
    onSortOrderWatcherChanged: sortedGames = null
    onSortFieldWatcherChanged: sortedGames = null
    property bool isLeftTriggerPressed: false;
    property bool isRightTriggerPressed: false;

    Component.onCompleted: applyMetadataType(metadataTypeIndexFor(metadataKey, listType));

    Timer {
        id: letterScrollRepeatTimer
        interval: 300
        repeat: true
        property int scrollDirection: 0
        onTriggered: navigateToNextLetter(scrollDirection)
    }

    function beginTriggerLetterScroll(direction) {
        if (categoryList.activeFocus) {
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

        if (categoryList.activeFocus) {
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

    property int storedCategoryIndex: 0
    property int storedCategoryGameIndex: 0
    property int numColumns: settings.GridColumns ? settings.GridColumns : 6
    property int titleMargin: settings.AlwaysShowTitles === "Yes" ? vpx(30) : 0
    property real categoryItemHeight: vpx(50)
    property var categoryNames: ["All Games"].concat(Utils.uniqueGameValues(metadataKey, isKidsView))

    readonly property var listFiltered: listFilteredLoader.item

    ListAllGames {
        id: listAll
        max: api.allGames.count
        kidsOnly: isKidsView
    }

    Loader {
        id: listFilteredLoader
        sourceComponent: listType === "developer" ? listDeveloperComponent : listGenreComponent
    }

    Component {
        id: listGenreComponent

        ListGenre {
            max: api.allGames.count
            genre: categoryList.currentIndex > 0 ? categoryNames[categoryList.currentIndex] : ""
            kidsOnly: isKidsView
        }
    }

    Component {
        id: listDeveloperComponent

        ListDeveloper {
            max: api.allGames.count
            developer: categoryList.currentIndex > 0 ? categoryNames[categoryList.currentIndex] : ""
            kidsOnly: isKidsView
        }
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
            color: theme.text
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
        color: "transparent"
        z: 5

        HeaderBar {
        id: headercontainer

            anchors.fill: parent
            titleText: " "
        }

        Item {
        id: metadataTypeButton

            property bool mouseHovered: false
            property bool highlighted: activeFocus || mouseHovered

            width: metadataTypeTitle.contentWidth + vpx(30)
            height: vpx(40)
            anchors {
                left: parent.left; leftMargin: globalMargin
                verticalCenter: parent.verticalCenter
            }
            z: 1

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: metadataTypeButton.highlighted ? theme.accent : theme.text
                opacity: metadataTypeButton.highlighted ? 1 : 0.2
            }

            Text {
            id: metadataTypeTitle

                text: currentMetadataType().label
                color: theme.text
                font.family: subtitleFont.name
                font.pixelSize: vpx(18)
                anchors.centerIn: parent
                elide: Text.ElideRight
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: metadataTypeButton.mouseHovered = true
                onExited: metadataTypeButton.mouseHovered = false
                onClicked: cycleMetadataType();
            }

            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    cycleMetadataType();
                    return;
                }
            }

            Keys.onDownPressed: {
                sfxNav.play();
                categoryList.focus = true;
            }

            Keys.onRightPressed: {
                sfxNav.play();
                headercontainer.focus = true;
            }
        }

        Keys.onDownPressed: {
            sfxNav.play();
            categoryList.focus = true;
        }
    }

    Item {
    id: categoryContainer

        anchors {
            top: header.bottom; topMargin: globalMargin
            left: parent.left; leftMargin: globalMargin
            right: parent.right; rightMargin: globalMargin
            bottom: parent.bottom; bottomMargin: globalMargin
        }

        ListView {
        id: categoryList

            clip: true
            spacing: 0
            orientation: ListView.Vertical
            model: categoryNames
            currentIndex: storedCategoryIndex

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: vpx(300)

            preferredHighlightBegin: height / 2 - categoryItemHeight
            preferredHighlightEnd: height / 2
            highlightRangeMode: ListView.ApplyRange
            highlightMoveDuration: 100

            onCurrentIndexChanged: {
                storedCategoryIndex = currentIndex;
                gamegrid.currentIndex = 0;
                sortedGames = null;
            }

            delegate: Item {
                width: ListView.view.width
                height: categoryItemHeight
                property bool selected: ListView.isCurrentItem
                property bool highlighted: selected && categoryList.focus

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
                        categoryList.currentIndex = index;
                        if (selected)
                            gamegrid.forceActiveFocus();
                    }
                }
            }

            Keys.onUpPressed: {
                sfxNav.play();
                if (currentIndex === 0)
                    metadataTypeButton.forceActiveFocus();
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
                left: categoryList.right
                top: categoryList.top
                bottom: categoryList.bottom
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
                left: categoryList.right; leftMargin: globalMargin
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
                    currentIndex = storedCategoryGameIndex;
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

                model: categoryList.currentIndex === 0 ? listAll.games : listFiltered.games
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
                        categoryList.focus = true;
                        gamegrid.currentIndex = -1;
                    } else {
                        moveCurrentIndexUp();
                    }
                }
                Keys.onDownPressed:     { sfxNav.play(); moveCurrentIndexDown() }
                Keys.onLeftPressed: {
                    sfxNav.play();
                    if (currentIndex % numColumns === 0) {
                        categoryList.focus = true;
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
            } else if (categoryList.focus) {
                sfxAccept.play();
                gamegrid.forceActiveFocus();
                gamegrid.currentIndex = 0;
            } else {
                categoryList.focus = true;
            }
            return;
        }

        if (api.keys.isCancel(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (gamegrid.activeFocus) {
                storedCategoryGameIndex = gamegrid.currentIndex;
                categoryList.focus = true;
            } else if (categoryList.focus) {
                previousScreen();
            } else {
                categoryList.focus = true;
            }
            return;
        }
    }

    ListModel {
        id: categoryHelpModel

        ListElement { name: "Back"; button: "cancel" }
        ListElement { name: "Toggle favorite"; button: "details" }
        ListElement { name: "View details"; button: "accept" }
    }

    onFocusChanged: {
        if (focus) {
            currentHelpbarModel = categoryHelpModel;
            if (!categoryList.focus && !gamegrid.focus)
                categoryList.focus = true;
        }
    }
}
