extends Node

# Generate the Datamap
#Returns a 2D array (X,Y) of coordinates to place clouds
#array contains:
# 0 - cloud
# 2 - empty
func GenerateClouds(map_size):
	randomize()
	
#	#INitialize!
#	var map = []
#	var empty_id = 2
#	var cloud_id = 0
	
#	#Populate empty map array
#	for x in range( map_size.x ): 
#		var column = []
#		for y in range(map_size.y):
#			column.append(empty_id)
#		map.append(column)
#
#
	
	#Add a few rows of clouds
	#These are the settings
	var num_clouds = randi()%3+3
	#These are the temp variables
	var cloud_length
	var cloud_x 
	var cloud_y = int(map_size.y/4)
	#Create a list (of dictionaries for each cloud)
	var clouds = []
	
	#For each cloud we need to create...
	for cloud_iter in range( num_clouds ):
		#Roll new cloud params
		cloud_length = randi()%6+10
		cloud_x = randi()%int(2*map_size.x/3)
		#cloud_y = randi()%int(map_size.y/3) + map_size.y/3
		cloud_y = cloud_y + randi()%4 + 2
		#Add that info to the disctionary list
		clouds.append( 
			{
				"length": cloud_length,
				"x": cloud_x,
				"y": cloud_y
			}
		)
	
#	#Set map cells based on clouds
#	for cloud in clouds:
#		#Cycle acrosst length
#		for x_iter in range(cloud.length):
#			map[cloud.x+x_iter][cloud.y] = cloud_id
	
	return clouds
	
	
	
# Generate a pattern of rectangular rooms
#returns a dicitonary to...
# map : individual pixel data in a 2D array, XY-accessed
# rooms : a list of Rect2 
func GenerateVault_v1(map_size):
	randomize()
	
	var map = [] #the main map (2D array) that we will return map[x][y]
	var num_rooms = 9 #How many rooms we have
	var blank_id = 0 #The ID for empty tiles
	var floor_id = 1 #The ID for Floor tiles
	var wall_id = 2 #The ID for Wall tiles
	
	
	#Initialize map 2D array
	for x in range(map_size.x):
		var column = [] #empty array
		for y in range(map_size.y):
			column.append(blank_id)
		map.append(column)
	
	#Create the rooms
	var rooms = [] #a list of room rectangles
	for room in range(num_rooms):
		#random parameters
		var length = randi()%3+5
		var x = randi()%int(map_size.x-length-2-2)+2
		var height = randi()%3+5
		var y = randi()%int(map_size.y-height-2-2)+2
		var temp_room = Rect2(x-1, y-1, length+1, height+1)
		
		#check if this room intersects any of the other ones...
		var does_intersect = false
		if !rooms.empty():
			for other_room in rooms:
				if temp_room.intersects(other_room):
					does_intersect = true
					print("inter")
					
		if does_intersect == false:
			#But if we made it here, it didn't intersect, so add it
			rooms.append(temp_room)
			
			#Carve out the room
			for tx in range(length):
				for ty in range(height):
					#Set the proper codes
					map[x+tx][y+ty] = floor_id
					
			#Also do the walls
			#TOP WALL & BOTTOM
			for tx in range(length+2):
				map[x+tx-1][y-1] = wall_id
				map[x+tx-1][y+height] = wall_id
			#LEFT AND RIGHTY
			for ty in range(height+1):
				map[x-1][y+ty-1] = wall_id
				map[x+length][y+ty-1] = wall_id

	#Create a path between the rooms
	var counter = 0
	for room in rooms:

		var random_point = inside_rect(room)
		#map[random_point.x][random_point.y] = 0
		var random_point2 = inside_rect(rooms[counter-1])
		#map[random_point2.x][random_point2.y] = wall_id

		#Now we can either go:
		var rand_choice = randi()%2
		match rand_choice:
			0:
				#Horizontal first, then vertical
				map = h_path(random_point.x, random_point2.x, random_point.y, map)
				map = v_path(random_point.y, random_point2.y, random_point2.x, map)
				
				#We need to ensure the "elbow joints" of the two paths are covered in walls	
				#Occurs at [random_point2.x][random_point.y]
				if map[random_point2.x-1][random_point.y-1] != floor_id:
					map[random_point2.x-1][random_point.y-1] = wall_id
					
				if map[random_point2.x+1][random_point.y+1] != floor_id:
					map[random_point2.x+1][random_point.y+1] = wall_id
					
				if map[random_point2.x-1][random_point.y+1] != floor_id:
					map[random_point2.x-1][random_point.y+1] = wall_id
					
				if map[random_point2.x+1][random_point.y-1] != floor_id:
					map[random_point2.x+1][random_point.y-1] = wall_id
				
				
				
				
			1:
				#Vertical first, then vertical
				map = v_path(random_point.y, random_point2.y, random_point.x, map)
				map = h_path(random_point.x, random_point2.x, random_point2.y, map)
				
				#We need to ensure the "elbow joints" of the two paths are covered in walls	
				#Occurs at [random_point.x][random_point2.y]
				if map[random_point.x-1][random_point2.y-1] != floor_id:
					map[random_point.x-1][random_point2.y-1] = wall_id
					
				if map[random_point.x+1][random_point2.y+1] != floor_id:
					map[random_point.x+1][random_point2.y+1] = wall_id
					
				if map[random_point.x-1][random_point2.y+1] != floor_id:
					map[random_point.x-1][random_point2.y+1] = wall_id
					
				if map[random_point.x+1][random_point2.y-1] != floor_id:
					map[random_point.x+1][random_point2.y-1] = wall_id

				
				
				
			
		
		counter = counter + 1
		
	var map_data = {
		
		"map": map,
		"rooms": rooms
		
		}
	
	return(map_data)
	
#Find a random point in a rectangle
func inside_rect(rect):
	var rx = rect.position.x + randi()%int(rect.size.x-1) + 1
	var ry = rect.position.y + randi()%int(rect.size.y-1) + 1
	var return_vect = Vector2(rx,ry)
	return(return_vect)
	
