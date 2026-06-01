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

    property alias games: gamesFiltered
    function currentGame(index) { return api.allGames.get(lastPlayedGames.mapToSource(index)) }
    function isKidsOnlyAt(index) { return Utils.isKidsOnlyGame(api.allGames.get(index)); }
    property bool kidsOnly: false
    property int max: lastPlayedGames.count

    SortFilterProxyModel {
    id: lastPlayedGames

        sourceModel: api.allGames
        filters: ExpressionFilter { enabled: kidsOnly; expression: root.isKidsOnlyAt(model.index) }
        sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder }
    }

    SortFilterProxyModel {
    id: gamesFiltered

        sourceModel: lastPlayedGames
        filters: IndexFilter { maximumIndex: max - 1 }
    }

    property var collection: {
        return {
            name:       "Continue Playing",
            shortName:  "lastplayed",
            games:      gamesFiltered
        }
    }
}
