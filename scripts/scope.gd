extends Control

var goal_graph_factor: float = .1
var player_line_factor: float = .11
var target_goal_factor: float = .1
@export var warning_threshold: float = 0.02
@export var ending_threshold: float = 0.04
@export var warning_sound_file: AudioStream

@onready var dial :TextureButton = %Dial
@onready var indicator : TextureRect = %Indicator
@onready var indicator_light : TextureRect = %IndicatorLight

@onready var goal_line: Line2D = %GraphLine
@onready var player_line: Line2D = %PlayerLine
@onready var warning_sound: AudioStreamPlayer2D = AudioStreamPlayer2D.new()

var goal_change_timer: Timer
var current_wave_type = Utils.GraphWaveform.SINE
var player_wave_type = Utils.GraphWaveform.SINE

var dial_active: bool = false
var goal_tween: Tween
var warning_tween: Tween
var warning: bool = false

func _ready():
    draw_sine_wave(goal_line, goal_graph_factor)
    draw_sine_wave(player_line, player_line_factor)

    dial.connect("button_down", func(): dial_active = true)
    dial.connect("button_up", func(): dial_active = false)

    warning_sound.stream = warning_sound_file

    goal_change_timer = Timer.new()
    goal_change_timer.wait_time = 2.0
    goal_change_timer.connect("timeout", _on_goal_change_timeout)
    goal_line.width = 4.0
    goal_line.default_color = Color.GREEN
    player_line.width = 4.0
    player_line.default_color = Color.RED

    add_child(goal_change_timer)
    add_child(warning_sound)
    goal_change_timer.start()
    indicator_light.modulate.a = 0

func _on_goal_change_timeout():
    var direction: int = sign(goal_graph_factor - player_line_factor)

    target_goal_factor = goal_graph_factor + randf_range(0, 0.01 * (direction if direction != 0 else 1))

    if goal_tween:
        goal_tween.kill()
    goal_tween = create_tween()
    goal_tween.tween_property(self, "goal_graph_factor", target_goal_factor, .6)\
         .set_trans(Tween.TRANS_SINE)\
         .set_ease(Tween.EASE_IN_OUT)

    goal_change_timer.start()

func draw_sine_wave(line_2d :Line2D, graph_factor: float):
    line_2d.clear_points()
    var points = 100
    var width = 375
    var height = 95
    for i in range(points):
        var x = (i / float(points)) * width
        var y = sin(i * graph_factor) * height
        line_2d.add_point(Vector2(x, y))

func update_goal_type():
    var wave_type = randi() % 5
    current_wave_type = Utils.GraphWavefor[wave_type]

func _process(_delta: float) -> void:
    var distance: float = abs(goal_graph_factor - player_line_factor)
    if(distance > warning_threshold):
        warning = true
    else:
        warning = false
    if(distance > ending_threshold):
        SignalBus.game_over.emit()

    if warning:
        if(!warning_sound.playing):
            warning_sound.play()
        if !warning_tween:
            warning_tween = create_tween().set_loops()
            warning_tween.tween_property(indicator_light, "modulate:a", 1.0, 0.5)\
            .set_trans(Tween.TRANS_SINE)\
            .set_ease(Tween.EASE_IN_OUT)
            warning_tween.tween_property(indicator_light, "modulate:a", 0.0, 0.5)\
            .set_trans(Tween.TRANS_SINE)\
            .set_ease(Tween.EASE_IN_OUT)
    else:
        if(warning_sound.playing):
            warning_sound.stop()
        if warning_tween:
            warning_tween.kill()
            warning_tween = create_tween()
            warning_tween.tween_property(indicator_light, "modulate:a", 0.0, 0.5)\
            .set_trans(Tween.TRANS_SINE)\
            .set_ease(Tween.EASE_IN_OUT)
            warning_tween = null

    if dial_active:
        var mouse_pos = get_viewport().get_mouse_position()
        var relative_pos = mouse_pos - dial.global_position
        if (relative_pos.x < 0 and Input.get_last_mouse_velocity().x < 0) \
            or (relative_pos.x < 0 and Input.get_last_mouse_velocity().y > 0) or \
           (relative_pos.x > 0 and Input.get_last_mouse_velocity().y < 0):
            player_line_factor += .001
            dial.rotation_degrees -= 1
        elif (relative_pos.x > 0 and Input.get_last_mouse_velocity().x > 0) \
            or (relative_pos.x > 0 and Input.get_last_mouse_velocity().y > 0) or \
           (relative_pos.x < 0 and Input.get_last_mouse_velocity().y < 0):
            player_line_factor -= .001
            dial.rotation_degrees += 1

        draw_wave(player_line, player_line_factor)

    draw_wave(goal_line, goal_graph_factor)

func draw_wave(wave: Line2D, graph_factor: float):
    match current_wave_type:
        0:  # Sine wave
            draw_sine_wave(wave, graph_factor)
        1:  # Square wave
            pass
            #draw_square_wave(goal_line)
        2:  # Triangle wave
            pass
            #draw_triangle_wave(goal_line)
        3:  # Sawtooth wave
            pass
            #draw_sawtooth_wave(goal_line)
