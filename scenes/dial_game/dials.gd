extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$steam_pressure.set_params_creation(5, 75, 101, 101, 20, 10)
	$temperature.set_params_creation(40, 40, 50, 60, 40, 30)
	$radiativity.set_params_creation(80, 80, 90, 95, 30, 15)
	
	$steam_pressure.set_trends(-20, 0.1, -1)
	$radiativity.set_trends(75, 0.05, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
