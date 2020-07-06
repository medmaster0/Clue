extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var tile_index #the index of which child/tile is visible

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	randomize()
	
	tile_index = randi()%$Prim.get_children().size()
	#get_child(tile_index).visible = true
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
	var temp_color3 = $Tert.get_child(tile_index).modulate #save the color
	$Tert.get_child(tile_index).visible = false
	
	#Change to new one
	tile_index = new_tile_index
	$Prim.get_child(tile_index).visible = true
	$Prim.get_child(tile_index).modulate = temp_color1
	$Seco.get_child(tile_index).visible = true
	$Seco.get_child(tile_index).modulate = temp_color2
	$Tert.get_child(tile_index).visible = true
	$Tert.get_child(tile_index).modulate = temp_color3
	

#function to change the color of the proper tiles
#color 1,2,3 --> Prim,Seco,Tert
func change_color(color1,color2,color3):
	$Prim.get_child(tile_index).modulate = color1
	$Seco.get_child(tile_index).modulate = color2
	$Tert.get_child(tile_index).modulate = color3
