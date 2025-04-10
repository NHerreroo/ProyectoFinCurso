extends Enemy

var bullet = preload("res://Scenes/Enemies/Misc/EnemyBullet.tscn")
var currentState

func _ready() -> void:
	$AnimationPlayer.play("idle")
	Global.enemies_remaining += 1
	selectState()
	
func selectState():
	currentState = get_random_state()
	match currentState:
		State.IDLE:
			idleState()
		State.WALK:
			walkState()
		State.ATTACK:
			attackState()

func walkState():
	$AnimationPlayer.play("idle")
	var posx = randf_range(-3.0, 3.0)
	var posz = randf_range(-7.0, 7.0)
	nav.target_position = global_transform.origin + Vector3(posx, 0, posz)
	
	await nav.navigation_finished
	selectState()

func idleState():
	$AnimationPlayer.play("idle")
	await get_tree().create_timer(randf_range(0.5,1.5)).timeout
	selectState()
	
func attackState():
	velocity = Vector3.ZERO
	$AnimationPlayer.play("prepare")
	await get_tree().create_timer(1.5).timeout
	
	var original_speed = speed
	speed *= 5
	$AnimationPlayer.play("attack")
	nav.target_position = player.global_transform.origin
	
	await nav.navigation_finished
	speed = original_speed
	selectState()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
