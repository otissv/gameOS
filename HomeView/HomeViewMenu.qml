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
import SortFilterProxyModel 0.2
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQml.Models 2.10
import "../Global"
import "../GameDetails"
import "../GridView"
import "../Lists"
import "../utils.js" as Utils

FocusScope {
id: root

    property bool kidsOnly: false

    // Pull in our custom lists and define
    ListAllGames    { id: listNone;        max: 0; kidsOnly: root.kidsOnly }
    ListAllGames    { id: listAllGames;    max: settings.ShowcaseColumns; kidsOnly: root.kidsOnly }
    ListFavorites   { id: listFavorites;   max: settings.ShowcaseColumns; kidsOnly: root.kidsOnly }
    ListLastPlayed  { id: listLastPlayed;  max: settings.ShowcaseColumns; kidsOnly: root.kidsOnly }
    ListMostPlayed  { id: listMostPlayed;  max: settings.ShowcaseColumns; kidsOnly: root.kidsOnly }
    ListRecommended { id: listRecommended; max: settings.ShowcaseColumns; kidsOnly: root.kidsOnly }
    ListPublisher   { id: listPublisher;   max: settings.ShowcaseColumns; publisher: randoPub; kidsOnly: root.kidsOnly }
    ListGenre       { id: listGenre;       max: settings.ShowcaseColumns; genre: randoGenre; kidsOnly: root.kidsOnly }

    property var randomFeaturedGames: []
    property var collection1: getCollection(settings.ShowcaseCollection1, settings.ShowcaseCollection1_Thumbnail)
    property var collection2: getCollection(settings.ShowcaseCollection2, settings.ShowcaseCollection2_Thumbnail)
    property var collection3: getCollection(settings.ShowcaseCollection3, settings.ShowcaseCollection3_Thumbnail)
    property var collection4: getCollection(settings.ShowcaseCollection4, settings.ShowcaseCollection4_Thumbnail)
    property var collection5: getCollection(settings.ShowcaseCollection5, settings.ShowcaseCollection5_Thumbnail)

    function getCollection(collectionName, collectionThumbnail) {
        var collection = {
            enabled: true,
        };

        var width = root.width - globalMargin * 2;

        switch (collectionThumbnail) {
            case "Square":
                collection.itemWidth = (width / 6.0);
                collection.itemHeight = collection.itemWidth;
                break;
            case "Tall":
                collection.itemWidth = (width / 8.0);
                collection.itemHeight = collection.itemWidth / settings.TallRatio;
                break;
            case "Wide":
            default:
                collection.itemWidth = (width / 4.0);
                collection.itemHeight = collection.itemWidth * settings.WideRatio;
                break;
            
        }

        collection.height = collection.itemHeight + vpx(40) + globalMargin

        switch (collectionName) {
            case "Favorites":
                collection.search = listFavorites;
                break;
            case "Recently Played":
                collection.search = listLastPlayed;
                break;
            case "Most Played":
                collection.search = listMostPlayed;
                break;
            case "Recommended":
                collection.search = listRecommended;
                break;
            case "Top by Publisher":
                collection.search = listPublisher;
                break;
            case "Top by Genre":
                collection.search = listGenre;
                break;
            case "Kids":
                collection.enabled = false;
                collection.height = 0;
                collection.search = listNone;
                break;
            case "None":
                collection.enabled = false;
                collection.height = 0;

                collection.search = listNone;
                break;
            default:
                collection.search = listAllGames;
                break;
        }

        collection.title = collection.search.collection.name;
        return collection;
    }

    property string randoPub: (Utils.returnRandom(Utils.uniqueValuesArray('publisher', kidsOnly)) || '')
    property string randoGenre: Utils.returnRandom(Utils.uniqueGameValues('genreList', kidsOnly)) || ''

    function refreshRandomFeaturedGames() {
        var pool = api.allGames.toVarArray();
        if (kidsOnly)
            pool = pool.filter(function(game) { return Utils.isKidsOnlyGame(game); });

        var withScreenshots = pool.filter(function(game) {
            return (game.assets.screenshots && game.assets.screenshots.length)
                || (game.assets.screenshotList && game.assets.screenshotList.length);
        });
        if (withScreenshots.length)
            pool = withScreenshots;

        pool = Utils.shuffleArray(pool.slice());
        randomFeaturedGames = pool.slice(0, Math.min(5, pool.length));
        if (featuredlist.currentIndex >= randomFeaturedGames.length)
            featuredlist.currentIndex = Math.max(0, randomFeaturedGames.length - 1);
    }

    function featuredScreenshot(game) {
        if (!game || !game.assets)
            return "";
        if (game.assets.screenshots && game.assets.screenshots.length)
            return game.assets.screenshots[Math.floor(Math.random() * game.assets.screenshots.length)];
        if (game.assets.textures && game.assets.textures.length)
            return game.assets.textures[Math.floor(Math.random() * game.assets.textures.length)];
        if (game.assets.screenshotList && game.assets.screenshotList.length)
            return game.assets.screenshotList[Math.floor(Math.random() * game.assets.screenshotList.length)];
        return game.assets.background || Utils.fanArt(game) || "";
    }

    Timer {
        interval: 600000
        running: true
        repeat: true
        onTriggered: refreshRandomFeaturedGames()
    }

    Timer {
        interval: 0
        running: true
        repeat: false
        onTriggered: restoreMainListPosition()
    }

    onKidsOnlyChanged: refreshRandomFeaturedGames()
    Component.onCompleted: refreshRandomFeaturedGames()

    property bool ftue: randomFeaturedGames.length == 0

    function storeIndices(secondary) {
        storedHomePrimaryIndex = mainList.currentIndex;
        if (secondary !== undefined && secondary !== null)
            storedHomeSecondaryIndex = secondary;
    }

    function storeCurrentListPosition() {
        if (mainList.currentIndex === 0) {
            storeIndices(featuredlist.currentIndex);
        } else if (mainList.currentIndex === platformlist.ObjectModel.index) {
            storeIndices(platformlist.currentIndex >= 0 ? platformlist.currentIndex : platformlist.savedIndex);
        } else if (mainList.currentItem && mainList.currentItem.currentIndex !== undefined) {
            storeIndices(mainList.currentItem.currentIndex);
        } else {
            storeIndices();
        }
    }

    function restoreMainListPosition() {
        mainList.currentIndex = storedHomePrimaryIndex;

        if (storedHomePrimaryIndex === 0) {
            mainList.contentY = 0;
            return;
        }

        mainList.positionViewAtIndex(storedHomePrimaryIndex, ListView.Visible);
    }

    Component.onDestruction: storeCurrentListPosition();
    
    anchors.fill: parent

   
    HomeHeader {
    id: header

        width: parent.width
        kidsOnly: root.kidsOnly
        ftueVisible: ftueContainer.visible

        onKidsRequested: kidsScreen()
        onHomeRequested: previousScreen()
        onMainListFocusRequested: mainList.forceActiveFocus()
        onMainListIndexRequested: mainList.currentIndex = index
    }

    // Using an object model to build the list
    ObjectModel {
    id: mainModel

        ListView {
        id: featuredlist

            property bool selected: ListView.isCurrentItem
            
            focus: selected
            width: root.width
            height: root.height - header.height  - header.height - helpMargin -  globalMargin
            orientation: ListView.Horizontal
            clip: true
            preferredHighlightBegin: vpx(0)
            preferredHighlightEnd: parent.width
            highlightRangeMode: ListView.StrictlyEnforceRange
            //highlightMoveDuration: 200
            highlightMoveVelocity: -1
            snapMode: ListView.SnapOneItem
            keyNavigationWraps: true
            currentIndex: (storedHomePrimaryIndex == 0) ? storedHomeSecondaryIndex : 0
            Component.onCompleted: positionViewAtIndex(currentIndex, ListView.Visible)
            
            model: randomFeaturedGames
            delegate: featuredDelegate

            Component {
            id: featuredDelegate

                Item {
                    property bool selected: ListView.isCurrentItem && featuredlist.focus
                    width: featuredlist.width
                    height: featuredlist.height

                    Image {
                        id: background
                        anchors.fill: parent
                        source: featuredScreenshot(modelData)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                    }

                    Scanlines {}

                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: featuredlist.focus ? 0 : 0.5
                        Behavior on opacity { PropertyAnimation { duration: 150; easing.type: Easing.OutQuart; easing.amplitude: 2.0; easing.period: 1.5 } }
                    }

                    LinearGradient {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: vpx(180)
                        start: Qt.point(0, 0)
                        end: Qt.point(0, height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: "#CC000000" }
                        }
                    }


                    Image {
                    id: featuredMarquee

                        anchors {
                            top: parent.top
                            left: parent.left
                            bottom: featuredGameInfo.top
                            leftMargin: globalMargin
                            rightMargin: globalMargin
                        }
                        width: vpx(500)
                        height:parent.height / 2
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        smooth: true
                        source: modelData ? (modelData.assets.marquee || Utils.logo(modelData)) : ""
                        visible: source !== ""
                        Behavior on opacity { PropertyAnimation { duration: 150; easing.type: Easing.OutQuart; easing.amplitude: 2.0; easing.period: 1.5 } }
                    }

                    DropShadow {
                        anchors.fill: featuredMarquee
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 8.0
                        samples: 12
                        color: "#000000"
                        source: featuredMarquee
                        visible: featuredMarquee.visible
                        opacity: featuredlist.focus ? 0.6 : 0.3
                    }


                    GameMetaRow {
                    id: featuredGameInfo

                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                            leftMargin: globalMargin
                            rightMargin: globalMargin
                        }
                        gameData: modelData
                        showGenre: false
                        showTitle: true
                    }

                }
            }

            Row {
            id: blips

                anchors.horizontalCenter: parent.horizontalCenter
                anchors { bottom: parent.bottom; bottomMargin: vpx(20) }
                spacing: vpx(10)
                Repeater {
                    model: featuredlist.count
                    Rectangle {
                        width: vpx(10)
                        height: width
                        color: (featuredlist.currentIndex == index) && featuredlist.focus ? theme.accent : theme.text
                        radius: width/2
                        opacity: (featuredlist.currentIndex == index) ? 1 : 0.5
                    }
                }
            }

            Keys.onUpPressed: {
                sfxNav.play();
                header.focusNavigationButton();
            }
            Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
            Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }
            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    storedHomeSecondaryIndex = featuredlist.currentIndex;
                    if (!ftue && randomFeaturedGames.length)
                        gameDetails(randomFeaturedGames[currentIndex]);
                }
            }
        }

        Rectangle {
            id: spacer1
            width: vpx(100); height: vpx(10)
            color: "transparent"
            enabled: false
        }

        
        // Collections list
        ListView {
        id: platformlist

            property bool selected: ListView.isCurrentItem
            property int myIndex: ObjectModel.index

            anchors {
                left: parent.left; leftMargin: globalMargin 
                right: parent.right; rightMargin: globalMargin
            }


            focus: selected
            width: root.width
            height: vpx(100) + globalMargin * 2
            spacing: vpx(16)
            orientation: ListView.Horizontal
            preferredHighlightBegin: vpx(0)
            preferredHighlightEnd: parent.width - vpx(60)
            highlightRangeMode: ListView.ApplyRange
            snapMode: ListView.SnapOneItem
            highlightMoveDuration: 100
            keyNavigationWraps: true
            
            property int savedIndex: (storedHomePrimaryIndex === myIndex) ? storedHomeSecondaryIndex : collectionToPlatformListIndex(currentCollectionIndex)
            onFocusChanged: {
                if (focus) {
                    currentIndex = savedIndex;
                    if (savedIndex < 2)
                        positionViewAtIndex(0, ListView.Begin);
                    else
                        positionViewAtIndex(savedIndex, ListView.Visible);
                } else {
                    if (currentIndex >= 0)
                        savedIndex = currentIndex;
                    currentIndex = -1;
                }
            }

            Component.onCompleted: positionViewAtIndex(0, ListView.Begin)

            model: platformListCount
            delegate: Rectangle {
                readonly property bool isGenre: platformListIsGenre(index)
                readonly property bool isSettings: platformListIsSettings(index)
                property var modelData: platformListIsCollection(index)
                    ? api.collections.get(platformListToCollectionIndex(index))
                    : null
                property bool selected: ListView.isCurrentItem && platformlist.focus
                width: (root.width - globalMargin * 2) / 7.0
                height: width * settings.WideRatio
                color: theme.secondary
                scale: selected ? 1.1 : 1
                Behavior on scale { NumberAnimation { duration: 100 } }
                border.width: vpx(1)
                border.color: selected ? theme.accent : theme.border
                radius: vpx(10)
                anchors.verticalCenter: parent.verticalCenter

				property var platformFilename: modelData
                    ? Utils.processPlatformName(modelData.shortName)
                    : ""

                Image {
                id: collectionlogo

                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.margins: vpx(15)
                    source: isSettings
                        ? "../assets/images/settingsicon.svg"
                        : (platformFilename
                            ? "../assets/images/platform/" + platformFilename + ".png"
                            : "")
                    sourceSize: Qt.size(collectionlogo.width, collectionlogo.height)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    visible: !isGenre
                    opacity: selected ? 1 : 0.5
                    scale: selected ? 1.1 : 1
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                Text {
                id: platformname

                    text: isGenre ? "Games" : (isSettings ? "Settings" : modelData.name)
                    anchors { fill: parent; margins: vpx(10) }
                    color: theme.text
                    opacity: selected ? 1 : 0.2
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                    font.pixelSize: vpx(18)
                    font.family: subtitleFont.name
                    font.bold: true
                    style: Text.Outline; styleColor: theme.main

					// show text when there's no PNG logo, or for genre tile
					visible: isGenre || collectionlogo.status == Image.Error
                    anchors.centerIn: parent
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    lineHeight: 0.8
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: settings.MouseHover == "Yes"
                    onEntered: { sfxNav.play(); mainList.currentIndex = platformlist.ObjectModel.index; platformlist.savedIndex = index; platformlist.currentIndex = index; }
                    onExited: {}
                    onClicked: {
                        if (selected)
                            activatePlatformListItem(index);
                        else {
                            mainList.currentIndex = platformlist.ObjectModel.index;
                            platformlist.currentIndex = index;
                        }
                    }
                }
            }

            // List specific input
            Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
            Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }
            Keys.onPressed: {
                // Accept
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    activatePlatformListItem(platformlist.currentIndex);
                }
            }

        }

        Rectangle {
            id: spacer2
            width: vpx(50); height: globalMargin * 2
            color: "transparent"
            enabled: false
        }


        HorizontalCollection {
        id: list1
            property bool selected: ListView.isCurrentItem
            property var currentList: list1
            property var collection: collection1

            enabled: collection.enabled
            visible: collection.enabled

            height: collection.height

            itemWidth: collection.itemWidth
            itemHeight: collection.itemHeight

            title: collection.title
            search: collection.search

            focus: selected
            width: root.width - globalMargin * 2
            x: globalMargin - vpx(8)

            savedIndex: (storedHomePrimaryIndex === currentList.ObjectModel.index) ? storedHomeSecondaryIndex : 0

            onActivateSelected: storedHomeSecondaryIndex = currentIndex;
            onActivate: { if (!selected) { mainList.currentIndex = currentList.ObjectModel.index; } }
            onListHighlighted: { sfxNav.play(); mainList.currentIndex = currentList.ObjectModel.index; }
        }

        HorizontalCollection {
        id: list2
            property bool selected: ListView.isCurrentItem
            property var currentList: list2
            property var collection: collection2

            enabled: collection.enabled
            visible: collection.enabled

            height: collection.height

            itemWidth: collection.itemWidth
            itemHeight: collection.itemHeight

            title: collection.title
            search: collection.search

            focus: selected
            width: root.width - globalMargin * 2
            x: globalMargin - vpx(8)

            savedIndex: (storedHomePrimaryIndex === currentList.ObjectModel.index) ? storedHomeSecondaryIndex : 0

            onActivateSelected: storedHomeSecondaryIndex = currentIndex;
            onActivate: { if (!selected) { mainList.currentIndex = currentList.ObjectModel.index; } }
            onListHighlighted: { sfxNav.play(); mainList.currentIndex = currentList.ObjectModel.index; }
        }

        HorizontalCollection {
        id: list3
            property bool selected: ListView.isCurrentItem
            property var currentList: list3
            property var collection: collection3

            enabled: collection.enabled
            visible: collection.enabled

            height: collection.height

            itemWidth: collection.itemWidth
            itemHeight: collection.itemHeight

            title: collection.title
            search: collection.search

            focus: selected
            width: root.width - globalMargin * 2
            x: globalMargin - vpx(8)

            savedIndex: (storedHomePrimaryIndex === currentList.ObjectModel.index) ? storedHomeSecondaryIndex : 0

            onActivateSelected: storedHomeSecondaryIndex = currentIndex;
            onActivate: { if (!selected) { mainList.currentIndex = currentList.ObjectModel.index; } }
            onListHighlighted: { sfxNav.play(); mainList.currentIndex = currentList.ObjectModel.index; }
        }

        HorizontalCollection {
        id: list4
            property bool selected: ListView.isCurrentItem
            property var currentList: list4
            property var collection: collection4

            enabled: collection.enabled
            visible: collection.enabled

            height: collection.height

            itemWidth: collection.itemWidth
            itemHeight: collection.itemHeight

            title: collection.title
            search: collection.search

            focus: selected
            width: root.width - globalMargin * 2
            x: globalMargin - vpx(8)

            savedIndex: (storedHomePrimaryIndex === currentList.ObjectModel.index) ? storedHomeSecondaryIndex : 0

            onActivateSelected: storedHomeSecondaryIndex = currentIndex;
            onActivate: { if (!selected) { mainList.currentIndex = currentList.ObjectModel.index; } }
            onListHighlighted: { sfxNav.play(); mainList.currentIndex = currentList.ObjectModel.index; }
        }

        HorizontalCollection {
        id: list5
            property bool selected: ListView.isCurrentItem
            property var currentList: list5
            property var collection: collection5

            enabled: collection.enabled
            visible: collection.enabled

            height: collection.height

            itemWidth: collection.itemWidth
            itemHeight: collection.itemHeight

            title: collection.title
            search: collection.search

            focus: selected
            width: root.width - globalMargin * 2
            x: globalMargin - vpx(8)

            savedIndex: (storedHomePrimaryIndex === currentList.ObjectModel.index) ? storedHomeSecondaryIndex : 0

            onActivateSelected: storedHomeSecondaryIndex = currentIndex;
            onActivate: { if (!selected) { mainList.currentIndex = currentList.ObjectModel.index; } }
            onListHighlighted: { sfxNav.play(); mainList.currentIndex = currentList.ObjectModel.index; }
        }
        
    }

    ListView {
    id: mainList

        anchors.fill: parent
        model: mainModel
        focus: !header.anyButtonActiveFocus
        highlightMoveDuration: 200
        highlightRangeMode: currentIndex === 0 ? ListView.NoHighlightRange : ListView.ApplyRange
        preferredHighlightBegin: currentIndex === 0 ? 0 : header.height
        preferredHighlightEnd: currentIndex === 0 ? height : parent.height - (helpMargin * 2)
        snapMode: ListView.SnapOneItem
        keyNavigationWraps: true
        currentIndex: storedHomePrimaryIndex
        onCurrentIndexChanged: {
            if (currentIndex === 0)
                contentY = 0;
        }
        
        cacheBuffer: 1000
        footer: Item { height: helpMargin }

        Keys.onUpPressed: {
            sfxNav.play();
            do {
                decrementCurrentIndex();
            } while (!currentItem.enabled);
        }
        Keys.onDownPressed: {
            sfxNav.play();
            do {
                incrementCurrentIndex();
            } while (!currentItem.enabled);
        }
    }

    // Global input handling for the screen
    Keys.onPressed: {
        // Settings
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            event.accepted = true;
            settingsScreen();
        }
    }

    // Helpbar buttons
    ListModel {
        id: gridviewHelpModel

        ListElement {
            name: "Settings"
            button: "filters"
        }
        ListElement {
            name: "Select"
            button: "accept"
        }
    }

    onFocusChanged: { 
        if (focus)
            currentHelpbarModel = gridviewHelpModel;
    }

}
