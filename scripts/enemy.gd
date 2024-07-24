extends CharacterBody2D

@onready var game_manager = get_tree().get_first_node_in_group("game_manager")
@onready var animation_player = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("player")
@onready var flash_red_timer = $HurtBox/FlashRedTimer
@onready var sprite = $Sprite2D
@onready var hitbox = $HitBox/CollisionShape2D
@onready var hurtbox = $HurtBox/CollisionShape2D
@onready var collision = $CollisionShape2D
@onready var progress_bar = $ProgressBar
@onready var knockback_timer = $KnockbackTimer
@onready var enemy_spawner = get_parent()

@export var speed := 60.0
@export var health := 3
@export var knockback_time := 0.1

@export_category("Coins")
@export var coin_yellow : Resource
@export var coin_orange : Resource
@export var coin_red : Resource
@export var yellow_prob : float 
@export var orange_prob : float 
@export var red_prob : float 
@onready var rarities = {0 : int(yellow_prob * 100), 1: int(orange_prob * 100), 2: int(red_prob * 100)}

var direction := "down"
var alive = true
var can_delete = false
var coin_picked_up = false
var move
var knockback = false
var rng = RandomNumberGenerator.new()
var coin_index : int

func _ready():
	progress_bar.max_value = health

func _physics_process(_delta):
	if (game_manager.lvl_up or game_manager.paused or player.dead or game_manager.game_over) and alive:
		animation_player.stop()
	else:
		if alive:
			move = global_position.direction_to(player.global_position)
			if knockback:
				velocity = -move * game_manager.current_knockback
				animation_player.stop()
			else:
				velocity = move * speed
				if velocity.x < 0: direction = "left"
				elif velocity.x > 0: direction = "right"
				elif velocity.y > 0: direction = "down"
				elif velocity.y < 0: direction = "up"
			animation_player.play("walk_" + direction)
			move_and_slide()
			progress_bar.value = health
		if can_delete and coin_picked_up:
			queue_free()

func _on_hurt_box_hurt(damage):
	health -= damage
	knockback = true
	knockback_timer.start()
	sprite.modulate = Color.CRIMSON
	flash_red_timer.start()
	if health == 0:
		die()

func die():
	alive = false
	animation_player.play("die")
	enemy_spawner.enemy_died()
	coin_index = rand_coin()
	var select_coin : Resource
	match coin_index:
		0: select_coin = coin_yellow
		1: select_coin = coin_orange
		2: select_coin = coin_red
	var new_coin = select_coin.instantiate()
	call_deferred("add_child", new_coin)
	sprite.modulate = Color.WHITE
	hitbox.queue_free()
	hurtbox.queue_free()
	progress_bar.queue_free()
	collision.queue_free()



func rand_coin():
	rng.randomize()
	var weighted_sum = 0
	for i in rarities:
		weighted_sum += rarities[i]
	var item = rng.randi_range(0, weighted_sum)
	for i in rarities:
		if item <= rarities[i]:
			return i
		item -= rarities[i]

func _on_flash_red_timer_timeout():
	sprite.modulate = Color.WHITE

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "die":
		can_delete = true

func _on_child_exiting_tree(node):
	if node.is_in_group("coin"):
		match coin_index:
			0: game_manager.coins += 1
			1: game_manager.coins += 3
			2: game_manager.coins += 5
		coin_picked_up = true

func _on_knockback_timer_timeout():
	knockback = false
