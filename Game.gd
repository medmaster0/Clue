extends Node2D
export (PackedScene) var CellTile
export (PackedScene) var Item

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

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	mansion = RogueGen.GenerateMansion(Vector2(30,30))
	# MANSION MPA Legend
	# 0 - Empty Space
	# 1 - WALL
	# 2 - FLOOR
	# 3 - DOOR
	
	#######
	brick_color_prim = Color(randf(), randf(), randf())
	brick_color_seco = Color(randf(), randf(), randf())
	basic_floor_color_prim = Color(randf(), randf(), randf())
	basic_floor_color_seco = Color(randf(), randf(), randf())
	basic_door_color_prim = Color(randf(), randf(), randf())
	basic_door_color_seco = Color(randf(), randf(), randf())	
	kitchen_floor_color_prim = Color(randf(), randf(), randf())
	kitchen_floor_color_seco = Color(randf(), randf(), randf())
	
	#Print out mansion 
	for row in mansion:
		print(row)
	
	#mansion = RogueGen.Rotate2DArray(mansion, "right")
	
#	#Draw out the mansion...
#	for i in range(mansion.size()):
#		for j in range(mansion[0].size()):
#			var new_cell = CellTile.instance()
#			new_cell.position.x = 16 + i * $TileMap.cell_size.x
#			new_cell.position.y = 16 + j * $TileMap.cell_size.y
#			if mansion[i][j] == 0:
#				new_cell.get_child(0).modulate = Color(1,0,0.78)
#				add_child(new_cell)
#			if mansion[i][j] == 1:
#				new_cell.get_child(0).modulate = Color(0,0,0)
#				add_child(new_cell)
#			if mansion[i][j] == 2:
#				new_cell.get_child(0).modulate = Color(1,1,1)
#				add_child(new_cell)
#			if mansion[i][j] == 3:
#				new_cell.get_child(0).modulate = Color(0,1,0)
#				add_child(new_cell)
				
	
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
			
		
		
		
		