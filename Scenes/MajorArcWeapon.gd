extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# MASTER WEAPON LIST
# 00 - The Fool's Bindle
# 01 - The Magician's Staff
# 02 - The Priestess' Feather
# 03 - The Empress' Shield
# 04 - The Emperor's Knife
# 05 - The Hierophant's Sceptre
# 06 - The Lover's Fruit
# 07 - The Chariot's Whip
# 08 - The Strength's Pillar
# 09 - The Hermit's Lamp
# 10 - The Fortune's Dice
# 11 - The Justice's Scales
# 12 - The Hangman's Rope
# 13 - The Death's Scythe
# 14 - The Temperance's Cup
# 15 - The Devil's Chain
# 16 - The Tower's Stone
# 17 - The Star's Coin
# 18 - The Moon's Crayfish
# 19 - The Sun's Lens
# 20 - The Judgement's Trumpet
# 21 - The World's Scroll

#LOAD UP ALL THE SPRITES>>>>
#Resources Load

var maj00Prim = preload("res://Tiles//major_arc//maj00Prim.png")
var maj00Seco = preload("res://Tiles//major_arc//maj00Seco.png")

var maj01Prim = preload("res://Tiles//major_arc//maj01Prim.png")
var maj01Seco = preload("res://Tiles//major_arc//maj01Seco.png")
var maj01Tert = preload("res://Tiles//major_arc//maj01Tert.png")

var maj02Prim = preload("res://Tiles//major_arc//maj02Prim.png")
var maj02Seco = preload("res://Tiles//major_arc//maj02Seco.png")

var maj03Prim = preload("res://Tiles//major_arc//maj03Prim.png")
var maj03Seco = preload("res://Tiles//major_arc//maj03Seco.png")

var maj04Prim = preload("res://Tiles//major_arc//maj04Prim.png")
var maj04Seco = preload("res://Tiles//major_arc//maj04Seco.png")

var maj05Prim = preload("res://Tiles//major_arc//maj05Prim.png")
var maj05Seco = preload("res://Tiles//major_arc//maj05Seco.png")

var maj06Prim = preload("res://Tiles//major_arc//maj06Prim.png")
var maj06Seco = preload("res://Tiles//major_arc//maj06Seco.png")

var maj07Prim = preload("res://Tiles//major_arc//maj07Prim.png")
var maj07Seco = preload("res://Tiles//major_arc//maj07Seco.png")

var maj08Prim = preload("res://Tiles//major_arc//maj08Prim.png")

var maj09Prim = preload("res://Tiles//major_arc//maj09Prim.png")

var maj10Prim = preload("res://Tiles//major_arc//maj10Prim.png")
var maj10Seco = preload("res://Tiles//major_arc//maj10Seco.png")

var maj11Prim = preload("res://Tiles//major_arc//maj11Prim.png")
var maj11Seco = preload("res://Tiles//major_arc//maj11Seco.png")

var maj12Prim = preload("res://Tiles//major_arc//maj12Prim.png")
var maj12Seco = preload("res://Tiles//major_arc//maj12Seco.png")

var maj13Prim = preload("res://Tiles//major_arc//maj13Prim.png")
var maj13Seco = preload("res://Tiles//major_arc//maj13Seco.png")

var maj14Prim = preload("res://Tiles//major_arc//maj14Prim.png")
var maj14Seco = preload("res://Tiles//major_arc//maj14Seco.png")

var maj15Prim = preload("res://Tiles//major_arc//maj15Prim.png")

var maj16Prim = preload("res://Tiles//major_arc//maj16Prim.png")

var maj17Prim = preload("res://Tiles//major_arc//maj17Prim.png")
var maj17Seco = preload("res://Tiles//major_arc//maj17Seco.png")

var maj18Prim = preload("res://Tiles//major_arc//maj18Prim.png")
var maj18Seco = preload("res://Tiles//major_arc//maj18Seco.png")

var maj19Prim = preload("res://Tiles//major_arc//maj19Prim.png")
var maj19Seco = preload("res://Tiles//major_arc//maj19Seco.png")
var maj19Tert = preload("res://Tiles//major_arc//maj19Tert.png")

var maj20Prim = preload("res://Tiles//major_arc//maj20Prim.png")
var maj20Seco = preload("res://Tiles//major_arc//maj20Seco.png")

var maj21Prim = preload("res://Tiles//major_arc//maj21Prim.png")
var maj21Seco = preload("res://Tiles//major_arc//maj21Seco.png")

#Class Variables
var primColor
var secoColor
var tertColor
var tile_index 
var item_name #a string to be shown when selected

