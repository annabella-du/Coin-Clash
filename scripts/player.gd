extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var flash_red_timer = $HurtBox/FlashRedTimer
@onready var progress_bar = $ProgressBar
@onready var coin_label = %CoinLabel
@onready var game_manager = %GameManager
@onready var death_timer = $DeathTimer
@onready var hurt_box = $HurtBox

@export var speed := 100.0
@export var health := 100
@export var sword : Resource
@export var sword_rotation_speed := 360.0

var direction := "down"
var active_move_animations := true
var attacking := false
var dead := false

var played_dead := false

func _ready():
	progress_bar.max_value = health

func _physics_process(_delta):
	if game_manager.lvl_up or game_manager.paused:
		animation_player.stop()
	elif dead or game_manager.game_over:
		pass
	else:
		# Movement
		var move = Input.get_vector("left", "right", "up", "down")
		velocity = move * speed
		move_and_slide()
		
		# Animation
		if active_move_animations:
			if velocity.length() == 0:
				animation_player.play("idle_" + direction)
			else:
				if velocity.x < 0: direction = "left"
				elif velocity.x > 0: direction = "right"
				elif velocity.y > 0: direction = "down"
				elif velocity.y < 0: direction = "up"
				animation_player.play("walk_" + direction)
		progress_bar.value = health

func _on_hurt_box_hurt(damage):
	health -= damage
	sprite.modulate = Color.CRIMSON
	flash_red_timer.start()
	if health <= 0:
		dead = true
		progress_bar.value = 0
		animation_player.play("die")
		death_timer.start()
		hurt_box.queue_free()

func _on_flash_red_timer_timeout():
	sprite.modulate = Color.WHITE

func create_sword(level : int):
	var new_sword = sword.instantiate()
	new_sword.visible = false
	match level:
		1: new_sword.starting_angle = 0
		2: new_sword.starting_angle = 180
		3: new_sword.starting_angle = 90
		4: new_sword.starting_angle = 270
		5: new_sword.starting_angle = 45
		6: new_sword.starting_angle = 225
		7: new_sword.starting_angle = 135
		8: new_sword.starting_angle = 315
	if level <= 8: add_child(new_sword)

func _on_death_timer_timeout():
	game_manager.game_over_lose()
