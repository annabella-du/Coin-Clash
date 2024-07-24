extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("player")
@onready var flash_red_timer = $HurtBox/FlashRedTimer
@onready var sprite = $Sprite2D
@onready var hitbox = $HitBox/CollisionShape2D
@onready var hurtbox = $HurtBox/CollisionShape2D
@onready var collision = $CollisionShape2D
@onready var progress_bar = $ProgressBar

@export var speed := 60.0
@export var health := 3
@export var coin : Resource

var direction := "down"
var alive = true
var can_delete = false
var coin_picked_up = false

func _ready():
	progress_bar.max_value = health

func _physics_process(_delta):
	if alive:
		var move = global_position.direction_to(player.global_position)
		velocity = move * speed
		move_and_slide()
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		elif velocity.y > 0: direction = "down"
		elif velocity.y < 0: direction = "up"
		animation_player.play("walk_" + direction)
		progress_bar.value = health
	if can_delete and coin_picked_up:
		print("deleted")
		queue_free()

func _on_hurt_box_hurt(damage):
	health -= damage
	sprite.modulate = Color.CRIMSON
	flash_red_timer.start()
	if health == 0:
		alive = false
		var new_coin = coin.instantiate()
		call_deferred("add_child", new_coin)
		sprite.modulate = Color.WHITE
		hitbox.queue_free()
		hurtbox.queue_free()
		progress_bar.queue_free()
		collision.queue_free()
		animation_player.play("die")

func _on_flash_red_timer_timeout():
	sprite.modulate = Color.WHITE

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "die":
		can_delete = true

func _on_child_exiting_tree(node):
	if node.is_in_group("coin"):
		coin_picked_up = true
