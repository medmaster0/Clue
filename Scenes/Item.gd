extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#MASTER ITEM LIST
# 0 - WEED
# 1 - STONE
# 2 - LADDER
# 3 - CAN
# 4 - LADDER HOLE
# 5 - FLAG
# 6 - POWDER

######## BUILDING ITEMS
# 101 - FLOOR
# 102 - WALL
# 103 - DOOR
# 104 - LADDER (HOLE)
# 105 - FLAG
# 106 - DESK
# 107 - KITCHEN FLOOR
# 108 - BOTTOM WINDOW
# 109 - TOP WINDOW
# 110 - FLOOR (BALCONY)

########### STREET ITEMS
# 201 - ROAD_CENTER_CORNER_INNER
# 202 - ROAD_CENTER_CORNER_OUTER
# 203 - ROAD_CENTER_MIDDLE
# 204 - ROAD_CENTER_TEE
# 205 - ROAD_CENTER_TURN
# 206 - ROAD_STRAIGHT
# 207 - ROAD_STRAIGHT_STOP_INNER
# 208 - ROAD_STRAIGHT_STOP_OUTER
# 209 - ROAD_TURN_INNER
# 210 - ROAD_TURN_OUTER
# 211 - SIDEWALK_BACK
# 212 - SIDEWALK_CORNER_BACK
# 213 - SIDEWALK_CORNER_INNER
# 214 - SIDEWALK_CORNER_OUTER
# 215 - SIDEWALK_FRONT
# 216 - SIDEWALK_INSIDE_CORNER_BACK

#LOAD UP ALL THE SPRITES>>>>

#Resources Load
var weedPrim = preload("res://Tiles//item//weedPrim.png")
var weedSeco = preload("res://Tiles//item//weedSeco.png")
var stonePrim = preload("res://Tiles//item//stonePrim.png")
var stoneSeco = preload("res://Tiles//item//stoneSeco.png")
var ladderPrim = preload("res://Tiles//item//ladderPrim.png")
var canPrim = preload("res://Tiles//item//canPrim.png")
var canSeco = preload("res://Tiles//item//canSeco.png")
var ladderHolePrim = preload("res://Tiles//scenery//ladderHolePrim.png")
var flagPrim = preload("res://Tiles//scenery//flagPrim.png")
var flagSeco = preload("res://Tiles//scenery//flagSeco.png")
var bagPrim = preload("res://Tiles//item//bagPrim.png")
var bagSeco = preload("res://Tiles//item//bagSeco.png")

#Building Resources Load
var floorPrim = preload("res://Tiles//scenery//adobePrim.png")
var floorSeco = preload("res://Tiles//scenery//adobeSeco.png")
var wallPrim = preload("res://Tiles//scenery//brickPrim.png")
var wallSeco = preload("res://Tiles//scenery//brickSeco.png")
var doorPrim = preload("res://Tiles//scenery//doorPrim.png")
var doorSeco = preload("res://Tiles//scenery//doorSeco.png")
var kitchenFloorPrim = preload("res://Tiles//scenery//kitchenFloorPrim.png")
var kitchenFloorSeco = preload("res://Tiles//scenery//kitchenFloorSeco.png")
var bottomWindowPrim = preload("res://Tiles//scenery//balcony//windowBotPrim.png")
var bottomWindowSeco = preload("res://Tiles//scenery//balcony//windowBotSeco.png")
var bottomWindowTert = preload("res://Tiles//scenery//balcony//windowBotTert.png")
var topWindowPrim = preload("res://Tiles//scenery//balcony//windowTopPrim.png")
var topWindowSeco = preload("res://Tiles//scenery//balcony//windowTopSeco.png")
var topWindowTert = preload("res://Tiles//scenery//balcony//windowTopTert.png")
var balconyFloorPrim = preload("res://Tiles//scenery//balcony/floor2DPrim.png")
var balconyFloorSeco = preload("res://Tiles//scenery//balcony/floor2DSeco.png")
var balconyKitchenFloorPrim = preload("res://Tiles//scenery//balcony/kitchenFloor2DPrim.png")
var balconyKitchenFloorSeco = preload("res://Tiles//scenery//balcony/kitchenFloor2DSeco.png")


#var ladderPrim
#var flagPrim
#var flagSeco

