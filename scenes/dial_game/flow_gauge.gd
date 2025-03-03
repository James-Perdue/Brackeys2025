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
@onready var flow_timer : Timer = Timer.new()
@onready var warning_player = AudioStreamPlayer.new()
@export var warning_sound: AudioStream
@export_range(-80.0, 24.0) var warning_volume_db: float = 0.0

func set_params_creation(val: float):
    self.value = val
    values_ready = true

func update_target_tween(new_target: float, time_to_update = 2):
    var tween = create_tween()
    tween.tween_property(self, "safe_target", new_target, time_to_update).set_trans(Tween.TRANS_SINE)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    add_child(flow_timer)
    add_child(warning_player)
    warning_player.stream = warning_sound
    warning_player.volume_db = warning_volume_db
    flow_timer.one_shot = true
    flow_timer.wait_time = max(randfn(12, 2), 2.0)
    flow_timer.timeout.connect(random_movement)
    flow_timer.start()

func random_movement():
    """ Contains the loop that moves the target around """
    var delta
    var wait
    var new_target

    delta = randi_range(-15, 15)
    new_target = clamp(safe_target + delta, 0, 100)
    update_target_tween(new_target)

    wait = max(randfn(12, 2), 2.0)
    flow_timer.wait_time = wait
    flow_timer.start()

func _process_warning(to_warn: bool):
    if to_warn and not warning_player.playing:
        warning_player.play()
    elif warning_player.playing and not to_warn:
        warning_player.stop()

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
        SignalBus.game_over.emit("The Flow Gauge")
    elif values_ready and (value < safe_target + low_warn_delta or value > safe_target + high_warn_delta):
        _process_warning(true)
    else:
        _process_warning(false)
