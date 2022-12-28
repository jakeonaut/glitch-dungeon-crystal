extends Spatial

var original_pos = null
var target_pos = null
onready var mySprite = get_node("Sprite3D")
onready var catchSound = get_node("CatchSound")
var didja_get_me = false
var opacity = 1.0

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export var is_static_in_level = true

# Called when the node enters the scene tree for the first time.
func _ready():
    if is_static_in_level and global.memory.has(level.getShortLevelName()) and global.memory[level.getShortLevelName()].has(self.name):
        queue_free()
        
    set_process(true)
    
    original_pos = global_transform.origin
    randomizeTargetPos()
    mySprite.material_override = mySprite.material_override.duplicate()

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*5)
    if didja_get_me:
        opacity = opacity + (0.0 - opacity) * (delta * 5)
        mySprite.material_override.set_shader_param("opacity", opacity)
        
        if stepify(opacity, 0.1) == 0:
            queue_free()
    else:
        var diff = target_pos - global_transform.origin
        var step = 0.1
        if stepify(abs(diff.x), step) == 0 and stepify(abs(diff.y), step) == 0:
            randomizeTargetPos()
        
func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-1, 1),
        original_pos.y + rand_range(-1, 1),
        original_pos.z
    )

    mySprite.flip_h = (target_pos.x < global_transform.origin.x)
    
func isActive():
    return false # true

func passiveActivate(_delta):
    if not didja_get_me:
        catchSound.play()
        if global.memory.has("dragonflies"):
            global.memory["dragonflies"] += 1
        else:
            global.memory["dragonflies"] = 1
        didja_get_me = true
        global.collectable_key_recently_got = "dragonflies"
        global.collectable_key_recently_got_timer = 0
        
        target_pos = Vector3(
            global_transform.origin.x,
            global_transform.origin.y + rand_range(2, 3),
            original_pos.z
        )
        
        if is_static_in_level:
            if not global.memory.has(level.getShortLevelName()):
                global.memory[level.getShortLevelName()] = {}
            global.memory[level.getShortLevelName()][self.name] = true
