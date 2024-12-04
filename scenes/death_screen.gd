extends Node2D


func _on_retry_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