#Carve out a path (walls and floors) of a horizontal line in the given map
func h_path(x1, x2, y, map):
	
	#Check to make sure they are ordered correctly
	if(x1>x2):
		var temp_x = x2
		x2 = x1
		x1 = temp_x
		
	#Go through and fill out the points
	for i in range(x1,x2+1):
		#Set cell
		map[i][y] = 1
		
		#Possibly make the surrounding tiles walls
		#As long as it's not a floor
		if map[i][y-1] != 1:
			map[i][y-1] = 2
		if map[i][y+1] != 1:
			map[i][y+1] = 2
		
	return(map)
	
#Carve out a path (walls and floors) of a horizontal line in the given map
func v_path(y1, y2, x, map):
	
	#Check to make sure they are ordered correctly
	if(y1>y2):
		var temp_y = y2
		y2 = y1
		y1 = temp_y
	
	#Go through and fill out the points
	for i in range(y1,y2+1):
		
		map[x][i] = 1
		
		#Possibly make the surrounding tiles walls
		#As long as it's not a floor
		if map[x-1][i] != 1:
			map[x-1][i] = 2
		if map[x+1][i] != 1:
			map[x+1][i] = 2
		
	return(map)
	
	
#Generate Bank Layout
func GenerateBank(map_size):
	randomize()
	
	var map = [] #the main map (2D array) that we will return map[x][y]
	var num_rooms = 9 #How many rooms we have
	var blank_id = 0 #The ID for empty tiles
	var floor_id = 1 #The ID for Floor tiles
	var wall_id = 2 #The ID for Wall tiles
	var window_id = 3 #The ID for Window tiles
	var back_floor_id = 4 #A different ID for floors of a different color
	
	#Initialize map 2D array
	for x in range(map_size.x):
		var column = [] #empty array
		for y in range(map_size.y):
			column.append(blank_id)
		map.append(column)
		
	#Determine starting point of room rect
	var x0 = 10
	var y0 = 15
	var width = 40
	var height = 15
	#Determine a random window pattern
	var window_interval = randi()%6 + 1 + 1 #how often windows appear
	#var window_run = randi()%window_interval + 1 #how long the window will be
	var window_run = window_interval - 1 #how long the window will be
	# oXXoXXoXXo - interval: 3 run: 2
	# oXoooXoooX - interval: 4 run: 1
	
	#Set the floor space
	for i in range(width):
		for j in range(height):
			map[x0+i][y0+j] = floor_id
			
	#Put a row for counter (walls)
	for i in range(width):
		map[x0+i][y0-1] = wall_id
	
	#Put some floor space behind the counter
	for i in range(width):
		for j in range(7):
			map[x0+i][y0-j-3] = back_floor_id
	
	#Put a random window pattern
	#(start with a row of wall)
	for i in range(width):
		map[x0+i][y0-2] = wall_id
	#Then carve out the window tiles
	for i in range(width):
		if i%window_interval==0: #Every interval start a window
			for r in range(window_run):
				if i+r < width: #make sure it doesn't extend bounds of width
					map[x0+i+r][y0-2] = window_id
	
	return map
	

#Generate Corridor Maze
#Inspired by moititi
# 0 - Empty Space
# 1 - Brick Space
# Access maze[row][col]
func GenerateCorridorMaze(num_rows, num_cols, num_inner_walls):
	
	randomize()
	
	var maze = [] #2D Array, with maze tiles to return
	#Intialize array with alternating rows of 0 and 1
	for i in range(num_rows):
		maze.append([])
		if i%2 == 0: #if even
			for j in range(num_cols):
				maze[i].append(0)
		else: #if odd
			for j in range(num_cols):
				maze[i].append(1)
	
	#Need to place walls in the middle of the empty rows (have 0s)
	#And also keep track of them!
	var empty_row_wall_locs = [] #2d list of positions where the walls are (doesn't have any for brick rows)
	for i in range(num_rows): #iterate over the rows
		if i%2!=0: #Skip the row if it's a brick wall
			continue 
		else: #otherwise, Now, we're accessing an empty row
			var walls = [] #list of col indices where wall is
			for w in range(num_inner_walls):
				# w + randi()%num_inner_walls/num_rows
				var wall_col #this is the col index of the tile that (will) become(s) a wall
				wall_col = w*(num_cols/num_inner_walls) + randi()%((num_cols/num_inner_walls) - 1)
				walls.append(wall_col)
				#Finally, set the tile to be a wall
				maze[i][wall_col] = 1
			empty_row_wall_locs.append(walls)
	#empty_row_wall_locs will have list (for each row) of list
	
	#Now with walls placed, we can decide where to put openings in brick walls
	for i in range(num_rows):
		if i%2==0: #Skip the row if it's an empty row
			continue
		else: #otherwise, now, we're accessing a brick row
			#Determine where the walls were in the adjacent empty rows...
			var adj_walls = [] #list of col indices where a wall appears in adjacent rows
			#Add the wall col_indices from empty row, above (if applicable)
			var above_row_index = floor(i/2.0)
			if above_row_index >= 0: #bounds check
				for w in empty_row_wall_locs[above_row_index]: #Copy all the indices 
					adj_walls.append(w) 
			#Add the wall col_indices from the empty row, below (if applicable)
			var below_row_index = ceil(i/2.0)
			if below_row_index < empty_row_wall_locs.size(): #bounds check
				for w in empty_row_wall_locs[below_row_index]: #Copy all the indices
					adj_walls.append(w)
			#Now adj_walls has the full list of col indices of adj walls
			#But we should sort them...
			adj_walls.sort_custom(self, "int_array_sort")
			
			#Now we place random openings between each wall
			#Before First
			if(adj_walls[0] > 1): #make sure there's enough room
				var d = randi()%(adj_walls[0]-1) + 1#Pick a random spot for it
				maze[i][d] = 0 #set the opening in the maze
			#Between Intermediate Walls
			for c in range(adj_walls.size()-1):
				if(adj_walls[c+1] - adj_walls[c]) > 1: #Make sure there's enough room
					var d = randi()%(adj_walls[c+1] - adj_walls[c] - 1) + adj_walls[c] + 1#pick a random spot for it
					maze[i][d] = 0 #set the opening in the maze
			#After Last
			if(num_cols - adj_walls[adj_walls.size()-1]) > 1:
				var d = randi()%(num_cols - adj_walls[adj_walls.size()-1] - 1) + adj_walls[adj_walls.size()-1] + 1
				maze[i][d] = 0 #set the opening in the maze
	
	return(maze)

#Utility function used to sort int array
func int_array_sort(a,b):
	return a < b
	
	

