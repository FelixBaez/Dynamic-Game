"
Board modela el tablero de juego.

Responsabilidades principales
- Mantener la colección de casillas (SquareCell) que componen el tablero.
- Conocer sus dimensiones lógicas (por ejemplo, cantidad de filas/columnas o cantidad total de casillas).
- Proveer operaciones para acceder a una casilla dada una posición o índice.
- Ofrecer servicios de alto nivel para el juego, por ejemplo:
  - calcular la nueva casilla a partir de una posición y un desplazamiento,
  - responder si una posición es válida dentro del tablero.
"
Class {
	#name : 'Board',
	#superclass : 'Object',
	#instVars : [
		'rows',
		'cols',
		'cells',
		'occupants'
	],
	#category : 'DynamicGame',
	#package : 'DynamicGame'
}

{ #category : 'instance creation' }
Board class >> rows: aRows cols: aCols [
	^ self new 
	initializeRows: aRows cols: aCols;
	yourself 
]

{ #category : 'private - validation' }
Board >> assertDimensions [
	"Verifica que las dimensiones respeten las reglas del juego"
	((rows between: 5 and: 10) and: [cols between: 5 and: 10])
		ifFalse:[self error: 'Dimensiones inválidas. El tablero debe ser entre 5x5 y 10x10']
]

{ #category : 'initialization' }
Board >> buildGrid [
	"rellena el tablero de celdas vacías"
	1 to: rows do: [ :x |
		 1 to: cols do: [ :y | 
			cells at: (x @ y) put: SquareCell new]]
]

{ #category : 'accessing' }
Board >> cellAt: aPoint [
	"Devuelve el objeto SquareCell en la posicion del Point"
	^ cells at: aPoint
	
]

{ #category : 'initialization' }
Board >> initializeArrowsWith: rng [
	"Recorre las celdas y les asigna una dirección aleatoria usando el RNG"
	| directions |
	directions:= { #up . #down . #left . #right }.
	cells valuesDo: [ : cell | 
		cell direction: (directions at: (rng nextInteger: 4))]
]

{ #category : 'initialization' }
Board >> initializeRows: aRows cols: aCols [ 
	"Inicializa bojeto Board con rows y cols"
	super initialize. 
	rows:= aRows.
	cols:= aCols.
	
	self assertDimensions.
	
	cells:= Dictionary new.
	occupants:= Dictionary new.
	self buildGrid.

	
	
	
	
]

{ #category : 'testing' }
Board >> isBorder: aPoint [
	"Verifica si una posicion se encuentra en el borde del tablero"
	^ (aPoint x = 1) or: [ aPoint x = rows or: [ aPoint y = 1 or: [ aPoint y = cols ] ] ]
	
]

{ #category : 'testing' }
Board >> isInside: aPoint [
	"Verifica si una posición se encuentra dentro del tablero"
	^ (aPoint x between: 1 and: rows) and: [ aPoint y between: 1 and: cols ]
]

{ #category : 'player management' }
Board >> isOccupied: aPoint [
	"Devuelve true si hay un jugador en el Point"
	^ occupants includesKey: aPoint
]

{ #category : 'player management' }
Board >> movePlayer: aPlayer to: aTargetPoint [
	"Mueve un jugador de su posición actual a una nueva"
	self removePlayerAt: aPlayer position.
	self placePlayer: aPlayer at: aTargetPoint.
]

{ #category : 'accessing' }
Board >> nextPointFrom: aPoint [
	"Calcula la cordenada siguiente"
	^ aPoint + (self cellAt: aPoint) vector
	
	
]

{ #category : 'player management' }
Board >> occupantAt: aPoint [
	"Devuelve el jugador en el Point o nil si está vacío"
	^ occupants at: aPoint ifAbsent: [ nil ]
]

{ #category : 'player management' }
Board >> placePlayer: aPlayer at: aPoint [
	"Guarda al jugador en el diccionario de posiciones y actualiza al jugador"
	occupants at: aPoint put: aPlayer.
	aPlayer position: aPoint.
]

{ #category : 'player management' }
Board >> removePlayerAt: aPoint [
	"Saca al jugador del diccionario"
	occupants removeKey: aPoint ifAbsent: [  ]
	
]

{ #category : 'accessing' }
Board >> rotateCellAt: aPoint [
	"Busca la celda y la hace rotar"
	(self cellAt: aPoint) rotateRight.
	
	
]

{ #category : 'testing' }
Board >> willExitFrom: aPoint [
	"Verifica si al moverse el jugador saldría del tablero. Si está en el borde y la flecha apunta hacia afuera"
	|nextP|
	(self isBorder: aPoint) ifFalse: [ ^ false].
	
	nextP := self nextPointFrom: aPoint.
	
 ^ (self isInside: nextP) not
]
