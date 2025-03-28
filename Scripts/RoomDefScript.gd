extends Node3D
class_name DefRoom

var player = null
var collilsions_seted = false
var coin = preload("res://Scenes/Dropps/Coin.tscn")
var heart = preload("res://Scenes/Dropps/Heart.tscn")
var shield = preload("res://Scenes/Dropps/Shield.tscn")

var topDoorSpecialRoom = preload("res://Scenes/Doors/TopDoorSpecialRoom.tscn")
var bottomDoorSpecialRoom = preload("res://Scenes/Doors/BottomDoorSpecialRoom.tscn")


var isSpecialDoorInstanciates = false

var sides = ["top", "bot", "right", "left"]

func _ready() -> void:
	Global.eraseLevel = false
	
	var current_room = [Global.playerMapPositionX, Global.playerMapPositionY]
	player = get_tree().get_root().find_child("player", true, false)
	# Recorremos el array de habitaciones y objetos
	for room_items in Global.persistent_items:
		var room_position = room_items[0]
		# Comprobamos si la posición coincide con la habitación actual
		if room_position == current_room:
			# Iterar sobre los elementos del array desde el segundo elemento
			for i in range(1, room_items.size()):
				var item = room_items[i]
				if item is Array and item.size() >= 4:
					var item_name = item[0]
					var pos_x = item[1]
					var pos_y = item[2]
					var pos_z = item[3]
					if item_name == "Coin":
						var coin_instance = coin.instantiate()
						coin_instance.position = Vector3(pos_x, pos_y, pos_z)
						add_child(coin_instance)  # Agregar la moneda como hijo del nodo actual
					if item_name == "Heart":
						var heart_instance = heart.instantiate()
						heart_instance.position = Vector3(pos_x, pos_y, pos_z)
						add_child(heart_instance)  # Agregar corazon como hijo del nodo actual
					if item_name == "Shield":
						var shield_instance = shield.instantiate()
						shield_instance.position = Vector3(pos_x, pos_y, pos_z)
						add_child(shield_instance)  # Agregar escudo como hijo del nodo actual
			break

func _process(delta):
	if Global.specialRooms == true:
		Global.leftCollider = true
		Global.rightCollider = true
		if isSpecialDoorInstanciates == false:
			instanciateDoorsSpecialRoom()
			isSpecialDoorInstanciates = true
			setCollisions()  # Asegurar que las colisiones se actualicen correctamente

				
	if Global.enemies_remaining == 0:
		setCollisions()
	else:
		activateAllCollisions()
		
	if Global.eraseLevel == true:
		queue_free()

func setCollisions():
	for side in sides:
		var collider = $BoundsColliders/StaticBody3D.get_node(side + "btwn")
		collider.disabled = not Global.get(side + "Collider")
	collilsions_seted = true

func activateAllCollisions():
	for side in sides:
		var collider = $BoundsColliders/StaticBody3D.get_node(side + "btwn")
		collider.disabled = false
	collilsions_seted = false

func instanciateDoorsSpecialRoom():
	var bottomDoorInst = bottomDoorSpecialRoom.instantiate()
	bottomDoorInst.position = Vector3(5, 0, 0)
	add_child(bottomDoorInst)
	
	var topDoorInst = topDoorSpecialRoom.instantiate()
	topDoorInst.position = Vector3(-5, 0, 0)
	add_child(topDoorInst)
