extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#The hardcoded colors of the 3 types of dirt colors we want....
#Can later be genned...
var dirt_colors = [Color(0.77, 0.61, 0.55), Color(0.72, 0.5333, 0.44), Color(0.7, 0.44, 0.35)]
#The dirt pattern....
#Three colors, shades of brown
#Each one progressively darker red
#(Start with three random shades of red)
#The first brown has a r-g difference and a g-b difference
#These are constant accross each brown
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	randomize()
	
	#Generate and change to new dirt pallete colors
	dirt_colors[0] = MedAlgo.generate_dirt_color()
	dirt_colors[1] = MedAlgo.generate_dirt_color()
	dirt_colors[2] = MedAlgo.generate_dirt_color()
	
	#Choose a random dirt color
	var dirt_color = dirt_colors[ randi() % dirt_colors.size() ]
	#var dirt_color = MedAlgo.generate_dirt_color()
	#^^^^^^ SKIN COLOR looks good for skin but not for dirt....
	#^^^^TODO: but still wanna generate dirt colors somehow one day...
	# The skin color a good start, but needs more Land of Enchantment reds swirled in there :)))
	# TODO: add red shade to skin color -> dirt_color = skin_color + red_shade
	$DirtSprite.modulate = dirt_color
	
	#Decide if we want gravel
	var decision = randi()%4 
	if decision == 0:
		#Choose a random gravel to turn on ....
		var choice = randi()%3
		match(choice):
			0:
				$Gravel1.visible = true
			1:
				$Gravel2.visible = true
			2:
				$Gravel3.visible = true
		
		#If there was gravel... Also posibly rotate the square...
		var rotate_choice = randi()%4
		match(rotate_choice):
			0:
				rotation = 0
			1:
				rotation = PI/2
				position.x = position.x + 16
			2:
				rotation = PI
				position.y = position.y + 16
				position.x = position.x + 16
			3:
				rotation = -PI/2
				position.y = position.y + 16
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
