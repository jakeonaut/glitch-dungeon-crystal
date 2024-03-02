extends Spatial

var original_pos = null
var target_pos = null
onready var mySprite = get_node("Sprite3D")
onready var catchSound = get_node("CatchSound")
onready var cicadaSound = get_node("CicadaSound")
onready var cicadaSound2 = get_node("CicadaSound2")
var cicada_timer = 0
var cicada_time_limit = 10
var didja_get_me = false
var opacity = 1.0
var is_awake = false

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export var is_static_in_level = true

# Called when the node enters the scene tree for the first time.
func _ready():
    if is_static_in_level and global.getStaticLevelZoneLevelVar(level, self.name):
        queue_free()
        
    set_process(true)
    
    original_pos = global_transform.origin
    randomizeTargetPos()
    mySprite.material_override = mySprite.material_override.duplicate()

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if is_awake:
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
    else:
        cicada_timer += (delta*22)
        if cicada_timer >= cicada_time_limit:
            cicada_timer = 0
            cicada_time_limit = rand_range(5, 15)
            if randi() % 2 == 0:
                cicadaSound.play()
            else:
                cicadaSound2.play()
        
func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-1, 1),
        original_pos.y + rand_range(-1, 1),
        original_pos.z
    )

    mySprite.flip_h = (target_pos.x < global_transform.origin.x)
    
export var is_active = true
func isActive(debug=false):
    return visible and is_active

# @override
func playerActivationAreaPassiveActivate():
    if not is_awake:
        is_awake = true
        mySprite.max_frames = 2
        mySprite.updateBaseFrame(1, 4)


func passiveActivate(_delta, _is_player):
    if not didja_get_me:
        catchSound.play()
        if global.memory.has("cicadas"):
            global.memory["cicadas"] += 1
        else:
            global.memory["cicadas"] = 1
        didja_get_me = true
        global.collectable_key_recently_got = "cicadas"
        global.collectable_key_recently_got_timer = 0
        
        target_pos = Vector3(
            global_transform.origin.x,
            global_transform.origin.y + rand_range(2, 3),
            original_pos.z
        )
        
        if is_static_in_level:
            global.setStaticLevelZoneLevelVar(level, self.name, true)
