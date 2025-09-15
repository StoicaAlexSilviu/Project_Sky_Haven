extends Control

@export var slot_number = 0


func _process(_delta: float) -> void:
	if Global.fish_catch == slot_number:
		$FishSlotCatch.visible = true
	if Global.fish_catch < slot_number:
		$FishSlotCatch.visible = false
