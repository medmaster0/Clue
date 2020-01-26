extends Node

#Set of functions for story-telling

#Zodiac compatibility Chart
# 0 - compatible
# 1 - less compatible
# 2 - non-compatible 

var zodiac_compatibility = [

    [0,1,0,2,0,1,0,1,0,2,0,1], #Aries
    [1,0,1,0,2,0,1,0,1,0,2,0], #Taurus
    [0,1,0,1,0,2,0,1,0,1,0,2], #Gemini
    [2,0,1,0,1,0,2,0,1,0,1,0], #Cancer
    [0,2,0,1,0,1,0,2,0,1,0,1], #Leo
    [1,0,2,0,1,0,1,0,2,0,1,0], #Virgo
    [0,1,0,2,0,1,0,1,0,2,0,1], #Libra
    [1,0,1,0,2,0,1,0,1,0,2,0], #Scorpio
    [0,1,0,1,0,2,0,1,0,1,0,2], #Sagittarius
    [2,0,1,0,1,0,2,0,1,0,1,0], #Capricorn
    [0,2,0,1,0,1,0,2,0,1,0,1], #Aquarius
    [1,0,2,0,1,0,1,0,2,0,1,0]  #Pisces

]

# Finds the element, based on the zodiac code
#Returns an element_code:
# 0 - WATER
# 1 - FIRE
# 2 - EARTH
# 3 - AIR
func find_element( zodiac_code ):
	if zodiac_code == 3 or zodiac_code == 7 or zodiac_code == 11:
		return(0)
	if zodiac_code == 0 or zodiac_code == 4 or zodiac_code == 8:
		return(1)
	if zodiac_code == 1 or zodiac_code == 5 or zodiac_code == 9:
		return(2)
	if zodiac_code == 2 or zodiac_code == 6 or zodiac_code == 10:
		return(3)
		

#Wil return a random zodiac sign given an element
#Uses same element codes as above
func give_element_sign(element_code):
	match(element_code):
		0:
			var signs = [3,7,11]
			return(signs[randi()%3])
		1:
			var signs = [0,4,8]
			return(signs[randi()%3])
		2:
			var signs = [1,5,9]
			return(signs[randi()%3])
		3:
			var signs = [2,6,10]
			return(signs[randi()%3])

#########################
## ELEMENTAL VALUE CHARTS
# We're developing charts that reflect each of the different
# elemental values. They show the relationships among groups of creatures
# WATER : LOVE
# EARTH : WEALTH
# FIRE  : FAME
# AIR   : POWER/POLITICS

# Charts, basically a list of webs and graphs using creature_index
# Here we define the data structure -> the matrix containing all of the info
# and also quick functions to access the data?

## WEALTH CHART 
# the easiest of the charts
# list of creatures with their wealth
# wealth can be across multiple currencies
# This will generate all of them, and their colors
func GenreateNeighborWealthChart(num_neighbors):
	var chart_data = {
		"num_creatures" : num_neighbors, #the amount of neighbors in the chart
		"num_currencies" : 2 + randi()%3, #generate how many currencies there will be
		"currency_colors_prim" : [], #A list of colors (prim) for each currency
		"currency_colors_seco" : [], #A list of colors (seco) for each currency
		"creature_wealth_chart" : [] #A 2D list containing wealth. access: chart[cre_index][currency_index] = how many coins of currency
	}
	
	#Generate the colors
	for i in range(chart_data["num_currencies"]):
		var temp_col_prim = Color(randf(),randf(),randf())
		chart_data["currency_colors_prim"].append(temp_col_prim)
		var temp_col_seco = Color(randf(),randf(),randf())
		chart_data["currency_colors_seco"].append(temp_col_seco)
		
	#Generate the wealth of each neighbor
	for i in range(num_neighbors):
		var currency_coins = [] #A list containing the amount of coins of each currency
		for j in range(chart_data["num_currencies"]):
			currency_coins.append(randi()%100 + 1)
		chart_data["creature_wealth_chart"].append(currency_coins)
	
	return(chart_data)

