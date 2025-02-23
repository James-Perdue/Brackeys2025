extends Control

func _ready():
    %ResetButton.pressed.connect(_on_reset_button_pressed)
    process_mode = Node.PROCESS_MODE_ALWAYS

func _on_reset_button_pressed():
    SignalBus.reset.emit()

func set_reason(reason):
    %Failure.text = "Failure: " + reason
