extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var direction_code #Code for which way it points -> 0123 : URDL

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	randomize()
	
	#random color
	modulate = Color(randf(), randf(), randf())
	
	#Pick a random direction
	direction_code = randi() % 4
	match(direction_code):
		0:
			$Sprite.position.y = 0 
			$Sprite.position.x = 0 
		1:
			rotation = PI/2
			$Sprite.position.y = - 16
			$Sprite.position.x = 0 
		2:
			rotation = PI
			$Sprite.position.y = - 16
			$Sprite.position.x = - 16
		3:
			rotation = -PI/2
			$Sprite.position.x = - 16
			$Sprite.position.y = 0 
	
	change_direction(randi() % 4)
	
	
	pass

#var total_delta = 0
#func _process(delta):
#
#	pass


func change_direction(code):
	direction_code = code
	match(direction_code):
		0:
			$Sprite.position.y = 0 
			$Sprite.position.x = 0 
		1:
			rotation = PI/2
			$Sprite.position.y = - 16
			$Sprite.position.x = 0 
		2:
			rotation = PI
			$Sprite.position.y = - 16
			$Sprite.position.x = - 16
		3:
			rotation = -PI/2
			$Sprite.position.x = - 16
			$Sprite.position.y = 0 



