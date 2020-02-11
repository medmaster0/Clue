extends Node2D

#GLOBAL VARS FOR GRAPH DRAWING
var prufer_code
var edges
var tree
var mod_tree
var pos_tree


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	prufer_code = Story.GeneratePruferCode(50)
	#prufer_code = [3,0,2,3]
	#print("Prufer Code:")
	#print(prufer_code)

	edges = Story.EdgesFromPruferCode(prufer_code)
	#print("Edges")
	#print(edges)

	tree = Story.TreeFromEdges(edges)
	#print("Tree")
	#print(tree)
	
#	var postorder_tree = Story.TreePostOrderChildren(deep_copy(tree))
#	print("PostOrder")
#	print(postorder_tree)

#	var mod_tree = Story.CalculateModTree(deep_copy(postorder_tree))
#	print("Mod Tree")
#	print(mod_tree)
	
	mod_tree = Story.CalculateModTree(deep_copy(tree))
	#print("Mod Tree")
	#print(mod_tree)
	Story.PrintTreeKeys(mod_tree)
	
	pos_tree = Story.CalculatePosTree(deep_copy(mod_tree), 0.0)
	#print("Pos tree")
	#print(pos_tree)
	#Story.PrintTreeKeys(pos_tree)
	
	#Continuously space the tree until done
	while(Story.TreeSpaceChildren(pos_tree,mod_tree) == true):
		pos_tree = Story.CalculatePosTree(deep_copy(mod_tree), 0.0)
	#Story.TreeSpaceChildren(pos_tree, mod_tree)
	#print(mod_tree)
	Story.PrintTreeKeys(mod_tree)

	#After TreeSpaceChildren is called, we need to recalc pos_tree
	pos_tree = Story.CalculatePosTree(deep_copy(mod_tree), 0.0)
	#print(pos_tree)
	#Story.PrintTreeKeys(pos_tree)

	
	
	
	Story.DrawGraphNodes(tree, pos_tree, Vector2(50,50), Vector2(200,50), self, 0)

#	var edges = [Vector2(0,1), Vector2(1,2)]
#	var tree = Story.TreeFromEdges(edges)
#	print(tree)


#called every time it's drawn
func _draw():
	
	var line_color = Color(randf(), randf(), randf())
	
	#Draw the lines of the graph
	var line_data = Story.DrawGraphLines(tree, pos_tree, Vector2(50,50), Vector2(200,50), self, 0)
	for i in range(line_data["start_vects"].size()):
		draw_line(line_data["start_vects"][i], line_data["stop_vects"][i], line_color, 4)

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
