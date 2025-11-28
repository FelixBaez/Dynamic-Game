"
Player representa a un jugador o participante del juego.

Responsabilidades principales
- Mantener la información propia del jugador:
  - nombre o identificador,
  - posición actual en el Board,
  - estado (activo, eliminado, etc.), u otras estadísticas.
- Proveer operaciones para cambiar de posición o actualizar su estado de acuerdo a las reglas del juego.
- Ofrecer una representación legible del jugador para depuración o interfaz de usuario.
"
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

{ #category : 'instance creation' }
Player class >> name: aName color: aColor [
^ self new
	configureWithName: aName color: aColor;
	yourself 
]

{ #category : 'accessing' }
Player >> color [

	^ color
]

{ #category : 'accessing' }
Player >> color: aValue [
    "Setea el color del jugador. Acepta: una instancia de Color (p.ej., Color red), un Symbol o String con el nombre de un color definido (p.ej., #red, 'blue'). Lanza error si no puede convertir."
    | resolved |
    (aValue isKindOf: Color) ifTrue: [ color := aValue. ^ self ].
    (aValue isSymbol or: [ aValue isString ]) ifTrue: [
        | sel |
        sel := aValue asSymbol.
        (Color class canUnderstand: sel)
            ifTrue: [ 
                resolved := Color perform: sel.
                (resolved isKindOf: Color)
                    ifTrue: [ color := resolved. ^ self ] ].
        self error: 'Nombre de color inválido: ', aValue asString ].
    self error: 'Se esperaba un Color o el nombre de un color (String/Symbol).'

]

{ #category : 'initialization' }
Player >> configureWithName: aName color: aColor [
	"Configura valor de atributos del jugador"
	self name: aName.
	self color: aColor. 
	
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