# Called when the node enters the scene tree for the first time.
func _ready():
	
	randomize()
	
	#Pick colors
	primColor = Color(randf(), randf(), randf())
	secoColor = Color(randf(), randf(), randf())
	tertColor = Color(1.0, 1.0, 1.0) #Tert color is always white
	
	#Set colors
	$Prim.modulate = primColor
	$Seco.modulate = secoColor
	$Tert.modulate = tertColor
	
	#Pick random tile_index (set here for debug purposesssss)
	tile_index = randi()%22
	setTile(tile_index)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setTile(in_tile_index):
	tile_index = in_tile_index
	match tile_index:
		0:
			#The Fool's Bindle
			item_name = "bindle"
			$Prim.texture = maj00Prim
			$Seco.texture = maj00Seco
			$Tert.texture = null
		1:
			#The Magician's Staff
			item_name = "staff"
			$Prim.texture = maj01Prim
			$Seco.texture = maj01Seco
			$Tert.texture = maj01Tert
		2:
			#The Priestess' Feather
			item_name = "feather"
			$Prim.texture = maj02Prim
			$Seco.texture = maj02Seco
			$Tert.texture = null
		3:
			#The Empress' Shield
			item_name = "shield"
			$Prim.texture = maj03Prim
			$Seco.texture = maj03Seco
			$Tert.texture = null
		4:
			#The Emperor's Knife
			item_name = "knife"
			$Prim.texture = maj04Prim
			$Seco.texture = maj04Seco
			$Tert.texture = null
		5:
			#The Hierophant's Sceptre
			item_name = "sceptre"
			$Prim.texture = maj05Prim
			$Seco.texture = maj05Seco
			$Tert.texture = null
		6:
			#The Lover's Fruit
			item_name = "fruit"
			$Prim.texture = maj06Prim
			$Seco.texture = maj06Seco
			$Tert.texture = null
		7:
			#The Chariot's Whip
			item_name = "whip"
			$Prim.texture = maj07Prim
			$Seco.texture = maj07Seco
			$Tert.texture = null
		8:
			#The Strength's Pillar
			item_name = "pillar"
			$Prim.texture = maj08Prim
			$Seco.texture = null
			$Tert.texture = null
		9:
			#The Hermit's Lamp
			item_name = "lamp"
			$Prim.texture = maj09Prim
			$Seco.texture = null
			$Tert.texture = null
		10:
			#The Fortune's Dice
			item_name = "dice"
			$Prim.texture = maj10Prim
			$Seco.texture = maj10Seco
			$Tert.texture = null
		11:
			#The Justice's Scales
			item_name = "scales"
			$Prim.texture = maj11Prim
			$Seco.texture = maj11Seco
			$Tert.texture = null
		12:
			#The Hangman's Rope
			item_name = "rope"
			$Prim.texture = maj12Prim
			$Seco.texture = maj12Seco
			$Tert.texture = null
		13:
			#The Death's Scythe
			item_name = "scythe"
			$Prim.texture = maj13Prim
			$Seco.texture = maj13Seco
			$Tert.texture = null
		14:
			#The Temperance's Cup
			item_name = "cup"
			$Prim.texture = maj14Prim
			$Seco.texture = maj14Seco
			$Tert.texture = null
		15:
			#The Devil's Chain
			item_name = "chain"
			$Prim.texture = maj15Prim
			$Seco.texture = null
			$Tert.texture = null
		16:
			#The Tower's Stone
			item_name = "stone"
			$Prim.texture = maj16Prim
			$Seco.texture = null
			$Tert.texture = null
		17:
			#The Star's Coin
			item_name = "coin"
			$Prim.texture = maj17Prim
			$Seco.texture = maj17Seco
			$Tert.texture = null
		18:
			#The Moon's Crayfish
			item_name = "crayfish"
			$Prim.texture = maj18Prim
			$Seco.texture = maj18Seco
			$Tert.texture = null
		19:
			#The Sun's Lens
			item_name = "lens"
			$Prim.texture = maj19Prim
			$Seco.texture = maj19Seco
			$Tert.texture = maj19Tert
		20:
			#The Judgement's Trumpet
			item_name = "trumpet"
			$Prim.texture = maj20Prim
			$Seco.texture = maj20Seco
			$Tert.texture = null
		21:
			#The World's Scroll
			item_name = "scroll"
			$Prim.texture = maj21Prim
			$Seco.texture = maj21Seco
			$Tert.texture = null
			


#Will copy all of the parameters of the given weapon
func copy_weapon(in_weapon):
	#Set the right index
	setTile(in_weapon.tile_index)
			
	#Also copy the colors...
	change_colors(in_weapon.primColor, in_weapon.secoColor, in_weapon.tertColor)

#Changes the colors of the sprites
func change_colors(inPrim, inSeco, inTert):
	primColor = inPrim
	$Prim.modulate = primColor
	secoColor = inSeco
	$Seco.modulate = secoColor
	tertColor = inTert
	$Tert.modulate = tertColor