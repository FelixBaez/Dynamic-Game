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

{ #category : 'accessing' }
Player >> color [

	^ color
]

{ #category : 'accessing' }
Player >> color: c [
	c isString ifFalse: [ self error: 'Formato de color inválido' ].
	color:= c.
]

{ #category : 'initialization' }
Player >> configureWithName: aName color: aColor position: aPoint [
	"Configura valor de atributos del jugador"
	self name: aName.
	self color: aColor. 
	position := aPoint.
	
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
	alive:= true.
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
	aString isString ifFalse: [ self error: 'Formato de nombre inválido: '].
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
		nextPutAll: ') ';
		nextPutAll: (alive ifTrue: [ ' alive ' ] ifFalse: [ ' dead ' ]).
	position ifNotNil: [ 
		aStream 
			nextPutAll: ' at '; 
			print: position ].
]
