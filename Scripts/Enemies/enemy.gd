extends CharacterBody3D

@onready var area: Area3D = $MeshInstance3D/Area3D  # Referencia al Area3D dentro del CharacterBody3D
@onready var nav: NavigationAgent3D = $NavigationAgent3D

var player

var speed = 3.0  # Velocidad de movimiento del enemigo
var accel = 10

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("attack"):
		queue_free()

func _physics_process(delta: float):
	player = get_tree().get_root().find_child("player", true, false)

	if player:
		nav.target_position = player.global_transform.origin
		
		var direction = nav.get_next_path_position() - global_transform.origin
		direction = direction.normalized()
		
		velocity = velocity.lerp(direction * speed, accel * delta)
		
		move_and_slide()