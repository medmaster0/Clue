extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var prufer_code = Story.GeneratePruferCode(5)
	#prufer_code = [3,0,2,3]
	print("Prufer Code:")
	print(prufer_code)
	
	var edges = Story.EdgesFromPruferCode(prufer_code)
	print("Edges")
	print(edges)
	
	var tree = Story.TreeFromEdges(edges)
	print("Tree")
	print(tree)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
