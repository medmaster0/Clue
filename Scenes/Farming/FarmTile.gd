extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var tile_index #the index of which child/tile is visible
var dirt_color #the color of the sprites (prim)
var wet_color #the color of the wet dirt (seco)
var water_color #the color of the water or plants (tert)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	randomize()
	
	tile_index = 0
	
	$BackTile.change_symbol(tile_index)
	$FrontTile.change_symbol(tile_index)
	
	#Pick a random dirt color...
	dirt_color = MedAlgo.generate_dirt_color()
	wet_color = MedAlgo.wet_dirt(dirt_color)
	water_color = MedAlgo.generate_water_color()
	$BackTile.change_color(dirt_color,wet_color,water_color)
	$FrontTile.change_color(dirt_color,wet_color,water_color)
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

#function to change the tile

func change_tile(in_tile_index):
	tile_index = in_tile_index
	$BackTile.change_symbol(tile_index)
	$FrontTile.change_symbol(tile_index)
	
func change_color(dirt_color,wet_color,water_color):
	$BackTile.change_color(dirt_color,wet_color,water_color)
	$FrontTile.change_color(dirt_color,wet_color,water_color)




func _on_GrowTimer_timeout():
	print("yo")
	print(tile_index)
	match(tile_index):
		8:
			print("heyyy")
			$BackTile.change_symbol(9)
			$FrontTile.change_symbol(9)
	
	pass # replace with function body
