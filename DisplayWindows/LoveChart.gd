extends Node2D

export (PackedScene) var Creature

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var placed_cres = [] #creatures taht have been placed
var min_distance = 16*4.5
var my_chart_data #will hold the chart data
var line_color #the color of the line connections

# Called when the node enters the scene tree for the first time.
func _ready():
	
	randomize()
	line_color = MedAlgo.generate_pink()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#called every time it's drawn
func _draw():
	#For each of the love connections.. draw a line
	for i in range(my_chart_data["num_creatures"]):
		for c in my_chart_data["web_of_love"][i]:
			# so i is lover index
			# so c is target index
			var ipos = placed_cres[i].position + Vector2(8,8) #Add an offset so we hit the middle of the sprite...
			var cpos = placed_cres[c].position + Vector2(8,8) #Add an offset so we hit the middle of the sprite...
			#draw the line
			draw_line(ipos, cpos, line_color, 4)
	

#Function that will load up (and draw) the input given love_chart data
#	var chart_data = {
#		"num_creatures" : num_neighbors, #the amount of neighbors in the chart
#		"web_of_love" : [] #a list of lists of lvoers of each creature 
#	}
# Basically draw the creatures scattered randomly (but spaced out)
func load_data(chart_data,map_creatures):
	
	#store the chart data
	my_chart_data = chart_data
	
	#Draw each of the creatures in a random position
	for i in range(chart_data["num_creatures"]):
		#copy
		var temp_cre = Creature.instance()
		add_child(temp_cre)
		temp_cre.CopyCreature(map_creatures[i])
		temp_cre.position = Vector2(randi()%(16*19), randi()%(16*30) + 50)
		
		#Don't stop until the position fits everything...
		#Check Against all of the placed cre
		var need_new_pos = false
		while(true):
			for p in range(placed_cres.size()):
				if distance(temp_cre.position, placed_cres[p].position) < min_distance:
					need_new_pos = true
					
			if(need_new_pos == true):
				temp_cre.position = Vector2(randi()%(16*19), randi()%(16*30) + 50)
				need_new_pos = false
			else:
				break
		
		#If it makes it out of here, it means we can place it...
		placed_cres.append(temp_cre)

#	#For each of the love connections.. draw a line
#	for i in range(chart_data["num_creatures"]):
#		for c in chart_data["web_of_love"][i]:
#			# so i is lover index
#			# so c is target index
			

##Utility FUNCtiNOS

func distance(vect1,vect2):
	var dist = sqrt(pow(vect1.x-vect2.x,2.0) + pow(vect1.y-vect2.y,2.0))
	return(dist)
