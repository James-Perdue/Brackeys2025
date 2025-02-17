extends CharacterBody2D
signal dragsignal

var dragging = false
var drag_start_mouse_y_offset = 0  # get mouse y position relative to origin
var lev_scale = 1
const MIN_Y = -490
const MAX_Y = 300
const Y_SCALE = MAX_Y - MIN_Y
const RELEASE_GRACE = 50  # if too far out of range stop dragging
var relative_value = 0

func _ready() -> void:
	connect("dragsignal", _set_drag)
	lev_scale = get_parent().scale.y
	

func _process(delta):
	if dragging:
		# print("Is Dragging: ", delta)
		var mousepos = get_viewport().get_mouse_position()
		# print("Current position, ", lev_scale)
		var new_pos = (mousepos.y - drag_start_mouse_y_offset) / lev_scale
		# Stop some annoying behavior with tracking the mouse out of range
		if new_pos > MAX_Y:
			if new_pos > MAX_Y + RELEASE_GRACE:
				dragging = false
			new_pos = MAX_Y
		elif new_pos < MIN_Y:
			if new_pos < MIN_Y - RELEASE_GRACE:
				dragging = false
			new_pos = MIN_Y
			
		self.position.y = new_pos
		relative_value = (MAX_Y - self.position.y) * 100 / Y_SCALE
		#print("true position ", self.position.y, " mouse position: ", mousepos.y, "offset: ", drag_start_mouse_y_offset)
		
func _set_drag():
	dragging = !dragging
	var mousepos = get_viewport().get_mouse_position()
	drag_start_mouse_y_offset = mousepos.y - self.position.y * lev_scale
	#print("Test Drag Switch", self.position.y, " mouse position: ", mousepos.y, "offset: ", drag_start_mouse_y_offset)


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	# print("got_event")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("dragsignal")
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			emit_signal("dragsignal")