## LOVE CHART 
# the secret is to not generate too too many love relationshiops (JEEZ rabbits)
# web of creatures 
# really, a list of lists of who that creature is attracted to
# Only compatible lovers will form relationships...
# ALSO,
# WATER and FIRE are monogamous
# EARTH and AIR are polyamorous
func GenreateNeighborLoveChart(num_neighbors, creature_list):
	
	var initial_connections = 6 #how many connections there are...
	
	var chart_data = {
		"num_creatures" : num_neighbors, #the amount of neighbors in the chart
		"web_of_love" : [] #a list of lists of lvoers of each creature 
	}

	#initialize web
	for i in num_neighbors:
		chart_data["web_of_love"].append([])
		
	
	#random connections
	var num_connections = 0
	while(num_connections < initial_connections):
		var isStalker = false #flag that decides if the connections is one way or two way
		#randomly select a pair
		var lover_index = randi()%num_neighbors
		var target_index = randi()%num_neighbors
		while(target_index == lover_index):
			target_index = randi()%num_neighbors
		#Check their elements
		var lover_element = find_element(creature_list[lover_index].zodiac_sign)
		var target_element = find_element(creature_list[target_index].zodiac_sign)
		#Check if the lover has room for more (monogamous or polyamorous)
		if lover_element == 0 or lover_element == 1:
			if chart_data["web_of_love"][lover_index].size() >= 1:
				continue #try a different 
		#Check if the target has room for more (monogamous or polyamorous)
		if target_element == 0 or target_element == 1:
			if chart_data["web_of_love"][target_index].size() >= 1:
				#But we can still potentially create a stalker relationship if not available...
				#random low chance of being a stalker
				var choice = randi()%7
				if choice == 0:
					isStalker = true
				else:
					continue #otherwise just continue
		#check if they are compatible
		if zodiac_compatibility[lover_element][target_element] != 0:
			#Decide if it's a one way or not... MOST LIKEY  a TWO way
			var choice = randi()%7
			if choice == 0:
				isStalker = true
			if isStalker == false:
				#TWO WAY
				#enter the data in the chart
				chart_data["web_of_love"][lover_index].append( target_index )
				chart_data["web_of_love"][target_index].append( lover_index )
			else: #if isStalker == true
				#ONE WAY
				#enter the data in the chart
				chart_data["web_of_love"][lover_index].append( target_index )
			
			#Also increment counter
			num_connections = num_connections + 1
				
	return(chart_data)

## POWER CHART
# Generates some political parties
# and the structures of each...
# There are three types of parties
# 0 - Tree, one at top, spreads towards bottom
# 1 - Ring, everyone answers to everyone.... in a ring
# 2 - Chain of Command, single line... like a tree but no branching
#
# Trees are notated like this:
# [top, alll its kids ]
# [top, [top's kid1, grandchildren1], [top's kid2, grandchildren2] ] ]
#
# [top, top_mid, mid, bot_mid, bot]
# [top, [second_lt1], mid1, bot1, [secon_lt2]]
#
# [top, top_mid, mid, bot_mid, bot]
# [top, [second_lt_1, mid, bot], second_lt_2, mid, bot]
# [top, [second_lt1], [second_lt2], second_lt3]
#
# Rings are just a list of everyone.... order doesn't really matter.
func GenerateNeighborPowerChart(num_neighbors):
	
	var num_parties = randi()%3 + 2 
	
	var chart_data = {
		"num_creatures" : num_neighbors, #the amount of neighbors in the chart
		"num_parties" : num_parties, #amount of parties to generate
		"party_names" : [], #list of all the party names...
		"party_types" : [], #list of the party types... ints, see above for code
		"party_members" : [], # a list of lists.... the second list is interpreted based on party type
	}

	#generate the parties
	for i in range(num_parties):
		var temp_name = Story.GeneratePartyName()
		chart_data['party_names'].append(temp_name)
		#Choose random structure
		var temp_type = randi()%3
		chart_data['party_types'].append(temp_type)
		#Initialize a list for the member structure
		chart_data['party_members'].append([])
	
	#Populate parties based on party type
	var ids = range(num_neighbors) #a list with ids for each of the neaighbors
	for i in range(ids.size()):
		#Pcik a random element
		var pick = ids[randi()%ids.size()]
		
		#Decide which party it will join... one after the other...
		var party_pick = i%num_parties
		#Add it to the chart
		chart_data['party_members'][party_pick].append(pick)
		
		#Remove from list so we don't pick again
		ids.erase(pick)
	
	
	
	return(chart_data)

