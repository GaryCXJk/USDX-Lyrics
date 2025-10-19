extends Node2D


func _on_button_pressed(scene: String) -> void:
	get_tree().change_scene_to_file("res://scenes/screens/" + scene + ".tscn")
