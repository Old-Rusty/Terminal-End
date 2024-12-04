extends CharacterBody2D

@onready var target = get_tree().get_first_node_in_group("player")

func _ready():
	pass

func _physics_process(delta):
	var direction = global_position.direction_to(target.global_position)
	velocity = direction * enep.speed1
	move_and_slide()
	
	rotation = lerp_angle(rotation, direction.angle(), 0.2)

func _on_hurt_box_area_entered(area):
	call_deferred("free")

