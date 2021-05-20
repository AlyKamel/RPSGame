
export function MoveImage(props) {
    const name = NameFromMoveType(props.move)
    const path = '/resources/hand-' + name + '.png'
    return (
        <input type='image' src={path} alt={name} value={props.move} onClick={props.handleClick} />
    )
}

export function MatchCounter(props) {
    return (
        <p>
            MatchID <span>{props.matchID}</span>:
            Win: <span>{props.winCount}</span> |
            Loss: <span>{props.lossCount}</span> |
            Tie: <span>{props.tieCount}</span>
        </p>
    )
}

function NameFromMoveType(type) {
    const movenames = ['rock', 'paper', 'scissors']
    return movenames[type]
}