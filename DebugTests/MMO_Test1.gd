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
var building_layout = [] #The 2D tile layout of the building (temp)
# ACCESS IS: building_layout[x][y] (when we were using balcon view)
var field_map = [] #A tile layout of the level (from RogueGen.GenerateMansion Main Map)
# ACCESS SHOULD BE: field_map[z_floor][x][y]
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
var dirt_patch_color_set_data #will keep track of random colors for the dirt patch
#
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

#Display stuff
var selected_creature #which creature is picked to look at

#MMO STUFF

#NETWORKING STUFF (CLIENT)
var client #the object that will handle network comms with server
var wrapped_client #more specialized to handle the individual bytes
var connected = false #if we are connected to server or not
var recvBuffer = "" # a string buffer containging messages from the server

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
	curtains_prim = Color(randf(), randf(), randf())
	#
	dirt_patch_color_set_data = MedAlgo.generate_offset_color_set(background_color, 10, 0.05)

	
	#DEBUG
	#window_prim = Color(1,1,1)
	
	#Screen Dimension stuff
	world_width = get_viewport().size.x
	world_height = get_viewport().size.y
	map_width = int($TileMap.world_to_map(Vector2(world_width,0)).x)
	map_height = int($TileMap.world_to_map(Vector2(0,world_height)).y)
	
	#Position Display Windows
	$HUDLayer/CreatureDisplay.position.y = world_height - 8*16
	$HUDLayer/ItemDisplay.position.y = world_height - 8*16
	
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
	field_map = []
	for k in range(num_floors):
		field_map.append(RogueGen.GenerateEmptySpaceArray(Vector2(num_x_layers,num_y_layers)))
	
	#GENERATE FIRST FLOOR
	var building_map = RogueGen.GenerateMansion(Vector2(25,25))
	building_map = RogueGen.MansionResourceWindowGen(building_map, 5)
	building_map = RogueGen.MansionWindowGen(building_map,5)
	building_map = RogueGen.MansionFrontDoorGen(building_map)
	#field_map = RogueGen.MansionWindowGen(building_map,2)
	field_map[0] = RogueGen.StampSpaceOntoSpace(building_map, field_map[0], Vector2(2,2))
	#Now generate the foliage
	field_map[0] = RogueGen.InitializeFoliageSeeds(field_map[0],1,10)
	field_map[0] = RogueGen.AdvanceGenerationsFoliageSeeds(field_map[0],1,4)
	#GENERATE OTHER FLOORS
	for i in range(5):
		var new_room = RogueGen.GenerateMansionFloor(building_map, 5, 2)
		new_room = RogueGen.MansionWindowGen(new_room,10)
		field_map[i+1] = RogueGen.StampSpaceOntoSpace(new_room, field_map[i+1], Vector2(2,2))
	
	#Make an array for dirt tiles and stamp those down onto the field_map
	var farm_plot = []
	var farm_plot_x = 4 + randi()%3
	var farm_plot_y = 4 + randi()%3
	for i in range(farm_plot_x):
		var temp_row = []
		for j in range(farm_plot_y):
			temp_row.append(401) #the code for dirt tiles
		farm_plot.append(temp_row)
	
	field_map[0] = RogueGen.StampSpaceOntoSpace(farm_plot, field_map[0], Vector2(30+randi()%6,15+randi()%3))
			
	
	#field_map = RogueGen.AdvanceSingleGenerationFoliageSeeds(field_map,1)
	#print(field_map)
	
	#Initialize canvas layers for each of the floors
	#BIRDSEYE
	for temp_floor in field_map:
		var temp_canvas_layer = CanvasLayer.new()
		birdseyeLayers.append(temp_canvas_layer)
		add_child(temp_canvas_layer)
		#BALCONY
	var layer_index = 0 #used to set the layers 
	for temp_slice in field_map[0][0]: #cycling through the y dimensions...
		var temp_canvas_layer = CanvasLayer.new()
		balconyXZLayers.append(temp_canvas_layer)
		add_child(temp_canvas_layer)
		#also set the layer index....
		temp_canvas_layer.layer = layer_index
		#update counter... we go backwards, depper into the z levels 
		layer_index = layer_index - 1

	##Build out the field...
	for k in range(field_map.size()):
		for i in range(field_map[0].size()):
			for j in range(field_map[0][0].size()):
				#BLANK TILE
				if field_map[k][i][j] == 0:
					var new_building_item = Item.instance()
					new_building_item.position.y = j * $TileMap.cell_size.y
					new_building_item.position.x = i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(999)
					new_building_item.SetPrimColor(background_color)
					
				if field_map[k][i][j] == 1:
					var new_building_item = Item.instance()
					new_building_item.position.y = j * $TileMap.cell_size.y
					new_building_item.position.x = i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(102)
					new_building_item.SetPrimColor(brick_color_prim)
					new_building_item.SetSecoColor(brick_color_seco)
					
				if field_map[k][i][j] == 2:
					var new_building_item = Item.instance()
					new_building_item.position.y = j * $TileMap.cell_size.y
					new_building_item.position.x = i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(101)
					new_building_item.SetPrimColor(basic_floor_color_prim)
					new_building_item.SetSecoColor(basic_floor_color_seco)
				if field_map[k][i][j] == 3:
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(103)
					new_building_item.SetPrimColor(basic_door_color_prim)
					new_building_item.SetSecoColor(basic_door_color_seco)
				if field_map[k][i][j] == 4:
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(107)
					new_building_item.SetPrimColor(kitchen_floor_color_prim)
					new_building_item.SetSecoColor(kitchen_floor_color_seco)
				#PERSONAL ROOM (FLOOR) FURNITURE
				if field_map[k][i][j] == 5:
					#CREATE THE FLOOR ITEM
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(101)
					new_building_item.SetPrimColor(basic_floor_color_prim)
					new_building_item.SetSecoColor(basic_floor_color_seco)
					#CREATE THE RANDOM FURNITURE ITEM
					new_building_item = BattleHuntItem.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					var furniture_items = [402, 403, 404, 405, 406, 410]
					var choice = furniture_items[randi()%furniture_items.size()]
					new_building_item.setTile(choice)
					new_building_item.SetPrimColor(personal_room_furniture_prim)
					new_building_item.SetSecoColor(personal_room_furniture_seco)
				#PUBLIC ROOM (FLOOR) FURNITURE
				if field_map[k][i][j] == 6:
					#CREATE THE FLOOR ITEM
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(107)
					new_building_item.SetPrimColor(kitchen_floor_color_prim)
					new_building_item.SetSecoColor(kitchen_floor_color_seco)
					#CREATE THE RANDOM FURNITURE ITEM
					new_building_item = BattleHuntItem.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					var furniture_items = [401, 407, 408, 409, 410]
					var choice = furniture_items[randi()%furniture_items.size()]
					new_building_item.setTile(choice)
					new_building_item.SetPrimColor(public_room_furniture_prim)
					new_building_item.SetSecoColor(public_room_furniture_seco)
				#WINDOW
				if field_map[k][i][j] == 9:
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(108)
					new_building_item.SetPrimColor(brick_color_prim)
					new_building_item.SetSecoColor(brick_color_seco)
					new_building_item.SetTertColor(window_prim)
	
				#SPECIFIC FURNITURE CODES!!!
				#LEFT PUBLIC ROOM SET FURNITURE
				if field_map[k][i][j] == 101:
					#CREATE THE FLOOR ITEM
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(107)
					new_building_item.SetPrimColor(kitchen_floor_color_prim)
					new_building_item.SetSecoColor(kitchen_floor_color_seco)
					#CREATE THE FURNITURE ITEM
					new_building_item = BattleHuntItem.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					var furniture_items = [409]
					var choice = furniture_items[randi()%furniture_items.size()]
					new_building_item.setTile(choice)
					new_building_item.SetPrimColor(public_room_furniture_prim)
					new_building_item.SetSecoColor(public_room_furniture_seco)
				#MID PUBLIC ROOM SET FURNITURE
				if field_map[k][i][j] == 102:
					#CREATE THE FLOOR ITEM
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][0].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(107)
					new_building_item.SetPrimColor(kitchen_floor_color_prim)
					new_building_item.SetSecoColor(kitchen_floor_color_seco)
					#CREATE THE FURNITURE ITEM
					new_building_item = BattleHuntItem.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					var furniture_items = [407]
					var choice = furniture_items[randi()%furniture_items.size()]
					new_building_item.setTile(choice)
					new_building_item.SetPrimColor(public_room_furniture_prim)
					new_building_item.SetSecoColor(public_room_furniture_seco)
				#RIGHT PUBLIC ROOM SET FURNITURE
				if field_map[k][i][j] == 103:
					#CREATE THE FLOOR ITEM
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(107)
					new_building_item.SetPrimColor(kitchen_floor_color_prim)
					new_building_item.SetSecoColor(kitchen_floor_color_seco)
					#CREATE THE FURNITURE ITEM
					new_building_item = BattleHuntItem.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					var furniture_items = [408]
					var choice = furniture_items[randi()%furniture_items.size()]
					new_building_item.setTile(choice)
					new_building_item.SetPrimColor(public_room_furniture_prim)
					new_building_item.SetSecoColor(public_room_furniture_seco)
				#LEFT PRIVATEROOM SET FURNITURE
				if field_map[k][i][j] == 104:
					#CREATE THE FLOOR ITEM
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(101)
					new_building_item.SetPrimColor(basic_floor_color_prim)
					new_building_item.SetSecoColor(basic_floor_color_seco)
					#CREATE THE FURNITURE ITEM
					new_building_item = BattleHuntItem.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					var furniture_items = [403]
					var choice = furniture_items[randi()%furniture_items.size()]
					new_building_item.setTile(choice)
					new_building_item.SetPrimColor(personal_room_furniture_prim)
					new_building_item.SetSecoColor(personal_room_furniture_seco)
				#MID PUBLIC ROOM SET FURNITURE
				if field_map[k][i][j] == 105:
					#CREATE THE FLOOR ITEM
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(101)
					new_building_item.SetPrimColor(basic_floor_color_prim)
					new_building_item.SetSecoColor(basic_floor_color_seco)
					#CREATE THE FURNITURE ITEM
					new_building_item = BattleHuntItem.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					var furniture_items = [402]
					var choice = furniture_items[randi()%furniture_items.size()]
					new_building_item.setTile(choice)
					new_building_item.SetPrimColor(personal_room_furniture_prim)
					new_building_item.SetSecoColor(personal_room_furniture_seco)
				#RIGHT PUBLIC ROOM SET FURNITURE
				if field_map[k][i][j] == 106:
					#CREATE THE FLOOR ITEM
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(101)
					new_building_item.SetPrimColor(basic_floor_color_prim)
					new_building_item.SetSecoColor(basic_floor_color_seco)
					#CREATE THE FURNITURE ITEM
					new_building_item = BattleHuntItem.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					var furniture_items = [405]
					var choice = furniture_items[randi()%furniture_items.size()]
					new_building_item.setTile(choice)
					new_building_item.SetPrimColor(personal_room_furniture_prim)
					new_building_item.SetSecoColor(personal_room_furniture_seco)
				#FOLIAGE TILES
				if field_map[k][i][j] == 301:
					#Make the blank tile
					var new_building_item = Item.instance()
					new_building_item.position.y = j * $TileMap.cell_size.y
					new_building_item.position.x = i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(999)
					new_building_item.SetPrimColor(background_color)
					#Also make the leafy tile on top
					new_building_item = Item.instance()
					new_building_item.position.y = j * $TileMap.cell_size.y
					new_building_item.position.x = i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(301)
					new_building_item.SetPrimColor(foliage_prim)
				if field_map[k][i][j] == 302:
					#Make the blank tile
					var new_building_item = Item.instance()
					new_building_item.position.y = j * $TileMap.cell_size.y
					new_building_item.position.x = i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(999)
					new_building_item.SetPrimColor(background_color)
					#Also make the leafy tile on top
					new_building_item = Item.instance()
					new_building_item.position.y = j * $TileMap.cell_size.y
					new_building_item.position.x = i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(302)
					new_building_item.SetPrimColor(foliage_prim)
				if field_map[k][i][j] == 303:
					#Make the blank tile
					var new_building_item = Item.instance()
					new_building_item.position.y = j * $TileMap.cell_size.y
					new_building_item.position.x = i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(999)
					new_building_item.SetPrimColor(background_color)
					#Also make the leafy tile on top
					new_building_item = Item.instance()
					new_building_item.position.y = j * $TileMap.cell_size.y
					new_building_item.position.x = i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(303)
					new_building_item.SetPrimColor(foliage_prim)
				#FARM TILES
				#dirt
				if field_map[k][i][j] == 401:
					var temp_tile = DirtTile.instance()
					temp_tile.position.y = j * $TileMap.cell_size.y
					temp_tile.position.x = i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(temp_tile) #add to global item matrix
					birdseyeLayers[k].add_child(temp_tile)
					#Choose a random dirt color from the set
					var temp_col = dirt_patch_color_set_data["color_set"][randi()%dirt_patch_color_set_data["color_set"].size()]
					temp_tile.SetPrimColor(temp_col)
					
				#RESOURCE HARVEST OBJECTS
				#CuRTAINS
				if field_map[k][i][j] == 501:
					#Make Window first
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(108)
					new_building_item.SetPrimColor(brick_color_prim)
					new_building_item.SetSecoColor(brick_color_seco)
					new_building_item.SetTertColor(window_prim)
					#Make the curtains
					new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					map_buildings[i][j][k].append(new_building_item) #add to global item matrix
					birdseyeLayers[k].add_child(new_building_item)
					new_building_item.setTile(404)
					new_building_item.SetPrimColor(curtains_prim)

	#INitially, turn off all canvas layers
	for layer in birdseyeLayers:
		CanvasLayerOff(layer)
	for layer in balconyXZLayers:
		CanvasLayerOff(layer)
		
	view_mode = VIEW_MODE.birdseye

	#Now We can build out the creature(s)
	main_player = Creature.instance()
	#main_player.position = Vector2(2 * $TileMap.cell_size.x, 2 * $TileMap.cell_size.y)
	add_child(main_player)
	main_player.moveCreature(Vector3(4,4,0))
	
	#Networking stuff....
	client = StreamPeerTCP.new()
	client.set_no_delay(true)

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
		var next_index = field_map[0][next_step.x][next_step.y]
		if !(next_index in blocked_tiles):
			main_player.moveCreature(next_step)
		
	if event.is_action_pressed("mmo_send_map"):
		if connected == true:
			print("sending map")
			send_msg_server("NEW_MAP<" + str(num_x_layers) + "," + str(num_y_layers) + "," + str(num_floors) + ">END_NEW_MAP" )
			transmit_world_data()
	
	if event.is_action_pressed("mmo_request_map"):
		if connected == true:
			#First, bring up the loading screen 
			$GenericLoadingScreen.visible = true
			update()
			
			#Send message requesting map data
			send_msg_server("REQUEST_MAP")
	
	if event.is_action_pressed("mmo_dump_recvBuffer"):
		print("This is the buffer:")
		print(recvBuffer)
	
	if event.is_action_pressed("mmo_send_tile_data"):
		transmit_one_tile()
	
	if event.is_action_pressed("mmo_send_debug_info"):
		if connected == true:
			send_msg_server("PRINT_BUFFER")
	
	if event.is_action_pressed("mmo_make_connection"):
		if connected == false: 
			print("making connection")
			set_process(true) #We'll now start calling the _process fucntion every frame
			var ip = "localhost"
			var port = 5555
			var connect = client.connect_to_host(ip, port)
			#Check if connection was successful
			if client.is_connected_to_host():
				print("connected")
				#We are connected
				connected = true
				wrapped_client = PacketPeerStream.new()
				wrapped_client.set_stream_peer(client)
				#Upon initial connection completion, send full player profile
				#STANDARD REGISTER PROFILE ROUTINE
				send_msg_server("uno")
				send_msg_server("dos")
				send_msg_server("tres") #for some reason, the first msgs fall off?
				## Does this only happen when we first connect/ call set_stream_peer?
				send_msg_server("REGISTER") #Tell server to make a blank profile for itself
				send_msg_server("CRE_NAME<" + main_player.creature_name + ">END_CRE_NAME") #enter the name
				send_msg_server("CRE_PRIM<"+str(main_player.dumpPrimColor()[0]) +"," + str(main_player.dumpPrimColor()[1]) +"," +str(main_player.dumpPrimColor()[2]) +">END_CRE_PRIM"  )
				send_msg_server("CLOTHES_INDEX<" + str(main_player.find_node("Clothes").tile_index) + ">END_CLOTHES_INDEX")
				send_msg_server("CLOTHES_PRIM<"+str(main_player.find_node("Clothes").dumpPrimColor()[0]) +"," + \
					str(main_player.find_node("Clothes").dumpPrimColor()[1]) +"," +str(main_player.find_node("Clothes").dumpPrimColor()[2]) +">END_CLOTHES_PRIM"  )
				send_msg_server("CLOTHES_SECO<"+str(main_player.find_node("Clothes").dumpSecoColor()[0]) +"," + \
					str(main_player.find_node("Clothes").dumpSecoColor()[1]) +"," +str(main_player.find_node("Clothes").dumpSecoColor()[2]) +">END_CLOTHES_SECO"  )
				send_msg_server("CLOTHES_TERT<"+str(main_player.find_node("Clothes").dumpTertColor()[0]) +"," + \
					str(main_player.find_node("Clothes").dumpTertColor()[1]) +"," +str(main_player.find_node("Clothes").dumpTertColor()[2]) +">END_CLOTHES_TERT"  )
				send_msg_server("CLOTHES_QUAD<"+str(main_player.find_node("Clothes").dumpQuadColor()[0]) +"," + \
					str(main_player.find_node("Clothes").dumpQuadColor()[1]) +"," +str(main_player.find_node("Clothes").dumpQuadColor()[2]) +">END_CLOTHES_QUAD"  )
				send_msg_server("CRE_POS<"+str(main_player.map_coords.x) +"," + \
					str(main_player.map_coords.y) +"," +str(main_player.map_coords.z) +">END_CRE_POS"  )
	
	#VIEW CONTROLS
	#If in BIRDSEYE MODE
	if view_mode == VIEW_MODE.birdseye:
		if event.is_action_pressed("ui_up_level"):
			
			print("press up")
			
			#TURN OFF OLD LAYER
			CanvasLayerOff(birdseyeLayers[view_cursor_position.z])
			
			view_cursor_position = view_cursor_position + Vector3(0,0,1)
			if view_cursor_position.z > num_floors - 1:
				view_cursor_position.z = num_floors - 1
			
			#TURN ON NEW LAYERS
			CanvasLayerOn(birdseyeLayers[view_cursor_position.z])
			
		if event.is_action_pressed("ui_down_level"):
			
			#TURN OFF OLD LAYER
			CanvasLayerOff(birdseyeLayers[view_cursor_position.z])
			
			view_cursor_position = view_cursor_position + Vector3(0,0,-1)
			if view_cursor_position.z < 0:
				view_cursor_position.z = 0
			
			#TURN ON NEW LAYER
			CanvasLayerOn(birdseyeLayers[view_cursor_position.z])

