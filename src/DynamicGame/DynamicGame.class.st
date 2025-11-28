"
DynamicGame modela una partida completa del juego de tablero.

Responsabilidades principales
- Crear y mantener los objetos principales del modelo: Board, Players, Dice y Turn actual.
- Gestionar el flujo de la partida:
  - iniciar el juego,
  - avanzar turnos,
  - coordinar tiradas de dados y movimientos sobre el Board,
  - aplicar las reglas particulares cuando un Player cae en una SquareCell.
- Determinar condiciones de fin de juego (por ejemplo, jugador ganador, empate, etc.).

Colaboradores
- Board: conoce la estructura del tablero y las casillas.
- Player: representa a cada participante del juego.
- Dice: usado para obtener resultados aleatorios de movimiento u otras acciones.
- Turn: encapsula la información de cada turno (quién juega, qué tirada se obtuvo, etc.).

Notas de diseño
- DynamicGame actúa como “fachada” del modelo: ofrece una interfaz de alto nivel para controlar y observar la partida sin exponer detalles internos.

"
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

{ #category : 'instance creation' }
DynamicGame class >> startWith: somePlayers seed: aSeed maxTurns: anInteger [
	^ self new
		startWith: somePlayers seed: aSeed maxTurns: anInteger;
		yourself
]

{ #category : 'running' }
DynamicGame >> advanceTurn [
	| startIndex |
	isOver ifTrue: [ ^self ]. "si termino, fin"
	players size == eliminationOrder size ifTrue:[ isOver := true. winner:= nil. ^self]. "Todos los jugadores eliminados, fin"
	turnNumber := turnNumber + 1.
	startIndex := turnIndex .
	turnIndex := turnIndex + 1.
	turnIndex > players  size ifTrue: [ 
		turnIndex := 1  ].
	[(players at: turnIndex) isAlive] whileFalse: [ 
		turnIndex := turnIndex + 1.
		turnIndex > players size ifTrue: [ turnIndex := 1 ].
		turnIndex = startIndex ifTrue: [ isOver:= true. winner:= nil . ^self]
		].
^self
]

{ #category : 'private' }
DynamicGame >> alivePlayers [
	|alivePl|
	players ifNil: [ ^ OrderedCollection new ].
	alivePl:= players select: [:pl | pl isAlive ].
^alivePl asOrderedCollection 
]

{ #category : 'accessing' }
DynamicGame >> board [

	^ board
]

{ #category : 'accessing' }
DynamicGame >> board: anObject [

	board := anObject
]

{ #category : 'private' }
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

{ #category : 'accessing' }
DynamicGame >> currentPlayer [
	|anyPlayer|
	players isEmpty ifTrue: [ self error: 'No hay jugadores.' ].
	(turnIndex < 1 or: [turnIndex > players size]) ifTrue: [self error: 'Turno fuera de rango'].
	anyPlayer := players at: turnIndex  .
	"anyPlayer isAlive ifFalse: [ self error:'El jugador esta muerto. Se esperaba un jugador vivo.' ]."
	^ anyPlayer 
]

{ #category : 'private' }
DynamicGame >> determineInitialOrderWithDice [
	"Determinar orden inicial de jugadores: ordenarlos en la collection."
	|pendientes ordenFinal |
	pendientes:= players copy.
	ordenFinal := OrderedCollection new.
	[ordenFinal size < players size] whileTrue: [
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

{ #category : 'accessing' }
DynamicGame >> dice [

	^ dice
]

{ #category : 'accessing' }
DynamicGame >> dice: anObject [

	dice := anObject
]

{ #category : 'accessing' }
DynamicGame >> eliminationOrder [

	^ eliminationOrder
]

{ #category : 'accessing' }
DynamicGame >> eliminationOrder: anObject [

	eliminationOrder := anObject
]

{ #category : 'accessing' }
DynamicGame >> isOver [

	^ isOver
]

{ #category : 'accessing' }
DynamicGame >> isOver: anObject [

	isOver := anObject
]

{ #category : 'accessing' }
DynamicGame >> maxTurns [

	^ maxTurns
]

{ #category : 'accessing' }
DynamicGame >> maxTurns: anObject [

	maxTurns := anObject
]

{ #category : 'accessing' }
DynamicGame >> moves [

	^ moves
]

{ #category : 'accessing' }
DynamicGame >> moves: anObject [

	moves := anObject
]

{ #category : 'private' }
DynamicGame >> placeAllPlayersRandomly [
	|validPositions safePosition|
	board ifNil: [ self error:'No hay tablero.' ].
	players ifEmpty: [ self error: 'No hay jugadores.' ].
	"Obtengo todas las celdas"
	validPositions := board allPointsInside asOrderedCollection.
	
	"Rechazamos las celdas desde las cuales uno saldria del tablero inmediatamente"
	safePosition := validPositions reject: [ :aPoint |
			board willExitFrom: aPoint.
		].
	
	"Actualizo lista para usar las seguras"
	validPositions := safePosition asOrderedCollection.
	
	"Valido la capacidad sobre las celdas SEGURAS"
	(players size > validPositions size) ifTrue: [ self error: 'El tablero es muy pequeño para albergar a todos los jugadores.' ].
	board resetOccupants.
	
	players do: [ :pl ||index pos|
		index:= rng nextInteger: validPositions size.
		pos:= validPositions removeAt: index.
		board placePlayer: pl at: pos ].
	^self
	
]

{ #category : 'private' }
DynamicGame >> playAtomicStepFor: aPlayer [
	"Maneja tres casos: fuera de tabero, celda libre y empuje en cadena."
	|from to|
	from := aPlayer position. "Origen"
	to := board nextPointFrom: from . "Destino"
	(board isInside: to) ifFalse: [ board removePlayerAt:from. aPlayer eliminate. eliminationOrder add: aPlayer. board rotateCellAt:from. self checkEndCondition. ^self ]. "Si sale, eliminar"
	(board isOccupied: to) ifTrue: [ self pushChainFrom: to . board movePlayer: aPlayer to: to. board rotateCellAt: from. ^self] "ocupado: empujar, mover y rotar"
	ifFalse: [ board movePlayer: aPlayer to: to. board rotateCellAt: from. ^self ] "Sin colisión: mover A y rotar origen"
	
]

{ #category : 'running' }
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

{ #category : 'accessing' }
DynamicGame >> players [

	^ players
]

{ #category : 'accessing' }
DynamicGame >> players: anObject [

	players := anObject
]

{ #category : 'private' }
DynamicGame >> pushChainFrom: aPoint [
	|from to current pushed|
	current:= aPoint .
	[ board isOccupied: current ] whileTrue: ["mientras current esta ocup"
		pushed:= board occupantAt: current.
		from:= current.
		to:= board nextPointFrom: current.
		(board isInside: to) ifFalse: [ pushed eliminate. eliminationOrder add: pushed . board rotateCellAt: from . ^self]."sale del tablero, se elimina"
		(board isOccupied: to) ifTrue: [ 
			current:= to ]"sigue cadena"
		ifFalse: [
			board movePlayer: pushed to: to. board rotateCellAt: from .^self]
		].
	^self
]

{ #category : 'private' }
DynamicGame >> randomPointInside [
	|x y|
	board ifNil: [ self error: 'No hay tablero.' ].
	x:= rng nextInteger: board cols.
	y:= rng nextInteger: board rows. 
^x@y
]

{ #category : 'accessing' }
DynamicGame >> rng [

	^ rng
]

{ #category : 'accessing' }
DynamicGame >> rng: anObject [

	rng := anObject
]

{ #category : 'running' }
DynamicGame >> runVisualDemo [
	"Ejecuta el juego completo reportando al Transcript paso a paso"

	Transcript open; clear.
	Transcript show: '===== INICIO DEMO VISUAL (Seed: ', seed asString, ') ====='; cr.
	Transcript show: board; cr.
	isOver := false.
	[ self isOver ] whileFalse: [ 
		| current startPos nextPos victim roll remaining |
		current := self currentPlayer.
		remaining := maxTurns - turnNumber.
		
		Transcript cr; show: '>>> TURNO #', turnNumber printString, 
					  ' (Restan: ', remaining printString, ') | Juega: ', current name; cr.

		"Tirar dado"
		roll := dice roll.
		Transcript show: '    Dado: ', roll asString; cr.

		"Ejecutar pasos atómicos con animación"
		roll timesRepeat: [ 
			(current isAlive and: [ isOver not ]) ifTrue: [
				startPos := current position.
				
				"Predicción para el Log"
				nextPos := board nextPointFrom: startPos.
				Transcript show: '    Moviendo: ', startPos asString, ' -> ', nextPos asString.
				
				(board isInside: nextPos) 
					ifTrue: [ 
						(board isOccupied: nextPos) ifTrue: [
							victim := board occupantAt: nextPos.
							Transcript show: ' [💥 COLISIÓN con ', victim name, ']'.
						]
					] 
					ifFalse: [ Transcript show: ' [☠️ SALIDA]' ].
				Transcript cr.

				"Ejecución"
				self playAtomicStepFor: current.
				
				"Visualización"
				Transcript show: board; cr.
			]
		].

		"Avanzar turno"
		self advanceTurn.
		self checkEndCondition.
	].

	Transcript show: '===== JUEGO TERMINADO ====='; cr.
	self winner 
		ifNotNil: [ :w | Transcript show: '🏆 GANADOR: ', w name; cr ]
		ifNil: [ Transcript show: '🏳️ EMPATE O TODOS ELIMINADOS'; cr ].
]

{ #category : 'accessing' }
DynamicGame >> seed [

	^ seed
]

{ #category : 'accessing' }
DynamicGame >> seed: anObject [

	seed := anObject
]

{ #category : 'running' }
DynamicGame >> startWith: someplayers seed: aSeed maxTurns: anInteger [
	"Verificar si los datos tienen sentido."
	((someplayers isEmpty) or:[anInteger <= 0]) ifTrue: [self error:'Parámetros inválidos.'].
	players := someplayers asOrderedCollection ."Ingresar jugadores"
	seed:= aSeed ."Definir semilla."
	maxTurns:= anInteger ."Definir maximo nro de turnos."
	dice:= Dice six: aSeed. "Genera un dado a partir de seed."
	rng:= dice rng.
	board:= Board rows: 5 cols: 5 rng: dice rng. "Establecer tablero de juego."
	eliminationOrder := OrderedCollection new. "Estado inicial del juego. Colecc vacía."
	moves:= OrderedCollection new. "Colección vacía."
	isOver := false. "Final del juego = falso"
	winner:= nil."Sin ganador."
	turnIndex := 1. "Selecciona primer jugador."
	turnNumber := 1."Inicia primer turno"
	self determineInitialOrderWithDice. "Determinar orden inicial del juego."
	self placeAllPlayersRandomly.	"Posicionar jugadores en el tablero."
	
	

]

{ #category : 'accessing' }
DynamicGame >> turnIndex [

	^ turnIndex
]

{ #category : 'accessing' }
DynamicGame >> turnIndex: anObject [

	turnIndex := anObject
]

{ #category : 'accessing' }
DynamicGame >> turnNumber [

	^ turnNumber
]

{ #category : 'accessing' }
DynamicGame >> turnNumber: anObject [

	turnNumber := anObject
]

{ #category : 'accessing' }
DynamicGame >> winner [
	isOver ifFalse: [ ^ nil ].
^winner
]

{ #category : 'accessing' }
DynamicGame >> winner: anObject [

	winner := anObject
]
