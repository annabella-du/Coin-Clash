extends Node2D

func _physics_process(_delta):
	if Input.is_action_just_pressed("continue"):
		get_tree().change_scene_to_file("res://main_scenes/main_menu.tscn")
