extends Spatial

var original_pos = null
var target_pos = null
onready var mySprite = get_node("Sprite3D")
onready var catchSound = get_node("CatchSound")
var didja_get_me = false
var opacity = 1.0

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export var is_static_in_level = true

var is_smacked = false
var smack_timer = 0
export var smack_time_limit = 2

# Called when the node enters the scene tree for the first time.
func _ready():
    is_static_in_level = false # TODO(jaketroweR): :-)

    if is_static_in_level and global.getStaticLevelZoneLevelVar(level, self.name):
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

    var diff = target_pos - global_transform.origin
    var step = 0.1
    if not didja_get_me and stepify(abs(diff.x), step) == 0 and stepify(abs(diff.y), step) == 0:
        randomizeTargetPos()

    if is_smacked:
        smack_timer += (delta * 22)
        if smack_timer >= smack_time_limit:
            unsmack()
            didja_get_me = true

func unsmack():
    is_smacked = false
    mySprite.material_override.set_shader_param("time_influence", 3)
    mySprite.material_override.set_shader_param("y_div", 2.3)
    mySprite.material_override.set_shader_param("normal_offset", .02)
        
func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-1, 1),
        original_pos.y + rand_range(-1, 1),
        original_pos.z
    )

    mySprite.flip_h = (target_pos.x < global_transform.origin.x)
    
func isActive():
    return true

func passiveActivate(_delta):
    if not didja_get_me:
        catchSound.play()
        # if global.memory.has("dragonflies"):
        #     global.memory["dragonflies"] += 1
        # else:
        #     global.memory["dragonflies"] = 1
        didja_get_me = true
        # global.collectable_key_recently_got = "dragonflies"
        # global.collectable_key_recently_got_timer = 0
        
        target_pos = Vector3(
            global_transform.origin.x,
            global_transform.origin.y + rand_range(2, 3),
            original_pos.z
        )
        
        if is_static_in_level:
            global.setStaticLevelZoneLevelVar(level, self.name, true)

export var time_influence = 35
export var y_div = 2.3
export var normal_offset = .15
func getSmacked(_broom_origin):
    if catchSound: catchSound.play()
    mySprite.material_override.set_shader_param("time_influence", time_influence)
    mySprite.material_override.set_shader_param("y_div", y_div)
    mySprite.material_override.set_shader_param("normal_offset", normal_offset)
    
    smack_timer = 0
    is_smacked = true
    if level.player.mySprite.flip_h:
        target_pos = self.global_transform.origin + Vector3(-3, 6, 0)
    else:
        target_pos = self.global_transform.origin + Vector3(3, 6, 0)
    mySprite.flip_h = (target_pos.x < global_transform.origin.x)