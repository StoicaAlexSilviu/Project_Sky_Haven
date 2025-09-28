extends Sprite2D


func _on_area_2d_area_entered(_area: Area2D) -> void:
	Global.indicator_in = true
	#print("entered ",Global.indicator_in)


func _on_area_2d_area_exited(_area: Area2D) -> void:
	Global.indicator_in = false
	#print("exited ",Global.indicator_in)
