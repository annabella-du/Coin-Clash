extends Area2D

@onready var game_manager = get_tree().get_first_node_in_group("game_manager")

var speed : float
var starting_angle : float
var attacking := false

@onready var collision = $HitBox/CollisionShape2D

func _physics_process(delta):
	speed = game_manager.current_swing
	if attacking:
		if rotation_degrees >= starting_angle + 360:
			attacking = false
		rotation_degrees += speed * delta
	else:
		rotation_degrees = starting_angle
		if Input.is_action_just_pressed("attack"):
			attacking = true
	if attacking:
		visible = true
		collision.call_deferred("set", "disabled", false)
	else:
		visible = false
		collision.call_deferred("set", "disabled", true)
