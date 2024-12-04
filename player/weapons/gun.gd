extends Node2D
@export var energy_bullet: PackedScene
@onready var player = get_parent()
@onready var spawner = $Marker2D
@onready var reload = $reload

func _ready():
	reload.wait_time = 1/wm.fire_rate

func _physics_process(delta) -> void:
	
	var direction = global_position.direction_to(get_global_mouse_position())
	self.global_rotation = lerp_angle(global_rotation, direction.angle(), 0.2)

func shoot(delta):
	if reload.is_stopped():
		var projectile = energy_bullet.instantiate()
		var main = get_parent().get_parent()
		main.add_child(projectile)
		projectile.global_position = spawner.global_position
		projectile.global_rotation = global_rotation
		projectile.velo = (Vector2.RIGHT.rotated(global_rotation)*wm.bullet_speed + player.linear_velocity) * delta
		reload.start()
	else:
		pass

