extends CanvasLayer
@onready var clock_arm : Sprite2D = %ClockArm
@onready var help_button : TextureButton = %HelpButton

var help_board = preload("res://scenes/HelpMenu.tscn")

func _ready() -> void:
    TimeKeeper.start_day()
    help_button.connect("pressed", _on_help_pressed)
    start_clock()

func start_clock() -> void:
    clock_arm.rotation_degrees = 0
    if(TimeKeeper.day_lengths.size() > TimeKeeper.day - 1):
        var tween = create_tween()
        tween.tween_property(clock_arm, "rotation_degrees", 360, TimeKeeper.day_lengths[TimeKeeper.day - 1])
        tween.set_trans(Tween.TRANS_LINEAR)

func _input(event: InputEvent) -> void:
    if(event.is_action_pressed("Help")):
        var help = help_board.instantiate()
        add_child(help)

func _on_help_pressed() -> void:
    var help = help_board.instantiate()
    add_child(help)
