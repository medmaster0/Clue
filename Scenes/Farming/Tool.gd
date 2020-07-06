extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var tile_index
#Tile Index Legend:
# 0 - HOE
# 1 - PLOUGH
# 2 - RAKE
# 3 - SCYTHE
# 4 - SHOVEL
# 5 - WHEELBARROW
# 6 - SEEDBAG

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	randomize()
	
	#pick a random tile_index
	tile_index = randi()%6
	#Turn on the proper tiles...
	$Prim.get_child(tile_index).visible = true
	$Seco.get_child(tile_index).visible = true
	
	#Need to color the sprites...
	#First get some colors fool...
	var prim_color = Color(randf(), randf(), randf())
	prim_color = MedAlgo.color_to_pastel(prim_color) #make the color a pastel
	var seco_color = MedAlgo.generate_brown()
	change_color(prim_color, seco_color)
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

#function to change the color of the proper tile
func change_color(color1, color2):
	$Prim.get_child(tile_index).modulate = color1
	$Seco.get_child(tile_index).modulate = color2

#Function to handle changing of tile types
#switches on and off the proper sprites
func change_tile(tile_type):
	
	#Preserve colors
	#if $Prim.get_child(tile_index).modulate() != null:
	var prim_col = $Prim.get_child(tile_index).modulate
	#if $Seco.get_child(tile_index).modulate() != null:
	var seco_col = $Seco.get_child(tile_index).modulate
	
	#First turn off the old sprites...
	$Prim.get_child(tile_index).visible = false
	$Seco.get_child(tile_index).visible = false
	
	#Turn on the new ones
	tile_index = tile_type
	$Prim.get_child(tile_index).visible = true
	$Seco.get_child(tile_index).visible = true
	
	#Change the colors on new sprites
	$Prim.get_child(tile_index).modulate = prim_col
	$Seco.get_child(tile_index).modulate = seco_col