#This is a test to view the buildings from different views (birds eye and balcony)
# 1. Generate Building - all floors, etc.
# 2. Enter/Change a view
# -> Changing is a one time legnthy process
# -> Copy all sprites and align them onto proper CanvasLayers...
# ****Maybe instead, just keep two sets of Canvas Layers???
# 3. Scrolling across layers
# -> Sprites stored in proper CanvasLayer, cycle through and enable/disable as needed
# 4. Ambience (Ahhhhmmm=bee-ahhhnncee)
# -> However many canvas layers at a time. an alpha film int between each to provide distance haziness

extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#MEMBER VARIABLES
var building_layout = [] #The 3D tile layout of the building
var num_floors = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Generate the first floor
	var first_floor = RogueGen.GenerateMansion(Vector2(30,29))
	# Generate the other floors
	#for i in range(num_floors - 1):
		
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
