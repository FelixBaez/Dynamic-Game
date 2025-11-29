"
DynamicGameUI modela la interfaz visual del juego.
"
Class {
	#name : 'DynamicGameUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'game',
		'boardPresenter',
		'turnButton',
		'statusLabel',
		'lastRollLabel',
		'historyList',
		'winnerLabel'
	],
	#category : 'DynamicGameUI',
	#package : 'DynamicGameUI'
}

{ #category : 'instance creation' }
DynamicGameUI class >> openOn: aGameModel [
	| window |
	window := self new.
	window setModel: aGameModel.
	window open.
	^ window
]

{ #category : 'initialization' }
DynamicGameUI >> defaultLayout [
	^ SpBoxLayout newHorizontal
		"Panel Izquierdo: El tablero se expande para ocupar el espacio"
		add: boardPresenter expand: true;
		"Panel Derecho: Una columna vertical con ancho fijo"
		add: (SpBoxLayout newVertical
				add: statusLabel height: 60;
				add: lastRollLabel height: 30;
				add: turnButton height: 60; "Botón grande como en el mockup"
				add: (self newLabel label: 'Historial:') height: 20;
				add: historyList; "El resto del espacio para el historial"
				"--- NUEVO: Agregamos el label abajo con altura fija ---"
             add: winnerLabel height: 50;
				spacing: 10; "Espacio entre elementos verticales"
				yourself)
		width: 250; "Ancho fijo para el panel derecho"
		spacing: 5; "Espacio entre los dos paneles principales"
		yourself
]

{ #category : 'private' }
DynamicGameUI >> directionToDegrees: aSymbol [
	"toma una direccion y la convierte en grados para roassal"
	"comienza en la posicion UP cuando grado = 0"
	aSymbol = #up ifTrue: [ ^ 0 ].
	aSymbol = #right ifTrue: [ ^ 90 ].
	aSymbol = #down ifTrue: [ ^ 180 ].
	aSymbol = #left ifTrue: [ ^ 270 ].
]

{ #category : 'actions' }
DynamicGameUI >> doPlayTurn [
	"Acción del botón: Jugar turno, actualizar vista y manejar el fin del juego silenciosamente"

	"1. Si el juego ya estaba terminado, no hacemos nada"
	game isOver ifTrue: [ ^ self ].

	[
		"2. Intentamos jugar el turno"
		game playOneTurn.

		"3. Actualizamos la vista"
		self updateView.
		
		"Restauramos el color de estado normal"
		statusLabel color: Color black.

	] on: Error do: [ :excepcion | 
		"4. MANEJO DE ERRORES"

		game isOver 
			ifTrue: [ 

				self updateView.
			]
			ifFalse: [ 
				statusLabel label: '⛔ ', excepcion messageText.
				statusLabel color: Color red.
			].
	].
]

{ #category : 'drawing' }
DynamicGameUI >> drawBoardOn: aCanvas [
	| cellShapes scale arrowForm |

	cellShapes := OrderedCollection new.
	scale := 60.
	
	"imagen a utilizar en las celdas"
	arrowForm := (FileSystem workingDirectory / 'arrow.png') exists 
		ifTrue: [ ImageReadWriter formFromFileNamed: 'arrow.png' ]
		ifFalse: [ 
			"Fallback para colocar un icono en caso de no encontrar la img"
			self iconNamed: #arrowUp 
		].

	"RECORRER EL TABLERO"
	1 to: game board rows do: [ :row |
		1 to: game board cols do: [ :col |
			| point cell player box arrowBitmap composite colorFondo |
			
			point := col @ row.
			cell := game board cellAt: point.
			player := game board occupantAt: point.
			
		
			colorFondo := player 
				ifNil: [ Color white ] 
				ifNotNil: [ player color alpha: 0.3 ]. "Color pastel"

			box := RSBox new 
				size: scale; 
				color: colorFondo; 
				border: (RSBorder new color: Color black; width: 4).


			arrowBitmap := RSBitmap new.
			arrowBitmap form: arrowForm. 
			arrowBitmap size: scale * 0.15. 
			
			"Rotamos la imagen usando el convertidor"
			arrowBitmap rotateByDegrees: (self directionToDegrees: cell direction).

			"COMPOSICIÓN"
			composite := RSComposite new.
			composite add: box.         
			composite add: arrowBitmap. 
			composite model: point.
			
			cellShapes add: composite.
		]
	].

	aCanvas addAll: cellShapes.
	RSGridLayout new lineItemsCount: game board cols; gapSize: 0; on: cellShapes.

	aCanvas @ RSCanvasController.
]

{ #category : 'initialization' }
DynamicGameUI >> initializePresenters [
	| players seed dice |
    "----MODELO----"
    game := DynamicGame new.
	seed := 123456.
	players := {
    (Player name: 'Ana' color: Color red).
    (Player name: 'Beto' color: Color blue).
    } asOrderedCollection.

    game := DynamicGame new
    startWith: players seed: seed maxTurns: 20.
    game placeAllPlayersRandomly.
	
   "-----VISTA----"
	dice := (FileSystem workingDirectory / 'dice.png') exists 
		ifTrue: [ (ImageReadWriter formFromFileNamed: 'dice.png') scaledToSize: 50@50 ]
		ifFalse: [ self iconNamed: #objects ]. "Fallback si no hay imagen"
	
	"Área del tablero (Roassal)"
	boardPresenter := self instantiate: SpRoassalPresenter.
	"Le decimos que use nuestro método de dibujo personalizado"
	boardPresenter script: [ :canvas | self drawBoardOn: canvas ].

	"Panel derecho"
	statusLabel := self newLabel.
	lastRollLabel := self newLabel.

	"Botón de tirar dado"
	 turnButton := self newButton
		label: 'TIRAR DADO';
		icon: dice;
		action: [ self doPlayTurn ]. "Conectamos el clic con el método de acción"

	"Historial"
	historyList := self newList.
	
	"Configuramos cómo mostrar cada objeto 'Turn' en la lista"
	historyList display: [ :turn | 
    | destinoTexto |
    "Si endPosition es nil, escribimos MUERTO/ELIMINADO"
    destinoTexto := turn endPosition 
        ifNil: [ 'ELIMINADO' ] 
        ifNotNil: [ turn endPosition asString ].
        
    'T', turn turnNumber asString, ': ', turn turnPlayer name, 
    ' (sacó ', turn turnRoll asString, ') -> ', destinoTexto 
].
	
	"Actualizamos la vista por primera vez para mostrar el estado inicial"
	self updateView.
]

{ #category : 'initialization' }
DynamicGameUI >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'Juego Repulsor | G14'; initialExtent: 750@500.
	
]

{ #category : 'initialization' }
DynamicGameUI >> setModel: aGame [
	game:= aGame.
	self updateView.
]

{ #category : 'updating' }
DynamicGameUI >> updateView [
	"Actualiza la interfaz usando texto plano estándar"
	| currPlayerName lastRollText |
	
	"1. Obtener nombre del jugador actual (Protegido contra errores)"
	currPlayerName := [ game currentPlayer name ] 
		on: Error do: [ '---' ].

	"2. Actualizar etiquetas con texto simple"
	statusLabel label: 'Turno: ', game turnNumber asString, ' - Juega: ', currPlayerName.
	
	"3. Actualizar etiqueta del dado"
	lastRollText := game moves 
		ifEmpty: [ '-' ] 
		ifNotEmpty: [ game moves last turnRoll asString ].
		
	lastRollLabel label: 'Dado: ', lastRollText.

	"4. Actualizar lista y tablero"
	historyList items: game moves reversed.
	boardPresenter refresh.
	
	"5. Lógica de Ganador"
	game isOver ifTrue: [ 
		| nombre |
		nombre := game winner ifNotNil: [:w | w name] ifNil: ['Nadie'].
		
		"Cambiamos el botón gigante"
		turnButton label: 'GANADOR: ', nombre.
		turnButton icon: (self iconNamed: #thumbsUp). 

	].
]
