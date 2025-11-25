"
Dice representa uno o más dados utilizados por el juego.

Responsabilidades principales
- Mantener la cantidad de caras del dado (o dados) y, opcionalmente, su valor mínimo/máximo.
- Proveer la operación de lanzamiento (roll) que devuelve un valor aleatorio válido.
- Encapsular la fuente de aleatoriedad (Random) para facilitar pruebas y reproducibilidad si fuera necesario.

"
Class {
	#name : 'Dice',
	#superclass : 'Object',
	#instVars : [
		'faces',
		'rng',
		'lastRoll'
	],
	#category : 'DynamicGame',
	#package : 'DynamicGame'
}

{ #category : 'instance creation' }
Dice class >> six [ 
	^ self new 
	rng: Random;
	yourself 
]

{ #category : 'accessing' }
Dice >> faces [

	^ faces
]

{ #category : 'accessing' }
Dice >> faces: anObject [

	faces := anObject
]

{ #category : 'initialization' }
Dice >> initialize [
	super initialize.
	faces := #(1 2 3 4 5 6).
	"Por defecto usamos un Random sin seed fija, a menos que se cambie luego"
	rng:= Random new.
]

{ #category : 'accessing' }
Dice >> lastRoll [

	^ lastRoll
]

{ #category : 'accessing' }
Dice >> rng: anObject [

	rng := anObject
]

{ #category : 'actions' }
Dice >> roll [
	"Elige una cara aleatoriamente usando rng, actualiza lastRoll y devuelve resultado"
	|indice|
	indice:= rng nextInteger: faces size.
	
	lastRoll := faces at: indice.
	^lastRoll
	
]
