extends Node

var day : int = 1
var game_over_screen = preload("res://scenes/game_over.tscn")
var day_end_screen = preload("res://scenes/day_end.tscn")
var victory_screen = preload("res://scenes/victory.tscn")

var main_menu = preload("res://scenes/main_menu.tscn")

var day_lengths : Array[float] = [30, 40, 45, 50, 60, 60, 60]
var day_levels  = [
    preload("res://scenes/Day1.tscn"),
     preload("res://scenes/Day2.tscn"),
      preload("res://scenes/Day3.tscn"),
       preload("res://scenes/Day4.tscn"),
       preload("res://scenes/Day5.tscn"),
       preload("res://scenes/Day6.tscn"),
       preload("res://scenes/Day7.tscn")
       ]

@onready var day_timer: Timer = Timer.new()

func _ready() -> void:
    SignalBus.game_over.connect(_on_game_over)
    SignalBus.end_day.connect(_on_day_end)
    SignalBus.reset.connect(_on_reset)
    SignalBus.next_day.connect(_on_next_day)
    SignalBus.restart_game.connect(_on_restart_game)

    add_child(day_timer)
    day_timer.timeout.connect(_on_day_end_timer)
    
func start_day():
    if(day <= day_lengths.size()):
        day_timer.wait_time = day_lengths[day-1]
    day_timer.start()

func _on_day_end_timer() -> void:
    SignalBus.end_day.emit()

func _on_day_end() -> void:
    print("Day Ended: ", day)
    day += 1
    
    if(day > 7):
        var screen = victory_screen.instantiate()
        get_tree().current_scene.add_child(screen)
        get_tree().paused = true
    else:
        var screen = day_end_screen.instantiate()
        get_tree().current_scene.add_child(screen)
        get_tree().paused = true

func _on_game_over(reason: String) -> void:
    print("Game Over")
    var screen = game_over_screen.instantiate()
    screen.set_reason(reason)
    get_tree().current_scene.add_child(screen)
    screen.start_loss()
    get_tree().paused = true

func _on_reset() -> void:
    get_tree().paused = false
    day_timer.start()
    get_tree().reload_current_scene()

func _on_next_day() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()
    
func load_next_day() -> void:
    print("Loading Day: ", day)
    if(day <= day_levels.size()):
        get_tree().change_scene_to_packed(day_levels[day-1])

func _on_restart_game() -> void:
    get_tree().paused = false
    day = 1
    MusicManager.restart_music()
    get_tree().change_scene_to_packed(main_menu)