#Street Resources Load
var roadCenterCornerInnerPrim = preload("res://Tiles//street//RoadCenterCornerInnerPrim.png")
var roadCenterCornerInnerSeco = preload("res://Tiles//street//RoadCenterCornerInnerSeco.png")
var roadCenterCornerOuterPrim = preload("res://Tiles//street//RoadCenterCornerOuterPrim.png")
var roadCenterCornerOuterSeco = preload("res://Tiles//street//RoadCenterCornerOuterSeco.png")
var roadCenterMiddlePrim = preload("res://Tiles//street//RoadCenterMiddlePrim.png")
var roadCenterMiddleSeco = preload("res://Tiles//street//RoadCenterMiddleSeco.png")
var roadCenterTeePrim = preload("res://Tiles//street//RoadCenterTeePrim.png")
var roadCenterTeeSeco = preload("res://Tiles//street//RoadCenterTeeSeco.png")
var roadCenterTurnPrim = preload("res://Tiles//street//RoadCenterTurnPrim.png")
var roadCenterTurnSeco = preload("res://Tiles//street//RoadCenterTurnSeco.png")
var roadStraightPrim = preload("res://Tiles//street//RoadStraightPrim.png")
var roadStraightSeco = preload("res://Tiles//street//RoadStraightSeco.png")
var roadStraightStopInnerPrim = preload("res://Tiles//street//RoadStraightStopInnerPrim.png")
var roadStraightStopInnerSeco = preload("res://Tiles//street//RoadStraightStopInnerSeco.png")
var roadStraightStopOuterPrim = preload("res://Tiles//street//RoadStraightStopOuterPrim.png")
var roadStraightStopOuterSeco = preload("res://Tiles//street//RoadStraightStopOuterSeco.png")
var roadTurnInnerPrim = preload("res://Tiles//street//RoadTurnInnerPrim.png")
var roadTurnInnerSeco = preload("res://Tiles//street//RoadTurnInnerSeco.png")
var roadTurnOuterPrim = preload("res://Tiles//street//RoadTurnOuterPrim.png")
var roadTurnOuterSeco = preload("res://Tiles//street//RoadTurnOuterSeco.png")
var sidewalkBackPrim = preload("res://Tiles//street//SidewalkBackPrim.png")
var sidewalkBackSeco = preload("res://Tiles//street//SidewalkBackSeco.png")
var sidewalkCornerBackPrim = preload("res://Tiles//street//SidewalkCornerBackPrim.png")
var sidewalkCornerInnerPrim = preload("res://Tiles//street//SidewalkCornerInnerPrim.png")
var sidewalkCornerInnerSeco = preload("res://Tiles//street//SidewalkCornerInnerSeco.png")
var sidewalkCornerOuterPrim = preload("res://Tiles//street//SidewalkCornerOuterPrim.png")
var sidewalkCornerOuterSeco = preload("res://Tiles//street//SidewalkCornerOuterSeco.png")
var sidewalkFrontPrim = preload("res://Tiles//street//SidewalkFrontPrim.png")
var sidewalkFrontSeco = preload("res://Tiles//street//SidewalkFrontSeco.png")
var sidewalkInsideCornerBackPrim = preload("res://Tiles//street//SidewalkInsideCornerBackPrim.png")
var sidewalkInsideCornerBackSeco = preload("res://Tiles//street//SidewalkInsideCornerBackSeco.png")

