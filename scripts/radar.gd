extends Control

@onready var radar_screen = %RadarScreen
@onready var radar_window : TextureRect = %RadarWindow
@onready var dial = %Dial
@onready var hit_button: TextureButton = %HitButton
@onready var warning_timer = Timer.new()

@onready var indicator_light : AnimatedSprite2D = %WarningLight

var enemy_positions : Array[Vector2] = []
var warning = false
@export_range(-80.0, 24.0) var warning_volume_db: float = 0.0
@export_range(-80.0, 24.0) var launch_volume_db: float = 0.0

@export var warning_sound: AudioStream
@export var missile_sound: AudioStream

@onready var warning_player = AudioStreamPlayer.new()
@onready var launch_player = AudioStreamPlayer.new()

var dial_active: bool = false
var dial_center: Vector2 = Vector2.ZERO

var warning_tween: Tween

func _ready():
    var spawn_timer = Timer.new()
    spawn_timer.wait_time = 4
    spawn_timer.timeout.connect(spawn_random_node)
    add_child(spawn_timer)
    spawn_timer.start()

    var ping_timer = Timer.new()
    ping_timer.wait_time = .5
    ping_timer.timeout.connect(display_pings)
    add_child(ping_timer)
    ping_timer.start()

    add_child(warning_timer)
    warning_timer.one_shot = true
    warning_timer.wait_time = 1.0
    warning_timer.timeout.connect(_on_warning_timer_timeout)

    add_child(warning_player)
    warning_player.stream = warning_sound
    warning_player.volume_db = warning_volume_db
    warning_player.finished.connect(func(): if warning: warning_player.play())

    launch_player.stream = missile_sound
    launch_player.volume_db = launch_volume_db
    add_child(launch_player)

    dial.connect("button_down", func(): dial_active = true)
    dial.connect("button_up", func(): dial_active = false)
    dial_center = dial.global_position + dial.size/2

    hit_button.pressed.connect(_on_hit_button_pressed)
    
    indicator_light.modulate.a = 0

func _on_warning_timer_timeout():
    process_warning(false)

func spawn_random_node():
    var random_angle = randf_range(0, TAU)

    var radius = radar_screen.size.x / 2 - 12
    var spawn_pos = Vector2(
        cos(random_angle) * radius,
        sin(random_angle) * radius
    )

    var ping_pos = radar_screen.size / 2 + spawn_pos - Vector2(4, 4)
    enemy_positions.append(ping_pos)

func display_pings():
    for pos in enemy_positions:
        var ping = ColorRect.new()
        ping.custom_minimum_size = Vector2(8, 8)
        ping.color = Color.GREEN
        radar_screen.add_child(ping)
        ping.position = pos - ping.custom_minimum_size / 2

        var lifetime_timer = Timer.new()
        lifetime_timer.wait_time = 0.2
        lifetime_timer.one_shot = true
        lifetime_timer.timeout.connect(func(): ping.queue_free())
        add_child(lifetime_timer)
        lifetime_timer.start()

func _process(delta: float) -> void:
    var center = radar_screen.size / 2
    var has_close_enemy = false

    for i in range(enemy_positions.size()):
        var distance_to_center : Vector2 = center - enemy_positions[i]
        if(distance_to_center.length() < 15):
            SignalBus.game_over.emit("The Radar")
            return
        if(distance_to_center.length() < 150):
            has_close_enemy = true
        var direction = distance_to_center.normalized()
        enemy_positions[i] += direction * 20.0 * delta

    if has_close_enemy and !warning:
        process_warning(true)
    if not has_close_enemy and warning:
        process_warning(false)

    if dial_active:
        var mouse_pos = get_viewport().get_mouse_position()
        var relative_pos = mouse_pos - (dial_center)
        var upwards_vector = Vector2.UP.rotated(dial.rotation)
        if relative_pos.angle_to(upwards_vector) > 0.01:
            dial.rotation_degrees -= 2
            radar_window.rotation_degrees -= 2
        elif relative_pos.angle_to(upwards_vector) < -0.01:
            dial.rotation_degrees += 2
            radar_window.rotation_degrees += 2
        clamp(dial.rotation_degrees, -360, 360)
        clamp(radar_window.rotation_degrees, -360, 360)

func process_warning(warning_value: bool):
    warning = warning_value
    if(warning):
        warning_player.play()
        if !warning_tween:
            warning_tween = create_tween().set_loops()
            warning_tween.tween_property(indicator_light, "modulate:a", 1.0, 0.5)\
            .set_trans(Tween.TRANS_SINE)\
            .set_ease(Tween.EASE_IN_OUT)
            warning_tween.tween_property(indicator_light, "modulate:a", 0.0, 0.5)\
            .set_trans(Tween.TRANS_SINE)\
            .set_ease(Tween.EASE_IN_OUT)
    else:
        warning_player.stop()
        if warning_tween:
            warning_tween.kill()
            warning_tween = create_tween()
            warning_tween.tween_property(indicator_light, "modulate:a", 0.0, 0.5)\
            .set_trans(Tween.TRANS_SINE)\
            .set_ease(Tween.EASE_IN_OUT)
            warning_tween = null

func _on_hit_button_pressed():
    var center = radar_screen.size / 2
    var window_forward = Vector2.UP.rotated(deg_to_rad(22.5)).rotated(radar_window.rotation)
    launch_player.play()
    for i in range(enemy_positions.size() - 1, -1, -1):
        var enemy_pos = enemy_positions[i]
        var to_enemy = enemy_pos - center
        var angle_diff = abs(to_enemy.angle_to(window_forward))
        
        if angle_diff < 0.5:
            enemy_positions.remove_at(i)
