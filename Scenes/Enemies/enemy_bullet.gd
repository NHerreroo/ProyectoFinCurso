extends Node3D


var direction = Vector3.ZERO
var speed = 10

func _process(delta):
	if direction != Vector3.ZERO:
		position += direction.normalized() * speed * delta

func _ready():
	await get_tree().create_timer(5).timeout
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("player"):
		queue_free()

	