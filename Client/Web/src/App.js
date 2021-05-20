import React from 'react'
import './App.css'
import MatchSetup from './MatchSetup'
import MatchArena from './MatchArena'
import MatchEnd from './MatchEnd'

class App extends React.Component {
  constructor(props) {
    super(props)
    this.state = { viewMode: 0, match: null, user: null, winCount: 0, lossCount: 0, tieCount: 0, endresult: null }
  }

  toMatchAction = (match, user) => {
    this.setState({ match: match, user: user, viewMode: 1})
  }

  toMatchEnd = (endresult) => {
    this.setState({viewMode: 2, endresult: endresult})
  }

  toStartPage = () => {
    this.setState({ match: null, user: null, winCount: 0, lossCount: 0, tieCount: 0, endresult: null, viewMode: 0 })
  }

  render() {
    var view = ''
    switch (this.state.viewMode) {
      case 0:
        view = <MatchSetup startMatch={this.toMatchAction} />
        break
      case 1:
        view = <MatchArena match={this.state.match} user={this.state.user} endMatch={this.toMatchEnd}/>
        break
      case 2:
        view = <MatchEnd result={this.state.endresult} toStartPage={this.toStartPage}/>
        break
      default:
        throw new Error('invalid state')
    }

    return (
      <div className="App">
        {view}
      </div>
    );
  }
}

export default App;
