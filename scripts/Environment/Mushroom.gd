extends Spatial

var bubble_timer = 0
var bubble_time_limit = 5
var sporeRes = preload("res://sceneObjects/Environment/Spore.tscn")

var had_already_been_collided = false
var is_being_collided = false

func _ready():
    bubble_time_limit = randi() % 50 + 5

func randomizeBubbleTimeLimit():
    bubble_time_limit = randi() % 100 + 50

func fallthroughCollisionActivate():
    is_being_collided = true
    if not had_already_been_collided:
        had_already_been_collided = true
        var how_many = randi() % 4 + 3
        for _i in range(how_many):
            spawnASpore()

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if is_being_collided:
        bubble_timer += (delta*22)
        if bubble_timer >= bubble_time_limit:
            bubble_timer = 0
            randomizeBubbleTimeLimit()

            if randi() % 2 == 0:
                spawnASpore()
            is_being_collided = false

func spawnASpore():
    var spore = sporeRes.instance()
    spore.bubble_speed = rand_range(4.0, 8.0)
    add_child(spore)
    spore.global_transform.origin = self.global_transform.origin
    spore.global_transform.origin.x += rand_range(0, 2.5)
    spore.global_transform.origin.z = 0
    spore.global_transform.origin.y -= rand_range(0, .625)
    
