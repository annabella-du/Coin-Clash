extends Node2D

@onready var mute_label = %MuteLabel
@onready var global = get_node("/root/Global")

func _physics_process(_delta):
	if !global.muted:
		mute_label.text = "Mute"
	else:
		mute_label.text = "Unmute"

func _on_play_button_button_up():
	get_tree().change_scene_to_file("res://main_scenes/world.tscn")

func _on_instruction_button_button_up():
	get_tree().change_scene_to_file("res://main_scenes/instructions.tscn")

func _on_mute_button_button_up():
	if !global.muted:
		AudioServer.set_bus_mute(0, true)
		global.muted = true
	else:
		AudioServer.set_bus_mute(0, false)
		global.muted = false

func _on_credits_button_button_up():
	get_tree().change_scene_to_file("res://main_scenes/credits.tscn")
