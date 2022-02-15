extends Spatial

onready var mrmotex1 = get_node("MrMoTex")
onready var mrmotex2 = get_node("MrMoTex2")
onready var mrmotex3 = get_node("MrMoTex3")
onready var mrmotex4 = get_node("MrMoTex4")
onready var appearSound = get_node("AppearSound")

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    appearSound.pitch_scale = rand_range(1.0, 1.8)
    setSpriteValues(mrmotex1)
    setSpriteValues(mrmotex2)
    setSpriteValues(mrmotex3)
    setSpriteValues(mrmotex4)

func setSpriteValues(whichSprite):
    whichSprite.updateBaseFrame(randi() % 32, (randi() % 4) + 27)
    whichSprite.max_frames = randi() % 20 + 8
    whichSprite.should_soft_fizzle_out = true

func _process(delta):
    processSpriteValues(mrmotex1)
    processSpriteValues(mrmotex2)
    processSpriteValues(mrmotex3)
    processSpriteValues(mrmotex4)

    if not is_instance_valid(mrmotex1) and not is_instance_valid(mrmotex2) \
       and not is_instance_valid(mrmotex3) and not is_instance_valid(mrmotex4):
       queue_free()

func processSpriteValues(whichSprite):
    if is_instance_valid(whichSprite):
        if not whichSprite.visible:
            whichSprite.should_soft_fizzle_out = false
            whichSprite.should_fizzle_out = true
            whichSprite.updateBaseFrame(17, 6)
            whichSprite.max_frames = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#   pass