#Generate Flow Map
#Reads in a maze array (2D, 0 for empty, 1 for blocked)
#REturns an identically sized array
#But each cell contains a value from 0 - 15
#One of the possible combinations of
# UP   DOWN   LEFT  RIGHT
# 0 	0		0		0
# 0		0		0		1
# ......
# 1		1		1		1
func DetermineFlowMap(maze_map):
	
	print("")
	
	var flow_map = [] #the flow map we return
	
	#Copy the maze_map
	var x_dim = maze_map.size()
	var y_dim = maze_map[0].size()
	for i in range(x_dim):
		var row = []
		for j in range(y_dim):
			row.append(0)
		flow_map.append(row)
		
	#Iterate through the flow map
	var check_x #index to check maze_map
	var check_y #index to check maze_map
	var isBlock = false #flag used to check if the flow is blocked in that direction
	for i in range(x_dim): #x dim
		for j in range(y_dim): #y dim
		
			#Construct the string "0000" to "1111" bit-by-bit
			var flow_code = ""
			
			#If the tile is blocked, then write 1111 to it
			if maze_map[i][j] == 1:
				flow_code = "XXXX"
				flow_map[i][j] = flow_code
				continue
			
			#UP
			check_x = i
			check_y = j - 1
			#First bounds check
			if check_y < 0:
				flow_code = flow_code + "1"
			else:
				#Then Check if blocked
				if maze_map[check_x][check_y] == 1:
					flow_code = flow_code + "1"
				else:
					flow_code = flow_code + "0"
				
			#DOWN
			check_x = i
			check_y = j + 1
			#First bounds check
			if check_y >= y_dim:
				flow_code = flow_code + "1"
			else:
				#Then Check if blocked
				if maze_map[check_x][check_y] == 1:
					flow_code = flow_code + "1"
				else:
					flow_code = flow_code + "0"
			
			#LEFT
			check_x = i - 1
			check_y = j
			#First bounds check
			if check_x < 0:
				flow_code = flow_code + "1"
			else:
				#Then Check if blocked
				if maze_map[check_x][check_y] == 1:
					flow_code = flow_code + "1"
				else:
					flow_code = flow_code + "0"
				
			#RIGHT
			check_x = i + 1
			check_y = j
			#First bounds check
			if check_x >= x_dim:
				flow_code = flow_code + "1"
			else:
				#Then Check if blocked
				if maze_map[check_x][check_y] == 1:
					flow_code = flow_code + "1"
				else:
					flow_code = flow_code + "0"

			#Enter the flow code...
			flow_map[i][j] = flow_code
			
	return(flow_map)

#Generates a ship with a maze inside
# Process:
# Creates the ship, cell by cell, row by row. Then constructs a maze inside...
# 
# CELL LEGEND:
# 0 - empty space
# 1 - ship wall - impassible
# 2 - ship wall - inside
# 3 - ladder
# 4 - walkable area

# Use GOLEN RATIO as guide
# Keep scaling/dividing by 1.6!
func GenerateMazeShip(num_rows):
	
	#make sure it's big enough : 5 is the mathematically smallest size to make a maze
	if num_rows < 5:
		print("need more rows in ship building")
		return
	#make sure it's an odd number
	if num_rows % 2 == 0:
		num_rows = num_rows + 1
	
	#Determine how wide ship should be based on rows
	var num_cols = round(1.6 * num_rows)
	
	#Now, given num_rows we can determine the ship pattern.....
	##################################################################
	
	#Drawing the bottoms with decreasing inverse golden_ratio applied to each step
	var CURVE_RATIO = 1.6 #adjustable curvature setting
	var segment_add = num_cols / CURVE_RATIO #how much to extend the bottom of the ship...
	var tiles_added = [] #a list of the rounded segment_add values for each row
	for row in range(num_rows):
		segment_add = segment_add / CURVE_RATIO
		tiles_added.append(round(segment_add))
	
	#Now that we have list of tiles to add each segment, lets apply to the cell_grid
	#Figure out how wide the ship will be
	var half_width = 0
	#Go throught the list and add up all of the values
	for a in tiles_added:
		half_width = half_width + a
	#The actual amount of cols will be twice the half_width
	num_cols = half_width + half_width
	
	
	#initialize the blank grid
	var cell_grid = [] #2D array of ints for holding raw cell data (SEE LEGEND)
	for i in range(num_rows):
		var temp_row = []
		for j in range(num_cols + 1): #Make it a little wider just in case...
			temp_row.append(0)
		cell_grid.append(temp_row)
	
	
	#Now apply the add_lengths to the cell_grid
	var row_index = 0 #run index used in iterating rows
	var build_cursor = 0 #Where (which col) the last tile of the last segment was
	for add_length in tiles_added: #for each add_length
		for t in range(add_length):
			#Apply to the left half
			cell_grid[row_index][half_width - (t + build_cursor)] = 1
			#Apply to the right half
			cell_grid[row_index][half_width + (t + build_cursor)] = 1
		
		#Also "cap" the ends of each row....
		cell_grid[row_index][half_width - build_cursor - add_length] = 1
		cell_grid[row_index][half_width + build_cursor + add_length] = 1
		
		#Update the indices.cursor
		row_index = row_index + 1
		build_cursor = build_cursor + add_length
		
	
	### At this point, we have the ship's hull outlined
	## we also know the amount added on each level stored in tiles_added list
	## SHIP HULL FINISHED!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	#Go through and fill the rows with inside walls on odd numbered rows
	row_index = 0 #reset the row index
	for row in cell_grid:
		
		#The FIRST ROW
		if row_index == 0:
			row_index = row_index + 1
			continue
		
		#EVEN ROWS
		if row_index % 2 == 0:
			cell_grid[row_index] = RowInteriorWall(row)
			#Increment counters
			row_index = row_index + 1
			continue
			
		#ODD ROWS
		else:
			cell_grid[row_index] = RowInteriorRooms(row)
			#Increment counters
			row_index = row_index + 1
			continue
		
		
	### At this point, we have the ship's rows properly layered
	## SHIP LAYERS FINISHED!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	#Go through the rows (in groups of three)
	#and put the proper barriers/ladders
	row_index = 0 #reset row index
	for row in cell_grid:
		
		#The FIRST ROW
		if row_index == 0:
			row_index = row_index + 1
			continue
			
		# The TOP ROW
		if row_index == cell_grid.size() - 1:
			#Capture and change new row data by adding ladders to form the top deck
			var rowData = RowDeckTop(cell_grid[row_index -1], cell_grid[row_index])
			cell_grid[row_index -1 ] = rowData[0]
			cell_grid[row_index] = rowData[1]
			#Increment counters
			row_index = row_index + 1
			continue
			
		#EVEN ROWS
		if row_index % 2 == 0:
			#Capture and change new row data by adding ladders and barriers
			var rowData = RowInteriorLaddersBarriers(cell_grid[row_index-1], cell_grid[row_index], cell_grid[row_index+1])
			cell_grid[row_index - 1] = rowData[0]
			cell_grid[row_index] = rowData[1]
			cell_grid[row_index + 1] = rowData[2]
			#Increment counters
			row_index = row_index + 1
			continue
		
		row_index = row_index + 1
	
	
	
	
