class_name MapGenerator
extends Node

var X_DIST = Global.X_DIST
var Y_DIST =  Global.Y_DIST
var PLACEMENT_RANDOMNESS =  Global.PLACEMENT_RANDOMNESS
var FLOORS =  Global.FLOORS
var MAP_WIDTH =  Global.MAP_WIDTH
var PATHS =  Global.PATHS
var MONSTERS_ROOM_WEIGHT =  Global.MONSTERS_ROOM_WEIGHT
var SHOP_ROOM_WEIGHT =  Global.SHOP_ROOM_WEIGHT
var CAMPFIRE_ROOM_WEIGHT =  Global.CAMPFIRE_ROOM_WEIGHT

var random_room_type_weights = {
	Room.Type.MONSTER: 0.0,
	Room.Type.CAMPFIRE: 0.0,
	Room.Type.SHOP: 0.0,
}
var random_room_type_total_weight := 0
var map_data: Array[Array]


func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	var starting_points := _get_random_starting_points()
	
	for j in starting_points:
		var current_j := j
		for i in FLOORS - 1:
			current_j = _setup_connection(i, current_j)
			
	_setup_boss_room()
	_setup_random_room_weights()
	_setup_random_types()
	
	var i := 0
	for floor in map_data:
		print("floor %s" % i)
		var used_rooms = floor.filter(
			func(room: Room): return room.next_rooms.size() > 0
		)
		print(used_rooms)
		i += 1
	
	return map_data
	
func _generate_initial_grid() -> Array[Array]:
	
	var result: Array[Array] = []
	
	for i in FLOORS:
		var adjacent_rooms: Array[Room]= []
		
		for j in MAP_WIDTH:
			var current_room := Room.new()
			var offset = Vector2(randf(), randf()) * PLACEMENT_RANDOMNESS
			current_room.position = Vector2(j * X_DIST, i * -Y_DIST) + offset
			current_room.row = i
			current_room.column = j
			current_room.next_rooms = []
			
			
			if i == FLOORS - 1:
				current_room.position.y = (i + 1) * -Y_DIST
				
			adjacent_rooms.append(current_room)
			
		result.append(adjacent_rooms)
			
	return result
			
		
func _get_random_starting_points() -> Array[int]:
	var y_coordinates: Array[int]
	var unique_points: int = 0
	
	while unique_points < 2:
		unique_points = 0
		y_coordinates = []
		
		for i in PATHS:
			var starting_point := randi_range(0, MAP_WIDTH - 1)
			if not y_coordinates.has(starting_point):
				unique_points += 1
			
			y_coordinates.append(starting_point)
			
	return y_coordinates


func _setup_connection(i: int, j: int) -> int:
	var next_room: Room
	var current_room := map_data[i][j] as Room
	
	while not next_room or _would_cross_exsisting_path(i,j,next_room):
		var random_j := clampi(randi_range(j - 1, j + 1), 0, MAP_WIDTH - 1)
		next_room = map_data[i + 1][random_j]
	
	current_room.next_rooms.append(next_room)
	
	return next_room.column
	
	
func _would_cross_exsisting_path(i: int, j: int, room: Room) -> bool:
	var left_neighbour: Room
	var right_neighbour: Room

	if j > 0:
		left_neighbour = map_data[i][j - 1]
	if j < MAP_WIDTH - 1:
		right_neighbour = map_data[i][j + 1]

	if right_neighbour and room.column > j:
		for next_room in right_neighbour.next_rooms:
			if next_room.column < room.column:
				return true

	if left_neighbour and room.column < j:
		for next_room in left_neighbour.next_rooms:
			if next_room.column > room.column:  # Cambiar aquí
				return true
				
	return false

func _setup_boss_room() -> void:
	var middle := floori(MAP_WIDTH * 0.5)
	var boss_room := map_data[FLOORS -1][middle] as Room
	
	for j in MAP_WIDTH:
		var current_room = map_data[FLOORS -2][j] as Room
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[Room]
			current_room.next_rooms.append(boss_room)
	
	boss_room.type = Room.Type.BOSS
	
func _setup_random_room_weights():
	random_room_type_weights[Room.Type.MONSTER] = MONSTERS_ROOM_WEIGHT
	random_room_type_weights[Room.Type.CAMPFIRE] = MONSTERS_ROOM_WEIGHT + CAMPFIRE_ROOM_WEIGHT
	random_room_type_weights[Room.Type.SHOP] = MONSTERS_ROOM_WEIGHT + CAMPFIRE_ROOM_WEIGHT + SHOP_ROOM_WEIGHT
	
	random_room_type_total_weight = random_room_type_weights[Room.Type.SHOP]
	
func _setup_random_types():
	for room in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			
	var treasure_floor := floori(FLOORS * 0.6)
	if treasure_floor < FLOORS:
		for room in map_data[treasure_floor]:
			if room.next_rooms.size() > 0:
				room.type = Room.Type.TREASURE
			
	var campfire_floor = FLOORS - 2
	if FLOORS >= 7 and campfire_floor >= 0:
		for room in map_data[campfire_floor]:
			if room.next_rooms.size() > 0:
				room.type = Room.Type.CAMPFIRE
			
	for current_floor in map_data:
		for room in current_floor:
			for next_room in room.next_rooms:
				if next_room.type == Room.Type.NOT_ASSIGNED:
					_set_room_randomly(next_room)
			
	
func _set_room_randomly(room_to_set: Room) -> void:
	var campfire_below_4 := true
	var consecutive_campfire := true
	var consecutive_shop := true
	var campfire_on_13 := true
	
	var type_candidate: Room.Type
	
	while campfire_below_4 or consecutive_campfire or consecutive_shop or campfire_on_13:
		type_candidate = _get_random_room_type_by_weight()
		
		var is_campfire := type_candidate == Room.Type.CAMPFIRE
		var has_campfire_parent := _room_has_parent_of_type(room_to_set, Room.Type.CAMPFIRE)
		var is_shop := type_candidate == Room.Type.SHOP
		var has_shop_parent := _room_has_parent_of_type(room_to_set, Room.Type.SHOP)
		
		campfire_below_4 = is_campfire and room_to_set.row < 3
		consecutive_campfire = is_campfire and has_campfire_parent
		consecutive_shop = is_shop and has_shop_parent
		campfire_on_13 = is_campfire and room_to_set.row == 12
		
	room_to_set.type = type_candidate
		

func _room_has_parent_of_type(room: Room, type: Room.Type) -> bool:
	var parents: Array[Room] = []
	
	if room.column > 0 and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column -1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	if room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	if room.column < MAP_WIDTH - 1 and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column +1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
			
	for parent in parents:
		if parent.type == type:
			return true
			
	return false
	
func _get_random_room_type_by_weight() -> Room.Type:
	var roll := randf_range(0.0, random_room_type_total_weight)
	
	for type in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
			
	return Room.Type.MONSTER
	
