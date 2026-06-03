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
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.12
import "../Global"
import "../Lists"
import "../utils.js" as Utils

FocusScope {
id: root

    anchors.fill: parent
    

    readonly property real heroHeight: height * 0.5
    readonly property real gridTopInset: heroHeight
    readonly property string platformFilename: (
        root.collectionIndex >= 0 && root.collectionIndex < api.collections.count
            ? Utils.processPlatformName(api.collections.get(root.collectionIndex).shortName)
            : ""
    )
    readonly property string platformContentSource: (
        root.platformFilename
            ? "../assets/images/platform/" + root.platformFilename + "-content.jpg"
            : ""
    )
    property string heroScreenshotSource: pickRandomHeroScreenshot() 

    function pickRandomHeroScreenshot() {
        var count = list.games.count
        if (count <= 0)
            return ""

        var tries = Math.min(count, 8)
        for (var i = 0; i < tries; i++) {
            var game = list.currentGame(Math.floor(Math.random() * count))
            if (!game)
                continue

            var shots = game.assets.screenshotList
            if (shots && shots.length > 0)
                return shots[Math.floor(Math.random() * shots.length)]

            if (game.assets.screenshots && game.assets.screenshots[0])
                return game.assets.screenshots[0]

            if (game.assets.background)
                return game.assets.background
        }

        return ""
    }

    function gridRowForIndex(index) {
        if (index < 0)
            return -1

        return Math.floor(index / numColumns)
    }

    function targetGridContentY(index) {
        var row = gridRowForIndex(index)
        var maxContentY = Math.max(0, gamegrid.contentHeight - gamegrid.height)

        if (row <= 0)
            return 0

        return Math.min(row * gamegrid.cellHeight, maxContentY)
    }

    function animateGridScroll(targetY) {
        var clampedTargetY = Math.max(0, Math.min(targetY, Math.max(0, gamegrid.contentHeight - gamegrid.height)))

        if (Math.abs(gamegrid.contentY - clampedTargetY) < 1)
            return

        heroSnapAnim.stop()
        heroSnapAnim.from = gamegrid.contentY
        heroSnapAnim.to = clampedTargetY
        heroSnapAnim.start()
    }

    function alignGridToCurrentIndex(immediate) {
        var targetY = targetGridContentY(gamegrid.currentIndex)

        if (immediate) {
            heroSnapAnim.stop()
            gamegrid.contentY = targetY
            return
        }

        animateGridScroll(targetY)
    }

    function resetHeroScroll(immediate) {
        if (immediate) {
            heroSnapAnim.stop()
            gamegrid.contentY = 0
            return
        }

        animateGridScroll(0)
    }

    function isFirstGridRow(index) {
        return index >= 0 && index < numColumns
    }

    // While not necessary to do it here, this means we don't need to change it in both
    // touch and gamepad functions each time
    function gameActivated() {
        storedCollectionGameIndex = gamegrid.currentIndex
        gameDetails(list.currentGame(gamegrid.currentIndex));
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

        if (modifier > 0) { // Scroll down
            if (charCode < firstAlpha || isNaN(charCode)) {
                return 'a';
            }
            if (charCode > lastAlpha) {
                return '';
            }
        } else { // Scroll up
            if (charCode == firstAlpha - 1) {
                return '';
            }
            if (charCode < firstAlpha || charCode > lastAlpha || isNaN(charCode)) {
                return 'z';
            }
        }

        return String.fromCharCode(charCode);
    }

    function navigateToNextLetter(modifier) {
        if (sortByFilter[sortByIndex] !== "sortBy") {
            endTriggerLetterScroll(modifier);
            return false;
        }

        var currentIndex = gamegrid.currentIndex;
        if (currentIndex == -1) {
            gamegrid.currentIndex = 0;
        }
        else {
            // NOTE: We should be using the scroll proxy here, but this is significantly faster.
            if (sortedGames == null) {
                sortedGames = list.collection.games.toVarArray().map(g => g.sortBy.toLowerCase());
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

        gamegrid.focus = true;
        sfxToggle.play();

        return true;
    }

    ListCollectionGames {
        id: list
        kidsOnly: isKidsView
    }

    // Load settings
    property bool showBoxes: settings.GridThumbnail === "Box Art"
    property int numColumns: settings.GridColumns ? settings.GridColumns : 6
    property int titleMargin: settings.AlwaysShowTitles === "Yes" ? vpx(30) : 0


    Rectangle {
    id: gridBackground

        parent: gamegrid.contentItem
        x: -gamegrid.x
        y: 0
        z: -1
        width: root.width
        height: Math.max(gamegrid.contentHeight, gamegrid.height)
        color: theme.main
    }



    GridSpacer {
    id: fakebox

        width: vpx(100); height: vpx(100)
        games: list.games
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

    // Fixed hero (grid scrolls over this)
    Item {
    id: heroSection

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: heroHeight
        z: 0

        Image {
            id: heroBackground

            anchors.fill: parent
            property bool usePlatformFallback: false

            readonly property string screenshotSource: root.heroScreenshotSource
            readonly property string fallbackSource: root.platformContentSource

            source: screenshotSource ? screenshotSource: fallbackSource 
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
        }


        Scanlines {}

        Image {
            id:platformlogo

             anchors.centerIn: parent
            source: "../assets/images/platform/" + platformFilename + ".png"
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            visible: platformFilename !== ""
        }

        DropShadow {
        id: platformlogoShadow

            anchors.fill: platformlogo
            horizontalOffset: 0
            verticalOffset: 0
            radius: 8.0
            samples: 12
            color: "#000000"
            source: platformlogo
            opacity: (content.currentIndex !== 0 || detailsScreen.opacity !== 0) ? 0 : 0.4
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: settings.GameLogo === "Show"
        }


        LinearGradient {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: vpx(120)
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: theme.main }
            }
        }
    }

    Rectangle {
    id: header

        anchors {
            top:    parent.top
            left:   parent.left
            right:  parent.right
        }
        height: vpx(75)
        color: "transparent"
        z: 5

        HeaderBar {
        id: headercontainer

            anchors.fill: parent
        }
        Keys.onDownPressed: {
            sfxNav.play();
            gamegrid.focus = true;
            gamegrid.currentIndex = 0;
            resetHeroScroll();
        }
    }

    NumberAnimation {
    id: heroSnapAnim

        target: gamegrid
        property: "contentY"
        duration: 200
        easing.type: Easing.OutCubic
    }

    GridView {
    id: gamegrid

        // Figuring out the aspect ratio for box art
            property real cellHeightRatio: fakebox.paintedHeight / fakebox.paintedWidth
            property real savedCellHeight: {
                if (settings.GridThumbnail == "Tall") {
                    return cellWidth / settings.TallRatio;
                } else if (settings.GridThumbnail == "Square") {
                    return cellWidth;
                } else {
                    return cellWidth * settings.WideRatio;
                }
            }
            property var sourceThumbnail: showBoxes ? "BoxArtGridItem.qml" : "../Global/DynamicGridItem.qml"

            Component.onCompleted: {
                currentIndex = storedCollectionGameIndex;
                alignGridToCurrentIndex(true);
            }

            onCurrentIndexChanged: {
                if (isFirstGridRow(currentIndex))
                    resetHeroScroll();
                else
                    alignGridToCurrentIndex();
            }

            populate: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
            }

            anchors {
                top: parent.top
                topMargin: gridTopInset
                left: parent.left; leftMargin: globalMargin
                right: parent.right; rightMargin: globalMargin
                bottom: parent.bottom; bottomMargin: helpMargin + vpx(40)
            }
            z: 2
            clip: false

        cellWidth: width / numColumns
        cellHeight: ((showBoxes) ? cellWidth * cellHeightRatio : savedCellHeight) + titleMargin
        preferredHighlightBegin: 0
        preferredHighlightEnd: gamegrid.height - helpMargin - vpx(40)
        highlightRangeMode: GridView.NoHighlightRange
        highlightMoveDuration: 200
        highlight: highlightcomponent
        keyNavigationWraps: false
        displayMarginBeginning: cellHeight * 2
        displayMarginEnd: cellHeight * 2

        model: list.games
        delegate: (showBoxes) ? boxartdelegate : dynamicDelegate

        Component {
            id: boxartdelegate

            BoxArtGridItem {
                selected: GridView.isCurrentItem && root.focus
                    gameData: modelData

                    width:      GridView.view.cellWidth
                    height:     GridView.view.cellHeight - titleMargin
                    
                    onActivate: {
                        if (selected)
                            gameActivated();
                        else
                            gamegrid.currentIndex = index;
                    }
                    onHighlighted: {
                        gamegrid.currentIndex = index;
                    }
                    Keys.onPressed: {
                        // Toggle favorite
                        if (api.keys.isDetails(event) && !event.isAutoRepeat) {
                            event.accepted = true;
                            sfxToggle.play();
                            modelData.favorite = !modelData.favorite;
                        }
                    }

                }
            }

        Component {
        id: dynamicDelegate

            DynamicGridItem {
                id: dynamicdelegatecontainer

                    selected: GridView.isCurrentItem && root.focus

                    width:      GridView.view.cellWidth
                    height:     GridView.view.cellHeight - titleMargin
                    
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
                        // Toggle favorite
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
                    boxArt: showBoxes
                }
            }

        // Manually set the navigation this way so audio can play without performance hits
        Keys.onUpPressed: {
                sfxNav.play();
                if (currentIndex < numColumns) {
                    headercontainer.focus = true;
                    gamegrid.currentIndex = -1;
                    resetHeroScroll();
                } else {
                    moveCurrentIndexUp();
                }
            }
        Keys.onDownPressed:     { sfxNav.play(); moveCurrentIndexDown() }
        Keys.onLeftPressed:     { sfxNav.play(); moveCurrentIndexLeft() }
        Keys.onRightPressed:    { sfxNav.play(); moveCurrentIndexRight() }
    }

    Keys.onReleased: {
        // Scroll Down
        if (api.keys.isPageDown(event) && !event.isAutoRepeat) {
            event.accepted = true;
            endTriggerLetterScroll(+1);
            return;
        }

        // Scroll Up
        if (api.keys.isPageUp(event) && !event.isAutoRepeat) {
            event.accepted = true;
            endTriggerLetterScroll(-1);
            return;
        }
    }

    Keys.onPressed: {
        // Accept
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

        // Back
        if (api.keys.isCancel(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (gamegrid.focus) {
                previousScreen();
            } else {
                gamegrid.focus = true;
            }
            return;
        }

        // Details
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxToggle.play();
            cycleSort();
            return;
        }

        // Scroll Down
        if (api.keys.isPageDown(event) && !event.isAutoRepeat) {
            event.accepted = true;
            beginTriggerLetterScroll(+1);
            return;
        }

        // Scroll Up
        if (api.keys.isPageUp(event) && !event.isAutoRepeat) {
            event.accepted = true;
            beginTriggerLetterScroll(-1);
            return;
        }

        // Next collection
        if (api.keys.isNextPage(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (currentCollectionIndex < api.collections.count - 1)
                currentCollectionIndex++;
            else
                currentCollectionIndex = 0;

            gamegrid.currentIndex = 0;
            resetHeroScroll();
            sfxToggle.play();

            // Reset our cached sorted games
            sortedGames = null;
            return;
        }

        // Previous collection
        if (api.keys.isPrevPage(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (currentCollectionIndex > 0)
                currentCollectionIndex--;
            else
                currentCollectionIndex = api.collections.count - 1;

            gamegrid.currentIndex = 0;
            resetHeroScroll();
            sfxToggle.play();

            // Reset our cached sorted games
            sortedGames = null;
            return;
        }
    }

    // Helpbar buttons
    ListModel {
        id: gridviewHelpModel

        ListElement {
            name: "Back"
            button: "cancel"
        }
        ListElement {
            name: "Toggle favorite"
            button: "details"
        }
        ListElement {
            name: "Filters"
            button: "filters"
        }
        ListElement {
            name: "View details"
            button: "accept"
        }
    }

    property int collectionIndex: currentCollectionIndex
    onCollectionIndexChanged: {
        pickRandomHeroScreenshot()
        resetHeroScroll()
    }

    Component.onCompleted: pickRandomHeroScreenshot()

    onFocusChanged: {
        if (focus) {
            pickRandomHeroScreenshot()
            currentHelpbarModel = gridviewHelpModel;
            gamegrid.focus = true;
            if (isFirstGridRow(gamegrid.currentIndex))
                resetHeroScroll();
            else
                alignGridToCurrentIndex();
        }
    }
}
