extends Spatial

export var mushroom_walk_direction = -1
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var mySprite1 = get_node("Sprite3D")
onready var mySprite2 = get_node("Sprite3D2")
onready var mySprite3 = get_node("Sprite3D3")
onready var mySprite4 = get_node("Sprite3D4")
onready var tongueDirSprite = get_node("TongueDirSprite")

func _ready():
    mySprite1.material_override = mySprite1.material_override.duplicate()
    mySprite2.material_override = mySprite1.material_override
    mySprite3.material_override = mySprite1.material_override
    mySprite4.material_override = mySprite1.material_override
    # var hframe = randi() % mySprite.hframes
    # var vframe = randi() % mySprite.vframes
    # mySprite.updateBaseFrame(hframe, vframe)
    set_process(true)

    # if mushroom_walk_direction == -1:
    #     mySprite.material_override.set_shader_param("target_palette", global.base_palette_pink)

var reactivate_timer = 0
var reactivate_time_limit = 30
func _process(delta):
    if not is_active:
        reactivate_timer += (delta*11)
        if reactivate_timer >= reactivate_time_limit:
            reactivate_timer = 0
            is_active = true

    if is_smacked:
        smack_timer += (delta * 22)
        if smack_timer >= smack_time_limit:
            unsmack()
        if smack_timer >= smack_recovery_time_limit:
            is_smacked = false

var is_active = true
func isActive():
    return true

func passiveActivate(_delta, is_player, _is_local_broom = false):
    if is_player and is_active and level.player.canIGetCaught(true):
        level.clearOtherGrabbers(level.player)
        reactivate_timer = 0
        is_active = false
        # level.player.is_mushroom_infected = true
        
        level.player.gravitySound.play()
        # if level.player.transformation == level.player.TransformationState.FISHY:
        #     level.player.getFishyCured()
        # if level.player.transformation == level.player.TransformationState.CHICKEN:
        #     level.player.getChickenCured()
        # level.player.loseBroom()
        # level.player.mushroom_infection_direction = mushroom_walk_direction
        level.player.on_ground = false
        level.player.truly_on_ground = false
        level.player.glitchTickle()
        level.player.tryClearFallthroughCollisionSolid(self.global_transform.origin)
        var rotation_vector = Vector2(0, 0)
        
        # respect inputs first...
        # if level.player.physics_state == level.player.PhysicsState.BEING_TOSSED:
        #     if Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
        #         rotation_degrees.z = 180
        #     elif Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
        #         rotation_degrees.z = 0
        #     if Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_down"):
        #         rotation_degrees.z = 270
        #     elif Input.is_action_pressed("ui_down") and not Input.is_action_pressed("ui_up"):
        #         rotation_degrees.z = 90

        var rotZ = round(rotation_degrees.z)
        if rotZ == 0:
            rotation_vector = Vector2(-1, 0)
            level.player.global_transform.origin.y = global_transform.origin.y
            level.player.global_transform.origin.y -= 0.3
        elif rotZ == -90 or rotZ == 270:
            rotation_vector = Vector2(0, 1)
            level.player.global_transform.origin.x = global_transform.origin.x
        elif rotZ == -180 or rotZ == 180:
            rotation_vector = Vector2(1, 0)
            level.player.global_transform.origin.y = global_transform.origin.y
            level.player.global_transform.origin.y -= 0.3
        elif rotZ == -270 or rotZ == 90:
            rotation_vector = Vector2(0, -1)
            level.player.global_transform.origin.x = global_transform.origin.x
        level.player.tumbleFall(rotation_vector, false)
        if level.player.physics_state == level.player.PhysicsState.BEING_TOSSED:
            level.player.playBounce("grow")

func otherPassiveActivate(_delta, gameMover):
    if not gameMover.has_method("tumbleFall"):
        return
        
    level.player.gravitySound.play()
    gameMover.on_ground = false
    gameMover.truly_on_ground = false
    # gameMover.glitchTickle()
    gameMover.tryClearFallthroughCollisionSolid(self.global_transform.origin)
    var rotation_vector = Vector2(0, 0)
    var rotZ = stepify(rotation_degrees.z, 90)
    if rotZ == 0:
        rotation_vector = Vector2(-1, 0)
        gameMover.global_transform.origin.y = global_transform.origin.y
        gameMover.global_transform.origin.y -= 0.25
    elif rotZ == -90 or rotZ == 270:
        rotation_vector = Vector2(0, 1)
        gameMover.global_transform.origin.x = global_transform.origin.x
    elif rotZ == -180 or rotZ == 180:
        rotation_vector = Vector2(1, 0)
        gameMover.global_transform.origin.y = global_transform.origin.y
        gameMover.global_transform.origin.y -= 0.25 
    elif rotZ == -270 or rotZ == 90:
        rotation_vector = Vector2(0, -1)
        gameMover.global_transform.origin.x = global_transform.origin.x
    gameMover.tumbleFall(rotation_vector, true)


func stopPassiveActivate():
    pass

func justStopPassiveActivate():
    pass

var smack_timer = 0
export var smack_time_limit = 10
export var smack_recovery_time_limit = 12
var is_smacked = false
export var time_influence = 35
export var y_div = 2.3
export var normal_offset = .15
var smacked_palette = global.white_palette
var last_palette = global.base_palette
onready var notDieSound = get_node("NotDieSound")
func getSmacked(_broom_origin = null, _silently = false, _is_local_broom = false):
    if is_smacked:
        return false

    notDieSound.play()
    mySprite1.material_override.set_shader_param("time_influence", time_influence)
    mySprite1.material_override.set_shader_param("y_div", y_div)
    mySprite1.material_override.set_shader_param("normal_offset", normal_offset)
    mySprite1.material_override.set_shader_param("shake_power", 0.143)
    mySprite1.material_override.set_shader_param("shake_block_size", 60)
    mySprite1.material_override.set_shader_param("shake_color_rate", 0.219)
    last_palette = mySprite1.material_override.get_shader_param("target_palette")
    mySprite1.material_override.set_shader_param("target_palette", smacked_palette)
    smack_timer = 0
    is_smacked = true
    mushroom_walk_direction = -mushroom_walk_direction
    rotation_degrees.z -= 180
    rotation_degrees.z = int(rotation_degrees.z) % 360
    rotation_degrees.z = stepify(rotation_degrees.z, 90.0)
    # if rotation_degrees.z == 90 or rotation_degrees.z == -270:
    #     rotation_degrees.z = 0
    is_active = true
    return true

func unsmack():
    mySprite1.material_override.set_shader_param("time_influence", 16)
    mySprite1.material_override.set_shader_param("y_div", 2.3)
    mySprite1.material_override.set_shader_param("normal_offset", .02)
    mySprite1.material_override.set_shader_param("shake_power", 0.03)
    mySprite1.material_override.set_shader_param("shake_block_size", 30.5)
    mySprite1.material_override.set_shader_param("shake_color_rate", 0.01)
    mySprite1.material_override.set_shader_param("shake_power", 0.03)
    mySprite1.material_override.set_shader_param("target_palette", last_palette)
