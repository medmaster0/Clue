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




