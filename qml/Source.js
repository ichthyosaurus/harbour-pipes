// This file is part of harbour-pipes.
// SPDX-FileCopyrightText: 2022 Arusekk
// SPDX-License-Identifier: GPL-3.0-or-later

.import "DB.js" as DB

function loadSave(save) {
	game.pipeState.clear()
	for (var i=0; i<save.length; i++)
		game.pipeState.append({data: save.charCodeAt(i) - 48})
}

function save(){
	if (game.dimensionX !== -1 && !game.won){
		DB.save(function(i, j){return game.pipeState.get(game.pipeAt(i, j)).data}, game.dimensionX, game.dimensionY)
		DB.setSavedTime(game.dimensionX, game.dimensionY, game.time)
	}
}


// vvvv Mirrored in worker.js, with adapted parameters vvvv //

var cCONN_UP = 1
var cCONN_RIGHT = 2
var cCONN_DOWN = 4
var cCONN_LEFT = 8
var cCONN_OVERFLOW = 17

function rotate(connections, clockwise) {
    if (clockwise) {
        connections <<= 1
        if (connections & cCONN_OVERFLOW)
            connections ^= cCONN_OVERFLOW
    }
    else {
        if (connections & cCONN_OVERFLOW)
            connections ^= cCONN_OVERFLOW
        connections >>= 1
    }
    return connections
}

function addConn(idx, v) {
    game.pipeState.set(idx, {data: (game.pipeState.get(idx).data & 15) | v})
}

// ^^^^ Mirrored in worker.js, with adapted parameters ^^^^ //


function connectedDeltas(gridX, gridY, connections, all) {
    var chk = []
    if (gridY > 0 &&
        (connections&cCONN_UP))
        chk.push([0, -1, cCONN_DOWN])
    if (gridX+1 < game.dimensionX &&
        ((connections&cCONN_RIGHT) || all))
        chk.push([1, 0, cCONN_LEFT])
    if (gridY+1 < game.dimensionY &&
        ((connections&cCONN_DOWN) || all))
        chk.push([0, 1, cCONN_UP])
    if (gridX > 0 &&
        ((connections&cCONN_LEFT) || all))
        chk.push([-1, 0, cCONN_RIGHT])
    return chk
}

function connectedNeigh(idx, inSet) {
    var gridX = idx % game.dimensionX
    var gridY = (idx - gridX) / game.dimensionX
    var deltas = connectedDeltas(gridX, gridY, game.pipeState.get(idx).data)
    var ret = []
    for (var i = 0; i < deltas.length; i++) {
        var delta = deltas[i]
        var neigh = game.pipeAt(gridX + delta[0], gridY + delta[1])
        var neighconn = game.pipeState.get(neigh).data;
        if ((neighconn & delta[2]) && (inSet ^ neighconn & 16))
            ret.push(neigh)
    }
    return ret
}

function doRotate(idx, state) {
    state = (state & 16) | rotate(state & 15, true)
    game.pipeState.set(idx, {data: state})
}
