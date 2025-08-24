extends Node2D

@export var fade_start: float = 18.0   # stars start fading in at 18:00
@export var fade_end: float   = 6.0    # fade out by 06:00
@export var max_alpha: float  = 0.8
@export var shader_uniform_name: String = "fade"  # must match the shader

@onready var shader_mat: ShaderMaterial = material as ShaderMaterial

func _process(_delta: float) -> void:
	var h: float = float(Clock.hour) + float(Clock.minute) / 60.0

	var alpha: float = 0.0
	if h >= fade_start:
		# evening: fade in between fade_start and 24
		var t: float = (h - fade_start) / (24.0 - fade_start)
		alpha = lerp(0.0, max_alpha, clamp(t, 0.0, 1.0))
	elif h <= fade_end:
		# early morning: fade out between 0 and fade_end
		var t2: float = 1.0 - (h / fade_end)
		alpha = lerp(0.0, max_alpha, clamp(t2, 0.0, 1.0))
	else:
		alpha = 0.0  # daytime = invisible

	var a: float = clamp(alpha, 0.0, max_alpha)

	if shader_mat != null:
		# Drive the shader uniform so fade works even with ShaderMaterial
		shader_mat.set_shader_parameter(shader_uniform_name, a)
	else:
		# Fallback: no shader, use modulate
		modulate.a = a
