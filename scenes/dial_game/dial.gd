extends Node2D

const MIN_ANGLE = -60
const MAX_ANGLE = 60
const ANGLE_RANGE = MAX_ANGLE - MIN_ANGLE

var init_val: float
var value: float
var high_warn
var high_fail
var low_warn
var low_fail
var trend_target = 50
var trend_rate_scalar = 0
var trend_rate_flat = 0
var values_ready = false

func set_params_creation(init: float, val: float, high_warn, high_fail, low_warn, low_fail):
	self.init_val = init
	self.value = val
	self.high_warn = high_warn
	self.high_fail = high_fail
	self.low_warn = low_warn
	self.low_fail = low_fail
	values_ready = true


func set_trends(target, rate, flaty):
	self.trend_target = target
	self.trend_rate_scalar = rate
	self.trend_rate_flat = flaty

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# FIXME: I think there's some float issues around here
	var trend_rate = ((value - trend_target) * trend_rate_scalar - trend_rate_flat)
	#print(trend_rate)
	value = value - trend_rate * delta
	#print(value)
	var angle = ((value - 50) * ANGLE_RANGE) / 100
	$needle.rotation_degrees = angle
	#print($needle.rotation_degrees)
	#print(angle)
	if values_ready and (value < low_fail or value > high_fail):
		SignalBus.game_over.emit()