#	#Print Grid (backward so it displays upright
#	for row_i in range(cell_grid.size()-1,-1,-1):
#		print(cell_grid[row_i])

	return(cell_grid)


##ROW PARSER FUNCTIONS

# Given a row, fills the insides with 2's
# ex [0,1,0,0,0,1] -> [0,1,2,2,2,1]
func RowInteriorWall(in_row):
	
	var out_row = [] #the row to be outputted
	var wallCount = 0 #counts how many walls encoutnered (if too many, consider it outside)
	
	#Some state-machine flags
	var isInsideHull = false #a flag used to tell if currently setting tiles (entries) inside or not
	var lastValue = 0 #used in parsing, stores last value in memory
	for e in in_row:
		
		##Toggle inside/outside when switch from 0 to 1
		if lastValue == 0 and e == 1:
			isInsideHull = !isInsideHull
		
		#What to print depending on whether inside/outside
		if isInsideHull == true:
			if e == 1:
				out_row.append(1)
			if e == 0:
				out_row.append(2)
		if isInsideHull == false:
			if e == 1:
				out_row.append(1)
			if e == 0:
				out_row.append(0)
				
		#Update value
		lastValue = e
			
	return(out_row)


# Given a row, fills the insides with 24's
# ex [0,1,0,0,0,1] -> [0,1,4,4,4,1]
func RowInteriorRooms(in_row):
	
	var out_row = [] #the row to be outputted
	
	#Some state-machine flags
	var isInsideHull = false #a flag used to tell if currently setting tiles (entries) inside or not
	var lastValue = 0 #used in parsing, stores last value in memory
	for e in in_row:
		
		##Toggle inside/outside when switch from 0 to 1
		if lastValue == 0 and e == 1:
			isInsideHull = !isInsideHull
		
		#What to print depending on whether inside/outside
		if isInsideHull == true:
			if e == 1:
				out_row.append(1)
			if e == 0:
				out_row.append(4)
		if isInsideHull == false:
			if e == 1:
				out_row.append(1)
			if e == 0:
				out_row.append(0)
				
		#Update value
		lastValue = e
			
	return(out_row)

#it seems ROOM_SIZE cant be larger than num_rows?? needs more experimenting

#Parse a row, idnetify how many interior spaces there are
#Place a barrier wall if enough space (refer to GLOBAL VARIABLE)
#Inside empty spaces (0) are turned into walkable areas (4)
# REturn a list with
# element 0: the modified row
# element 1: list of barrier positions (row indices)

#This function takes three rows at a time...
#Meant to straddle the solid row of 2's (rows with the 4's on each side)
# bot_row : 
# mid_row
# top_row
# It will place barriers where possible and ALSO
# It identifies where we can place ladders between each layer....

