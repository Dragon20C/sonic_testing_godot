extends Node3D
class_name Demo
# Arena Loader class

@export_group("Arena Config")
@export var arena_packages : Array[ArenaPackage]
@export var arena_ID : int = 0
@export var arena_root : Node3D
@export var song_player : AudioStreamPlayer
@export_group("Gui Config")
@export var previous_label : Label
#@export var prev_button : Button
@export var current_label : Label
#@export var next_button : Button
@export var next_label : Label

## Private ##
var _disabled : bool = false
var _arena_package : ArenaPackage
var _arena : Node3D


func _ready() -> void:
	if arena_packages.is_empty():
		_disabled = true
		return
	
	if not is_instance_valid(song_player):
		_disabled = true
		return
	# the load next arena function loads the next, but for the initial loading we just take 1 away
	load_map_by_name("Emerald Beach")

func load_arena(ID : int) -> void:
	unload_arena()
	
	if ID in range(0,arena_packages.size()):
		_arena_package = arena_packages[ID]
	
	if _arena_package == null:
		printerr("Arena ID is out of range: Current ID -> %s , max size -> %s" % [ID,arena_packages.size() - 1])
		return
	
	print("Loading arena (%s)" % _arena_package.arena_title)
	
	_arena = _arena_package.arena_scene.instantiate()
	arena_root.add_child(_arena)
	
	# wait one physics frame before attempting to get children
	await get_tree().physics_frame
	
	var spawn_point_root : Node3D = _arena.get_node("SpawnPoints")
	
	if spawn_point_root:
		var spawn_points : Array = spawn_point_root.get_children()
		if spawn_points:
			print("spawn points found, %s valid positions exist" % spawn_points.size())
	else:
		print("Spawn points not found, returning...")
		return
		
	if _arena_package.arena_song:
		song_player.stream = _arena_package.arena_song
		song_player.play()
	

func unload_arena() -> void:
	if is_instance_valid(_arena):
		_arena.queue_free()
		_arena_package = null
		song_player.stop()

func load_next_arena(dir : String) -> void:
	
	match dir:
		"+":
			arena_ID = wrapi(arena_ID + 1, 0, arena_packages.size())
		"-":
			arena_ID = wrapi(arena_ID - 1, 0, arena_packages.size())
		_:
			return 
	
	previous_label.text = "- %s -" % arena_packages[wrap_id_around(arena_ID - 1)].arena_title
	current_label.text = "- %s -" % arena_packages[arena_ID].arena_title
	next_label.text = "- %s -" % arena_packages[wrap_id_around(arena_ID + 1)].arena_title
	
	load_arena(arena_ID)

func wrap_id_around(id : int) -> int:
	return wrapi(id, 0, arena_packages.size())

func load_map_by_name(map_name : String) -> void:
	
	var temp_id : int = 0
	for package in arena_packages:
		# check if the package title matches
		if package.arena_title == map_name:
			arena_ID = temp_id
			load_arena(temp_id)
			
			previous_label.text = "- %s -" % arena_packages[wrap_id_around(arena_ID - 1)].arena_title
			current_label.text = "- %s -" % arena_packages[arena_ID].arena_title
			next_label.text = "- %s -" % arena_packages[wrap_id_around(arena_ID + 1)].arena_title
			return
		# increment a temp var so we can update labels
		temp_id += 1
		
	# fall back if map name is not found
	print("Falling back to index 0, map not found (%s)" % map_name)
	load_arena(arena_ID)
	previous_label.text = "- %s -" % arena_packages[wrap_id_around(arena_ID - 1)].arena_title
	current_label.text = "- %s -" % arena_packages[arena_ID].arena_title
	next_label.text = "- %s -" % arena_packages[wrap_id_around(arena_ID + 1)].arena_title

func _on_left_pressed() -> void:
	load_next_arena("-")


func _on_right_pressed() -> void:
	load_next_arena("+")
