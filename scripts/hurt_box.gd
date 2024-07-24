extends Area2D

@onready var collision = $CollisionShape2D
@onready var disable_timer = $DisableTimer

signal hurt(damage, angle)

func _on_area_entered(area):
	if area.is_in_group("hit_box"):
		var damage = area.damage
		collision.call_deferred("set", "disabled", true)
		disable_timer.start()
		emit_signal("hurt", damage)

func _on_disable_timer_timeout():
	if collision != null:
		collision.call_deferred("set", "disabled", false)	

