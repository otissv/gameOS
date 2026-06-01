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

Item {
id: root

    readonly property alias games: lastPlayedInCollection
    property var sourceCollection: api.collections.get(currentCollectionIndex)

    function currentGame(index) {
        return sourceCollection.games.get(lastPlayedInCollection.mapToSource(index));
    }

    SortFilterProxyModel {
    id: lastPlayedInCollection

        sourceModel: sourceCollection.games
        filters: ExpressionFilter {
            expression: !isNaN(lastPlayed)
        }
        sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder }
    }

    property var collection: {
        return {
            name:       "Continue Playing",
            shortName:  "lastplayed",
            games:      lastPlayedInCollection
        }
    }
}
