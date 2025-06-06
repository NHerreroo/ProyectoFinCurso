extends Node2D
class_name Map

const SCROLL_SPEED := 35
const SCROLL_SMOOTHNESS: float = 0.1
const  MAP_ROOM = preload("res://Scenes/Map/map_room.tscn")
const  MAP_LINE = preload("res://Scenes/Map/map_line.tscn")

@onready var map_generator: MapGenerator = $MapGenerator
@onready var lines: Node2D = %Lines
@onready var rooms: Node2D = %Rooms
@onready var visuals: Node2D = $Visuals
@onready var camera_2d: Camera2D = $Camera2D
@onready var music: AudioStreamPlayer = $AudioStreamPlayer

var map_data: Array[Array]
var floors_climbed: int
var last_room: Room
var camera_edge_y: float

signal map_exited(room: Room)

func _ready() -> void:
	camera_edge_y = Global.Y_DIST * (Global.FLOORS - 1)
	music.volume_db = -40
	music.play()
	_fade_in_music()

func _process(delta: float) -> void:
	if Global.runEnded == true:
		camera_2d.enabled = false
		queue_free()
	if camera_2d.enabled == false:
		$AudioStreamPlayer.volume_db = -80
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		camera_2d.position.y -= SCROLL_SPEED
	elif event.is_action_pressed("scroll_down"):
		camera_2d.position.y += SCROLL_SPEED
	
	camera_2d.position.y = clamp(camera_2d.position.y, -camera_edge_y, 0)

func generate_new_map() -> void:
	floors_climbed = 0
	map_data = map_generator.generate_map()
	create_map()

func create_map() -> void:
	for current_floor in map_data:
		for room in current_floor:
			if room.next_rooms.size() > 0:
				_spawn_room(room)

	var middle := floori(Global.MAP_WIDTH * 0.5)
	_spawn_room(map_data[Global.FLOORS-1][middle])

	var map_width_pixels = Global.X_DIST * (Global.MAP_WIDTH - 1)
	visuals.position.x = (get_viewport_rect().size.x - map_width_pixels) / 2
	visuals.position.y = get_viewport_rect().size.y / 5

func unlock_floor(which_floor: int = floors_climbed) -> void:
	for map_room in rooms.get_children():
		if map_room.room.row == which_floor:
			map_room.available = true

func unlock_next_room() -> void:
	for map_room in rooms.get_children():
		if last_room.next_rooms.has(map_room.room):
			map_room.available = true

func show_map() -> void:
	_fade_out_music()
	self.show()
	$MapBackground.show()
	camera_2d.enabled = true

func hide_map() -> void:
	_fade_in_music()
	self.hide()
	$MapBackground.hide()
	camera_2d.enabled = false

func _spawn_room(room: Room) -> void:
	var new_map_room := MAP_ROOM.instantiate() as MapRoom
	rooms.add_child(new_map_room)
	new_map_room.room = room
	new_map_room.selected.connect(_on_map_room_selected)
	_connect_lines(room)

	if room.selected and room.row < floors_climbed:
		new_map_room.show_selected()

func _connect_lines(room: Room) -> void:
	if room.next_rooms.is_empty():
		return

	for next in room.next_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(room.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)

func _on_map_room_selected(room: Room) -> void:
	for map_room in rooms.get_children():
		if map_room.room.row == room.row:
			map_room.available = false

	last_room = room
	floors_climbed += 1
	Global.lvlCount += 1
	await _fade_out_music()
	emit_signal("map_exited", room)

func _fade_in_music():
	while music.volume_db < 0:
		music.volume_db += 5
		if get_tree():
			await get_tree().create_timer(0.01).timeout
		else:
			return

func _fade_out_music():
	while music.volume_db > -40:
		music.volume_db -= 5
		if get_tree():
			await get_tree().create_timer(0.01).timeout
		else:
			return

	
