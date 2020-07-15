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
export (PackedScene) var FarmTile
export (PackedScene) var DirtTile
export (PackedScene) var Creature

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
var field_map = [] #A tile layout of the level (from RogueGen.GenerateMansion Main Map)
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
#
var dirt_color_prim #dry
var dirt_color_seco #wet
var dirt_color_tert #water
#
var dirt_patch_color_set_data #will keep track of random colors for the dirt patch

# Resources
var curtains_prim

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

################
### 3-D Indexed ITEM arrays -> Really a 4-D list
#######
### Access: map_items[x_coord][y_coord][z-_coord] = {list of Item scenes}
var map_items = [] #items that can be picked up...
var map_buildings = [] #building items (no diff between top and bottom) -> Always under creature

#Control Stuff
var balcony_begin_position 

#Main Player
var main_player #the main creature
#tiles that the player can't walk through (reference Mansion Gen MAIN MAP LIST)
var blocked_tiles = [1,5,6,7,8,9,101,102,103,104,105,106,501] 


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
	#background_color = MedAlgo.color_shift(background_color,-0.3)
	foliage_prim = Color(randf(), randf(), randf(), 0.7)
	foliage_seco = Color(randf(), randf(), randf())
	#
#	dirt_color_prim = MedAlgo.generate_pastel()
#	dirt_color_seco = MedAlgo.wet_dirt(dirt_color_prim)
#	dirt_color_tert = MedAlgo.generate_water_color()
	#
	dirt_patch_color_set_data = MedAlgo.generate_offset_color_set(background_color, 10, 0.05)
	
	curtains_prim = Color(randf(), randf(), randf())
	
	#DEBUG
	#window_prim = Color(1,1,1)
	
	#Screen Dimension stuff
	world_width = get_viewport().size.x
	world_height = get_viewport().size.y
	map_width = int($TileMap.world_to_map(Vector2(world_width,0)).x)
	map_height = int($TileMap.world_to_map(Vector2(0,world_height)).y)
	
	#Initialize canvas layers for each of the floors
	#BIRDSEYE
	for temp_floor in building_layout:
		var temp_canvas_layer = CanvasLayer.new()
		birdseyeLayers.append(temp_canvas_layer)
		add_child(temp_canvas_layer)
	
	#Initialize Item Arrays
	#MAP ITEMS
	for i in range(num_x_layers):
		var x_list = []
		for j in range(num_y_layers):
			var y_list = []
			for z in range(num_floors):
				var z_list = []
				y_list.append(z_list)
			x_list.append(y_list)
		map_items.append(x_list)
	#BUILDINGS
	for i in range(num_x_layers):
		var x_list = []
		for j in range(num_y_layers):
			var y_list = []
			for z in range(num_floors):
				var z_list = []
				y_list.append(z_list)
			x_list.append(y_list)
		map_buildings.append(x_list)
	
	
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
	field_map = RogueGen.GenerateEmptySpaceArray(Vector2(num_x_layers,num_y_layers))
	var building_map = RogueGen.GenerateMansion(Vector2(25,25))
	building_map = RogueGen.MansionResourceWindowGen(building_map, 5)
	building_map = RogueGen.MansionWindowGen(building_map,5)
	building_map = RogueGen.MansionFrontDoorGen(building_map)
	#field_map = RogueGen.MansionWindowGen(building_map,2)
	field_map = RogueGen.StampSpaceOntoSpace(building_map, field_map, Vector2(2,2))
	#Now generate the foliage
	field_map = RogueGen.InitializeFoliageSeeds(field_map,1,10)
	field_map = RogueGen.AdvanceGenerationsFoliageSeeds(field_map,1,4)
	
	#Make an array for dirt tiles and stamp those down onto the field_map
	var farm_plot = []
	var farm_plot_x = 4 + randi()%3
	var farm_plot_y = 4 + randi()%3
	for i in range(farm_plot_x):
		var temp_row = []
		for j in range(farm_plot_y):
			temp_row.append(401) #the code for dirt tiles
		farm_plot.append(temp_row)
	
	field_map = RogueGen.StampSpaceOntoSpace(farm_plot, field_map, Vector2(30+randi()%6,15+randi()%3))
			
	
	#field_map = RogueGen.AdvanceSingleGenerationFoliageSeeds(field_map,1)
	
	#print(field_map)

	##Build out the field...
	for i in range(field_map.size()):
		for j in range(field_map[0].size()):
			#BLANK TILE
			if field_map[i][j] == 0:
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(999)
				new_building_item.SetPrimColor(background_color)
				
			if field_map[i][j] == 1:
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(102)
				new_building_item.SetPrimColor(brick_color_prim)
				new_building_item.SetSecoColor(brick_color_seco)
				
			if field_map[i][j] == 2:
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
			if field_map[i][j] == 3:
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(103)
				new_building_item.SetPrimColor(basic_door_color_prim)
				new_building_item.SetSecoColor(basic_door_color_seco)
			if field_map[i][j] == 4:
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
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
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
				#CREATE THE RANDOM FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
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
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(107)
				new_building_item.SetPrimColor(kitchen_floor_color_prim)
				new_building_item.SetSecoColor(kitchen_floor_color_seco)
				#CREATE THE RANDOM FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
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
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
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
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(107)
				new_building_item.SetPrimColor(kitchen_floor_color_prim)
				new_building_item.SetSecoColor(kitchen_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
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
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(107)
				new_building_item.SetPrimColor(kitchen_floor_color_prim)
				new_building_item.SetSecoColor(kitchen_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
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
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(107)
				new_building_item.SetPrimColor(kitchen_floor_color_prim)
				new_building_item.SetSecoColor(kitchen_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
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
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
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
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
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
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
				#CREATE THE FURNITURE ITEM
				new_building_item = BattleHuntItem.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
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
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(999)
				new_building_item.SetPrimColor(background_color)
				#Also make the leafy tile on top
				new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(301)
				new_building_item.SetPrimColor(foliage_prim)
			if field_map[i][j] == 302:
				#Make the blank tile
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(999)
				new_building_item.SetPrimColor(background_color)
				#Also make the leafy tile on top
				new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(302)
				new_building_item.SetPrimColor(foliage_prim)
			if field_map[i][j] == 303:
				#Make the blank tile
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(999)
				new_building_item.SetPrimColor(background_color)
				#Also make the leafy tile on top
				new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(303)
				new_building_item.SetPrimColor(foliage_prim)
			#FARM TILES
			#dirt
			if field_map[i][j] == 401:
				var temp_tile = DirtTile.instance()
				temp_tile.position.y = j * $TileMap.cell_size.y
				temp_tile.position.x = i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(temp_tile) #add to global item matrix
				add_child(temp_tile)
				#Choose a random dirt color from the set
				var temp_col = dirt_patch_color_set_data["color_set"][randi()%dirt_patch_color_set_data["color_set"].size()]
				temp_tile.SetPrimColor(temp_col)
				
			#RESOURCE HARVEST OBJECTS
			#CuRTAINS
			if field_map[i][j] == 501:
				#Make Window first
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(108)
				new_building_item.SetPrimColor(brick_color_prim)
				new_building_item.SetSecoColor(brick_color_seco)
				new_building_item.SetTertColor(window_prim)
				#Make the curtains
				new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				map_buildings[i][j][0].append(new_building_item) #add to global item matrix
				add_child(new_building_item)
				new_building_item.setTile(404)
				new_building_item.SetPrimColor(curtains_prim)

	#Now We can build out the creature(s)
	main_player = Creature.instance()
	#main_player.position = Vector2(2 * $TileMap.cell_size.x, 2 * $TileMap.cell_size.y)
	add_child(main_player)
	main_player.moveCreature(Vector3(4,4,0))

#			#DIRT
#			temp_tile = DirtTile.instance()
#			temp_tile.position = temp_global_coords
#			add_child(temp_tile)
#			map_tiles[temp_map_coords.y*map_width + temp_map_coords.x] = temp_tile
#			pass


#			var temp_farm_tile = FarmTile.instance()
#			temp_farm_tile.position = Vector2(i*16, j*16)
#			add_child(temp_farm_tile)
#			temp_farm_tile.change_tile(8)
#			temp_farm_tile.SetPrim(Color(1.0,1.0,0.0)); 



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

var move_timer  = 0#A timer that keeps track of when last movement happened
func _input(event):
	
	var next_step = Vector3(0,0,0)
	
	#Handle movement
	if event.is_action_pressed("ui_up"):
		#record the next step...
		next_step = main_player.map_coords + Vector3(0,-1,0)
	if event.is_action_pressed("ui_down"):
		#record the next step...
		next_step = main_player.map_coords + Vector3(0,1,0)
	if event.is_action_pressed("ui_left"):
		#record the next step...
		next_step = main_player.map_coords + Vector3(-1,0,0)
	if event.is_action_pressed("ui_right"):
		#record the next step...
		next_step = main_player.map_coords + Vector3(1,0,0)

	#Bounds check
	if next_step.x > 0 and next_step.y > 0 and next_step.x < num_x_layers and next_step.y < num_y_layers: 
		#Check if next tile is blocked
		var next_index = field_map[next_step.x][next_step.y]
		if !(next_index in blocked_tiles):
			main_player.moveCreature(next_step)
		
	if event.is_action_pressed("mmo_send_map"):
		print("sending map")


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
	
	
	
	
	






