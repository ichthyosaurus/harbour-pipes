// This file is part of harbour-pipes.
// SPDX-FileCopyrightText: 2025 Mirian Margiani
// SPDX-FileCopyrightText: 2022 Arusekk
// SPDX-License-Identifier: GPL-3.0-or-later

import "../components"
import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Rectangle {
        id: rectGrille

        color: Qt.rgba(0, 0, 0, 0.1)
        width: parent.width * 0.9
        height: width
        radius: width * 0.01
        transform: [
            Rotation {
                angle: 33
            },
            Scale {
                xScale: 2
                yScale: 2
            },
            Translate {
                x: width / 3
                y: width / 5
            }
        ]

        Grid {
            id: grille

            width: parent.width * 0.95
            height: width
            anchors.centerIn: parent
            spacing: 2
            columns: game.dimensionX
            visible: grille.children.length === game.dimensionX * game.dimensionY + 1

            Repeater {
                id: myRepeat

                model: game.pipeState

                Pipe {
                    enabled: false
                    width: (rectGrille.width - (game.dimensionX - 1) * 2) / game.dimensionX
                    height: width
                }
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: label.height + Theme.paddingMedium + label.anchors.bottomMargin
        radius: Theme.paddingMedium
        color: Theme.highlightDimmerColor
        opacity: Theme.opacityHigh
    }

    Label {
        id: label

        color: Theme.highlightColor
        text: new Date(null, null, null, null, null, game.time).toLocaleTimeString(Qt.locale(), "HH:mm:ss")

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }
    }
}
