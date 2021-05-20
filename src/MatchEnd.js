import React from 'react'

class MatchEnd extends React.Component {
    render() {
        var resultText
        switch (this.props.result) {
            case 1:
                resultText = 'win'
                break
            case -1:
                resultText = 'lose'
                break
            case 0:
                resultText = 'tie'
                break
            default:
                throw new Error('invalid result')
        }

        return (
            <div>
                <p>Game Over. You {resultText}</p>
                <button onClick={this.props.toStartPage}>To start page</button>
            </div>
        );
    }
}

export default MatchEnd;