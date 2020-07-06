extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var tile_index #keeps track of gate position

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	randomize()
	
	tile_index = randi()%2
	change_symbol(tile_index)
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func change_symbol(new_tile_index):
	
	#Turn off old one...
	var temp_color1 = $Prim.get_child(tile_index).modulate #save the color
	$Prim.get_child(tile_index).visible = false
	var temp_color2 = $Seco.get_child(tile_index).modulate #save the color
	$Seco.get_child(tile_index).visible = false
	
	#Change to new one
	tile_index = new_tile_index
	$Prim.get_child(tile_index).visible = true
	$Prim.get_child(tile_index).modulate = temp_color1
	$Seco.get_child(tile_index).visible = true
	$Seco.get_child(tile_index).modulate = temp_color2
	

#function to change the color of the proper tiles
#color 1,2,3 --> Prim,Seco,Tert
func change_color(color1,color2):
	$Prim.get_child(tile_index).modulate = color1
	$Seco.get_child(tile_index).modulate = color2