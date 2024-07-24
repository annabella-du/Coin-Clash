extends Node2D

@onready var mute_label = %MuteLabel
@onready var global = get_node("/root/Global")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy_spawner = %EnemySpawner
@onready var canvas_layer = %CanvasLayer
@onready var game_over_layer = %GameOverLayer
@onready var game_over_label = %GameOverLabel

@onready var music_1 : AudioStreamPlayer = %Music1
@onready var music_2 : AudioStreamPlayer = %Music2
@onready var music_3 : AudioStreamPlayer = %Music3
@onready var music_4 : AudioStreamPlayer = %Music4
@export var switch_1 := 10
@export var switch_2 := 20

@onready var lvl_up_layer = %LevelUpLayer
var lvl_up := false

@onready var pause_layer = %PauseLayer
var paused = false

@onready var sword_sprite = %SwordLvlUp
@onready var sword_cost = %SwordCost

@onready var speed_sprite = %SpeedLvlUp
@onready var speed_cost = %SpeedCost

@onready var knockback_sprite = %KnockbackLvlUp
@onready var knockback_cost = %KnockbackCost

@onready var swing_sprite = %SwingLvlUp
@onready var swing_cost = %SwingCost

@onready var coin_label = %CoinLabel

@onready var countdown_label = %CountdownLabel
@onready var countdown_timer = %CountdownTimer
@export var countdown_amount := 5 
var countdown : int
var countdown_active := false

var sword_level := 1

var speed_level := 1
var initial_speed := 70.0
var speed_increment := 15.0

var knockback_level := 1
var initial_knockback := 50.0
var knockback_increment := 40.0
var current_knockback : int

var swing_level := 1
var initial_swing := 360.0
var swing_increment := 70.0
var current_swing : int

var coins = 0
var costs = {2: 5, 3: 10, 4: 20, 5: 35, 6: 55, 7: 80, 8: 110, 9: "N/A"}  

var potions = 0
var potions_purchased = 0
@onready var potion_cost = %PotionCost
@onready var potion_label = %PotionLabel

var been_paused = false

@export var final_wave : int

var game_over = false

func _on_potion_button_button_up():
	var cost
	if potions_purchased < 4:
		cost = (potions_purchased + 1) * 10
	else:
		cost = 50
	if coins >= cost:
		potions += 1
		potions_purchased += 1
		coins -= cost
		if potions_purchased < 4:
			potion_cost.text = "%02d" % [(potions_purchased + 1) * 10]
		else:
			potion_cost.text = "50"

func _ready():
	player.create_sword(sword_level)
	player.speed = int(initial_speed)
	current_knockback = int(initial_knockback)
	current_swing = int(initial_swing)
	
	switch_music(1)
	
	lvl_up_layer.visible = false
	countdown_label.visible = false
	canvas_layer.visible = true
	pause_layer.visible = false
	game_over_layer.visible = false
	
	sword_cost.text = "%03d" % [costs[sword_level + 1]]
	speed_cost.text = "%03d" % [costs[speed_level + 1]]
	knockback_cost.text = "%03d" % [costs[knockback_level + 1]]
	swing_cost.text = "%03d" % [costs[swing_level + 1]]

func _physics_process(_delta):
	potion_label.text = "%02d" % [potions]
	
	if Input.is_action_just_pressed("consume_potion"):
		if potions > 0:
			potions -= 1
			player.health = clamp(player.health + 20, 0, 100)
	
	if countdown_active:
		if paused:
			countdown_timer.stop()
			been_paused = true
		elif !paused and been_paused:
			countdown_timer.start()
			been_paused = false
	
	if !global.muted:
		mute_label.text = "Mute"
	else:
		mute_label.text = "Unmute"
	
	if lvl_up:
		if Input.is_action_just_pressed("continue") and !paused:
			done_lvl_up()
	
	coin_label.text = "%03d" % [coins]
	
	if Input.is_action_just_pressed("pause"):
		if !paused:
			pause()
		else:
			resume()

func game_over_lose():
	game_over_layer.visible = true
	game_over_label.text = "Game Over"
	switch_music(4)

