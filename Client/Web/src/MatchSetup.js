import React from 'react'
import * as SC from './ServerConnection'

class MatchSetup extends React.Component {
    constructor(props) {
        super(props)
        this.state = { loggedIn: false, matchEntryChosen: false, joinMatch: false, gamecount: 3, opponentType: 'bot'}
    }

    selectMatchEntry = (event) => {
        const joinMatch = event.target.value === 'joinMatch'
        this.setState({ matchEntryChosen: true, joinMatch: joinMatch})
    }

    handleChange = (event) => {
        const name = event.target.name
        this.setState({ [name]: event.target.value });
    }

    submit = (event) => {
        event.preventDefault()
        SC.createPlayer(this.state.username, (user) => {
            var promise
            if (this.state.joinMatch)
                promise = SC.joinMatch(this.state.matchID, user.id)
            else
                promise = SC.createMatch(user.id, this.state.opponentType === 'bot', this.state.gamecount)

            promise
                .then(res => {
                    if (!res.ok)
                        return res.json().then(err => { throw err.message })
                    return res.json()
                })
                .then(match => {
                    this.props.startMatch(match, user)
                })
                .catch(err => {
                    alert(`unable to ${this.state.joinMatch ? 'join' : 'create'} match: ${err}`)
                })
        })
    }

    render() {
        var matchEntry = ''
        if (this.state.matchEntryChosen) {
            if (this.state.joinMatch)
                matchEntry = <Numberfield name='matchID' changeHandler={this.handleChange} />
            else
                matchEntry = <div>
                    <OpponentSelector changeHandler={this.handleChange}/>
                    <GameCountSelector changeHandler={this.handleChange}/>
                </div>
        }

        return (
            <div>
                <h1>RPS Game</h1>
                <form onSubmit={this.submit}>
                    <Textfield name='username' changeHandler={this.handleChange} />
                    <br />

                    {matchEntry}

                    <br />

                    <JoinCreateMatch choiceMade={this.state.matchEntryChosen} joinMatch={false} onEntryChange={this.selectMatchEntry} />

                    <input
                        type='submit' disabled={!this.state.matchEntryChosen}
                    />
                </form>
            </div>
        )
    }
}

function Numberfield(props) {
    return (
        <label>
            {props.name}:
            <input
                name={props.name}
                type='number'
                min='0'
                onChange={props.changeHandler}
            />
        </label>
    )
}

function Textfield(props) {
    return (
        <label>
            {props.name}:
            <input
                name={props.name}
                type='text'
                maxLength='10'
                onChange={props.changeHandler}
            />
        </label>
    )
}

function OpponentSelector(props) {
    return (
        <div>
            <input type="radio" id="bot" name="opponentType" value="bot" defaultChecked onChange={props.changeHandler} />
            <label htmlFor="bot">Bot</label>
            <input type="radio" id="human" name="opponentType" value="human" onChange={props.changeHandler}/>
            <label htmlFor="human">Human</label>
        </div>
    )
}

function GameCountSelector(props) {
    return (
        <div>
            <label htmlFor="gamecount">Game count:</label>
            <input type="radio" id="1gamecount" name="gamecount" value={1} onChange={props.changeHandler}/>
            <label htmlFor="1gamecount">1</label>
            <input type="radio" id="3gamecount" name="gamecount" value={3} defaultChecked onChange={props.changeHandler}/>
            <label htmlFor="3gamecount">3</label>
            <input type="radio" id="10gamecount" name="gamecount" value={10} onChange={props.changeHandler}/>
            <label htmlFor="10gamecount">10</label><br />
        </div>
    )
}

function JoinCreateMatch(props) {
    return (
        <div>
            <input type="radio" id="joinMatch" name="enterMatch" value="joinMatch" onChange={props.onEntryChange}/>
            <label htmlFor="joinMatch">join match</label>
            <input type="radio" id="createMatch" name="enterMatch" value="createMatch" onChange={props.onEntryChange}/>
            <label htmlFor="createMatch">create match</label>
            <br />
        </div>
    )
}

export default MatchSetup;