extends Control

func _ready() -> void:
	pass
	$VBoxContainer/Hull_02.grab_focus()


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level_01_TEST/Level_01_TEST.tscn")


func _on_hull_02_pressed() -> void:
	if Global.coins >= $VBoxContainer/Hull_02.price:
		Global.coins -= $VBoxContainer/Hull_02.price
		Global.hull_01 = false
		Global.hull_02 = true
		Global.hull_03 = false
		Global.hull_04 = false
		$VBoxContainer/Hull_02.disabled = true
		$VBoxContainer/Hull_02.price = 900000000000
		Global.fish_value = 2


func _on_hull_03_pressed() -> void:
	if Global.coins >= $VBoxContainer/Hull_03.price:
		Global.coins -= $VBoxContainer/Hull_03.price
		Global.hull_01 = false
		Global.hull_02 = false
		Global.hull_03 = true
		Global.hull_04 = false
		$VBoxContainer/Hull_03.disabled = true
		$VBoxContainer/Hull_03.price = 900000000000
		Global.fish_value = 3

func _on_hull_04_pressed() -> void:
	if Global.coins >= $VBoxContainer/Hull_04.price:
		Global.coins -= $VBoxContainer/Hull_04.price
		Global.hull_01 = false
		Global.hull_02 = false
		Global.hull_03 = false
		Global.hull_04 = true
		$VBoxContainer/Hull_04.disabled = true
		$VBoxContainer/Hull_04.price = 900000000000
		Global.fish_value = 5
