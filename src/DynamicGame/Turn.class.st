"
Turn modela un turno individual dentro de la partida.

Responsabilidades principales
- Registrar la información relevante de un turno:
  - qué Player está jugando,
  - resultado de la tirada de Dice,
  - posición de origen y de destino en el Board,
  - eventos especiales ocurridos durante el turno
- Proveer operaciones para acceder a esa información y, si corresponde, calcular algunos derivados (por ejemplo, desplazamiento total).
"
Class {
	#name : 'Turn',
	#superclass : 'Object',
	#instVars : [
		'turnNumber',
		'turnPlayer',
		'turnRoll',
		'path',
		'eliminatedPlayers',
		'events'
	],
	#category : 'DynamicGame',
	#package : 'DynamicGame'
}

{ #category : 'initialization' }
Turn class >> number: aNumber player: aPlayer roll: aValue [
	"Crea turno y asigna valores"
	^ self new
		initializeNumber: aNumber player: aPlayer roll: aValue;
		path: OrderedCollection new;
		eliminatedPlayers: OrderedCollection new;
		yourself.
]

{ #category : 'printing' }
Turn >> addCollisionWith: aPlayerName [
    events add: '💥 Choca a ', aPlayerName
]

{ #category : 'actions' }
Turn >> addElimination: aPlayer [
	"registra el jugador eliminado durante este turno"
	eliminatedPlayers add: aPlayer.

]

{ #category : 'actions' }
Turn >> addEvent: aString [
	"Registra un evento de texto en el historial del turno"
	events add: aString
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

{ #category : 'accessing' }
Turn >> eliminatedPlayers: anObject [

	eliminatedPlayers := anObject
]

{ #category : 'testing' }
Turn >> endPosition [ 
	"Devuelve el ultim punto registrado en el camino"
	path ifNotEmpty: [ ^ path last ].
	^ nil
]

{ #category : 'accessing' }
Turn >> events [

	^ events
]

{ #category : 'testing' }
Turn >> hasEliminations [
	^ eliminatedPlayers isNotEmpty 
]

{ #category : 'initialization' }
Turn >> initialize [ 
	super initialize.
	path := OrderedCollection new.
	events := OrderedCollection new.
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

{ #category : 'accessing' }
Turn >> path: anObject [

	path := anObject
]

{ #category : 'printing' }
Turn >> printOn: aStream [
	"Formato: Turno 5 (Ana): 1@1 -> 1@2 -> 2@2"
	
	aStream 
		nextPutAll: 'Turno '; print: turnNumber;
		nextPutAll: ' (';
		nextPutAll: (turnPlayer ifNotNil: [ turnPlayer name ] ifNil: ['?']);
		nextPutAll: ') Roll: '; print: turnRoll;
		nextPutAll: ' | Camino: '.
		
	path ifEmpty: [ aStream nextPutAll: 'Sin movimientos' ]
	     ifNotEmpty: [ 
			path do: [ :p | aStream print: p ] separatedBy: [ aStream nextPutAll: ' -> ' ] 
		].
		
	self hasEliminations ifTrue: [ aStream nextPutAll: ' [HUBO MUERTE]' ].
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
Turn >> turnNumber: anObject [

	turnNumber := anObject
]

{ #category : 'accessing' }
Turn >> turnPlayer [

	^ turnPlayer
]

{ #category : 'accessing' }
Turn >> turnPlayer: anObject [

	turnPlayer := anObject
]

{ #category : 'accessing' }
Turn >> turnRoll [

	^ turnRoll
]

{ #category : 'accessing' }
Turn >> turnRoll: anObject [

	turnRoll := anObject
]
