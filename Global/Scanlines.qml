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
import QtGraphicalEffects 1.0

Item {
id: root

    anchors.fill: parent

    property bool rounded: false
    property int cornerRadius: vpx(10)

    Image {
    id: scanlinesImage

        anchors.fill: parent
        source: "../assets/images/scanlines_v3.png"
        asynchronous: true
        opacity: selected ? 0.1 : 0.4
        visible: !rounded
    }

    Rectangle {
    id: scanlinesMask

        anchors.fill: parent
        radius: cornerRadius
        color: "white"
        visible: false
    }

    OpacityMask {
        anchors.fill: parent
        source: scanlinesImage
        maskSource: scanlinesMask
        opacity: scanlinesImage.opacity
        visible: rounded
    }
}
