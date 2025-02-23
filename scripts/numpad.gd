extends Control
var code = ""
var goal_code = "12345"
var warning = false
@onready var code_label : Label = %CodeLabel
@onready var goal_code_label : Label = %CodeNeeded
@onready var game_timer = Timer.new()
@onready var warning_timer = Timer.new()
@onready var ticker: AnimatedSprite2D = $Ticker

@export var warning_sound: AudioStream
@export var incorrect_sound: AudioStream
@export var keypress_sound: AudioStream
@export var pass_sound: AudioStream

@export_range(-80.0, 24.0) var warning_volume_db: float = 0.0
@export_range(-80.0, 24.0) var incorrect_volume_db: float = 0.0
@export_range(-80.0, 24.0) var keypress_volume_db: float = 0.0
@export_range(-80.0, 24.0) var pass_volume_db: float = 0.0

@onready var warning_player = AudioStreamPlayer.new()
@onready var incorrect_player = AudioStreamPlayer.new()
@onready var keypress_player = AudioStreamPlayer.new()
@onready var pass_player = AudioStreamPlayer.new()

@onready var indicator_light : TextureRect = %IndicatorLight

var warning_tween: Tween

func _ready():
    goal_code = generate_random_code()
    for i in range(10):
        var button = get_node("keys/" +str(i))
        button.pressed.connect(_on_number_pressed.bind(i))

    ticker.animation_finished.connect(_on_ticker_animation_finished)
    set_new_goal_code(goal_code)
    add_child(game_timer)
    game_timer.one_shot = true
    game_timer.wait_time = 15.0
    game_timer.timeout.connect(_on_game_timer_timeout)
    game_timer.start()

    add_child(warning_timer)
    warning_timer.one_shot = true
    warning_timer.wait_time = 7.0
    warning_timer.timeout.connect(_on_warning_timer_timeout)
    warning_timer.start()

    add_child(warning_player)
    add_child(incorrect_player)
    add_child(keypress_player)
    add_child(pass_player)

    warning_player.stream = warning_sound
    warning_player.volume_db = warning_volume_db
    incorrect_player.stream = incorrect_sound
    incorrect_player.volume_db = incorrect_volume_db
    keypress_player.stream = keypress_sound
    keypress_player.volume_db = keypress_volume_db
    pass_player.stream = pass_sound
    pass_player.volume_db = pass_volume_db
    indicator_light.modulate.a = 0

func set_new_goal_code(new_code: String):
    goal_code = new_code
    goal_code_label.text = ""
    ticker.play()

func _on_ticker_animation_finished():
            goal_code_label.text = "Enter: " + goal_code

func _on_game_timer_timeout():
    SignalBus.game_over.emit("The Numpad")

func _on_warning_timer_timeout():
    process_warning(true)

func _on_number_pressed(number: int):
    keypress_player.play()
    code += str(number)
    code_label.text = "Code:" + code
    if(code[code.length() - 1] != goal_code[code.length() - 1]):
        print("Wrong Code!")
        incorrect_player.play()
        code = ""
        code_label.text = "Code: " + code

    if(code.length() == 5):
        if(code == goal_code):
            print("Code entered correctly")
            var new_code = generate_random_code()
            set_new_goal_code(new_code)
            pass_player.play()
            process_warning(false)
            game_timer.start()
        else:
            print("Wrong Code!")
            incorrect_player.play()
        code = ""
        code_label.text = "Code:" + code

func process_warning(warning_value: bool):
    warning = warning_value
    if warning:
        if(!warning_player.playing):
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
        if(warning_player.playing):
            warning_player.stop()
        if warning_tween:
            warning_tween.kill()
            warning_tween = create_tween()
            warning_tween.tween_property(indicator_light, "modulate:a", 0.0, 0.5)\
            .set_trans(Tween.TRANS_SINE)\
            .set_ease(Tween.EASE_IN_OUT)
            warning_tween = null

func generate_random_code() -> String:
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    var random_code = ""
    for i in range(5):
        random_code += str(rng.randi_range(0, 9))
    return random_code
