extends Label

@export var start_time: int = 10
var current_time: int

func _ready():
	current_time = start_time
	text = format_time(current_time)

	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	if current_time > 0:
		current_time -= 1
		text = format_time(current_time)

func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [minutes, secs]
