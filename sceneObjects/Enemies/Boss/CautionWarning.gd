extends Spatial

export var is_fast = false
onready var aniPlayer = get_node("AnimationPlayer")

func _ready():
    set_process(true)

func _process(_delta):
    if aniPlayer.assigned_animation == "byebye":
        return
        
    if is_fast and not aniPlayer.assigned_animation == "cautionFast":
        aniPlayer.stop()
        aniPlayer.clear_queue()
        aniPlayer.play("cautionFast")
    elif not is_fast and not aniPlayer.assigned_animation == "caution":
        aniPlayer.stop()
        aniPlayer.clear_queue()
        aniPlayer.play("caution")