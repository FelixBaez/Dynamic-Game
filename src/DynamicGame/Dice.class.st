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
Dice class >> sixWithSeed: aSeed [
	"Crea un dado de 6 caras, pero con un generador aleatorio fijado por una semilla (seed)"
	^ self new
		rng: (Random seed: aSeed);
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
