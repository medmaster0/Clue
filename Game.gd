extends Node2D
export (PackedScene) var CellTile
export (PackedScene) var Item
export (PackedScene) var Creature

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#Global variables
var mansion
var brick_color_prim
var brick_color_seco
var basic_floor_color_prim
var basic_floor_color_seco
var basic_door_color_prim
var basic_door_color_seco
var kitchen_floor_color_prim
var kitchen_floor_color_seco

var map_enemies = [] #list of creatures
var num_enemies = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	mansion = RogueGen.GenerateMansion(Vector2(30,30))
	
	#Clip space for cleanliness and ease of use
	mansion = RogueGen.BoundingBoxClipArray(mansion)
	
	# MANSION MPA Legend
	# 0 - Empty Space
	# 1 - WALL
	# 2 - FLOOR
	# 3 - DOOR
	
	####### COLOR INITIALIZATION
	brick_color_prim = Color(randf(), randf(), randf())
	brick_color_seco = Color(randf(), randf(), randf())
	basic_floor_color_prim = Color(randf(), randf(), randf())
	basic_floor_color_seco = Color(randf(), randf(), randf())
	basic_door_color_prim = Color(randf(), randf(), randf())
	basic_door_color_seco = Color(randf(), randf(), randf())	
	kitchen_floor_color_prim = Color(randf(), randf(), randf())
	kitchen_floor_color_seco = Color(randf(), randf(), randf())
	
	# Create the map enemies
	for i in range(num_enemies):
		var new_enemy = Creature.instance()
		add_child(new_enemy)
		new_enemy.z_index = new_enemy.z_index + 1
		new_enemy.position.y = 16
		new_enemy.position.x = 16 * i
		map_enemies.append(new_enemy)
	
	##Build out the mansion...
	for i in range(mansion.size()):
		for j in range(mansion[0].size()):
			if mansion[i][j] == 0:
				continue #skip empty space...
			if mansion[i][j] == 1:
				var new_building_item = Item.instance()
				new_building_item.position.y = 16 + j * $TileMap.cell_size.y
				new_building_item.position.x = 16 + i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(102)
				new_building_item.SetPrimColor(brick_color_prim)
				new_building_item.SetSecoColor(brick_color_seco)
				
			if mansion[i][j] == 2:
				var new_building_item = Item.instance()
				new_building_item.position.y = 16 + j * $TileMap.cell_size.y
				new_building_item.position.x = 16 + i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
			if mansion[i][j] == 3:
				var new_building_item = Item.instance()
				new_building_item.position.y = 16 + j * $TileMap.cell_size.y
				new_building_item.position.x = 16 + i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(103)
				new_building_item.SetPrimColor(basic_door_color_prim)
				new_building_item.SetSecoColor(basic_door_color_seco)
			if mansion[i][j] == 4:
				var new_building_item = Item.instance()
				new_building_item.position.y = 16 + j * $TileMap.cell_size.y
				new_building_item.position.x = 16 + i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(107)
				new_building_item.SetPrimColor(kitchen_floor_color_prim)
				new_building_item.SetSecoColor(kitchen_floor_color_seco)
	
	#Place map enemies in a random room...
	for i in range(map_enemies.size()):
		var floor_position = RogueGen.FindRandomTile(mansion, [2,4]) #find random floor pos
		map_enemies[i].position.x = floor_position.x * 16 + 16
		map_enemies[i].position.y = floor_position.y * 16 + 16
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if event.is_action_pressed("ui_up_level"):
		var new_room = RogueGen.OutlineBuilding(mansion)
		
		##How many successful splits to apply...
		var num_splits = 5
		var split_counter = 0
		while(split_counter < num_splits):
			var wall_return_data = RogueGen.WallLineBuilding(new_room)
			new_room = wall_return_data["out_array"]
			if wall_return_data["success"] == true:
				split_counter = split_counter + 1
		
		##ALso change the tile types up...
		var kitchen_rooms = 2 #how many times we will apply the fill alorithm to a floor...
		var rooms_changed = 0 #counter to keep track
		while(rooms_changed < kitchen_rooms):
			#Try to find a floor tile...
			var check_location = Vector2(0,0)
			while(true):
				#pick random location
				check_location.x = randi()%new_room.size()
				check_location.y = randi()%new_room[0].size()
				#check if it's a floor tile 2
				if(new_room[check_location.x][check_location.y] == 2):
					break
			#Now appliy the fill at this locaiton 
			new_room = RogueGen.FillTileArray(new_room, check_location, 4)
			rooms_changed = rooms_changed + 1
		
		
		##Build out the new room
		for i in range(new_room.size()):
			for j in range(new_room[0].size()):
				if new_room[i][j] == 0:
					continue #skip empty space...
				if new_room[i][j] == 1:
					var new_building_item = Item.instance()
					new_building_item.position.y = 16 + j * $TileMap.cell_size.y
					new_building_item.position.x = 16 + i * $TileMap.cell_size.x
					add_child(new_building_item)
					new_building_item.setTile(102)
					new_building_item.SetPrimColor(brick_color_prim)
					new_building_item.SetSecoColor(brick_color_seco)
					
				if new_room[i][j] == 2:
					var new_building_item = Item.instance()
					new_building_item.position.y = 16 + j * $TileMap.cell_size.y
					new_building_item.position.x = 16 + i * $TileMap.cell_size.x
					add_child(new_building_item)
					new_building_item.setTile(101)
					new_building_item.SetPrimColor(basic_floor_color_prim)
					new_building_item.SetSecoColor(basic_floor_color_seco)
				if new_room[i][j] == 3:
					var new_building_item = Item.instance()
					new_building_item.position.y = 16 + j * $TileMap.cell_size.y
					new_building_item.position.x = 16 + i * $TileMap.cell_size.x
					add_child(new_building_item)
					new_building_item.setTile(103)
					new_building_item.SetPrimColor(basic_door_color_prim)
					new_building_item.SetSecoColor(basic_door_color_seco)
				if new_room[i][j] == 4:
					var new_building_item = Item.instance()
					new_building_item.position.y = 16 + j * $TileMap.cell_size.y
					new_building_item.position.x = 16 + i * $TileMap.cell_size.x
					add_child(new_building_item)
					new_building_item.setTile(107)
					new_building_item.SetPrimColor(kitchen_floor_color_prim)
					new_building_item.SetSecoColor(kitchen_floor_color_seco)
			
		#Place map enemies in a random room...
		for i in range(map_enemies.size()):
			var floor_position = RogueGen.FindRandomTile(new_room, [2,4]) #find random floor pos
			map_enemies[i].position.x = floor_position.x * 16 + 16
			map_enemies[i].position.y = floor_position.y * 16 + 16
		
		
		