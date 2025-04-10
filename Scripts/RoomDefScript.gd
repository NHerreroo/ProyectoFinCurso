extends Node3D
class_name DefRoom

var player = null
var collilsions_seted = false
var coin = preload("res://Scenes/Dropps/Coin.tscn")
var heart = preload("res://Scenes/Dropps/Heart.tscn")
var shield = preload("res://Scenes/Dropps/Shield.tscn")

var topDoorSpecialRoom = preload("res://Scenes/Doors/TopDoorSpecialRoom.tscn")
var bottomDoorSpecialRoom = preload("res://Scenes/Doors/BottomDoorSpecialRoom.tscn")

var region

var isSpecialDoorInstanciates = false

var sides = ["top", "bot", "right", "left"]

func _ready() -> void:
	Global.eraseLevel = false
	var x = Global.playerMapPositionX
	var y = Global.playerMapPositionY

	var items = Global.get_items_in_room(x, y)

	print("Instanciando ítems de sala: %s,%s" % [x, y])
	print("Ítems:", items)

	for item in items:
		if not item.has("type") or not item.has("position"):
			continue

		var item_type = item["type"]
		var pos = item["position"]

		var instance = null
		match item_type:
			"Coin":
				instance = coin.instantiate()
			"Heart":
				instance = heart.instantiate()
			"Shield":
				instance = shield.instantiate()

		if instance:
			instance.position = pos
			instance.is_from_persistence = true  # ← ¡ESTO es clave!
			add_child(instance)


func _process(delta):
	if Global.specialRooms == true:
		Global.leftCollider = true
		Global.rightCollider = true
		if isSpecialDoorInstanciates == false:
			instanciateDoorsSpecialRoom()
			isSpecialDoorInstanciates = true
			setCollisions()

	if Global.enemies_remaining == 0:
		setCollisions()
	else:
		activateAllCollisions()

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
