extends Spatial

onready var mySprite = get_node("Sprite3D")
var grav = 28
var vv = 0
var terminal_vel = -10

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    terminal_vel = rand_range(-10, -20)
    setSpriteValues(mySprite)

func setSpriteValues(whichSprite):
    var maxFrames = 8
    var startingFrame = randi() % (40 - maxFrames)

    whichSprite.updateBaseFrame(startingFrame % 10, startingFrame / 4)
    whichSprite.max_frames = maxFrames
    whichSprite.should_soft_fizzle_out = true

func _process(delta):
    processSpriteValues(mySprite)

    if not is_instance_valid(mySprite):
       queue_free()
    else:
        vv -= (grav * delta)
        if vv < terminal_vel:
            vv = terminal_vel
        global_transform.origin.y += (vv * delta)

func processSpriteValues(whichSprite):
    if is_instance_valid(whichSprite):
        if not whichSprite.visible:
            whichSprite.should_soft_fizzle_out = false
            whichSprite.should_fizzle_out = true
            whichSprite.max_frames = 1
            whichSprite.restart()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#   pass
