extends Node2D
export (PackedScene) var CellTile
export (PackedScene) var Item
export (PackedScene) var Creature
export (PackedScene) var ZodiacTile
export (PackedScene) var Arrow
export (PackedScene) var BattleHuntItem

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
var personal_room_furniture_prim
var personal_room_furniture_seco
var public_room_furniture_prim
var public_room_furniture_seco
var window_prim

var map_enemies = [] #list of creatures
#var num_enemies = 3
#DEBUG
var num_enemies = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#seed(7)
	
	mansion = RogueGen.GenerateMansion(Vector2(30,29))
	
	#Clip space for cleanliness and ease of use
	mansion = RogueGen.BoundingBoxClipArray(mansion)
	mansion = RogueGen.MansionFurnitureGen(mansion)
	mansion = RogueGen.MansionWindowGen(mansion, 10)
	
	# MANSION MPA Legend
	# 0 - Empty Space
	# 1 - WALL
	# 2 - FLOOR
	# 3 - DOOR
	# 4 - KITCHEN FLOOR
	# 5 - PERSONAL ROOM FURNITURE (has floor, but also furniture)
	# 6 - PUBLIC ROOM FURNITURE (has floor, but also furniture)
	# 7 - PERSONAL ROOM ITEM (has floor, but also item)
	# 8 - PUBLIC ROOM ITEM (has floor, but also item)
	# 9 - WINDOW
	
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
	window_prim = Color(randf(), randf(), randf(), 0.75) #make it transparent
	
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
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(102)
				new_building_item.SetPrimColor(brick_color_prim)
				new_building_item.SetSecoColor(brick_color_seco)
				
			if mansion[i][j] == 2:
				var new_building_item = Item.instance()
				new_building_item.position.y = j * $TileMap.cell_size.y
				new_building_item.position.x = i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(101)
				new_building_item.SetPrimColor(basic_floor_color_prim)
				new_building_item.SetSecoColor(basic_floor_color_seco)
			if mansion[i][j] == 3:
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(103)
				new_building_item.SetPrimColor(basic_door_color_prim)
				new_building_item.SetSecoColor(basic_door_color_seco)
			if mansion[i][j] == 4:
				var new_building_item = Item.instance()
				new_building_item.position.y =  j * $TileMap.cell_size.y
				new_building_item.position.x =  i * $TileMap.cell_size.x
				add_child(new_building_item)
				new_building_item.setTile(107)
				new_building_item.SetPrimColor(kitchen_floor_color_prim)
				new_building_item.SetSecoColor(kitchen_floor_color_seco)
			#PERSONAL ROOM (FLOOR) FURNITURE
			if mansion[i][j] == 5:
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
			if mansion[i][j] == 6:
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
			if mansion[i][j] == 9:
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
			if mansion[i][j] == 101:
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
			if mansion[i][j] == 102:
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
			if mansion[i][j] == 103:
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
			if mansion[i][j] == 104:
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
			if mansion[i][j] == 105:
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
			if mansion[i][j] == 106:
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


	#Place map enemies in a random room...
	for i in range(map_enemies.size()):
		var floor_position = RogueGen.FindRandomTile(mansion, [2,4]) #find random floor pos
		map_enemies[i].position.x = floor_position.x * 16 
		map_enemies[i].position.y = floor_position.y * 16
	#For each enemy, find a clockwise path for it around it's room...
	for i in range(map_enemies.size()):
		#Need to translate position to MAP COORDS
		var map_posiiton = $TileMap.world_to_map(map_enemies[i].position)
		map_enemies[i].path = RogueGen.PathAroundRoom(mansion, map_posiiton)
	
	####STORY MYSTERY GEENRATION!!!  ############################
	########
	# There are 4 possible VITAL World Relationship Charts
	# Corresponding to murderer's element
	# 
	# First arrange the VITAL chart with the motive set up
	# 	This will involve choosing and possibly arranging some of the other creature's elements
	# Then randomly assign the remaining creatures elements
	# Then generate the remaining charts
	# 	Some charts can be straight up random
	#	Others will be dependent on the neighbors' existing elements (shouldn't need to change elements at this point though)
	# Introduce some red herrings?
	# 	Change the color of other creatures to match the murderer (SPARINGLY - 3 tops)
	#	Change the clothing of other creatures to match murderer (SPARINGLY - 3 tops) -> type but no color copy
	#######	
	
	# Create the characters....
	var num_neighbors = 18
	var map_neighbors = [] 
	for i in range(num_neighbors):
		var new_cre = Creature.instance()
		add_child(new_cre)
		new_cre.position.y = 16*30
		new_cre.position.x = 32*i + 16
		map_neighbors.append(new_cre)
