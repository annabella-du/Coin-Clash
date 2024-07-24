extends Area2D

@onready var game_manager = get_tree().get_first_node_in_group("game_manager")

func _on_area_entered(area):
	if area.is_in_group("player"):
		queue_free()
