// gameOS theme
// Copyright (C) 2026 Otis Virginie
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

import QtQuick 2.0
import SortFilterProxyModel 0.2
import "../utils.js" as Utils

Item {
id: root

    readonly property alias games: gamesFiltered
    function currentGame(index) { return api.allGames.get(developerGames.mapToSource(index)) }
    property int max: developerGames.count
    property string developer: ""

    property bool kidsOnly: false

    function matchesDeveloperAt(srcIndex) {
        var filterDeveloper = developer
        if (!filterDeveloper.length)
            return false
        return Utils.gameHasDeveloper(api.allGames.get(srcIndex), filterDeveloper)
    }

    function isKidsOnlyAt(index) {
        return Utils.isKidsOnlyGame(api.allGames.get(index));
    }

    SortFilterProxyModel {
    id: developerGames

        sourceModel: api.allGames
        filters: [
            ExpressionFilter { expression: root.matchesDeveloperAt(model.index) },
            ValueFilter { roleName: "favorite"; value: true; enabled: showFavs },
            RegExpFilter { roleName: "title"; pattern: searchTerm; caseSensitivity: Qt.CaseInsensitive; enabled: searchTerm != "" },
            ExpressionFilter { enabled: kidsOnly; expression: root.isKidsOnlyAt(model.index) }
        ]
        sorters: [
            RoleSorter { roleName: sortByFilter[sortByIndex]; sortOrder: orderBy }
        ]
    }

    SortFilterProxyModel {
    id: gamesFiltered

        sourceModel: developerGames
        filters: IndexFilter { maximumIndex: max - 1 }
    }

    property var collection: {
        return {
            name:       "Games by " + developer,
            shortName:  developer + "games",
            games:      gamesFiltered
        }
    }
}
