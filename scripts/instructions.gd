extends Node2D

@onready var layer_0 = %Layer0
@onready var layer_1 = %Layer1
@onready var layer_2 = %Layer2
@onready var layer_3 = %Layer3
@onready var layer_4 = %Layer4
@onready var layer_5 = %Layer5
@onready var layer_6 = %Layer6

var layer := 1

func _ready():
	layer_0.visible = true
	layer_1.visible = true
	layer_2.visible = false
	layer_3.visible = false
	layer_4.visible = false
	layer_5.visible = false
	layer_6.visible = false

func _physics_process(_delta):
	if Input.is_action_just_pressed("continue"):
		match layer:
			1:
				layer_1.visible = false
				layer_2.visible = true
				layer += 1
			2:
				layer_2.visible = false
				layer_3.visible = true
				layer += 1
			3:
				layer_3.visible = false
				layer_4.visible = true
				layer += 1
			4:
				layer_4.visible = false
				layer_5.visible = true
				layer += 1
			5:
				layer_5.visible = false
				layer_6.visible = true
				layer += 1
			6:
				get_tree().change_scene_to_file("res://main_scenes/main_menu.tscn")
