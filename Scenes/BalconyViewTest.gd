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
var view_cursor_position = Vector3(0,0,0) #where we are currently viewing... x, y, z
var view_mode = VIEW_MODE.birdseye #start in birds eye view

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

#Store Canvas Layers
#Here is the tricky part: There are list of node2D's. Each Node2D has canvas layer
#Basically, each node is a wrapper for the canvas layer
#We use it to turn off each of the canvas layers quickly
var birdseyeLayers = []
var balconyLayers = [] 

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
	
	# Generate the first floor
	var first_floor = RogueGen.GenerateMansion(Vector2(30,29))
	building_layout.append(first_floor)
	building_layout[0] = RogueGen.MansionWindowGen(building_layout[0], 10)
	# Generate the other floors
	for i in range(num_floors - 1):
		var new_room = RogueGen.GenerateMansionFloor(first_floor, 5, 2)
		building_layout.append(new_room)
		building_layout[i+1] = RogueGen.MansionWindowGen(building_layout[i+1],10)
	
	#Initialize canvas layers for each of the floors
	#BIRDSEYE
	for temp_floor in building_layout:
		var temp_canvas_layer = CanvasLayer.new()
		birdseyeLayers.append(temp_canvas_layer)
		add_child(temp_canvas_layer)
	#BALCONY
	for temp_slice in building_layout[0]: #cycling through the x dimensions...
		var temp_canvas_layer = CanvasLayer.new()
		balconyLayers.append(temp_canvas_layer)
		add_child(temp_canvas_layer)
	
	#Populate BOTH OF the sets of Canvas layers
	#BIRDSEYE
	for z in building_layout.size():
		for x in building_layout[0].size():
			for y in building_layout[0][0].size():
				if building_layout[z][x][y] == 0:
					continue #skip empty space...
				if building_layout[z][x][y] == 1:
					var new_building_item = Item.instance()
					new_building_item.position.y = y * $TileMap.cell_size.y
					new_building_item.position.x = x * $TileMap.cell_size.x
					birdseyeLayers[z].add_child(new_building_item)
					new_building_item.setTile(102)
					new_building_item.SetPrimColor(brick_color_prim)
					new_building_item.SetSecoColor(brick_color_seco)
				if building_layout[z][x][y] == 2:
					var new_building_item = Item.instance()
					new_building_item.position.y = y * $TileMap.cell_size.y
					new_building_item.position.x = x * $TileMap.cell_size.x
					birdseyeLayers[z].add_child(new_building_item)
					new_building_item.setTile(101)
					new_building_item.SetPrimColor(basic_floor_color_prim)
					new_building_item.SetSecoColor(basic_floor_color_seco)
				if building_layout[z][x][y] == 3:
					var new_building_item = Item.instance()
					new_building_item.position.y =  y * $TileMap.cell_size.y
					new_building_item.position.x =  x * $TileMap.cell_size.x
					birdseyeLayers[z].add_child(new_building_item)
					new_building_item.setTile(103)
					new_building_item.SetPrimColor(basic_door_color_prim)
					new_building_item.SetSecoColor(basic_door_color_seco)
				if building_layout[z][x][y] == 4:
					var new_building_item = Item.instance()
					new_building_item.position.y =  y * $TileMap.cell_size.y
					new_building_item.position.x =  x * $TileMap.cell_size.x
					birdseyeLayers[z].add_child(new_building_item)
					new_building_item.setTile(107)
					new_building_item.SetPrimColor(kitchen_floor_color_prim)
					new_building_item.SetSecoColor(kitchen_floor_color_seco)
				#PERSONAL ROOM (FLOOR) FURNITURE
				if building_layout[z][x][y] == 5:
					#CREATE THE FLOOR ITEM
					var new_building_item = Item.instance()
					new_building_item.position.y =  y * $TileMap.cell_size.y
					new_building_item.position.x =  x * $TileMap.cell_size.x
					birdseyeLayers[z].add_child(new_building_item)
					new_building_item.setTile(101)
					new_building_item.SetPrimColor(basic_floor_color_prim)
					new_building_item.SetSecoColor(basic_floor_color_seco)
					#CREATE THE RANDOM FURNITURE ITEM
					new_building_item = BattleHuntItem.instance()
					new_building_item.position.y = y * $TileMap.cell_size.y
					new_building_item.position.x = x * $TileMap.cell_size.x
					birdseyeLayers[z].add_child(new_building_item)
					var furniture_items = [402, 403, 404, 405, 406, 410]
					var choice = furniture_items[randi()%furniture_items.size()]
					new_building_item.setTile(choice)
					new_building_item.SetPrimColor(personal_room_furniture_prim)
					new_building_item.SetSecoColor(personal_room_furniture_seco)
				#PUBLIC ROOM (FLOOR) FURNITURE
				if building_layout[z][x][y] == 6:
					#CREATE THE FLOOR ITEM
					var new_building_item = Item.instance()
					new_building_item.position.y = y * $TileMap.cell_size.y
					new_building_item.position.x = x * $TileMap.cell_size.x
					birdseyeLayers[z].add_child(new_building_item)
					new_building_item.setTile(107)
					new_building_item.SetPrimColor(kitchen_floor_color_prim)
					new_building_item.SetSecoColor(kitchen_floor_color_seco)
					#CREATE THE RANDOM FURNITURE ITEM
					new_building_item = BattleHuntItem.instance()
					new_building_item.position.y = y * $TileMap.cell_size.y
					new_building_item.position.x = x * $TileMap.cell_size.x
					birdseyeLayers[z].add_child(new_building_item)
					var furniture_items = [401, 407, 408, 409, 410]
					var choice = furniture_items[randi()%furniture_items.size()]
					new_building_item.setTile(choice)
					new_building_item.SetPrimColor(public_room_furniture_prim)
					new_building_item.SetSecoColor(public_room_furniture_seco)
				if building_layout[z][x][y] == 9:
					var new_building_item = Item.instance()
					new_building_item.position.y =  y * $TileMap.cell_size.y
					new_building_item.position.x =  x * $TileMap.cell_size.x
					birdseyeLayers[z].add_child(new_building_item)
					new_building_item.setTile(108)
					new_building_item.SetPrimColor(brick_color_prim)
					new_building_item.SetSecoColor(brick_color_seco)
					new_building_item.SetTertColor(window_prim)
			