func RowInteriorLaddersBarriers(botRow, midRow, topRow):
	
	var ROOM_SIZE = 3 + randi()%2 #The minimum amount of tiles before a partition is made
	
	#The modified rows we will out put... copy for now
	var outBotRow = botRow
	var outMidRow = midRow
	var outTopRow = topRow
	
	#Function variables
	var botStart = 0 #index of row where bottom walking path starts (4s)
	var botEnd = 0 #index of row where bot walking path ends (4s) THE LAST INDEX THAT IS STILL WALKING SPACE
	var botBarriers = [] #list of indices where barriers are placed
	var topStart = 0 #index of row where top walking path starts (4s)
	var topEnd = 0 #index of row where top walking path ends (4s) THE LAST INDEX THAT IS STILL WALKING SPACE
	var topBarriers = [] #list of indices where barriers are placed (2s)
	var midLadders = [] #list of indices where ladders are placed (3s)
	
	#Parse Bottom row
	var row_index = 0 #index for iterating rows
	var foundWalkingSpace = false #Turn on or off whether we are counting the wakling spaces
	for e in botRow:
		if e == 4: #walking space
			if foundWalkingSpace == false:
				foundWalkingSpace = true
				botStart = row_index #keep track where we found the start
				
		if e == 2: #barrier
			botBarriers.append(row_index) #keep track where we find barriers
			
		if e == 1: #wall
			if foundWalkingSpace == true: #then we reached the end of walking space
				foundWalkingSpace = false
				botEnd = row_index - 1 #keep track where we found the end (but don't count this space)
				
		#iterate counters
		row_index = row_index + 1
	
	#Parse Top row
	row_index = 0 #index for iterating rows
	foundWalkingSpace = false #Turn on or off whether we are counting the wakling spaces
	for e in topRow:
		if e == 4: #walking space
			if foundWalkingSpace == false:
				foundWalkingSpace = true
				topStart = row_index #keep track where we found the start
				
		if e == 2: #barrier
			topBarriers.append(row_index) #keep track where we find barriers
			
		if e == 1: #wall
			if foundWalkingSpace == true: #then we reached the end of walking space
				foundWalkingSpace = false
				topEnd = row_index - 1 #keep track where we found the end (but don't count this space)
				
		#iterate counters
		row_index = row_index + 1
	
	##Now that we have this data, we can determine where to add ladders...
	
	#Bottom row is the limiting factor...
	
	########>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	# If there are no bottom barriers,
	# 	place appropriate number of ladders based on (bridgingSpan),
	#	then place barriers on bottom where needed (IN BETWEEN PAIRS OF LADDERS)
	#	then place barriers on top where needed (ON EITHER SIDE OF LADDERS) "ptf"
	# Else if there are bottom barriers already
	#	place ladders ON EITHER SIDE OF BARRIERS (provided they fit)
	#	bottom barriers remain the same
	#	top barriers ON EITHER SIDE OF (just now) LADDERS (provided they fit)
	
	
	var numLadders = 0 #how many ladders are on the current grouping
	if botBarriers.size() == 0: #If bottom row didn't detect any existing barriers
		var bridgingSpan = (botEnd + 1) - botStart
		#How many ladders we'll put depends on ROOM_SIZE
		numLadders = floor((bridgingSpan) / ROOM_SIZE)
		
		#Now place the ladders in their compartments
		#(add random increment to add "noise")
		for d in range(numLadders):
			var ladderIndex = botStart + (d*ROOM_SIZE) + randi()%(ROOM_SIZE-1) #subtracting 1 from ROOM_SIZE ensures no ladders will be right next to each other
			outMidRow[ladderIndex] = 3
			midLadders.append(ladderIndex)
			
		#Place Barriers on bottom between pairs of ladders (if applicable)
		if numLadders > 1:
			for i in range(numLadders - 1): #For every ladder PAIR
				#The barrier will be placed where the first ladder in pair is, plus a random offset
				#Also add 1 to make sure not on top of ladder
				var barrierIndex = (midLadders[i]+1) + randi()%(midLadders[i+1] - midLadders[i] - 1)
				outBotRow[barrierIndex] = 2
	
		#Place barriers on top on either side of each ladder (provided they fit)
		var check_span = 0 #checks the span between each ladder segement 
		#Do Outside of first ladder
		check_span = midLadders[0] - topStart
		if check_span >= 1:
			#Then it's possible to place a barrier there
			var barrierIndex = topStart + randi()%check_span
			outTopRow[barrierIndex] = 2
		#Do inbetween each pair of ladders
		if numLadders > 1:
			for i in range(numLadders - 1): #For every ladder PAIR
				#The barrier will be placed where the first ladder in pair is, plus a random offset
				#also add 1 to make sure not on top of ladder
				var barrierIndex = (midLadders[i]+1) + randi()%(midLadders[i+1] - midLadders[i] - 1)
				outTopRow[barrierIndex] = 2
		#Do outside of last ladder
		check_span = topEnd - midLadders[midLadders.size()-1]
		if check_span >= 1:
			#then it's possible to place a barrier there
			var barrierIndex = midLadders[midLadders.size()-1] + randi()%check_span
			outTopRow[barrierIndex] = 2

				
	else: #Then some barriers were detected and put in botBarriers
		#Place ladders on either side of bottomBarriers (provided they fit)
		var check_span = 0 #checks the span between each ladder segment
		#Do outside of first ladder
		check_span = botBarriers[0] - botStart
		if check_span >= 1:
			#Then it's possible to place a ladder there
			var ladderIndex = botStart + randi()%check_span
			outMidRow[ladderIndex] = 3
			midLadders.append(ladderIndex)
			numLadders = numLadders + 1
		#Do in between each pair of botBarriers
		if botBarriers.size() > 1:
			for i in range(botBarriers.size() - 1): # FOR every barrier PAIR
				if botBarriers[i+1] - botBarriers[i] > 1:
					#The ladder will be placed where the first barrier is, plus a random offset
					#also add 1 to make sure not on top of barrier
					var ladderIndex = (botBarriers[i]+1) + randi()%(botBarriers[i+1] - botBarriers[i] - 1)
					outMidRow[ladderIndex] = 3
					midLadders.append(ladderIndex)
					numLadders = numLadders + 1
		#Do OUtside of last barrier
		check_span = botEnd - botBarriers[botBarriers.size()-1]
		if check_span >= 1:
			#Then it's possible to place a ladder there
			var ladderIndex = botBarriers[botBarriers.size() - 1] + 1 + randi()%check_span
			outMidRow[ladderIndex] = 3
			midLadders.append(ladderIndex)
			numLadders = numLadders + 1
		
		#Place barriers on top on either side of each ladder (provided they fit)
		check_span = 0 #checks the span between each ladder segement 
		#Do Outside of first ladder
		check_span = midLadders[0] - topStart
		if check_span >= 1:
			#Then it's possible to place a barrier there
			var barrierIndex = topStart + randi()%check_span
			outTopRow[barrierIndex] = 2
		#Do inbetween each pair of ladders
		if numLadders > 1:
			for i in range(numLadders - 1): #For every ladder PAIR
				if midLadders[i+1] - midLadders[i] > 1:
					#The barrier will be placed where the first ladder in pair is, plus a random offset
					#also add 1 to make sure not on top of ladder
					var barrierIndex = (midLadders[i]+1) + randi()%(midLadders[i+1] - midLadders[i] - 1)
					outTopRow[barrierIndex] = 2
		#Do outside of last ladder
		check_span = topEnd - midLadders[midLadders.size()-1]
		if check_span >= 1:
			#then it's possible to place a barrier there
			var barrierIndex = midLadders[midLadders.size()-1] + 1 + randi()%check_span
			outTopRow[barrierIndex] = 2
				
		
	
	###<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	
	var outData = [outBotRow, outMidRow, outTopRow]
	return(outData)

