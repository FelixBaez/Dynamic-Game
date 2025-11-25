Class {
	#name : 'DynamicGame',
	#superclass : 'Object',
	#instVars : [
		'seed',
		'board',
		'players',
		'turnIndex',
		'rng',
		'dice',
		'turnNumber',
		'isOver',
		'winner',
		'maxTurns',
		'eliminationOrder',
		'moves'
	],
	#category : 'DynamicGame',
	#package : 'DynamicGame'
}

{ #category : 'as yet unclassified' }
DynamicGame >> advanceTurn [
	| startIndex |
	isOver ifTrue: [ ^self ]. "si termino, fin"
	players size == eliminationOrder size ifTrue:[ isOver := true. winner:= nil. ^self]. "Todos los jugadores eliminados, fin"
	startIndex := turnIndex .
	turnIndex := turnIndex + 1.
	turnIndex > players  size ifTrue: [ 
		turnIndex := 1  ].
	(players at: turnIndex isAlive) whileFalse: [ 
		turnIndex := turnIndex + 1.
		turnIndex > players size ifTrue: [ turnIndex := 1 ].
		turnIndex = startIndex ifTrue: [ isOver:= true. winner:= nil . ^self]
		].
^self
]

{ #category : 'as yet unclassified' }
DynamicGame >> checkEndCondition [
	|lastMove allAlivePlayers|
	lastMove := moves isEmpty ifTrue:[ nil ] ifFalse:[ moves last].
	allAlivePlayers:= self alivePlayers.
	allAlivePlayers size = 1 ifTrue: [ isOver:= true. winner:= allAlivePlayers first. ^self ]. "Queda uno vivo. Gana"
	(allAlivePlayers isEmpty and:[ lastMove notNil and: [ lastMove hasEliminations ]]) ifTrue: [ 
		isOver:= true. winner:= allAlivePlayers eliminatedPlayers last. ^self ]."No quedan vivos"
	turnNumber >= maxTurns ifTrue: [ isOver:= true.
		winner:= (allAlivePlayers size = 1) ifTrue:[ allAlivePlayers first ] ifFalse:[ nil ]. ^self ]."Se alcanzó maxturns. Falta definir desempate."
^self
]

{ #category : 'initialization' }
DynamicGame >> currentPlayer [
	|anyPlayer|
	players isEmpty ifTrue: [ self error: 'No hay jugadores.' ].
	(turnIndex < 1 or: [turnIndex > players size]) ifTrue: [self error: 'Turno fuera de rango'].
	anyPlayer := players at: turnIndex  .
	anyPlayer isAlive ifFalse: [ self error:'El jugador esta muerto. Se esperaba un jugador vivo.' ].
	^ anyPlayer 
]

{ #category : 'initialization' }
DynamicGame >> determineInitialOrderWithDice [
	"Determinar orden inicial de jugadores: ordenarlos en la collection."
	|pendientes ordenFinal |
	pendientes:= players copy.
	ordenFinal := OrderedCollection new.
	ordenFinal size < players size whileTrue: [
		|buckets empates|
		buckets := Dictionary new.
		pendientes do: [ :p ||k|
			k:= dice roll.
			(buckets at: k ifAbsentPut: [ OrderedCollection new ]) add: p].
		empates:= OrderedCollection new.
		(buckets keys asSortedCollection) do: [ :k | |group|
			group:= buckets at: k.
			group size = 1 ifTrue: [ordenFinal add: group first]
			ifFalse:[ empates addAll: group ]].
		pendientes:= empates].
	players := ordenFinal .
^self	
]

{ #category : 'as yet unclassified' }
DynamicGame >> playAtomicStepFor: aPlayer [
	"Maneja tres casos: fuera de tabero, celda libre y empuje en cadena."
	|from to|
	from := aPlayer position. "Origen"
	to := board nextPointFrom: from . "Destino"
	(board isInside: to) ifTrue: [ aPlayer eliminate. eliminationOrder add: aPlayer. self checkEndCondition ]. "Si sale, eliminar"
	(board isOccupied: to) ifTrue: [ self pushChainFrom: to . board movePlayer: aPlayer to: to. board rotateCellAt: from. ^self] "ocupado: empujar, mover y rotar"
	ifFalse: [ board movePlayer: aPlayer to: to. board rotateCellAt: from. ^self ] "Sin colisión: mover A y rotar origen"
	
]

{ #category : 'initialization' }
DynamicGame >> playOneTurn [
	"Juega un turno del currentPlayer."
	|p k turn |
	isOver ifTrue: [ ^self ].
	p:= self currentPlayer . "Llama al jugador vivo actual."
	k:= dice roll . "tira el dado"
	turn:= Turn number: turnNumber player: p roll: k. "Arma registro."
	k timesRepeat: [ 
		(p isAlive and: [ isOver not ]) ifTrue: [ 
			self playAtomicStepFor: p ].
		turn addStep: p position].
	moves add: turn. "guarda registro en moves"
	self advanceTurn."avanza un turno"
	self checkEndCondition."chequea cond final"
	^self
	
	
]

{ #category : 'as yet unclassified' }
DynamicGame >> pushChainFrom: aPoint [
	|from to current pushed|
	current:= aPoint .
	[ board isOccupiedAt: current ] whileTrue: ["mientras current esta ocup"
		pushed:= board occupantAt: current.
		from:= current.
		to:= board nextPointFrom: current.
		(board isInside: to) ifFalse: [ pushed eliminated. eliminationOrder add: pushed . board rotateCellAt: from . ^self]."sale del tablero, se elimina"
		(board isOccupiedAt: to) ifTrue: [ 
			current:= to ]"sigue cadena"
		ifFalse: [
			board movePlayer: pushed to: to. board rotateCellAt: from .^self]
		].
	^self
]

{ #category : 'initialization' }
DynamicGame >> startWith: someplayers on: aBoard seed: aSeed maxTurns: anInteger [
	"Verificar si los datos tienen sentido."
	((someplayers isEmpty) or:[maxTurns <= 0]) ifTrue: [self error:'Parámetros inválidos.'].
	players := someplayers asOrderedCollection ."Ingresar jugadores"
	board:= aBoard . "Establecer tablero de juego."
	seed:= aSeed ."Definir semilla."
	maxTurns:= anInteger ."Definir maximo nro de turnos."
	rng:= Random new seed: seed. "Generador nro aleat rng vinculado a la seed."
	dice:= Dice six. "Genera un dado a partir de seed."
	dice rng: rng. "Genera un numero aleatorio de ese dado a partir de rng."
	eliminationOrder := OrderedCollection new. "Estado inicial del juego. Colecc vacía."
	moves:= OrderedCollection new. "Colección vacía."
	isOver := false. "Final del juego = falso"
	winner:= nil."Sin ganador."
	turnIndex := 1. "Selecciona primer jugador."
	turnNumber := 1."Inicia primer turno"
	self determineInitialOrderWithDice. "Determinar orden inicial del juego."
	self placeAllPlayersRandomly.	"Posicionar jugadores en el tablero."
	
	

]