#		#Also generate an appropriate zodiac tile under them.
#		var new_zod_sym = ZodiacTile.instance()
#		add_child(new_zod_sym)
#		new_zod_sym.change_symbol(new_cre.zodiac_sign)
#		new_zod_sym.position.y = 16*31
#		new_zod_sym.position.x = new_cre.position.x
	
	#Generate the premise i.e. MURDER
	var murderer_arrow = Arrow.instance()
	add_child(murderer_arrow)
	murderer_arrow.modulate = Color(1.0,0.0,0.7)
	var murderer_index = randi()%num_neighbors
	murderer_arrow.change_direction(2)
	murderer_arrow.position.y = 16*28 + 8
	murderer_arrow.position.x = 32*murderer_index + 16
	var victim_arrow = Arrow.instance()
	add_child(victim_arrow)
	victim_arrow.modulate = Color(0.7, 0.0, 1.0)
	var victim_index = randi()%num_neighbors
	#Make sure vicitm isn't the same as murderer (no suicide in this game)
	while(victim_index == murderer_index):
		victim_index = randi()%num_neighbors
	victim_arrow.change_direction(2)
	victim_arrow.position.y = 16*28 + 8
	victim_arrow.position.x = 32*victim_index + 16
	
	#Duplicate the murderer and the victim below
	#Murderer
	var temp_cre = map_neighbors[murderer_index].duplicate()
	add_child(temp_cre)
	temp_cre.position = Vector2(320,16*33)
	temp_cre.CopyCreature(map_neighbors[murderer_index])
	#Victim
	temp_cre = map_neighbors[victim_index].duplicate()
	add_child(temp_cre)
	temp_cre.position = Vector2(320 + 6*16,16*33)
	temp_cre.CopyCreature(map_neighbors[victim_index])
	
	#Identify motive (based on randomly chosen murderer's element)
	var motive_element = Story.find_element(map_neighbors[murderer_index].zodiac_sign)
	## Murder Weapon...
	## IMPORTANT ITEMS:
	## COIN - 107
	## DAGGER - 117
	## WAND - 130
	## CUP - 106
	var temp_weapon = BattleHuntItem.instance()
	add_child(temp_weapon)
	match(motive_element):
		0:
			temp_weapon.setTile(106)
		1:
			temp_weapon.setTile(130)
		2:
			temp_weapon.setTile(107)
		3:
			temp_weapon.setTile(117)
	temp_weapon.position = Vector2(368,568)
	
	#Generate the charts
	var wealth_chart = Story.GenreateNeighborWealthChart(num_neighbors)
	$WealthChart.load_data(wealth_chart,map_neighbors)
	var love_chart = Story.GenreateNeighborLoveChart(num_neighbors, map_neighbors)
	$LoveChart.load_data(love_chart,map_neighbors)
	var power_chart = Story.GenerateNeighborPowerChart(num_neighbors)
	#print(power_chart)
	
	#DEBUG
	power_chart = Story.GenerateNeighborPowerChart(40)
	print(power_chart)
	
	#Seed the VITAL CHART
	
	
	##################### END STORY MYSTERY GEN
	
	
	
	pass # Replace with function body.
	
	#Gener
	

#Called every frame. 'delta' is the elapsed time since the previous frame.
var room_timer = 0 #keeps track of when the current room was created
func _process(delta):
	
	if room_timer > 2:
		#Creature Tasking...
		for enemy in map_enemies:
			if enemy.path.size() == 0:
				#Need to translate position to MAP COORDS
				var map_posiiton = $TileMap.world_to_map(enemy.position)
				enemy.path = RogueGen.PathAroundRoom(mansion, map_posiiton)
	
	#Update timers
	room_timer = room_timer + delta
	
	pass


func _input(event):
	if event.is_action_pressed("ui_up_level"):
		var new_room = RogueGen.GenerateMansionFloor(mansion, 5, 2)
		
		##Build out the new room
		for i in range(new_room.size()):
			for j in range(new_room[0].size()):
				if new_room[i][j] == 0:
					continue #skip empty space...
				if new_room[i][j] == 1:
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					add_child(new_building_item)
					new_building_item.setTile(102)
					new_building_item.SetPrimColor(brick_color_prim)
					new_building_item.SetSecoColor(brick_color_seco)
					
				if new_room[i][j] == 2:
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					add_child(new_building_item)
					new_building_item.setTile(101)
					new_building_item.SetPrimColor(basic_floor_color_prim)
					new_building_item.SetSecoColor(basic_floor_color_seco)
				if new_room[i][j] == 3:
					var new_building_item = Item.instance()
					new_building_item.position.y = j * $TileMap.cell_size.y
					new_building_item.position.x = i * $TileMap.cell_size.x
					add_child(new_building_item)
					new_building_item.setTile(103)
					new_building_item.SetPrimColor(basic_door_color_prim)
					new_building_item.SetSecoColor(basic_door_color_seco)
				if new_room[i][j] == 4:
					var new_building_item = Item.instance()
					new_building_item.position.y =  j * $TileMap.cell_size.y
					new_building_item.position.x =  i * $TileMap.cell_size.x
					add_child(new_building_item)
					new_building_item.setTile(107)
					new_building_item.SetPrimColor(kitchen_floor_color_prim)
					new_building_item.SetSecoColor(kitchen_floor_color_seco)
		
		#update the date in the mansion layout
		mansion = new_room
		
		
			
		#Delete old enemies
		for i in range(map_enemies.size()):
			remove_child(map_enemies[i])
		#Generate new enemies
		for i in range(num_enemies):
			var new_enemy = Creature.instance()
			add_child(new_enemy)
			new_enemy.z_index = new_enemy.z_index + 1
			new_enemy.position.y = 16
			new_enemy.position.x = 16 * i
			map_enemies.append(new_enemy)
		#Place map enemies in a random room...
		for i in range(map_enemies.size()):
			var floor_position = RogueGen.FindRandomTile(mansion, [2,4]) #find random floor pos
			map_enemies[i].position.x = floor_position.x * 16 
			map_enemies[i].position.y = floor_position.y * 16 
		#For each enemy, find a clockwise path for it around it's room...
		for i in range(map_enemies.size()):
			#Need to translate position to MAP COORDS
			var map_posiiton = $TileMap.world_to_map(map_enemies[i].position)
			map_enemies[i].path = RogueGen.PathAroundRoom(mansion, map_posiiton)
		
		#Reset room timer
		room_timer = 0
