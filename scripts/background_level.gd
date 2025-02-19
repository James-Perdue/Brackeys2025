extends CanvasLayer
@onready var clock_arm : Sprite2D = %ClockArm

func _ready() -> void:
    TimeKeeper.start_day()
    start_clock()

func start_clock() -> void:
    clock_arm.rotation_degrees = 0
    if(TimeKeeper.day_lengths.size() > TimeKeeper.day):
        var tween = create_tween()
        tween.tween_property(clock_arm, "rotation_degrees", 360, TimeKeeper.day_lengths[TimeKeeper.day])
        tween.set_trans(Tween.TRANS_LINEAR)
