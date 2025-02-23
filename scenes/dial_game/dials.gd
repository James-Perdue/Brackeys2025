extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $steam_pressure.set_params_creation(5, 75, 101, 101, 30, 10)
    $temperature.set_params_creation(40, 43, 50, 60, 37, 30)
    $radiativity.set_params_creation(80, 80, 85, 95, 30, 15)
    
    $steam_pressure.set_trends(-20, 0.1, -1)
    $radiativity.set_trends(75, 0.05, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
