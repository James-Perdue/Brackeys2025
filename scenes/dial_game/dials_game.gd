extends Node2D

var b1_held = false
var b3_held = false
var b4_held = false

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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

func _button_b3_u() -> void:
	print("button_3_up")

func _button_b4_d() -> void:
	print("button_4_down")
	$Dials/radiativity.trend_rate_flat += 5
	$Dials/temperature.trend_rate_flat += 2.5

func _button_b4_u() -> void:
	print("button_4_up")
	$Dials/radiativity.trend_rate_flat -= 5
	$Dials/temperature.trend_rate_flat -= 2.5

func _button_b5_p() -> void:
	print("button_5_up")

func _flip_t1(state) -> void:
	print("Toggled Switch, ", state)
	$Buttons/TextureButton_B3.disabled = !state
	var delay = 0.75 if state else 0.25
	await get_tree().create_timer(delay).timeout
	$Buttons/TextureButton_B5.disabled = !state
