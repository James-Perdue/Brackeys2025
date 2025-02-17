extends Node2D

var init_val
var value
var high_warn
var high_fail
var low_warn
var low_fail

func set_params_creation(init, val, high_warn, high_fail, low_warn, low_fail):
	self.init_val = init
	self.value = val
	self.high_warn = high_warn
	self.high_fail = high_fail
	self.low_warn = low_warn
	self.low_fail = low_fail

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
