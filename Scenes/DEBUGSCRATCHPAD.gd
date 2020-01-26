extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var prufer_code = Story.GeneratePruferCode(16)
	#prufer_code = [3,0,2,3]
	print("Prufer Code:")
	print(prufer_code)

	var edges = Story.EdgesFromPruferCode(prufer_code)
	print("Edges")
	print(edges)

	var tree = Story.TreeFromEdges(edges)
	print("Tree")
	print(tree)
	
	var postorder_tree = Story.TreePostOrderChildren(deep_copy(tree))
	print("PostOrder")
	print(postorder_tree)

	var mod_tree = Story.CalculateModTree(deep_copy(postorder_tree))
	print("Mod Tree")
	print(mod_tree)

#	var edges = [Vector2(0,1), Vector2(1,2)]
#	var tree = Story.TreeFromEdges(edges)
#	print(tree)

	
#	var test_dict = {2:{3:{0:{0:{ 0:{5:{}} , 1:{4:{}} }}}}}
#	print(Story.KeyDepthInTree(test_dict,1))


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
