extends "TreasureCollectable.gd"

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
    set_physics_process(false)

    if is_static_in_level and self.getMyStaticLevelZoneVar():
        visible = false

    if grav == 0 and visible:
        landSound.play()
        yield(get_tree().create_timer(0.3), "timeout")
        landSound.play()
        yield(get_tree().create_timer(0.1), "timeout")
        landSound.play()

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

func isActive(_debug=false):
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

func collectMe():
    get_node("SecretAnimationPlayer").play("GET")
    grav = 0
    getGameCamera().initial_target = level.player.get_node("CameraTarget")
    getGameCamera().actual_target = weakref(getGameCamera().initial_target)
    collectSound.play()
    level.displayMessageText(tr("UI.Alert.1"))