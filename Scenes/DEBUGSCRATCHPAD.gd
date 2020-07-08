extends Node2D

#GLOBAL VARS FOR GRAPH DRAWING
var prufer_code
var edges
var tree
var mod_tree
var pos_tree

export (PackedScene) var FarmTile

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var dirt_color_base = MedAlgo.generate_darkenable_color(0.22)
	
	#FARM TEST
	#DIRT PATCH 1 - all random offset
	for i in range(10):
		for j in range(12):
			var temp_farm_tile = FarmTile.instance()
			temp_farm_tile.position = Vector2(i*16, j*16)
			add_child(temp_farm_tile)
			temp_farm_tile.change_tile(1)
			var temp_dirt_color = MedAlgo.generate_off_color(dirt_color_base,0.05)
			temp_dirt_color = MedAlgo.color_to_pastel_set_grey(temp_dirt_color,rand_range(0.0,0.75))
			temp_farm_tile.SetPrim(temp_dirt_color); 
			
	
	#DIRT PATCH 2 - random pick from 10 random offsets
	#(VASTLY SUPERIOR!!!!)
	var offset_return_data = MedAlgo.generate_offset_color_set(dirt_color_base,10,0.05)
	for i in range(10):
		for j in range(12):
			var temp_farm_tile = FarmTile.instance()
			temp_farm_tile.position = Vector2(17*16+i*16, j*16)
			add_child(temp_farm_tile)
			temp_farm_tile.change_tile(1)
			var temp_dirt_color = offset_return_data["color_set"][randi()%offset_return_data["color_set"].size()]
			temp_farm_tile.SetPrim(temp_dirt_color); 
	
	
	#FOLIAGE TEST...
	
#	#####SAVE THIS CODE OMG BAD I KNOW
#	## TREE GRAPH HIERARCHY DISPLAY
#	##VvvVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
#
#
#	prufer_code = Story.GeneratePruferCode(50)
#	#prufer_code = [3,0,2,3]
#	#print("Prufer Code:")
#	#print(prufer_code)
#
#	edges = Story.EdgesFromPruferCode(prufer_code)
#	#print("Edges")
#	#print(edges)
#
#	tree = Story.TreeFromEdges(edges)
#	#print("Tree")
#	#print(tree)
#
##	var postorder_tree = Story.TreePostOrderChildren(deep_copy(tree))
##	print("PostOrder")
##	print(postorder_tree)
#
##	var mod_tree = Story.CalculateModTree(deep_copy(postorder_tree))
##	print("Mod Tree")
##	print(mod_tree)
#
#	mod_tree = Story.CalculateModTree(deep_copy(tree))
#	#print("Mod Tree")
#	#print(mod_tree)
#	Story.PrintTreeKeys(mod_tree)
#
#	pos_tree = Story.CalculatePosTree(deep_copy(mod_tree), 0.0)
#	#print("Pos tree")
#	#print(pos_tree)
#	#Story.PrintTreeKeys(pos_tree)
#
#	#Continuously space the tree until done
#	while(Story.TreeSpaceChildren(pos_tree,mod_tree) == true):
#		pos_tree = Story.CalculatePosTree(deep_copy(mod_tree), 0.0)
#	#Story.TreeSpaceChildren(pos_tree, mod_tree)
#	#print(mod_tree)
#	Story.PrintTreeKeys(mod_tree)
#
#	#After TreeSpaceChildren is called, we need to recalc pos_tree
#	pos_tree = Story.CalculatePosTree(deep_copy(mod_tree), 0.0)
#	#print(pos_tree)
#	#Story.PrintTreeKeys(pos_tree)
#
#
#	Story.DrawGraphNodes(tree, pos_tree, Vector2(50,50), Vector2(200,50), self, 0)
#
##	var edges = [Vector2(0,1), Vector2(1,2)]
##	var tree = Story.TreeFromEdges(edges)
##	print(tree)
#
#
#	#######END TREE HIERARCHY DRAW



#called every time it's drawn
#func _draw():
	
#	### TREE HIERARCHY DRAWW
#
#	var line_color = Color(randf(), randf(), randf())
#
#	#Draw the lines of the graph
#	var line_data = Story.DrawGraphLines(tree, pos_tree, Vector2(50,50), Vector2(200,50), self, 0)
#	for i in range(line_data["start_vects"].size()):
#		draw_line(line_data["start_vects"][i], line_data["stop_vects"][i], line_color, 4)
#
#	##END HIERARCHY DRAWW

### UTILITY FOR COPYING DICTIONARIES ESPECIALLY
static func deep_copy(v):
    var t = typeof(v)

    if t == TYPE_DICTIONARY:
        var d = {}
        for k in v:
            d[k] = deep_copy(v[k])
        return d

    elif t == TYPE_ARRAY:
        var d = []
        d.resize(len(v))
        for i in range(len(v)):
            d[i] = deep_copy(v[i])
        return d

    elif t == TYPE_OBJECT:
        if v.has_method("duplicate"):
            return v.duplicate()
        else:
            print("Found an object, but I don't know how to copy it!")
            return v

    else:
        # Other types should be fine,
        # they are value types (except poolarrays maybe)
        return v
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
