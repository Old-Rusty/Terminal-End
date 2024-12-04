extends Trails
@onready var trail_pos = get_parent()

func _get_position():
	return trail_pos.global_position
