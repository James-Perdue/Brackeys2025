extends Control

func _ready():
    %NextButton.pressed.connect(_on_next_button_pressed)
    process_mode = Node.PROCESS_MODE_ALWAYS

func _on_next_button_pressed():
    TimeKeeper.load_next_day()