#Happens every cycle
#Mainly Network stuff
func _process(delta):
	if connected == true:
		poll_server()


func poll_server():
	
	while client.get_available_bytes() > 0:
		print("we poll stream")
		var msg = client.get_string(client.get_available_bytes())
		if msg == null:
			print("nothing")
			continue
		print("Recieved msg: " + str(msg))
		recvBuffer = recvBuffer + msg
		
		#PROCESS MESSAGE HERE
		#########################################
		
		#NEW_MAP command
		var new_map_regex = RegEx.new()
		new_map_regex.compile("NEW_MAP<(\\d+),(\\d+),(\\d+)>END_NEW_MAP")
		var new_map_result = new_map_regex.search(recvBuffer)
		if new_map_result:
			#First, bring up the loading screen 
			$GenericLoadingScreen.visible = true
			update()
			
			#Record the new map dimensions in global variables
			num_x_layers = int(new_map_result.get_string(1))
			num_y_layers = int(new_map_result.get_string(2))
			num_floors = int(new_map_result.get_string(3))
			
			#REMOVE COMMAND from BUFFER
			recvBuffer = recvBuffer.replace(new_map_result.get_string(),"")
		
		#PUT_TILE_DATA command
		var tile_data_regex = RegEx.new()
		tile_data_regex.compile("PUT_TILE_DATA<(\\d+),(\\d+),(\\d+),(\\d+)>END_PUT_TILE_DATA")
		var tile_data_result_list = tile_data_regex.search_all(recvBuffer)
		if tile_data_result_list.size() > 0:
			#iterate through all of the results
			for tile_data_result in tile_data_result_list:
				#Convert each of the result strings to ints
				var x_result = int(tile_data_result.get_string(1))
				var y_result = int(tile_data_result.get_string(2))
				var z_result = int(tile_data_result.get_string(3))
				var tile_result = int(tile_data_result.get_string(4))
				#Enter the data into the field_map
				field_map[z_result][x_result][y_result] = tile_result
				
				#REMOVE COMMAND from BUFFER
				recvBuffer = recvBuffer.replace(tile_data_result.get_string(), "")
				
		#PUT_COLOR_DATA command
		var color_data_regex = RegEx.new()
		color_data_regex.compile("PUT_COLOR_DATA<(\\d+),(\\d+(\\.\\d+)?),(\\d+(\\.\\d+)?),(\\d+(\\.\\d+)?)>END_PUT_COLOR_DATA")
		var color_data_result_list = color_data_regex.search_all(recvBuffer)
		if color_data_result_list.size() > 0:
			#iterate through all of the results
			for color_data_result in color_data_result_list:
				#Convert each of the result strings to numbers
				var index_result = int(color_data_result.get_string(1))
				var r_result = float(color_data_result.get_string(2))
				var g_result = float(color_data_result.get_string(3))
				var b_result = float(color_data_result.get_string(4))
				#Enter the data in the list of world colors
				var temp_color = Color(r_result,g_result,b_result)
				match(index_result):
					0:
						brick_color_prim = temp_color
					1:
						brick_color_seco = temp_color
					2:
						basic_floor_color_prim = temp_color
					3:
						basic_floor_color_seco = temp_color
					4:
						basic_door_color_prim = temp_color
					5:
						basic_door_color_seco = temp_color
					6:
						kitchen_floor_color_prim = temp_color
					7:
						kitchen_floor_color_seco = temp_color
					8:
						personal_room_furniture_prim = temp_color
					9:
						personal_room_furniture_seco = temp_color
					10:
						public_room_furniture_prim = temp_color
					11:
						public_room_furniture_seco = temp_color
					12:
						window_prim = temp_color
						window_prim.a = 0.7 #also set alpha for windows...
					13:
						background_color = temp_color
					14:
						foliage_prim = temp_color
					15:
						foliage_seco = temp_color
					16:
						curtains_prim = temp_color
				###End Match
				
				#REMOVE COMMAND from BUFFER
				recvBuffer = recvBuffer.replace(color_data_result.get_string(), "")