#This function takes two rows (the top two)
#and will analyze the bottom row for barriers and add ladders to the top row (the deck)
func RowDeckTop(botRow, midRow):
	#The modified rows we will out put... copy for now
	var outBotRow = botRow
	var outMidRow = midRow
	
	#Function variables
	var botStart = 0 #index of row where bottom walking path starts (4s)
	var botEnd = 0 #index of row where bot walking path ends (4s) THE LAST INDEX THAT IS STILL WALKING SPACE
	var botBarriers = [] #list of indices where barriers are placed
	var midLadders = [] #list of indices where ladders are placed (3s)
	
	#Parse Bottom row
	var row_index = 0 #index for iterating rows
	var foundWalkingSpace = false #Turn on or off whether we are counting the wakling spaces
	for e in botRow:
		if e == 4: #walking space
			if foundWalkingSpace == false:
				foundWalkingSpace = true
				botStart = row_index #keep track where we found the start
				
		if e == 2: #barrier
			botBarriers.append(row_index) #keep track where we find barriers
			
		if e == 1: #wall
			if foundWalkingSpace == true: #then we reached the end of walking space
				foundWalkingSpace = false
				botEnd = row_index - 1 #keep track where we found the end (but don't count this space)
				
		#iterate counters
		row_index = row_index + 1
	
	#Now add ladders where appropriate
	#Place ladders on either side of bottomBarriers (provided they fit)
	var check_span = 0 #checks the span between each ladder segment
	var numLadders = 0
	#Do outside of first ladder
	check_span = botBarriers[0] - botStart
	if check_span >= 1:
		#Then it's possible to place a ladder there
		var ladderIndex = botStart + randi()%check_span
		outMidRow[ladderIndex] = 3
		midLadders.append(ladderIndex)
		numLadders = numLadders + 1
	#Do in between each pair of botBarriers
	if botBarriers.size() > 1:
		for i in range(botBarriers.size() - 1): # FOR every barrier PAIR
			if botBarriers[i+1] - botBarriers[i] > 1:
				#The ladder will be placed where the first barrier is, plus a random offset
				#also add 1 to make sure not on top of barrier
				var ladderIndex = (botBarriers[i]+1) + randi()%(botBarriers[i+1] - botBarriers[i] - 1)
				outMidRow[ladderIndex] = 3
				midLadders.append(ladderIndex)
				numLadders = numLadders + 1
	#Do OUtside of last barrier
	check_span = botEnd - botBarriers[botBarriers.size()-1]
	if check_span >= 1:
		#Then it's possible to place a ladder there
		var ladderIndex = botBarriers[botBarriers.size() - 1] + 1 + randi()%check_span
		outMidRow[ladderIndex] = 3
		midLadders.append(ladderIndex)
		numLadders = numLadders + 1
	

			
			
	var outData = [outBotRow, outMidRow]
	return(outData)

#########################
### MANSION GEN -> clustering rooms and hallways together

#Generates a mansion by placing a room in a space
#and mashing a bunch of rooms and/or hallways onto it
# see Procedural Gernation in GameDesign. Level Design II: Dungeon Generation#
#
# MAP Legend
# 0 - Empty Space
# 1 - WALL
# 2 - FLOOR
# 3 - DOOR
#
# Output:
# 	a 2D indexed array [x][y] with tile data for the mansion (see legend)
#
# Input: 
# 	Vector2 Space dimensions where rooms can be placed
func GenerateMansion(space_dimensions):
	
	#Function Vars
	var num_rooms = 0 #will keep count of the number of rooms created
	var num_hallways = 0 #will keep count of the number of hallways created
	var map_space = []
	
	#Initialize map_space
	for i in range(space_dimensions.x):
		var new_row = []
		for j in range(space_dimensions.y):
			new_row.append(0)
		map_space.append(new_row)
	
	#TO START - BASE CASE
	#Place a random room in the space
	var temp_room = GenerateRoomAndOuterFloorCoord().floor_data
	
	#DEBUG:
	#temp_room = [[2,2,2,2,2,2,2],[2,2,2,2,2,2,2],[2,2,2,2,2,2,2],[2,2,2,2,2,2,2],[2,2,2,2,2,2,2]]
	
	
	#Stamp the Room down... Somewhere in the center is probs Best...
	var stamp_data = StampRoomOntoSpace(temp_room, map_space, Vector2(int(space_dimensions.x/2), int(space_dimensions.y/2)) )
	#Make sure stamping succeeded
	if stamp_data["success"] == true:
		map_space = stamp_data["space_array"]
	else:
		print("stamping failed.... watch out")
	# Wallify the room
	map_space = SurroundExposedFloors(map_space)
	# Find exposed walls to attach room to.
	var exposed_walls = IdentifyExposedWalls(map_space)
	
	#KEEP GOING UNTIL DONE - CONTINUOUS CASE
	#Now, keep scrunching rooms onto this one until reach the limit
	num_rooms = 1
	while(num_rooms < 8):

		#Pick a random exposed wall
		var temp_wall = exposed_walls[randi()%exposed_walls.size()]

		#Generate a new room
		var temp_room_data = GenerateRoomAndOuterFloorCoord()
		#Unpack the data for use later
		var floor_space = temp_room_data["floor_data"]
		var floor_coord = temp_room_data["outer_floor_coord"]
		var floor_dim_x = floor_space.size()
		var floor_dim_y = floor_space[0].size()

		#Based on the directions of each, orient the new room
		# 0 - UP
		# 1 - DOWN
		# 2 - LEFT
		# 3 - RIGHT
		var floor_direction = temp_room_data["direction"]
		var wall_direction = temp_wall.z #z coordinate contains direction code
		#There are 16 different cases....
		#Each will need to rotate the floor a certain direction
		#And adjust the stamp location in a certain way....
		var stamp_location = Vector2(0,0)
		# CASE 1: W up, F down
		if wall_direction == 0 and floor_direction == 1:
			print("case 1")
			#Calculate new stamp location
			stamp_location.x = temp_wall.x - floor_coord.x
			stamp_location.y = temp_wall.y - floor_dim_y 
			#Attempt to stamp...
			stamp_data = StampRoomOntoSpace(floor_space, map_space, stamp_location )
			#Make sure stamping succeeded 
			if stamp_data["success"] == true:
				print("yes stamp")
				map_space = stamp_data["space_array"]
				num_rooms = num_rooms + 1
				#FINISHING UP/BOOKKEEPING after floor place
				map_space[temp_wall.x][temp_wall.y] = 3 #turn into door
				map_space = SurroundExposedFloors(map_space) #WALLIFY!
			else:
				print("no stamp")
				continue

		# CASE 2: W down, F up
		if wall_direction == 1 and floor_direction == 0:
			print("case 2")
			#Calculate new stamp location
			stamp_location.x = temp_wall.x - floor_coord.x
			stamp_location.y = (temp_wall.y + 1) + floor_coord.y
			#Attempt to stamp...
			stamp_data = StampRoomOntoSpace(floor_space, map_space, stamp_location )
			#Make sure stamping succeeded 
			if stamp_data["success"] == true:
				print("yes stamp")
				map_space = stamp_data["space_array"]
				num_rooms = num_rooms + 1
				#FINISHING UP/BOOKKEEPING after floor place
				map_space[temp_wall.x][temp_wall.y] = 3 #turn into door
				map_space = SurroundExposedFloors(map_space) #WALLIFY!
			else:
				print("no stamp")
				continue
				
		# CASE 3: W left, F right
		if wall_direction == 2 and floor_direction == 3:
			print("case 3")
			#Calculate new stamp location
			stamp_location.x = temp_wall.x - floor_dim_x
			stamp_location.y = temp_wall.y - floor_coord.y
			#Attempt to stamp...
			stamp_data = StampRoomOntoSpace(floor_space, map_space, stamp_location )
			#Make sure stamping succeeded 
			if stamp_data["success"] == true:
				print("yes stamp")
				map_space = stamp_data["space_array"]
				num_rooms = num_rooms + 1
				#FINISHING UP/BOOKKEEPING after floor place
				map_space[temp_wall.x][temp_wall.y] = 3 #turn into door
				map_space = SurroundExposedFloors(map_space) #WALLIFY!
			else:
				print("no stamp")
				continue

		# CASE 4: W right, F left
		if wall_direction == 3 and floor_direction == 2:
			print("case 4")
			#Calculate new stamp location
			stamp_location.x = temp_wall.x + 1
			stamp_location.y = temp_wall.y - floor_coord.y
			#Attempt to stamp...
			stamp_data = StampRoomOntoSpace(floor_space, map_space, stamp_location )
			#Make sure stamping succeeded 
			if stamp_data["success"] == true:
				print("yes stamp")
				map_space = stamp_data["space_array"]
				num_rooms = num_rooms + 1
				#FINISHING UP/BOOKKEEPING after floor place
				map_space[temp_wall.x][temp_wall.y] = 3 #turn into door
				map_space = SurroundExposedFloors(map_space) #WALLIFY!
			else:
				print("no stamp")
				continue