#	#BALCONY - Cycling through X layers
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


	
	#INitially, turn off all canvas layers
	for layer in birdseyeLayers:
		CanvasLayerOff(layer)
	for layer in balconyLayers:
		CanvasLayerOff(layer)
		
	CanvasLayerOn(birdseyeLayers[0])
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event.is_action_pressed("ui_up_level"):
		
		#TURN OFF OLD LAYER
		CanvasLayerOff(birdseyeLayers[view_cursor_position.z])
		
		view_cursor_position = view_cursor_position + Vector3(0,0,1)
		if view_cursor_position.z > num_floors - 1:
			view_cursor_position.z = num_floors - 1
		
		#TURN ON NEW LAYER
		CanvasLayerOn(birdseyeLayers[view_cursor_position.z])
		
	if event.is_action_pressed("ui_down_level"):
		
		#TURN OFF OLD LAYER
		CanvasLayerOff(birdseyeLayers[view_cursor_position.z])
		
		view_cursor_position = view_cursor_position + Vector3(0,0,-1)
		if view_cursor_position.z < 0:
			view_cursor_position.z = 0
		
		#TURN ON NEW LAYER
		CanvasLayerOn(birdseyeLayers[view_cursor_position.z])


#Utility Functions To TOGGLE Canvas Layers
func CanvasLayerOff(canvas_layer):
	for child in canvas_layer.get_children():
		child.hide()
func CanvasLayerOn(canvas_layer):
	for child in canvas_layer.get_children():
		child.show()