extends Node2D

var b1_held = false
var b3_held = false
var b4_held = false

var lever_drag = [0, 0]
var lever_to_dial_scalar = 1
var active_dial_warnings: Array[StringName] = []
const SHORT_KEYS = ["A", "S", "D", "F", "G"]

@onready var warning_player = AudioStreamPlayer.new()
@export var warning_sound: AudioStream
@export_range(-80.0, 24.0) var warning_volume_db: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.
    # Link button presses to functionality
    $Buttons/TextureButton_B1.button_down.connect(_button_b1_d)
    $Buttons/TextureButton_B1.button_up.connect(_button_b1_u)
    $Buttons/TextureButton_B2.button_down.connect(_button_b2_press)
    $Buttons/TextureButton_B3.button_down.connect(_button_b3_d)
    $Buttons/TextureButton_B3.button_up.connect(_button_b3_u)
    $Buttons/TextureButton_B4.button_down.connect(_button_b4_d)
    $Buttons/TextureButton_B4.button_up.connect(_button_b4_u)
    $Buttons/TextureButton_B5.pressed.connect(_button_b5_p)
    $Buttons/TextureButton_T1.toggled.connect(_flip_t1)

    # Buttons should start disabled
    $Buttons/TextureButton_B3.disabled = true
    $Buttons/TextureButton_B5.disabled = true

    $lever/handle_body.change_dials.connect(_lever_changed_to_dials)
    # Flow ready needs lever to be ready
    $flow_gauge.set_params_creation(50)

    # connect warning signals from the dials
    $Dials/steam_pressure.dial_warn.connect(_process_dial_warn.bind("STEAM"))
    $Dials/temperature.dial_warn.connect(_process_dial_warn.bind("TEMP"))
    $Dials/radiativity.dial_warn.connect(_process_dial_warn.bind("RAD"))
    add_child(warning_player)
    warning_player.stream = warning_sound
    warning_player.volume_db = warning_volume_db

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    # Get Lever value and pass to flow gauge
    $flow_gauge.value = $lever/handle_body.relative_value

func _process_dial_warn(set_warning: bool, dial_name: StringName):
    print("Warning Signal, ", set_warning, dial_name)
    # gdscript should make sets a thing
    if set_warning and dial_name not in active_dial_warnings:
        active_dial_warnings.append(dial_name)
    elif not set_warning:
        active_dial_warnings.erase(dial_name)
    # toggle warning player as needed
    if set_warning and not warning_player.playing:
        print(active_dial_warnings)
        warning_player.play()
    elif active_dial_warnings.is_empty():
        warning_player.stop()
    

func _unhandled_key_input(event: InputEvent) -> void:
    # Fix stupid behavior with holding
    # FIXME: Years of godot coding, still no solution to showing a button held when used from keyboard
    match event.as_text():
        "A":
            if event.is_pressed() and not b1_held:
                print("Holding")
                b1_held = true
                _button_b1_d()
            elif event.is_released():
                print("releasing")
                b1_held = false
                _button_b1_u()
        "S":
            if event.is_pressed():
                _button_b2_press()
        "D":
            if event.is_pressed() and not b3_held:
                print("Holding")
                b3_held = true
                _button_b3_d()
            elif event.is_released():
                print("releasing")
                b3_held = false
                _button_b3_u()
        "F":
            if event.is_pressed() and not b4_held:
                print("Holding")
                b4_held = true
                _button_b4_d()
            elif event.is_released():
                print("releasing")
                b4_held = false
                _button_b4_u()
        "G":
            if event.is_pressed():
                _button_b5_p()
        _:
            return  # doesn't match hotkeys for buttonry
    get_viewport().set_input_as_handled()

func _lever_changed_to_dials(is_dragging, cur_val):
    if is_dragging:  # ie lever  got picked up
        lever_drag[0] = cur_val
        print("recorded drag start")
    else:  # lever got released
        lever_drag[1] = cur_val
        print("recorded drag end")
        var delta = lever_drag[1] - lever_drag[0]
        # change over 2 second
        $Dials/steam_pressure.trend_rate_flat -= delta * lever_to_dial_scalar / 2
        $Dials/temperature.trend_rate_flat += delta * lever_to_dial_scalar / 4
        await get_tree().create_timer(2).timeout
        $Dials/steam_pressure.trend_rate_flat += delta * lever_to_dial_scalar / 2
        $Dials/temperature.trend_rate_flat -= delta * lever_to_dial_scalar / 4


func _button_b1_d() -> void:
    print("button_1_down")
    $Dials/steam_pressure.trend_rate_flat += 25
    $Dials/temperature.trend_rate_flat -= 5

func _button_b1_u() -> void:
    print("button_1_up")
    $Dials/steam_pressure.trend_rate_flat -= 25
    $Dials/temperature.trend_rate_flat += 5

func _button_b2_press() -> void:
    print("button_2_press")
    $Dials/temperature.value +=10
    $Dials/radiativity.value -=25

func _button_b3_d() -> void:
    print("button_3_down")
    $Dials/steam_pressure.trend_rate_flat += 12
    $Dials/radiativity.trend_rate_flat += 5
    $Dials/temperature.trend_rate_flat += 2.5
    

func _button_b3_u() -> void:
    print("button_3_up")
    $Dials/steam_pressure.trend_rate_flat -= 12
    $Dials/radiativity.trend_rate_flat -= 5
    $Dials/temperature.trend_rate_flat -= 2.5

func _button_b4_d() -> void:
    print("button_4_down")
    $Dials/radiativity.trend_rate_flat += 5
    $Dials/temperature.trend_rate_flat += 2.5

func _button_b4_u() -> void:
    print("button_4_up")
    $Dials/radiativity.trend_rate_flat -= 5
    $Dials/temperature.trend_rate_flat -= 2.5

func _button_b5_p() -> void:
    var pressure = $Dials/steam_pressure.value + 25
    var tween = create_tween()
    tween.tween_property($Dials/steam_pressure, "value", pressure, 3).set_trans(Tween.TRANS_ELASTIC)
    tween.parallel().tween_property($Dials/steam_pressure, "value", pressure, 3).set_trans(Tween.TRANS_ELASTIC)
    print("button_5_up")

func _flip_t1(state) -> void:
    print("Toggled Switch, ", state)
    $Buttons/TextureButton_B3.disabled = !state
    var delay = 0.75 if state else 0.25
    await get_tree().create_timer(delay).timeout
    $Buttons/TextureButton_B5.disabled = !state
    lever_to_dial_scalar = 3 if state else 1  # Increase leve efficacy
