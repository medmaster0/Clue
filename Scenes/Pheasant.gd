extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var primCol
var secoCol
var tertCol
var quadCol

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	primCol = Color(randf(), randf(), randf())
	secoCol = Color(randf(), randf(), randf())
	tertCol = Color(randf(), randf(), randf())
	quadCol = Color(randf(), randf(), randf())
	
	$ONE_Tail/Prim.modulate = primCol
	$ONE_Tail/Seco.modulate = secoCol
	$ONE_Tail/Tert.modulate = tertCol
	$ONE_Tail/Quad.modulate = quadCol
	
	$TWO_Tail/Prim.modulate = primCol
	$TWO_Tail/Seco.modulate = secoCol
	$TWO_Tail/Tert.modulate = tertCol
	$TWO_Tail/Quad.modulate = quadCol
	
	$TRE_Tail/Prim.modulate = primCol
	$TRE_Tail/Seco.modulate = secoCol
	$TRE_Tail/Tert.modulate = tertCol
	$TRE_Tail/Quad.modulate = quadCol
	
	#randomly choose how many tails
	match(randi()%3):
		0:
			$ONE_Tail.visible = true
		1:
			$TWO_Tail.visible = true
		2:
			$TRE_Tail.visible = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
