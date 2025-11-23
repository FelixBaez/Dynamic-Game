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
