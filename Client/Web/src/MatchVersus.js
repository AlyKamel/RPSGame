import React from 'react'
import * as MI from './MoveImage'

class MatchVersus extends React.Component {

    componentDidMount() {
        setTimeout(() => {
            this.props.afterResultShown()
        }, 1200);
    }

    render() {
        return (
            <div>
                <MI.MoveImage move={this.props.user.move} />
                &nbsp;&nbsp;
                
                <MI.MoveImage move={this.props.opponent.move} />
            </div>
        )
    }
}

export default MatchVersus;