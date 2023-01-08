extends "TreasureCollectable.gd"

var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")

export var behavior_walking = true
export var behavior_was_thrown = true
export var walk_direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process_input(true)
    set_process(true)
    set_physics_process(true)

func _process(_delta):
    if vv > 0:
        behavior_was_thrown = false

# @override
func pressingMoveLeft():
    return walk_direction == -1 and behavior_walking and not on_ground

# @override
func pressingMoveRight():
    return walk_direction == 1 and behavior_walking and not on_ground

func isActive():
    return visible and on_ground

# @override
func justPressedJump():
    return behavior_was_thrown

# @override
func isKindOfOnGround():
    return behavior_was_thrown

# @override
func alignMySprite():
    pass

func landed():
    get_node("SecretAnimationPlayer").play("land")

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
    for _i in range(num_clouds):
        var newSmokeCloud = smokeCloudRes.instance()
        level.add_child(newSmokeCloud)
        newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x + rand_range(-1, 1)
        newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + rand_range(-1, 1)
        newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
        if play_sound:
            newSmokeCloud.get_node("CleanGlitchSound").play()
            newSmokeCloud.get_node("CleanGlitchSound").pitch_scale = rand_range(0.8, 1.2)
            play_sound = false
        if is_glitchy:
            var new_material = newSmokeCloud.get_material_override().duplicate()
            new_material.set_shader_param("enable_glitch", "true")
            new_material.set_shader_param("target_palette", global.weird_base_palette)
            newSmokeCloud.set_material_override(new_material.duplicate())

func collectMe():
    get_node("SecretAnimationPlayer").play("GET")
    grav = 0
    getGameCamera().initial_target = level.player.get_node("CameraTarget")
    getGameCamera().actual_target = weakref(getGameCamera().initial_target)