#		#There are four cases...
#		# CASE 1 - Directions aligned (no rotation needed)
#		if (wall_direction == 0 and floor_direction == 1) or \
#		   (wall_direction == 1 and floor_direction == 0) or \
#		   (wall_direction == 2 and floor_direction == 3) or \
#		   (wall_direction == 3 and floor_direction == 2):
#			print("floor already aligned")
#		# CASE 2 - Floor needs to be rotated LEFT
#		if (wall_direction == 0 and floor_direction == 2) or \
#		   (wall_direction == 1 and floor_direction == 3) or \
#		   (wall_direction == 2 and floor_direction == 1) or \
#		   (wall_direction == 3 and floor_direction == 0):
#			print("floor needs to be rotated left")
#		# CASE 3 - Floor needs to be rotated RIGHT
#		if (wall_direction == 0 and floor_direction == 3) or \
#		   (wall_direction == 1 and floor_direction == 2) or \
#		   (wall_direction == 2 and floor_direction == 0) or \
#		   (wall_direction == 3 and floor_direction == 1):
#			print("floor rot RIGHT")
#		# CASE 4 - Floor needs to be rotated 180 deg
#		if (wall_direction == 0 and floor_direction == 0) or \
#		   (wall_direction == 1 and floor_direction == 1) or \
#		   (wall_direction == 2 and floor_direction == 2) or \
#		   (wall_direction == 3 and floor_direction == 3):
#			print("floor flipped 180")

		#DEBUG TO END LOOP!
		#num_rooms = num_rooms + 1
		
		#Recalculate exposed walls
		exposed_walls = IdentifyExposedWalls(map_space)

	print("Done making mansion")
	
	return(map_space)

#Generates a Hallway and
# ALSO returns a coord of a floor that can be spliced onto other walls...
func GenerateHallwayAndOuterFloorCoord():	
	
	print("a hallway")
	

#Generates a Room and
# ALSO returns a coord of a floor that can be spliced onto other walls...
# Returns a 2D x,y-indexed array of room tiles
# Only contains the FLOOR DATA and EMPTY SPACE DATA
# 0 - EMPTY SPACE
# 2 - FLOOR 
#
# But the dircetion code corresponds to the following:
# 0 - UP
# 1 - DOWN
# 2 - LEFT
# 3 - RIGHT
func GenerateRoomAndOuterFloorCoord():
	
	#Function variabls
	var room_data = []
	
	#Make a SQUARE room...
	#Generate random dimensions...
	var room_dimension = Vector2(4+randi()%3, 4+randi()%3)
	#Enter the floor data into an array...
	for i in range(room_dimension.x):
		var row = []
		for j in range(room_dimension.y):
			row.append(2)
		room_data.append(row)
		
	
	var outerFloorCoord = Vector2(0,0) #a coord of one of the outer coords...
	#Choose a random coord on the perimeter....
	var choice = randi()%4 #1 out of the 4 sides...
	match(choice):
		0:
			#Top Row...
			outerFloorCoord.x = randi()%int(room_dimension.x)
			outerFloorCoord.y = 0
		1:
			#Bottom Row
			outerFloorCoord.x = randi()%int(room_dimension.x)
			outerFloorCoord.y = room_dimension.y
		2:
			#Left Row
			outerFloorCoord.x = 0
			outerFloorCoord.y = randi()%int(room_dimension.y)
		3:
			#Right Row...
			outerFloorCoord.x = room_dimension.x
			outerFloorCoord.y = randi()%int(room_dimension.y)
	
	var return_data = {
		"floor_data" : room_data,
		"outer_floor_coord" : outerFloorCoord,
		"direction" : choice
	}
	
	return(return_data)


###Function to stamp a room onto a space
# input a room array, then stamps on the contents of it onto the space_array at the specified location
# Will make sure the stamped room fits onto the space (with at least 1 tile of empty space to spare)
# Will also make sure it's not stamping onto any exisiting floor/wall/door tiles
# or else it will return FALSE...
# returns TRUE otherwise...
func StampRoomOntoSpace(room_array, space_array, location_coords):
	
	#First, make sure the room will fit into the space array in the first place...
	#Return false if it doesn't
	if location_coords.x < 1:
			var return_data = {
				"success" : false,
				"space_array" : space_array
			}
			return(return_data)
	if location_coords.x + room_array.size() > space_array.size() - 1:
			var return_data = {
				"success" : false,
				"space_array" : space_array
			}
			return(return_data)
	if location_coords.y < 1:
			var return_data = {
				"success" : false,
				"space_array" : space_array
			}
			return(return_data)
	if location_coords.y + room_array[0].size() > space_array[0].size() - 1:
			var return_data = {
				"success" : false,
				"space_array" : space_array
			}
			return(return_data)
	
	#Next, Make a copy of the existing space_array 
	var space_array_copy = Copy2DArray(space_array)
	
	#Stamp the room onto this new space copy
	# -> WHile going through stamping, make sure you are only placing on empty space
	# -> if placing on existing space, quit and return FALSE and the original space_array
	for i in range(room_array.size()):
		for j in range(room_array[0].size()):
			#Check if an actual floor is specified
			if room_array[i][j] == 2:
				#Check if the space_array is clear at that spot...
				var space_x = i + location_coords.x
				var space_y = j + location_coords.y
				#If it's clear, stamp down, otherwise return FALSE
				if(space_array_copy[space_x][space_y]==0):
					space_array_copy[space_x][space_y]=2
				else:
					print("failed try overwrite")
					print(space_array_copy[space_x][space_y])
					var return_data = {
						"success" : false,
						"space_array" : space_array
					}
					return(return_data)
					
	
	#If successfully finish stamping, return TRUE
	
	var return_data = {
		"success" : true,
		"space_array" : space_array_copy
	}
	
	return(return_data)
	
