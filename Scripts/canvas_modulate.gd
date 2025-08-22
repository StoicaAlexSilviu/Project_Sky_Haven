extends CanvasModulate

func _ready() -> void:
	SkyTint.tint_changed.connect(_apply_tint)
	_apply_tint(SkyTint.color) # initialize immediately

func _apply_tint(c: Color) -> void:
	color = c
