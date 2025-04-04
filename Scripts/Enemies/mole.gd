extends Enemy

var bullet = preload("res://Scenes/Enemies/Misc/EnemyBullet.tscn")
var randX
var randZ

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	Global.enemies_remaining += 1
	await get_tree().create_timer(1).timeout
	logic()


func logic():
	while true:
		entry()
		await get_tree().create_timer(2).timeout
		attack()
		await get_tree().create_timer(4).timeout
		exit()
		await get_tree().create_timer(2).timeout

func entry():
	$MeshInstance3D/Area3D/CollisionShape3D.disabled = true
	self.position.x = randf_range(-4,4)
	self.position.z = randf_range(-8,8)
	$AnimationPlayer.play("entry")
	
func attack():
	$MeshInstance3D/Area3D/CollisionShape3D.disabled = false
	$AnimationPlayer.play("idle")
	await get_tree().create_timer(2).timeout
	shoot_in_four_directions()

func exit():
	$MeshInstance3D/Area3D/CollisionShape3D.disabled = true
	$AnimationPlayer.play("exit")
	
func shoot_in_four_directions():
	var directions = [
		Vector3(0, 0, -1),  # Adelante
		Vector3(0, 0, 1),   # Atrás 
		Vector3(-1, 0, 0),  # Izquierda 
		Vector3(1, 0, 0)    # Derecha 
	]
	
	for direction in directions:
		var bullet_instance = bullet.instantiate()
		bullet_instance.global_transform.origin = self.global_transform.origin
		bullet_instance.scale = Vector3(0.6, 0.6, 0.6)  # Ajusta según el tamaño correcto
		bullet_instance.direction = direction
		get_tree().root.add_child(bullet_instance)