##More story stuff....
var negative_earth_adjectives = ["bullheaded","colorless","compulsive","conventional","drab","gloomy","grim","grinding","hardheaded","humorless","inflexible","intractable","intransigent","materialistic","mulish","obdurate","obsessive","obstinate","ordinary","overcautious","overorganized","pedestrian","perfectionistic","pertinacious","pessimistic","pigheaded","prim","prosaic","rigid","staid","stiff","stiff-necked","stodgy","stubborn","timid","unadventurous","unbending","uncompromising","unexciting","unimaginative","unquestioning","unromantic","unspontaneous","unyielding"]
var positive_earth_adjectives = ["able","adept","adroit","assiduous","bighearted","capable","careful","cautious","competent","concrete","conscientious","constant","dependable","determined","dogged","down-to-earth","efficient","enterprising","factual","firm","generous","handy","hardworking","industrious","loyal","magnanimous","meticulous","nurturing","orderly","organized","painstaking","persevering","practical","productive","proficient","prudent","realistic","reliable","resolute","resourceful","responsible","sensible","skillful","solid","stable","stalwart","staunch","steadfast","steady","sturdy","supporting","tenacious","thorough","trusting","trustworthy","unwavering"]
var negative_water_adjectives = ["broody","delicate","doleful","escapist","fanciful","fragile","frail","gushy","huffy","hypersensitive","hysterical","impressionable","indolent","introverted","lazy","maudlin","melancholic","mopish","moody","morose","narcissistic","overemotional","overrefined","petulant","passive","sulky","sullen","temperamental","thin-skinned","touchy","vapory","waspish","wishy-washy"]
var positive_water_adjectives = ["aesthetic","affectionate","agreeable","amiable","benevolent","calm","caring","compassionate","concerned","considerate","diplomatic","dreamy","emotional","empathetic","forbearing","gentle","good-hearted","gracious","healing","humane","imaginative","inner","intimate","introspective","intuitive","joyful","kind","loving","mellow","merciful","mild","nice","patient","peaceful","perceptive","psychic","quiet","refined","responsive","romantic","sensitive","soft","spiritual","subjective","sweet","sympathetic","telepathic","tenderhearted","tolerant","understanding","wise"]
var negative_fire_adjectives = ["aggressive","brash","cocky","dare-devilish","devil-may-care","foolhardy","hasty","headstrong","heedless","hot-headed","hot-tempered","impatient","impetuous","impulsive","imprudent","incautious","irresponsible","nervy","overconfident","overzealous","precipitous","presumptuous","rash","reckless","restless","rootless","self-absorbed","superficial","thoughtless","unprepared"]
var positive_fire_adjectives = ["adventurous","aggressive","ardent","attractive","audacious","avid","bold","brave","buoyant","charismatic","charming","cheerful","confident","courageous","creative","daring","eager","ebullient","energetic","enthusiastic","exuberant","extroverted","fiery","forceful","heroic","inspiring","intrepid","inventive","magnetic","optimistic","original","outgoing","passionate","risk-taking","self-assured","self-confident","undaunted","valiant","wholehearted"]
var negative_air_adjectives = ["abstruse","aloof","arrogant","autocratic","biting","blunt","cold","condescending","controlling","cool","critical","cutting","detached","distant","dogmatic","domineering","high-handed","imperious","insensitive","intolerant","judgmental","opinionated","overbearing","overintellectualizing","patronizing","remote","standoffish","thoughtless","unaffectionate","unfeeling","unresponsive","unsparing"]
var positive_air_adjectives = ["analytical","articulate","astute","authoritative","clearheaded","clever","dignified","direct","discerning","dispassionate","equitable","ethical","evenhanded","forthright","frank","honest","honorable","impartial","incisive","intellectual","just","keen-minded","knowledgeable","learned","literate","logical","lucid","magisterial","mental","moral","objective","observant","outspoken","penetrating","perspicacious","quick-witted","rational","reasonable","smart","trenchant","truthful","unbiased","unprejudiced","well-informed","witty"]

