Class {
	#name : 'GameLauncherUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'nameInput',
		'colorDropList',
		'addButton',
		'playersList',
		'startButton',
		'playersCollection',
		'availableColors'
	],
	#category : 'DynamicGameUI',
	#package : 'DynamicGameUI'
}

{ #category : 'initialization' }
GameLauncherUI class >> open [
	<script>

	^ self new open
]

{ #category : 'private' }
GameLauncherUI >> colorNameFor: aColor [
	"Busca en nuestra lista el nombre del color seleccionado"
	^ (colorDropList items detect: [ :assoc | assoc value = aColor ] ifNone: [ 'Color' -> nil ]) key
]

{ #category : 'actions' }
GameLauncherUI >> connectPresenters [
	
	addButton action: [ 
		| nombre seleccion colorElegido nuevoJugador |
		nombre := nameInput text.
		seleccion := colorDropList selectedItem.
		
		(nombre isEmpty) ifTrue: [ self inform: '¡Falta el nombre!' ] ifFalse: [
			
			seleccion ifNil: [ self inform: '¡Ya no quedan colores disponibles!' ] ifNotNil: [
				
				colorElegido := seleccion value.
				nuevoJugador := Player name: nombre color: colorElegido.
				playersCollection add: nuevoJugador.
				playersList items: playersCollection.
				
				"EXCLUSIÓN DE COLOR"
				availableColors remove: seleccion.
				colorDropList items: availableColors.
				
				"Seleccionar el siguiente automáticamente si quedan"
				availableColors ifNotEmpty: [ colorDropList selectIndex: 1 ].
				
				
				nameInput text: ''; takeKeyboardFocus.
			]
		]
	].

	startButton action: [ 
		(playersCollection size < 2)
			ifTrue: [ self inform: 'Mínimo 2 jugadores.' ]
			ifFalse: [ 
				self delete. 
				DynamicGameUI openOn: (DynamicGame new startWith: playersCollection seed: 123456 maxTurns: 30).
			]
	].
]

{ #category : 'visualization' }
GameLauncherUI >> defaultLayout [
	^ SpBoxLayout newVertical
		spacing: 10;
		add: (SpBoxLayout newHorizontal
				add: (self newLabel label: 'Nuevo Jugador:') width: 100;
				yourself) 
			height: 20;
		add: (SpBoxLayout newHorizontal
				spacing: 5;
				add: nameInput;
				add: colorDropList width: 100;
				add: addButton width: 130;
				yourself) 
			height: 30;
		add: (self newLabel label: 'Lista de Jugadores:') height: 20;
		add: playersList; 
		add: startButton height: 50;
		yourself
]

{ #category : 'initialization' }
GameLauncherUI >> initializePresenters [
	playersCollection := OrderedCollection new.

	"Colores disponibles"
	availableColors := { 
		'Rojo' -> Color red.
		'Azul' -> Color blue.
		'Verde' -> Color green.
		'Amarillo' -> Color yellow.
		'Negro' -> Color black.
		'Violeta' -> Color purple.
		'Naranja' -> Color orange.
		'Rosa' -> Color pink.
		'Cyan' -> Color cyan.
		'Marrón' -> Color brown.
	} asOrderedCollection.

	nameInput := self newTextInput placeholder: 'Nombre del Jugador'.

	"Colección dinámica"
	colorDropList := self newDropList.
	colorDropList items: availableColors.
	colorDropList display: [ :assoc | assoc key ].
	colorDropList selectIndex: 1.

	addButton := self newButton label: 'Agregar Jugador'; icon: (self iconNamed: #add).
	
	playersList := self newList.
	playersList display: [ :p | p name, ' (', (self colorNameFor: p color), ')' ].

	startButton := self newButton label: 'INICIAR JUEGO'; icon: (self iconNamed: #smallDoIt).
	
	self connectPresenters.
]
