extends CharacterBody2D
@onready var despawnTimer: Timer = $despawnTimer
var velo = Vector2.ZERO

func _physics_process(delta):
	move_and_collide(velo)

func _on_visible_on_screen_notifier_2d_screen_exited():
	call_deferred("free")


func _on_area_2d_body_entered(body):
	call_deferred("free")


func _on_area_2d_area_entered(area):
	call_deferred("free")
