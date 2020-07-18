extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


#RESOURCE load
var foxPrim = preload("res://Tiles/animals/foxPrim.png")
var foxSeco = preload("res://Tiles/animals/foxSeco.png")

var swanPrim = preload("res://Tiles/animals/swanPrim.png")
var swanSeco = preload("res://Tiles/animals/swanSeco.png")

var turtlePrim = preload("res://Tiles/animals/turtlePrim.png")
var turtleSeco = preload("res://Tiles/animals/turtleSeco.png")

var dragonPrim = preload("res://Tiles/animals/dragonPrim.png")
var dragonSeco = preload("res://Tiles/animals/dragonSeco.png")

var shroomPrim = preload("res://Tiles/animals/shroomPrim.png")
var shroomSeco = preload("res://Tiles/animals/shroomSeco.png")

#Class Variables
var primColor
var secoColor
var tertColor
var tile_index 
var creature_name #a string to be shown when selected

# Called when the node enters the scene tree for the first time.
func _ready():
		
	#Pick colors...
	primColor = Color(randf(), randf(), randf())
	secoColor = Color(1,1,1) #no modulation
	tertColor = Color(randf(), randf(), randf())
	
	#Set colors...
	$Prim.modulate = primColor
	$Seco.modulate = secoColor
	$Tert.modulate = tertColor
	
	#Pick random tile_index (set here for debug purposesssss)
	tile_index = randi()%5
	setTile(tile_index)
	

#CLASS FUNCS
func SetPrimColor(color):
	primColor = color
	$Prim.modulate = primColor
	
func SetSecoColor(color):
	secoColor = color
	$Seco.modulate = secoColor
	
func SetTertColor(color):
	tertColor = color
	$Tert.modulate = tertColor

func setTile(in_tile_index):
	tile_index = in_tile_index
	match tile_index:
		0:
			#SHROOM
			creature_name = "shroom"
			$Prim.texture = shroomSeco #YES I KNOW THESE ARE BACKWARDS!! $Seco never gets changed so...
			$Seco.texture = shroomPrim #YES I KNOW THESE ARE BACKWARDS!! $Seco never gets changed so...
			$Tert.texture = null
		1:
			#DRAGON
			creature_name = "dragon"
			$Prim.texture = dragonPrim
			$Seco.texture = dragonSeco
			$Tert.texture = null
		2:
			#SWAN
			creature_name = "swan"
			$Prim.texture = swanPrim
			$Seco.texture = swanSeco
			$Tert.texture = null
		3:
			#FOX
			creature_name = "fox"
			$Prim.texture = foxPrim
			$Seco.texture = foxSeco
			$Tert.texture = null
		4:
			#TURTLE
			creature_name = "turtle"
			$Prim.texture = turtlePrim
			$Seco.texture = turtleSeco
			$Tert.texture = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

