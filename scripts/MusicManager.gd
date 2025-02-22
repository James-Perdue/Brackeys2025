extends Node

var music_stream : AudioStream = load("res://audio/soundtrack.wav")
@onready var music: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready():
    music.stream = music_stream
    add_child(music)
    music.play()
    music.volume_db = -10.0

func _process(_delta: float) -> void:
    if(music.playing == false):
        music.play()

func restart_music() -> void:
    music.play()