#Class Variables
var primColor
var secoColor
var tertColor
var tile_index 
var item_name #a string to be shown when selected

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() 
	
	#Pick colors...
	primColor = Color(randf(), randf(), randf())
	secoColor = Color(randf(), randf(), randf())
	tertColor = Color(randf(), randf(), randf())
	
	#Set colors...
	$Prim.modulate = primColor
	$Seco.modulate = secoColor
	$Tert.modulate = tertColor
	
	#Pick random tile_index (set here for debug purposesssss)
	tile_index = 107
	setTile(tile_index)
	
	
	pass # Replace with function body.

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
			#WEED
			item_name = "weed"
			$Prim.texture = weedPrim
			$Seco.texture = weedSeco
			$Tert.texture = null
		1:
			#STONE
			item_name = "stone"
			$Prim.texture = stonePrim
			$Seco.texture = stoneSeco
			$Tert.texture = null
		2:
			#LADDER
			item_name = "ladder"
			$Prim.texture = ladderPrim
			$Seco.texture = null
			$Tert.texture = null
		3:
			#CAN
			item_name = "can"
			$Prim.texture = canPrim
			$Seco.texture = canSeco
			$Tert.texture = null
		4:
			#LADDER HOLE
			item_name = "ladder"
			$Prim.texture = ladderHolePrim
			$Seco.texture = null
			$Tert.texture = null
		5:
			#FLAG
			item_name = "flag"
			$Prim.texture = flagPrim
			$Seco.texture = flagSeco
			$Tert.texture = null
		6:
			#POWDER
			item_name = "powder"
			$Prim.texture = bagPrim
			$Seco.texture = bagSeco
			$Tert.texture = null
		######BUILDING SHIT
		101:
			#FLOOR
			item_name = "floor"
			$Prim.texture = floorPrim
			$Seco.texture = floorSeco
			$Tert.texture = null
		102:
			#WALL
			item_name = "wall"
			$Prim.texture = wallPrim
			$Seco.texture = wallSeco
			$Tert.texture = null
		103:
			#DOOR
			item_name = "door"
			$Prim.texture = doorPrim
			$Seco.texture = doorSeco
			$Tert.texture = null
		104:
			#LADDER HOLE
			item_name = "ladder down"
			$Prim.texture = ladderHolePrim
			$Seco.texture = null
			$Tert.texture = null
		105:
			#FLAG
			item_name = "flag"
			$Prim.texture = flagPrim
			$Seco.texture = flagSeco
			$Tert.texture = null
		107:
			#KITCHEN FLOOR
			item_name = "kitchen floor"
			$Prim.texture = kitchenFloorPrim
			$Seco.texture = kitchenFloorSeco
			$Tert.texture = null
		108:
			#BOTTOM WINDOW
			item_name = "window"
			$Prim.texture = bottomWindowPrim
			$Seco.texture = bottomWindowSeco
			$Tert.texture = bottomWindowTert
		109:
			#TOP WINDOW
			item_name = "window"
			$Prim.texture = topWindowPrim
			$Seco.texture = topWindowSeco
			$Tert.texture = topWindowTert
		110:
			#FLOOR (BALCONY)
			item_name = "floor"
			$Prim.texture = balconyFloorPrim
			$Seco.texture = balconyFloorSeco
			$Tert.texture = null
		111:
			#KITCHEN FLOOR (BALCONY)
			item_name = "kitchen floor"
			$Prim.texture = balconyKitchenFloorPrim
			$Seco.texture = balconyKitchenFloorSeco
			$Tert.texture = null
		######STREET SHIT
		201:
			#ROAD_CENTER_CORNER_INNER
			item_name = "road"
			$Prim.texture = roadCenterCornerInnerPrim
			$Seco.texture = roadCenterCornerInnerSeco
			$Tert.texture = null
		202:
			#ROAD_CENTER_CORNER_OUTER
			item_name = "road"
			$Prim.texture = roadCenterCornerOuterPrim
			$Seco.texture = roadCenterCornerOuterSeco
			$Tert.texture = null
		203:
			#ROAD_CENTER_MIDDLE
			item_name = "road"
			$Prim.texture = roadCenterMiddlePrim
			$Seco.texture = roadCenterMiddleSeco
			$Tert.texture = null
		204:
			#ROAD_CENTER_TEE
			item_name = "road"
			$Prim.texture = roadCenterTeePrim
			$Seco.texture = roadCenterTeeSeco
			$Tert.texture = null
		205:
			#ROAD_CENTER_TURN
			item_name = "road"
			$Prim.texture = roadCenterTurnPrim
			$Seco.texture = roadCenterTurnSeco
			$Tert.texture = null
		206:
			#ROAD_STRAIGHT
			item_name = "road"
			$Prim.texture = roadStraightPrim
			$Seco.texture = roadStraightSeco
			$Tert.texture = null
		207:
			#ROAD_STRAIGHT_STOP_INNER
			item_name = "road"
			$Prim.texture = roadStraightStopInnerPrim
			$Seco.texture = roadStraightStopInnerSeco
			$Tert.texture = null
		208:
			#ROAD_STRAIGHT_STOP_OUTER
			item_name = "road"
			$Prim.texture = roadStraightStopOuterPrim
			$Seco.texture = roadStraightStopOuterSeco
			$Tert.texture = null
		209:
			#ROAD_TURN_INNER
			item_name = "road"
			$Prim.texture = roadTurnInnerPrim
			$Seco.texture = roadTurnInnerSeco
			$Tert.texture = null
		210:
			#ROAD_TURN_OUTER
			item_name = "road"
			$Prim.texture = roadTurnOuterPrim
			$Seco.texture = roadTurnOuterSeco
			$Tert.texture = null
		211:
			#SIDEWALK_BACK
			item_name = "sidewalk"
			$Prim.texture = sidewalkBackPrim
			$Seco.texture = sidewalkBackSeco
			$Tert.texture = null
		212:
			#SIDEWALK_CORNER_BACK
			item_name = "sidewalk"
			$Prim.texture = sidewalkCornerBackPrim
			$Seco.texture = null
			$Tert.texture = null
		213:
			#SIDEWALK_CORNER_INNER
			item_name = "sidewalk"
			$Prim.texture = sidewalkCornerInnerPrim
			$Seco.texture = sidewalkCornerInnerSeco
			$Tert.texture = null
		214:
			#SIDEWALK_CORNER_OUTER
			item_name = "sidewalk"
			$Prim.texture = sidewalkCornerOuterPrim
			$Seco.texture = sidewalkCornerOuterSeco
			$Tert.texture = null
		215:
			#SIDEWALK_FRONT
			item_name = "sidewalk"
			$Prim.texture = sidewalkFrontPrim
			$Seco.texture = sidewalkFrontSeco
			$Tert.texture = null
		216:
			#SIDEWALK_INSIDE_CORNER_BACK
			item_name = "sidewalk"
			$Prim.texture = sidewalkInsideCornerBackPrim
			$Seco.texture = sidewalkInsideCornerBackSeco
			$Tert.texture = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#All this function does is pass itself to the parent Game
