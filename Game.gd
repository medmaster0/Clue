extends Node2D
export (PackedScene) var CellTile

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var mansion = RogueGen.GenerateMansion(Vector2(30,30))
	
	#Print out mansion 
	for row in mansion:
		print(row)
	
	#mansion = RogueGen.Rotate2DArray(mansion, "right")
	
	#Draw out the mansion...
	for i in range(mansion.size()):
		for j in range(mansion[0].size()):
			var new_cell = CellTile.instance()
			new_cell.position.x = 16 + i * $TileMap.cell_size.x
			new_cell.position.y = 16 + j * $TileMap.cell_size.y
			if mansion[i][j] == 0:
				new_cell.get_child(0).modulate = Color(1,0,0.78)
				add_child(new_cell)
			if mansion[i][j] == 1:
				new_cell.get_child(0).modulate = Color(0,0,0)
				add_child(new_cell)
			if mansion[i][j] == 2:
				new_cell.get_child(0).modulate = Color(1,1,1)
				add_child(new_cell)
			if mansion[i][j] == 3:
				new_cell.get_child(0).modulate = Color(0,1,0)
				add_child(new_cell)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
