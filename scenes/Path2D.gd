extends Path2D

@onready var player = get_tree().get_first_node_in_group("player")

func _process(delta):
	self.global_position = player.global_position
