extends Camera2D

@export var top_left_corner : Node2D # Negative
@export var bottom_right_corner : Node2D # Positive

func _ready():
	limit_left = int(top_left_corner.global_position.x) - 48
	limit_right = int(bottom_right_corner.global_position.x) + 48
	limit_top = int(top_left_corner.global_position.y) - 64
	limit_bottom = int(bottom_right_corner.global_position.y) + 64
