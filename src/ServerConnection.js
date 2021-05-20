
const rpsserver = "https://rps-game-server.herokuapp.com/" //"http://localhost:3000/"

function post(url, data) {
    return fetch(url, { method: "POST", body: data })
}

export function createPlayer(username, callback) {
    const params = new URLSearchParams({ name: username }); //x-www-form-urlencoded

    post(rpsserver + 'start', params)
    .then(res => res.json())
    .then(data => {
        console.log(data)
        callback(data)
    })
    .catch((err) => {
        alert('unable to create player: ' + err)
        return -1
    })
}

export function createMatch(userID, isOpponentBot, gamecount) {
    const params = new URLSearchParams({ gamecount: gamecount, playerId: userID })
    if (isOpponentBot)
        params.append('botMatch', true)
    return post(rpsserver + 'matches', params)
}

export function joinMatch(matchID, userID) {
    return post(`${rpsserver}matches/${matchID}/players/${userID}`)
}

export function sendMove(matchID, userID, move) {
    const params = new URLSearchParams({ move: move })
    return post(`${rpsserver}matches/${matchID}/players/${userID}/play`, params)
}


export function uploadMove(matchID, userID, image) {
    const url = `${rpsserver}matches/${matchID}/players/${userID}/play_upload`
    return fetch(url, { 
        method: "POST", 
        body: image
    })
}