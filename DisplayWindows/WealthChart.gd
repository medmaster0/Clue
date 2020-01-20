extends Node2D

export (PackedScene) var Creature
export (PackedScene) var BattleHuntItem

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body

#Function that will load up (and draw) the input given wealth_chart data
# Chart data looks as folllows:
#	var chart_data = {
#		"num_creatures" : num_neighbors, #the amount of neighbors in the chart
#		"num_currencies" : 2 + randi()%3, #generate how many currencies there will be
#		"currency_colors_prim" : [], #A list of colors (prim) for each currency
#		"currency_colors_seco" : [], #A list of colors (seco) for each currency
#		"creature_wealth_chart" : [] #A 2D list containing wealth. access: chart[cre_index][currency_index] = how many coins of currency
#	}
func load_data(chart_data,map_creatures):
	#Draw the creatures in an up and down line
	for i in range(chart_data["num_creatures"]):
		# Draw the creatures in a line
		var temp_cre = Creature.instance()
		add_child(temp_cre)
		temp_cre.CopyCreature(map_creatures[i])
		temp_cre.position.x = 16
		temp_cre.position.y = 16 + i*32
		
	#Draw the Coins... 
	for i in range(chart_data["num_creatures"]):
		for j in range(chart_data["num_currencies"]):
			var temp_coin = BattleHuntItem.instance()
			add_child(temp_coin)
			temp_coin.setTile(107)
			temp_coin.SetPrimColor(chart_data["currency_colors_prim"][j])
			temp_coin.SetSecoColor(chart_data["currency_colors_seco"][j])
			temp_coin.position.x = 16 + 64 + 64 * j
			temp_coin.position.y = 16 + i*32
	
	#Generate teh labels
	for i in range(chart_data["num_creatures"]):
		for j in range(chart_data["num_currencies"]):
			var label = Label.new()
			add_child(label)
			label.margin_left = 16 + 128 + 64 * j - 48
			label.margin_top = 16 + i*32 + 4
			label.text = str(chart_data["creature_wealth_chart"][i][j])
	








# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
