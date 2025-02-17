extends Node

var day : int = 1
var day_length: float = 10.0
var game_over_screen = preload("res://scenes/game_over.tscn")
@onready var day_timer: Timer = Timer.new()

func _ready() -> void:
    SignalBus.game_over.connect(_on_game_over)
    SignalBus.end_day.connect(_on_day_end)
    SignalBus.reset.connect(_on_reset)

    add_child(day_timer)
    day_timer.wait_time = day_length
    day_timer.timeout.connect(_on_day_end_timer)

func start_day():
    day_timer.start()

func _on_day_end_timer() -> void:
    SignalBus.end_day.emit()

func _on_day_end() -> void:
    print("Day Ended: ", day)
    day += 1

func _on_game_over() -> void:
    print("Game Over")
    var screen = game_over_screen.instantiate()
    screen.position = get_viewport().get_visible_rect().size / 2
    get_tree().current_scene.add_child(screen)
    get_tree().paused = true

func _on_reset() -> void:
    day = 1
    get_tree().paused = false
    day_timer.start()
    get_tree().reload_current_scene()
