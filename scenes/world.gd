extends Node2D

@export var commonEnemy: PackedScene
@export var MaxEnemyCount: int = 4
var CurrentEnemyCount: int = 0
@onready var spawnPath = $Path2D/PathFollow2D
@onready var spawnPoint = $Path2D/PathFollow2D/Marker2D

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_spawn_timer_timeout():
	if CurrentEnemyCount >= MaxEnemyCount:
		return
	else:
		var basicEnemy = commonEnemy.instantiate()
		spawnPath.progress_ratio = randf_range(0.0,1.0)
		basicEnemy.global_position = spawnPoint.global_position
		add_child(basicEnemy)

func _on_child_entered_tree(node):
	if node.is_in_group("enemy"):
		CurrentEnemyCount += 1


func _on_child_exiting_tree(node):
	if node.is_in_group("enemy"):
		CurrentEnemyCount -= 1