func game_over_win():
	game_over_layer.visible = true
	game_over_label.text = "You Win!"
	switch_music(4)

func pause():
	paused = true
	pause_layer.visible = true
	canvas_layer.visible = false
	if lvl_up:
		lvl_up_layer.visible = false

func resume():
	paused = false
	pause_layer.visible = false
	canvas_layer.visible = true
	if lvl_up:
		lvl_up_layer.visible = true

func wave_countdown():
	countdown = countdown_amount
	countdown_label.visible = true
	countdown_label.text = "Next wave in " + str(countdown) + "..."
	countdown_timer.start()

func choose_lvl_up():
	lvl_up_layer.visible = true
	lvl_up = true

func done_lvl_up():
	lvl_up = false
	lvl_up_layer.visible = false
	enemy_spawner.new_wave()

func inc_sword():
	if sword_level < 8:
		var cost = costs[sword_level + 1]
		if coins >= cost:
			coins -= cost
			sword_level += 1
			sword_sprite.frame += 1
			if sword_level == 8:
				sword_cost.text = "N/A"
			else:
				sword_cost.text = "%03d" % [costs[sword_level + 1]]
			player.create_sword(sword_level)

func inc_speed():
	if speed_level < 8:
		var cost = costs[speed_level + 1]
		if coins >= cost:
			coins -= cost
			speed_level += 1
			speed_sprite.frame += 1
			if speed_level == 8:
				speed_cost.text = "N/A"
			else:
				speed_cost.text = "%03d" % [costs[speed_level + 1]]
			player.speed = initial_speed + ((speed_level - 1) * speed_increment)

func inc_knockback():
	if knockback_level < 8:
		var cost = costs[knockback_level + 1]
		if coins >= cost:
			coins -= cost
			knockback_level += 1
			knockback_sprite.frame += 1
			if knockback_level == 8:
				knockback_cost.text = "N/A"
			else:
				knockback_cost.text = "%03d" % [costs[knockback_level + 1]]
			current_knockback = int(initial_knockback + ((knockback_level - 1) * knockback_increment))

func inc_swing():
	if swing_level < 8:
		var cost = costs[swing_level + 1]
		if coins >= cost:
			coins -= cost
			swing_level += 1
			swing_sprite.frame += 1
			if swing_level == 8:
				swing_cost.text = "N/A"
			else:
				swing_cost.text = "%03d" % [costs[swing_level + 1]]
			current_swing = int(initial_swing + ((swing_level - 1) * swing_increment))

func _on_sword_button_button_up():
	inc_sword()

func _on_speed_button_button_up():
	inc_speed()

func _on_knockback_button_button_up():
	inc_knockback()

func _on_swing_button_button_up():
	inc_swing()

func _on_countdown_timer_timeout():
	countdown -= 1
	countdown_label.text = "Next wave in " + str(countdown) + "..."
	if countdown == 0:
		countdown_active = false
		choose_lvl_up()
		countdown_label.visible = false
	else:
		countdown_timer.start()

func _on_resume_button_button_up():
	resume()

func _on_restart_button_button_up():
	get_tree().reload_current_scene()

func _on_quit_button_button_up():
	get_tree().change_scene_to_file("res://main_scenes/main_menu.tscn")

func _on_mute_button_button_up():
	if !global.muted:
		AudioServer.set_bus_mute(0, true)
		global.muted = true
	else:
		AudioServer.set_bus_mute(0, false)
		global.muted = false

func _on_go_restart_button_button_up():
	get_tree().reload_current_scene()

func _on_go_main_menu_button_up():
	get_tree().change_scene_to_file("res://main_scenes/main_menu.tscn")

func switch_music(num : int):
	match num:
		1:
			music_1.play()
			music_2.stop()
			music_3.stop()
			music_4.stop()
		2:
			music_1.stop()
			music_2.play()
			music_3.stop()
			music_4.stop()
		3:
			music_1.stop()
			music_2.stop()
			music_3.play()
			music_4.stop()
		4:
			music_1.stop()
			music_2.stop()
			music_3.stop()
			music_4.play()
