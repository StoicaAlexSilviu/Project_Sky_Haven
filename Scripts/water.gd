extends Node2D


func _process(_delta: float) -> void:
	if Global.water_vis:
		$ParallaxBackground2.visible = true
	else:
		$ParallaxBackground2.visible = false
