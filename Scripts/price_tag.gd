extends Label

@export var target : Button

func _process(_delta: float) -> void:
	if target.has_focus():
		self.visible = true
	else:
		self.visible = false