#Name Monickers
var post_monickers = ["Dopest","Dope","Baddest","Bad","Slickest","Slick","Mostest","Rad","Clown","Killa","Slizza","Blizza","Snow","Product","Biggie","Down","Chiller","Fuse","Bomb","Bombest","Funny","Punk","Chill","Junkhead","Cracker","Lowlife","Thug","Thuggin","Pimpin","Chief","Pill","Rocker","Baller","Insane","Moco","Snoop","JoJo","Fly","Real Deal","Peep","Pump","Smalls", "Illest","Dude","Duderino","Baby","Vato","Joker","Homie","Flow","Slug","Bastard","Flava","Bean"] 
var pre_monickers = ["Mista", "Lil", "Supa", "Fitty", "Champ", "Kid", "Wiz", "Babyface","Cousin", "Filthy","Trashcan","Janky","Muthafucka"]

##Generate Political Party names...
# The [Adjective] [type of people] [type of organization]
# Or The [organization] of [adj] [type of people]
var adjectives = ["Good", "Bad", "Witchy", "Proud","Vile"]
var types_of_people = ["Witches", "Warlocks","Magicians","Doctors","Witchdoctors",
"Professors","Illusionists","Acolytes","Priests","Druids"]
var organizations = ["Coven", "Brotherhood", "Sisterhood", "Confederation", "Tribunal",
"Republic","Magistry","School","Family","Gang","Monarchy","Empire","League","Oligarchy"]

#Generates politcal party names
func GeneratePartyName():
	var fullName = "" #the name of the party that will be returned
	var adjective
	var org_type
	var people_type
	
	#Choose a random adjective... from the elemental adjectives (8 sets)
	var element_choice = randi()%8
	match(element_choice):
		0:
			adjective = positive_air_adjectives[randi()%positive_air_adjectives.size()]
		1:
			adjective = negative_air_adjectives[randi()%negative_air_adjectives.size()]
		2:
			adjective = positive_fire_adjectives[randi()%positive_fire_adjectives.size()]
		3:
			adjective = negative_fire_adjectives[randi()%negative_fire_adjectives.size()]
		4:
			adjective = positive_earth_adjectives[randi()%positive_earth_adjectives.size()]
		5:
			adjective = negative_earth_adjectives[randi()%negative_earth_adjectives.size()]
		6:
			adjective = positive_water_adjectives[randi()%positive_water_adjectives.size()]
		7:
			adjective = negative_water_adjectives[randi()%negative_water_adjectives.size()]	
	
	#random org type
	org_type = organizations[randi()%organizations.size()]
	
	#random people
	people_type = types_of_people[randi()%types_of_people.size()]
	
	#Pick format
	if randi()%2 == 0:
		fullName = "The " + org_type + " of " + adjective.capitalize() + " " + people_type
	else:
		fullName = "The " + adjective.capitalize() + " " + people_type + "'s " + org_type
	
	return(fullName)
	

######### TREE FUNCTIONS 
# Useful in chart gen

#Function to generate a random Prufer Code sequence
# "A tree with n nodes can be uniquely expressed by a 
# sequence of n-2 integer numbers (in the range of [0, n-1]). 
# This is called the Prüfer sequence."
#					-Nico Schertler (StackOverFlow)
func GeneratePruferCode(num_nodes):
	
	var code = []
	#generate the sequence
	for i in range(num_nodes-2):
		code.append(randi()%(num_nodes-1))
	return(code)

## Function that returns all of teh edges given a Prufer Code Sequence
func EdgesFromPruferCode(in_code):
	
	var edges = [] #list containing the edges of the tree of the prufer code
	
	#Algorithm uses two sets
	var S_set = in_code
	var L_set = range(in_code.size()+2)
	
	#Cycle through the S_Set
	for i in range(S_set.size()):
		
		var temp_edge = Vector2(0,0) #Every iteration we create a new edge
		
		#Vertex 1 is the value in S_Set
		temp_edge.x = S_set[i]
		
		#Vertex 2 is the smallest value in L that is not in the current S set
		#Cycle through all of the L values
		for j in range(L_set.size()):
			#Cycle through the CURRENT S_set and check if j is in there
			var inS_set = false
			for k in range(i,S_set.size()):
				if S_set[k] == L_set[j]:
					inS_set = true
			#Now that it's done cycling,
			if inS_set == true:
				#Then j is not the vertex and we need to keep searching 
				continue
			else:
				# we found the vertex
				temp_edge.y = L_set[j]
				#remove from L_set
				L_set.erase(L_set[j])
				break
		
		#Now the edge is ready to be added to the edges array
		edges.append(temp_edge)
		#... And we move on to next value in the S-Set

	#At this point, only two elements left in L set... they become the two vertices of the final edge
	edges.append(Vector2(L_set[0], L_set[1]))

	return(edges)
	

