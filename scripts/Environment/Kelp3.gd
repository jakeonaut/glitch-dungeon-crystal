extends Spatial


var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")

var bubble_timer = 0
var bubble_time_limit = 5

func _ready():
    bubble_time_limit = randi() % 50 + 5

func randomizeBubbleTimeLimit():
    bubble_time_limit = randi() % 100 + 50

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if global_transform.origin.z > 2:
        return

    bubble_timer += (delta*22)
    if bubble_timer >= bubble_time_limit:
        bubble_timer = 0
        randomizeBubbleTimeLimit()

        if randi() % 2 == 0:
            var bubble = bubbleRes.instance()
            # bubble.bubble_speed = rand_range(4.0, 8.0)
            add_child(bubble)
            bubble.global_transform.origin = self.global_transform.origin
            bubble.global_transform.origin.z = 0
            bubble.global_transform.origin.y += rand_range(0, .625)
