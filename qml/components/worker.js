// This file is part of harbour-pipes.
// SPDX-FileCopyrightText: 2025 Mirian Margiani
// SPDX-FileCopyrightText: 2022 Arusekk
// SPDX-License-Identifier: GPL-3.0-or-later

var _lc = "[Worker]"
var log = console.log.bind(console, _lc)
var warn = console.warn.bind(console, _lc)
var error = console.error.bind(console, _lc)


// vvvv Mirrored in Source.js, with adapted parameters vvvv //

var cCONN_UP = 1
var cCONN_RIGHT = 2
var cCONN_DOWN = 4
var cCONN_LEFT = 8
var cCONN_OVERFLOW = 17

function pipeAt(x, y, dimensionX) {
    return y * dimensionX + x
}

function addConnection(model, index, v) {
    model.set(index, {data: (model.get(index).data & 15) | v})
}

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

// ^^^^ Mirrored in Source.js, with adapted parameters ^^^^ //


function maybeConnectRandom(model, dimensionX, dimensionY, idx) {
    var connections = model.get(idx).data
    var gridX = idx % dimensionX
    var gridY = (idx - gridX) / dimensionX
    var chk = [], targ, targConn

    if (gridY > 0 && !(connections&cCONN_UP)) {
        targ = pipeAt(gridX, gridY-1, dimensionX)
        targConn = model.get(targ).data
        if (!(targConn & 16))
            chk.push([targ, cCONN_DOWN, cCONN_UP])
    }

    if (gridX+1 < dimensionX && !(connections&cCONN_RIGHT)) {
        targ = pipeAt(gridX+1, gridY, dimensionX)
        targConn = model.get(targ).data
        if (!(targConn & 16))
            chk.push([targ, cCONN_LEFT, cCONN_RIGHT])
    }

    if (gridY+1 < dimensionY && !(connections&cCONN_DOWN)) {
        targ = pipeAt(gridX, gridY+1, dimensionX)
        targConn = model.get(targ).data
        if (!(targConn & 16))
            chk.push([targ, cCONN_UP, cCONN_DOWN])
    }

    if (gridX > 0 && !(connections&cCONN_LEFT)) {
        targ = pipeAt(gridX-1, gridY, dimensionX)
        targConn = model.get(targ).data
        if (!(targConn & 16))
            chk.push([targ, cCONN_RIGHT, cCONN_LEFT])
    }

    if (!chk.length) {
        return
    }

    var i = Math.floor(Math.random() * chk.length)

    targ = chk[i][0]
    addConnection(model, targ, chk[i][1] | 16)
    addConnection(model, idx, chk[i][2] | 16)

    return targ
}


function rotateRandom(connections) {
    for (var i = Math.random()*4; i > 0; i -= 1) {
        connections = rotate(connections, true)
    }

    return connections
}

function scramblePipes(message) {
    log("scrambing pipes...")
    var model = message.model

    for (var i = 0; i < model.count; ++i) {
        var conn = model.get(i).data
        conn = (conn & 16) | rotateRandom(conn & 15)
        model.set(i, {data: conn})
    }

    for (var k = 0; k < model.count; ++k) {
        addConnection(model, k, 0)
    }

    model.sync()

    WorkerScript.sendMessage({type: 'scramble-ready'})
}

function newGame(message) {
    log("setting up new game...")
    var model = message.model
    var dimensionX = message.dimensionX
    var dimensionY = message.dimensionY

    model.clear()
    model.sync()

    for (var i = 0; i < dimensionY; i++) {
        for (var j = 0; j < dimensionX; j++) {
            model.append({data: 0})
        }
    }

    var disconnectedPipes = dimensionX * dimensionY - 1
    var pipe = pipeAt(dimensionX >> 1, dimensionY >> 1, dimensionX)

    addConnection(model, pipe, 16)
    var acceptablePipes = [pipe]

    while (disconnectedPipes > 0 && acceptablePipes.length) {
        var n = Math.floor(Math.random() * acceptablePipes.length)

        pipe = acceptablePipes[n]

        var newpipe = maybeConnectRandom(model, dimensionX, dimensionY, pipe)

        if (typeof newpipe === "undefined") {
            acceptablePipes[n] = acceptablePipes.pop()
        } else {
            acceptablePipes.push(newpipe)
            disconnectedPipes--
        }
    }

    scramblePipes(message)

    model.sync()

    WorkerScript.sendMessage({type: 'new-game-ready'})

    log("new game ready")
}

WorkerScript.onMessage = function(message) {
    if (!message || !message.hasOwnProperty('type')) {
        warn("bug: message has no type, got:\n", JSON.stringify(message, null, 2))
        return
    } else {
        log("message:\n", JSON.stringify(message, null, 2))
    }

    if (message.type === "scramble") {
        scramblePipes(message)
    } else if (message.type === "new-game") {
        newGame(message)
    } else {
        warn("bug: cannot handle unknown message type")
    }
}
