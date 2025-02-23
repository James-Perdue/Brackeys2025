extends Control

var loss_png : AudioStream = load("res://audio/loss_png.wav")
@onready var loss_player = AudioStreamPlayer.new()
@export_range(-80.0, 24.0) var warning_volume_db: float = 0.0

func _ready():
    %ResetButton.pressed.connect(_on_reset_button_pressed)
    process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(loss_player)
    loss_player.stream = loss_png
    loss_player.finished.connect(start_loss)

func start_loss():
    print("C")
    loss_player.play()

func _on_reset_button_pressed():
    loss_player.stop()
    SignalBus.reset.emit()

func set_reason(reason):
    %Failure.text = "Failure: " + reason
