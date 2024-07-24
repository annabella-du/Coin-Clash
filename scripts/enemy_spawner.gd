extends Node2D

@export var spawns : Array[Spawn_Info] = []

@onready var player = get_tree().get_first_node_in_group("player")
@onready var game_manager = %GameManager

@onready var top_left_corner = %TopLeft # Negative
@onready var bottom_right_corner = %BottomRight # Positive

@onready var timer = $Timer
@onready var progress_bar = %ProgressBar
@onready var wave_label = %WaveLabel

var current_wave := 0
var time := 0
var killed_enemies := 0
var num_of_enemies_in_wave := 0
var spawns_in_current_wave : Array[Spawn_Info] = []
var spawning = false
var been_paused = false

func _ready():
	progress_bar.value = 0
	new_wave()

func _physics_process(_delta):
	if spawning:
		if game_manager.paused:
			timer.stop()
			been_paused = true
		elif !game_manager.paused and been_paused:
			timer.start()
			been_paused = false
	if game_manager.game_over or player.dead:
		timer.stop()


func _on_timer_timeout():
	time += 1 # increase time counter
	for i in spawns_in_current_wave: # for each enemy that spawns in the current wave
		if i.delay_counter == i.delay_between_spawn: # if the delay counter is equal to the delay between spawns
			i.delay_counter = 0 # reset delay counter
			for j in range(i.enemies_per_group): # for every enemy in a group
				var enemy_spawn = i.enemy.instantiate() # instantiate enemy
				enemy_spawn.global_position = get_random_position() # set enemy's position to a random position
				enemy_spawn.speed = i.speed
				enemy_spawn.health = i.health
				add_child(enemy_spawn) # add the enemy as a child of the enemy spawner
			i.num_groups_spawned += 1 # increase the number of groups spawned
			if i.num_groups_spawned == i.num_of_enemy_groups: # if all the groups have been spawned
				spawns_in_current_wave.erase(i) # remove the spawn info from the current array
		else: # if the counter is less than the delay between spawns
			i.delay_counter += 1 # increase delay counter by 1
	if spawns_in_current_wave.size() == 0: # if there are no more spawns in the current wave
		spawning = false
		timer.stop() # stop timer

func new_wave():
	current_wave += 1 # start next wave
	if current_wave == 11:
		game_manager.switch_music(2)
	elif current_wave == 21:
		game_manager.switch_music(3)
	wave_label.text = "WAVE " + str(current_wave)
	time = 0 # reset time counter
	killed_enemies = 0
	num_of_enemies_in_wave = 0 # reset number of enemies in current wave
	for i in spawns: # for each spawn
		if i.wave == current_wave: # if the spawn's wave is the current wave
			spawns_in_current_wave.append(i) # add spawn into array
			# add the number of enemies in the spawn to the total num of enemies in current wave
			num_of_enemies_in_wave += i.num_of_enemy_groups * i.enemies_per_group 
	progress_bar.max_value = num_of_enemies_in_wave
	progress_bar.value = 0
	spawning = true
	timer.start() # start timer

func enemy_died(): # called by each child enemy when it dies
	killed_enemies += 1
	progress_bar.value = killed_enemies
	if killed_enemies == num_of_enemies_in_wave: # if all enemies in current wave are killed
		if current_wave == game_manager.final_wave:
			game_manager.game_over = true
			game_manager.game_over_win()
		else:
			game_manager.wave_countdown()
			game_manager.countdown_active = true

func get_random_position():
	var attempt = attempt_get_random_position()
	if attempt.x < top_left_corner.global_position.x or attempt.x > bottom_right_corner.global_position.x or attempt.y < top_left_corner.global_position.y or attempt.y > bottom_right_corner.global_position.y:
		attempt = get_random_position()
	return attempt

func attempt_get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1, 1.4)
	var top_left = Vector2(player.global_position.x - (vpr.x / 2), player.global_position.y - (vpr.y / 2))
	var top_right = Vector2(player.global_position.x + (vpr.x / 2), player.global_position.y - (vpr.y / 2))
	var bottom_left = Vector2(player.global_position.x - (vpr.x / 2), player.global_position.y + (vpr.y / 2))
	var bottom_right = Vector2(player.global_position.x + (vpr.x / 2), player.global_position.y + (vpr.y / 2))
	var pos_side = ["up", "down", "right", "left"].pick_random()
	var spawn_pos1 : Vector2
	var spawn_pos2: Vector2
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y,spawn_pos2.y)
	return Vector2(x_spawn,y_spawn)
