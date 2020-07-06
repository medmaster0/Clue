extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var tile_index

var total_delta = 0
var wave_timer = 3

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	randomize()
	
	tile_index = randi() % 5
	change_tile(tile_index)
	
	wave_timer = rand_range(2.0,3.0)
	
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	
	total_delta = total_delta + delta
	if total_delta > wave_timer:
		flip_sprites()
		#also reset
		total_delta = total_delta - wave_timer
	
	pass

#change symbol, like wtf you want from me
func change_tile(new_tile_index):
	
	#Turn off old one...
	var temp_color1 = $Prim.get_child(tile_index).modulate #save the color
	$Prim.get_child(tile_index).visible = false
	$Seco.get_child(tile_index).visible = false
	var temp_color3 = $Prim.get_child(tile_index).modulate
	$Tert.get_child(tile_index).visible = false
	
	#Change to new one
	tile_index = new_tile_index
	$Prim.get_child(tile_index).visible = true
	$Prim.get_child(tile_index).modulate = temp_color1
	$Seco.get_child(tile_index).visible = true
	$Tert.get_child(tile_index).visible = true
	$Tert.get_child(tile_index).modulate = temp_color3

#function to change the color of the proper tiles
#color 1,2,3 --> Prim,Seco,Tert
func change_color(color1,color3):
	$Prim.get_child(tile_index).modulate = color1
	$Tert.get_child(tile_index).modulate = color3
	
#a function that handles the toggling of the sprites to give moving water illusion...
func flip_sprites():
	match(tile_index):
		0:
			scale.x = -scale.x
			position.x = position.x - (scale.x * 16)
			
		8:
			scale.x = -scale.x
			position.x = position.x - (scale.x * 16)


