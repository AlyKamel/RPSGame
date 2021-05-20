import React from 'react'
import MatchAction from './MatchAction'
import MatchVersus from './MatchVersus'
import * as MI from './MoveImage'

class MatchArena extends React.Component {
    constructor(props) {
        super(props)
        this.state = { moveChosen: false, match: this.props.match, winCount: 0, lossCount: 0, tieCount: 0, user: this.props.user}
        this.state.opponent = props.match.players.find(p => p.id !== this.props.user.id)
    }

    toActionView = () => {
        if (this.state.match.duelcount === 0) {
            this.props.endMatch(this.state.endresult)
        } else {
            this.setState({ moveChosen: false })
        }
    }

    showResult = (match, duelresult, endresult) => {
        this.setState({moveChosen: true, match: match,
            user: match.players.find(p => p.id === this.props.user.id),
            opponent: match.players.find(p => p.id !== this.props.user.id),
            endresult: endresult
        })

        switch (duelresult) {
            case 1: 
                this.setState(prevState => ({winCount: prevState.winCount + 1}))
                break
            case -1:
                this.setState(prevState => ({ lossCount: prevState.lossCount + 1 }))
                break
            case 0:
                this.setState(prevState => ({ tieCount: prevState.tieCount + 1 }))
                break
            default:
                throw Error('invalid result')
        }
    }

    render() {
        var view = ''
        if (!this.state.moveChosen)
            view = <MatchAction matchID={this.state.match.id} userID={this.props.user.id} showResult={this.showResult}/>
        else
            view = <MatchVersus user={this.state.user} opponent={this.state.opponent} afterResultShown={this.toActionView}/>

        const opponentText = this.state.opponent === undefined ? ' waiting for opponent...' : ' vs. Opponent ' + this.state.opponent.name

        return (
            <div>
                <p>Player {this.state.user.name + opponentText}</p>
                {view}
                <MI.MatchCounter matchID={this.state.match.id} winCount={this.state.winCount} lossCount={this.state.lossCount} tieCount={this.state.tieCount} />
            </div>
        );
    }
}

export default MatchArena;