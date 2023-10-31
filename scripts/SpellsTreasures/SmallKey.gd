extends "TreasureCollectable.gd"

var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")

export var behavior_walking = true
export var behavior_was_thrown = true
export var message = "got a key!"

var land_count = 0
var land_count_limit = 3

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    set_physics_process(true)

    if is_static_in_level and self.getMyStaticLevelZoneVar():
        visible = false

func _process(_delta):
    pauseSelf = not visible

func isActive():
    return visible and on_ground

# @override
func justPressedJump():
    return behavior_was_thrown and on_ground

# @override
func alignMySprite():
    pass

func landed():
    get_node("SecretAnimationPlayer").play("land")
    landSound.play()
    jump_force /= 2
    land_count += 1
    if land_count >= land_count_limit:
        behavior_was_thrown = false

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
    for _i in range(num_clouds):
        var newSmokeCloud = smokeCloudRes.instance()
        level.add_child(newSmokeCloud)
        newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x + rand_range(-1, 1)
        newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + rand_range(-1, 1)
        newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
        if play_sound:
            newSmokeCloud.tryPlaySound()
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
    collectSound.play()
    level.displayMessageText(message)