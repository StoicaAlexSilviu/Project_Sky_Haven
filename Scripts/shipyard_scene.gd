extends Control

func _ready() -> void:
	pass
	$VBoxContainer/Hull_02.grab_focus()


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level_01_TEST/Level_01_TEST.tscn")


func _on_hull_02_pressed() -> void:
	if Global.coins >= $VBoxContainer/Hull_02.price:
		Global.coins -= $VBoxContainer/Hull_02.price
		Global.hull_02 = true
		Global.hull_01 = false
