extends Node
const ROOM_SIZE := Vector2(480, 270)
const PLAYER_SCENE := preload("res://Entities/Player/player.tscn")
#allows it to autoload
var spawned_rooms: Dictionary = {} # Vector2i -> Node2D
const DIRS := {
	#assigns direction to grid offsets
	"N": Vector2i.UP,
	"E": Vector2i.RIGHT,
	"S": Vector2i.DOWN,
	"W": Vector2i.LEFT
}
const OPPOSITE := {
	#shows the direction you arrive in when you go through the door
	"N": "S",
	"S": "N",
	"W": "E",
	"E": "W"
}
const ROOM_POOLS := {
	#1-Door
	"N": preload("res://rooms/room_scenes/1_Doors/N.tscn"),
	"E": preload("res://rooms/room_scenes/1_Doors/E.tscn"),
	"S": preload("res://rooms/room_scenes/1_Doors/S.tscn"),
	"W": preload("res://rooms/room_scenes/1_Doors/W.tscn"),
	#2-Doors
	"ES": preload("res://rooms/room_scenes/2_doors/E_S.tscn"),
	"EW": preload("res://rooms/room_scenes/2_doors/E_W.tscn"),
	"EN": preload("res://rooms/room_scenes/2_doors/N_E.tscn"),
	"NS": preload("res://rooms/room_scenes/2_doors/N_S.tscn"),
	"NW": preload("res://rooms/room_scenes/2_doors/N_W.tscn"),
	"SW": preload("res://rooms/room_scenes/2_doors/S_W.tscn"),
	#3-Doors
	"ESW": preload("res://rooms/room_scenes/3_Doors/E_S_W.tscn"),
	"ENS": preload("res://rooms/room_scenes/3_Doors/N_E_S.tscn"),
	"ENW": preload("res://rooms/room_scenes/3_Doors/N_E_W.tscn"),
	"NSW": preload("res://rooms/room_scenes/3_Doors/N_S_W.tscn"), 
	#4-Doors
	"ENSW": preload("res://rooms/room_scenes/4_Doors/N_E_S_W.tscn")
}

const BOSS_ROOM_SCENE := preload("res://rooms/room_scenes/1_Doors/Boss.tscn")
#stores boss scene
#Variables for States
var dungeon: Dictionary = {}
#holds dungeon map
var current_coords: Vector2i = Vector2i.ZERO
#holds the cord in our grid the player is in
var entry_direction: String = ""
#direction you entry from
func generate_dungeon(main_path_length: int = 6, branch_count: int = 2):
	#steup function that defines a 6 rooom path whith 2 side branches that lead to nothing
	while not _try_build_layout(main_path_length, branch_count): 
		#makes sure the function keeps trying to generate until it does succeed
		pass
	for coords: Vector2i in dungeon.keys():
		#for loop loops through all coordinates made during the generation and checks its condition
		var cells: Dictionary = dungeon[coords]
		if cells ["kind"] == "boss": 
			#checks for boss room
			cells ["scene"] = BOSS_ROOM_SCENE
		else:
			#if not it converts the rooms doors into a alphabet look up key and then chooses random matching rooms. 
			var key := _get_direction_key(cells["doors"])
			var pool: Array = ROOM_POOLS[key]    
			cells["scene"] = pool.pick_random() 
