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
import SortFilterProxyModel 0.2
import "../utils.js" as Utils

Item {
id: root

    property bool kidsOnly: false
    readonly property alias games: gamesFiltered
    property var collection: api.collections.get(currentCollectionIndex)
    function currentGame(index) {
        return collection.games.get(gamesFiltered.mapToSource(index));
    }
    function isKidsGameInCollection(index) {
        return Utils.isKidsOnlyGame(collection.games.get(index));
    }
    property int max

    SortFilterProxyModel {
    id: gamesFiltered

        sourceModel: collection.games
        filters: [
            ValueFilter { roleName: "favorite"; value: true; enabled: showFavs },
            RegExpFilter { roleName: "title"; pattern: searchTerm; caseSensitivity: Qt.CaseInsensitive; enabled: searchTerm != "" },
            ExpressionFilter { enabled: kidsOnly; expression: root.isKidsGameInCollection(model.index) },
            IndexFilter { maximumIndex: max - 1; enabled: max }
        ]
        sorters: [
            RoleSorter { roleName: sortByFilter[sortByIndex]; sortOrder: orderBy }
        ]
    }
}
