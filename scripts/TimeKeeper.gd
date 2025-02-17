extends Node

var day : int = 1
var time_remaining: float = 0
var day_length: float = 60.0

@onready var day_timer: Timer = Timer.new()

func _ready() -> void:
    SignalBus.game_over.connect(_on_game_over)

    add_child(day_timer)
    day_timer.wait_time = day_length
    day_timer.timeout.connect(_on_day_end)
    
func start_day():
    day_timer.start()

func _on_day_end() -> void:
    day += 1
    SignalBus.end_day.emit()

func _on_game_over() -> void:
    print("Game Over")
    get_tree().paused = true