## Function that creates a dictionary representation of a tree
# given the set of it's edges. 
# 3rd step in the pipeline: PruferCode -> EdgesFromPrufer -> TreeFromEdges
#
# Tree structure looks like:
#tree = {
#	"node" : {
#		"sub_node1" : {
#
#		}
#		"sub_node2" : {
#
#		}
#
#	{
#}
# leaves have empty dictioionary
func TreeFromEdges(in_edges):
	var out_tree = {}
	
	#Add the first edge... Each edge has a Parent node and a child node
	var temp_edge = in_edges.pop_front()
	#Register the parent node
	out_tree[temp_edge.x] = {}
	#Register the child node
	out_tree[temp_edge.x][temp_edge.y] = {}
	
	#Now cycle through the rest of the edges...
	print("cycling")
	while(in_edges.size() != 0):
		#pop the edge
		temp_edge = in_edges.pop_front()
		
		#Check if the current tree has either of the nodes already
		###################
		
		#Check the X NODE
		var check_exist = DoesKeyExistInNestedDict(out_tree,temp_edge.x)
		if check_exist["has"] == true:
			#Then follow the search path (in check_exist) to the node and add new child...
			var temp_dict = out_tree
			while(check_exist["path_to_root"].empty() == false):
				temp_dict = temp_dict[check_exist["path_to_root"].pop_back()]
			#final step into the leaf
			temp_dict = temp_dict[temp_edge.x]
			#temp_dict is at the the node...
			
			#Add the other node now
			temp_dict[temp_edge.y] = {}
			continue #now coninue 
		
		#Check the Y NODE
		check_exist = DoesKeyExistInNestedDict(out_tree,temp_edge.y)
		if check_exist["has"] == true:
			#Then follow the search path (in check_exist) to the node and add new child...
			var temp_dict = out_tree
			while(check_exist["path_to_root"].empty() == false):
				temp_dict = temp_dict[check_exist["path_to_root"].pop_back()]
			#final step into the leaf
			temp_dict = temp_dict[temp_edge.y]
			#temp_dict is at the the node...

			#Add the other node now
			temp_dict[temp_edge.x] = {}
			continue #now coninue 

		#If it makes it down here, that means none of the edge's nodes have been added yet....
		#add it to the back of the list and continue
		in_edges.push_back(temp_edge)
		
		print()
	
	return(out_tree)

## Recursive function to search a tree dictionary for nodes
# Checks if a key exists in a dictionary of dicts...
# if it does, it will return a series of keys to follow to it
# returns a data structure like so:
#		var return_data = {
#			"has" : true, #whether it had the key or not
#			"path_to_key" : [] #a series of keys to follow from the key to the root (so backwards)
#		}
func DoesKeyExistInNestedDict(search_dict,search_key):
	# Base Case
	if search_dict.has(search_key):
		var return_data = {
			"has" : true,
			"path_to_root" : [] #a series of keys to follow from the key to the root (so backwards)
		}
		return(return_data)
	# Recursive Case
	else:
		for key in search_dict.keys():
			var check_data = DoesKeyExistInNestedDict(search_dict[key], search_key)
			if check_data['has'] == true:
				var return_data = {
					"has" : true,
					"path_to_root" : [] #a series of keys to follow from the key to the root (so backwards)
				}
				#need to copy the path from check_data to return_data
				for existing_key in check_data["path_to_root"]:
					return_data["path_to_root"].append(existing_key)
				#Finally, add the current key to the path
				return_data["path_to_root"].append(key)
				return(return_data)
	#If we make it here... then false...
	var return_data = {
		"has" : false,
		"path_to_root" : []#a series of keys to follow from the key to the root (so backwards)
	}
	return(return_data)