func _try_build_layout(main_path_length: int, branch_count: int) -> bool:
	dungeon.clear()
	var main_path: Array[Vector2i] = [Vector2i.ZERO]
	dungeon[Vector2i.ZERO] = {"doors": [], "scene": "", "kind": "start"}

	# 1. Carve the main path (creates a chain of 2-door rooms)
	while main_path.size() < main_path_length - 1:
		var current: Vector2i = main_path.back()
		var open_dirs_current := _get_unvisited_neighbors(current)
		if open_dirs_current.is_empty():
			return false
		var chosen_dir: String = open_dirs_current.pick_random()
		var next_coords: Vector2i = current + DIRS[chosen_dir]
		dungeon[next_coords] = {"doors": [], "scene": "", "kind": "normal"}
		_connect_rooms(current, next_coords, chosen_dir)
		main_path.append(next_coords)

	# 2. Place the Boss Room at the end (always 1 step North so it uses a South entrance)
	var pre_boss: Vector2i = main_path.back()
	var boss_coords: Vector2i = pre_boss + DIRS["N"]
	if dungeon.has(boss_coords):
		return false
	dungeon[boss_coords] = {"doors": [], "scene": "", "kind": "boss"}
	_connect_rooms(pre_boss, boss_coords, "N")
	main_path.append(boss_coords)

	# 3. Add side branches ONLY to 2-door rooms (turns them into 3-door rooms)
	var candidates: Array[Vector2i] = []
	for coords in main_path:
		if dungeon[coords]["kind"] == "normal" and dungeon[coords]["doors"].size() == 2:
			candidates.append(coords)
	candidates.shuffle()
	var branches_added := 0
	for junction in candidates:
		if branches_added >= branch_count:
			break
		var open_dirs_junction := _get_unvisited_neighbors(junction)
		if open_dirs_junction.is_empty():
			continue
		var branch_dir: String = open_dirs_junction.pick_random()
		var dead_end: Vector2i = junction + DIRS[branch_dir]
		dungeon[dead_end] = {"doors": [], "scene": "", "kind": "reward"}
		_connect_rooms(junction, dead_end, branch_dir)
		branches_added += 1

	return true
func _connect_rooms(a: Vector2i, b: Vector2i, dir_from_a_to_b: String) -> void:
	dungeon[a]["doors"].append(dir_from_a_to_b)#adds direction we add
	dungeon[b]["doors"].append(OPPOSITE[dir_from_a_to_b])#adds direction we add
func _get_unvisited_neighbors(coords: Vector2i) -> Array[String]:
	var available: Array[String] = []
	for dir: String in DIRS.keys():
		if not dungeon.has(coords + DIRS[dir]):
			available.append(dir)
	return available
func _get_direction_key(dirs: Array) -> String:
	var sorted := dirs.duplicate()#takes array and turns it into a room key readable to us
	sorted.sort()
	return "".join(sorted)
func start_run() -> void:
	generate_dungeon(6, 2)	
	current_coords = Vector2i.ZERO
	entry_direction = ""
	_load_room(dungeon[current_coords]["scene"])
func move_through_door(exit_direction: String) -> void:
	
	var next_coords: Vector2i = current_coords + DIRS[exit_direction]
	if not dungeon.has(current_coords):
		return
	var current_room: Node2D = spawned_rooms.get(current_coords)
	var current_pos := current_coords
	var next_room_pos := next_coords 
	current_coords += next_coords
	entry_direction = OPPOSITE[exit_direction]
	_load_room(dungeon[current_coords]["scene"], next_room_pos)
func _load_room(room_scene: PackedScene, target_pos: Vector2 = Vector2.ZERO) -> void:
	var room_instance: Node2D
	if spawned_rooms.has(current_coords) and is_instance_valid(spawned_rooms[current_coords]):
		room_instance = spawned_rooms[current_coords]
	else:
		room_instance = room_scene.instantiate() as Node2D
		room_instance.global_position = target_pos
		get_tree().current_scene.add_child(room_instance)
		spawned_rooms[current_coords] = room_instance
		var cam_tween = get_tree().create_tween()
		cam_tween.tween_property(get_viewport().get_camera_2d(), "global_position", target_pos, 1)
	"""
	get_tree().change_scene_to_file.call_deferred(scene_path)
	# Wait for the deferred scene swap to finish loading the new room
	await get_tree().process_frame
	await get_tree().process_frame
	_spawn_and_position_player()
	"""
func _spawn_and_position_player() -> void:
	var room := get_tree().current_scene
	if room == null:
		return

	var player: CharacterBody2D = null
	for child in room.get_children():
		if child is CharacterBody2D:
			player = child
			break

	if player == null:
		player = PLAYER_SCENE.instantiate()
		room.add_child(player)

	if entry_direction != "":
		for child in room.get_children():
			if "door_direction" in child and child.door_direction == entry_direction:
				if child.has_method("play_entry_walk"):
					child.play_entry_walk(player)
				break
		entry_direction = ""
	elif player.global_position == Vector2.ZERO:
		var start_marker := room.get_node_or_null("PlayerStart")
		player.global_position = start_marker.global_position if start_marker else Vector2(224, 136)
