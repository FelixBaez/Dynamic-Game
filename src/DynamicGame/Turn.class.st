Class {
	#name : 'Turn',
	#superclass : 'Object',
	#instVars : [
		'turnNumber',
		'turnPlayer',
		'turnRoll',
		'path',
		'eliminatedPlayers'
	],
	#category : 'DynamicGame',
	#package : 'DynamicGame'
}

{ #category : 'as yet unclassified' }
Turn class >> number: aNumber player: aPlayer roll: aValue [
	"Crea turno y asigna valores"
	^ self new
		initializeNumber: aNumber player: aPlayer roll: aValue;
		yourself.
]

{ #category : 'actions' }
Turn >> addElimination: aPlayer [
	"registra el jugador eliminado durante este turno"
	eliminatedPlayers add: aPlayer.

]

{ #category : 'actions' }
Turn >> addStep: aPoint [
	"registra un paso mas del camino que recorre el player"
	path add: aPoint.

]

{ #category : 'accessing' }
Turn >> eliminatedPlayers [

	^ eliminatedPlayers
]

{ #category : 'testing' }
Turn >> endPosition [ 
	"Devuelve el ultim punto registrado en el camino"
	path ifNotEmpty: [ ^ path last ].
	^ nil
]

{ #category : 'testing' }
Turn >> hasEliminations [
	^ eliminatedPlayers isNotEmpty 
]

{ #category : 'initialization' }
Turn >> initialize [ 
	super initialize.
	path := OrderedCollection new.
	eliminatedPlayers := OrderedCollection new.
	
]

{ #category : 'initialization' }
Turn >> initializeNumber: anInteger player: aPlayer roll: anIntegerRoll [
	"metodo aux para setear los valores iniciales que se reciben del const de class"
	turnNumber := anInteger .
	turnPlayer := aPlayer .
	turnRoll := anIntegerRoll .
]

{ #category : 'accessing' }
Turn >> path [

	^ path
]

{ #category : 'printing' }
Turn >> printOn: aStream [
	"Formato: turn 5: Benjamin (Roll: 4) -> [Path size: 4]"
	aStream 
		nextPutAll: 'Turn ';
		print: turnNumber;
		nextPutAll: ': ';
		nextPutAll: (turnPlayer ifNotNil: [ turnPlayer name ] ifNil: ['Desconocido']);
		nextPutAll: ' (Roll: ';
		print: turnRoll;
		nextPutAll: ')'.
		
	self hasEliminations ifTrue: [ 
		aStream nextPutAll: ' [ELIMINADO]'
	].
]

{ #category : 'testing' }
Turn >> startPosition [ 
	path ifNotEmpty: [ ^ path first ].
	^ nil
]

{ #category : 'testing' }
Turn >> stepsCount [
	"Devuelve la cantidad de pasos registrados"
	^ path size
]

{ #category : 'accessing' }
Turn >> turnNumber [

	^ turnNumber
]

{ #category : 'accessing' }
Turn >> turnPlayer [

	^ turnPlayer
]

{ #category : 'accessing' }
Turn >> turnRoll [

	^ turnRoll
]
