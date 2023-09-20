extends "TreasureCollectable.gd"

var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
onready var sparkleSprite = get_node("SparkleSprite3D")
var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")

export var behavior_walking = true
export var behavior_was_thrown = true

var land_count = 0
var land_count_limit = 3
var spawn_timer = 0
var spawn_time_limit = 5

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    set_physics_process(true)

    if is_static_in_level and self.getMyStaticLevelZoneVar():
        visible = false

func _process(delta):
    pauseSelf = not visible
    if pauseSelf:
      return
    # spawn_timer += (delta*22)
    # if spawn_timer >= spawn_time_limit:
    #     spawn_timer = 0
    #     var bubble = bubbleRes.instance()
    #     level.add_child(bubble)
    #     bubble.global_transform.origin = self.global_transform.origin
    #     bubble.original_pos_x = self.global_transform.origin.x
    #     bubble.target_pos_x = self.global_transform.origin.x + rand_range(-1, 1)
    #     bubble.global_transform.origin.y += 1
    #     bubble.setAsParent(self)

    spawn_timer += (delta*22)
    if spawn_timer >= spawn_time_limit:
        var children = self.get_children()
        var num_children = 0
        for i in children:
            num_children += 1

        if num_children < 20:
            var newSprite = sparkleSprite.duplicate()
            newSprite.should_fizzle_out = true
            newSprite.visible = true
            var origin_diff = Vector3(
                stepify(rand_range(-1.0, 1.0), 0.125),
                stepify(rand_range(0.5, 1.5), 0.125),
                0
            )
            newSprite.updateBaseFrame(0, 0)
            newSprite.max_frames = 2
            level.add_child(newSprite)
            newSprite.global_transform.origin = self.global_transform.origin + origin_diff
            spawn_timer = 0

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
            pass
            # TODO(jaketrower): testing performance # 
            # var new_material = newSmokeCloud.get_material_override().duplicate()
            # new_material.set_shader_param("enable_glitch", "true")
            # new_material.set_shader_param("target_palette", global.weird_base_palette)
            # newSmokeCloud.set_material_override(new_material.duplicate())

func collectMe():
    get_node("SecretAnimationPlayer").play("GET")
    grav = 0
    getGameCamera().initial_target = level.player.get_node("CameraTarget")
    getGameCamera().actual_target = weakref(getGameCamera().initial_target)
    collectSound.play()
    level.displayMessageText("got an angel!")