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

export (PackedScene) var Item
export (PackedScene) var BattleHuntItem

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#CONSTANTS
enum VIEW_MODE{
	birdseye,
	balcony
}

#MEMBER VARIABLES
var building_layout = [] #The 3D tile layout of the building
# ACCESS IS: building_layout[z_floor][x][y]
var num_floors = 20
var num_x_layers = 50
var num_y_layers = 30
var view_cursor_position = Vector3(0,0,0) #where we are currently viewing... x, y, z
var view_mode = VIEW_MODE.birdseye #start in birds eye view

#STANDARD GAME SCENE GLOBALS
var world_width #the size of the map (in pixels)
var world_height #the size of the map (in pixels)
var map_width #the size of the map (in cells/tiles) SCREEN DIMS!!
var map_height #the size of the map (in cells/tiles) SCREEN DIMS!!
var background_color #The color of the background

#Building Specific
var brick_color_prim
var brick_color_seco
var basic_floor_color_prim
var basic_floor_color_seco
var basic_door_color_prim
var basic_door_color_seco
var kitchen_floor_color_prim
var kitchen_floor_color_seco
var personal_room_furniture_prim
var personal_room_furniture_seco
var public_room_furniture_prim
var public_room_furniture_seco
var window_prim
var foliage_prim
var foliage_seco

##Distance Shade  Sprites
#Initialize Distance Shade Sprites
#This is an array of sprites to give the distance depth effect
#An array of sprites stretched out to screen
#Transparency to 1/15th 
#Color is same as background
#Layers stacked across z layers
#These shouldn't change during the course of things...
var distanceShadeSprites = []

#Store Canvas Layers
#Here is the tricky part: There are list of node2D's. Each Node2D has canvas layer
#Basically, each node is a wrapper for the canvas layer
#We use it to turn off each of the canvas layers quickly
var birdseyeLayers = []
var balconyXZLayers = [] 

#Control Stuff
var balcony_begin_position 


# Called when the node enters the scene tree for the first time.
func _ready():
	
	randomize()
	
	####### COLOR INITIALIZATION
	brick_color_prim = Color(randf(), randf(), randf())
	brick_color_seco = Color(randf(), randf(), randf())
	basic_floor_color_prim = Color(randf(), randf(), randf())
	basic_floor_color_seco = Color(randf(), randf(), randf())
	basic_door_color_prim = Color(randf(), randf(), randf())
	basic_door_color_seco = Color(randf(), randf(), randf())	
	kitchen_floor_color_prim = Color(randf(), randf(), randf())
	kitchen_floor_color_seco = Color(randf(), randf(), randf())
	personal_room_furniture_prim = Color(randf(), randf(), randf())
	personal_room_furniture_seco = Color(randf(), randf(), randf())
	public_room_furniture_prim = Color(randf(), randf(), randf())
	public_room_furniture_seco = Color(randf(), randf(), randf())
	window_prim = Color(randf(), randf(), randf(), 0.7)
	#background_color = Color(randf(), randf(), randf())
	background_color = MedAlgo.generate_darkenable_color(0.3)
	background_color = MedAlgo.color_shift(background_color,-0.3)
	foliage_prim = Color(randf(), randf(), randf(), 0.7)
	foliage_seco = Color(randf(), randf(), randf())
	
	#DEBUG
	#window_prim = Color(1,1,1)
	
	#Screen Dimension stuff
	world_width = get_viewport().size.x
	world_height = get_viewport().size.y
	map_width = int($TileMap.world_to_map(Vector2(world_width,0)).x)
	map_height = int($TileMap.world_to_map(Vector2(0,world_height)).y)
	
	####### POSITION INITIALIZATION
	balcony_begin_position = Vector2(30*($TileMap.cell_size.x),30*($TileMap.cell_size.y))
	