##Function that creates walls around all empty floor space
func SurroundExposedFloors(space_array):
	#Cycle through every element and identify empty spaces
	# IF IT"S TOUCHING A FLOOR, TURN IT INTO A WALL!!
	for i in range(space_array.size()):
		for j in range(space_array[0].size()):
			if space_array[i][j] == 0:
				#Then we can start checking all of it's surrounding cells.... ALL 8...
				#NW Tile
				if i - 1 >= 0 and j - 1 >= 0:
					if space_array[i-1][j-1] == 2:
						space_array[i][j] = 1
				#N Tile
				if j - 1 >= 0:
					if space_array[i][j-1] == 2:
						space_array[i][j] = 1
				#NE Tile
				if i + 1 < space_array.size() and j - 1 >= 0:
					if space_array[i+1][j-1] == 2:
						space_array[i][j] = 1
				#W TILE
				if i - 1 >= 0:
					if space_array[i-1][j] == 2:
						space_array[i][j] = 1
				#E TILE
				if i + 1 < space_array.size():
					if space_array[i+1][j] == 2:
						space_array[i][j] = 1
				#SW TILE
				if i - 1 >= 0 and j + 1 < space_array[0].size():
					if space_array[i-1][j+1] == 2:
						space_array[i][j] = 1
				#S TILE
				if j + 1 < space_array[0].size():
					if space_array[i][j+1] == 2:
						space_array[i][j] = 1
				#SE TILE
				if i + 1 < space_array.size() and j + 1 < space_array[0].size():
					if space_array[i+1][j+1] == 2:
						space_array[i][j] = 1


	return(space_array)
					

## Function that identifies all walls that can have other rooms/hallways attached
# Any wall that has an empty tile on one side and a floor tile on the other 
# returns a list with these Vector3 coords
# THE VECTOR3 is SPECIAL!!
# Vector3 Return:
# x - x coord
# y - y coord
# z - DIRECTION Code

#Direction Codes:
# 0 - UP
# 1 - DOWN
# 2 - LEFT
# 3 - RIGHT
func IdentifyExposedWalls(space_array):
	
	var candidate_list = [] #list of Vector3 of wall coods that can be latched on to...
	
	#Cycle through every element and identify exposed walls
	# if it's a wall and has empty on one side and floor on the other 0 & 2
	for i in range(space_array.size()):
		for j in range(space_array[0].size()):
			if space_array[i][j] == 1:
				#Then we can start checking all of it's surrounding cells.... ALL 4...
				var u_tile = 99 #initialize with 99 to indicate if it hasn't been set
				var d_tile = 99 #initialize with 99 to indicate if it hasn't been set
				var l_tile = 99 #initialize with 99 to indicate if it hasn't been set
				var r_tile = 99 #initialize with 99 to indicate if it hasn't been set
				#UP Tile
				if j - 1 >= 0:
					u_tile = space_array[i][j-1]
				#LEFT TILE
				if i - 1 >= 0:
					l_tile = space_array[i-1][j]
				#RIGHT TILE
				if i + 1 < space_array.size():
					r_tile = space_array[i+1][j]
				#DOWN TILE
				if j + 1 < space_array[0].size():
					d_tile = space_array[i][j+1] 
				
				#Check for up direction
				if u_tile == 0 and d_tile == 2:
					var temp_vector = Vector3(i,j,0)
					candidate_list.append(temp_vector)
				#Check for down direction
				if u_tile == 2 and d_tile == 0:
					var temp_vector = Vector3(i,j,1)
					candidate_list.append(temp_vector)
				#Check for left direction
				if r_tile == 2 and l_tile == 0:
					var temp_vector = Vector3(i,j,2)
					candidate_list.append(temp_vector)
				#Check for right direction
				if r_tile == 0 and l_tile == 2:
					var temp_vector = Vector3(i,j,3)
					candidate_list.append(temp_vector)
	
	return(candidate_list)

###Utility functions for room map arrays
#input direction for rotation: "left" or "right"
func Rotate2DArray(map_array, direction):
	
	var rotated_map = []
	
	#Let's take this in steps...
	#Whether it's left or right, the new matrix will still be the same size... let's initialize
	for i in range(map_array[0].size()):
		var temp_row = []
		for j in range(map_array.size()):
			temp_row.append(0)
		rotated_map.append(temp_row)
	
	if direction == "right":
		#Cycle through every row and place into last column of new array
		# FIRST row into LAST col
		for i in range(map_array.size()):
			for j in range(map_array[0].size()):
				#Read in element from original array
				var read_element = map_array[i][j]
				#Now place into new array
				rotated_map[rotated_map.size()-1-j][i] = read_element
				
	if direction == "left":
		#Cycle through every row and place into first column of new array
		# FIRST row into FIRST col
		for i in range(map_array.size()):
			for j in range(map_array[0].size()):
				#Read in element from original array
				var read_element = map_array[i][j]
				#Now place into new array
				rotated_map[j][rotated_map[0].size()-1-i] = read_element
	
	return(rotated_map)
	

#Copies an entire array element by element
func Copy2DArray(in_array):
	
	var copy_array = []
	
	#Initializing Array
	for i in range(in_array.size()):
		var new_row = []
		for j in range(in_array[0].size()):
			new_row.append(in_array[i][j])
		copy_array.append(new_row)
	
	return(copy_array)
	