Class {
	#name : 'DynamicGameTest',
	#superclass : 'TestCase',
	#instVars : [
		'game',
		'players'
	],
	#category : 'DynamicGame-Tests',
	#package : 'DynamicGame-Tests'
}

{ #category : 'running' }
DynamicGameTest >> setUp [
    super setUp.

    players := OrderedCollection new
        add: (Player name: 'Alice' color: Color red);
        add: (Player name: 'Bob'   color: Color blue);
        add: (Player name: 'Carol' color: Color green);
        yourself.

    game := DynamicGame
        startWith: players
        seed: 42
        maxTurns: 100.
]

{ #category : 'tests - turns' }
DynamicGameTest >> testAdvanceTurnCyclesBackToFirstPlayer [
    game turnIndex: game players size.

    game advanceTurn.

    self assert: game turnIndex equals: 1.
]

{ #category : 'tests - turns' }
DynamicGameTest >> testAdvanceTurnEndsGameWhenAllPlayersEliminated [
    "Simulamos el caso: todos los jugadores están en eliminationOrder."
    game eliminationOrder: game players copy.

    game advanceTurn.

    self assert: game isOver.
    self assert: game winner isNil.
]

{ #category : 'tests - turns' }
DynamicGameTest >> testAdvanceTurnIncrementsTurnNumber [
    | before after |
    before := game turnNumber.

    game advanceTurn.

    after := game turnNumber.
    self assert: after equals: before + 1.
]

{ #category : 'tests - turns' }
DynamicGameTest >> testAdvanceTurnSkipsDeadPlayers [
    | next |
    (game players second) alive: false.

    game turnIndex: 1.
    game advanceTurn.

    next := game currentPlayer.

    self deny: next equals: (game players second).
]

{ #category : 'tests - helper' }
DynamicGameTest >> testAlivePlayersFiltersByIsAlive [
    | firstPlayer alive |
    firstPlayer := game players first.

    firstPlayer alive: false.  "lo marcamos muerto"

    alive := game alivePlayers.

    self deny: (alive includes: firstPlayer).
    self assert: (alive allSatisfy: [:pl | pl isAlive]).
]

{ #category : 'tests - game over' }
DynamicGameTest >> testCheckEndConditionEndsGameAtMaxTurnsWithoutWinnerIfSeveralAlive [
    "Dejamos al menos dos vivos"
    (game players first) alive: true.
    (game players second) alive: true.

    game turnNumber: game maxTurns.

    game checkEndCondition.

    self assert: game isOver.
    self assert: game winner isNil.
]

{ #category : 'tests - game over' }
DynamicGameTest >> testCheckEndConditionWithSingleAlivePlayerSetsWinner [
    | survivor |
    "Marcamos a todos muertos salvo uno"
    game players do: [:pl | pl alive: false ].
    survivor := game players first.
    survivor alive: true.

    game checkEndCondition.

    self assert: game isOver.
    self assert: game winner equals: survivor.
]

{ #category : 'tests - turns' }
DynamicGameTest >> testCurrentPlayerMatchesTurnIndexAndIsAlive [
    | p |
    p := game currentPlayer.

    self assert: p equals: (game players at: game turnIndex).
    self assert: p isAlive.
]

{ #category : 'tests - turns' }
DynamicGameTest >> testCurrentPlayerRaisesErrorWhenTurnIndexOutOfRange [
    game turnIndex: 0.

    self
        should: [ game currentPlayer ]
        raise: Error.
]

{ #category : 'tests - set up order and placement' }
DynamicGameTest >> testInitialOrderIsPermutationOfPlayers [
    | ordered originalSet |
    ordered := game players.
    originalSet := players asSet.

    self assert: ordered size equals: players size.
    self assert: ordered asSet equals: originalSet.
]

{ #category : 'tests - playOneTurn' }
DynamicGameTest >> testPlayOneTurnAddsTurnToMoves [
    | before after |
    before := game moves size.

    game playOneTurn.

    after := game moves size.
    self assert: after equals: before + 1.
]

{ #category : 'tests - playOneTurn' }
DynamicGameTest >> testPlayOneTurnDoesNothingWhenGameIsOver [
    | beforeMoves beforeTurnNumber |
    game isOver: true.

    beforeMoves := game moves copy.
    beforeTurnNumber := game turnNumber.

    game playOneTurn.

    self assert: game moves size equals: beforeMoves size.
    self assert: game turnNumber equals: beforeTurnNumber.
]

{ #category : 'tests - playOneTurn' }
DynamicGameTest >> testPlayOneTurnUsesCurrentPlayerInTurnRecord [
    | playerBefore lastTurn |
    playerBefore := game currentPlayer.

    game playOneTurn.
    lastTurn := game moves last.

    self assert: lastTurn turnPlayer equals: playerBefore.
]

{ #category : 'tests - set up order and placement' }
DynamicGameTest >> testPlayersArePlacedInsideBoardOnSafeCells [
    | b |
    b := game board.

    game players do: [:pl |
        self assert: (b isInside: pl position).
        self deny: (b willExitFrom: pl position).
    ].
]

{ #category : 'tests - set up order and placement' }
DynamicGameTest >> testRandomPointInsideProducesValidBoardPoints [
    | b p |
    b := game board.

    50 timesRepeat: [
        p := game randomPointInside.
        self assert: (b isInside: p).
    ].
]

{ #category : 'testing - initialization' }
DynamicGameTest >> testStartWithInitialState [
    | gamePlayers b |
    b := game board.
    gamePlayers := game players.

    self assert: gamePlayers size equals: players size.
    players do: [:each | self assert: (gamePlayers includes: each)].

    self assert: game seed equals: 42.
    self assert: game maxTurns equals: 100.

    self assert: game dice notNil.
    self assert: game rng notNil.
    self assert: b notNil.

    self deny: game isOver.
    self assert: game winner isNil.
    self assert: game eliminationOrder isEmpty.
    self assert: game moves isEmpty.

    self assert: game turnIndex equals: 1.
    self assert: game turnNumber equals: 1.

]

{ #category : 'testing - initialization' }
DynamicGameTest >> testStartWithRequiresAtLeastOnePlayer [
    self
        should: [ DynamicGame
                    startWith: #()
                    seed: 1
                    maxTurns: 10 ]
        raise: Error.
]

{ #category : 'testing - initialization' }
DynamicGameTest >> testStartWithRequiresPositiveMaxTurns [
    self
        should: [ DynamicGame
                    startWith: players
                    seed: 1
                    maxTurns: 0 ]
        raise: Error.
]
