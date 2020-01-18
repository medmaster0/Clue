extends Node2D

#Class for displaying Zodiac Symbols

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var tile_index = null #Keep track of which 

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	#Select a random tile
	tile_index = randi()%12
	change_symbol(tile_index)
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func change_symbol(new_tile_index):
	
	#Turn off old one...
	var temp_color = get_child(tile_index).modulate #save the color
	get_child(tile_index).visible = false
	
	#Change to new one
	tile_index = new_tile_index
	get_child(tile_index).visible = true
	get_child(tile_index).modulate = temp_color