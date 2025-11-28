Class {
	#name : 'DynamicGameUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'game',
		'boardPresenter',
		'turnButton',
		'statusLabel',
		'lastRollLabel',
		'historyList'
	],
	#category : 'DynamicGameUI',
	#package : 'DynamicGameUI'
}

{ #category : 'initialization' }
DynamicGameUI >> defaultLayout [
	^ SpBoxLayout newHorizontal
		"Panel Izquierdo: El tablero se expande para ocupar el espacio"
		add: boardPresenter expand: true;
		"Panel Derecho: Una columna vertical con ancho fijo"
		add: (SpBoxLayout newVertical
				add: statusLabel height: 30;
				add: lastRollLabel height: 30;
				add: turnButton height: 60; "Botón grande como en el mockup"
				add: (self newLabel label: 'Historial:') height: 20;
				add: historyList; "El resto del espacio para el historial"
				spacing: 10; "Espacio entre elementos verticales"
				yourself)
		width: 250; "Ancho fijo para el panel derecho"
		spacing: 15; "Espacio entre los dos paneles principales"
		yourself
]

{ #category : 'actions' }
DynamicGameUI >> doPlayTurn [
	"Esta acción se ejecuta al hacer clic en el botón"

	"Validar si el juego terminó"
	game isOver ifTrue: [ 
		self inform: '¡El juego ha terminado! Ganador: ', (game winner ifNotNil: [:w| w name] ifNil: ['Nadie']).
		turnButton disable.
		^ self.
	].

	"1. Ejecutar la lógica del dominio"
	game playOneTurn.

	"2. Refrescar toda la interfaz con los nuevos datos"
	self updateView.

]

{ #category : 'drawing' }
DynamicGameUI >> drawBoardOn: aCanvas [
	"Este método se llama cada vez que boardView refresh se ejecuta"
	| cellShapes scale |
	
	"Limpiamos el canvas por si acaso"
	
	cellShapes := OrderedCollection new.
	scale := 60. "Tamaño base de las celdas"

	"1. DIBUJAR LAS CELDAS Y FLECHAS"
	"Iteramos fila por fila para que el grid layout funcione fácil"
	1 to: game board rows do: [ :row |
		1 to: game board cols do: [ :col |
			| point cell box arrow composite visualPoint |
			point := col @ row.
			cell := game board cellAt: point.
			
			"La caja gris de fondo"
			box := RSBox new 
				size: scale; 
				color: Color lightGray; 
				border: (RSBorder new color: Color gray; width: 2);
				cornerRadius: 5.
			
			"La flecha (un polígono simple)"
			arrow := RSPolygon new 
				points: { (-1 * scale / 4) @ (-1 * scale / 4) .  0 @ (scale / 3) . (scale / 4) @ (-1 * scale / 4) };
				color: Color black ;
				size: scale / 2.
				
			"Rotamos la flecha según la dirección lógica de la celda"
			"self rotateRight arrow direction: cell direction."

			"Combinamos caja y flecha en un solo objeto visual"
			composite := RSComposite new.
			composite add: box; add: arrow.
			"Guardamos la coordenada lógica en el modelo visual para usarla luego"
			composite model: point. 
			
			cellShapes add: composite.
		]
	].

	"Añadimos todas las celdas al canvas"
	aCanvas addAll: cellShapes.
	"Usamos un layout de grilla para ordenarlas automáticamente"
	RSGridLayout new lineItemsCount: game board cols; gapSize: 5; on: cellShapes.

	"2. DIBUJAR LOS JUGADORES ENCIMA"
	game players do: [ :player |
		player isAlive ifTrue: [
			| playerCircle targetCellShape |
			"Buscamos la forma visual que corresponde a la posición del jugador"
			targetCellShape := cellShapes detect: [ :shape | shape model = player position ].
			
			"Creamos el círculo del jugador"
			playerCircle := RSEllipse new
				size: scale * 0.1; "Un poco más chico que la celda"
				color: player color.
			
			"Lo ubicamos en la misma posición que la celda"
			playerCircle position: targetCellShape position.
			
			"Lo añadimos al canvas (se dibujará encima porque se añade al final)"
			aCanvas add: playerCircle.
		]
	].

	"Añadir controles básicos de zoom/paneo (opcional)"
	aCanvas @ RSCanvasController.

]

{ #category : 'initialization' }
DynamicGameUI >> initializePresenters [
	| players seed |
    "1. INICIALIZAR EL MODELO (Tu lógica)"
    game := DynamicGame new.
	seed := 123456.
	players := {
    (Player name: 'Ana' color: Color red).
    (Player name: 'Beto' color: Color blue).
    (Player name: 'Carla' color: Color green).
    } asOrderedCollection.
    "Configuración estándar: 2 jugadores, mapa 5x5, semilla fija"
    game := DynamicGame new
    startWith: players seed: seed maxTurns: 20.
    game placeAllPlayersRandomly.

   "2. CREAR LOS WIDGETS (La Vista)"
	
	"Área del tablero (Roassal)"
	boardPresenter := self instantiate: SpRoassalPresenter.
	"Le decimos que use nuestro método de dibujo personalizado"
	boardPresenter script: [ :canvas | self drawBoardOn: canvas ].

	"Panel derecho: Etiquetas"
	statusLabel := self newLabel.
	lastRollLabel := self newLabel label: 'Dado: -'.

	"Botón de acción"
	 turnButton := self newButton
		label: 'TIRAR DADO';
		icon: (self iconNamed: #smallDoIt); "Icono opcional"
		action: [ self doPlayTurn ]. "Conectamos el clic con el método de acción"

	"Lista de historial"
	historyList := self newList.
	"Configuramos cómo mostrar cada objeto 'Turn' en la lista"
	historyList display: [ :turn | 
		'T', turn turnNumber asString, ': ', turn turnPlayer name, 
		' (sacó ', turn turnRoll asString, ') terminó en ', turn endPosition asString ].

	"Actualizamos la vista por primera vez para mostrar el estado inicial"
	self updateView.
]

{ #category : 'updating' }
DynamicGameUI >> updateView [
	"Actualiza todos los widgets basándose en el estado actual del objeto 'game'"
	
	"Actualizar etiquetas"
	statusLabel label: 'Turno: ', game turnNumber asString, ' - Juega: ', game currentPlayer name.
	
	"Mostrar el último dado tirado (si hubo alguno)"
	game moves ifNotEmpty: [ 
		lastRollLabel label: 'Dado: ', game moves last turnRoll asString.
	].
	
	"Actualizar la lista del historial (mostrando el más reciente arriba)"
	historyList items: game moves reversed.
	
	"IMPORTANTE: Decirle a Roassal que redibuje el tablero"
	boardPresenter refresh.
]
