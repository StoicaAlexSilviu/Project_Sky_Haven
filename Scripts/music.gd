extends Node2D

@export var player: AudioStreamPlayer
@export var track_number_max: int = 1

@onready var rng = RandomNumberGenerator.new()
var track_random_number: int = 0


func _ready() -> void:
	rng.randomize()
	_play_random_track()


func _play_random_track() -> void:
	track_random_number = rng.randi_range(1, track_number_max)
	var path = "res://Assets/Music/track_%02d.mp3" % track_random_number
	var stream = load(path)
	
	if stream:
		player.stream = stream
		player.play()


func _on_audio_stream_player_finished() -> void:
	_play_random_track()