func transmit_world_data():
	print("sending world data over tcp...")
	#Sending tile indices
	for k in range(field_map.size()): #floors
		for i in range(field_map[0].size()): #x dim
			for j in range(field_map[0][0].size()):
				var read_index = field_map[k][i][j]
				send_msg_server("PUT_TILE_DATA<"+str(i)+","+str(j)+","+str(k)+","+str(read_index)+">END_PUT_TILE_DATA")
				
	#Sending World colors....
	send_msg_server("PUT_COLOR_DATA<0,"+str(brick_color_prim.r)+","+str(brick_color_prim.g)+","+str(brick_color_prim.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<1,"+str(brick_color_seco.r)+","+str(brick_color_seco.g)+","+str(brick_color_seco.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<2,"+str(basic_floor_color_prim.r)+","+str(basic_floor_color_prim.g)+","+str(basic_floor_color_prim.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<3,"+str(basic_floor_color_seco.r)+","+str(basic_floor_color_seco.g)+","+str(basic_floor_color_seco.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<4,"+str(basic_door_color_prim.r)+","+str(basic_door_color_prim.g)+","+str(basic_door_color_prim.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<5,"+str(basic_door_color_seco.r)+","+str(basic_door_color_seco.g)+","+str(basic_door_color_seco.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<6,"+str(kitchen_floor_color_prim.r)+","+str(kitchen_floor_color_prim.g)+","+str(kitchen_floor_color_prim.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<7,"+str(kitchen_floor_color_seco.r)+","+str(kitchen_floor_color_seco.g)+","+str(kitchen_floor_color_seco.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<8,"+str(personal_room_furniture_prim.r)+","+str(personal_room_furniture_prim.g)+","+str(personal_room_furniture_prim.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<9,"+str(personal_room_furniture_seco.r)+","+str(personal_room_furniture_seco.g)+","+str(personal_room_furniture_seco.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<10,"+str(public_room_furniture_prim.r)+","+str(public_room_furniture_prim.g)+","+str(public_room_furniture_prim.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<11,"+str(public_room_furniture_seco.r)+","+str(public_room_furniture_seco.g)+","+str(public_room_furniture_seco.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<12,"+str(window_prim.r)+","+str(window_prim.g)+","+str(window_prim.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<13,"+str(background_color.r)+","+str(background_color.g)+","+str(background_color.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<14,"+str(foliage_prim.r)+","+str(foliage_prim.g)+","+str(foliage_prim.b)+">END_PUT_COLOR_DATA")
	send_msg_server("PUT_COLOR_DATA<15,"+str(foliage_seco.r)+","+str(foliage_seco.g)+","+str(foliage_seco.b)+">END_PUT_COLOR_DATA")

	#Resource colors
	send_msg_server("PUT_COLOR_DATA<16,"+str(curtains_prim.r)+","+str(curtains_prim.g)+","+str(curtains_prim.b)+">END_PUT_COLOR_DATA")

	#Flush Buffer when over...
	send_msg_server("FLUSH_BUFFER")

#PRetty much for debug
func transmit_one_tile():
	send_msg_server("PUT_TILE_DATA<1,1,1,33>END_PUT_TILE_DATA")

#	while wrapped_client.get_available_packet_count() > 0:
#		print("we poll")
#		var msg = wrapped_client.get_var()
#		var error = wrapped_client.get_packet_error()
#		if error != 0:
#			print("Error on packet get: %s" % error)
#		if msg == null:
#			print("nothing")
#			continue;
#		print("Received msg: " + str(msg))
	
	

#Function that will send a message to the server
var debug_count = 1
func send_msg_server(msg):
	wrapped_client.put_var(msg)
	debug_count = debug_count + 1
	var error = wrapped_client.get_packet_error()
	if error != 0:
		print(error)
	

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
	

#Function that displays and populates the Creature Status Window
#Called by individual creature's scenes when they are selected
#Also handles the closing/deselecting? of other windows...
func DisplayCreature(cre):
	#Turn on window
	$HUDLayer/CreatureDisplay.visible = true
	
	#Turn off other windows
	$HUDLayer/ItemDisplay.visible = false
	
	#Populate the Window with passed creature data
	$HUDLayer/CreatureDisplay.setDisplayInfo(cre)
	
	#Update selected creature...
	selected_creature = cre

#Function that displays and populate the Item Display Window
#Called by individual item scenes when they are pressed
#also handles the closing/deselecting of other windows
func DisplayItem(item):
	#Turn on window
	$HUDLayer/ItemDisplay.visible = true
	
	#Turn off other windows
	$HUDLayer/CreatureDisplay.visible = false
	
	#Populate the window with the passed item data
	$HUDLayer/ItemDisplay.setDisplayInfo(item)

#Utility Functions To TOGGLE Canvas Layers
func CanvasLayerOff(canvas_layer):
	for child in canvas_layer.get_children():
		child.hide()
func CanvasLayerOn(canvas_layer):
	for child in canvas_layer.get_children():
		child.show()




