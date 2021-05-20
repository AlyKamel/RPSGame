import React from 'react'
import * as MI from './MoveImage'
import * as SC from './ServerConnection'

class MatchAction extends React.Component {
    selectMove = (event) => {
        const move = event.target.value
        const promise = SC.sendMove(this.props.matchID, this.props.userID, move)
        this.handleResult(promise)
    }

    uploadMove = (image) => {
        const promise = SC.uploadMove(this.props.matchID, this.props.userID, image)
        this.handleResult(promise)
    }

    handleResult = (promise) => {
        promise.then(res => {
                if (!res.ok)
                    return res.json().then(err => { throw err.message })
                return res.json()
            })
            .then((data) => {
                this.props.showResult(data.match, data.duelresult, data.endresult)
            })
            .catch(err => {
                alert(`unable to send move: ${err}`)
            })
    }

    render() {
        const moves = []
        for (var i = 0; i <= 2; ++i)
            moves.push(<MI.MoveImage move={i} key={i} handleClick={this.selectMove} />)

        return (
            <div class="container-fluid">
                <p>Select a move:</p>
                
                {moves}

                <br/>
                <p>Or upload a move:</p>
                <MoveUpload uploadMove={this.uploadMove}/>
                
                <br />
            </div>
        )
    }
}

// TODO: error with CORS
class MoveUpload extends React.Component {
    doUpload = () => {
        const file = document.querySelector('input[type="file"]').files[0];
        this.props.uploadMove(file)
    }

    render() {
        return (
            <form id="uploadForm" encType="multipart/form-data">
                <input name="file" type="file" accept="image/*" />
                <input type="button" value="Upload" onClick={this.doUpload} />
            </form>
        )
    }
}

export default MatchAction;