#By calling the funciton with itself
func _on_SelectButton_pressed():
	get_parent().DisplayItem(self)

#This function will disable the select button
func disableSelect():
	find_node("SelectButton").visible = false #need to disable button

#Function to rotate the items...
#Will preserve the position, but will change the sprite offsets
#Code:
# 0 - 0 degrees
# 1 - 90
# 2 - 180
# 3 - -90
# 4 - Flip H <>
# 5 - Flip V ^ v
# 6 - Flip Origin
# 7 - Flip Reverse Origin
func rotateSprites(rotation_code):
	
	match(rotation_code):
		0:
			#Adjust the rotation
			$Prim.rotation_degrees = 0
			$Seco.rotation_degrees = 0
			$Tert.rotation_degrees = 0
			#Adjust the offset 
			$Prim.offset = Vector2(0,0)
			$Seco.offset = $Prim.offset
			$Tert.offset = $Prim.offset
		1:
			#Adjust the rotation
			$Prim.rotation_degrees = 90
			$Seco.rotation_degrees = 90
			$Tert.rotation_degrees = 90
			#Adjust the offset 
			$Prim.offset = Vector2(0,-16)
			$Seco.offset = $Prim.offset
			$Tert.offset = $Prim.offset
		2:
			#Adjust the rotation
			$Prim.rotation_degrees = 180
			$Seco.rotation_degrees = 180
			$Tert.rotation_degrees = 180
			#Adjust the offset 
			$Prim.offset = Vector2(-16,-16)
			$Seco.offset = $Prim.offset
			$Tert.offset = $Prim.offset
		3:
			#Adjust the rotation
			$Prim.rotation_degrees = -90
			$Seco.rotation_degrees = -90
			$Tert.rotation_degrees = -90
			#Adjust the offset 
			$Prim.offset = Vector2(-16,0)
			$Seco.offset = $Prim.offset
			$Tert.offset = $Prim.offset
		4:
			#Flip Horizontal < >
			$Prim.flip_h = !$Prim.flip_h
			$Seco.flip_h = !$Seco.flip_h
			$Tert.flip_h = !$Tert.flip_h
		5:
			#Flip Vert ^ v
			$Prim.flip_v = !$Prim.flip_v
			$Seco.flip_v = !$Seco.flip_v
			$Tert.flip_v = !$Tert.flip_v
		6:
			#First flip, then rotate 90
			$Prim.flip_v = !$Prim.flip_v
			$Prim.rotation_degrees = 90
			$Prim.offset = Vector2(0,-16)
			$Seco.flip_v = !$Seco.flip_v
			$Seco.rotation_degrees = 90
			$Seco.offset = Vector2(0,-16)
			$Tert.flip_v = !$Tert.flip_v
			$Tert.rotation_degrees = 90
			$Tert.offset = Vector2(0,-16)
		7:
			#First flip, then rotate -90
			$Prim.flip_v = !$Prim.flip_v
			$Prim.rotation_degrees = -90
			$Prim.offset = Vector2(-16,0)
			$Seco.flip_v = !$Seco.flip_v
			$Seco.rotation_degrees = -90
			$Seco.offset = Vector2(-16,0)
			$Tert.flip_v = !$Tert.flip_v
			$Tert.rotation_degrees = -90
			$Tert.offset = Vector2(-16,0)