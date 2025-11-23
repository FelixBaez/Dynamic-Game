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
Player class >> named: aName color: aColor position: aPoint [ 
	"Crea e inicializa un nuevo jugador"
	
	^self new initializePlayer: aName color: aColor position: aPoint;
	yourself
]

{ #category : 'accessing' }
Player >> color [

	^ color
]

{ #category : 'accessing' }
Player >> color: c [
	color:= c.
]

{ #category : 'accessing' }
Player >> eliminate [
	"Modifica el atributo alive del objeto Player a false y position a nil"
	
	position := nil.
	alive := false.
]

{ #category : 'initialization' }
Player >> initialize [
	super initialize.
	position:= nil.
	alive:= true.
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
Player >> name [

	^ name
]

{ #category : 'accessing' }
Player >> name: aString [
	name:= aString.
]

{ #category : 'accessing' }
Player >> position [

	^ position
]

{ #category : 'accessing' }
Player >> position: aPoint [
	
	position := aPoint
]

{ #category : 'printing' }
Player >> printOn: aStream [	
	aStream
		nextPutAll: 'Player (';
		nextPutAll: name asString;
		nextPutAll: ')';
		nextPutAll: (alive ifTrue: [ 'alive' ] ifFalse: [ 'dead' ]).
	position ifNotNil: [ 
		aStream 
			nextPutAll: 'at'; 
			print: position ].
]
