extends Control

@onready var body_text = %Body
@onready var prev_button = %PreviousPage
@onready var next_button = %NextPage
@onready var close_button = %CloseButton

var current_page = 0
var pages = []

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    load_day_notes()
    update_page_display()
    next_button.connect("pressed", _on_next_page_pressed)
    prev_button.connect("pressed", _on_previous_page_pressed)
    close_button.connect("pressed", _on_close_pressed)
    get_tree().paused = true

func load_day_notes():
    var file = FileAccess.open("res://data/day%dnotes.json" % TimeKeeper.day, FileAccess.READ)
    if file:
        var json = JSON.new()
        var parse_result = json.parse(file.get_as_text())
        if parse_result == OK:
            pages = json.get_data()
        file.close()

func update_page_display():
    if pages.size() > 0:
        body_text.text = pages[current_page]

        # Update button states
        prev_button.disabled = (current_page <= 0)
        next_button.disabled = (current_page >= pages.size() - 1)

func _on_next_page_pressed():
    if current_page < pages.size() - 1:
        current_page += 1
        update_page_display()

func _on_previous_page_pressed():
    if current_page > 0:
        current_page -= 1
        update_page_display()

func _on_close_pressed():
    get_tree().paused = false
    queue_free()  # or queue_free() if you're instancing this scene
