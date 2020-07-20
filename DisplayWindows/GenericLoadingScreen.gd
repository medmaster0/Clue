extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#STANDARD GAME SCENE GLOBALS
var world_width #the size of the map (in pixels)
var world_height #the size of the map (in pixels)
var map_width #the size of the map (in cells/tiles) SCREEN DIMS!!
var map_height #the size of the map (in cells/tiles) SCREEN DIMS!!
var background_color #The color of the background

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Screen Dimension stuff
	world_width = get_viewport().size.x
	world_height = get_viewport().size.y
	map_width = int($TileMap.world_to_map(Vector2(world_width,0)).x)
	map_height = int($TileMap.world_to_map(Vector2(0,world_height)).y)
	
	$BackSprite.scale = Vector2(map_width+16,map_height+16)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
