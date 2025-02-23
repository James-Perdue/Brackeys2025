extends Control
@onready var debug_button = %DebugButton
@onready var level_container = %LevelContainer

func _ready():
    %NextButton.pressed.connect(_on_next_button_pressed)
    debug_button.pressed.connect(_on_debug_button_pressed)
    process_mode = Node.PROCESS_MODE_ALWAYS

func _on_next_button_pressed():
    TimeKeeper.load_next_day()

func _on_debug_button_pressed():
    for child in level_container.get_children():
        child.queue_free()

    for day in range(1, 8):
        var button = Button.new()
        button.text = "Day " + str(day)
        level_container.add_child(button)
        button.pressed.connect(_on_day_button_pressed.bind(day))

func _on_day_button_pressed(day: int):
    TimeKeeper.day = day
    TimeKeeper.load_next_day()
