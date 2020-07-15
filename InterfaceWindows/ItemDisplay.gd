extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#DISABLE Select button
	$Item/SelectButton.visible = false
	

#Populate the display fields with input item
func setDisplayInfo(item):
	$NameLabel.text = "Type: " + item.item_name
	$Item.setTile(item.tile_index)
	$Item.SetPrimColor(item.primColor)
	$Item.SetSecoColor(item.secoColor)
	$Item.SetTertColor(item.tertColor)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
