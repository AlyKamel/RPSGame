'use strict'

const express = require('express')
const app = express()
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// CORS
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*')
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept')
    next()
});

// Set up image upload
const multer = require('multer')
const upload = multer({
    limits: {
        fileSize: 1e6,
    },
    fileFilter(req, file, cb) {
        if (!file.originalname.toLowerCase().match(/\.(png|jpg|jpeg)$/)) {
            cb(new Error('Please upload an image.'))
        }
        cb(undefined, true)
    }
})

// Set up TensorFlow
const tf = require('@tensorflow/tfjs-node')
var model = loadModel()
async function loadModel() {
    model = await tf.loadLayersModel('file://ml-models/mle/model.json')
}

async function saveImage(data, name) {
    const fs = require('fs')
    fs.writeFile(name + '.png', data, 'binary', function (err) {
        if (err) {
            console.log("There was an error writing the image")
        }
    });
};

/////////////////////////////////////////////////////////////////////////////////////

// Start server
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Starting RPSGame server on port ${port}...`))

// initialize match and player array
var matches = [], players = []

app.get('/', (req, res) => res.send('RPSGame server is running'))

process.openStdin().addListener("data", (d) => {
    // delete all data stored on server
    if (d.toString().trim() === "delete_all") {
        matches = []
        players = []
        console.log("deleted all server data")
    }
})

// create player
app.post('/start', (req, res) => {
    const player = new Player(req.body.name)
    players.push(player)
    res.json(player)
})

// player creates (and joins) match
app.post('/matches', (req, res) => {
    const player = players.find(p => p.id == req.body.playerId)
    if (player === undefined) {
        res.status(400).json(new Error(8, 'Player not found'))
    } else {
        const match = new Match(req.body.gamecount)
        match.addPlayer(player)
        matches.push(match)

        if (req.body.botMatch)
            match.addPlayer(new Bot(`bot-m${match.id}`))

        res.json(match)
    }
})

// player joins match
app.post('/matches/:matchID/players/:playerID', (req, res) => {
    const player = players.find(p => p.id == req.params.playerID)
    const match = matches.find(m => m.id == req.params.matchID)
    
    if (match === undefined) {
        res.status(400).json(new Error(0, 'Match not found'))
    } else if (player === undefined) {
        res.status(400).json(new Error(8, 'Player not found'))
    } else if (match.players.length >= 2) {
        res.status(400).json(new Error(1, 'Maximum amount of players reached'))
    } else if (match.players.includes(player)) {
        res.status(400).json(new Error(2, 'Player has already joined the match'))
    } else {
        match.addPlayer(player)
        res.json(match)
    }
})

// player makes move (returns result)
app.post('/matches/:matchID/players/:playerID/play', (req, res) => {
    const move = Move.create(req.body.move)
    makeMove(move, req.params.playerID, req.params.matchID, res)
})

// player makes move (image) (returns result)
app.post('/matches/:matchID/players/:playerID/play_upload', upload.single('file'), (req, res) => {
    const modelInputWidth = model.input.shape[1];
    const modelInputHeight = model.input.shape[2];

    const imgbuff = req.file.buffer
    saveImage(imgbuff, 'before')

    var inputTensor = tf.node.decodeImage(imgbuff).div(255)
    inputTensor = tf.image.cropAndResize(tf.expandDims(inputTensor), [[0.05, 0.05, 0.95, 0.95]], [0], [modelInputWidth, modelInputHeight])
    
    // useful for debugging
    // const imgarr = await tf.node.encodeJpeg(tensor.squeeze().mul(255))
    // saveImage(Buffer.from(imgarr), 'after')

    const prediction = model.predict(inputTensor);
    const pred_array = prediction.arraySync()[0].map(x => x.toFixed(4))
    console.log('preds: ' + pred_array)

    const choiceIndex = prediction.argMax(1).dataSync()[0];
    const move = Move.create(choiceIndex)
    makeMove(move, req.params.playerID, req.params.matchID, res)
})

function makeMove(move, playerid, matchid, res) {
    const match = matches.find(m => m.id == matchid)
    if (match === undefined) {
        res.status(400).json(new Error(0, 'Match not found'))
        return
    }

    const player = match.players.find(p => p.id == playerid)
    if (player === undefined) {
        res.status(400).json(new Error(3, 'Player has not joined the match'))
    } else if (match.players.length < 2) { // second player hasn't joined
        res.status(400).json(new Error(6, 'Two players are required'))
    } else if (player.moveSelected) { // move reselected before other player made his move
        res.status(400).json(new Error(4, 'Move already entered'))
    } else if (move === null) {
        res.status(400).json(new Error(5, 'Invalid move'))
    } else {
        match.duelres = null // remove old result

        // calculate result and decrement duel count once
        if (match.players[0].id == player.id) {
            calcResult(match)
            match.duelcount--
        }

        player.makeMove(move)
        waitResult(match, function () {
            var ppos = match.players.findIndex(p => p.id == player.id)
            res.json({ 'match': match, 'duelresult': match.getDuelres(ppos), 'endresult': match.getEndres(ppos) })
        })
    }
}

// delete all player info after he logs out
app.post('/deleteme', (req) => {
    const playerIndex = players.findIndex(p => p.id == req.body.playerId)
    const matchIndex = matches.findIndex(m => m.id == req.body.matchId)

    players.splice(playerIndex, 1)
    if (matchIndex != -1)
        matches.splice(matchIndex, 1)

    console.log(`deleted player ${req.body.playerId} and match ${req.body.matchId}`)
})

/**
 * Wait until both players made their moves, then calculate the result. Deletes match if it has ended. 
 * @param {Match} match the match for which the result should be calculated
 */
function calcResult(match) {
    var _moveSelectionCheck = setInterval(() => {
        if (match.players.every(p => p.moveSelected)) { // both players made their move
            clearInterval(_moveSelectionCheck);

            const m1 = match.players[0].move
            const m2 = match.players[1].move
            match.duelres = Move.calcOutcome(m1, m2)
            match.players.forEach(p => p.moveSelected = false)

            match.players.forEach(p => match.print(`player ${p.name} used ${Move.getString(p.move)}`))
            match.print(`duel result: ${getResultText(match.getDuelres(0), match.players)}`)

            if (match.duelcount == 0) {
                match.print(`match result: ${getResultText(match.getEndres(0), match.players)}`)
                console.log(`match ${match.id} has ended`)

                // delete match if it has ended since more than 30s
                setTimeout(() => {
                    const index = matches.indexOf(match)
                    matches.splice(index, 1)
                }, 30 * 1000);
            }
        }
    }, 100);
}

function getResultText(res, players) {
    switch (res) {
        case 0: return "Tie"
        case 1: return players[0].name + " won"
        case -1: return players[1].name + " won"
    }
}

/**
 * Wait until the duelresult has been calculated 
 * @param {Match} match the match which the duelresult is waited for
 * @param {function(): void} callback function to execute after the calculation
 */
function waitResult(match, callback) {
    var _resultCheck = setInterval(() => {
        if (match.getDuelres(0) != null) {
            clearInterval(_resultCheck);
            callback()
        }
    }, 100);
}



// classes
class Match {
    static #matchIdCount = 0
    #endResCounter = 0
    #duelres = null

    constructor(duelcount) {
        this.id = Match.#matchIdCount++
        this.duelcount = duelcount
        this.players = []
        console.log(`match ${this.id} created with ${this.duelcount} duels`)
    }

    addPlayer(player) {
        this.players.push(player)
        this.print(`player ${player.name} has joined`)
    }

    getDuelres(playerPos){
        const mult = -2 * playerPos + 1
        return this.#duelres == null ? null : this.#duelres * mult
    }

    set duelres(res) {
        this.#duelres = res
        if (this.#duelres != null) { // not a delete operation
            this.#endResCounter += this.#duelres
        }
    }

    getEndres(playerPos) {
        const mult = -2 * playerPos + 1
        return Math.sign(this.#endResCounter) * mult
    }

    print(message) {
        console.log(`<match-${this.id}>: ${message}`)
    }
}

class Player {
    static #playerIdCount = 0
    #moveSelected = false

    constructor(name) {
        this.id = Number(Player.#playerIdCount++)
        this.name = name
        this.move = null
        console.log(`player ${this.name} (#${this.id}) has joined the server`)
    }

    makeMove(move) {
        this.move = move
        this.#moveSelected = true
    }

    get moveSelected() {
        return this.#moveSelected
    }

    set moveSelected(s) {
        this.#moveSelected = s
    }
}

class Bot extends Player {
    get moveSelected() {
        this.makeMove(Move.random())
        return true
    }

    set moveSelected(s) {
        super.moveSelected = s
    }
}

class Move {
    static #MoveNames = ['ROCK', 'PAPER', 'SCISSORS']
    static #MatchRes = { WIN: 1, LOSS: -1, TIE: 0 }

    static create(type) {
        return type >= 0 && type <= 2 ? type : null
    }

    static random() {
        return Move.create(Math.floor(Math.random() * 3))
    }

    /**
     * @returns {MatchResult} result of m1 against m2
     */
    static calcOutcome(m1, m2) {
        if (m1 == m2)
            return Move.#MatchRes.TIE;
        return m1 == (m2 + 1) % 3 ? Move.#MatchRes.WIN : Move.#MatchRes.LOSS
    }

    static getString(m) {
        return Move.#MoveNames[m]
    }
}

class Error {
    constructor(code, message) {
        this.code = code
        this.message = message
    }
}
