extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (PackedScene) var Pheasant
export (PackedScene) var MajorArcWeapon
export (PackedScene) var Item
export (PackedScene) var BattleHuntItem
export (PackedScene) var Creature

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	for i in range(30):
		var temp_bird = Pheasant.instance()
		temp_bird.position = Vector2(randi()%int(get_viewport().size.x), randi()%int(get_viewport().size.y))
		add_child(temp_bird)
#
	for i in range(300):
		var temp_weapon = MajorArcWeapon.instance()
		temp_weapon.position = Vector2(randi()%int(get_viewport().size.x), randi()%int(get_viewport().size.y))
		add_child(temp_weapon)
#
	for i in range(300):
		var temp_item = BattleHuntItem.instance()
		temp_item.position = Vector2(randi()%int(get_viewport().size.x), randi()%int(get_viewport().size.y))
		add_child(temp_item)
		#temp_item.setTile(201 + randi()%15)

	var temp_item = Item.instance()
	temp_item.position = Vector2(16,16)
	add_child(temp_item)
	temp_item.setTile(202)
	temp_item.rotateSprites(6)
	
	temp_item = Item.instance()
	temp_item.position = Vector2(0,0)
	add_child(temp_item)
	temp_item.setTile(202)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
