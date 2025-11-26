// This file is part of harbour-pipes.
// SPDX-FileCopyrightText: 2025 Mirian Margiani
// SPDX-FileCopyrightText: 2022 Arusekk
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.6
import Sailfish.Silica 1.0

Rectangle {
    id: root

    readonly property int connections: model.data & 15
    readonly property bool inConnectedSet: model.data & 16

    height: game.unitSize
    width: height
    color: game.tileBackgroundColor

    HighlightImage {
        source: root.connections > 0 ? "../images/pipe-%1.png?".arg(root.connections) : ""
        cache: true
        fillMode: Image.Stretch
        anchors.fill: parent
        color: root.inConnectedSet ? game.tileConnectedColor : game.tileDisconnectedColor
    }

    MouseArea {
        anchors.fill: parent
        onClicked: game.tileClicked(model.index, root.connections, inConnectedSet)
    }

}
