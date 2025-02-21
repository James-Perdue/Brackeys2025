extends Control

func _ready():
    %NextButton.pressed.connect(_on_next_button_pressed)
    process_mode = Node.PROCESS_MODE_ALWAYS

func _on_next_button_pressed():
    SignalBus.next_day.emit()
    TimeKeeper.load_next_day()
