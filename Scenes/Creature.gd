extends Node2D

onready var map = get_parent().find_node("TileMap")


#Movement stuff
var step_tick = 0.5 #time period for each step
var step_timer = 0 #will help keep track of when we stepped
var path = [] #A set of steps to follow in pathfinding (usually set outside)
var last_position #a position vector, keeping track of what tile we came from (for positioning)
var map_coords = Vector3(0,0,0) #the map coords of the creature....

#ALCHEMY SPECIFIC STUFF  (kept for reference.....)
#export (PackedScene) var MaterialSymbol #has to create it's own material for picking up
#export (PackedScene) var InstrumentSymbol #has to create it's own material for picking up
var carried_item = null #keeps track of an item the creature is holding
var need_material = true #flag to keep track of creature's behavior, tastks
var need_to_take_material = true # " "
var need_instrument = true # " " 
var need_to_take_instrument = true # " " 
var need_to_start_cooking = true # " "
var need_to_finish_cooking = true # " " 
#Timers an shit
var cooking_timer = 0 #Will accumulate the amount of time since started cooking shit

#ROGUE CIV SPECIFIC STUFF
var creature_name = null ; #The name of the creature...
var primColor = null; #keep track of the color of the creature
var zodiac_sign = null; #the number of the Zodiac sign 0-Aries, 11-Pisces
var fave_color = null; #the color the creature always likes going for

#Dungeon Stuff - Every Creature has it's own dungeon it crawls through...
var dungeon_map = null; #a pointer to the current dungeon creature is crawling through

##GOD DAMN...
## Stealth Mansion Stuff


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	randomize()
	
	#Add color
	$Sprite.modulate = Color(randf(), randf(), randf())
	primColor = $Sprite.modulate
	
	#Generate Name...
	creature_name = MedAlgo.generateName()
	
	#Pick random Zodiac Sign
	zodiac_sign = randi()%12; 
	
	#Pick random fave color
	fave_color = Color(randf(), randf(), randf())
	
	#Random step tick?
	step_tick = rand_range(0.25,0.75)
	
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	
	step_timer = step_timer + delta
	if step_timer > step_tick:
		path_step()
		#update timer
		step_timer = step_timer - step_tick
	
	
	
	pass

#A function that takes a step in the stored path
#Returns true if done with path
#Returns false if not
###GOTTA MAKE SURE THIS MAP VARIABLE GETS SET OUTSIDE TOO....
func path_step():
	
	last_position = position #register the current position
	
	if path.size() == 0:
		return(true) #Do nothing since there are no more steps left
	
	#Take the first Vector2 in the list
	var next_coords = path.pop_front()
	
	#Move the Creature there (remember to convert to world coords from map)
	position = map.map_to_world(Vector2(next_coords.x, next_coords.y))
	
	#Also adjust the total world map coords
	map_coords = Vector3(next_coords.x, next_coords.y, map_coords.z)
	
#	#Position the carried weapon if necessary
#	if position.y > last_position.y: #then walked down
#		$MajorArcWeapon.position.y = -16
#		$MajorArcWeapon.position.x = 0
#	if position.y < last_position.y: #then walked up
#		$MajorArcWeapon.position.y = 16
#		$MajorArcWeapon.position.x = 0
#	if position.x < last_position.x: #then walked left
#		$MajorArcWeapon.position.y = 0
#		$MajorArcWeapon.position.x = 16	
#	if position.x > last_position.x: #then walked right
#		$MajorArcWeapon.position.y = 0
#		$MajorArcWeapon.position.x = -16	

####CLASS FUNCS
#Set the primColor
func SetPrimColor(color):
	primColor = color; 
	$Sprite.modulate = primColor

#FUnction that copies everything about another creature...
func CopyCreature(in_cre):
	SetPrimColor(in_cre.primColor)
	find_node("Clothes").copy_clothes(in_cre.find_node("Clothes"))
	zodiac_sign = in_cre.zodiac_sign
	fave_color = in_cre.fave_color

func _on_SelectButton_pressed():
	#Displaying the crature
	get_parent().DisplayCreature(self)
	#pass creature data to parent scene's (Game's) CreatureDisplayFunction