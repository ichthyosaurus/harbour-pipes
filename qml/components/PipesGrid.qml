// This file is part of harbour-pipes.
// SPDX-FileCopyrightText: 2025 Mirian Margiani
// SPDX-FileCopyrightText: 2022 Arusekk
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Source.js" as Source

Rectangle {
    id: rectGrid

    property int connectedCount: 0

    onConnectedCountChanged: {
        if (connectedCount > 0 &&
                connectedCount === game.dimensionX * game.dimensionY) {
            game.win()
        }
    }

    function newGame() {
        connectedCount = 0
        game.pipeState.clear()
        worker.sendMessage({
            type: "new-game",
            model: game.pipeState,
            dimensionX: dimensionX,
            dimensionY: dimensionY,
        })
    }

    function scramblePipes() {
        worker.sendMessage({
            type: "scramble",
            model: game.pipeState
        })
    }

    function clearConnections() {
        // NOTE this is not done asynchronously in the worker script
        //      because syncing the model back takes too long for
        //      medium-large games (>20x20)

        connectedCount = 0

        for (var i = 0; i < game.dimensionY; i++) {
            for (var j = 0; j < game.dimensionX; j++) {
                Source.addConn(game.pipeAt(j, i), 0)
            }
        }

        checkConnections(pipeAt(game.dimensionX >> 1, game.dimensionY >> 1))
    }

    function checkConnections(pipe) {
        // NOTE this is not done asynchronously in the worker script
        //      because syncing the model back takes too long for
        //      medium-large games (>20x20)

        var pipes = [pipe]

        while (pipes.length) {
            pipe = pipes.pop()

            Source.addConn(pipe, 16)

            connectedCount++

            var neigh = Source.connectedNeigh(pipe, 16)

            for (var i = 0; i < neigh.length; i++) {
                var newpipe = neigh[i]
                Source.addConn(newpipe, 16)
                pipes.push(newpipe)
            }
        }
    }

    function tileClicked(index, state, inConnectedSet) {
        // NOTE this is not done asynchronously in the worker script
        //      because syncing the model back takes too long for
        //      medium-large games (>20x20)

        Source.doRotate(index, state)

        if (inConnectedSet) {
            clearConnections()
        } else {
            var neigh = Source.connectedNeigh(index, 0)

            if (neigh.length) {
                theGrid.checkConnections(index)
            }
        }
    }

    WorkerScript {
        id: worker
        source: Qt.resolvedUrl("worker.js")

        onMessage: {
            if (messageObject.type === 'new-game-ready' || messageObject.type === 'scramble-ready') {
                checkConnections(pipeAt(game.dimensionX >> 1, game.dimensionY >> 1))
            } else {
                console.error("[bug] unknown worker message received:")
                console.error(JSON.stringify(messageObject, null, 2))
            }
        }
    }

    Grid {
        anchors.fill: parent
        spacing: insideBorderSize
        columns: game.dimensionX

        Repeater {
            model: game.pipeState
            delegate: Component {
                Pipe {}
            }
        }
    }

    Connections {
        target: game

        onNewGame: newGame()
        onCheckConnections: clearConnections()
        onTileClicked: tileClicked(index, state, inConnectedSet)
    }
}
