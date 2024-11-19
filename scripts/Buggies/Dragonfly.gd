extends Spatial

var original_pos = null
var target_pos = null
onready var mySprite = get_node("Sprite3D")
onready var catchSound = get_node("CatchSound")
onready var smackSound = get_node("SmackSound")
var didja_get_me = false
var opacity = 1.0

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export var is_static_in_level = true

var is_smacked = false
var smack_timer = 0
export var smack_time_limit = 2
var miniCubeCrystalRes = preload("res://sceneObjects/miniCubeCrystal.tscn")
var malwareDragonflyRes = preload("res://sceneObjects/Buggies/MalwareDragonfly.tscn")
var is_swimmin_away = false

# Called when the node enters the scene tree for the first time.
func _ready():
    # is_static_in_level = false # TODO(jaketroweR): :-)

    set_process(true)
    original_pos = global_transform.origin
    randomizeTargetPos()
    mySprite.material_override = mySprite.material_override.duplicate()
    mySprite.global_transform.origin = self.global_transform.origin

    if is_static_in_level and global.getStaticLevelZoneLevelVar(level, self):
        # set_process(false)
        yield(TempTimer.idle_frame(self), "timeout")
        yield(TempTimer.idle_frame(self), "timeout")
        var miniCubeCrystal = miniCubeCrystalRes.instance()
        level.add_child(miniCubeCrystal)
        miniCubeCrystal.global_transform.origin = global.normalizeMemoryPosition(global.getStaticLevelZoneLevelVar(level, self))
        miniCubeCrystal.addPlusSprite()
        miniCubeCrystal.queue_free()
        can_i_spawn_crystal = false

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
    if is_swimmin_away:
        step = 5
        if stepify(target_pos.x, 0.1) == stepify(global_transform.origin.x, 0.1) and \
        stepify(target_pos.y, 0.1) == stepify(global_transform.origin.y, 0.1):
            is_swimmin_away = false
            randomizeTargetPos()
    elif not didja_get_me and stepify(abs(diff.x), step) == 0 and stepify(abs(diff.y), step) == 0:
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
    
var is_active = true
func isActive(_debug=false):
    return visible and is_active

func passiveActivate(_delta, _is_player):
    if not is_swimmin_away:
        is_swimmin_away = true
        
    var x_min = 2
    var x_max = 3
    var y_min = 2
    var y_max = 3
    if level.player.global_transform.origin.x > self.global_transform.origin.x:
        x_min = -3
        x_max = -2
    if level.player.global_transform.origin.y > self.global_transform.origin.y:
        y_min = -3
        y_max = -2


    target_pos = Vector3(
        global_transform.origin.x + rand_range(x_min, x_max),
        global_transform.origin.y + rand_range(y_min, y_max),
        original_pos.z
    )
    mySprite.flip_h = (target_pos.x < global_transform.origin.x)

export var time_influence = 35
export var y_div = 2.3
export var normal_offset = .15
var can_i_spawn_crystal = true
func getSmacked(_broom_origin = Vector3(0, 0, 0)):
    if is_smacked:
        return

    if level.player.malware_infected:
        var malwareDragonfly = malwareDragonflyRes.instance()
        level.add_child(malwareDragonfly)
        malwareDragonfly.global_transform.origin = self.global_transform.origin
        self.queue_free()
        return
    if catchSound: catchSound.play()
    if smackSound: smackSound.play()
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

    if is_static_in_level and can_i_spawn_crystal:
        var miniCubeCrystal = miniCubeCrystalRes.instance()
        miniCubeCrystal.is_static_in_level = false
        level.add_child(miniCubeCrystal)
        miniCubeCrystal.global_transform.origin = self.global_transform.origin
        miniCubeCrystal.passiveActivate(0, false)

        global.setStaticLevelZoneLevelVar(level, self, global_transform.origin)
