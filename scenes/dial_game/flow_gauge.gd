extends Node2D

const MIN_ANGLE = -60
const MAX_ANGLE = 60
const ANGLE_RANGE = MAX_ANGLE - MIN_ANGLE


var value: float
var high_warn_delta = 10
var high_fail_delta = 20
var low_warn_delta = -10
var low_fail_delta = -20
var safe_target = 50
var trend_rate_scalar = 0
var trend_rate_flat = 0
var values_ready = false

func set_params_creation(val: float):
    self.value = val
    values_ready = true

func update_target_tween(new_target: float, time_to_update = 2):
    var tween = create_tween()
    tween.tween_property(self, "safe_target", new_target, time_to_update).set_trans(Tween.TRANS_SINE)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    random_movement()

func random_movement():
    """ Contains the loop that moves the target around """
    var delta
    var wait
    var new_target
    while true:
        delta = randi_range(-30, 30)
        wait = max(randfn(12, 2), 2.0)
        new_target = clamp(safe_target + delta, 0, 100)
        await get_tree().create_timer(wait).timeout
        update_target_tween(new_target)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    #print(value)
    var target_angle = ((safe_target - 50) * ANGLE_RANGE) / 100
    var angle = ((value - 50) * ANGLE_RANGE) / 100
    $safe_range.rotation_degrees = target_angle
    $needle.rotation_degrees = angle
    #print($needle.rotation_degrees)
    #print(angle)
    if values_ready and (value < safe_target + low_fail_delta or value > safe_target + high_fail_delta):
        SignalBus.game_over.emit()
