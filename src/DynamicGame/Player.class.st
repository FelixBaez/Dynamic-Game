Class {
	#name : 'Player',
	#superclass : 'Object',
	#instVars : [
		'name',
		'color',
		'position',
		'alive'
	],
	#category : 'DynamicGame',
	#package : 'DynamicGame'
}

{ #category : 'initialization' }
Player class >> withName: aName color: aColor position: aPoint [ 
	"Crea e inicializa un nuevo jugador"
	
	^self new initializePlayer: aName color: aColor position: aPoint;
	yourself
]

{ #category : 'accessing' }
Player >> eliminate [
	"Modifica el atributo alive del objeto jugador a false"
	
	alive := false.
]

{ #category : 'accessing' }
Player >> getColor [

	^ color
]

{ #category : 'accessing' }
Player >> getName [

	^ name
]

{ #category : 'accessing' }
Player >> getPosition [

	^ position
]

{ #category : 'initialization' }
Player >> initializePlayer: aName color: aColor position: aPoint [
	"Inicializa Jugador"
	name := aName.
	color := aColor. 
	position := aPoint.
	alive := true.
	
]

{ #category : 'accessing' }
Player >> isAlive [ 

	^ alive
]

{ #category : 'accessing' }
Player >> setPosition: unPoint [
	
	position := unPoint
]
