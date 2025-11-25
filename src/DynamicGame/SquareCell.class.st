"
SquareCell representa una casilla individual del Board.

Responsabilidades principales
- Mantener la información asociada a una casilla:
  - direccion
- Rotarse cuando lo pida el board.
"
Class {
	#name : 'SquareCell',
	#superclass : 'Object',
	#instVars : [
		'direction'
	],
	#category : 'DynamicGame',
	#package : 'DynamicGame'
}

{ #category : 'instance creation' }
SquareCell class >> direction: aDirection [
    "Create a cell with the given direction (#up #right #down #left)."
    ^ self new initialize: aDirection;
	yourself
]

{ #category : 'instance creation' }
SquareCell class >> down [
    ^ self direction: #down
]

{ #category : 'instance creation' }
SquareCell class >> left [
    ^ self direction: #left
]

{ #category : 'instance creation' }
SquareCell class >> right [
    ^ self direction: #right
]

{ #category : 'instance creation' }
SquareCell class >> up [
    ^ self direction: #up
]

{ #category : 'accessing' }
SquareCell >> direction [
    ^ direction

]

{ #category : 'accessing' }
SquareCell >> direction: aSymbol [

	(#( #up #right #down #left ) includes: aSymbol) ifFalse: [
		self error: 'Dirección inválida: ' , aSymbol printString ].
	direction := aSymbol
]

{ #category : 'initialization' }
SquareCell >> initialize: aDirection [
	"Inicializa SquareCell"
	self direction: aDirection.
]

{ #category : 'printing' }
SquareCell >> printOn: aStream [
	aStream 
	nextPutAll: 'Direction: (';
	nextPutAll: direction asString;
	nextPutAll: ') '
	
]

{ #category : 'geometry' }
SquareCell >> rotateRight [
	"Rotate 90 degrees clockwise."
	direction := {
		             (#up -> #right).
		             (#right -> #down).
		             (#down -> #left).
		             (#left -> #up) }
		             at: direction
		             ifAbsent: [
		             self error:
			             'Invalid direction: ' , direction printString ]
]

{ #category : 'geometry' }
SquareCell >> vector [
	"Return the unit displacement (Δx@Δy) for this direction."
	"The origin is up-left, in the corner. The y axis grows down."

	direction = #up ifTrue: [ ^ 0 @ -1 ].
	direction = #right ifTrue: [ ^ 1 @ 0 ].
	direction = #down ifTrue: [ ^ 0 @ 1 ].
	direction = #left ifTrue: [ ^ -1 @ 0 ].
	self error: 'Invalid direction: ' , direction printString
]