#	# Generate the first floor
#	var first_floor = RogueGen.GenerateMansion(Vector2(num_x_layers,num_y_layers))
#	building_layout.append(first_floor)
#	building_layout[0] = RogueGen.MansionWindowGen(building_layout[0], 10)
#	# Generate the other floors
#	for i in range(num_floors - 1):
#		var new_room = RogueGen.GenerateMansionFloor(first_floor, 5, 2)
#		building_layout.append(new_room)
#		building_layout[i+1] = RogueGen.MansionWindowGen(building_layout[i+1],10)

	#Generate a field of foliage... It will go around the building
	#First make an empty map
	var field_map = RogueGen.GenerateEmptySpaceArray(Vector2(num_x_layers,num_y_layers))
	var building_map = RogueGen.GenerateMansion(Vector2(25,25))
	#field_map = RogueGen.MansionWindowGen(building_map,2)
	field_map = RogueGen.StampSpaceOntoSpace(building_map, field_map, Vector2(2,2))
	#Now generate the foliage
	field_map = RogueGen.InitializeFoliageSeeds(field_map,1,10)
	#field_map = RogueGen.AdvanceGenerationsFoliageSeeds(field_map,1,4)
	
	field_map = RogueGen.AdvanceSingleGenerationFoliageSeeds(field_map,1)
	
	#print(field_map)

	##Build out the field...
	for i in range(field_map.size()):
		for j in range(field_map[0].size()):
			#BLANK TILE
			if field_map[i][j] == 0:
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(999)
				new_building_item.SetPrimColor(background_color)
				
			if field_map[i][j] == 1:
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(102)
				new_building_item.SetPrimColor(brick_color_prim)
				new_building_item.SetSecoColor(brick_color_seco)
				
			if field_map[i][j] == 2:
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
			if field_map[i][j] == 3:
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(103)
				new_building_item.SetPrimColor(basic_door_color_prim)
				new_building_item.SetSecoColor(basic_door_color_seco)
			if field_map[i][j] == 4:
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(107)
				new_building_item.SetPrimColor(kitchen_floor_color_prim)
				new_building_item.SetSecoColor(kitchen_floor_color_seco)
			#PERSONAL ROOM (FLOOR) FURNITURE
			if field_map[i][j] == 5:
				#CREATE THE FLOOR ITEM
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
				#CREATE THE RANDOM FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				var furniture_items = [402, 403, 404, 405, 406, 410]
				var choice = furniture_items[randi()%furniture_items.size()]
				new_building_item.setTile(choice)
				new_building_item.SetPrimColor(personal_room_furniture_prim)
				new_building_item.SetSecoColor(personal_room_furniture_seco)
			#PUBLIC ROOM (FLOOR) FURNITURE
			if field_map[i][j] == 6:
				#CREATE THE FLOOR ITEM
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(107)
				new_building_item.SetPrimColor(kitchen_floor_color_prim)
				new_building_item.SetSecoColor(kitchen_floor_color_seco)
				#CREATE THE RANDOM FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				var furniture_items = [401, 407, 408, 409, 410]
				var choice = furniture_items[randi()%furniture_items.size()]
				new_building_item.setTile(choice)
				new_building_item.SetPrimColor(public_room_furniture_prim)
				new_building_item.SetSecoColor(public_room_furniture_seco)
			#WINDOW
			if field_map[i][j] == 9:
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(108)
				new_building_item.SetPrimColor(brick_color_prim)
				new_building_item.SetSecoColor(brick_color_seco)
				new_building_item.SetTertColor(window_prim)

			#SPECIFIC FURNITURE CODES!!!
			#LEFT PUBLIC ROOM SET FURNITURE
			if field_map[i][j] == 101:
				#CREATE THE FLOOR ITEM
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(107)
				new_building_item.SetPrimColor(kitchen_floor_color_prim)
				new_building_item.SetSecoColor(kitchen_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				var furniture_items = [409]
				var choice = furniture_items[randi()%furniture_items.size()]
				new_building_item.setTile(choice)
				new_building_item.SetPrimColor(public_room_furniture_prim)
				new_building_item.SetSecoColor(public_room_furniture_seco)
			#MID PUBLIC ROOM SET FURNITURE
			if field_map[i][j] == 102:
				#CREATE THE FLOOR ITEM
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(107)
				new_building_item.SetPrimColor(kitchen_floor_color_prim)
				new_building_item.SetSecoColor(kitchen_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				var furniture_items = [407]
				var choice = furniture_items[randi()%furniture_items.size()]
				new_building_item.setTile(choice)
				new_building_item.SetPrimColor(public_room_furniture_prim)
				new_building_item.SetSecoColor(public_room_furniture_seco)
			#RIGHT PUBLIC ROOM SET FURNITURE
			if field_map[i][j] == 103:
				#CREATE THE FLOOR ITEM
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(107)
				new_building_item.SetPrimColor(kitchen_floor_color_prim)
				new_building_item.SetSecoColor(kitchen_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				var furniture_items = [408]
				var choice = furniture_items[randi()%furniture_items.size()]
				new_building_item.setTile(choice)
				new_building_item.SetPrimColor(public_room_furniture_prim)
				new_building_item.SetSecoColor(public_room_furniture_seco)
			#LEFT PRIVATEROOM SET FURNITURE
			if field_map[i][j] == 104:
				#CREATE THE FLOOR ITEM
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				var furniture_items = [403]
				var choice = furniture_items[randi()%furniture_items.size()]
				new_building_item.setTile(choice)
				new_building_item.SetPrimColor(personal_room_furniture_prim)
				new_building_item.SetSecoColor(personal_room_furniture_seco)
			#MID PUBLIC ROOM SET FURNITURE
			if field_map[i][j] == 105:
				#CREATE THE FLOOR ITEM
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				var furniture_items = [402]
				var choice = furniture_items[randi()%furniture_items.size()]
				new_building_item.setTile(choice)
				new_building_item.SetPrimColor(personal_room_furniture_prim)
				new_building_item.SetSecoColor(personal_room_furniture_seco)
			#RIGHT PUBLIC ROOM SET FURNITURE
			if field_map[i][j] == 106:
				#CREATE THE FLOOR ITEM
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				var furniture_items = [405]
				var choice = furniture_items[randi()%furniture_items.size()]
				new_building_item.setTile(choice)
				new_building_item.SetPrimColor(personal_room_furniture_prim)
				new_building_item.SetSecoColor(personal_room_furniture_seco)
			#FOLIAGE TILES
			if field_map[i][j] == 301:
				#Make the blank tile
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(999)
				new_building_item.SetPrimColor(background_color)
				#Also make the leafy tile on top
				new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(301)
				new_building_item.SetPrimColor(foliage_prim)
			if field_map[i][j] == 302:
				#Make the blank tile
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(999)
				new_building_item.SetPrimColor(background_color)
				#Also make the leafy tile on top
				new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(302)
				new_building_item.SetPrimColor(foliage_prim)
			if field_map[i][j] == 303:
				#Make the blank tile
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(999)
				new_building_item.SetPrimColor(background_color)
				#Also make the leafy tile on top
				new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(303)
				new_building_item.SetPrimColor(foliage_prim)

#	#Background
#	background_color = Color(randf(), randf(), randf())
#	VisualServer.set_default_clear_color(background_color)
#
#	#Initialize Distance Shade Sprites
#	#This is an array of sprites to give the distance depth effect
#	#An array of sprites stretched out to screen
#	#Transparency to 1/15th 
#	#Color is same as background
#	#These shouldn't change during the course of things...
#	$DepthSprite.scale = Vector2(map_width + 1, map_height + 1) #Stretch the template one to size of screen
#	$DepthSprite.modulate = Color(background_color.r, background_color.g, background_color.b, 0.07)
#
#	#Initialize canvas layers for each of the floors
#	#BIRDSEYE
#	for temp_floor in building_layout:
#		var temp_canvas_layer = CanvasLayer.new()
#		birdseyeLayers.append(temp_canvas_layer)
#		add_child(temp_canvas_layer)
#	#BALCONY
#	var layer_index = 0 #used to set the layers 
#	for temp_slice in building_layout[0][0]: #cycling through the y dimensions...
#		var temp_canvas_layer = CanvasLayer.new()
#		balconyXZLayers.append(temp_canvas_layer)
#		add_child(temp_canvas_layer)
#		#also set the layer index....
#		temp_canvas_layer.layer = layer_index
#		#update counter... we go backwards, depper into the z levels 
#		layer_index = layer_index - 1
#	print(balconyXZLayers.size())
#
#	#Add a depth Sprite into each layer... This gives the haze effect since they are transparent
#	for balcony_layer in balconyXZLayers:
#		var temp_sprite = $DepthSprite.duplicate()
#		balcony_layer.add_child(temp_sprite)
#		distanceShadeSprites.append(temp_sprite)
#		temp_sprite.visible = true
#
#	#Populate BOTH OF the sets of Canvas layers with ITEMS from Builidng Layout Plan
#	#BIRDSEYE Canvas Layers
#	for z in building_layout.size():
#		for x in building_layout[0].size():
#			for y in building_layout[0][0].size():
#				if building_layout[z][x][y] == 0:
#					continue #skip empty space...
#				if building_layout[z][x][y] == 1:
#					var new_building_item = Item.instance()
#					new_building_item.position.y = y * $TileMap.cell_size.y
#					new_building_item.position.x = x * $TileMap.cell_size.x
#					birdseyeLayers[z].add_child(new_building_item)
#					new_building_item.setTile(102)
#					new_building_item.SetPrimColor(brick_color_prim)
#					new_building_item.SetSecoColor(brick_color_seco)
#				if building_layout[z][x][y] == 2:
#					var new_building_item = Item.instance()
#					new_building_item.position.y = y * $TileMap.cell_size.y
#					new_building_item.position.x = x * $TileMap.cell_size.x
#					birdseyeLayers[z].add_child(new_building_item)
#					new_building_item.setTile(101)
#					new_building_item.SetPrimColor(basic_floor_color_prim)
#					new_building_item.SetSecoColor(basic_floor_color_seco)
#				if building_layout[z][x][y] == 3:
#					var new_building_item = Item.instance()
#					new_building_item.position.y =  y * $TileMap.cell_size.y
#					new_building_item.position.x =  x * $TileMap.cell_size.x
#					birdseyeLayers[z].add_child(new_building_item)
#					new_building_item.setTile(103)
#					new_building_item.SetPrimColor(basic_door_color_prim)
#					new_building_item.SetSecoColor(basic_door_color_seco)
#				if building_layout[z][x][y] == 4:
#					var new_building_item = Item.instance()
#					new_building_item.position.y =  y * $TileMap.cell_size.y
#					new_building_item.position.x =  x * $TileMap.cell_size.x
#					birdseyeLayers[z].add_child(new_building_item)
#					new_building_item.setTile(107)
#					new_building_item.SetPrimColor(kitchen_floor_color_prim)
#					new_building_item.SetSecoColor(kitchen_floor_color_seco)
#				#PERSONAL ROOM (FLOOR) FURNITURE
#				if building_layout[z][x][y] == 5:
#					#CREATE THE FLOOR ITEM
#					var new_building_item = Item.instance()
#					new_building_item.position.y =  y * $TileMap.cell_size.y
#					new_building_item.position.x =  x * $TileMap.cell_size.x
#					birdseyeLayers[z].add_child(new_building_item)
#					new_building_item.setTile(101)
#					new_building_item.SetPrimColor(basic_floor_color_prim)
#					new_building_item.SetSecoColor(basic_floor_color_seco)
#					#CREATE THE RANDOM FURNITURE ITEM
#					new_building_item = BattleHuntItem.instance()
#					new_building_item.position.y = y * $TileMap.cell_size.y
#					new_building_item.position.x = x * $TileMap.cell_size.x
#					birdseyeLayers[z].add_child(new_building_item)
#					var furniture_items = [402, 403, 404, 405, 406, 410]
#					var choice = furniture_items[randi()%furniture_items.size()]
#					new_building_item.setTile(choice)
#					new_building_item.SetPrimColor(personal_room_furniture_prim)
#					new_building_item.SetSecoColor(personal_room_furniture_seco)
#				#PUBLIC ROOM (FLOOR) FURNITURE
#				if building_layout[z][x][y] == 6:
#					#CREATE THE FLOOR ITEM
#					var new_building_item = Item.instance()
#					new_building_item.position.y = y * $TileMap.cell_size.y
#					new_building_item.position.x = x * $TileMap.cell_size.x
#					birdseyeLayers[z].add_child(new_building_item)
#					new_building_item.setTile(107)
#					new_building_item.SetPrimColor(kitchen_floor_color_prim)
#					new_building_item.SetSecoColor(kitchen_floor_color_seco)
#					#CREATE THE RANDOM FURNITURE ITEM
#					new_building_item = BattleHuntItem.instance()
#					new_building_item.position.y = y * $TileMap.cell_size.y
#					new_building_item.position.x = x * $TileMap.cell_size.x
#					birdseyeLayers[z].add_child(new_building_item)
#					var furniture_items = [401, 407, 408, 409, 410]
#					var choice = furniture_items[randi()%furniture_items.size()]
#					new_building_item.setTile(choice)
#					new_building_item.SetPrimColor(public_room_furniture_prim)
#					new_building_item.SetSecoColor(public_room_furniture_seco)
#				#WINDOW
#				if building_layout[z][x][y] == 9:
#					var new_building_item = Item.instance()
#					new_building_item.position.y =  y * $TileMap.cell_size.y
#					new_building_item.position.x =  x * $TileMap.cell_size.x
#					birdseyeLayers[z].add_child(new_building_item)
#					new_building_item.setTile(108)
#					new_building_item.SetPrimColor(brick_color_prim)
#					new_building_item.SetSecoColor(brick_color_seco)
#					new_building_item.SetTertColor(window_prim)
#
#	#BALCONY Canvas Layers
#	#Z layers are 2 tiles high
#	#So as we go through the building_layout, we need to put two items down
#	for z in building_layout.size():
#		for x in building_layout[0].size():
#			for y in building_layout[0][0].size():
#				if building_layout[z][x][y] == 0:
#					continue #skip empty space...
#				#CALCULATE SCREEN POSITION OF THE ITEM
#				var temp_position = Vector2()
#				temp_position.y = balcony_begin_position.y - (z * (2 * $TileMap.cell_size.y)) #z layers are two tiles wide!
#				temp_position.x = balcony_begin_position.x + x * $TileMap.cell_size.x
#				#WALL
#				if building_layout[z][x][y] == 1:
#					var new_building_item = Item.instance()
#					new_building_item.position = temp_position
#					balconyXZLayers[y].add_child(new_building_item)
#					new_building_item.setTile(102)
#					new_building_item.SetPrimColor(brick_color_prim)
#					new_building_item.SetSecoColor(brick_color_seco)
#					#Create Another wall on top
#					var top_building_item = Item.instance()
#					top_building_item.position = temp_position
#					top_building_item.position.y = temp_position.y - $TileMap.cell_size.y
#					balconyXZLayers[y].add_child(top_building_item)
#					top_building_item.setTile(102)
#					top_building_item.SetPrimColor(brick_color_prim)
#					top_building_item.SetSecoColor(brick_color_seco)
#				#FLOOR
#				if building_layout[z][x][y] == 2:
#					var new_building_item = Item.instance()
#					new_building_item.position = temp_position
#					balconyXZLayers[y].add_child(new_building_item)
#					new_building_item.setTile(110)
#					new_building_item.SetPrimColor(basic_floor_color_prim)
#					new_building_item.SetSecoColor(basic_floor_color_seco)
#				#DOOR
#				if building_layout[z][x][y] == 3:
#					var new_building_item = Item.instance()
#					new_building_item.position = temp_position
#					balconyXZLayers[y].add_child(new_building_item)
#					new_building_item.setTile(103)
#					new_building_item.SetPrimColor(basic_door_color_prim)
#					new_building_item.SetSecoColor(basic_door_color_seco)
#					#Create Another wall on top
#					var top_building_item = Item.instance()
#					top_building_item.position = temp_position
#					top_building_item.position.y = temp_position.y - $TileMap.cell_size.y
#					balconyXZLayers[y].add_child(top_building_item)
#					top_building_item.setTile(102)
#					top_building_item.SetPrimColor(brick_color_prim)
#					top_building_item.SetSecoColor(brick_color_seco)
#				#KITCHEN FLOOR
#				if building_layout[z][x][y] == 4:
#					var new_building_item = Item.instance()
#					new_building_item.position = temp_position
#					balconyXZLayers[y].add_child(new_building_item)
#					new_building_item.setTile(111)
#					new_building_item.SetPrimColor(kitchen_floor_color_prim)
#					new_building_item.SetSecoColor(kitchen_floor_color_seco)
##				#PERSONAL ROOM (FLOOR) FURNITURE
##				if building_layout[z][x][y] == 5:
##					#CREATE THE FLOOR ITEM
##					var new_building_item = Item.instance()
##					new_building_item.position = temp_position
##					balconyXZLayers[y].add_child(new_building_item)
##					new_building_item.setTile(110)
##					new_building_item.SetPrimColor(basic_floor_color_prim)
##					new_building_item.SetSecoColor(basic_floor_color_seco)
##					#CREATE THE RANDOM FURNITURE ITEM
##					new_building_item = BattleHuntItem.instance()
##					new_building_item.position = temp_position
##					balconyXZLayers[y].add_child(new_building_item)
##					var furniture_items = [402, 403, 404, 405, 406, 410]
##					var choice = furniture_items[randi()%furniture_items.size()]
##					new_building_item.setTile(choice)
##					new_building_item.SetPrimColor(personal_room_furniture_prim)
##					new_building_item.SetSecoColor(personal_room_furniture_seco)
##				#PUBLIC ROOM (FLOOR) FURNITURE
##				if building_layout[z][x][y] == 6:
##					#CREATE THE FLOOR ITEM
##					var new_building_item = Item.instance()
##					new_building_item.position = temp_position
##					balconyXZLayers[y].add_child(new_building_item)
##					new_building_item.setTile(111)
##					new_building_item.SetPrimColor(kitchen_floor_color_prim)
##					new_building_item.SetSecoColor(kitchen_floor_color_seco)
##					#CREATE THE RANDOM FURNITURE ITEM
##					new_building_item = BattleHuntItem.instance()
##					new_building_item.position = temp_position
##					balconyXZLayers[y].add_child(new_building_item)
##					var furniture_items = [401, 407, 408, 409, 410]
##					var choice = furniture_items[randi()%furniture_items.size()]
##					new_building_item.setTile(choice)
##					new_building_item.SetPrimColor(public_room_furniture_prim)
##					new_building_item.SetSecoColor(public_room_furniture_seco)
#				if building_layout[z][x][y] == 9:
#					var new_building_item = Item.instance()
#					new_building_item.position = temp_position
#					balconyXZLayers[y].add_child(new_building_item)
#					new_building_item.setTile(108)
#					new_building_item.SetPrimColor(brick_color_prim)
#					new_building_item.SetSecoColor(brick_color_seco)
#					new_building_item.SetTertColor(window_prim)
#					#Create Another window on top
#					var top_building_item = Item.instance()
#					top_building_item.position = temp_position
#					top_building_item.position.y = temp_position.y - $TileMap.cell_size.y
#					balconyXZLayers[y].add_child(top_building_item)
#					top_building_item.setTile(109)
#					top_building_item.SetPrimColor(brick_color_prim)
#					top_building_item.SetSecoColor(brick_color_seco)
#					top_building_item.SetTertColor(window_prim)
#
#	print("done")
#
#
#	#INitially, turn off all canvas layers
#	for layer in birdseyeLayers:
#		CanvasLayerOff(layer)
#	for layer in balconyXZLayers:
#		CanvasLayerOff(layer)
#
#	CanvasLayerOn(birdseyeLayers[0])
#	#CanvasLayerOn(balconyXZLayers[0])
#	#view_mode = VIEW_MODE.balcony
#	view_mode = VIEW_MODE.birdseye
#
#	#################################################
#	#DEBUG SHIT
#	ConfigLayers(view_cursor_position)
#
##	for layer in balconyXZLayers:
##		CanvasLayerAlpha(layer, 0.05)
#
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func _input(event):
#	#If in BIRDSEYE MODE
#	if view_mode == VIEW_MODE.birdseye:
#		if event.is_action_pressed("ui_up_level"):
#
#			#TURN OFF OLD LAYER
#			CanvasLayerOff(birdseyeLayers[view_cursor_position.z])
#
#			view_cursor_position = view_cursor_position + Vector3(0,0,1)
#			if view_cursor_position.z > num_floors - 1:
#				view_cursor_position.z = num_floors - 1
#
#			#TURN ON NEW LAYERS
#			CanvasLayerOn(birdseyeLayers[view_cursor_position.z])
#
#		if event.is_action_pressed("ui_down_level"):
#
#			#TURN OFF OLD LAYER
#			CanvasLayerOff(birdseyeLayers[view_cursor_position.z])
#
#			view_cursor_position = view_cursor_position + Vector3(0,0,-1)
#			if view_cursor_position.z < 0:
#				view_cursor_position.z = 0
#
#			#TURN ON NEW LAYER
#			CanvasLayerOn(birdseyeLayers[view_cursor_position.z])
#
#	#If in BALCONY MODE
#	if view_mode == VIEW_MODE.balcony:
#		if event.is_action_pressed("ui_up_level"):
#
#			#TURN OFF OLD LAYER
#			CanvasLayerOff(balconyXZLayers[view_cursor_position.y])
#
#			view_cursor_position = view_cursor_position + Vector3(0,1,0)
#			if view_cursor_position.y > num_y_layers - 1:
#				view_cursor_position.y = num_y_layers - 1
#
#			#TURN ON NEW LAYERS
#			#CanvasLayerOn(balconyXZLayers[view_cursor_position.y])
#			ConfigLayers(view_cursor_position)
#
#		if event.is_action_pressed("ui_down_level"):
#
#			#TURN OFF OLD LAYER
#			CanvasLayerOff(balconyXZLayers[view_cursor_position.y])
#
#			view_cursor_position = view_cursor_position + Vector3(0,-1,0)
#			if view_cursor_position.y < 0:
#				view_cursor_position.y = 0
#
#			#TURN ON NEW LAYERS
#			#CanvasLayerOn(balconyXZLayers[view_cursor_position.y])
#			ConfigLayers(view_cursor_position)
#
##Utility Functions To TOGGLE Canvas Layers
#func CanvasLayerOff(canvas_layer):
#	for child in canvas_layer.get_children():
#		child.hide()
#func CanvasLayerOn(canvas_layer):
#	for child in canvas_layer.get_children():
#		child.show()
#
###Function that will ajust the alpha of all items in the Canvas layer
##func CanvasLayerAlpha(canvas_layer, alpha):
##	var temp_col #will temp hold the color we change
##	for child in canvas_layer.get_children():
##		temp_col = Color(child.primColor.r, child.primColor.g, child.primColor.b, alpha)
##		child.SetPrimColor(temp_col)
##		temp_col = Color(child.secoColor.r, child.secoColor.g, child.secoColor.b, alpha)
##		child.SetSecoColor(temp_col)
##		temp_col = Color(child.tertColor.r, child.tertColor.g, child.tertColor.b, alpha)
##		child.SetTertColor(temp_col)
#
##Function that will configure the proper layers for a given position
##This includes
## Turning On/OFF proper layers
## Setting layer index / z-index
## setting alpha
#func ConfigLayers(view_position):
#
#	if view_mode == VIEW_MODE.balcony:
#
#		var current_layer = view_position.y + 14
#		for i in range(15): #We will be turning on 15 layers, starting with the last
#
#			#Bounds check
#			if current_layer < balconyXZLayers.size():
#				#Turn on layer
#				CanvasLayerOn(balconyXZLayers[current_layer])
#
#			#Set the proper alpha for the layer
#			#CanvasLayerAlpha(balconyXZLayers[current_layer], )
#
#			#Cycle on to the next one
#			current_layer = current_layer - 1 #moving backwards
#
#
	
	
	
	
	






